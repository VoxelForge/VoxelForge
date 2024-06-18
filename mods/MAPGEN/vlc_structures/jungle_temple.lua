local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

vlc_structures.register_structure("jungle_temple",{
	place_on = {"group:grass_block","group:dirt","vlc_core:dirt_with_grass"},
	fill_ratio = 0.01,
	flags = "place_center_x, place_center_z",
	solid_ground = true,
	make_foundation = true,
	y_offset = function(pr) return pr:next(-3,0) -5 end,
	chunk_probability = 200,
	y_max = vlc_vars.mg_overworld_max,
	y_min = 1,
	biomes = { "Jungle" },
	sidelen = 18,
	filenames = {
		vlc_structures.schempath.."/schems/vlc_structures_jungle_temple.mts",
		vlc_structures.schempath.."/schems/vlc_structures_jungle_temple_nice.mts",
	},
	loot = {
		["vlc_chests:trapped_chest_small" ] ={{
			stacks_min = 2,
			stacks_max = 6,
			items = {
				{ itemstring = "vlc_mobitems:bone", weight = 20, amount_min = 4, amount_max=6 },
				{ itemstring = "vlc_mobitems:rotten_flesh", weight = 16, amount_min = 3, amount_max=7 },
				{ itemstring = "vlc_core:gold_ingot", weight = 15, amount_min = 2, amount_max = 7 },
				{ itemstring = "vlc_bamboo:bamboo", weight = 15, amount_min = 1, amount_max=3 },
				{ itemstring = "vlc_core:iron_ingot", weight = 15, amount_min = 1, amount_max = 5 },
				{ itemstring = "vlc_core:diamond", weight = 3, amount_min = 1, amount_max = 3 },
				{ itemstring = "vlc_mobitems:saddle", weight = 3, },
				{ itemstring = "vlc_core:emerald", weight = 2, amount_min = 1, amount_max = 3 },
				{ itemstring = "vlc_books:book", weight = 1, func = function(stack, pr)
					vlc_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
				end },
				{ itemstring = "vlc_mobitems:iron_horse_armor", weight = 1, },
				{ itemstring = "vlc_mobitems:gold_horse_armor", weight = 1, },
				{ itemstring = "vlc_mobitems:diamond_horse_armor", weight = 1, },
				{ itemstring = "vlc_core:apple_gold_enchanted", weight = 2, },
				{ itemstring = "vlc_armor:wild", amount_min = 1, amount_max = 1, },
			}
		}}
	}
})
