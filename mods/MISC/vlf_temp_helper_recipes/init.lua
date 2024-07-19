-- Temporary helper recipes.
-- These recipes are NOT part of Minecraft. They are added to make some currently unobtainable items accessible.
-- TODO: Remove recipes when they become accessible by regular means

minetest.register_craft({
	type = "shapeless",
	output = "vlf_chests:trapped_chest",
	recipe = {"vlf_core:iron_ingot", "vlf_core:stick", "group:wood", "vlf_chests:chest"},
})

minetest.register_craft({
	output = "vlf_nether:quartz_smooth 4",
	recipe = {
		{ "vlf_nether:quartz_block", "vlf_nether:quartz_block" },
		{ "vlf_nether:quartz_block", "vlf_nether:quartz_block" },
	},
})

minetest.register_craft({
	output = "vlf_core:sandstonesmooth2 4",
	recipe = {
		{ "vlf_core:sandstonesmooth", "vlf_core:sandstonesmooth" },
		{ "vlf_core:sandstonesmooth", "vlf_core:sandstonesmooth" },
	},
})

minetest.register_craft({
	output = "vlf_core:redsandstonesmooth2 4",
	recipe = {
		{ "vlf_core:redsandstonesmooth", "vlf_core:redsandstonesmooth" },
		{ "vlf_core:redsandstonesmooth", "vlf_core:redsandstonesmooth" },
	},
})

minetest.register_craft({
	output = "vlf_entity_effects:dragon_breath 3",
	recipe = {
		{"","vlf_end:chorus_flower",""},
		{"vlf_entity_effects:glass_bottle","vlf_entity_effects:glass_bottle","vlf_entity_effects:glass_bottle"},
	}
})

-- Armor trims
minetest.register_craft({
	output = "vlf_armor:eye",
	recipe = {
		{"vlf_core:diamond","vlf_end:ender_eye","vlf_core:diamond"},
		{"vlf_core:diamond","vlf_end:ender_eye","vlf_core:diamond"},
		{"vlf_core:diamond","vlf_core:diamond","vlf_core:diamond"},
	}
})

minetest.register_craft({
    output = "vlf_armor:wayfinder",
    recipe = {
        {"vlf_core:diamond","vlf_core:diamond","vlf_core:diamond"},
        {"vlf_core:diamond", "vlf_maps:empty_map","vlf_core:diamond"},
        {"vlf_core:diamond","vlf_core:diamond","vlf_core:diamond"},
    }
})
