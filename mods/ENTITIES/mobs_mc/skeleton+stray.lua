--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")
<<<<<<< HEAD
local mod_bows = minetest.get_modpath("vlc_bows") ~= nil
=======
local mod_bows = minetest.get_modpath("vlf_bows") ~= nil
>>>>>>> 3eb27be82 (change naming in mods)

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
	mesh = "mobs_mc_skeleton.b3d",
	shooter_avoid_enemy = true,
	strafes = true,
	makes_footstep_sound = true,
	textures = {
		{
			"mobs_mc_empty.png", -- armor
			"mobs_mc_skeleton.png", -- texture
<<<<<<< HEAD
			"vlc_bows_bow_0.png", -- wielded_item
=======
			"vlf_bows_bow_0.png", -- wielded_item
>>>>>>> 3eb27be82 (change naming in mods)
		}
	},
	walk_velocity = 1.1,
	run_velocity = 1.45, -- skeletons are really anoying in mc, so i made only walkin 0.2 slower
	sounds = {
		random = "mobs_mc_skeleton_random",
		death = "mobs_mc_skeleton_death",
		damage = "mobs_mc_skeleton_hurt",
		distance = 16,
	},
	runaway_from = {"mobs_mc:wolf"},
	damage = 2,
	reach = 2,
	drops = {
<<<<<<< HEAD
		{name = "vlc_bows:arrow",
=======
		{name = "vlf_bows:arrow",
>>>>>>> 3eb27be82 (change naming in mods)
		chance = 1,
		min = 0,
		max = 2,
		looting = "common",},
<<<<<<< HEAD
		{name = "vlc_bows:bow",
=======
		{name = "vlf_bows:bow",
>>>>>>> 3eb27be82 (change naming in mods)
		chance = 100 / 8.5,
		min = 1,
		max = 1,
		looting = "rare",},
<<<<<<< HEAD
		{name = "vlc_mobitems:bone",
=======
		{name = "vlf_mobitems:bone",
>>>>>>> 3eb27be82 (change naming in mods)
		chance = 1,
		min = 0,
		max = 2,
		looting = "common",},

		-- Head
		-- TODO: Only drop if killed by charged creeper
<<<<<<< HEAD
		{name = "vlc_heads:skeleton",
=======
		{name = "vlf_heads:skeleton",
>>>>>>> 3eb27be82 (change naming in mods)
		chance = 200, -- 0.5% chance
		min = 1,
		max = 1,},
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
		return true
	end,
	ignited_by_sunlight = true,
	view_range = 16,
	fear_height = 4,
	attack_type = "dogshoot",
<<<<<<< HEAD
	arrow = "vlc_bows:arrow_entity",
=======
	arrow = "vlf_bows:arrow_entity",
>>>>>>> 3eb27be82 (change naming in mods)
	shoot_arrow = function(self, pos, dir)
		if mod_bows then
			if self.attack then
				self.object:set_yaw(minetest.dir_to_yaw(vector.direction(self.object:get_pos(), self.attack:get_pos())))
			end
			local dmg = math.random(3, 4)
<<<<<<< HEAD
			vlc_bows.shoot_arrow("vlc_bows:arrow", pos, dir, self.object:get_yaw(), self.object, nil, dmg)
=======
			vlf_bows.shoot_arrow("vlf_bows:arrow", pos, dir, self.object:get_yaw(), self.object, nil, dmg)
>>>>>>> 3eb27be82 (change naming in mods)
		end
	end,
	shoot_interval = 2,
	shoot_offset = 1.5,
	dogshoot_switch = 1,
	dogshoot_count_max =1.8,
	harmed_by_heal = true,
	on_die = function(self, pos, cmi_cause)
		if cmi_cause and cmi_cause.puncher then
			local l = cmi_cause.puncher:get_luaentity()
			if l and  l._is_arrow and l._shooter and l._shooter:is_player() and vector.distance(pos,l._startpos) > 20 then
<<<<<<< HEAD
				awards.unlock(l._shooter:get_player_name(), "vlc:snipeSkeleton")
=======
				awards.unlock(l._shooter:get_player_name(), "vlf:snipeSkeleton")
>>>>>>> 3eb27be82 (change naming in mods)
			end
		end
	end,
}

<<<<<<< HEAD
vlc_mobs.register_mob("mobs_mc:skeleton", skeleton)
=======
vlf_mobs.register_mob("mobs_mc:skeleton", skeleton)
>>>>>>> 3eb27be82 (change naming in mods)


--###################
--################### STRAY
--###################

local stray = table.copy(skeleton)
stray.description = S("Stray")
stray.mesh = "mobs_mc_skeleton.b3d"
stray.textures = {
	{
		"mobs_mc_stray_overlay.png",
		"mobs_mc_stray.png",
<<<<<<< HEAD
		"vlc_bows_bow_0.png",
=======
		"vlf_bows_bow_0.png",
>>>>>>> 3eb27be82 (change naming in mods)
	},
}
-- TODO: different sound (w/ echo)
-- TODO: stray's arrow inflicts slowness status
table.insert(stray.drops, {
<<<<<<< HEAD
	name = "vlc_potions:slowness_arrow",
=======
	name = "vlf_potions:slowness_arrow",
>>>>>>> 3eb27be82 (change naming in mods)
	chance = 2,
	min = 1,
	max = 1,
	looting = "rare",
	looting_chance_function = function(lvl)
		local chance = 0.5
		for i = 1, lvl do
			if chance > 1 then
				return 1
			end
			chance = chance + (1 - chance) / 2
		end
		return chance
	end,
})

<<<<<<< HEAD
vlc_mobs.register_mob("mobs_mc:stray", stray)

vlc_mobs.spawn_setup({
=======
vlf_mobs.register_mob("mobs_mc:stray", stray)

vlf_mobs.spawn_setup({
>>>>>>> 3eb27be82 (change naming in mods)
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

<<<<<<< HEAD
vlc_mobs.spawn_setup({
=======
vlf_mobs.spawn_setup({
>>>>>>> 3eb27be82 (change naming in mods)
	name = "mobs_mc:skeleton",
	type_of_spawning = "ground",
	dimension = "nether",
	aoc = 2,
	biomes = {
		"SoulsandValley",
	},
	chance = 800,
})

<<<<<<< HEAD
vlc_mobs.spawn_setup({
=======
vlf_mobs.spawn_setup({
>>>>>>> 3eb27be82 (change naming in mods)
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
<<<<<<< HEAD
vlc_mobs.register_egg("mobs_mc:skeleton", S("Skeleton"), "#c1c1c1", "#494949", 0)

vlc_mobs.register_egg("mobs_mc:stray", S("Stray"), "#5f7476", "#dae8e7", 0)
=======
vlf_mobs.register_egg("mobs_mc:skeleton", S("Skeleton"), "#c1c1c1", "#494949", 0)

vlf_mobs.register_egg("mobs_mc:stray", S("Stray"), "#5f7476", "#dae8e7", 0)
>>>>>>> 3eb27be82 (change naming in mods)
