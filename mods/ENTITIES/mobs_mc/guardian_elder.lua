-- v1.4

--###################
--################### GUARDIAN
--###################

local S = minetest.get_translator("mobs_mc")

<<<<<<< HEAD
vlc_mobs.register_mob("mobs_mc:guardian_elder", {
=======
vlf_mobs.register_mob("mobs_mc:guardian_elder", {
>>>>>>> 3eb27be82 (change naming in mods)
	description = S("Elder Guardian"),
	type = "monster",
	spawn_class = "hostile",
	hp_min = 80,
	hp_max = 80,
	xp_min = 10,
	xp_max = 10,
	breath_max = -1,
	passive = false,
	attack_type = "dogfight",
	pathfinding = 1,
	view_range = 16,
	walk_velocity = 2,
	run_velocity = 4,
	damage = 8,
	reach = 3,
	collisionbox = {-0.99875, 0.5, -0.99875, 0.99875, 2.4975, 0.99875},
	doll_size_override = { x = 0.72, y = 0.72 },
	visual = "mesh",
	mesh = "mobs_mc_guardian.b3d",
	textures = {
		{"mobs_mc_guardian_elder.png"},
	},
	visual_size = {x=7, y=7},
	sounds = {
		random = "mobs_mc_guardian_random",
		war_cry = "mobs_mc_guardian_random",
		damage = {name="mobs_mc_guardian_hurt", gain=0.3},
		death = "mobs_mc_guardian_death",
		flop = "mobs_mc_squid_flop",
		base_pitch = 0.6,
		distance = 16,
	},
	animation = {
		stand_speed = 25, walk_speed = 25, run_speed = 50,
		stand_start = 0,		stand_end = 20,
		walk_start = 0,		walk_end = 20,
		run_start = 0,		run_end = 20,
	},
	drops = {
<<<<<<< HEAD
		{name = "vlc_ocean:prismarine_shard",
=======
		{name = "vlf_ocean:prismarine_shard",
>>>>>>> 3eb27be82 (change naming in mods)
		chance = 1,
		min = 0,
		max = 2,
		looting = "common",},

		-- TODO: Only drop if killed by player
<<<<<<< HEAD
		{name = "vlc_sponges:sponge_wet",
=======
		{name = "vlf_sponges:sponge_wet",
>>>>>>> 3eb27be82 (change naming in mods)
		chance = 1,
		min = 1,
		max = 1,},

		-- The following drops are approximations
		-- Fish / prismarine crystal
<<<<<<< HEAD
		{name = "vlc_fishing:fish_raw",
=======
		{name = "vlf_fishing:fish_raw",
>>>>>>> 3eb27be82 (change naming in mods)
		chance = 4,
		min = 1,
		max = 1,
		looting = "common",},
<<<<<<< HEAD
		{name = "vlc_ocean:prismarine_crystals",
=======
		{name = "vlf_ocean:prismarine_crystals",
>>>>>>> 3eb27be82 (change naming in mods)
		chance = 1,
		min = 1,
		max = 10,
		looting = "common",},

		-- Rare drop: fish
<<<<<<< HEAD
		{name = "vlc_fishing:fish_raw",
=======
		{name = "vlf_fishing:fish_raw",
>>>>>>> 3eb27be82 (change naming in mods)
		chance = 160, -- 2.5% / 4
		min = 1,
		max = 1,
		looting = "rare",
		looting_factor = 0.01 / 4,},
<<<<<<< HEAD
		{name = "vlc_fishing:salmon_raw",
=======
		{name = "vlf_fishing:salmon_raw",
>>>>>>> 3eb27be82 (change naming in mods)
		chance = 160,
		min = 1,
		max = 1,
		looting = "rare",
		looting_factor = 0.01 / 4,},
<<<<<<< HEAD
		{name = "vlc_fishing:clownfish_raw",
=======
		{name = "vlf_fishing:clownfish_raw",
>>>>>>> 3eb27be82 (change naming in mods)
		chance = 160,
		min = 1,
		max = 1,
		looting = "rare",
		looting_factor = 0.01 / 4,},
<<<<<<< HEAD
		{name = "vlc_fishing:pufferfish_raw",
=======
		{name = "vlf_fishing:pufferfish_raw",
>>>>>>> 3eb27be82 (change naming in mods)
		chance = 160,
		min = 1,
		max = 1,
		looting = "rare",
		looting_factor = 0.01 / 4,},
	},
	fly = true,
	makes_footstep_sound = false,
<<<<<<< HEAD
	fly_in = { "vlc_core:water_source", "vlcx_core:river_water_source" },
=======
	fly_in = { "vlf_core:water_source", "vlfx_core:river_water_source" },
>>>>>>> 3eb27be82 (change naming in mods)
	jump = false,
})

-- spawn eggs
<<<<<<< HEAD
vlc_mobs.register_egg("mobs_mc:guardian_elder", S("Elder Guardian"), "#ceccba", "#747693", 0)
=======
vlf_mobs.register_egg("mobs_mc:guardian_elder", S("Elder Guardian"), "#ceccba", "#747693", 0)
>>>>>>> 3eb27be82 (change naming in mods)


