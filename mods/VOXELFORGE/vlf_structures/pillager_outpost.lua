local spawnon = {"mcl_trees:wood_birch"}

vlf_structures.register_structure("pillager_outpost",{
	place_on = {"group:grass_block","group:dirt","mcl_core:dirt_with_grass","group:sand"},
	flags = "place_center_x, place_center_z",
	--solid_ground = true,
	make_foundation = true,
	terrain_setting = "terrain_matching",
	include_entities = true,
	wom = "false",
	sidelen = 32,
	y_offset = 0,
	chunk_probability = 15,
	y_max = mcl_vars.mg_overworld_max,
	y_min = 1,
	biomes = { "Desert", "Plains", "Savanna", "IcePlains", "Taiga" },
	--construct_nodes = {"mcl_anvils:anvil_damage_2"},
	filenames = {
		"data/voxelforge/structure/pillager_outpost/base_plate.gamedata",
	},
})

vlf_structures.register_structure_spawn({
	name = "mobs_mc:pillager",
	y_min = mcl_vars.mg_overworld_min,
	y_max = mcl_vars.mg_overworld_max,
	chance = 1,
	interval = 6,
	limit = 9,
	spawnon = spawnon,
	radius = 15,
})
