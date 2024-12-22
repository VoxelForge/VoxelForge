local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

local spawnon = {"vlf_end:purpur_block"}

local function spawn_shulkers(pos,def,pr)
	local p1 = vector.offset(pos,-def.sidelen/2,-1,-def.sidelen/2)
	local p2 = vector.offset(pos,def.sidelen/2,def.sidelen,def.sidelen/2)
	vlf_structures.spawn_mobs("mobs_mc:shulker",spawnon,p1,p2,pr,1)

	local guard = minetest.find_node_near(pos,def.sidelen,{"vlf_itemframes:frame"})
	if guard then
		minetest.add_entity(vector.offset(guard,0,-0.5,0),"mobs_mc:shulker")
	end
end

vlf_structures.register_structure("end_shipwreck",{
	place_on = {"vlf_end:end_stone"},
	flags = "place_center_x, place_center_z, all_floors",
	y_offset = function(pr) return pr:next(-50,-20) end,
	chunk_probability = 20,
	--y_max = vlf_vars.mg_end_max,
	--y_min = vlf_vars.mg_end_min -100,
	biomes = { "End", "EndHighlands", "EndMidlands", "EndBarrens", "EndSmallIslands" },
	sidelen = 32,
	filenames = {
		modpath.."/schematics/vlf_structures_end_shipwreck_1.mts",
	},
	construct_nodes = {"vlf_chests:ender_chest_small","vlf_chests:ender_chest","vlf_brewing:stand_000","vlf_chests:violet_shulker_box_small"},
	after_place = function(pos,def,pr)
		local fr = minetest.find_node_near(pos,def.sidelen,{"vlf_itemframes:frame"})
		if fr then
			if vlf_itemframes then
				vlf_itemframes.update_entity(fr)
			end
		end
		return spawn_shulkers(pos,def,pr)
	end,
	loot = {
		[ "vlf_itemframes:frame" ] ={{
			stacks_min = 1,
			stacks_max = 1,
			items = {
				{ itemstring = "vlf_armor:elytra", weight = 100 },
			},
		}},
		[ "vlf_chests:chest_small" ] ={{
			stacks_min = 2,
			stacks_max = 6,
			items = {
				{ itemstring = "vlf_mobitems:bone", weight = 20, amount_min = 4, amount_max=6 },
				{ itemstring = "vlf_farming:beetroot_seeds", weight = 16, amount_min = 1, amount_max=10 },
				{ itemstring = "vlf_core:gold_ingot", weight = 15, amount_min = 2, amount_max = 7 },
				{ itemstring = "vlf_bamboo:bamboo", weight = 15, amount_min = 1, amount_max=3 },
				{ itemstring = "vlf_core:iron_ingot", weight = 15, amount_min = 4, amount_max = 8 },
				{ itemstring = "vlf_core:diamond", weight = 3, amount_min = 2, amount_max = 7 },
				{ itemstring = "vlf_mobitems:saddle", weight = 3, },
				{ itemstring = "vlf_core:emerald", weight = 2, amount_min = 1, amount_max = 3 },
				{ itemstring = "vlf_armor:spire", amount_min = 1, amount_max = 1 },
				{ itemstring = "vlf_books:book", weight = 1, func = function(stack, pr)
					vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
				end },
				{ itemstring = "vlf_tools:pick_iron_enchanted", weight = 3,func = function(stack, pr) vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlf_tools:shovel_iron_enchanted", weight = 3,func = function(stack, pr) vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlf_tools:sword_iron_enchanted", weight = 3,func = function(stack, pr) vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlf_armor:helmet_iron_enchanted", weight = 3,func = function(stack, pr) vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlf_armor:chestplate_iron_enchanted", weight = 3,func = function(stack, pr) vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlf_armor:leggings_iron_enchanted", weight = 3,func = function(stack, pr) vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlf_armor:boots_iron_enchanted", weight = 3,func = function(stack, pr) vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlf_tools:pick_diamond_enchanted", weight = 3,func = function(stack, pr) vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlf_tools:shovel_diamond_enchanted", weight = 3,func = function(stack, pr) vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlf_tools:sword_diamond_enchanted", weight = 3,func = function(stack, pr) vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlf_armor:helmet_diamond_enchanted", weight = 3,func = function(stack, pr) vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlf_armor:chestplate_diamond_enchanted", weight = 3,func = function(stack, pr) vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlf_armor:leggings_diamond_enchanted", weight = 3,func = function(stack, pr) vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlf_armor:boots_diamond_enchanted", weight = 3,func = function(stack, pr) vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlf_core:emerald", weight = 2, amount_min = 1, amount_max = 3 },
				{ itemstring = "vlf_mobitems:iron_horse_armor", weight = 1, },
				{ itemstring = "vlf_mobitems:gold_horse_armor", weight = 1, },
				{ itemstring = "vlf_mobitems:diamond_horse_armor", weight = 1, },
				{ itemstring = "vlf_core:apple_gold_enchanted", weight = 2, },
			}
		}}
	}
})

vlf_structures.register_structure("end_boat",{
	place_on = {"vlf_end:end_stone"},
	flags = "place_center_x, place_center_z, all_floors",
	y_offset = function(pr) return pr:next(15,30) end,
	chunk_probability = 25,
	--y_max = vlf_vars.mg_end_max,
	--y_min = vlf_vars.mg_end_min -100,
	biomes = { "End", "EndHighlands", "EndMidlands", "EndBarrens", "EndSmallIslands" },
	sidelen = 20,
	filenames = {
		modpath.."/schematics/vlf_structures_end_boat.mts",
	},
	after_place = spawn_shulkers,
	construct_nodes = {"vlf_chests:ender_chest_small","vlf_chests:ender_chest","vlf_brewing:stand_000","vlf_chests:violet_shulker_box_small"},
	loot = {
		[ "vlf_chests:chest_small" ] ={{
			stacks_min = 2,
			stacks_max = 6,
			items = {
				{ itemstring = "vlf_mobitems:bone", weight = 20, amount_min = 4, amount_max=6 },
				{ itemstring = "vlf_farming:beetroot_seeds", weight = 16, amount_min = 1, amount_max=10 },
				{ itemstring = "vlf_core:gold_ingot", weight = 15, amount_min = 2, amount_max = 7 },
				{ itemstring = "vlf_core:iron_ingot", weight = 15, amount_min = 4, amount_max = 8 },
				{ itemstring = "vlf_core:diamond", weight = 3, amount_min = 2, amount_max = 7 },
				{ itemstring = "vlf_mobitems:saddle", weight = 3, },
				{ itemstring = "vlf_core:emerald", weight = 2, amount_min = 1, amount_max = 3 },
				{ itemstring = "vlf_tools:pick_iron_enchanted", weight = 3,func = function(stack, pr) vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlf_tools:shovel_iron_enchanted", weight = 3,func = function(stack, pr) vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlf_tools:sword_iron_enchanted", weight = 3,func = function(stack, pr) vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlf_armor:helmet_iron_enchanted", weight = 3,func = function(stack, pr) vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlf_armor:chestplate_iron_enchanted", weight = 3,func = function(stack, pr) vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlf_armor:leggings_iron_enchanted", weight = 3,func = function(stack, pr) vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlf_armor:boots_iron_enchanted", weight = 3,func = function(stack, pr) vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlf_tools:pick_diamond_enchanted", weight = 3,func = function(stack, pr) vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlf_tools:shovel_diamond_enchanted", weight = 3,func = function(stack, pr) vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlf_armor:helmet_diamond_enchanted", weight = 3,func = function(stack, pr) vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlf_armor:leggings_diamond_enchanted", weight = 3,func = function(stack, pr) vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlf_armor:boots_diamond_enchanted", weight = 3,func = function(stack, pr) vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlf_core:emerald", weight = 2, amount_min = 1, amount_max = 3 },
				{ itemstring = "vlf_mobitems:iron_horse_armor", weight = 1, },
				{ itemstring = "vlf_mobitems:gold_horse_armor", weight = 1, },
				{ itemstring = "vlf_core:apple_gold_enchanted", weight = 2, },
			}
		}}
	}
})

vlf_structures.register_structure("small_end_city",{
	place_on = {"vlf_end:end_stone"},
	fill_ratio = 0.01,
	flags = "place_center_x, place_center_z, all_floors",
	y_offset = 0,
	chunk_probability = 900,
	biomes = { "End", "EndHighlands", "EndMidlands", "EndBarrens", "EndSmallIslands" },
	sidelen = 20,
	filenames = {
		modpath.."/schematics/vlf_structures_end_city_simple.mts",
	},
	after_place = spawn_shulkers,
	construct_nodes = {"vlf_chests:ender_chest_small","vlf_chests:ender_chest","vlf_brewing:stand_000","vlf_chests:violet_shulker_box_small"},
	loot = {
		[ "vlf_chests:chest_small" ] ={{
			stacks_min = 2,
			stacks_max = 6,
			items = {
				{ itemstring = "vlf_mobitems:bone", weight = 20, amount_min = 4, amount_max=6 },
				{ itemstring = "vlf_farming:beetroot_seeds", weight = 16, amount_min = 1, amount_max=10 },
				{ itemstring = "vlf_core:gold_ingot", weight = 15, amount_min = 2, amount_max = 7 },
				{ itemstring = "vlf_core:iron_ingot", weight = 15, amount_min = 4, amount_max = 8 },
				{ itemstring = "vlf_core:diamond", weight = 3, amount_min = 2, amount_max = 7 },
				{ itemstring = "vlf_mobitems:saddle", weight = 3, },
				{ itemstring = "vlf_core:emerald", weight = 2, amount_min = 1, amount_max = 3 },
				{ itemstring = "vlf_tools:pick_iron_enchanted", weight = 3,func = function(stack, pr) vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlf_tools:shovel_iron_enchanted", weight = 3,func = function(stack, pr) vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlf_tools:sword_iron_enchanted", weight = 3,func = function(stack, pr) vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlf_armor:helmet_iron_enchanted", weight = 3,func = function(stack, pr) vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlf_armor:chestplate_iron_enchanted", weight = 3,func = function(stack, pr) vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlf_armor:leggings_iron_enchanted", weight = 3,func = function(stack, pr) vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlf_armor:boots_iron_enchanted", weight = 3,func = function(stack, pr) vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlf_tools:pick_diamond_enchanted", weight = 3,func = function(stack, pr) vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlf_tools:shovel_diamond_enchanted", weight = 3,func = function(stack, pr) vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlf_armor:helmet_diamond_enchanted", weight = 3,func = function(stack, pr) vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlf_armor:leggings_diamond_enchanted", weight = 3,func = function(stack, pr) vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlf_armor:boots_diamond_enchanted", weight = 3,func = function(stack, pr) vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlf_core:emerald", weight = 2, amount_min = 1, amount_max = 3 },
				{ itemstring = "vlf_mobitems:iron_horse_armor", weight = 1, },
				{ itemstring = "vlf_mobitems:gold_horse_armor", weight = 1, },
				{ itemstring = "vlf_core:apple_gold_enchanted", weight = 2, },
			}
		}}
	}
})
