-- Temporary helper recipes.
-- These recipes are NOT part of Minecraft. They are added to make some currently unobtainable items accessible.
-- TODO: Remove recipes when they become accessible by regular means

minetest.register_craft({
	type = "shapeless",
	output = "vlf_chests:trapped_chest",
	recipe = {"vlf_core:iron_ingot", "vlf_core:stick", "group:wood", "vlf_chests:chest"},
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
