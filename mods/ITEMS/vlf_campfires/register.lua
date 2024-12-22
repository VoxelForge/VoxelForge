local S = minetest.get_translator(minetest.get_current_modname())

-- Register Plain Campfire
vlf_campfires.register_campfire("vlf_campfires:campfire", {
	description = S("Campfire"),
	inv_texture = "vlf_campfires_campfire_inv.png",
	fire_texture = "vlf_campfires_campfire_fire.png",
	lit_logs_texture = "vlf_campfires_campfire_log_lit.png",
	drops = "vlf_core:charcoal_lump 2",
	lightlevel = minetest.LIGHT_MAX,
	damage = 1,
})

-- Register Soul Campfire
vlf_campfires.register_campfire("vlf_campfires:soul_campfire", {
	description = S("Soul Campfire"),
	inv_texture = "vlf_campfires_soul_campfire_inv.png",
	fire_texture = "vlf_campfires_soul_campfire_fire.png",
	lit_logs_texture = "vlf_campfires_soul_campfire_log_lit.png",
	drops = "vlf_blackstone:soul_soil",
	lightlevel = 10,
	damage = 2,
	groups = {
		soul_firelike = 1,
	},
})

-- Register Campfire Crafting
minetest.register_craft({
	output = "vlf_campfires:campfire_lit",
	recipe = {
		{ "", "vlf_core:stick", "" },
		{ "vlf_core:stick", "group:coal", "vlf_core:stick" },
		{ "group:tree", "group:tree", "group:tree" },
	}
})

minetest.register_craft({
	output = "vlf_campfires:soul_campfire_lit",
	recipe = {
		{ "", "vlf_core:stick", "" },
		{ "vlf_core:stick", "group:soul_block", "vlf_core:stick" },
		{ "group:tree", "group:tree", "group:tree" },
	}
})
