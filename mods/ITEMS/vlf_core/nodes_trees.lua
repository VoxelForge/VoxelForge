local schempath = minetest.get_modpath("vlf_schematics")

local S = minetest.get_translator(minetest.get_current_modname())

vlf_trees.register_wood("oak",{
	readable_name = S("Oak"),
	sign_color="#917056",
	tree_schems= {
		{ file = schempath.."/schems/vlf_core_oak_balloon.mts"},
		{ file = schempath.."/schems/vlf_core_oak_large_1.mts"},
		{ file = schempath.."/schems/vlf_core_oak_large_2.mts"},
		{ file = schempath.."/schems/vlf_core_oak_large_3.mts"},
		{ file = schempath.."/schems/vlf_core_oak_large_4.mts"},
		{ file = schempath.."/schems/vlf_core_oak_swamp.mts"},
		{ file = schempath.."/schems/vlf_core_oak_v6.mts"},
		{ file = schempath.."/schems/vlf_core_oak_classic_bee_nest.mts"},
		{ file = schempath.."/schems/vlf_core_oak_classic.mts"},
	},
	tree = { tiles = {"default_tree_top.png", "default_tree_top.png","default_tree.png"} },
	leaves = {
		tiles = { "default_leaves.png" },
		color = "#77ab2f",
	},
	drop_apples = true,
	wood = { tiles = {"default_wood.png"}},
	sapling = {
		tiles = {"default_sapling.png"},
		inventory_image = "default_sapling.png",
		wield_image = "default_sapling.png",
	},
	door = {
		inventory_image = "doors_item_wood.png",
		tiles_bottom = {"vlf_doors_door_wood_lower.png", "vlf_doors_door_wood_side_lower.png"},
		tiles_top = {"vlf_doors_door_wood_upper.png", "vlf_doors_door_wood_side_upper.png"}
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

vlf_trees.register_wood("dark_oak",{
	readable_name = S("Dark Oak"),
	sign_color="#625048",
	tree_schems_2x2 = {
		{ file = schempath.."/schems/vlf_core_dark_oak.mts"},
	},
	tree = { tiles = {"vlf_core_log_big_oak_top.png", "vlf_core_log_big_oak_top.png","vlf_core_log_big_oak.png"} },
	leaves = {
		tiles = { "vlf_core_leaves_big_oak.png" },
		color = "#77ab2f",
	},
	drop_apples = true,
	wood = { tiles = {"vlf_core_planks_big_oak.png"}},
	sapling = {
		tiles = {"vlf_core_sapling_big_oak.png"},
		inventory_image = "vlf_core_sapling_big_oak.png",
		wield_image = "vlf_core_sapling_big_oak.png",
	},
	fence = {
		tiles = { "vlf_fences_fence_big_oak.png" },
	},
	fence_gate = {
		tiles = { "vlf_fences_fence_gate_big_oak.png" },
	},
	potted_sapling = {
		image = "vlf_core_sapling_big_oak.png",
	},
})

vlf_trees.register_wood("jungle",{
	readable_name = S("Jungle"),
	sign_color="#845A43",
	tree_schems = {
		{ file = schempath.."/schems/vlf_core_jungle_tree.mts"},
		{ file = schempath.."/schems/vlf_core_jungle_tree_2.mts"},
		{ file = schempath.."/schems/vlf_core_jungle_tree_3.mts"},
		{ file = schempath.."/schems/vlf_core_jungle_tree_4.mts"},
	},
	tree_schems_2x2 = {
		{ file = schempath.."/schems/vlf_core_jungle_tree_huge_1.mts"},
		{ file = schempath.."/schems/vlf_core_jungle_tree_huge_2.mts"},
		{ file = schempath.."/schems/vlf_core_jungle_tree_huge_3.mts"},
		{ file = schempath.."/schems/vlf_core_jungle_tree_huge_4.mts"},
	},
	tree = { tiles = {"default_jungletree_top.png", "default_jungletree_top.png","default_jungletree.png"} },
	leaves = {
		tiles = { "default_jungleleaves.png" },
		color = "#30bb0b",
	},
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

vlf_trees.register_wood("spruce",{
	readable_name = S("Spruce"),
	sign_color="#604335",
	tree_schems = {
		{ file = schempath.."/schems/vlf_core_spruce_1.mts"},
		{ file = schempath.."/schems/vlf_core_spruce_2.mts"},
		{ file = schempath.."/schems/vlf_core_spruce_3.mts"},
		{ file = schempath.."/schems/vlf_core_spruce_4.mts"},
		{ file = schempath.."/schems/vlf_core_spruce_5.mts"},
		{ file = schempath.."/schems/vlf_core_spruce_lollipop.mts"},
		{ file = schempath.."/schems/vlf_core_spruce_matchstick.mts"},
		{ file = schempath.."/schems/vlf_core_spruce_tall.mts"},
	},
	tree_schems_2x2 = {
		{ file = schempath.."/schems/vlf_core_spruce_huge_1.mts"},
		{ file = schempath.."/schems/vlf_core_spruce_huge_2.mts"},
		{ file = schempath.."/schems/vlf_core_spruce_huge_3.mts"},
		{ file = schempath.."/schems/vlf_core_spruce_huge_4.mts"},
		{ file = schempath.."/schems/vlf_core_spruce_huge_up_1.mts"},
		{ file = schempath.."/schems/vlf_core_spruce_huge_up_2.mts"},
		{ file = schempath.."/schems/vlf_core_spruce_huge_up_3.mts"},
	},
	leaves = {
		color = "#2bbb0f",
	},
})

vlf_trees.register_wood("acacia",{
	readable_name = S("Acacia"),
	sign_color="#965638",
	tree_schems ={
		{ file = schempath.."/schems/vlf_core_acacia_1.mts"},
		{ file = schempath.."/schems/vlf_core_acacia_2.mts"},
		{ file = schempath.."/schems/vlf_core_acacia_3.mts"},
		{ file = schempath.."/schems/vlf_core_acacia_4.mts"},
		{ file = schempath.."/schems/vlf_core_acacia_5.mts"},
		{ file = schempath.."/schems/vlf_core_acacia_6.mts"},
		{ file = schempath.."/schems/vlf_core_acacia_7.mts"},
		{ file = schempath.."/schems/vlf_core_acacia_weirdo.mts"},
	},
	tree = { tiles = {"default_acacia_tree_top.png", "default_acacia_tree_top.png","default_acacia_tree.png"} },
	leaves = {
		tiles = { "default_acacia_leaves.png" },
		color = "#aea42a",
	},
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

vlf_trees.register_wood("birch",{
	readable_name = S("Birch"),
	sign_color="#AA907A",
	tree_schems = {
		{ file = schempath.."/schems/vlf_core_birch_bee_nest.mts"},
		{ file = schempath.."/schems/vlf_core_birch.mts"},
		{ file = schempath.."/schems/vlf_core_birch_tall.mts"},
	},
	leaves = {
		color = "#68a55f",
	},
})
