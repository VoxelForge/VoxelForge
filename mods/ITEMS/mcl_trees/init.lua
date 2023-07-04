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
		},
		tree = { tiles = {"default_tree_top.png", "default_tree_top.png","default_tree.png"} },
		leaves = { tiles = { "default_leaves.png" } },
		planks = { tiles = {"default_wood.png"}},
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
	} ,
	["dark_oak"]={
		sign_color="#5F4021",
		tree_schems = {
			{ file=modpath.."/schematics/mcl_core_dark_oak.mts",width=4,height=7 },
		},
		tree = { tiles = {"mcl_core_log_big_oak_top.png", "mcl_core_log_big_oak_top.png","mcl_core_log_big_oak.png"} },
		leaves = { tiles = { "mcl_core_leaves_big_oak.png" } },
		planks = { tiles = {"mcl_core_planks_big_oak.png"}},
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
		tree = { tiles = {"default_jungletree_top.png", "default_jungletree_top.png","default_jungletree.png"} },
		leaves = { tiles = { "default_jungleleaves.png" } },
		planks = { tiles = {"default_junglewood.png"}},
		sapling = {
			tiles = {"default_junglesapling.png"},
			inventory_image = "defaultjungle_sapling.png",
			wield_image = "default_junglesapling.png",
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
		},
		tree = { tiles = {"default_acacia_tree_top.png", "default_acacia_tree_top.png","default_acacia_tree.png"} },
		leaves = { tiles = { "default_acacia_leaves.png" } },
		planks = { tiles = {"default_acacia_wood.png"}},
		sapling = {
			tiles = {"default_acacia_sapling.png"},
			inventory_image = "default_acacia_sapling.png",
			wield_image = "default_acacia_sapling.png",
		},
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
		},
		tree = { tiles = {"mcl_mangrove_log_top.png", "mcl_mangrove_log_top.png","mcl_mangrove_log.png" }},
		bark = { tiles = {"mcl_mangrove_log.png"}},
		leaves = { tiles = { "mcl_mangrove_leaves.png" }},
		planks = { tiles = {"mcl_mangrove_planks.png"}},
		stripped = {
			tiles = {"mcl_stripped_mangrove_log_top.png", "mcl_stripped_mangrove_log_top.png","mcl_stripped_mangrove_log_side.png"}
		},
		stripped_bark = {
			tiles = {"mcl_stripped_mangrove_log_side.png"}
		},
		fence = {
			tiles = { "mcl_mangrove_fence.png" },
		},
		fence_gate = {
			tiles = { "mcl_mangrove_fence_gate.png" },
		},
		door = {
			inventory_image = "mcl_mangrove_doors.png",
			tiles_bottom = {"mcl_mangrove_door_bottom.png", "mcl_mangrove_door_bottom.png"},
			tiles_top = {"mcl_mangrove_door_top.png", "mcl_mangrove_door_top.png"}
		},
		trapdoor = {
			tile_front = "mcl_mangrove_trapdoor.png",
			tile_side = "mcl_mangrove_trapdoor.png",
			wield_image = "mcl_mangrove_trapdoor.png",
		},
	},
	["crimson"]={
		sign_color="#c35f51",
		boat=false,
		sapling=false,
		leaves=false,
		tree = { tiles = {"crimson_hyphae.png", "crimson_hyphae.png","crimson_hyphae_side.png" }},
		bark = { tiles = {"crimson_hyphae_side.png"}},
		planks = { tiles = {"crimson_hyphae_wood.png"}},
		stripped = {
			tiles = {"stripped_crimson_stem_top.png", "stripped_crimson_stem_top.png","stripped_crimson_stem_side.png"}
		},
		stripped_bark = {
			tiles = {"stripped_crimson_stem_side.png"}
		},
		fence = {
			tiles = { "mcl_crimson_crimson_fence.png" },
		},
		fence_gate = {
			tiles = { "mcl_crimson_crimson_fence.png" },
		},
		door = {
			inventory_image = "mcl_crimson_crimson_door.png",
			tiles_bottom = {"mcl_crimson_crimson_door_bottom.png","mcl_doors_door_crimson_side_upper.png"},
			tiles_top = {"mcl_crimson_crimson_door_top.png","mcl_doors_door_crimson_side_upper.png"},
		},
		trapdoor = {
			tile_front = "mcl_crimson_crimson_trapdoor.png",
			tile_side = "mcl_crimson_crimson_trapdoor.png",
			wield_image = "mcl_crimson_crimson_trapdoor.png",
		},
	},
	["warped"]={
		sign_color="#9f7dcf",
		boat=false,
		sapling=false,
		leaves=false,
		tree = { tiles = {"warped_hyphae.png", "warped_hyphae.png","warped_hyphae_side.png" }},
		bark = { tiles = {"warped_hyphae_side.png"}},
		planks = { tiles = {"warped_hyphae_wood.png"}},
		stripped = {
			tiles = {"stripped_warped_stem_top.png", "stripped_warped_stem_top.png","stripped_warped_stem_side.png"}
		},
		stripped_bark = {
			tiles = {"stripped_warped_stem_side.png"}
		},
		fence = {
			tiles = { "mcl_crimson_warped_fence.png" },
		},
		fence_gate = {
			tiles = { "mcl_crimson_warped_fence.png" },
		},
		door = {
			inventory_image = "mcl_crimson_warped_door.png",
			tiles_bottom = {"mcl_crimson_warped_door_bottom.png","mcl_doors_door_warped_side_upper.png"},
			tiles_top = {"mcl_crimson_warped_door_top.png","mcl_doors_door_warped_side_upper.png"},
		},
		trapdoor = {
			tile_front = "mcl_crimson_warped_trapdoor.png",
			tile_side = "mcl_crimson_warped_trapdoor.png",
			wield_image = "mcl_crimson_warped_trapdoor.png",
		},
	},
	["bamboo"]={
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
	tiles = {"default_ladder.png"},
	inventory_image = "default_ladder.png",
	wield_image = "default_ladder.png",
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
