local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

local function get_replacements(b,c,pr)
	local r = {}
	if not b then return r end
	for _, v in pairs(b) do
		if pr:next(1,100) < c then table.insert(r,v) end
	end
	return r
end

local def = {
	place_on = {"group:grass_block","group:dirt","vlf_core:dirt_with_grass","group:grass_block","group:sand","group:grass_block_snow","vlf_core:snow"},
	flags = "place_center_x, place_center_z, all_floors",
	solid_ground = true,
	make_foundation = true,
	chunk_probability = 20,
	y_max = vlf_vars.mg_overworld_max,
	y_min = 1,
	sidelen = 10,
	y_offset = -5,
	filenames = {
		modpath.."/schematics/vlf_structures_ruined_portal_1.mts",
		modpath.."/schematics/vlf_structures_ruined_portal_2.mts",
		modpath.."/schematics/vlf_structures_ruined_portal_3.mts",
		modpath.."/schematics/vlf_structures_ruined_portal_4.mts",
		modpath.."/schematics/vlf_structures_ruined_portal_5.mts",
		modpath.."/schematics/vlf_structures_ruined_portal_6.mts",
		modpath.."/schematics/vlf_structures_ruined_portal_99.mts",
	},
	after_place = function(pos, _, pr)
		local p1 = vector.offset(pos,-9, -1, -9)
		local p2 = vector.offset(pos,9, 16 ,9)
		local gold = minetest.find_nodes_in_area(p1,p2,{"vlf_core:goldblock"})
		local lava = minetest.find_nodes_in_area(p1,p2,{"vlf_core:lava_source"})
		local rack = minetest.find_nodes_in_area(p1,p2,{"vlf_nether:netherrack"})
		local brick = minetest.find_nodes_in_area(p1,p2,{"vlf_core:stonebrick"})
		local obby = minetest.find_nodes_in_area(p1,p2,{"vlf_core:obsidian"})
		vlf_util.bulk_swap_node(get_replacements(gold,30,pr),{name="air"})
		vlf_util.bulk_swap_node(get_replacements(lava,20,pr),{name="vlf_nether:magma"})
		vlf_util.bulk_swap_node(get_replacements(rack,7,pr),{name="vlf_nether:magma"})
		vlf_util.bulk_swap_node(get_replacements(obby,30,pr),{name="vlf_core:crying_obsidian"})
		vlf_util.bulk_swap_node(get_replacements(obby,10,pr),{name="air"})
		vlf_util.bulk_swap_node(get_replacements(brick,50,pr),{name="vlf_core:stonebrickcracked"})
		brick = minetest.find_nodes_in_area(p1,p2,{"vlf_core:stonebrick"})
		vlf_util.bulk_swap_node(get_replacements(brick,50,pr),{name="vlf_core:stonebrickmossy"})
	end,
	loot = {
		["vlf_chests:chest_small" ] ={{
			stacks_min = 4,
			stacks_max = 8,
			items = {
				{ itemstring = "vlf_core:iron_nugget", weight = 40, amount_min = 9, amount_max = 18 },
				{ itemstring = "vlf_core:flint", weight = 40, amount_min = 1, amount_max=4 },
				{ itemstring = "vlf_core:obsidian", weight = 40, amount_min = 1, amount_max=2 },
				{ itemstring = "vlf_fire:fire_charge", weight = 40, amount_min = 1, amount_max = 1 },
				{ itemstring = "vlf_fire:flint_and_steel", weight = 40, amount_min = 1, amount_max = 1 },
				{ itemstring = "vlf_core:gold_nugget", weight = 15, amount_min = 4, amount_max = 24 },
				{ itemstring = "vlf_core:apple_gold", weight = 15, },

				{ itemstring = "vlf_tools:axe_gold", weight = 15, func = function(stack, pr)
					vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
				end },
				{ itemstring = "vlf_farming:hoe_gold", weight = 15, func = function(stack, pr)
					vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
				end },
				{ itemstring = "vlf_tools:pick_gold", weight = 15, func = function(stack, pr)
					vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
				end },
				{ itemstring = "vlf_tools:shovel_gold", weight = 15, func = function(stack, pr)
					vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
				end },
				{ itemstring = "vlf_tools:sword_gold", weight = 15, func = function(stack, pr)
					vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
				end },

				{ itemstring = "vlf_armor:helmet_gold", weight = 15, func = function(stack, pr)
					vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
				end },
				{ itemstring = "vlf_armor:chestplate_gold", weight = 15, func = function(stack, pr)
					vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
				end },
				{ itemstring = "vlf_armor:leggings_gold", weight = 15, func = function(stack, pr)
					vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
				end },
				{ itemstring = "vlf_armor:boots_gold", weight = 15, func = function(stack, pr)
					vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
				end },

				{ itemstring = "vlf_potions:speckled_melon", weight = 5, amount_min = 4, amount_max = 12 },
				{ itemstring = "vlf_farming:carrot_item_gold", weight = 5, amount_min = 4, amount_max = 12 },

				{ itemstring = "vlf_core:gold_ingot", weight = 5, amount_min = 2, amount_max = 8 },
				{ itemstring = "vlf_clock:clock", weight = 5, },
				{ itemstring = "vlf_mobitems:gold_horse_armor", weight = 1, },
				{ itemstring = "vlf_core:goldblock", weight = 1, amount_min = 1, amount_max = 2 },
				{ itemstring = "vlf_bells:bell", weight = 1, },
				{ itemstring = "vlf_core:apple_gold_enchanted", weight = 1, },
			}
		}}
	}
}
vlf_structures.register_structure("ruined_portal_overworld",def)
vlf_structures.register_structure("ruined_portal_nether",table.merge(def,{
	y_min = vlf_vars.mg_lava_nether_max +10,
	y_max = vlf_vars.mg_nether_max - 15,
	place_on = {"vlf_nether:netherrack","group:soul_block","vlf_blackstone:basalt,vlf_blackstone:blackstone","vlf_crimson:crimson_nylium","vlf_crimson:warped_nylium"}
}))
