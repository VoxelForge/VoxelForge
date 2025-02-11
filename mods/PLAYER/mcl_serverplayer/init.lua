mcl_serverplayer = {}

------------------------------------------------------------------------
-- Server-client communication.
------------------------------------------------------------------------

local modchannels = {}
local client_states = {}
mcl_serverplayer.client_states = client_states

minetest.register_on_joinplayer (function (player)
	assert (not modchannels[player])
	local channel = "mcl_player:" .. player:get_player_name ()
	modchannels[player] = minetest.mod_channel_join (channel)
	client_states[player] = {
		handshake_status = "want_hello",
	}
end)

minetest.register_on_leaveplayer (function (player)
	assert (modchannels[player])
	modchannels[player]:leave ()
	modchannels[player] = nil
	client_states[player] = nil
end)

-----------------------------------------------------------------------
-- Modchannel message definitions.
-----------------------------------------------------------------------

local MAX_PROTO_VERSION = 0

-- Serverbound messages.
local SERVERBOUND_HELLO = 'aa'
local SERVERBOUND_PLAYERPOSE = 'ab'
local SERVERBOUND_MOVEMENT_STATE = 'ac'
local SERVERBOUND_MOVEMENT_EVENT = 'ad'
local SERVERBOUND_PLAYERANIM = 'ae'
local SERVERBOUND_DAMAGE = 'af'
local SERVERBOUND_GET_AMMO = 'ag'
local SERVERBOUND_RELEASE_USEITEM = 'ah'
local SERVERBOUND_VISUAL_WIELDITEM = 'ai'
local SERVERBOUND_ACKNOWLEDGE_VEHICLE = 'aj'
local SERVERBOUND_REFUSE_VEHICLE = 'ak'
local SERVERBOUND_MOVE_VEHICLE = 'al'
local SERVERBOUND_CONFIGURE_VEHICLE = 'am'
local SERVERBOUND_TURN_VEHICLE = 'an'

-- Clientbound messages.
local CLIENTBOUND_HELLO = 'AA'
local CLIENTBOUND_PLAYER_CAPABILITIES = 'AB'
local CLIENTBOUND_ROCKET_USE = 'AC'
local CLIENTBOUND_REGISTER_ATTRIBUTE_MODIFIER = 'AD'
local CLIENTBOUND_REMOVE_ATTRIBUTE_MODIFIER = 'AE'
local CLIENTBOUND_REGISTER_STATUS_EFFECT = 'AF'
local CLIENTBOUND_REMOVE_STATUS_EFFECT = 'AG'
local CLIENTBOUND_POSECTRL = 'AH'
local CLIENTBOUND_SHIELDCTRL = 'AI'
local CLIENTBOUND_AMMOCTRL = 'AJ'
local CLIENTBOUND_BOW_CAPABILITIES = 'AK'
local CLIENTBOUND_VEHICLE_HANDOFF = 'AL'
local CLIENTBOUND_VEHICLE_POSITION = 'AM'
local CLIENTBOUND_RESCIND_VEHICLE = 'AN'
local CLIENTBOUND_VEHICLE_CAPABILITIES = 'AO'
local CLIENTBOUND_KNOCKBACK = 'AP'

local MAX_PAYLOAD = 65533

function mcl_serverplayer.send_player_capabilities (player, caps)
	local caps = minetest.write_json (caps)
	assert (#caps <= MAX_PAYLOAD, "oversized ClientboundPlayerCapabilities")
	modchannels[player]:send_all (table.concat ({
		CLIENTBOUND_PLAYER_CAPABILITIES,
		caps,
	}))
end

function mcl_serverplayer.send_rocket_use (player, duration)
	modchannels[player]:send_all (table.concat ({
		CLIENTBOUND_ROCKET_USE, duration,
	}))
end

function mcl_serverplayer.send_register_attribute_modifier (player, modifier)
	local modifier = minetest.write_json (modifier)
	assert (#modifier <= MAX_PAYLOAD, "oversized ClientboundRegisterAttributeModifier")
	modchannels[player]:send_all (table.concat ({
		CLIENTBOUND_REGISTER_ATTRIBUTE_MODIFIER, modifier,
	}))
end

function mcl_serverplayer.send_remove_attribute_modifier (player, field, id)
	local modifier = minetest.write_json ({
		field = field,
		id = id,
	})
	assert (#modifier <= MAX_PAYLOAD, "oversized ClientboundRemoveAttributeModifier")
	modchannels[player]:send_all (table.concat ({
		CLIENTBOUND_REMOVE_ATTRIBUTE_MODIFIER,
		modifier,
	}))
end

function mcl_serverplayer.send_register_status_effect (player, effect)
	local effect = minetest.write_json (effect)
	assert (#effect <= MAX_PAYLOAD, "oversized ClientboundRegisterStatusEffect")
	modchannels[player]:send_all (table.concat ({
		CLIENTBOUND_REGISTER_STATUS_EFFECT,
		effect,
	}))
end

function mcl_serverplayer.send_remove_status_effect (player, id)
	assert (#id <= MAX_PAYLOAD, "oversized ClientboundRemoveStatusEffect")
	modchannels[player]:send_all (table.concat ({
		CLIENTBOUND_REMOVE_STATUS_EFFECT, id,
	}))
end

function mcl_serverplayer.send_posectrl (player, override)
	modchannels[player]:send_all (table.concat ({
		CLIENTBOUND_POSECTRL, override or "",
	}))
end

function mcl_serverplayer.send_shieldctrl (player, active_shield)
	modchannels[player]:send_all (table.concat ({
		CLIENTBOUND_SHIELDCTRL, active_shield,
	}))
end

function mcl_serverplayer.send_ammoctrl (player, ammo, challenge)
	modchannels[player]:send_all (table.concat ({
		CLIENTBOUND_AMMOCTRL, ammo, ',', challenge,
	}))
end

function mcl_serverplayer.send_bow_capabilities (player, capabilities)
	local payload = core.write_json (capabilities)
	assert (#payload <= MAX_PAYLOAD, "oversized ClientboundBowCapabilities")
	modchannels[player]:send_all (table.concat {
		CLIENTBOUND_BOW_CAPABILITIES, payload,
	})
end

function mcl_serverplayer.send_vehicle_handoff (player, vehicle_type, objid)
	modchannels[player]:send_all (table.concat {
		CLIENTBOUND_VEHICLE_HANDOFF,
		vehicle_type, ",", objid,
	})
end

function mcl_serverplayer.send_vehicle_position (player, objid, pos, v)
	modchannels[player]:send_all (table.concat {
		CLIENTBOUND_VEHICLE_POSITION,
		objid, ",", pos.x, ",", pos.y, ",", pos.z,
		",", v.x, ",", v.y, ",", v.z,
	})
end

function mcl_serverplayer.send_rescind_vehicle (player, objid)
	modchannels[player]:send_all (table.concat {
		CLIENTBOUND_RESCIND_VEHICLE, objid,
	})
end

function mcl_serverplayer.send_vehicle_capabilities (player, objid, capabilities)
	capabilities.id = objid
	local payload = core.write_json (capabilities)
	assert (#payload <= MAX_PAYLOAD, "oversized ClientboundVehicleCapabilities")
	modchannels[player]:send_all (table.concat {
		CLIENTBOUND_VEHICLE_CAPABILITIES, payload,
	})
end

function mcl_serverplayer.send_knockback (player, kb)
	modchannels[player]:send_all (table.concat {
		CLIENTBOUND_KNOCKBACK, kb.x, ",", kb.y, ",", kb.z,
	})
end

-----------------------------------------------------------------------
-- Handshakes.  When a client joins, it is not considered CSM-enabled
-- till a SERVERBOUND_HELLO packet is received containing the protocol
-- version of the client.
--
-- Multiple CLIENTBOUND_HELLO messages are subsequently delivered
-- incorporating a variable length serialized handshake of the
-- following form:
--
--   {
--     proto = PROTO_VERSION,
--     node_definitions = ..., -- an abridgement of core.registered_nodes
--   }
--
-- The server subsequently waits for the client to deliver any packet,
-- thus concluding the handshake.
-----------------------------------------------------------------------

function mcl_serverplayer.is_csm_capable (player)
	return client_states[player]
		and (client_states[player].handshake_status
			== "complete")
end

local serverbound_handshake = {}
local keys_to_copy = {
	"_mcl_velocity_factor",
	"groups",
	"liquidtype",
	"_liquid_type",
	"climbable",
}

minetest.register_on_mods_loaded (function ()
	local tbl = {}
	for name, def in pairs (minetest.registered_nodes) do
		local def1 = {}
		for _, key in pairs (keys_to_copy) do
			def1[key] = def[key]
		end
		tbl[name] = def1
	end
	serverbound_handshake.node_definitions = tbl
	serverbound_handshake.bow_info = mcl_serverplayer.bow_info
end)

local function process_serverbound_hello (player, state, payload)
	if state.handshake_status ~= "want_hello" then
		error ("Duplicate ServerboundHello messages")
	end
	local proto = tonumber (payload)
	if proto then
		local proto = math.min (proto, MAX_PROTO_VERSION)
		client_states[player].proto = proto

		-- Generate the response.
		serverbound_handshake.proto = proto
		local payload = minetest.write_json (serverbound_handshake)
		if (#payload % MAX_PAYLOAD) == 0 then
			-- Insert trailing whitespace so that partial
			-- payloads may always be correctly terminated.
			payload = payload .. " "
		end
		local i = 1
		while i <= #payload do
			local max = math.min (i + MAX_PAYLOAD - 1, #payload)
			local substr = payload:sub (i, max)
			local str = table.concat ({
				CLIENTBOUND_HELLO,
				substr,
			})
			modchannels[player]:send_all (str)
			i = i + MAX_PAYLOAD
		end
		state.handshake_status = "want_acknowledgment"
		mcl_serverplayer.init_player (state, player)
	else
		error ("Invalid payload")
	end
end

local function process_serverbound_movement_state (player, state, payload)
	if state.handshake_status == "want_hello" then
		error ("ServerboundMovementState received before completion of handshake")
	end
	local json = minetest.parse_json (payload)
	if not json or type (json) ~= "table" then
		error ("Invalid ServerboundMovementState payload")
	end
	state.is_fall_flying = json.is_fall_flying
	state.is_sprinting = json.is_sprinting
	state.in_water = json.in_water
	state.is_swimming = json.is_swimming
end

-----------------------------------------------------------------------
-- Packet delivery.
-----------------------------------------------------------------------

local function check_table (value)
	if type (value) ~= "table" then
		error ("Invalid table: " .. dump (value))
	end
end

local function check_vector (value)
	if type (value) ~= "table"
		or type (value.x) ~= "number"
		or type (value.y) ~= "number"
		or type (value.z) ~= "number" then
		error ("Invalid vector: " .. dump (value))
	end
end

local function check_number (value)
	if type (value) ~= "number" then
		error ("Invalid number: " .. dump (value))
	end
end

local function receive_modchannel_message_1 (player, message)
	local msgtype = message:sub (1, 2)
	local payload = message:sub (3, #message)
	local state = client_states[player]

	if msgtype == SERVERBOUND_HELLO then
		process_serverbound_hello (player, state, payload)
	else
		if state.handshake_status == "want_acknowledgment" then
			local blurb = "Established CSM connection with client "
				.. player:get_player_name ()
			minetest.log ("action", blurb)
			state.handshake_status = "complete"
		end
		if msgtype == SERVERBOUND_PLAYERPOSE then
			local id = tonumber (payload)
			if not id then
				error ("Invalid player pose")
			end
			mcl_serverplayer.handle_playerpose (player, state, id)
		elseif msgtype == SERVERBOUND_MOVEMENT_STATE then
			process_serverbound_movement_state (player, state, payload)
		elseif msgtype == SERVERBOUND_MOVEMENT_EVENT then
			local id = tonumber (payload)
			if not id then
				error ("Invalid movement event payload")
			end
			mcl_serverplayer.handle_movement_event (player, id)
		elseif msgtype == SERVERBOUND_PLAYERANIM then
			mcl_serverplayer.handle_playeranim (player, state, payload)
		elseif msgtype == SERVERBOUND_DAMAGE then
			local json = minetest.parse_json (payload)
			if not json or type (json) ~= "table" then
				error ("Invalid movement damage payload")
			end
			if json.type == "fall" then
				-- Verify the collision list,
				-- damage_pos, and amount.
				if not json.collisions then
					json.collisions = {}
				end
				check_table (json.collisions)
				for _, item in pairs (json.collisions) do
					check_vector (item)
				end
				check_vector (json.damage_pos)
				check_number (json.amount)
			elseif json.type == "kinetic" then
				check_number (json.amount)
			end
			mcl_serverplayer.handle_damage (player, state, json)
		elseif msgtype == SERVERBOUND_GET_AMMO then
			local challenge = tonumber (payload)
			if not challenge or challenge <= state.ammo_challenge then
				error ("Invalid or out of order ServerboundGetAmmo message")
			end
			state.ammo_challenge = challenge
			mcl_serverplayer.update_ammo (state, player, true)
		elseif msgtype == SERVERBOUND_RELEASE_USEITEM then
			local ctrlwords = string.split (payload, ',')
			if #ctrlwords ~= 2
				or not (tonumber (ctrlwords[1]))
				or not (tonumber (ctrlwords[2]))
				or tonumber (ctrlwords[2]) <= state.ammo_challenge then
				error ("Invalid ServerboundReleaseUseitem message")
			end
			local usetime = tonumber (ctrlwords[1])
			local challenge = tonumber (ctrlwords[2])
			mcl_serverplayer.release_useitem (state, player, usetime, challenge)
		elseif msgtype == SERVERBOUND_VISUAL_WIELDITEM then
			local item = ItemStack (payload)

			if not item:is_empty () then
				state.visual_wielditem = item
			else
				state.visual_wielditem = nil
			end
		elseif msgtype == SERVERBOUND_ACKNOWLEDGE_VEHICLE then
			local id = tonumber (payload)
			if not id then
				error ("Invalid ServerboundAcknowledgeVehicle message")
			end
			mcl_serverplayer.handle_acknowledge_vehicle (player, state, id)
		elseif msgtype == SERVERBOUND_REFUSE_VEHICLE then
			local id = tonumber (payload)
			if not id then
				error ("Invalid ServerboundRefuseVehicle message")
			end
			mcl_serverplayer.handle_refuse_vehicle (player, state, id)
		elseif msgtype == SERVERBOUND_MOVE_VEHICLE then
			local id, tsc, x, y, z, vx, vy, vz
				= unpack (payload:split (','))
			if not id or not tsc or not x or not y or not z
				or not vx or not vy or not vz then
				error ("Parameters absent from ServerboundMoveVehicle message")
			end
			tsc = tonumber (tsc)
			id = tonumber (id)
			x = tonumber (x)
			y = tonumber (y)
			z = tonumber (z)
			vx = tonumber (vx)
			vy = tonumber (vy)
			vz = tonumber (vz)
			if not id or not tsc or not x or not y
				or not z or not vx or not vy or not vz then
				error ("Invalid ServerboundMoveVehicle message")
			end
			local pos = vector.new (x, y, z)
			local vel = vector.new (vx, vy, vz)
			mcl_serverplayer.handle_move_vehicle (player, state, id, tsc, pos, vel)
		elseif msgtype == SERVERBOUND_CONFIGURE_VEHICLE then
			local config = minetest.parse_json (payload)
			if not config then
				error ("Invalid configuration")
			end
			mcl_serverplayer.handle_configure_vehicle (player, state, config)
		elseif msgtype == SERVERBOUND_TURN_VEHICLE then
			local id, tsc, yaw = unpack (payload:split (','))
			if not id or not tsc or not yaw then
				error ("Parameters absent from ServerboundTurnVehicle message")
			end
			id = tonumber (id)
			tsc = tonumber (tsc)
			yaw = tonumber (yaw)
			if not id or not tsc or not yaw then
				error ("Invalid ServerboundTurnVehicle message")
			end
			mcl_serverplayer.handle_turn_vehicle (player, state, id, tsc, yaw)
		else
			minetest.log ("warning", table.concat ({
				"Client ", player:get_player_name (), " delivered",
				" unknown message of type '", msgtype,
				"'",
			}))
		end
	end
end

local function receive_modchannel_message (channel_name, sender, message)
	if channel_name == "mcl_player:" .. sender then
		local player = minetest.get_player_by_name (sender)
		if player then
			local _, err
				= pcall (receive_modchannel_message_1, player, message)
			if err then
				local reason = "Malformed serverbound message: " .. dump (err)
				minetest.kick_player (sender, reason)
			end
		end
	end
end

minetest.register_on_modchannel_message (receive_modchannel_message)

local modpath = minetest.get_modpath (minetest.get_current_modname ())
dofile (modpath .. "/player.lua")
dofile (modpath .. "/items.lua")
dofile (modpath .. "/mount.lua")
