local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
-- Ancient Hermitage - mini ancient city

vlc_structures.register_structure("ancient_hermitage",{
	place_on = {"vlc_deepslate:deepslate","vlc_sculk:sculk"},
	fill_ratio = 0.01,
	flags = "all_floors",
	solid_ground = true,
	make_foundation = true,
	chunk_probability = 5, --high prob since placement underground is relatively unlikely
	y_max = vlc_vars.mg_overworld_min + 72,
	y_min = vlc_vars.mg_overworld_min + 12,
	biomes = { "DeepDark" },
	sidelen = 32,
	filenames = {
		vlc_structures.schempath.."/schems/vlc_structures_ancient_hermitage.mts",
		vlc_structures.schempath.."/schems/vlc_structures_ancient_hermitage_2.mts",
		vlc_structures.schempath.."/schems/vlc_structures_ancient_hermitage_3.mts",
		vlc_structures.schempath.."/schems/vlc_structures_ancient_hermitage_4.mts",
	},

	loot = {
		["vlc_chests:chest_small" ] ={{
			stacks_min = 3,
			stacks_max = 3,
			items = {
				{ itemstring = "vlc_core:coal_lump", weight = 7, amount_min = 6, amount_max=15 },
				{ itemstring = "vlc_mobitems:bone", weight = 5, amount_min = 1, amount_max = 15 },
				{ itemstring = "vlc_blackstone:soul_torch", weight = 5, amount_min = 1, amount_max=15 },
				{ itemstring = "vlc_books:book", weight = 5, amount_min = 3, amount_max=10 },
				{ itemstring = "vlc_potions:regeneration", weight = 5, amount_min = 1, amount_max=1 },
				{ itemstring = "vlc_books:book", weight = 5, func = function(stack, pr)vlc_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },

				--{ itemstring = "vlc_jukebox:disc_fragment", weight = 4, amount_min = 1, amount_max = 3 },

				{ itemstring = "vlc_amethyst:amethyst_shard", weight = 3, amount_min = 1, amount_max = 15 },
				{ itemstring = "vlc_lush_caves:glow_berry", weight = 3, amount_min = 1, amount_max = 15 },
				{ itemstring = "vlc_sculk:sculk", weight = 3, amount_min = 4, amount_max = 10 },
				--{ itemstring = "vlc_candles:candle", weight = 3, amount_min = 1, amount_max = 4 },
				{ itemstring = "vlc_experience:bottle", weight = 3, amount_min = 1, amount_max = 3 },
				--{ itemstring = "vlc_sculk:sensor", weight = 3, amount_min = 1, amount_max = 3 },
				--SWIFT SNEAK{ itemstring = "vlc_books:book", weight = 5, func = function(stack, pr)vlc_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },

				{ itemstring = "vlc_armor:leggings_iron", weight = 1, func = function(stack, pr)vlc_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlc_armor:ward", weight = 1 },
				-- { itemstring = "vlc_armor:silence", weight = 1 }, --TODO: Add silence armor trim

				{ itemstring = "vlc_sculk:catalyst", weight = 2, amount_min = 1, amount_max = 2 },
				{ itemstring = "vlc_compass:compass", weight = 2, amount_min = 1, amount_max = 1 },
				{ itemstring = "vlc_jukebox:record_1", weight = 2 },
				{ itemstring = "vlc_jukebox:record_4", weight = 2 },

				--{ itemstring = "vlc_mobitems:LEAD", weight = 2, amount_min = 1, amount_max = 1 },
				{ itemstring = "vlc_mobitems:nametag", weight = 2, amount_min = 1, amount_max = 3 },
				{ itemstring = "vlc_mobitems:saddle", weight = 2, amount_min = 1, amount_max = 1 },

				{ itemstring = "vlc_farming:hoe_diamond", weight = 2, amount_min = 1, amount_max = 1 },
				{ itemstring = "vlc_mobitems:diamond_horse_armor", weight = 2 },

				{ itemstring = "vlc_core:apple_gold_enchanted", weight = 1 },
				{ itemstring = "vlc_jukebox:record_8", weight = 2 },

			}},
		}
	}
})
