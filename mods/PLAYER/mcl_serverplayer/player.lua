------------------------------------------------------------------------
-- Poses, animations, physics, and damage, for client-side players.
------------------------------------------------------------------------

local S = minetest.get_translator (minetest.get_current_modname ())
local client_poses = {}
local persistent_physics_factors = {}

minetest.register_on_joinplayer (function (player)
	if not client_poses[player] then
		client_poses[player] = {}
	end
	if not persistent_physics_factors[player] then
		mcl_serverplayer.load_persistent_physics_factors (player)
	end
end)

minetest.register_on_leaveplayer (function (player)
	client_poses[player] = nil
	mcl_serverplayer.save_persistent_physics_factors (player)
	persistent_physics_factors[player] = nil
end)

local POSE_STANDING = 1
local POSE_CROUCHING = 2
local POSE_SLEEPING = 3
local POSE_FALL_FLYING = 4
local POSE_SWIMMING = 5
local POSE_SIT_MOUNTED = 6
local POSE_MOUNTED = 7
local POSE_DEATH = 8

mcl_serverplayer.POSE_STANDING = POSE_STANDING
mcl_serverplayer.POSE_CROUCHING = POSE_CROUCHING
mcl_serverplayer.POSE_SLEEPING = POSE_SLEEPING
mcl_serverplayer.POSE_FALL_FLYING = POSE_FALL_FLYING
mcl_serverplayer.POSE_SIT_MOUNTED = POSE_SIT_MOUNTED
mcl_serverplayer.POSE_MOUNTED = POSE_MOUNTED
mcl_serverplayer.POSE_DEATH = POSE_DEATH

local PLAYER_EVENT_JUMP = 1

function mcl_serverplayer.post_load_model (player, model)
	-- This function is apt to be called by an earlier joinplayer
	-- handler.
	if not client_poses[player] then
		client_poses[player] = {}
	end
	local poses = {
		[POSE_STANDING] = {
			stand = model.animations.stand,
			walk = model.animations.walk,
			mine = model.animations.mine,
			walk_mine = model.animations.walk_mine,
			walk_bow = model.animations.bow_walk,
			collisionbox = mcl_player.player_props_normal.collisionbox,
			eye_height = mcl_player.player_props_normal.eye_height,
		},
		[POSE_CROUCHING] = {
			stand = model.animations.sneak_stand,
			walk = model.animations.sneak_walk,
			mine = model.animations.sneak_mine,
			walk_bow = model.animations.bow_sneak,
			walk_mine = model.animations.sneak_walk_mine,
			collisionbox = mcl_player.player_props_sneaking.collisionbox,
			eye_height = mcl_player.player_props_sneaking.eye_height,
		},
		[POSE_SLEEPING] = {
			stand = model.animations.lay,
			walk = model.animations.lay,
			mine = model.animations.lay,
			walk_bow = model.animations.lay,
			walk_mine = model.animations.lay,
			collisionbox = mcl_player.player_props_normal.collisionbox,
			eye_height = 0.3,
		},
		[POSE_FALL_FLYING] = {
			stand = model.animations.fly,
			walk = model.animations.fly,
			mine = model.animations.fly,
			walk_bow = model.animations.fly,
			walk_mine = model.animations.fly,
			collisionbox = mcl_player.player_props_elytra.collisionbox,
			eye_height = mcl_player.player_props_elytra.eye_height,
		},
		[POSE_SWIMMING] = {
			stand = model.animations.swim_stand,
			walk = model.animations.swim_walk,
			mine = model.animations.swim_mine,
			walk_bow = model.animations.swim_walk,
			walk_mine = model.animations.swim_walk_mine,
			collisionbox = mcl_player.player_props_swimming.collisionbox,
			eye_height = mcl_player.player_props_swimming.eye_height,
		},
		[POSE_SIT_MOUNTED] = {
			stand = model.animations.sit_mount,
			walk = model.animations.sit_mount,
			mine = model.animations.sit_mount,
			walk_bow = model.animations.sit_mount,
			walk_mine = model.animations.sit_mount,
			collisionbox = mcl_player.player_props_normal.collisionbox,
			eye_height = mcl_player.player_props_normal.eye_height,
		},
		[POSE_MOUNTED] = {
			stand = model.animations.sit,
			walk = model.animations.sit,
			mine = model.animations.sit,
			walk_bow = model.animations.sit,
			walk_mine = model.animations.sit,
			collisionbox = mcl_player.player_props_normal.collisionbox,
			eye_height = mcl_player.player_props_normal.eye_height,
		},
		[POSE_DEATH] = {
			stand = model.animations.die,
			walk = model.animations.die,
			mine = model.animations.die,
			walk_bow = model.animations.die,
			walk_mine = model.animations.die,
			collisionbox = mcl_player.player_props_normal.collisionbox,
			eye_height = mcl_player.player_props_normal.eye_height,
		},
	}
	local caps = {
		pose_defs = poses,
	}
	if mcl_serverplayer.is_csm_capable (player) then
		mcl_serverplayer.send_player_capabilities (player, caps)
		mcl_serverplayer.refresh_pose (player)
	end
	client_poses[player] = poses
end

mcl_serverplayer.movement_arresting_nodes = {
	["mcl_farming:sweet_berry_bush_0"] = {
		x = 0.8,
		y = 0.75,
		z = 0.8,
	},
	["mcl_farming:sweet_berry_bush_1"] = {
		x = 0.8,
		y = 0.75,
		z = 0.8,
	},
	["mcl_farming:sweet_berry_bush_2"] = {
		x = 0.8,
		y = 0.75,
		z = 0.8,
	},
	["mcl_farming:sweet_berry_bush_3"] = {
		x = 0.8,
		y = 0.75,
		z = 0.8,
	},
	["mcl_core:cobweb"] = {
		x = 0.25,
		y = 0.10,
		z = 0.25,
	},
	["mcl_powder_snow:powder_snow"] = {
		x = 0.9,
		y = 1.5,
		z = 0.9,
	},
}

function mcl_serverplayer.init_player (client_state, player)
	local can_sprint = not mcl_hunger.active
		or mcl_hunger.get_hunger (player) > 6

	local inv = player:get_inventory ()
	local stack = inv:get_stack ("armor", 3)
	local boots = inv:get_stack ("armor", 5)
	local can_fall_fly
		= minetest.get_item_group (stack:get_name (), "elytra") > 0
		and mcl_armor.elytra_usable (stack)
	local level = mcl_enchanting.get_enchantment (boots, "depth_strider")
	local initial_caps = {
		pose_defs = client_poses[player],
		movement_arresting_nodes
			= mcl_serverplayer.movement_arresting_nodes,
		can_sprint = can_sprint,
		can_fall_fly = can_fall_fly,
		depth_strider_level = level,
		gamemode = mcl_gamemode.get_gamemode (player),
	}
	client_state.ammo_challenge = 0
	client_state.ammo = 0
	client_state.pose = POSE_STANDING
	client_state.anim = "stand"
	client_state.can_sprint = can_sprint
	client_state.can_fall_fly = can_fall_fly
	client_state.depth_strider_level = level
	client_state.movement_statistics = {
		dist_swum = 0.0,
		dist_walked_in_water = 0.0,
		dist_sprinted = 0.0,
	}
	mcl_serverplayer.send_player_capabilities (player, initial_caps)
	for id, modifier in pairs (persistent_physics_factors[player]) do
		mcl_serverplayer.send_register_attribute_modifier (player, modifier)
	end
	mcl_potions.send_effects_to_client (player)
end

function mcl_serverplayer.sprinting_locally (player)
	if mcl_serverplayer.client_states[player] then
		return mcl_serverplayer.client_states[player].is_sprinting
	end
	return false
end

function mcl_serverplayer.set_depth_strider_level (player, level)
	local state = mcl_serverplayer.client_states[player]
	if not state then
		return
	end
	if level ~= state.depth_strider_level then
		state.depth_strider_level = level
		mcl_serverplayer.send_player_capabilities (player, {
			depth_strider_level = level,
		})
	end
end

function mcl_serverplayer.set_fall_flying_capable (player, can_fall_fly)
	local state = mcl_serverplayer.client_states[player]
	if not state then
		return
	end
	if can_fall_fly ~= state.can_fall_fly then
		state.can_fall_fly = can_fall_fly
		mcl_serverplayer.send_player_capabilities (player, {
			can_fall_fly = can_fall_fly,
		})
	end
end

local function apply_pose (state, player, poseid)
	local pose_table = client_poses[player][poseid]

	if not pose_table then
		return
	end

	-- Apply the pose in question.
	player:set_properties ({
		eye_height = pose_table.eye_height,
		collisionbox = pose_table.collisionbox,
	})
	player:set_animation (pose_table[state.anim])
end

function mcl_serverplayer.refresh_pose (player)
	local state = mcl_serverplayer.client_states[player]
	if state then
		apply_pose (state, player, state.override_pose or state.pose)
	end
end

function mcl_serverplayer.handle_playerpose (player, state, poseid)
	if poseid < POSE_STANDING or poseid > POSE_DEATH then
		error ("Unknown pose " .. poseid)
	end

	if poseid ~= state.pose then
		state.pose = poseid
		if not state.override_pose then
			-- Apply this pose.
			apply_pose (state, player, poseid)
		end
	end
end

function mcl_serverplayer.handle_playeranim (player, state, animname)
	if animname ~= state.anim then
		state.anim = animname

		-- Don't apply this animation if it doesn't exist yet.
		local pose_table = client_poses[player][state.pose]
		if pose_table and pose_table[animname] then
			player:set_animation (pose_table[animname])
		end
	end
end

local function dir_to_pitch (dir)
	local xz = math.abs (dir.x) + math.abs (dir.z)
	return -math.atan2 (-dir.y, xz)
end

function mcl_serverplayer.check_movement (state, player, self_pos)
	local last_pos = state.last_pos
	if last_pos and not vector.equals (self_pos, last_pos) then
		local stats = state.movement_statistics
		local d = vector.distance (self_pos, last_pos)
		local name = player:get_player_name ()
		if state.in_water or state.pose == POSE_SWIMMING then
			local old = math.floor (stats.dist_swum)
			stats.dist_swum = stats.dist_swum + d
			local new = math.floor (stats.dist_swum)
			if new - old > 0 then
				local exhaustion = mcl_hunger.EXHAUST_SWIM * (new - old)
				mcl_hunger.exhaust (name, exhaustion)
			end
		elseif state.is_sprinting then
			local old = math.floor (stats.dist_sprinted)
			stats.dist_sprinted = stats.dist_sprinted + d
			local new = math.floor (stats.dist_sprinted)
			if new - old > 0 then
				local exhaustion = mcl_hunger.EXHAUST_SPRINT * (new - old)
				mcl_hunger.exhaust (name, exhaustion)
			end
		end
	end
	if last_pos and (math.abs (self_pos.x - last_pos.x) > 0.05
				or math.abs (self_pos.z - last_pos.z) > 0.05) then
		local d = vector.direction (last_pos, self_pos)
		state.move_yaw = math.atan2 (d.z, d.x) - math.pi / 2
		state.move_pitch = dir_to_pitch (d)
		if not state.move_pitch then
			state.move_pitch = 0
		else
			state.move_pitch = state.move_pitch
				+ -state.move_pitch * 0.25
		end
	end
	if not state.move_yaw then
		state.move_yaw = player:get_look_horizontal ()
	end
	if not state.move_pitch then
		state.move_pitch = 0
	end
	state.last_pos = self_pos
end

local FOURTY_DEG = math.rad (40)
local TWENTY_DEG = math.rad (20)
local SEVENTY_FIVE_DEG = math.rad (75)
local FIFTY_DEG = math.rad (50)
local ONE_HUNDRED_AND_TEN_DEG = math.rad (110)

local RIGHT_ARM_BLOCKING_OVERRIDE = {
	rotation = {
		vec = vector.new (20, -20, 0):apply (math.rad),
		absolute = true,
	},
}

local LEFT_ARM_BLOCKING_OVERRIDE = {
	rotation = {
		vec = vector.new (20, 20, 0):apply (math.rad),
		absolute = true,
	},
}

function mcl_serverplayer.get_visual_wielditem (player)
	local state = mcl_serverplayer.client_states[player]
	if state and state.visual_wielditem then
		return state.visual_wielditem
	end
	return player:get_wielded_item ()
end

local norm_radians = mcl_util.norm_radians

local ZERO_OVERRIDE = {
	rotation = {
		vec = vector.zero (),
		absolute = true,
	},
}

local DEFAULT_ANIMATION_SPEED = 30

function mcl_serverplayer.animate_localplayer (state, player)
	local speed = DEFAULT_ANIMATION_SPEED
	local look_dir = norm_radians (player:get_look_horizontal ())
	local pose = state.override_pose or state.pose
	local blocking = mcl_shields.is_blocking (player)

	if pose == POSE_CROUCHING or (blocking and blocking ~= 0) then
		speed = speed / 2
	end

	if speed ~= state.animation_speed then
		player:set_animation_frame_speed (speed)
		state.animation_speed = speed
	end

	if pose == POSE_STANDING or pose == POSE_CROUCHING
		or pose == POSE_MOUNTED or pose == POSE_SIT_MOUNTED then
		-- Animate body.
		if pose == POSE_MOUNTED or pose == POSE_SIT_MOUNTED then
			local attach = player:get_attach ()
			if attach then
				local yaw = attach:get_yaw ()
				local yrot = -norm_radians (look_dir - norm_radians (yaw))
				local pitch = -player:get_look_vertical ()
				player:set_bone_override ("Body_Control", ZERO_OVERRIDE)
				player:set_bone_override ("Head_Control", {
					rotation = {
						vec = vector.new (pitch, yrot, 0),
						absolute = true,
					},
				})
			end
		else
			local move_yaw = norm_radians (state.move_yaw)
			local diff = norm_radians (move_yaw - look_dir)
			if diff > FOURTY_DEG then
				move_yaw = look_dir + FOURTY_DEG
			elseif diff < -FOURTY_DEG then
				move_yaw = look_dir - FOURTY_DEG
			end
			state.move_yaw = move_yaw
			local body = look_dir - move_yaw
			local rot = vector.new (0, body, 0)
			player:set_bone_override ("Body_Control", {
				rotation = { vec = rot, absolute = true, },
			})
			rot.y = move_yaw - look_dir
			rot.x = -player:get_look_vertical ()
			player:set_bone_override ("Head_Control", {
				rotation = { vec = rot, absolute = true, },
			})
		end
		-- Control arm rotation whilst blocking.
		if blocking == 2 then
			player:set_bone_override ("Arm_Right_Pitch_Control",
						RIGHT_ARM_BLOCKING_OVERRIDE)
			player:set_bone_override ("Arm_Left_Pitch_Control", nil)
		elseif blocking == 1 then
			player:set_bone_override ("Arm_Right_Pitch_Control", nil)
			player:set_bone_override ("Arm_Left_Pitch_Control",
						LEFT_ARM_BLOCKING_OVERRIDE)
		else
			player:set_bone_override ("Arm_Right_Pitch_Control", nil)
			player:set_bone_override ("Arm_Left_Pitch_Control", nil)
		end
	elseif pose == POSE_SWIMMING then
		local pitch = player:get_look_vertical ()
		local move_yaw = norm_radians (state.move_yaw)
		local move_pitch = state.move_pitch
		local rot = vector.new ((pitch - move_pitch) + TWENTY_DEG,
			move_yaw - look_dir, 0)
		player:set_bone_override ("Head_Control", {
			rotation = { vec = rot, absolute = true, },
		})
		rot.x = SEVENTY_FIVE_DEG + move_pitch
		rot.y = move_yaw - look_dir
		rot.z = math.pi
		player:set_bone_override ("Body_Control", {
			rotation = { vec = rot, absolute = true, },
		})
		state.move_yaw = move_yaw
	elseif pose == POSE_FALL_FLYING then
		local move_pitch = state.move_pitch
		local move_yaw = norm_radians (state.move_yaw)
		local xrot = move_pitch + FIFTY_DEG
		local yrot = move_yaw - look_dir
		local rot = vector.new (xrot, yrot, 0)
		player:set_bone_override ("Head_Control", {
			rotation = { vec = rot, absolute = true, },
		})
		local xrot = move_pitch + ONE_HUNDRED_AND_TEN_DEG
		local yrot = -move_yaw + norm_radians (look_dir)
		rot.x = xrot
		rot.y = yrot
		rot.z = math.pi
		player:set_bone_override ("Body_Control", {
			rotation = { vec = rot, absolute = true, },
		})
		state.move_yaw = move_yaw
	elseif pose == POSE_SLEEPING then
		player:set_bone_override ("Head_Control", {})
		player:set_bone_override ("Body_Control", {
			rotation = {
				vec = vector.new (0, math.pi, 0),
				absolute = true,
			},
		})
	elseif pose == POSE_DEATH then
		player:set_bone_override ("Head_Control", {})
		player:set_bone_override ("Body_Control", {})
	end

	local wielditem = state.visual_wielditem
		or player:get_wielded_item ()
	local wielded_def = wielditem:get_definition ()
	local name = wielditem:get_name ()
	mcl_player.position_wielditem (name, wielded_def, player)
end

function mcl_serverplayer.globalstep (player, dtime)
	local state = mcl_serverplayer.client_states[player]
	local self_pos = player:get_pos ()
	mcl_serverplayer.check_movement (state, player, self_pos)
	if state.is_sprinting then
		mcl_sprint.spawn_particles (player, self_pos)
	end
	if mcl_hunger.active then
		if state.can_sprint and mcl_hunger.get_hunger (player) <= 6 then
			state.can_sprint = false
			mcl_serverplayer.send_player_capabilities (player, {
				can_sprint = false,
			})
		elseif not state.can_sprint and mcl_hunger.get_hunger (player) > 6 then
			state.can_sprint = true
			mcl_serverplayer.send_player_capabilities (player, {
				can_sprint = true,
			})
		end
	end
	mcl_serverplayer.animate_localplayer (state, player)
	local name = player:get_player_name ()
	if state.is_fall_flying and not minetest.is_creative_enabled (name) then
		local fall_flown_ticks = (state.fall_flown_ticks or 0) + dtime
		if fall_flown_ticks >= 1 then
			local inv = player:get_inventory ()
			local elytra = inv:get_stack ("armor", 3)
			if minetest.get_item_group (elytra:get_name (), "elytra") > 0 then
				local penalty = math.floor (fall_flown_ticks)
				local durability = mcl_util.calculate_durability (elytra)
				local remaining = math.floor ((65536 - elytra:get_wear ())
								* durability / 65536)
				local uses = math.min (penalty, remaining - 1)
				fall_flown_ticks = fall_flown_ticks - penalty
				mcl_util.use_item_durability (elytra, uses)
				-- If this is not a pair of elytra,
				-- this invalid state should be
				-- corrected soon by the client,
				-- provided it cooperates...

				if remaining - uses <= 1 then
					-- Disable fall flying once
					-- the elytra's durability is
					-- depleted.
					mcl_serverplayer.set_fall_flying_capable (player, false)
					mcl_armor.disable_elytra (elytra)
				end
				inv:set_stack ("armor", 3, elytra)
			end
		end
		state.fall_flown_ticks = fall_flown_ticks
	end
	mcl_serverplayer.update_ammo (state, player, false)
	mcl_serverplayer.validate_mounting (state, player, dtime)
end

function mcl_serverplayer.handle_movement_event (player, event)
	if event == PLAYER_EVENT_JUMP then
		if not mcl_hunger.active then
			return
		end

		local exhaustion
		if mcl_serverplayer.sprinting_locally (player) then
			exhaustion = mcl_hunger.EXHAUST_SPRINT_JUMP
		else
			exhaustion = mcl_hunger.EXHAUST_JUMP
		end
		mcl_hunger.exhaust (player:get_player_name (), exhaustion)
	else
		error ("Unknown movement event " .. event)
	end
end

function mcl_serverplayer.use_rocket (user, duration)
	local state = mcl_serverplayer.client_states[user]
	assert (state)
	if not state.can_fall_fly then
		mcl_title.set (user, "actionbar", {
			text = S("Elytra not equipped."),
			color = "white",
			stay = 60,
		})
		return false
	elseif not state.is_fall_flying then
		mcl_title.set (user, "actionbar", {
			text = S("Elytra not deployed. Jump while falling down to deploy."),
			color = "white",
			stay = 60,
		})
		return false
	else
		mcl_serverplayer.send_rocket_use (user, duration)
		return true
	end
end

function mcl_serverplayer.handle_damage (player, state, payload)
	if payload.type == "fall" then
		local damage = math.ceil (payload.amount)
		if damage < 0 then
			-- This will kick the client.
			error ("Outrageous fall damage request")
		end

		-- Apply `fall_damage_add_percent' node definitions.
		local greatest = 0.0
		for _, node in pairs (payload.collisions) do
			local name = minetest.get_node (node).name
			local def = minetest.registered_nodes[name]
			if def and def.groups.fall_damage_add_percent then
				local this = def.groups.fall_damage_add_percent
				if this < 0 then
					greatest = this
				else
					greatest = math.max (greatest, this)
				end
			end
		end
		damage = math.max (0, damage + damage * (greatest / 100.0))
		local reason = {type = "fall"}
		mcl_damage.finish_reason (reason)
		mcl_damage.damage_player (player, damage, reason)

		-- If payload.riding is set, it should designate a mob
		-- that is the player's current vehicle.
		if payload.riding then
			local object = minetest.object_refs[payload.riding]
			if object and object == state.vehicle then
				mcl_util.deal_damage (object, damage, reason)
			end
		end
	elseif payload.type == "kinetic" then
		local damage = math.ceil (payload.amount)
		if damage < 0 then
			-- This will kick the client.
			error ("Absurd kinetic damage request")
		end
		local reason = {type = "fly_into_wall"}
		mcl_damage.finish_reason (reason)
		mcl_damage.damage_player (player, damage, reason)
	else
		local blurb = "Client requesting unknown damage: "
			.. dump (payload)
		minetest.log ("warning", blurb)
	end
end

function mcl_serverplayer.is_swimming (player)
	if mcl_serverplayer.is_csm_capable (player) then
		local state = mcl_serverplayer.client_states[player]
		return state.is_swimming
	end
	return false
end

function mcl_serverplayer.in_singleheight_pose (player)
	if mcl_serverplayer.is_csm_capable (player) then
		local state = mcl_serverplayer.client_states[player]
		local pose = state.override_pose or state.pose
		return pose == POSE_FALL_FLYING
			or pose == POSE_SLEEPING
			or pose == POSE_SWIMMING
	end
	return false
end

mcl_player.register_globalstep (function (player, dtime)
	if mcl_serverplayer.is_csm_capable (player) then
		mcl_serverplayer.globalstep (player, dtime)
	end
end)

-- Override PLAYER's active pose, or annul the override if POSEID is
-- nil.  This pose will remain effect server-side till the player
-- leaves or the override is annulled.

function mcl_serverplayer.override_pose (player, poseid)
	if mcl_serverplayer.is_csm_capable (player) then
		local state = mcl_serverplayer.client_states[player]
		state.override_pose = poseid

		if poseid then
			apply_pose (state, player, poseid)
			mcl_serverplayer.send_posectrl (player, poseid)
		else
			apply_pose (state, player, state.pose)
			mcl_serverplayer.send_posectrl (player, false)
		end
	end
end

function mcl_serverplayer.handle_blocking (player, blocking)
	if mcl_serverplayer.is_csm_capable (player) then
		mcl_serverplayer.send_shieldctrl (player, blocking)
	end
end

------------------------------------------------------------------------
-- Client-side physics factors.  These attribute modifiers are sent to
-- clients upon connection and _are persistent_ on the server.
------------------------------------------------------------------------

function mcl_serverplayer.load_persistent_physics_factors (player)
	local meta = player:get_meta ()
	local str = meta:get_string ("mcl_serverplayer:attributes")
	persistent_physics_factors[player] = minetest.deserialize (str) or {}
end

function mcl_serverplayer.save_persistent_physics_factors (player)
	local meta = player:get_meta ()
	if persistent_physics_factors[player] then
		local data = minetest.serialize (persistent_physics_factors[player])
		meta:set_string ("mcl_serverplayer:attributes", data)
	end
end

minetest.register_on_shutdown (function ()
	for player in mcl_util.connected_players () do
		mcl_serverplayer.save_persistent_physics_factors (player)
	end
end)

function mcl_serverplayer.add_physics_factor (player, field, id, factor, op)
	local modifier = {
		field = field,
		id = id,
		value = factor,
		op = op,
	}
	if not persistent_physics_factors[player] then
		mcl_serverplayer.load_persistent_physics_factors (player)
	end
	persistent_physics_factors[player][id] = modifier
	if mcl_serverplayer.is_csm_capable (player) then
		mcl_serverplayer.send_register_attribute_modifier (player, modifier)
	end
end

function mcl_serverplayer.remove_physics_factor (player, field, id)
	if not persistent_physics_factors[player] then
		mcl_serverplayer.load_persistent_physics_factors (player)
	end
	persistent_physics_factors[player][id] = nil
	if mcl_serverplayer.is_csm_capable (player) then
		mcl_serverplayer.send_remove_attribute_modifier (player, field, id)
	end
end

------------------------------------------------------------------------
-- Client-side status effects.
------------------------------------------------------------------------

function mcl_serverplayer.add_status_effect (object, effect)
	if mcl_serverplayer.is_csm_capable (object) then
		mcl_serverplayer.send_register_status_effect (object, effect)
	else
		-- This might be a mob interested in tracking its
		-- status effects.
		local entity = object:get_luaentity ()
		if entity and entity.register_status_effect then
			entity:register_status_effect (effect)
		end
	end
end

function mcl_serverplayer.remove_status_effect (object, id)
	if mcl_serverplayer.is_csm_capable (object) then
		mcl_serverplayer.send_remove_status_effect (object, id)
	else
		-- This might be a mob interested in tracking its
		-- status effects.
		local entity = object:get_luaentity ()
		if entity and entity.remove_status_effect then
			entity:remove_status_effect (id)
		end
	end
end

------------------------------------------------------------------------
-- Game modes.
------------------------------------------------------------------------

mcl_gamemode.register_on_gamemode_change (function (player, _, gamemode)
	if mcl_serverplayer.is_csm_capable (player) then
		mcl_serverplayer.send_player_capabilities (player, {
			gamemode = gamemode,
		})
	end
end)
