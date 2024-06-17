-- Temporary helper recipes.
-- These recipes are NOT part of Minecraft. They are added to make some currently unobtainable items accessible.
-- TODO: Remove recipes when they become accessible by regular means

minetest.register_craft({
	type = "shapeless",
	output = "vlc_chests:trapped_chest",
	recipe = {"vlc_core:iron_ingot", "vlc_core:stick", "group:wood", "vlc_chests:chest"},
})

minetest.register_craft({
	output = "vlc_nether:quartz_smooth 4",
	recipe = {
		{ "vlc_nether:quartz_block", "vlc_nether:quartz_block" },
		{ "vlc_nether:quartz_block", "vlc_nether:quartz_block" },
	},
})

minetest.register_craft({
	output = "vlc_core:sandstonesmooth2 4",
	recipe = {
		{ "vlc_core:sandstonesmooth", "vlc_core:sandstonesmooth" },
		{ "vlc_core:sandstonesmooth", "vlc_core:sandstonesmooth" },
	},
})

minetest.register_craft({
	output = "vlc_core:redsandstonesmooth2 4",
	recipe = {
		{ "vlc_core:redsandstonesmooth", "vlc_core:redsandstonesmooth" },
		{ "vlc_core:redsandstonesmooth", "vlc_core:redsandstonesmooth" },
	},
})

minetest.register_craft({
	output = "vlc_potions:dragon_breath 3",
	recipe = {
		{"","vlc_end:chorus_flower",""},
		{"vlc_potions:glass_bottle","vlc_potions:glass_bottle","vlc_potions:glass_bottle"},
	}
})

-- Armor trims
minetest.register_craft({
	output = "vlc_armor:eye",
	recipe = {
		{"vlc_core:diamond","vlc_end:ender_eye","vlc_core:diamond"},
		{"vlc_core:diamond","vlc_end:ender_eye","vlc_core:diamond"},
		{"vlc_core:diamond","vlc_core:diamond","vlc_core:diamond"},
	}
})

minetest.register_craft({
    output = "vlc_armor:wayfinder",
    recipe = {
        {"vlc_core:diamond","vlc_core:diamond","vlc_core:diamond"},
        {"vlc_core:diamond", "vlc_maps:empty_map","vlc_core:diamond"},
        {"vlc_core:diamond","vlc_core:diamond","vlc_core:diamond"},
    }
})
