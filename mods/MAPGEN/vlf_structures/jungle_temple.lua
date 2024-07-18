vlf_structures.register_structure("jungle_temple",{
	place_on = {"group:grass_block","group:dirt","vlf_core:dirt_with_grass"},
	fill_ratio = 0.01,
	flags = "place_center_x, place_center_z",
	solid_ground = true,
	make_foundation = true,
	y_offset = function(pr) return pr:next(-3,0) -5 end,
	chunk_probability = 200,
	y_max = vlf_vars.mg_overworld_max,
	y_min = 1,
	biomes = { "Jungle" },
	sidelen = 18,
	filenames = {
		vlf_structures.schempath.."/schems/vlf_structures_jungle_temple.mts",
		vlf_structures.schempath.."/schems/vlf_structures_jungle_temple_nice.mts",
	},
	loot = {
		["vlf_chests:trapped_chest_small" ] ={{
			stacks_min = 2,
			stacks_max = 6,
			items = {
				{ itemstring = "vlf_mobitems:bone", weight = 20, amount_min = 4, amount_max=6 },
				{ itemstring = "vlf_mobitems:rotten_flesh", weight = 16, amount_min = 3, amount_max=7 },
				{ itemstring = "vlf_core:gold_ingot", weight = 15, amount_min = 2, amount_max = 7 },
				{ itemstring = "vlf_bamboo:bamboo", weight = 15, amount_min = 1, amount_max=3 },
				{ itemstring = "vlf_core:iron_ingot", weight = 15, amount_min = 1, amount_max = 5 },
				{ itemstring = "vlf_core:diamond", weight = 3, amount_min = 1, amount_max = 3 },
				{ itemstring = "vlf_mobitems:saddle", weight = 3, },
				{ itemstring = "vlf_core:emerald", weight = 2, amount_min = 1, amount_max = 3 },
				{ itemstring = "vlf_books:book", weight = 1, func = function(stack, pr)
					vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
				end },
				{ itemstring = "vlf_mobitems:iron_horse_armor", weight = 1, },
				{ itemstring = "vlf_mobitems:gold_horse_armor", weight = 1, },
				{ itemstring = "vlf_mobitems:diamond_horse_armor", weight = 1, },
				{ itemstring = "vlf_core:apple_gold_enchanted", weight = 2, },
				{ itemstring = "vlf_armor:wild", amount_min = 1, amount_max = 1, },
			}
		}}
	}
})
