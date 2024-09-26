--Phantom for mcl2
--cora
--License for code WTFPL, cc0
local S = minetest.get_translator("mobs_mc")

vlf_mobs.register_mob("mobs_mc:phantom", {
	description = S("Phantom"),
	type = "monster",
	spawn_class = "passive",
	pathfinding = 1,
	hp_min = 6,
	hp_max = 6,
	xp_min = 1,
	damage = 2,
	xp_max = 3,
	collisionbox = {-0.25, -0.01, -0.25, 0.25, 0.89, 0.25},
	visual = "mesh",
	mesh = "mobs_mc_phantom.b3d",
	textures = {{"mobs_mc_phantom.png","mobs_mc_phantom_e.png","mobs_mc_phantom_e_s.png"}},
	visual_size = {x=3, y=3},
	walk_velocity = 3,
	run_velocity = 5,
	desired_altitude = 19,
	drops = {
		{name = "vlf_mobitems:phantom_membrane", chance = 2, min = 0, max = 1, looting = "common"},
	},
	--[[sounds = {
		random = "mobs_mc_phantom_random",
		damage = {name="mobs_mc_phantom_hurt", gain=0.3},
		death = {name="mobs_mc_phantom_death", gain=0.6},
		eat = "mobs_mc_animal_eat_generic",
		distance = 16,
	},]]
	animation = {
		stand_speed = 50,
		walk_speed = 50,
		fly_speed = 50,
		stand_start = 0,
		stand_end = 0,
		fly_start = 0,
		fly_end = 30,
		walk_start = 0,
		walk_end = 30,
	},
	fall_damage = 0,
	fall_speed = -2.25,
	attack_type = "dogfight",
	floats = 1,
	physical = true,
	fly = true,
	fly_in = { "air" },
	fly_velocity = 4,
	harmed_by_heal = true,
	makes_footstep_sound = false,
	ignited_by_sunlight = true,
	sunlight_damage = 2,
	fear_height = 0,
	view_range = 40,
})

-- spawn eggs
vlf_mobs.register_egg("mobs_mc:phantom", S("Phantom"), "#FBDDCC", "#FBaa99", 0)
