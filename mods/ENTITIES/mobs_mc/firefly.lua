-- LICENSE FOR CODE: GPL 3.0
local S = minetest.get_translator(minetest.get_current_modname())

vlf_mobs.register_mob("mobs_mc:firefly", {
	description = S("Firefly"),
	type = "animal",
	spawn_class = "ambient",
	can_despawn = false,
	passive = true,
	hp_min = 1,
	hp_max = 1,
	collisionbox = {-0.01, -0.01, -0.01, 0.01, 0.01, 0.01},
	visual = "sprite",
	textures = {"mobs_mc_firefly_frame_0.png"},
	glow = 10,
	visual_size = {x = 0.125, y = 0.0625},
	sounds = {
		-- No sounds for the firefly by default
	},
	walk_velocity = 0.3,
	run_velocity = 0.3,
	animation = {
		stand_speed = 0,
		stand_start = 0,
		stand_end = 0,
		walk_speed = 0,
		walk_start = 0,
		walk_end = 0,
		run_speed = 0,
		run_start = 0,
		run_end = 0,
		die_speed = 0,
		die_start = 0,
		die_end = 0,
		die_loop = false,
	},
	walk_chance = 100,
	fall_damage = 0,
	sunlight_damage = 2,
	view_range = 8,
	fear_height = 0,
	jump = false,
	fly = true,
	makes_footstep_sound = false,
	do_custom = mobs_mc.firefly_animation()
})

-- Spawning Due to issues this can't be used. See code after this for spawning function.
--[[vlf_mobs.spawn_setup({
	name = "mobs_mc:firefly",
	dimension = "overworld",
	type_of_spawning = "ground",
	min_height = 3,
	min_light = 1,
	max_light = 5,
	aoc = 80,
	chance = 2400,
	biomes = {
		"SwampLand",
		"MangroveSwamp",
		"JungleEdge",
		"Jungle",
	},
})]]

minetest.register_node("mobs_mc:firefly_spawner", {
	description = "Firefly Spawner",
	tiles = {"blank.png"},
	groups = {not_in_creative_inventory=1},
	is_ground_content = true,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	floodable = false,
	use_texture_alpha = "clip",
	oost_effect_color = {a=0},
})

minetest.register_lbm({
	name = "mobs_mc:firefly_spawn_lbm",
	nodenames = {"mobs_mc:firefly_spawner"},
	run_at_every_load = true,
	action = function(pos, node, metadata, run_at_every_load)
		local biomes = {
			"SwampLand",
			"MangroveSwamp",
			"JungleEdge",
			"Jungle",
		}
		local biome_data = minetest.get_biome_data(pos)
		local biome_name = minetest.get_biome_name(biome_data.biome)
		local biome_match = false
		for _, biome in ipairs(biomes) do
			if biome_name == biome then
				biome_match = true
				break
			end
		end
		if biome_match then
			local pos_below = {x=pos.x, y=pos.y-1, z=pos.z}
			if minetest.get_node(pos_below).name ~= "mobs_mc:firefly_spawner" or minetest.get_node(pos_below).name ~= "air" then
				minetest.remove_node(pos)
			else
				vlf_mobs.spawn(pos, "mobs_mc:firefly")
			end
		else
			minetest.remove_node(pos) --Not in a biome that fireflies can spawn in, so no need to keep. Though technically the blocks should never be placed in any biome that isn't in the above table, however strange things can happen.
		end
	end,
})

-- spawn eggs
vlf_mobs.register_egg("mobs_mc:firefly", S("Firefly"), "#113151", "#ddbfa2", 0)
