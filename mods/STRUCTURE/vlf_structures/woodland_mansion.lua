local spawnon = {"vlf_deepslate:deepslate","vlf_trees:wood_birch","vlf_wool:red_carpet","vlf_wool:brown_carpet"}

vlf_structures.register_structure("woodland_cabin",{
	place_on = {"group:grass_block","group:dirt","vlf_core:dirt_with_grass"},
	fill_ratio = 0.01,
	flags = "place_center_x, place_center_z",
	solid_ground = true,
	make_foundation = true,
	chunk_probability = 800,
	y_max = vlf_vars.mg_overworld_max,
	y_min = 1,
	biomes = { "Dark_Forest" },
	sidelen = 32,
	filenames = {
		vlf_structures.schempath.."/schems/vlf_structures_woodland_cabin.mts",
		vlf_structures.schempath.."/schems/vlf_structures_woodland_outpost.mts",
	},
	construct_nodes = {"vlf_barrels:barrel_closed","vlf_books:bookshelf"},
	after_place = function(p,def,pr)
		local p1=vector.offset(p,-def.sidelen,-1,-def.sidelen)
		local p2=vector.offset(p,def.sidelen,def.sidelen,def.sidelen)
		vlf_structures.spawn_mobs("mobs_mc:vindicator",spawnon,p1,p2,pr,5)
		vlf_structures.spawn_mobs("mobs_mc:evoker",spawnon,p1,p2,pr,1)
		vlf_structures.spawn_mobs("mobs_mc:parrot",{"vlf_heads:wither_skeleton"},p1,p2,pr,1)
	end,
	loot = {
		["vlf_chests:chest_small" ] ={{
			stacks_min = 3,
			stacks_max = 3,
			items = {
				{ itemstring = "vlf_mobitems:bone", weight = 10, amount_min = 1, amount_max=8 },
				{ itemstring = "vlf_mobitems:gunpowder", weight = 10, amount_min = 1, amount_max = 8 },
				{ itemstring = "vlf_mobitems:rotten_flesh", weight = 10, amount_min = 1, amount_max=8 },
				{ itemstring = "vlf_mobitems:string", weight = 10, amount_min = 1, amount_max=8 },

				{ itemstring = "vlf_core:gold_ingot", weight = 15, amount_min = 2, amount_max = 7 },
			}},{
				stacks_min = 1,
				stacks_max = 4,
				items = {
				{ itemstring = "vlf_farming:wheat_item", weight = 20, amount_min = 1, amount_max = 4 },
				{ itemstring = "vlf_farming:bread", weight = 20, amount_min = 1, amount_max = 1 },
				{ itemstring = "vlf_core:coal_lump", weight = 15, amount_min = 1, amount_max = 4 },
				{ itemstring = "mesecons:mesecon", weight = 15, amount_min = 1, amount_max = 4 },
				{ itemstring = "vlf_farming:beetroot_seeds", weight = 10, amount_min = 2, amount_max = 4 },
				{ itemstring = "vlf_farming:melon_seeds", weight = 10, amount_min = 2, amount_max = 4 },
				{ itemstring = "vlf_farming:pumpkin_seeds", weight = 10, amount_min = 2, amount_max = 4 },
				{ itemstring = "vlf_core:iron_ingot", weight = 10, amount_min = 1, amount_max = 4 },
				{ itemstring = "vlf_buckets:bucket_empty", weight = 10, amount_min = 1, amount_max = 1 },
				{ itemstring = "vlf_core:gold_ingot", weight = 5, amount_min = 1, amount_max = 4 },
			}},{
				stacks_min = 1,
				stacks_max = 4,
				items = {
				--{ itemstring = "FIXME:lead", weight = 20, amount_min = 1, amount_max = 1 },
				{ itemstring = "vlf_mobitems:nametag", weight = 2, amount_min = 1, amount_max = 3 },
				{ itemstring = "vlf_books:book", weight = 1, func = function(stack, pr)vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlf_armor:chestplate_chain", weight = 1, },
				{ itemstring = "vlf_armor:chestplate_diamond", weight = 1, },
				{ itemstring = "vlf_core:apple_gold_enchanted", weight = 2, },
				{ itemstring = "vlf_armor:vex", amount_max = 1, },
			}
		}}
	}
})

vlf_structures.register_structure_spawn({
	name = "mobs_mc:vindicator",
	y_min = vlf_vars.mg_overworld_min,
	y_max = vlf_vars.mg_overworld_max,
	chance = 10,
	interval = 60,
	limit = 6,
	spawnon = spawnon,
})

vlf_structures.register_structure_spawn({
	name = "mobs_mc:evoker",
	y_min = vlf_vars.mg_overworld_min,
	y_max = vlf_vars.mg_overworld_max,
	chance = 50,
	interval = 60,
	limit = 6,
	spawnon = spawnon,
})
