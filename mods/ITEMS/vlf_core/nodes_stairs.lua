local S = minetest.get_translator(minetest.get_current_modname())

vlf_stairs.register_stair_and_slab("stone_rough", {
	baseitem = "vlf_core:stone",
	description_stair = S("Stone Stairs"),
	description_slab = S("Stone Slab"),
	overrides = {_vlf_stonecutter_recipes = {"vlf_core:stone"}},
})

vlf_stairs.register_slab("stone", {
	baseitem = "vlf_core:stone_smooth",
	description = S("Smooth Stone Slab"),
	tiles = {"vlf_stairs_stone_slab_top.png", "vlf_stairs_stone_slab_top.png", "vlf_stairs_stone_slab_side.png"},
	overrides = {_vlf_stonecutter_recipes = {"vlf_core:stone_smooth"}},
})

vlf_stairs.register_stair_and_slab("andesite", {
	baseitem = "vlf_core:andesite",
	description_stair = S("Andesite Stairs"),
	description_slab = S("Andesite Slab"),
	overrides = {_vlf_stonecutter_recipes = {"vlf_core:andesite"}},
})
vlf_stairs.register_stair_and_slab("granite", {
	baseitem = "vlf_core:granite",
	description_stair = S("Granite Stairs"),
	description_slab = S("Granite Slab"),
	overrides = {_vlf_stonecutter_recipes = {"vlf_core:granite"}},
})
vlf_stairs.register_stair_and_slab("diorite", {
	baseitem = "vlf_core:diorite",
	description_stair = S("Diorite Stairs"),
	description_slab = S("Diorite Slab"),
	overrides = {_vlf_stonecutter_recipes = {"vlf_core:diorite"}},
})

vlf_stairs.register_stair_and_slab("cobble", {
	baseitem = "vlf_core:cobble",
	description_stair = S("Cobblestone Stairs"),
	description_slab = S("Cobblestone Slab"),
	overrides = {_vlf_stonecutter_recipes = {"vlf_core:cobble"}},
})
vlf_stairs.register_stair_and_slab("mossycobble", {
	baseitem = "vlf_core:mossycobble",
	description_stair = S("Mossy Cobblestone Stairs"),
	description_slab = S("Mossy Cobblestone Slab"),
	overrides = {_vlf_stonecutter_recipes = {"vlf_core:mossycobble"}},
})

vlf_stairs.register_stair_and_slab("brick_block", {
	baseitem = "vlf_core:brick_block",
	description_stair = S("Brick Stairs"),
	description_slab = S("Brick Slab"),
	overrides = {_vlf_stonecutter_recipes = {"vlf_core:brick_block"}},
})


vlf_stairs.register_stair_and_slab("sandstone", {
	baseitem = "vlf_core:sandstone",
	description_stair = S("Sandstone Stairs"),
	description_slab = S("Sandstone Slab"),
	overrides = {_vlf_stonecutter_recipes = {"vlf_core:sandstone"}},
})
vlf_stairs.register_stair_and_slab("sandstonesmooth2", {
	baseitem = "vlf_core:sandstonesmooth2",
	description_stair = S("Smooth Sandstone Stairs"),
	description_slab = S("Smooth Sandstone Slab"),
	overrides = {_vlf_stonecutter_recipes = {"vlf_core:sandstone"}},
})
vlf_stairs.register_stair_and_slab("sandstonesmooth", {
	baseitem = "vlf_core:sandstonesmooth",
	description_stair = S("Cut Sandstone Stairs"),
	description_slab = S("Cut Sandstone Slab"),
	overrides = {_vlf_stonecutter_recipes = {"vlf_core:sandstone", "vlf_core:sandstonesmooth2"}},
})

vlf_stairs.register_stair_and_slab("redsandstone", {
	baseitem = "vlf_core:redsandstone",
	description_stair = S("Red Sandstone Stairs"),
	description_slab = S("Red Sandstone Slab"),
	overrides = {_vlf_stonecutter_recipes = {"vlf_core:redsandstone"}},
})
vlf_stairs.register_stair_and_slab("redsandstonesmooth2", {
	baseitem = "vlf_core:redsandstonesmooth2",
	description_stair = S("Smooth Red Sandstone Stairs"),
	description_slab = S("Smooth Red Sandstone Slab"),
	overrides = {_vlf_stonecutter_recipes = {"vlf_core:redsandstone"}},
})
vlf_stairs.register_stair_and_slab("redsandstonesmooth", {
	baseitem = "vlf_core:redsandstonesmooth",
	description_stair = S("Cut Red Sandstone Stairs"),
	description_slab = S("Cut Red Sandstone Slab"),
	overrides = {_vlf_stonecutter_recipes = {"vlf_core:redsandstone", "vlf_core:redsandstonesmooth2"}},
})

vlf_stairs.register_stair_and_slab("stonebrick", {
	baseitem = "vlf_core:stonebrick",
	description_stair = S("Stone Brick Stairs"),
	description_slab = S("Stone Brick Slab"),
	overrides = {_vlf_stonecutter_recipes = {"vlf_core:stone", "vlf_core:stonebrick"}},
})

vlf_stairs.register_stair("andesite_smooth", {
	baseitem = "vlf_core:andesite_smooth",
	description = S("Polished Andesite Stairs"),
	overrides = {_vlf_stonecutter_recipes = {"vlf_core:andesite_smooth", "vlf_core:andesite"}},
})
vlf_stairs.register_slab("andesite_smooth", {
	baseitem = "vlf_core:andesite_smooth",
	description = S("Polished Andesite Slab"),
	tiles = {"vlf_core_andesite_smooth.png", "vlf_core_andesite_smooth.png", "vlf_stairs_andesite_smooth_slab.png"},
	overrides = {_vlf_stonecutter_recipes = {"vlf_core:andesite_smooth", "vlf_core:andesite"}},
})

vlf_stairs.register_stair("granite_smooth", {
	baseitem = "vlf_core:granite_smooth",
	description = S("Polished Granite Stairs"),
	overrides = {_vlf_stonecutter_recipes = {"vlf_core:granite_smooth", "vlf_core:granite"}},
})
vlf_stairs.register_slab("granite_smooth", {
	baseitem = "vlf_core:granite_smooth",
	description = S("Polished Granite Slab"),
	tiles = {"vlf_core_granite_smooth.png", "vlf_core_granite_smooth.png", "vlf_stairs_granite_smooth_slab.png"},
	overrides = {_vlf_stonecutter_recipes = {"vlf_core:granite_smooth", "vlf_core:granite"}},
})

vlf_stairs.register_stair("diorite_smooth", {
	baseitem = "vlf_core:diorite_smooth",
	description = S("Polished Diorite Stairs"),
	overrides = {_vlf_stonecutter_recipes = {"vlf_core:diorite_smooth", "vlf_core:diorite"}},
})
vlf_stairs.register_slab("diorite_smooth", {
	baseitem = "vlf_core:diorite_smooth",
	description = S("Polished Diorite Slab"),
	tiles = {"vlf_core_diorite_smooth.png", "vlf_core_diorite_smooth.png", "vlf_stairs_diorite_smooth_slab.png"},
	overrides = {_vlf_stonecutter_recipes = {"vlf_core:diorite_smooth", "vlf_core:diorite"}},
})

vlf_stairs.register_stair_and_slab("stonebrickmossy", {
	baseitem = "vlf_core:stonebrickmossy",
	description_stair = S("Mossy Stone Brick Stairs"),
	description_slab = S("Mossy Stone Brick Slab"),
	overrides = {_vlf_stonecutter_recipes = {"vlf_core:stonebrickmossy"}},
})
