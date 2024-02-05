local S = minetest.get_translator(minetest.get_current_modname())

local extra_nodes = minetest.settings:get_bool("mcl_extra_nodes", true)

mcl_stairs.register_stair_and_slab("stone_rough", {
	baseitem = "mcl_core:stone",
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:stone"}},
})

mcl_stairs.register_slab("stone", {
	baseitem = "mcl_core:stone_smooth",
	tiles = {"mcl_stairs_stone_slab_top.png", "mcl_stairs_stone_slab_top.png", "mcl_stairs_stone_slab_side.png"},
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:stone_smooth"}},
})
mcl_stairs.register_stair("stone", {
	baseitem = "mcl_core:stone_smooth",
	recipeitem = extra_nodes and "mcl_core:stone_smooth" or "",
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:stone_smooth"}},
	groups = {not_in_creative_inventory = extra_nodes and 0 or 1},
})


mcl_stairs.register_stair_and_slab("andesite", {
	baseitem = "mcl_core:andesite",
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:andesite"}},
})
mcl_stairs.register_stair_and_slab("granite", {
	baseitem = "mcl_core:granite",
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:granite"}},
})
mcl_stairs.register_stair_and_slab("diorite", {
	baseitem = "mcl_core:diorite",
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:diorite"}},
})

mcl_stairs.register_stair_and_slab("cobble", {
	baseitem = "mcl_core:cobble",
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:cobble"}},
})
mcl_stairs.register_stair_and_slab("mossycobble", {
	baseitem = "mcl_core:mossycobble",
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:mossycobble"}},
})

mcl_stairs.register_stair_and_slab("brick_block", {
	baseitem = "mcl_core:brick_block",
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:brick_block"}},
})


mcl_stairs.register_stair_and_slab("sandstone", {
	baseitem = "mcl_core:sandstone",
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:sandstone"}},
})
mcl_stairs.register_stair_and_slab("sandstonesmooth2", {
	baseitem = "mcl_core:sandstonesmooth2",
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:sandstone"}},
})
mcl_stairs.register_stair_and_slab("sandstonesmooth", {
	baseitem = "mcl_core:sandstonesmooth",
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:sandstone", "mcl_core:sandstonesmooth2"}},
})

mcl_stairs.register_stair_and_slab("redsandstone", {
	baseitem = "mcl_core:redsandstone",
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:redsandstone"}},
})
mcl_stairs.register_stair_and_slab("redsandstonesmooth2", {
	baseitem = "mcl_core:redsandstonesmooth2",
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:redsandstone"}},
})
mcl_stairs.register_stair_and_slab("redsandstonesmooth", {
	baseitem = "mcl_core:redsandstonesmooth",
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:redsandstone", "mcl_core:redsandstonesmooth2"}},
})

mcl_stairs.register_stair_and_slab("stonebrick", {
	baseitem = "mcl_core:stonebrick",
	base_description = S("Stone Brick"),
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:stone", "mcl_core:stonebrick"}},
})

mcl_stairs.register_stair("andesite_smooth", {
	baseitem = "mcl_core:andesite_smooth",
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:andesite_smooth", "mcl_core:andesite"}},
})
mcl_stairs.register_slab("andesite_smooth", {
	baseitem = "mcl_core:andesite_smooth",
	tiles={"mcl_core_andesite_smooth.png", "mcl_core_andesite_smooth.png", "mcl_stairs_andesite_smooth_slab.png"},
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:andesite_smooth", "mcl_core:andesite"}},
})

mcl_stairs.register_stair("granite_smooth", {
	baseitem = "mcl_core:granite_smooth",
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:granite_smooth", "mcl_core:granite"}},
})
mcl_stairs.register_slab("granite_smooth", {
	baseitem = "mcl_core:granite_smooth",
	tiles={"mcl_core_granite_smooth.png", "mcl_core_granite_smooth.png", "mcl_stairs_granite_smooth_slab.png"},
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:granite_smooth", "mcl_core:granite"}},
})

mcl_stairs.register_stair("diorite_smooth", {
	baseitem = "mcl_core:diorite_smooth",
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:diorite_smooth", "mcl_core:diorite"}},
})
mcl_stairs.register_slab("diorite_smooth", {
	baseitem = "mcl_core:diorite_smooth",
	tiles={"mcl_core_diorite_smooth.png", "mcl_core_diorite_smooth.png", "mcl_stairs_diorite_smooth_slab.png"},
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:diorite_smooth", "mcl_core:diorite"}},
})

mcl_stairs.register_stair("stonebrickmossy", {
	baseitem = "mcl_core:stonebrickmossy",
	base_description = S("Mossy Stone Brick"),
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:stonebrickmossy"}},
})
