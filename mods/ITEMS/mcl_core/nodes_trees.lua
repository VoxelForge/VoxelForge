local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

mcl_trees.register_wood("oak",{
	sign_color="#ECA870",
	tree_schems= {
		{ file = modpath.."/schematics/mcl_core_oak_balloon.mts", width = 5, height = 7 },
		{ file = modpath.."/schematics/mcl_core_oak_large_1.mts", width = 7, height = 13 },
		{ file = modpath.."/schematics/mcl_core_oak_large_2.mts", width = 9, height = 14 },
		{ file = modpath.."/schematics/mcl_core_oak_large_3.mts", width = 7, height = 14 },
		{ file = modpath.."/schematics/mcl_core_oak_large_4.mts", width = 9, height = 13 },
		{ file = modpath.."/schematics/mcl_core_oak_swamp.mts", width = 7, height = 8 },
		{ file = modpath.."/schematics/mcl_core_oak_v6.mts", width = 5, height = 7 },
		{ file = modpath.."/schematics/mcl_core_oak_classic_bee_nest.mts", width = 5, height = 8 },
		{ file = modpath.."/schematics/mcl_core_oak_classic.mts", width = 5, height = 8 },
	},
	tree = { tiles = {"default_tree_top.png", "default_tree_top.png","default_tree.png"} },
	leaves = { tiles = { "default_leaves.png" } },
	drop_apples = true,
	wood = { tiles = {"default_wood.png"}},
	sapling = {
		tiles = {"default_sapling.png"},
		inventory_image = "default_sapling.png",
		wield_image = "default_sapling.png",
	},
	door = {
		inventory_image = "doors_item_wood.png",
		tiles_bottom = {"mcl_doors_door_wood_lower.png", "mcl_doors_door_wood_side_lower.png"},
		tiles_top = {"mcl_doors_door_wood_upper.png", "mcl_doors_door_wood_side_upper.png"}
	},
	trapdoor = {
		tile_front = "doors_trapdoor.png",
		tile_side = "doors_trapdoor_side.png",
		wield_image = "doors_trapdoor.png",
	},
	potted_sapling = {
		image = "default_sapling.png",
	},
})

mcl_trees.register_wood("dark_oak",{
	sign_color="#5F4021",
	tree_schems = {
		{ file = modpath.."/schematics/mcl_core_dark_oak.mts", width = 8, height = 11 },
	},
	tree = { tiles = {"mcl_core_log_big_oak_top.png", "mcl_core_log_big_oak_top.png","mcl_core_log_big_oak.png"} },
	leaves = { tiles = { "mcl_core_leaves_big_oak.png" } },
	drop_apples = true,
	wood = { tiles = {"mcl_core_planks_big_oak.png"}},
	sapling = {
		tiles = {"mcl_core_sapling_big_oak.png"},
		inventory_image = "mcl_core_sapling_big_oak.png",
		wield_image = "mcl_core_sapling_big_oak.png",
	},
	fence = {
		tiles = { "mcl_fences_fence_big_oak.png" },
	},
	fence_gate = {
		tiles = { "mcl_fences_fence_gate_big_oak.png" },
	},
	potted_sapling = {
		image = "mcl_core_sapling_big_oak.png",
	},
})

mcl_trees.register_wood("jungle",{
	sign_color="#9f4112",
	tree_schems = {
		{ file = modpath.."/schematics/mcl_core_jungle_tree.mts", width = 5, height = 15 },
		{ file = modpath.."/schematics/mcl_core_jungle_tree_2.mts", width = 7, height = 15 },
		{ file = modpath.."/schematics/mcl_core_jungle_tree_3.mts", width = 7, height = 15 },
		{ file = modpath.."/schematics/mcl_core_jungle_tree_4.mts", width = 7, height = 15 },
		{ file = modpath.."/schematics/mcl_core_jungle_tree_huge_1.mts", width = 14, height = 26 },
		{ file = modpath.."/schematics/mcl_core_jungle_tree_huge_2.mts", width = 14, height = 30 },
		{ file = modpath.."/schematics/mcl_core_jungle_tree_huge_3.mts", width = 14, height = 26 },
		{ file = modpath.."/schematics/mcl_core_jungle_tree_huge_4.mts", width = 14, height = 30 },
	},
	tree = { tiles = {"default_jungletree_top.png", "default_jungletree_top.png","default_jungletree.png"} },
	leaves = { tiles = { "default_jungleleaves.png" } },
	sapling_chances = {40, 26, 32, 24, 10},
	wood = { tiles = {"default_junglewood.png"}},
	sapling = {
		tiles = {"default_junglesapling.png"},
		inventory_image = "default_junglesapling.png",
		wield_image = "default_junglesapling.png",
	},
	potted_sapling = {
		image = "default_junglesapling.png",
	},
})

mcl_trees.register_wood("spruce",{
	sign_color="#7f5f37",
	tree_schems = {
		{ file = modpath.."/schematics/mcl_core_spruce_1.mts", width = 7, height = 12 },
		{ file = modpath.."/schematics/mcl_core_spruce_2.mts", width = 7, height = 13 },
		{ file = modpath.."/schematics/mcl_core_spruce_3.mts", width = 7, height = 14 },
		{ file = modpath.."/schematics/mcl_core_spruce_4.mts", width = 7, height = 12 },
		{ file = modpath.."/schematics/mcl_core_spruce_5.mts", width = 5, height = 9 },
		{ file = modpath.."/schematics/mcl_core_spruce_lollipop.mts", width = 5, height = 7 },
		{ file = modpath.."/schematics/mcl_core_spruce_matchstick.mts", width = 3, height = 16 },
		{ file = modpath.."/schematics/mcl_core_spruce_tall.mts", width = 7, height = 15 },
		{ file = modpath.."/schematics/mcl_core_spruce_huge_1.mts", width = 10, height = 25 },
		{ file = modpath.."/schematics/mcl_core_spruce_huge_2.mts", width = 10, height = 19 },
		{ file = modpath.."/schematics/mcl_core_spruce_huge_3.mts", width = 10, height = 26 },
		{ file = modpath.."/schematics/mcl_core_spruce_huge_4.mts", width = 10, height = 23 },
		{ file = modpath.."/schematics/mcl_core_spruce_huge_up_1.mts", width = 8, height = 24 },
		{ file = modpath.."/schematics/mcl_core_spruce_huge_up_2.mts", width = 10, height = 24 },
		{ file = modpath.."/schematics/mcl_core_spruce_huge_up_3.mts", width = 8, height = 23 },
	},
})

mcl_trees.register_wood("acacia",{
	sign_color="#ea7479",
	tree_schems ={
		{ file = modpath.."/schematics/mcl_core_acacia_1.mts", width = 11, height = 9 },
		{ file = modpath.."/schematics/mcl_core_acacia_2.mts", width = 9, height = 10 },
		{ file = modpath.."/schematics/mcl_core_acacia_3.mts", width = 9, height = 8 },
		{ file = modpath.."/schematics/mcl_core_acacia_4.mts", width = 7, height = 9 },
		{ file = modpath.."/schematics/mcl_core_acacia_5.mts", width = 11, height = 10 },
		{ file = modpath.."/schematics/mcl_core_acacia_6.mts", width = 7, height = 11 },
		{ file = modpath.."/schematics/mcl_core_acacia_7.mts", width = 7, height = 12 },
		{ file = modpath.."/schematics/mcl_core_acacia_weirdo.mts", width = 7, height = 8 },
	},
	tree = { tiles = {"default_acacia_tree_top.png", "default_acacia_tree_top.png","default_acacia_tree.png"} },
	leaves = { tiles = { "default_acacia_leaves.png" } },
	wood = { tiles = {"default_acacia_wood.png"}},
	sapling = {
		tiles = {"default_acacia_sapling.png"},
		inventory_image = "default_acacia_sapling.png",
		wield_image = "default_acacia_sapling.png",
	},
	potted_sapling = {
		image = "default_acacia_sapling.png",
	},
})

mcl_trees.register_wood("birch",{
	sign_color="#ffdba7",
	tree_schems = {
		{ file = modpath.."/schematics/mcl_core_birch_bee_nest.mts", width = 5, height = 8 },
		{ file = modpath.."/schematics/mcl_core_birch.mts", width = 5, height = 9 },
		{ file = modpath.."/schematics/mcl_core_birch_tall.mts", width = 5, height = 13 },
	},
})
