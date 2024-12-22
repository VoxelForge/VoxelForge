--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")
local mod_bows = minetest.get_modpath("vlf_bows") ~= nil

--###################
--################### SKELETON
--###################

local skeleton = {
	description = S("Skeleton"),
	type = "monster",
 	spawn_class = "hostile",
	hp_min = 20,
	hp_max = 20,
	xp_min = 6,
	xp_max = 6,
	breath_max = -1,
	armor = {undead = 100, fleshy = 100},
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.98, 0.3},
	pathfinding = 1,
	group_attack = true,
	head_swivel = "Head_Control",
 	bone_eye_height = 2.38,
	curiosity = 6,
	visual = "mesh",
	mesh = "mobs_mc_skeleton_weaponless.b3d",
	shooter_avoid_enemy = true,
	strafes = true,
	makes_footstep_sound = true,
 	textures = {
		{
			"mobs_mc_empty.png",
			"mobs_mc_skeleton.png", -- texture
		}
	},
	walk_velocity = 1.1,
	run_velocity = 1.45,
	sounds = {
		random = "mobs_mc_skeleton_random",
		death = "mobs_mc_skeleton_death",
		damage = "mobs_mc_skeleton_hurt",
		distance = 16,
	},
	runaway_from = {"mobs_mc:wolf"},
	damage = 2,
	reach = 2,
	left = false,
	bow_timer = 0.0,
	drops = {
		{name = "vlf_bows:arrow", chance = 1, min = 0, max = 2, looting = "common"},
		{name = "vlf_bows:bow", chance = 100 / 8.5, min = 1, max = 1, looting = "rare"},
		{name = "vlf_mobitems:bone", chance = 1, min = 0, max = 2, looting = "common"},
		{name = "vlf_heads:skeleton", chance = 200, min = 1, max = 1, mob_head = true},
	},
	animation = {
		stand_speed = 15,
		stand_start = 0,
		stand_end = 40,
		walk_speed = 15,
		walk_start = 40,
		walk_end = 60,
 		run_speed = 30,
		shoot_start = 70,
		shoot_end = 90,
		jockey_start = 172,
		jockey_end = 172,
		die_start = 160,
		die_end = 170,
		die_speed = 15,
		die_loop = false,
	},
	on_spawn = function(self)
		if math.random(100) == 1 then
			self:jock_to("mobs_mc:spider", vector.new(0,0,0), vector.new(0,0,0))
		end
		local bow = minetest.add_entity(self.object:get_pos(), "vlf_mob_weapons:bow")
		if bow then
			if math.random(100) <= 11 then
				bow:set_attach(self.object, "arm.left",
					{x = 0, y = 2, z = 0},
					{x = 0, y = 90, z = 0}
				)
				self.left = true
			else
				bow:set_attach(self.object, "arm.right",
					{x = 0, y = 2, z = 0},
					{x = 0, y = 0, z = -45}
				)
				self.left = false
			end
			self.bow_entity = bow -- Store reference to the bow entity
		end
		return true
	end,
	on_activate = function(self)
		local bow = minetest.add_entity(self.object:get_pos(), "vlf_mob_weapons:bow")
		if bow then
			if self.left == true then
				bow:set_attach(self.object, "arm.left",
					{x = 0, y = 2, z = 0},
					{x = 0, y = 90, z = 0}
				)
				self.left = true
			else
				bow:set_attach(self.object, "arm.right",
					{x = 0, y = 2, z = 0},
					{x = 0, y = 0, z = -45}
				)
				self.left = false
			end
			self.bow_entity = bow
		end
		return true
	end,
	on_deactivate = function(self, staticdata)
		-- If the bow is attached, remove it when skeleton is deactivated
		if self.bow_entity and self.bow_entity:get_luaentity() then
			self.bow_entity:set_detach()
			self.bow_entity:remove()
			self.bow_entity = nil
			self.initialized = false
		end
	end,
	do_custom = function(self)
		if self.bow_entity == nil then
			self.bow_timer = os.time()
		end
		local current_time = os.time()
		local time_since_activate = current_time - self.bow_timer
		if time_since_activate >= 0.1 and self.bow_entity == nil then
			self.bow_timer = current_time
			local bow = minetest.add_entity(self.object:get_pos(), "vlf_mob_weapons:bow")
			if bow then
				if self.left == true then
					bow:set_attach(self.object, "arm.left",
						{x = 0, y = 2, z = 0},
						{x = 0, y = 90, z = 0}
					)
					self.left = true
				else
					bow:set_attach(self.object, "arm.right",
						{x = 0, y = 2, z = 0},
						{x = 0, y = 0, z = -45}
					)
					self.left = false
				end
				self.bow_entity = bow
			end
		end
	end,
	ignited_by_sunlight = true,
	floats = 0,
	view_range = 16,
	 fear_height = 4,
	attack_type = "dogshoot",
 	arrow = "vlf_bows:arrow_entity",
	shoot_arrow = function(self, pos, dir)
		if mod_bows then
			if self.attack then
				self.object:set_yaw(minetest.dir_to_yaw(vector.direction(self.object:get_pos(), self.attack:get_pos())))
			end
			local dmg = math.random(3, 4)
			vlf_bows.shoot_arrow("vlf_bows:arrow", pos, dir, self.object:get_yaw(), self.object, nil, dmg)
 		end
    	end,
	shoot_interval = 2,
	shoot_offset = 1.5,
	dogshoot_switch = 1,
	dogshoot_count_max = 1.8,
	harmed_by_heal = true,
	on_die = function(self, pos, cmi_cause)
		if cmi_cause and cmi_cause.puncher then
			local l = cmi_cause.puncher:get_luaentity()
			if l and l._is_arrow and l._shooter and l._shooter:is_player() and vector.distance(pos, l._startpos) > 20 then
				awards.unlock(l._shooter:get_player_name(), "vlf:snipeSkeleton")
			end
		elseif cmi_cause and cmi_cause.type == "freeze" then
			vlf_util.replace_mob(self.object, "mobs_mc:stray")
			return true
		end
		if self.bow_entity then
			self.bow_entity:remove() -- Remove bow entity when skeleton dies
		end
	end,
}

vlf_mobs.register_mob("mobs_mc:skeleton", skeleton)


--###################
--################### STRAY
--###################

-- TODO: different sound (w/ echo)
vlf_mobs.register_mob("mobs_mc:stray", table.merge(skeleton, {
	description = S("Stray"),
	mesh = "mobs_mc_stray_weaponless.b3d",
	_vlf_freeze_damage = 0,
	textures = {
		{
			"mobs_mc_stray_overlay.png",
			"mobs_mc_stray.png",
			--"vlf_bows_bow_0.png",
		},
	},
	shoot_arrow = function(self, pos, dir)
		if mod_bows then
			if self.attack then
				self.object:set_yaw(minetest.dir_to_yaw(vector.direction(self.object:get_pos(), self.attack:get_pos())))
			end
			local dmg = math.random(3, 4)
			vlf_bows.shoot_arrow("vlf_entity_effects:slowness_arrow", pos, dir, self.object:get_yaw(), self.object, nil, dmg)
		end
	end,
	drops = table.insert(skeleton.drops, {
		name = "vlf_entity_effects:slowness_arrow",
		chance = 2,
		min = 1,
		max = 1,
		looting = "rare",
		looting_chance_function = function(lvl)
			local chance = 0.5
			for _ = 1, lvl do
				if chance > 1 then
					return 1
				end
				chance = chance + (1 - chance) / 2
			end
			return chance
		end,
	})
}))

-- TODO: different sound (w/ echo)
vlf_mobs.register_mob("mobs_mc:bogged", table.merge(skeleton, {
	description = S("Bogged"),
	mesh = "mobs_mc_bogged.b3d",
	hp_min = 16,
	hp_max = 16,
	textures = {
		{
			"bogged_overlay.png",
			"bogged.png",
			"vlf_bows_bow_0.png",
		},
	},
	shoot_arrow = function(self, pos, dir)
		if mod_bows then
			if self.attack then
				self.object:set_yaw(minetest.dir_to_yaw(vector.direction(self.object:get_pos(), self.attack:get_pos())))
			end
			local dmg = math.random(3, 4)
			vlf_bows.shoot_arrow("vlf_entity_effects:poison_arrow", pos, dir, self.object:get_yaw(), self.object, nil, dmg)
		end
	end,
	drops = table.insert(skeleton.drops, {
		name = "vlf_entity_effects:poison_arrow",
		chance = 2,
		min = 1,
		max = 1,
		looting = "rare",
		looting_chance_function = function(lvl)
			local chance = 0.5
			for _ = 1, lvl do
				if chance > 1 then
					return 1
				end
				chance = chance + (1 - chance) / 2
			end
			return chance
		end,
	})
}))

vlf_mobs.spawn_setup({
	name = "mobs_mc:skeleton",
	type_of_spawning = "ground",
	dimension = "overworld",
	aoc = 2,
	biomes_except = {
		"MushroomIslandShore",
		"MushroomIsland"
	},
	chance = 800,
})

vlf_mobs.spawn_setup({
	name = "mobs_mc:skeleton",
	type_of_spawning = "ground",
	dimension = "nether",
	aoc = 2,
	biomes = {
		"SoulsandValley",
	},
	chance = 800,
})

vlf_mobs.spawn_setup({
	name = "mobs_mc:stray",
	type_of_spawning = "ground",
	dimension = "overworld",
	aoc = 2,
	biomes = {
		"ColdTaiga",
		"IcePlainsSpikes",
		"IcePlains",
		"ExtremeHills+_snowtop",
	},
	chance = 1200,
})

-- spawn eggs
vlf_mobs.register_egg("mobs_mc:skeleton", S("Skeleton"), "#c1c1c1", "#494949", 0)

vlf_mobs.register_egg("mobs_mc:stray", S("Stray"), "#5f7476", "#dae8e7", 0)

vlf_mobs.register_egg("mobs_mc:bogged", S("Bogged"), "#7d8d67", "#1f3111", 0)
