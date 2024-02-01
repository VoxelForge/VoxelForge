local S = minetest.get_translator(minetest.get_current_modname())

mcl_stairs.register_stair_and_slab("stone_rough", {
	baseitem = "mcl_core:stone",
	extra_fields = {_mcl_stonecutter_recipes = {"mcl_core:stone"}},
})

mcl_stairs.register_slab("stone", {
	baseitem = "mcl_core:stone_smooth",
	tiles = {"mcl_stairs_stone_slab_top.png", "mcl_stairs_stone_slab_top.png", "mcl_stairs_stone_slab_side.png"},
	extra_fields = {_mcl_stonecutter_recipes = {"mcl_core:stone_smooth"}},
})

mcl_stairs.register_stair_and_slab("andesite", {
	baseitem = "mcl_core:andesite",
	extra_fields = {_mcl_stonecutter_recipes = {"mcl_core:andesite"}},
})
mcl_stairs.register_stair_and_slab("granite", {
	baseitem = "mcl_core:granite",
	extra_fields = {_mcl_stonecutter_recipes = {"mcl_core:granite"}},
})
mcl_stairs.register_stair_and_slab("diorite", {
	baseitem = "mcl_core:diorite",
	extra_fields = {_mcl_stonecutter_recipes = {"mcl_core:diorite"}},
})

mcl_stairs.register_stair_and_slab("cobble", {
	baseitem = "mcl_core:cobble",
	extra_fields = {_mcl_stonecutter_recipes = {"mcl_core:cobble"}},
})
mcl_stairs.register_stair_and_slab("mossycobble", {
	baseitem = "mcl_core:mossycobble",
	extra_fields = {_mcl_stonecutter_recipes = {"mcl_core:mossycobble"}},
})

mcl_stairs.register_stair_and_slab("brick_block", {
	baseitem = "mcl_core:brick_block",
	extra_fields = {_mcl_stonecutter_recipes = {"mcl_core:brick_block"}},
})


mcl_stairs.register_stair_and_slab("sandstone", {
	baseitem = "mcl_core:sandstone",
	extra_fields = {_mcl_stonecutter_recipes = {"mcl_core:sandstone"}},
})
mcl_stairs.register_stair_and_slab("sandstonesmooth2", {
	baseitem = "mcl_core:sandstonesmooth2",
	extra_fields = {_mcl_stonecutter_recipes = {"mcl_core:sandstone"}},
})
mcl_stairs.register_stair_and_slab("sandstonesmooth", {
	baseitem = "mcl_core:sandstonesmooth",
	extra_fields = {_mcl_stonecutter_recipes = {"mcl_core:sandstone", "mcl_core:sandstonesmooth2"}},
})

mcl_stairs.register_stair_and_slab("redsandstone", {
	baseitem = "mcl_core:redsandstone",
	extra_fields = {_mcl_stonecutter_recipes = {"mcl_core:redsandstone"}},
})
mcl_stairs.register_stair_and_slab("redsandstonesmooth2", {
	baseitem = "mcl_core:redsandstonesmooth2",
	extra_fields = {_mcl_stonecutter_recipes = {"mcl_core:redsandstone"}},
})
mcl_stairs.register_stair_and_slab("redsandstonesmooth", {
	baseitem = "mcl_core:redsandstonesmooth",
	extra_fields = {_mcl_stonecutter_recipes = {"mcl_core:redsandstone", "mcl_core:redsandstonesmooth2"}},
})

mcl_stairs.register_stair_and_slab("stonebrick", {
	baseitem = "mcl_core:stonebrick",
	basedesc = S("Stone Brick"),
	extra_fields = {_mcl_stonecutter_recipes = {"mcl_core:stone", "mcl_core:stonebrick"}}
})

mcl_stairs.register_stair_and_slab("andesite_smooth", {
	baseitem = "mcl_core:andesite_smooth",
	extra_fields = {_mcl_stonecutter_recipes = {"mcl_core:andesite_smooth", "mcl_core:andesite"}}
})

mcl_stairs.register_stair_and_slab("granite_smooth", {
	baseitem = "mcl_core:granite_smooth",
	extra_fields = {_mcl_stonecutter_recipes = {"mcl_core:granite_smooth", "mcl_core:granite"}}
})

mcl_stairs.register_stair_and_slab("diorite_smooth", {
	baseitem = "mcl_core:diorite_smooth",
	extra_fields = {_mcl_stonecutter_recipes = {"mcl_core:diorite_smooth", "mcl_core:diorite"}}
})

mcl_stairs.register_stair("stonebrickmossy", {
	baseitem = "mcl_core:stonebrickmossy",
	basedesc = S("Mossy Stone Brick"),
	{_mcl_stonecutter_recipes = {"mcl_core:stonebrickmossy"}}
})
