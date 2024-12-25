local S = minetest.get_translator("vlf_lanterns")

vlf_lanterns.register_lantern("lantern", {
	description = S("Lantern"),
	longdesc = S("Lanterns are light sources which can be placed on the top or the bottom of most blocks."),
	texture = "vlf_lanterns_lantern.png",
	texture_inv = "vlf_lanterns_lantern_inv.png",
	light_level = minetest.LIGHT_MAX,
})

vlf_lanterns.register_lantern("soul_lantern", {
	description = S("Soul Lantern"),
	longdesc = S("Lanterns are light sources which can be placed on the top or the bottom of most blocks."),
	texture = "vlf_lanterns_soul_lantern.png",
	texture_inv = "vlf_lanterns_soul_lantern_inv.png",
	light_level = 10,
	groups = {
		soul_firelike = 1,
	},
})

minetest.register_craft({
	output = "vlf_lanterns:lantern_floor",
	recipe = {
		{"vlf_core:iron_nugget", "vlf_core:iron_nugget", "vlf_core:iron_nugget"},
		{"vlf_core:iron_nugget", "vlf_torches:torch"   , "vlf_core:iron_nugget"},
		{"vlf_core:iron_nugget", "vlf_core:iron_nugget", "vlf_core:iron_nugget"},
	},
})

minetest.register_craft({
	output = "vlf_lanterns:soul_lantern_floor",
	recipe = {
		{"vlf_core:iron_nugget", "vlf_core:iron_nugget"      , "vlf_core:iron_nugget"},
		{"vlf_core:iron_nugget", "vlf_blackstone:soul_torch" , "vlf_core:iron_nugget"},
		{"vlf_core:iron_nugget", "vlf_core:iron_nugget"      , "vlf_core:iron_nugget"},
	},
})
