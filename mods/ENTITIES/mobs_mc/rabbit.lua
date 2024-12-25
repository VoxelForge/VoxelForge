--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")
local mob_class = vlf_mobs.mob_class

local rabbit = {
	description = S("Rabbit"),
	type = "animal",
	spawn_class = "passive",
	spawn_in_group_min = 2,
	spawn_in_group = 3,
	passive = true,
	reach = 1,
	hp_min = 3,
	hp_max = 3,
	xp_min = 1,
	xp_max = 3,
	collisionbox = {-0.2, -0.1, -0.2, 0.2, 0.49, 0.2},
	head_swivel = "head.control",
	bone_eye_height = 2,
	head_eye_height = 0.5,
	horizontal_head_height = -.3,
	curiosity = 20,
	head_yaw = "z",
	visual = "mesh",
	mesh = "mobs_mc_rabbit.b3d",
	textures = {
		{"mobs_mc_rabbit_brown.png"},
		{"mobs_mc_rabbit_gold.png"},
		{"mobs_mc_rabbit_white.png"},
		{"mobs_mc_rabbit_white_splotched.png"},
		{"mobs_mc_rabbit_salt.png"},
		{"mobs_mc_rabbit_black.png"},
	},
	sounds = {
		random = "mobs_mc_rabbit_random",
		damage = "mobs_mc_rabbit_hurt",
		death = "mobs_mc_rabbit_death",
		attack = "mobs_mc_rabbit_attack",
		eat = "mobs_mc_animal_eat_generic",
		distance = 16,
	},
	makes_footstep_sound = false,
	movement_speed = 6.0,
	runaway_from = {
		"mobs_mc:wolf",
		"players",
		"monsters",
	},
	runaway_view_range = 10.0,
	_runaway_player_view_range = 8.0,
	_runaway_monster_view_range = 4.0,
	runaway = true,
	drops = {
		{
			name = "vlf_mobitems:rabbit",
			chance = 1, min = 0, max = 1,
			looting = "common",
		},
		{
			name = "vlf_mobitems:rabbit_hide",
			chance = 1, min = 0, max = 1,
			looting = "common",
		},
		{
			name = "vlf_mobitems:rabbit_foot",
			chance = 10, min = 0, max = 1,
			looting = "rare",
			looting_factor = 0.03,
		},
	},
	animation = {
		stand_start = 0, stand_end = 0,
		jump_start = 0, jump_end = 20, jump_speed = 40,
		jump_loop = false,
	},
	_child_animations = {
		stand_start = 21, stand_end = 21,
		walk_start = 21, walk_end = 41, walk_speed = 30,
		run_start = 21, run_end = 41, run_speed = 45,
	},
	-- Follow (yellow) dangelions, carrots and golden carrots
	follow = {
		"vlf_flowers:dandelion",
		"vlf_farming:carrot_item",
		"vlf_farming:carrot_item_gold",
	},
	climb_powder_snow = true,
	follow_bonus = 1.0,
	pursuit_bonus = 1.4,
	run_bonus = 2.2,
	breed_bonus = 0.8,
	pace_bonus = 0.6,
	runaway_bonus_near = 2.2,
	runaway_bonus_far = 2.2,
	_speed_modifier = 1.0,
	_jump_delay = 0,
	pace_interval = 0,
	_grief_time = 0,
}

------------------------------------------------------------------------
-- Rabbit mechanics.
------------------------------------------------------------------------

function rabbit:on_rightclick (clicker)
	if self:follow_holding (clicker) then
		self:feed_tame (clicker, 4, true, false)
	end
end

function rabbit:set_nametag (nametag)
	if mob_class.set_nametag (self, nametag) then
		-- MC Easter egg: Change texture if rabbit is named
		-- "Toast."
		if nametag == "Toast" and not self._has_toast_texture then
			self._original_rabbit_texture = self.base_texture
			self.base_texture = { "mobs_mc_rabbit_toast.png" }
			self:set_textures (self.base_texture)
			self._has_toast_texture = true
		elseif nametag ~= "Toast" and self._has_toast_texture then
			self.base_texture = self._original_rabbit_texture
			self:set_textures (self.base_texture)
			self._has_toast_texture = false
		end
	end
end

function rabbit:on_spawn ()
	local self_pos = self.object:get_pos ()
	local data = minetest.get_biome_data (self_pos)
	local random = math.random (100)
	local name = minetest.get_biome_name (data.biome)
	local definition = minetest.registered_biomes[name]
	local texture

	if definition._vlf_biome_type == "cold"
		or definition._vlf_biome_type == "snowy" then
		if random < 80 then
			texture = "mobs_mc_rabbit_white.png"
		else
			texture = "mobs_mc_rabbit_white_splotched.png"
		end
	elseif name:find ("Desert") then
		texture = "mobs_mc_rabbit_gold.png"
	elseif random < 50 then
		texture = "mobs_mc_rabbit_brown.png"
	elseif random < 90 then
		texture = "mobs_mc_rabbit_salt.png"
	else
		texture = "mobs_mc_rabbit_black.png"
	end
	self.base_texture[0] = texture
	self:set_textures (self.base_texture)
end

------------------------------------------------------------------------
-- Rabbit movement.
------------------------------------------------------------------------

function rabbit:get_jump_force (moveresult)
	local collides = vlf_mobs.horiz_collision (moveresult)
	local self_pos = self.object:get_pos ()
	local v = 0.3

	if collides then
		v = 0.5
	elseif self.movement_goal == "go_pos"
		and self.movement_target
		and self.movement_target.y > self_pos.y + 0.5 then
		v = 0.5
	elseif self.waypoints
		and #self.waypoints >= 1
		and self.waypoints[#self.waypoints].y > self_pos.y + 0.5 then
		v = 0.5
	elseif self.pacing then
		v = 0.2
	end
	return self.jump_height * (v / 0.42)
end

function rabbit:jump_actual (v, jump_force)
	local v = mob_class.jump_actual (self, v, jump_force)
	local sqr = v.x * v.x + v.z * v.z

	-- Jump forward if immobile.
	if sqr < 0.01 then
		local yaw = self:get_yaw ()
		local x = -math.sin (yaw)
		local z = math.cos (yaw)

		v.x = v.x + 2.0 * x
		v.z = v.z + 2.0 * z
	end
	return v
end

function rabbit:do_go_pos (dtime, moveresult)
	local on_ground = moveresult.touching_ground
		or moveresult.standing_on_object

	if on_ground and not self._jump then
		self.acc_dir.z = 0
		self.acc_dir.x = 0
		self.acc_dir.y = 0
	else
		local self_pos = self.object:get_pos ()
		local depth = self:immersion_depth ("water", self_pos, 1.0)
		local factor = 1.0
		if depth > self.head_eye_height then
			factor = 1.5
		end

		local target = self.movement_target or vector.zero ()
		local vel = self.movement_velocity * factor
		local pos = self.object:get_pos ()
		local dist = vector.distance (pos, target)

		if dist < 0.0005 then
			self.acc_dir.z = 0
			return
		end

		self:look_at (target, math.pi / 2 * (dtime / 0.05))
		self:set_velocity (vel)
	end
end

function rabbit:movement_step (dtime, moveresult)
	local moveresult = self._moveresult
	local on_ground = moveresult.touching_ground
		or moveresult.standing_on_object

	self._jump_delay
		= math.max (self._jump_delay - dtime, 0.0)

	if on_ground then
		if not self._previously_on_ground then
			self._jump = false
			self._want_sprinting_particles = true

			if not self.frightened and not self.avoiding then
				self._jump_delay = 0.5
			else
				self._jump_delay = 0.048 -- Just under one tick.
			end
		end

		if self.movement_goal == "go_pos"
			and self._jump_delay == 0 then
			local target = self.movement_target or vector.zero ()
			self:look_at (target)
			self._jump = true
		end
	end
	self._previously_on_ground = on_ground
	mob_class.movement_step (self, dtime, moveresult)
end

function rabbit:display_sprinting_particles ()
	local display_particles = self._want_sprinting_particles
	self._want_sprinting_particles = false
	return display_particles
end

------------------------------------------------------------------------
-- Rabbit AI.
------------------------------------------------------------------------

local mob_griefing = minetest.settings:get_bool ("mobs_griefing", true)

function rabbit:ai_step (dtime)
	mob_class.ai_step (self, dtime)
	self._grief_time
		= math.max (self._grief_time - dtime, 0.0)
end

local function manhattan3d (v1, v2)
	return math.abs (v1.x - v2.x)
		+ math.abs (v1.y - v2.y)
		+ math.abs (v1.z - v2.z)
end

local function rabbit_griefable (name)
	local age = minetest.get_item_group (name, "carrot")
	return age > 1 and age or nil
end

local function previous_stage (age)
	if age >= 7 then
		return 5
	elseif age >= 5 then
		return 3
	else
		return 1
	end
end

local function rabbit_grief_garden (self, self_pos, dtime)
	if not mob_griefing then
		return false
	end
	if self._griefing_garden then
		local target = self._grief_target
		local node = minetest.get_node (target)
		local age = rabbit_griefable (node.name)
		if not age then
			self:cancel_navigation ()
			self:halt_in_tracks ()
			self._griefing_garden = nil
			return false
		end
		local distance = vector.distance (self_pos, target)

		if distance < 1.0 then
			if not self:navigation_finished () then
				self:cancel_navigation ()
				self:halt_in_tracks ()
			end

			-- Grief this carrot block and wait a random
			-- period before proceeding to do so again.
			if minetest.remove_node (target) then
				minetest.sound_play ("default_grass_footstep", {
					pos = target,
				}, true)

				local carrot = "vlf_farming:carrot_"
					.. previous_stage (age)
				minetest.place_node (target, {
					name = carrot,
					param2 = 3,
				}, self.object)
			end

			local next_start_time = math.random (200, 400) / 20
			local rabbit_time = math.random (20, 120) / 20
			self._grief_time = next_start_time + rabbit_time
			self._griefing_garden = false
			return false
		end

		if self._griefing_garden > 60 then
			self._griefing_garden = nil
			self:cancel_navigation ()
			self:halt_in_tracks ()
			return false
		end

		self._griefing_garden = self._griefing_garden + dtime
		if self:check_timer ("rabbit_repath", 2.0) then
			self:gopath (target, 0.7)
		end
		return true
	elseif self._grief_time == 0 then
		if not self:check_timer ("grief_carrots", 0.5) then
			return false
		end
		-- Locate carrot blocks within a 16 block horizontal
		-- area.
		local nodepos = vlf_util.get_nodepos (self_pos)
		local aa = vector.offset (nodepos, -8, 0, -8)
		local bb = vector.offset (nodepos, 8, 1, 8)
		local carrots = minetest.find_nodes_in_area (aa, bb, {
			"group:carrot",
		})
		if #carrots == 0 then
			return false
		end
		table.sort (carrots, function (a, b)
			return manhattan3d (a, nodepos)
				< manhattan3d (b, nodepos)
		end)
		for i = 1, #carrots do
			local carrot = carrots[i]
			local node = minetest.get_node (carrot)
			if rabbit_griefable (node.name) then
				self._grief_target = carrot
				self._griefing_garden = 0.0
				self:gopath (carrot, 0.7)
				return "_griefing_garden"
			end
		end
		return false
	end
	return false
end

rabbit.ai_functions = {
	mob_class.ascend_in_powder_snow,
	mob_class.check_frightened,
	mob_class.check_breeding,
	mob_class.check_following,
	mob_class.check_avoid,
	rabbit_grief_garden,
	mob_class.check_pace,
}

vlf_mobs.register_mob ("mobs_mc:rabbit", rabbit)

------------------------------------------------------------------------
-- Killer bunny.
------------------------------------------------------------------------

-- The killer bunny (Only with spawn egg)
local killer_bunny = table.merge (rabbit, {
	description = S("Killer Bunny"),
	spawn_class = "hostile",
	attack_type = "melee",
	specific_attack = {
		"player",
		"mobs_mc:wolf",
		"mobs_mc:dog",
	},
	damage = 8,
	passive = false,
	does_not_prevent_sleep = true,
	retaliates = true,
	-- 8 armor points
	armor = 50,
	textures = {
		"mobs_mc_rabbit_caerbannog.png",
	},
	group_attack = true,
	runaway = false,
})

function killer_bunny:on_spawn ()
	self:set_nametag ("The Killer Bunny")
end

killer_bunny.ai_functions = {
	mob_class.ascend_in_powder_snow,
	mob_class.check_attack,
	mob_class.check_breeding,
	mob_class.check_following,
	rabbit_grief_garden,
	mob_class.check_pace,
}

vlf_mobs.register_mob ("mobs_mc:killer_bunny", killer_bunny)

-- Mob spawning rules.
-- Different skins depending on spawn location <- we'll get to this when the spawning algorithm is fleshed out

vlf_mobs.spawn_setup({
	name = "mobs_mc:rabbit",
	type_of_spawning = "ground",
	dimension = "overworld",
	aoc = 8,
	min_light = 9,
	biomes = {
		"flat",
		"Desert",
		"FlowerForest",
		"Taiga",
		"MegaSpruceTaiga",
		"MegaTaiga",
		"ColdTaiga",
		"CherryGrove",
	},
	chance = 40,
})

-- Spawn egg
vlf_mobs.register_egg("mobs_mc:rabbit", S("Rabbit"), "#995f40", "#734831", 0)

-- Note: This spawn egg does not exist in Minecraft
vlf_mobs.register_egg("mobs_mc:killer_bunny", S("Killer Bunny"), "#f2f2f2", "#ff0000", 0)
