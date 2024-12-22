local S = minetest.get_translator("mobs_mc")

local mod_target = minetest.get_modpath("vlf_target")

-- Blaze mob with shield regeneration system
local function check_light(pos, environmental_light, artificial_light, sky_light)
	if artificial_light > 11 then
		return false, "Too bright"
	end
	return true, ""
end

-- Function to apply proximity effects
local function apply_proximity_effects(self, pos, target_pos)
	-- Check if the effect is already being applied
	if self.proximity_effect_active then
		return -- Skip if already running
	end

	-- Mark as active
	self.proximity_effect_active = true

	-- Run the proximity effect in a protected call (pcall)
	minetest.after(0, function()
		-- Calculate the distance between the Blaze and the target
		local distance = vector.distance(pos, target_pos)

		-- Determine the damage based on proximity
		local base_damage = 1 -- Minimum damage if at maximum range
		local max_damage = 10 -- Maximum damage if right next to the Blaze
		local damage = base_damage + math.max(0, max_damage - math.floor(distance))

		-- Determine the knockback based on proximity
		local base_knockback = 1 -- Minimum knockback at max range
		local max_knockback = 10 -- Maximum knockback if right next to the Blaze
		local knockback = base_knockback + math.max(0, max_knockback - math.floor(distance))

		-- Apply knockback to all entities within range
		local objects = minetest.get_objects_inside_radius(pos, 10) -- Adjust range as needed
		for _, obj in ipairs(objects) do
			if obj:is_player() or obj:get_luaentity() then
				local obj_pos = obj:get_pos()
				local direction = vector.normalize(vector.subtract(obj_pos, pos))
				local kb_vector = vector.multiply(direction, knockback)

				obj:add_velocity(kb_vector)
				if obj:is_player() and obj ~= self.object then
					obj:set_hp(obj:get_hp() - damage)
				elseif obj:get_luaentity() and obj ~= self.object then
					obj:punch(self.object, 1.0, {
						full_punch_interval = 1.0,
						damage_groups = {fleshy = damage},
					}, direction)
				end
			end
		end

		-- Mark as inactive when done
		self.proximity_effect_active = false
	end)
end

vlf_mobs.register_mob("mobs_mc:hovering_inferno", {
	description = S("Hovering Inferno"),
	type = "monster",
	spawn_class = "hostile",
	can_despawn = false,
	spawn_in_group_min = 2,
	spawn_in_group = 3,
	hp_min = 500,
	hp_max = 500,
	xp_min = 70,
	xp_max = 140,
	collisionbox = {-0.3, -0.3, -0.3, 0.3, 1.79, 0.3},
	--rotate = -180,
	visual = "mesh",
	mesh = "mobs_mc_hovering_inferno_4.b3d",
	textures = {
		{"mobs_mc_hovering_inferno.png"},
	},
	armor = { fleshy = 100, snowball_vulnerable = 100, water_vulnerable = 100 },
	visual_size = {x=10, y=10},
	sounds = {
		random = "mobs_mc_blaze_breath",
		death = "mobs_mc_blaze_died",
		damage = "mobs_mc_blaze_hurt",
		distance = 16,
	},
	walk_velocity = 0.8,
	run_velocity = 1.6,
	attack_type = "dogshoot",
	arrow = "mobs_mc:blaze_fireball",
	shoot_interval = 2.5,
	shoot_offset = 1.0,
	passive = false,
	damage = 4,
	reach = 2,
	pathfinding = 1,
	drops = {
		{name = "vlf_mobitems:blaze_shield", chance = 1, min = 0, max = 1},
	},
	animation = {
		stand_speed = 25,
		stand_start = 78,
		stand_end = 86,
		walk_speed = 25,
		walk_start = 78,
		walk_end = 86,
		run_speed = 25,
		run_start = 78,
		run_end = 86,
		hit_start = 78, -- Animation for being hit
		hit_end = 86,
	},
	water_damage = 2,
	_freeze_damage = 5,
	lava_damage = 0,
	fire_damage = 0,
	fall_damage = 0,
	fall_speed = -2.25,
	light_damage = 0,
	fire_resistant = true,
	glow = 14,
	view_range = 16,
	jump = true,
	jump_height = 4,
	fly = true,
	fear_height = 0,
	check_light = check_light,
	fire_resistant = true,
	
	on_spawn = function(self)
		if not self.shields then
			self.shields = 4
		end
	end,

--[[on_punch = function(self, hitter, tflp, tool_capabilities, dir)
	if not self.shield_hp then
		self.shield_hp = 125  -- Each shield starts with 125 HP
		self.shield_regen_timer = nil  -- Timer for shield regeneration
	end

	-- Update the mesh based on the number of shields remaining
	if self.shields == 4 then
		self.object:set_properties({
			mesh = "mobs_mc_hovering_inferno_4.b3d"
		})
	elseif self.shields == 3 then
		self.object:set_properties({
			mesh = "mobs_mc_hovering_inferno_3.b3d"
		})
	elseif self.shields == 2 then
		self.object:set_properties({
			mesh = "mobs_mc_hovering_inferno_2.b3d"
		})
	elseif self.shields == 1 then
		self.object:set_properties({
			mesh = "mobs_mc_hovering_inferno_1.b3d"
		})
	else
		self.object:set_properties({
			mesh = "mobs_mc_hovering_inferno.b3d"
		})
	end

	local damage = tool_capabilities and tool_capabilities.damage_groups and tool_capabilities.damage_groups.fleshy or 0

	-- If shields are present, reduce shield HP instead of mob HP
	if self.shields > 0 then
		self.shield_hp = self.shield_hp - damage
		minetest.chat_send_all("Blaze shield HP remaining: " .. self.shield_hp .. " / 125")

		-- Set to the attack animation
		self.object:set_animation({x = 0, y = 54}, 100, 0, false)

		-- Apply proximity effect and switch back to walking animation
		minetest.after(1.8, function()
			local pos = self.object:get_pos()
			if pos then
				apply_proximity_effects(self, pos, self.object:get_pos())
			end
			self.object:set_animation({x = 78, y = 86}, 25, 0, true)
		end)

		-- If the current shield HP reaches 0, destroy the shield
		if self.shield_hp <= 0 then
			self.shields = self.shields - 1
			minetest.chat_send_all("Blaze shield destroyed! Shields remaining: " .. self.shields)
			
			-- Reset shield HP for the next shield (if any)
			if self.shields > 0 then
				self.shield_hp = 125
			end
		end

		-- Start the shield regeneration timer if all shields are down
		if self.shields == 0 and not self.shield_regen_timer then
			minetest.chat_send_all("Blaze shields are down! They will regenerate in 60 seconds.")
			self.shield_regen_timer = minetest.after(60, function()
				self.shields = 4  -- Restore shields
				self.shield_hp = 125  -- Reset shield HP
				self.shield_regen_timer = nil  -- Reset the timer
				minetest.chat_send_all("Blaze shields have regenerated!")
			end)
		end

		-- Prevent HP from being reduced if shields are still active
		return true
	end

	-- If no shields remain, proceed with normal damage
	return false
end,

deal_damage = function (self, damage, vlf_reason)
	if self.shields > 0 then
		self.health = self.health
	else
		self.health = self.health - damage
	end
end,]]

on_punch = function(self, hitter, tflp, tool_capabilities, dir)
	if not self.shield_hp then
		self.shield_hp = 125  -- Each shield starts with 125 HP
		self.shield_regen_timer = nil  -- Timer for shield regeneration
	end
	-- Update the mesh based on the number of shields remaining
	if self.shields == 4 then
		self.object:set_properties({
			mesh = "mobs_mc_hovering_inferno_4.b3d"
		})
	elseif self.shields == 3 then
		self.object:set_properties({
			mesh = "mobs_mc_hovering_inferno_3.b3d"
		})
	elseif self.shields == 2 then
		self.object:set_properties({
			mesh = "mobs_mc_hovering_inferno_2.b3d"
		})
	elseif self.shields == 1 then
		self.object:set_properties({
			mesh = "mobs_mc_hovering_inferno_1.b3d"
		})
	else
		self.object:set_properties({
			mesh = "mobs_mc_hovering_inferno.b3d"
		})
	end

	local damage = tool_capabilities and tool_capabilities.damage_groups and tool_capabilities.damage_groups.fleshy or 0

	-- If shields are present, reduce shield HP instead of mob HP
	if self.shields > 0 then
		self.shield_hp = self.shield_hp - damage
		self.object:set_hp(self.object:get_hp())
		minetest.chat_send_all("Blaze shield HP remaining: " .. self.shield_hp .. " / 125")

		-- Set to the attack animation
		self.object:set_animation({x = 0, y = 54}, 100, 0, false)

		-- Apply proximity effect and switch back to walking animation
		minetest.after(1.8, function()
			local pos = self.object:get_pos()
			if pos then
				apply_proximity_effects(self, pos, self.object:get_pos())
			end
			self.object:set_animation({x = 78, y = 86}, 25, 0, true)
		end)

		-- If the current shield HP reaches 0, destroy the shield
		if self.shield_hp <= 0 then
			self.shields = self.shields - 1
			minetest.chat_send_all("Blaze shield destroyed! Shields remaining: " .. self.shields)
			
			-- Reset shield HP for the next shield (if any)
			if self.shields > 0 then
				self.shield_hp = 125
			end
		end

		-- Start the shield regeneration timer if all shields are down
		if self.shields == 0 and not self.shield_regen_timer then
			minetest.chat_send_all("Blaze shields are down! They will regenerate in 60 seconds.")
			self.shield_regen_timer = minetest.after(60, function()
				self.shields = 4  -- Restore shields
				self.shield_hp = 125  -- Reset shield HP
				self.shield_regen_timer = nil  -- Reset the timer
				minetest.chat_send_all("Blaze shields have regenerated!")
			end)
		end

		-- Prevent HP from being reduced if shields are still active
		return true
	else
	-- If no shields remain, proceed with normal damage
	local mob_hp = self.object:get_hp()
	self.object:set_hp(mob_hp - damage)
	end
	return false
end,


	-- Particle effects (smoke)
	do_custom = function(self,dtime)
		vlf_bossbars.update_boss(self.object, "Hovering Inferno", "red")
		local pos = self.object:get_pos()
		minetest.add_particle({
			pos = {x=pos.x+math.random(-0.7,0.7),y=pos.y+math.random(0.7,1.2),z=pos.z+math.random(-0.7,0.7)},
			velocity = {x=0, y=math.random(1,1), z=0},
			expirationtime = math.random(),
			size = math.random(1, 4),
			collisiondetection = true,
			vertical = false,
			texture = "vlf_particles_smoke_anim.png^[colorize:#2c2c2c:255",
			animation = {
				type = "vertical_frames",
				aspect_w = 8,
				aspect_h = 8,
				length = 2.05,
			},
		})
		if self.shields < 1 then
			self.shoot_interval = 1.5
		elseif self.shields >= 1 then
			self.shoot_inverval = 2.5
		end
	end,
})

-- spawn eggs
vlf_mobs.register_egg("mobs_mc:hovering_inferno", S("Hovering Inferno"), "#f6b201", "#fff87e", 0)
