local S = minetest.get_translator(minetest.get_current_modname())

-- Register Plain Campfire
vlc_campfires.register_campfire("vlc_campfires:campfire", {
	description = S("Campfire"),
	inv_texture = "vlc_campfires_campfire_inv.png",
	fire_texture = "vlc_campfires_campfire_fire.png",
	lit_logs_texture = "vlc_campfires_campfire_log_lit.png",
	drops = "vlc_core:charcoal_lump 2",
	lightlevel = 14,
	damage = 1,
})

-- Register Soul Campfire
vlc_campfires.register_campfire("vlc_campfires:soul_campfire", {
	description = S("Soul Campfire"),
	inv_texture = "vlc_campfires_soul_campfire_inv.png",
	fire_texture = "vlc_campfires_soul_campfire_fire.png",
	lit_logs_texture = "vlc_campfires_soul_campfire_log_lit.png",
	drops = "vlc_blackstone:soul_soil",
	lightlevel = 10,
	damage = 2,
})

-- Register Campfire Crafting
minetest.register_craft({
	output = "vlc_campfires:campfire_lit",
	recipe = {
		{ "", "vlc_core:stick", "" },
		{ "vlc_core:stick", "group:coal", "vlc_core:stick" },
		{ "group:tree", "group:tree", "group:tree" },
	}
})

minetest.register_craft({
	output = "vlc_campfires:soul_campfire_lit",
	recipe = {
		{ "", "vlc_core:stick", "" },
		{ "vlc_core:stick", "group:soul_block", "vlc_core:stick" },
		{ "group:tree", "group:tree", "group:tree" },
	}
})
