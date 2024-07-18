local water_level = minetest.get_mapgen_setting("water_level")
local modpath = minetest.get_modpath("vlf_structures")

--schematics by chmodsayshello
local schems = {
	vlf_structures.schempath.."/schems/vlf_structures_shipwreck_full_damaged.mts",
	vlf_structures.schempath.."/schems/vlf_structures_shipwreck_full_normal.mts",
	vlf_structures.schempath.."/schems/vlf_structures_shipwreck_full_back_damaged.mts",
	vlf_structures.schempath.."/schems/vlf_structures_shipwreck_half_front.mts",
	vlf_structures.schempath.."/schems/vlf_structures_shipwreck_half_back.mts",
}

local ocean_biomes = {
	"RoofedForest_ocean",
	"JungleEdgeM_ocean",
	"BirchForestM_ocean",
	"BirchForest_ocean",
	"IcePlains_deep_ocean",
	"Jungle_deep_ocean",
	"Savanna_ocean",
	"MesaPlateauF_ocean",
	"ExtremeHillsM_deep_ocean",
	"Savanna_deep_ocean",
	"SunflowerPlains_ocean",
	"Swampland_deep_ocean",
	"Swampland_ocean",
	"MegaSpruceTaiga_deep_ocean",
	"ExtremeHillsM_ocean",
	"JungleEdgeM_deep_ocean",
	"SunflowerPlains_deep_ocean",
	"BirchForest_deep_ocean",
	"IcePlainsSpikes_ocean",
	"Mesa_ocean",
	"StoneBeach_ocean",
	"Plains_deep_ocean",
	"JungleEdge_deep_ocean",
	"SavannaM_deep_ocean",
	"Desert_deep_ocean",
	"Mesa_deep_ocean",
	"ColdTaiga_deep_ocean",
	"Plains_ocean",
	"MesaPlateauFM_ocean",
	"Forest_deep_ocean",
	"JungleM_deep_ocean",
	"FlowerForest_deep_ocean",
	"MushroomIsland_ocean",
	"MegaTaiga_ocean",
	"StoneBeach_deep_ocean",
	"IcePlainsSpikes_deep_ocean",
	"ColdTaiga_ocean",
	"SavannaM_ocean",
	"MesaPlateauF_deep_ocean",
	"MesaBryce_deep_ocean",
	"ExtremeHills+_deep_ocean",
	"ExtremeHills_ocean",
	"MushroomIsland_deep_ocean",
	"Forest_ocean",
	"MegaTaiga_deep_ocean",
	"JungleEdge_ocean",
	"MesaBryce_ocean",
	"MegaSpruceTaiga_ocean",
	"ExtremeHills+_ocean",
	"Jungle_ocean",
	"RoofedForest_deep_ocean",
	"IcePlains_ocean",
	"FlowerForest_ocean",
	"ExtremeHills_deep_ocean",
	"MesaPlateauFM_deep_ocean",
	"Desert_ocean",
	"Taiga_ocean",
	"BirchForestM_deep_ocean",
	"Taiga_deep_ocean",
	"JungleM_ocean"
}

local buried_treasure = {
	{
		stacks_min = 1,
		stacks_max = 1,
		items = {
			{ itemstring = "vlf_mobitems:heart_of_the_sea", weight = 100, amount_min = 1, amount_max = 1 },
		}
	},
	{
		stacks_min = 5,
		stacks_max = 8,
		items = {
			{ itemstring = "vlf_core:iron_ingot", weight = 20, amount_min = 1, amount_max = 4 },
			{ itemstring = "vlf_core:gold_ingot", weight = 10, amount_min = 1, amount_max = 4 },
			{ itemstring = "vlf_tnt:tnt", weight = 1, amount_min = 1, amount_max = 2 },
		}
	},
	{
		stacks_min = 2,
		stacks_max = 2,
		items = {
			{ itemstring = "vlf_fishing:fish_cooked", weight = 1, amount_min = 2, amount_max = 4 },
			{ itemstring = "vlf_fishing:salmon_cooked", weight = 1, amount_min = 2, amount_max = 4 },
		}
	},
	{
		stacks_min = 1,
		stacks_max = 4,
		items = {
			{ itemstring = "vlf_core:emerald", weight = 5, amount_min = 4, amount_max = 8 },
			{ itemstring = "vlf_ocean:prismarine_crystals", weight = 5, amount_min = 1, amount_max = 5 },
			{ itemstring = "vlf_core:diamond", weight = 5, amount_min = 1, amount_max = 2 },
		}
	},
	{
		stacks_min = 0,
		stacks_max = 1,
		items = {
			{ itemstring = "vlf_armor:chestplate_leather", weight = 1, amount_min = 1, amount_max = 1 },
			{ itemstring = "vlf_tools:sword_iron", weight = 1, amount_min = 1, amount_max = 1 },
		}
	},
}

local function get_treasure_map(cpos)
	local stack = ItemStack("vlf_books:written_book")
	local bookmeta = stack:get_meta()
	bookmeta:set_string("text", "There is a treasure at \n"..minetest.pos_to_string(cpos))
	bookmeta:set_string("author", "The Albatross")
	bookmeta:set_string("title", "Treasure")
	bookmeta:set_string("description", "Treasure")
	return stack
end

vlf_structures.register_structure("shipwreck",{
	place_on = {"group:sand","vlf_core:gravel"},
	spawn_by = {"group:water"},
	num_spawn_by = 4,
	noise_params = {
		offset = 0,
		scale = 0.000022,
		spread = {x = 250, y = 250, z = 250},
		seed = 3,
		octaves = 3,
		persist = 0.001,
		flags = "absvalue",
	},
	sidelen = 16,
	flags = "force_placement",
	biomes = ocean_biomes,
	y_max = water_level-4,
	y_min = vlf_vars.mg_overworld_min,
	filenames = schems,
	y_offset = function(pr) return pr:next(-4,-2) end,
	after_place = function(p,def,pr)
		local pos = vector.new(p.x, 1, p.z)
		local sand = minetest.find_nodes_in_area_under_air(vector.offset(pos, -64, -2, -64), vector.offset(pos, 64, 5, 64), {"vlf_core:sand", "vlf_core:gravel", "vlf_core:dirt_with_grass", "vlf_core:mycelium", "vlf_core:podzol"})
		local chests = minetest.find_nodes_in_area_under_air(vector.offset(pos, -8, -7, -8), vector.offset(pos, 8, 8, 8), {"vlf_chests:chest_small"})
		if sand and #sand > 0 then
			local ppos = sand[pr:next(1,#sand)]
			local depth = pr:next(1,4)
			local cpos = vector.offset(ppos, 0, -depth, 0)
			minetest.set_node(cpos, {name = "vlf_chests:chest_small"})
			minetest.registered_nodes["vlf_chests:chest_small"].on_construct(cpos)
			vlf_loot.fill_inventory(minetest.get_meta(cpos):get_inventory(), "main", vlf_loot.get_multi_loot(buried_treasure, pr), pr)
			if chests and #chests > 0 then
				local cchest = chests[pr:next(1,#chests)]
				minetest.get_meta(cchest):get_inventory():add_item("main", get_treasure_map(cpos))
			end
		end
	end,
	loot = {
		["vlf_chests:chest_small"] = {
			{
				stacks_min = 3,
				stacks_max = 10,
				items = {
					{ itemstring = "vlf_sus_stew:stew", weight = 10, amount_min = 1, amount_max = 1 },
					{ itemstring = "vlf_core:paper", weight = 8, amount_min = 1, amount_max = 12 },
					{ itemstring = "vlf_farming:wheat_item", weight = 7, amount_min = 8, amount_max = 21 },
					{ itemstring = "vlf_farming:carrot_item", weight = 7, amount_min = 4, amount_max = 8 },
					{ itemstring = "vlf_farming:potato_item_poison", weight = 7, amount_min = 2, amount_max = 6 },
					{ itemstring = "vlf_farming:potato_item", weight = 7, amount_min = 2, amount_max = 6 },
					{ itemstring = "vlf_lush_caves:moss", weight = 7, amount_min = 1, amount_max = 4 },
					{ itemstring = "vlf_core:coal_lump", weight = 6, amount_min = 2, amount_max = 8 },
					{ itemstring = "vlf_mobitems:rotten_flesh", weight = 5, amount_min = 5, amount_max = 24 },
					{ itemstring = "vlf_farming:potato_item", weight = 3, amount_min = 1, amount_max = 5 },
					{ itemstring = "vlf_armor:helmet_leather_enchanted", weight = 3, func = function(stack, pr)
							vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}) end },
					{ itemstring = "vlf_armor:chestplate_leather_enchanted", weight = 3, func = function(stack, pr)
							vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}) end },
					{ itemstring = "vlf_armor:leggings_leather_enchanted", weight = 3, func = function(stack, pr)
							vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}) end },
					{ itemstring = "vlf_armor:boots_leather_enchanted", weight = 3, func = function(stack, pr)
							vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}) end },
					{ itemstring = "vlf_bamboo:bamboo", weight = 2, amount_min = 1, amount_max = 3 },
					{ itemstring = "vlf_farming:pumpkin", weight = 2, amount_min = 1, amount_max = 3 },
					{ itemstring = "vlf_tnt:tnt", weight = 1, amount_min = 1, amount_max = 2 },
				}
			},
			{
			stacks_min = 2,
			stacks_max = 6,
			items = {
				{ itemstring = "vlf_core:iron_ingot", weight = 90, amount_min = 1, amount_max = 5 },
				{ itemstring = "vlf_core:iron_nugget", weight = 50, amount_min = 1, amount_max = 10 },
				{ itemstring = "vlf_core:emerald", weight = 40, amount_min = 1, amount_max = 5 },
				{ itemstring = "vlf_core:lapis", weight = 20, amount_min = 1, amount_max = 10 },
				{ itemstring = "vlf_core:gold_ingot", weight = 10, amount_min = 1, amount_max = 5 },
				{ itemstring = "vlf_core:gold_nugget", weight = 10, amount_min = 1, amount_max = 10 },
				{ itemstring = "vlf_experience:bottle", weight = 5, amount_min = 1, amount_max = 1 },
				{ itemstring = "vlf_core:diamond", weight = 5, amount_min = 1, amount_max = 1 },
				}
			},{
			stacks_min = 3,
			stacks_max = 3,
			items = {
				--{ itemstring = "FIXME TREASURE MAP", weight = 8, amount_min = 1, amount_max = 5 },
				{ itemstring = "vlf_core:paper", weight = 20, amount_min = 1, amount_max = 10 },
				{ itemstring = "vlf_mobitems:feather", weight = 10, amount_min = 1, amount_max = 5 },
				{ itemstring = "vlf_books:book", weight = 5, amount_min = 1, amount_max = 5 },
				{ itemstring = "vlf_clock:clock", weight = 1, amount_min = 1, amount_max = 1 },
				{ itemstring = "vlf_compass:compass", weight = 1, amount_min = 1, amount_max = 1 },
				{ itemstring = "vlf_maps:empty_map", weight = 1, amount_min = 1, amount_max = 1 },
				{ itemstring = "vlf_armor:coast", weight = 20, amount_min = 2, amount_max = 2},
				}
			},
		}
	}
})

local spawnon = { "vlf_stairs:slab_prismarine_dark"}

vlf_structures.register_structure("ocean_temple",{
	place_on = {"group:sand","vlf_core:gravel"},
	spawn_by = {"group:water"},
	num_spawn_by = 4,
	noise_params = {
		offset = 0,
		scale = 0.0000122,
		spread = {x = 250, y = 250, z = 250},
		seed = 32345,
		octaves = 3,
		persist = 0.001,
		flags = "absvalue",
	},
	sidelen = 32,
	flags = "force_placement",
	biomes = ocean_biomes,
	y_max = water_level-4,
	y_min = vlf_vars.mg_overworld_min,
	filenames = {
		modpath .. "/schematics/vlf_structures_ocean_temple.mts",
		modpath .. "/schematics/vlf_structures_ocean_temple_2.mts",
	},
	y_offset = function(pr) return pr:next(-2,0) end,
	after_place = function(p,def,pr)
		local p1 = vector.offset(p,-9,0,-9)
		local p2 = vector.offset(p,9,32,9)
		vlf_structures.spawn_mobs("mobs_mc:guardian",spawnon,p1,p2,pr,5,true)
		vlf_structures.spawn_mobs("mobs_mc:guardian_elder",spawnon,p1,p2,pr,1,true)
		vlf_structures.construct_nodes(p1,p2,{"group:wall"})
	end,
	loot = {
		["vlf_chests:chest_small"] = {
			{
				stacks_min = 3,
				stacks_max = 10,
				items = {
					{ itemstring = "vlf_sus_stew:stew", weight = 10, amount_min = 1, amount_max = 1 },
					{ itemstring = "vlf_core:paper", weight = 8, amount_min = 1, amount_max = 12 },
					{ itemstring = "vlf_fishing:fish_raw", weight = 5, amount_min = 8, amount_max = 21 },
					{ itemstring = "vlf_fishing:salmon_raw", weight = 7, amount_min = 4, amount_max = 8 },
					{ itemstring = "vlf_tnt:tnt", weight = 1, amount_min = 1, amount_max = 2 },
				}
			},
			{
				stacks_min = 2,
				stacks_max = 6,
				items = {
					{ itemstring = "vlf_core:iron_ingot", weight = 10, amount_min = 1, amount_max = 5 },
					{ itemstring = "vlf_core:goldblock", weight = 1, amount_min = 1, amount_max = 2 },
					{ itemstring = "vlf_experience:bottle", weight = 5, amount_min = 1, amount_max = 1 },
					{ itemstring = "vlf_core:diamond", weight = 5, amount_min = 1, amount_max = 1 },
					{ itemstring = "vlf_fishing:fishing_rod", weight = 1, amount_min = 1, amount_max = 1 },
				}
			},
			{
				stacks_min = 4,
				stacks_max = 4,
				items = {
					--{ itemstring = "FIXME TREASURE MAP", weight = 8, amount_min = 1, amount_max = 5 },
					{ itemstring = "vlf_books:book", weight = 1, amount_min = 1, amount_max = 5 },
					{ itemstring = "vlf_clock:clock", weight = 1, amount_min = 1, amount_max = 1 },
					{ itemstring = "vlf_compass:compass", weight = 1, amount_min = 1, amount_max = 1 },
					{ itemstring = "vlf_maps:empty_map", weight = 1, amount_min = 1, amount_max = 1 },
				}
			},
		}
	}
})

vlf_structures.register_structure_spawn({
	name = "mobs_mc:guardian",
	y_min = vlf_vars.mg_overworld_min,
	y_max = vlf_vars.mg_overworld_max,
	chance = 10,
	interval = 60,
	limit = 9,
	spawnon = spawnon,
})

vlf_structures.register_structure_spawn({
	name = "mobs_mc:guardian_elder",
	y_min = vlf_vars.mg_overworld_min,
	y_max = vlf_vars.mg_overworld_max,
	chance = 100,
	interval = 60,
	limit = 4,
	spawnon = spawnon,
})
