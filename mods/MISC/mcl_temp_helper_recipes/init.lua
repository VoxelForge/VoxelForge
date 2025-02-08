-- Temporary helper recipes.
-- These recipes are NOT part of Minecraft. They are added to make some currently unobtainable items accessible.
-- TODO: Remove recipes when they become accessible by regular means

minetest.register_craft({
	type = "shapeless",
	output = "mcl_chests:trapped_chest",
	recipe = {"mcl_core:iron_ingot", "mcl_core:stick", "group:wood", "mcl_chests:chest"},
})

-- Armor trims
minetest.register_craft({
	output = "mcl_armor:eye",
	recipe = {
		{"mcl_core:diamond","mcl_end:ender_eye","mcl_core:diamond"},
		{"mcl_core:diamond","mcl_end:ender_eye","mcl_core:diamond"},
		{"mcl_core:diamond","mcl_core:diamond","mcl_core:diamond"},
	}
})

minetest.register_craft({
    output = "mcl_armor:wayfinder",
    recipe = {
        {"mcl_core:diamond","mcl_core:diamond","mcl_core:diamond"},
        {"mcl_core:diamond", "mcl_maps:empty_map","mcl_core:diamond"},
        {"mcl_core:diamond","mcl_core:diamond","mcl_core:diamond"},
    }
})
