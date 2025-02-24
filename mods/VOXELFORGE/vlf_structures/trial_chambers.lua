vlf_structures.register_structure("trial_chambers",{
	place_on = {"mcl_deepslate:deepslate"},
	flags = "place_center_x, place_center_z",
	--solid_ground = true,
	--make_foundation = true,
	y_offset = function(pr) return pr:next(-3,0) -5 end,
	chunk_probability = 2,
	fill_ratio = 50,
	y_max = -60,
	y_min = -100,
	--biomes = {},
	sidelen = 10,
	filenames = {
		"data/voxelforge/structure/trial_chambers/corridor/end_1.gamedata",
		"data/voxelforge/structure/trial_chambers/corridor/end_2.gamedata",
		"data/voxelforge/structure/trial_chambers/corridor/end_3.gamedata",
	},
})
