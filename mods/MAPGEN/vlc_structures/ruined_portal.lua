local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

local function get_replacements(b,c,pr)
	local r = {}
	if not b then return r end
	for k,v in pairs(b) do
		if pr:next(1,100) < c then table.insert(r,v) end
	end
	return r
end

local def = {
	place_on = {"group:grass_block","group:dirt","vlc_core:dirt_with_grass","group:grass_block","group:sand","group:grass_block_snow","vlc_core:snow"},
	fill_ratio = 0.006,
	flags = "place_center_x, place_center_z, all_floors",
	solid_ground = true,
	make_foundation = true,
	chunk_probability = 800,
	y_max = vlc_vars.mg_overworld_max,
	y_min = 1,
	sidelen = 10,
	y_offset = -5,
	filenames = {
		vlc_structures.schempath.."/schems/vlc_structures_ruined_portal_1.mts",
		vlc_structures.schempath.."/schems/vlc_structures_ruined_portal_2.mts",
		vlc_structures.schempath.."/schems/vlc_structures_ruined_portal_3.mts",
		vlc_structures.schempath.."/schems/vlc_structures_ruined_portal_4.mts",
		vlc_structures.schempath.."/schems/vlc_structures_ruined_portal_5.mts",
		vlc_structures.schempath.."/schems/vlc_structures_ruined_portal_6.mts",
		vlc_structures.schempath.."/schems/vlc_structures_ruined_portal_99.mts",
	},
	after_place = function(pos, def, pr)
		local p1 = vector.offset(pos,-9, -1, -9)
		local p2 = vector.offset(pos,9, 16 ,9)
		local gold = minetest.find_nodes_in_area(p1,p2,{"vlc_core:goldblock"})
		local lava = minetest.find_nodes_in_area(p1,p2,{"vlc_core:lava_source"})
		local rack = minetest.find_nodes_in_area(p1,p2,{"vlc_nether:netherrack"})
		local brick = minetest.find_nodes_in_area(p1,p2,{"vlc_core:stonebrick"})
		local obby = minetest.find_nodes_in_area(p1,p2,{"vlc_core:obsidian"})
		minetest.bulk_set_node(get_replacements(gold,30,pr),{name="air"})
		minetest.bulk_set_node(get_replacements(lava,20,pr),{name="vlc_nether:magma"})
		minetest.bulk_set_node(get_replacements(rack,7,pr),{name="vlc_nether:magma"})
		minetest.bulk_set_node(get_replacements(obby,30,pr),{name="vlc_core:crying_obsidian"})
		minetest.bulk_set_node(get_replacements(obby,10,pr),{name="air"})
		minetest.bulk_set_node(get_replacements(brick,50,pr),{name="vlc_core:stonebrickcracked"})
		brick = minetest.find_nodes_in_area(p1,p2,{"vlc_core:stonebrick"})
		minetest.bulk_set_node(get_replacements(brick,50,pr),{name="vlc_core:stonebrickmossy"})
	end,
	loot = {
		["vlc_chests:chest_small" ] ={{
			stacks_min = 4,
			stacks_max = 8,
			items = {
				{ itemstring = "vlc_core:iron_nugget", weight = 40, amount_min = 9, amount_max = 18 },
				{ itemstring = "vlc_core:flint", weight = 40, amount_min = 1, amount_max=4 },
				{ itemstring = "vlc_core:obsidian", weight = 40, amount_min = 1, amount_max=2 },
				{ itemstring = "vlc_fire:fire_charge", weight = 40, amount_min = 1, amount_max = 1 },
				{ itemstring = "vlc_fire:flint_and_steel", weight = 40, amount_min = 1, amount_max = 1 },
				{ itemstring = "vlc_core:gold_nugget", weight = 15, amount_min = 4, amount_max = 24 },
				{ itemstring = "vlc_core:apple_gold", weight = 15, },

				{ itemstring = "vlc_tools:axe_gold", weight = 15, func = function(stack, pr)
					vlc_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
				end },
				{ itemstring = "vlc_farming:hoe_gold", weight = 15, func = function(stack, pr)
					vlc_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
				end },
				{ itemstring = "vlc_tools:pick_gold", weight = 15, func = function(stack, pr)
					vlc_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
				end },
				{ itemstring = "vlc_tools:shovel_gold", weight = 15, func = function(stack, pr)
					vlc_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
				end },
				{ itemstring = "vlc_tools:sword_gold", weight = 15, func = function(stack, pr)
					vlc_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
				end },

				{ itemstring = "vlc_armor:helmet_gold", weight = 15, func = function(stack, pr)
					vlc_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
				end },
				{ itemstring = "vlc_armor:chestplate_gold", weight = 15, func = function(stack, pr)
					vlc_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
				end },
				{ itemstring = "vlc_armor:leggings_gold", weight = 15, func = function(stack, pr)
					vlc_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
				end },
				{ itemstring = "vlc_armor:boots_gold", weight = 15, func = function(stack, pr)
					vlc_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
				end },

				{ itemstring = "vlc_potions:speckled_melon", weight = 5, amount_min = 4, amount_max = 12 },
				{ itemstring = "vlc_farming:carrot_item_gold", weight = 5, amount_min = 4, amount_max = 12 },

				{ itemstring = "vlc_core:gold_ingot", weight = 5, amount_min = 2, amount_max = 8 },
				{ itemstring = "vlc_clock:clock", weight = 5, },
				{ itemstring = "vlc_mobitems:gold_horse_armor", weight = 1, },
				{ itemstring = "vlc_core:goldblock", weight = 1, amount_min = 1, amount_max = 2 },
				{ itemstring = "vlc_bells:bell", weight = 1, },
				{ itemstring = "vlc_core:apple_gold_enchanted", weight = 1, },
			}
		}}
	}
}
vlc_structures.register_structure("ruined_portal_overworld",def)
vlc_structures.register_structure("ruined_portal_nether",table.merge(def,{
	y_min = vlc_vars.mg_lava_nether_max +10,
	y_max = vlc_vars.mg_nether_max - 15,
	place_on = {"vlc_nether:netherrack","group:soul_block","vlc_blackstone:basalt,vlc_blackstone:blackstone","vlc_crimson:crimson_nylium","vlc_crimson:warped_nylium"}
}))
