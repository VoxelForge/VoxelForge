mcl_trees = {}
local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)

mcl_trees.woods = {
	["oak"] = {
		sign_color="#ECA870",
		tree_schems= {
			{ file=modpath.."/schematics/mcl_core_oak_balloon.mts",width=7,height=11 },
			{ file=modpath.."/schematics/mcl_core_oak_large_1.mts",width=7,height=11 },
			{ file=modpath.."/schematics/mcl_core_oak_large_2.mts",width=7,height=11 },
			{ file=modpath.."/schematics/mcl_core_oak_large_3.mts",width=7,height=11 },
			{ file=modpath.."/schematics/mcl_core_oak_large_4.mts",width=7,height=11 },
			{ file=modpath.."/schematics/mcl_core_oak_swamp.mts",width=5,height=5 },
			{ file=modpath.."/schematics/mcl_core_oak_v6.mts",width=3,height=5 },
			{ file=modpath.."/schematics/mcl_core_oak_classic_bee_nest.mts",width=3,height=5 },
			{ file=modpath.."/schematics/mcl_core_oak_classic.mts",width=3,height=5 },
		}
	} ,
	["dark_oak"]={
		sign_color="#5F4021",
		tree_schems = {
			{ file=modpath.."/schematics/mcl_core_dark_oak.mts",width=4,height=7 },
		}
	},
	["jungle"]={
		sign_color="#9f4112",
		tree_schems = {
			{ file=modpath.."/schematics/mcl_core_jungle_tree_2.mts",width=5,height=8 },
			{ file=modpath.."/schematics/mcl_core_jungle_tree_3.mts",width=5,height=8 },
			{ file=modpath.."/schematics/mcl_core_jungle_tree_4.mts",width=5,height=8 },
			{ file=modpath.."/schematics/mcl_core_jungle_tree.mts",width=5,height=8 },
			{ file=modpath.."/schematics/mcl_core_jungle_tree_huge_1.mts",width=8,height=8 },
			{ file=modpath.."/schematics/mcl_core_jungle_tree_huge_2.mts",width=8,height=8 },
			{ file=modpath.."/schematics/mcl_core_jungle_tree_huge_3.mts",width=8,height=8 },
			{ file=modpath.."/schematics/mcl_core_jungle_tree_huge_4.mts",width=8,height=8 },
		},
	},
	["spruce"]={
		sign_color="#7f5f37",
		tree_schems = {
			{ file=modpath.."/schematics/mcl_core_spruce_1.mts",width=5,height=11 },
			{ file=modpath.."/schematics/mcl_core_spruce_2.mts",width=5,height=11 },
			{ file=modpath.."/schematics/mcl_core_spruce_3.mts",width=5,height=11 },
			{ file=modpath.."/schematics/mcl_core_spruce_4.mts",width=5,height=11 },
			{ file=modpath.."/schematics/mcl_core_spruce_5.mts",width=5,height=11 },
			{ file=modpath.."/schematics/mcl_core_spruce_lollipop.mts",width=5,height=11 },
			{ file=modpath.."/schematics/mcl_core_spruce_matchstick.mts",width=6,height=20 },
			{ file=modpath.."/schematics/mcl_core_spruce_tall.mts",width=6,height=20 },
			{ file=modpath.."/schematics/mcl_core_spruce_huge_1.mts",width=6,height=20 },
			{ file=modpath.."/schematics/mcl_core_spruce_huge_2.mts",width=6,height=20 },
			{ file=modpath.."/schematics/mcl_core_spruce_huge_3.mts",width=6,height=20 },
			{ file=modpath.."/schematics/mcl_core_spruce_huge_4.mts",width=6,height=20 },
			{ file=modpath.."/schematics/mcl_core_spruce_huge_up_1.mts",width=6,height=20 },
			{ file=modpath.."/schematics/mcl_core_spruce_huge_up_2.mts",width=6,height=20 },
			{ file=modpath.."/schematics/mcl_core_spruce_huge_up_3.mts",width=6,height=20 },
		}
	},
	["acacia"]={
		sign_color="#ea7479",
		tree_schems ={
	 		{ file=modpath.."/schematics/mcl_core_acacia_1.mts",width=7,height=8 },
			{ file=modpath.."/schematics/mcl_core_acacia_2.mts",width=7,height=8 },
			{ file=modpath.."/schematics/mcl_core_acacia_3.mts",width=7,height=8 },
			{ file=modpath.."/schematics/mcl_core_acacia_4.mts",width=7,height=8 },
			{ file=modpath.."/schematics/mcl_core_acacia_5.mts",width=7,height=8 },
			{ file=modpath.."/schematics/mcl_core_acacia_6.mts",width=7,height=8 },
			{ file=modpath.."/schematics/mcl_core_acacia_7.mts",width=7,height=8 },
			{ file=modpath.."/schematics/mcl_core_acacia_weirdo.mts",width=7,height=8 },
		}
	},
	["birch"]={
		sign_color="#ffdba7",
		tree_schems = {
			{ file=modpath.."/schematics/mcl_core_birch_bee_nest.mts",width=3,height=6 },
			{ file=modpath.."/schematics/mcl_core_birch.mts",width=3,height=6 },
			{ file=modpath.."/schematics/mcl_core_birch_tall.mts",width=3,height=6 },
		},
	},
	["mangrove"]={
		sign_color="#b8693d",
		sapling=false,
		tree_schems = {
			{ file=modpath.."/schematics/mcl_mangrove_tree_1.mts",width=3,height=6 },
			{ file=modpath.."/schematics/mcl_mangrove_tree_2.mts",width=3,height=6 },
			{ file=modpath.."/schematics/mcl_mangrove_tree_3.mts",width=5,height=9 },
			{ file=modpath.."/schematics/mcl_mangrove_tree_4.mts",width=5,height=9 },
			{ file=modpath.."/schematics/mcl_mangrove_tree_5.mts",width=5,height=12 },
		}
	},
	["crimson"]={
		sign_color="#c35f51",
		boat=false,
		sapling=false,
		leaves=false
	},
	["warped"]={
		sign_color="#9f7dcf",
		boat=false,
		sapling=false,
		leaves=false
	},
}

dofile(modpath.."/functions.lua")
dofile(modpath.."/api.lua")
dofile(modpath.."/mangrove.lua")
dofile(modpath.."/items.lua")
dofile(modpath.."/recipes.lua")
dofile(modpath.."/abms.lua")

for w,v in pairs(mcl_trees.woods) do
	mcl_trees.register_wood(w,v)
end

dofile(modpath.."/aliases.lua")

minetest.register_node("mcl_trees:ladder", {
	description = S("Ladder"),
	_doc_items_longdesc = S("A piece of ladder which allows you to climb vertically. Ladders can only be placed on the side of solid blocks and not on glass, leaves, ice, slabs, glowstone, nor sea lanterns."),
	drawtype = "signlike",
	is_ground_content = false,
	tiles = {"mcl_trees_ladder.png"},
	inventory_image = "mcl_trees_ladder.png",
	wield_image = "mcl_trees_ladder.png",
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "wallmounted",
	walkable = true,
	climbable = true,
	node_box = {
		type = "wallmounted",
		wall_side = { -0.5, -0.5, -0.5, -7/16, 0.5, 0.5 },
	},
	selection_box = {
		type = "wallmounted",
		wall_side = { -0.5, -0.5, -0.5, -7/16, 0.5, 0.5 },
	},
	groups = {handy=1,axey=1, attached_node=1, deco_block=1, dig_by_piston=1, no_ladders = 1},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	node_placement_prediction = "",
	-- Restrict placement of ladders
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then return itemstack end
		local under = pointed_thing.under
		local node = minetest.get_node(under)
		local def = minetest.registered_nodes[node.name]
		if not def then return itemstack end

		if def.on_rightclick then
			return mcl_util.call_on_rightclick(itemstack, player, pointed_thing)
		end

		local above = pointed_thing.above
		local groups = def.groups

		if under.y ~= above.y then return itemstack end	-- Ladders may not be placed on ceiling or floor

		-- Don't allow to place the ladder at particular nodes
		if (groups and ((groups.glass or groups.leaves or groups.slab) or groups.no_ladders )) then
			return itemstack
		end

		local idef = itemstack:get_definition()
		local itemstack, success = minetest.item_place_node(itemstack, placer, pointed_thing)

		if success and idef.sounds and idef.sounds.place then
			minetest.sound_play(idef.sounds.place, {pos=above, gain=1}, true)
		end
		return itemstack
	end,

	_mcl_blast_resistance = 0.4,
	_mcl_hardness = 0.4,
	on_rotate = mcl_trees.rotate_climbable,
})
