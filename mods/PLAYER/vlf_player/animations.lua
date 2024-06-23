vlf_player.registered_player_models = {}
vlf_player.registered_on_visual_change = {}

local animation_blend = 0.2

local player_props_elytra = {
	collisionbox = { -0.35, 0, -0.35, 0.35, 0.8, 0.35 },
	eye_height = 0.6,
	nametag_color = { r = 225, b = 225, a = 225, g = 225 }
}
local player_props_riding = {
	collisionbox = { -0.312, 0, -0.312, 0.312, 1.8, 0.312 },
	eye_height = 1.6,
	nametag_color = { r = 225, b = 225, a = 225, g = 225 }
}
local player_props_sneaking = {
	collisionbox = { -0.312, 0, -0.312, 0.312, 1.8, 0.312 },
	eye_height = 1.45,
	nametag_color = { r = 225, b = 225, a = 0, g = 225 }
}
local player_props_swimming = {
	collisionbox = { -0.312, 0, -0.312, 0.312, 0.8, 0.312 },
	eye_height = 0.6,
	nametag_color = { r = 225, b = 225, a = 225, g = 225 }
}
local player_props_normal = {
	collisionbox = { -0.312, 0, -0.312, 0.312, 1.8, 0.312 },
	eye_height = 1.6,
	nametag_color = { r = 225, b = 225, a = 225, g = 225 }
}

function vlf_player.player_register_model(name, def)
	vlf_player.registered_player_models[name] = def
end

function vlf_player.register_on_visual_change(func)
	table.insert(vlf_player.registered_on_visual_change, func)
end

local function player_collision(player)

	local pos = player:get_pos()
	--local vel = player:get_velocity()
	local x = 0
	local z = 0
	local width = .75

	for _,object in pairs(minetest.get_objects_inside_radius(pos, width)) do

		local ent = object:get_luaentity()
		if (object:is_player() or (ent and ent.is_mob and object ~= player)) then

			local pos2 = object:get_pos()
			local vec  = {x = pos.x - pos2.x, z = pos.z - pos2.z}
			local force = (width + 0.5) - vector.distance(
				{x = pos.x, y = 0, z = pos.z},
				{x = pos2.x, y = 0, z = pos2.z})

			x = x + (vec.x * force)
			z = z + (vec.z * force)
		end
	end
	return {x,z}
end

local function dir_to_pitch(dir)
	local xz = math.abs(dir.x) + math.abs(dir.z)
	return -math.atan2(-dir.y, xz)
end

local function limit_vel_yaw(player_vel_yaw, yaw)
	if player_vel_yaw < 0 then
		player_vel_yaw = player_vel_yaw + 360
	end

	if yaw < 0 then
		yaw = yaw + 360
	end

	if math.abs(player_vel_yaw - yaw) > 40 then
		local player_vel_yaw_nm, yaw_nm = player_vel_yaw, yaw
		if player_vel_yaw > yaw then
			player_vel_yaw_nm = player_vel_yaw - 360
		else
			yaw_nm = yaw - 360
		end
		if math.abs(player_vel_yaw_nm - yaw_nm) > 40 then
			local diff = math.abs(player_vel_yaw - yaw)
			if diff > 180 and diff < 185 or diff < 180 and diff > 175 then
				player_vel_yaw = yaw
			elseif diff < 180 then
				if player_vel_yaw < yaw then
					player_vel_yaw = yaw - 40
				else
					player_vel_yaw = yaw + 40
				end
			else
				if player_vel_yaw < yaw then
					player_vel_yaw = yaw + 40
				else
					player_vel_yaw = yaw - 40
				end
			end
		end
	end

	if player_vel_yaw < 0 then
		player_vel_yaw = player_vel_yaw + 360
	elseif player_vel_yaw > 360 then
		player_vel_yaw = player_vel_yaw - 360
	end

	return player_vel_yaw
end

local function get_mouse_button(player)
	local controls = player:get_player_control()
	local get_wielded_item_name = player:get_wielded_item():get_name()
	if controls.RMB and minetest.get_item_group(get_wielded_item_name, "bow") == 0 and
		minetest.get_item_group(get_wielded_item_name, "crossbow") == 0 and
		not vlf_shields.wielding_shield(player, 1) and not vlf_shields.wielding_shield(player, 2) or controls.LMB then
		return true
	else
		return false
	end
end


function vlf_player.player_get_animation(player)
	local textures = vlf_player.players[player].textures

	if not vlf_player.players[player].visible then
		textures = table.copy(textures)
		textures[1] = "blank.png"
	end

	return {
		model = vlf_player.players[player].model,
		textures =  vlf_player.players[player].textures,
		animation =  vlf_player.players[player].animation,
		visibility = vlf_player.players[player].visibility
	}
end

local function update_player_textures(player)
	local textures = vlf_player.players[player].textures

	if not vlf_player.players[player].visible then
		textures = table.copy(textures)
		textures[1] = "blank.png"
	end

	player:set_properties({ textures = textures })

	-- Delay calling the callbacks because mods (including vlf_player)
	-- need to fully initialize player data from minetest.register_on_joinplayer
	-- before callbacks run
	minetest.after(0.1, function()
		if player:is_player() then
			for i, func in ipairs(vlf_player.registered_on_visual_change) do
				func(player)
			end
		end
	end)
end

-- Called when a player's appearance needs to be updated
function vlf_player.player_set_model(player, model_name)
	local model = vlf_player.registered_player_models[model_name]
	if model then
		if vlf_player.players[player].model == model_name then
			return
		end
		vlf_player.players[player].model = model_name
		player:set_properties({
			mesh = model_name,
			visual = "mesh",
			visual_size = model.visual_size or { x = 1, y = 1 },
			damage_texture_modifier = "^[colorize:red:130",
		})
		update_player_textures(player)
		vlf_player.player_set_animation(player, "stand")
	end
end

function vlf_player.player_set_visibility(player, visible)
	if vlf_player.players[player].visible == visible then return end
	vlf_player.players[player].visible = visible
	update_player_textures(player)
end

function vlf_player.player_set_skin(player, texture)
	vlf_player.players[player].textures[1] = texture
	update_player_textures(player)
end

function vlf_player.player_set_armor(player, texture)
	vlf_player.players[player].textures[2] = texture
	update_player_textures(player)
end

function vlf_player.get_player_formspec_model(player, x, y, w, h, fsname)
	local model = vlf_player.players[player].model
	local anim = vlf_player.registered_player_models[model].animations[vlf_player.players[player].animation]
	local textures = table.copy(vlf_player.players[player].textures)
	if not vlf_player.players[player].visible then
		textures[1] = "blank.png"
	end
	for k,v in pairs(textures) do
		textures[k] = minetest.formspec_escape(v)
	end
	return string.format("model[%s,%s;%s,%s;%s;%s;%s;0,180;false;false;%s,%s]", x, y, w, h, fsname, model,
		table.concat(textures, ","), anim.x, anim.y)
end

function vlf_player.player_set_animation(player, anim_name, speed)
	if vlf_player.players[player].animation == anim_name then
		return
	end
	local model = vlf_player.players[player].model and vlf_player.registered_player_models[vlf_player.players[player].model]
	if not (model and model.animations[anim_name]) then
		return
	end
	local anim = model.animations[anim_name]
	vlf_player.players[player].animation = anim_name
	player:set_animation(anim, speed or model.animation_speed, animation_blend)
end

local function set_swimming(player, anim, anim_speed)
	local pitch = - math.deg(player:get_look_vertical())
	local yaw = math.deg(player:get_look_horizontal())
	local vel = player:get_velocity()
	vlf_player.players[player].is_swimming = true
	anim = anim or "swim_stand"
	vlf_player.player_set_animation(player, anim, anim_speed)
	vlf_util.set_bone_position(player, "Head_Control", nil, vector.new(pitch - math.deg(dir_to_pitch(vel)) + 20, vlf_player.players[player].vel_yaw - yaw, 0))
	vlf_util.set_bone_position(player,"Body_Control", nil, vector.new((75 + math.deg(dir_to_pitch(vel))), vlf_player.players[player].vel_yaw - yaw, 180))
	vlf_util.set_properties(player, player_props_swimming)
end

vlf_player.register_globalstep(function(player, dtime)
	local name = player:get_player_name()
	local model_name = vlf_player.players[player].model
	local model = model_name and vlf_player.registered_player_models[model_name]
	local control = player:get_player_control()
	local parent = player:get_attach()
	local wielded = player:get_wielded_item()
	local wielded_def = wielded:get_definition()
	local wielded_itemname = player:get_wielded_item():get_name()
	local player_velocity = player:get_velocity()
	local elytra = vlf_player.players[player].elytra and vlf_player.players[player].elytra.active

	local c_x, c_y = unpack(player_collision(player))

	if player_velocity.x + player_velocity.y < .5 and c_x + c_y > 0 then
		player:add_velocity({x = c_x, y = 0, z = c_y})
		player_velocity = player:get_velocity()
	end

	-- control head bone
	local pitch = - math.deg(player:get_look_vertical())
	local yaw = math.deg(player:get_look_horizontal())

	local player_vel_yaw = math.deg(minetest.dir_to_yaw(player_velocity))
	if player_vel_yaw == 0 then
		player_vel_yaw = vlf_player.players[player].vel_yaw or yaw
	end
	player_vel_yaw = limit_vel_yaw(player_vel_yaw, yaw)
	vlf_player.players[player].vel_yaw = player_vel_yaw

	if parent or vlf_player.players[player].attached then
		if parent then
			vlf_util.set_properties(player, player_props_riding)
			local parent_yaw = math.deg(parent:get_yaw())
			vlf_util.set_bone_position(player, "Head_Control", nil, vector.new(pitch, -limit_vel_yaw(yaw, parent_yaw) + parent_yaw, 0))
			vlf_util.set_bone_position(player,"Body_Control", nil, vector.zero())
		else
			vlf_util.set_bone_position(player,"Head_Control", nil, vector.new(pitch, player_vel_yaw - yaw, 0))
			vlf_util.set_bone_position(player,"Body_Control", nil, vector.new(0, -player_vel_yaw + yaw, 0))
		end
	else
		local walking = control.up or control.down or control.left or control.right
		local animation_speed_mod = model and model.animation_speed or 30

		-- Determine if the player is sneaking, and reduce animation speed if so
		if control.sneak then
			animation_speed_mod = animation_speed_mod / 2
		end

		if vlf_shields.is_blocking(player) then
			animation_speed_mod = animation_speed_mod / 2
		end

		-- ask if player is swiming
		local head_in_water = minetest.get_item_group(vlf_player.players[player].nodes.feet, "water") ~= 0
		-- ask if player is sprinting
		local is_sprinting = vlf_sprint.is_sprinting(name)

		local velocity = player:get_velocity()

		-- Apply animations based on what the player is doing
		if player:get_hp() == 0 then --dead
			vlf_player.player_set_animation(player, "die")
		elseif elytra then --using elytra
			vlf_util.set_bone_position(player,"Head_Control", nil, vector.new(pitch - math.deg(dir_to_pitch(player_velocity)) + 50, player_vel_yaw - yaw, 0))
			vlf_util.set_bone_position(player, "Body_Control", nil, vector.new(math.deg(dir_to_pitch(player_velocity)) + 110, -player_vel_yaw + yaw, 180))
			-- sets eye height, and nametag color accordingly
			vlf_util.set_properties(player, player_props_elytra)
		elseif walking and (math.abs(velocity.x) > 0.35 or math.abs(velocity.z) > 0.35) then --walking
			vlf_util.set_properties(player, player_props_normal)
			local no_arm_moving = minetest.get_item_group(wielded_itemname, "bow") > 0 or
				minetest.get_item_group(wielded_itemname, "crossbow") > 0 or
				vlf_shields.wielding_shield(player, 1) or
				vlf_shields.wielding_shield(player, 2)
			if vlf_player.players[player].sneak ~= control.sneak then
				vlf_player.players[player].animation = nil
				vlf_player.players[player].sneak = control.sneak
			end
			if not control.sneak and head_in_water and is_sprinting then --swimming
				vlf_player.players[player].is_swimming = true
				if get_mouse_button(player) then
					set_swimming(player, "swim_walk_mine", animation_speed_mod)
				else
					set_swimming(player, "swim_walk", animation_speed_mod)
				end
			elseif vlf_player.players[player].is_swimming
			and minetest.get_item_group(vlf_player.players[player].nodes.head, "solid") == 0
			and minetest.get_item_group(vlf_player.players[player].nodes.head_top, "solid") == 0 then --not swimming anymore
				vlf_player.players[player].is_swimming = false
				vlf_player.player_set_animation(player, "stand")
				vlf_util.set_properties(player, player_props_normal)
				vlf_util.set_bone_position(player,"Head_Control", nil, vector.new(pitch, player_vel_yaw - yaw, 0))
				vlf_util.set_bone_position(player,"Body_Control", nil, vector.new(0, -player_vel_yaw + yaw, 0))
			elseif no_arm_moving and control.RMB and control.sneak or minetest.get_item_group(wielded_itemname, "crossbow") > 0 and control.sneak then
				vlf_player.player_set_animation(player, "bow_sneak", animation_speed_mod)
			elseif no_arm_moving and control.RMB or minetest.get_item_group(wielded_itemname, "crossbow") > 0 then
				vlf_player.player_set_animation(player, "bow_walk", animation_speed_mod)
			elseif is_sprinting and get_mouse_button(player) and not control.sneak and not head_in_water then
				vlf_player.player_set_animation(player, "run_walk_mine", animation_speed_mod)
			elseif get_mouse_button(player) and not control.sneak then
				vlf_player.player_set_animation(player, "walk_mine", animation_speed_mod)
			elseif get_mouse_button(player) and control.sneak and is_sprinting ~= true then
				vlf_player.player_set_animation(player, "sneak_walk_mine", animation_speed_mod)
			elseif is_sprinting and not control.sneak and not head_in_water then
				vlf_player.player_set_animation(player, "run_walk", animation_speed_mod)
			elseif control.sneak and get_mouse_button(player) ~= true then
				vlf_player.player_set_animation(player, "sneak_walk", animation_speed_mod)
			else
				vlf_player.player_set_animation(player, "walk", animation_speed_mod)
			end
		elseif not control.sneak and head_in_water and is_sprinting then --swim-stand
			if get_mouse_button(player) then
				set_swimming(player, "swim_mine")
			else
				set_swimming(player, "swim_stand")
			end
		elseif vlf_player.players[player].is_swimming
		and minetest.get_item_group(vlf_player.players[player].nodes.head, "solid") == 0
		and minetest.get_item_group(vlf_player.players[player].nodes.head_top, "solid") == 0 then --not swimming anymore
			vlf_player.players[player].is_swimming = false
			vlf_player.player_set_animation(player, "stand")
			vlf_util.set_properties(player, player_props_normal)
			vlf_util.set_bone_position(player,"Head_Control", nil, vector.new(pitch, player_vel_yaw - yaw, 0))
			vlf_util.set_bone_position(player,"Body_Control", nil, vector.new(0, -player_vel_yaw + yaw, 0))
		elseif get_mouse_button(player) and not control.sneak then
			vlf_player.player_set_animation(player, "mine")
		elseif get_mouse_button(player) and control.sneak then
			vlf_player.player_set_animation(player, "sneak_mine")
		elseif not control.sneak and head_in_water and is_sprinting then
			vlf_player.player_set_animation(player, "swim_stand", animation_speed_mod)
		elseif control.sneak then
			vlf_util.set_bone_position(player, "Head_Control", nil, vector.new(pitch, player_vel_yaw - yaw, player_vel_yaw - yaw))
			vlf_util.set_bone_position(player, "Body_Control", nil, vector.new(0, -player_vel_yaw + yaw, 0))
			vlf_util.set_properties(player, player_props_sneaking)
			vlf_player.player_set_animation(player, "sneak_stand", animation_speed_mod)
		elseif not vlf_player.players[player].attached then
			vlf_util.set_properties(player, player_props_normal)
			vlf_util.set_bone_position(player,"Head_Control", nil, vector.new(pitch, player_vel_yaw - yaw, 0))
			vlf_util.set_bone_position(player,"Body_Control", nil, vector.new(0, -player_vel_yaw + yaw, 0))
			vlf_player.player_set_animation(player, "stand", animation_speed_mod)
		end
	end

	-- Specific wielditem positions according to item
	if wielded_def and wielded_def._vlf_toollike_wield then
		vlf_util.set_bone_position(player, "Wield_Item", vector.new(0, 4.7, 3.1), vector.new(-90, 225, 90))
	elseif minetest.get_item_group(wielded_itemname, "bow") > 0 then
		vlf_util.set_bone_position(player, "Wield_Item", vector.new(1, 4, 0), vector.new(90, 130, 115))
	elseif minetest.get_item_group(wielded_itemname, "crossbow") > 4 then
		vlf_util.set_bone_position(player, "Wield_Item", vector.new(0, 5.2, 1.2), vector.new(0, 180, 73))
	elseif minetest.get_item_group(wielded_itemname, "crossbow") > 0 then
		vlf_util.set_bone_position(player, "Wield_Item", vector.new(0, 5.2, 1.2), vector.new(0, 180, 45))
	elseif wielded_def.inventory_image == "" then
		vlf_util.set_bone_position(player,"Wield_Item", vector.new(0, 6, 2), vector.new(180, -45, 0))
	else
		vlf_util.set_bone_position(player, "Wield_Item", vector.new(0, 5.3, 2), vector.new(90, 0, 0))
	end

	-- controls right and left arms pitch when shooting a bow or blocking
	if vlf_shields.is_blocking(player) == 2 then
		vlf_util.set_bone_position(player, "Arm_Right_Pitch_Control", nil, vector.new(20, -20, 0))
	elseif vlf_shields.is_blocking(player) == 1 then
		vlf_util.set_bone_position(player, "Arm_Left_Pitch_Control", nil, vector.new(20, 20, 0))
	-- controls right and left arms pitch when holing a loaded crossbow
	elseif minetest.get_item_group(wielded_itemname, "crossbow") == 5 then
		vlf_util.set_bone_position(player, "Arm_Right_Pitch_Control", nil, vector.new(pitch + 90, -30, pitch * -1 * .35))
		vlf_util.set_bone_position(player, "Arm_Left_Pitch_Control", nil, vector.new(pitch + 90, 43, pitch * .35))
	-- controls right and left arms pitch when loading a crossbow
	elseif minetest.get_item_group(wielded_itemname, "crossbow") > 0 then
		vlf_util.set_bone_position(player, "Arm_Right_Pitch_Control", nil, vector.new(45, -20, 25))
		vlf_util.set_bone_position(player, "Arm_Left_Pitch_Control", nil, vector.new(55, 20, -45))
	elseif minetest.get_item_group(wielded_itemname, "bow") > 0 and control.RMB then
		local right_arm_rot = vector.new(pitch + 90, -30, pitch * -1 * .35)
		local left_arm_rot = vector.new(pitch + 90, 43, pitch * .35)
		vlf_util.set_bone_position(player, "Arm_Right_Pitch_Control", nil, right_arm_rot)
		vlf_util.set_bone_position(player, "Arm_Left_Pitch_Control", nil, left_arm_rot)
	-- when punching
	elseif control.LMB and not parent then
		vlf_util.set_bone_position(player,"Arm_Right_Pitch_Control", nil, vector.new(pitch, 0, 0))
		vlf_util.set_bone_position(player,"Arm_Left_Pitch_Control", nil, vector.zero())
	-- when holding an item.
	elseif wielded:get_name() ~= "" then
		vlf_util.set_bone_position(player, "Arm_Right_Pitch_Control", nil, vector.new(20, 0, 0))
		vlf_util.set_bone_position(player, "Arm_Left_Pitch_Control", nil, vector.zero())
	-- resets arms pitch
	else
		vlf_util.set_bone_position(player, "Arm_Left_Pitch_Control", nil, vector.zero())
		vlf_util.set_bone_position(player, "Arm_Right_Pitch_Control", nil, vector.zero())
	end
end)

vlf_player.register_globalstep_slow(function(player, dtime)
	-- Underwater: Spawn bubble particles
	if not vlf_player.players[player].pspawner_underwater and minetest.get_item_group(vlf_player.players[player].nodes.head, "water") > 0 then
		vlf_player.players[player].pspawner_underwater = minetest.add_particlespawner({
			amount = 4,
			time = 0,
			minpos = { x = -0.25, y = 0.3, z = -0.25 },
			maxpos = { x = 0.25, y = 0.7, z = 0.75 },
			attached = player,
			minvel = {x = -0.2, y = 0, z = -0.2},
			maxvel = {x = 0.5, y = 0, z = 0.5},
			minacc = {x = -0.4, y = 4, z = -0.4},
			maxacc = {x = 0.5, y = 1, z = 0.5},
			minexptime = 0.3,
			maxexptime = 0.8,
			minsize = 0.7,
			maxsize = 2.4,
			texture = "vlf_particles_bubble.png"
		})
	elseif vlf_player.players[player].pspawner_underwater and minetest.get_item_group(vlf_player.players[player].nodes.head, "water") == 0 then
		minetest.delete_particlespawner(vlf_player.players[player].pspawner_underwater)
		vlf_player.players[player].pspawner_underwater = nil
	end
end)

minetest.register_on_respawnplayer(function(player)
	local pos = player:get_pos()
	minetest.add_particlespawner({
		amount = 20,
		time = 0.001,
		minpos = vector.add(pos, 0),
		maxpos = vector.add(pos, 0),
		minvel = vector.new(-5,-5,-5),
		maxvel = vector.new(5,5,5),
		minexptime = 1.1,
		maxexptime = 1.5,
		minsize = 1,
		maxsize = 2,
		collisiondetection = false,
		vertical = false,
		texture = "vlf_particles_mob_death.png^[colorize:#000000:255",
	})

	minetest.sound_play("vlf_mobs_mob_poof", {
		pos = pos,
		gain = 1.0,
		max_hear_distance = 8,
	}, true)
end)
