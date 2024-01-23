-- Minetest 0.4 mod: player
-- See README.txt for licensing and other information.
mcl_player = {
	registered_player_models = {},
	registered_globalsteps = {},
	registered_on_visual_change = {},
	players = {},
}

local animation_blend = 0.2
local tpl_playerinfo = {
	textures = { "character.png", "blank.png", "blank.png" },
	model = "",
	animation = "",
	sneak = false,
	visible = true,
	attached = false,
	elytra = {active = false, rocketing = 0, speed = 0},
	is_pressing_jump = {},
	lastPos = nil,
	swimDistance = 0,
	jump_cooldown = -1,	-- Cooldown timer for jumping, we need this to prevent the jump exhaustion to increase rapidly
	vel_yaw = nil,
	is_swimming = false,
}

local function get_mouse_button(player)
	local controls = player:get_player_control()
	local get_wielded_item_name = player:get_wielded_item():get_name()
	if controls.RMB and not string.find(get_wielded_item_name, "mcl_bows:bow") and
		not string.find(get_wielded_item_name, "mcl_bows:crossbow") and
		not mcl_shields.wielding_shield(player, 1) and not mcl_shields.wielding_shield(player, 2) or controls.LMB then
		return true
	else
		return false
	end
end

function mcl_player.register_globalstep(func)
	table.insert(mcl_player.registered_globalsteps, func)
end

function mcl_player.player_register_model(name, def)
	mcl_player.registered_player_models[name] = def
end

function mcl_player.register_on_visual_change(func)
	table.insert(mcl_player.registered_on_visual_change, func)
end

function mcl_player.player_get_animation(player)
	local textures = mcl_player.players[player].textures

	if not mcl_player.players[player].visible then
		textures = table.copy(textures)
		textures[1] = "blank.png"
	end

	return {
		model = mcl_player.players[player].model,
		textures =  mcl_player.players[player].textures,
		animation =  mcl_player.players[player].animation,
		visibility = mcl_player.players[player].visibility
	}
end

local function update_player_textures(player)
	local textures = mcl_player.players[player].textures

	if not mcl_player.players[player].visible then
		textures = table.copy(textures)
		textures[1] = "blank.png"
	end

	player:set_properties({ textures = textures })

	-- Delay calling the callbacks because mods (including mcl_player)
	-- need to fully initialize player data from minetest.register_on_joinplayer
	-- before callbacks run
	minetest.after(0.1, function()
		if player:is_player() then
			for i, func in ipairs(mcl_player.registered_on_visual_change) do
				func(player)
			end
		end
	end)
end

-- Called when a player's appearance needs to be updated
function mcl_player.player_set_model(player, model_name)
	local model = mcl_player.registered_player_models[model_name]
	if model then
		if mcl_player.players[player].model == model_name then
			return
		end
		mcl_player.players[player].model = model_name
		player:set_properties({
			mesh = model_name,
			visual = "mesh",
			visual_size = model.visual_size or { x = 1, y = 1 },
			damage_texture_modifier = "^[colorize:red:130",
		})
		update_player_textures(player)
		mcl_player.player_set_animation(player, "stand")
	end
end

function mcl_player.player_set_visibility(player, visible)
	if mcl_player.players[player].visible == visible then return end
	mcl_player.players[player].visible = visible
	update_player_textures(player)
end

function mcl_player.player_set_skin(player, texture)
	mcl_player.players[player].textures[1] = texture
	update_player_textures(player)
end

function mcl_player.player_set_armor(player, texture)
	mcl_player.players[player].textures[2] = texture
	update_player_textures(player)
end

function mcl_player.get_player_formspec_model(player, x, y, w, h, fsname)
	local model = mcl_player.players[player].model
	local anim = mcl_player.registered_player_models[model].animations[mcl_player.players[player].animation]
	local textures = table.copy(mcl_player.players[player].textures)
	if not mcl_player.players[player].visible then
		textures[1] = "blank.png"
	end
	for k,v in pairs(textures) do
		textures[k] = minetest.formspec_escape(v)
	end
	return string.format("model[%s,%s;%s,%s;%s;%s;%s;0,180;false;false;%s,%s]", x, y, w, h, fsname, model,
		table.concat(textures, ","), anim.x, anim.y)
end

function mcl_player.player_set_animation(player, anim_name, speed)
	if mcl_player.players[player].animation == anim_name then
		return
	end
	local model = mcl_player.players[player].model and mcl_player.registered_player_models[mcl_player.players[player].model]
	if not (model and model.animations[anim_name]) then
		return
	end
	local anim = model.animations[anim_name]
	mcl_player.players[player].animation = anim_name
	player:set_animation(anim, speed or model.animation_speed, animation_blend)
end

-- Update appearance when the player joins
minetest.register_on_joinplayer(function(player)
	mcl_player.players[player] = table.copy(tpl_playerinfo)
	--player:set_local_animation({x=0, y=79}, {x=168, y=187}, {x=189, y=198}, {x=200, y=219}, 30)
	player:set_fov(86.1) -- see <https://minecraft.gamepedia.com/Options#Video_settings>>>>

	-- Minetest bug: get_bone_position() returns all zeros vectors.
	-- Workaround: call set_bone_position() one time first.
	player:set_bone_position("Head_Control", vector.new(0, 6.75, 0))
	player:set_bone_position("Arm_Right_Pitch_Control", vector.new(-3, 5.785, 0))
	player:set_bone_position("Arm_Left_Pitch_Control", vector.new(3, 5.785, 0))
	player:set_bone_position("Body_Control", vector.new(0, 6.75, 0))
end)

minetest.register_on_leaveplayer(function(player)
	mcl_player.players[player] = nil
end)

-- Check each player and run callbacks
minetest.register_globalstep(function(dtime)
	for _, player in pairs(minetest.get_connected_players()) do
		for _, func in pairs(mcl_player.registered_globalsteps) do
			func(player, dtime)
		end
	end
end)

mcl_player.register_globalstep(function(player, dtime)
	local name = player:get_player_name()
	local model_name = mcl_player.players[player].model
	local model = model_name and mcl_player.registered_player_models[model_name]
	if model and not mcl_player.players[player].attached then
		local controls = player:get_player_control()
		local walking = false
		local animation_speed_mod = model.animation_speed or 30

		-- Determine if the player is walking
		if controls.up or controls.down or controls.left or controls.right then
			walking = true
		end

		-- Determine if the player is sneaking, and reduce animation speed if so
		if controls.sneak then
			animation_speed_mod = animation_speed_mod / 2
		end

		if mcl_shields.is_blocking(player) then
			animation_speed_mod = animation_speed_mod / 2
		end

		-- ask if player is swiming
		local head_in_water = minetest.get_item_group(mcl_playerinfo[name].node_head, "water") ~= 0
		-- ask if player is sprinting
		local is_sprinting = mcl_sprint.is_sprinting(name)

		local velocity = player:get_velocity() or player:get_player_velocity()

		-- Apply animations based on what the player is doing
		if player:get_hp() == 0 then
			mcl_player.player_set_animation(player, "die")
		elseif mcl_player.players[player].elytra and mcl_player.players[player].elytra.active then
			mcl_player.player_set_animation(player, "stand")
		elseif walking and velocity.x > 0.35
			or walking and velocity.x < -0.35
			or walking and velocity.z > 0.35
			or walking and velocity.z < -0.35 then
			local wielded_itemname = player:get_wielded_item():get_name()
			local no_arm_moving = string.find(wielded_itemname, "mcl_bows:bow") or
				mcl_shields.wielding_shield(player, 1) or
				mcl_shields.wielding_shield(player, 2)
			if mcl_player.players[player].sneak ~= controls.sneak then
				mcl_player.players[player].animation = nil
				mcl_player.players[player].sneak = controls.sneak
			end
			if get_mouse_button(player) == true and not controls.sneak and head_in_water and is_sprinting == true then
				mcl_player.player_set_animation(player, "swim_walk_mine", animation_speed_mod)
			elseif not controls.sneak and head_in_water and is_sprinting == true then
				mcl_player.player_set_animation(player, "swim_walk", animation_speed_mod)
			elseif no_arm_moving and controls.RMB and controls.sneak or string.find(wielded_itemname, "mcl_bows:crossbow_") and controls.sneak then
				mcl_player.player_set_animation(player, "bow_sneak", animation_speed_mod)
			elseif no_arm_moving and controls.RMB or string.find(wielded_itemname, "mcl_bows:crossbow_") then
				mcl_player.player_set_animation(player, "bow_walk", animation_speed_mod)
			elseif is_sprinting == true and get_mouse_button(player) == true and not controls.sneak and not head_in_water then
				mcl_player.player_set_animation(player, "run_walk_mine", animation_speed_mod)
			elseif get_mouse_button(player) == true and not controls.sneak then
				mcl_player.player_set_animation(player, "walk_mine", animation_speed_mod)
			elseif get_mouse_button(player) == true and controls.sneak and is_sprinting ~= true then
				mcl_player.player_set_animation(player, "sneak_walk_mine", animation_speed_mod)
			elseif is_sprinting == true and not controls.sneak and not head_in_water then
				mcl_player.player_set_animation(player, "run_walk", animation_speed_mod)
			elseif controls.sneak and get_mouse_button(player) ~= true then
				mcl_player.player_set_animation(player, "sneak_walk", animation_speed_mod)
			else
				mcl_player.player_set_animation(player, "walk", animation_speed_mod)
			end
		elseif get_mouse_button(player) == true and not controls.sneak and head_in_water and is_sprinting == true then
			mcl_player.player_set_animation(player, "swim_mine")
		elseif get_mouse_button(player) ~= true and not controls.sneak and head_in_water and is_sprinting == true then
			mcl_player.player_set_animation(player, "swim_stand")
		elseif get_mouse_button(player) == true and not controls.sneak then
			mcl_player.player_set_animation(player, "mine")
		elseif get_mouse_button(player) == true and controls.sneak then
			mcl_player.player_set_animation(player, "sneak_mine")
		elseif not controls.sneak and head_in_water and is_sprinting == true then
			mcl_player.player_set_animation(player, "swim_stand", animation_speed_mod)
		elseif not controls.sneak then
			mcl_player.player_set_animation(player, "stand", animation_speed_mod)
		else
			mcl_player.player_set_animation(player, "sneak_stand", animation_speed_mod)
		end
	end
end)
