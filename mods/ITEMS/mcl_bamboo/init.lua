local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
mcl_bamboo = {}

mcl_trees.register_wood("bamboo",{
	sign_color="#FCE6BC",
	sapling = false,
	leaves = false,
	tree_schems = {
		{ file=modpath.."/schematics/mcl_bamboo_tree_1.mts",width=3,height=6 },
		{ file=modpath.."/schematics/mcl_bamboo_tree_2.mts",width=3,height=6 },
		{ file=modpath.."/schematics/mcl_bamboo_tree_3.mts",width=5,height=9 },
		{ file=modpath.."/schematics/mcl_bamboo_tree_4.mts",width=5,height=9 },
		{ file=modpath.."/schematics/mcl_bamboo_tree_5.mts",width=5,height=12 },
	},
	tree = { tiles = {"mcl_bamboo_bamboo_bottom.png", "mcl_bamboo_bamboo_bottom.png","mcl_bamboo_bamboo_block.png" }},
	stripped = { tiles = {"mcl_bamboo_bamboo_bottom_stripped.png", "mcl_bamboo_bamboo_bottom_stripped.png","mcl_bamboo_bamboo_block_stripped.png" }},
	bark = { tiles = {"mcl_bamboo_bamboo_block.png"}},
	planks = { tiles = {"mcl_bamboo_bamboo_plank.png"}},
	stripped_bark = { tiles = {"mcl_bamboo_bamboo_block_stripped.png"} },
	fence = { tiles = { "mcl_bamboo_fence_bamboo.png" },},
	fence_gate = { tiles = { "mcl_bamboo_fence_gate_bamboo.png" }, },
	door = {
		inventory_image = "mcl_bamboo_door_wield.png",
		tiles_bottom = {"mcl_bamboo_door_bottom.png","mcl_bamboo_door_bottom.png"},
		tiles_top = {"mcl_bamboo_door_top.png","mcl_bamboo_door_bottom.png"},
	},
	trapdoor = {
		tile_front = "mcl_bamboo_trapdoor_side.png",
		tile_side = "mcl_bamboo_trapdoor_side.png",
		wield_image = "mcl_bamboo_trapdoor_side.png",
	},
})

dofile(modpath .. "/nodes.lua")
dofile(modpath .. "/recipes.lua")
