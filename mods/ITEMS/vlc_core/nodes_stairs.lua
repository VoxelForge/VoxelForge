local S = minetest.get_translator(minetest.get_current_modname())

vlc_stairs.register_stair_and_slab("stone_rough", {
	baseitem = "vlc_core:stone",
	description_stair = S("Stone Stairs"),
	description_slab = S("Stone Slab"),
	overrides = {_vlc_stonecutter_recipes = {"vlc_core:stone"}},
})

vlc_stairs.register_slab("stone", {
	baseitem = "vlc_core:stone_smooth",
	description = S("Smooth Stone Slab"),
	tiles = {"vlc_stairs_stone_slab_top.png", "vlc_stairs_stone_slab_top.png", "vlc_stairs_stone_slab_side.png"},
	overrides = {_vlc_stonecutter_recipes = {"vlc_core:stone_smooth"}},
})

vlc_stairs.register_stair_and_slab("andesite", {
	baseitem = "vlc_core:andesite",
	description_stair = S("Andesite Stairs"),
	description_slab = S("Andesite Slab"),
	overrides = {_vlc_stonecutter_recipes = {"vlc_core:andesite"}},
})
vlc_stairs.register_stair_and_slab("granite", {
	baseitem = "vlc_core:granite",
	description_stair = S("Granite Stairs"),
	description_slab = S("Granite Slab"),
	overrides = {_vlc_stonecutter_recipes = {"vlc_core:granite"}},
})
vlc_stairs.register_stair_and_slab("diorite", {
	baseitem = "vlc_core:diorite",
	description_stair = S("Diorite Stairs"),
	description_slab = S("Diorite Slab"),
	overrides = {_vlc_stonecutter_recipes = {"vlc_core:diorite"}},
})

vlc_stairs.register_stair_and_slab("cobble", {
	baseitem = "vlc_core:cobble",
	description_stair = S("Cobblestone Stairs"),
	description_slab = S("Cobblestone Slab"),
	overrides = {_vlc_stonecutter_recipes = {"vlc_core:cobble"}},
})
vlc_stairs.register_stair_and_slab("mossycobble", {
	baseitem = "vlc_core:mossycobble",
	description_stair = S("Mossy Cobblestone Stairs"),
	description_slab = S("Mossy Cobblestone Slab"),
	overrides = {_vlc_stonecutter_recipes = {"vlc_core:mossycobble"}},
})

vlc_stairs.register_stair_and_slab("brick_block", {
	baseitem = "vlc_core:brick_block",
	description_stair = S("Brick Stairs"),
	description_slab = S("Brick Slab"),
	overrides = {_vlc_stonecutter_recipes = {"vlc_core:brick_block"}},
})


vlc_stairs.register_stair_and_slab("sandstone", {
	baseitem = "vlc_core:sandstone",
	description_stair = S("Sandstone Stairs"),
	description_slab = S("Sandstone Slab"),
	overrides = {_vlc_stonecutter_recipes = {"vlc_core:sandstone"}},
})
vlc_stairs.register_stair_and_slab("sandstonesmooth2", {
	baseitem = "vlc_core:sandstonesmooth2",
	description_stair = S("Smooth Sandstone Stairs"),
	description_slab = S("Smooth Sandstone Slab"),
	overrides = {_vlc_stonecutter_recipes = {"vlc_core:sandstone"}},
})
vlc_stairs.register_stair_and_slab("sandstonesmooth", {
	baseitem = "vlc_core:sandstonesmooth",
	description_stair = S("Cut Sandstone Stairs"),
	description_slab = S("Cut Sandstone Slab"),
	overrides = {_vlc_stonecutter_recipes = {"vlc_core:sandstone", "vlc_core:sandstonesmooth2"}},
})

vlc_stairs.register_stair_and_slab("redsandstone", {
	baseitem = "vlc_core:redsandstone",
	description_stair = S("Red Sandstone Stairs"),
	description_slab = S("Red Sandstone Slab"),
	overrides = {_vlc_stonecutter_recipes = {"vlc_core:redsandstone"}},
})
vlc_stairs.register_stair_and_slab("redsandstonesmooth2", {
	baseitem = "vlc_core:redsandstonesmooth2",
	description_stair = S("Smooth Red Sandstone Stairs"),
	description_slab = S("Smooth Red Sandstone Slab"),
	overrides = {_vlc_stonecutter_recipes = {"vlc_core:redsandstone"}},
})
vlc_stairs.register_stair_and_slab("redsandstonesmooth", {
	baseitem = "vlc_core:redsandstonesmooth",
	description_stair = S("Cut Red Sandstone Stairs"),
	description_slab = S("Cut Red Sandstone Slab"),
	overrides = {_vlc_stonecutter_recipes = {"vlc_core:redsandstone", "vlc_core:redsandstonesmooth2"}},
})

vlc_stairs.register_stair_and_slab("stonebrick", {
	baseitem = "vlc_core:stonebrick",
	description_stair = S("Stone Brick Stairs"),
	description_slab = S("Stone Brick Slab"),
	overrides = {_vlc_stonecutter_recipes = {"vlc_core:stone", "vlc_core:stonebrick"}},
})

vlc_stairs.register_stair("andesite_smooth", {
	baseitem = "vlc_core:andesite_smooth",
	description = S("Polished Andesite Stairs"),
	overrides = {_vlc_stonecutter_recipes = {"vlc_core:andesite_smooth", "vlc_core:andesite"}},
})
vlc_stairs.register_slab("andesite_smooth", {
	baseitem = "vlc_core:andesite_smooth",
	description = S("Polished Andesite Slab"),
	tiles = {"vlc_core_andesite_smooth.png", "vlc_core_andesite_smooth.png", "vlc_stairs_andesite_smooth_slab.png"},
	overrides = {_vlc_stonecutter_recipes = {"vlc_core:andesite_smooth", "vlc_core:andesite"}},
})

vlc_stairs.register_stair("granite_smooth", {
	baseitem = "vlc_core:granite_smooth",
	description = S("Polished Granite Stairs"),
	overrides = {_vlc_stonecutter_recipes = {"vlc_core:granite_smooth", "vlc_core:granite"}},
})
vlc_stairs.register_slab("granite_smooth", {
	baseitem = "vlc_core:granite_smooth",
	description = S("Polished Granite Slab"),
	tiles = {"vlc_core_granite_smooth.png", "vlc_core_granite_smooth.png", "vlc_stairs_granite_smooth_slab.png"},
	overrides = {_vlc_stonecutter_recipes = {"vlc_core:granite_smooth", "vlc_core:granite"}},
})

vlc_stairs.register_stair("diorite_smooth", {
	baseitem = "vlc_core:diorite_smooth",
	description = S("Polished Diorite Stairs"),
	overrides = {_vlc_stonecutter_recipes = {"vlc_core:diorite_smooth", "vlc_core:diorite"}},
})
vlc_stairs.register_slab("diorite_smooth", {
	baseitem = "vlc_core:diorite_smooth",
	description = S("Polished Diorite Slab"),
	tiles = {"vlc_core_diorite_smooth.png", "vlc_core_diorite_smooth.png", "vlc_stairs_diorite_smooth_slab.png"},
	overrides = {_vlc_stonecutter_recipes = {"vlc_core:diorite_smooth", "vlc_core:diorite"}},
})

vlc_stairs.register_stair_and_slab("stonebrickmossy", {
	baseitem = "vlc_core:stonebrickmossy",
	description_stair = S("Mossy Stone Brick Stairs"),
	description_slab = S("Mossy Stone Brick Slab"),
	overrides = {_vlc_stonecutter_recipes = {"vlc_core:stonebrickmossy"}},
})
