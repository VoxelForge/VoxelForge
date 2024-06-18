local S = minetest.get_translator("vlc_lanterns")

vlc_lanterns.register_lantern("lantern", {
	description = S("Lantern"),
	longdesc = S("Lanterns are light sources which can be placed on the top or the bottom of most blocks."),
	texture = "vlc_lanterns_lantern.png",
	texture_inv = "vlc_lanterns_lantern_inv.png",
	light_level = 14,
})

vlc_lanterns.register_lantern("soul_lantern", {
	description = S("Soul Lantern"),
	longdesc = S("Lanterns are light sources which can be placed on the top or the bottom of most blocks."),
	texture = "vlc_lanterns_soul_lantern.png",
	texture_inv = "vlc_lanterns_soul_lantern_inv.png",
	light_level = 10,
})

minetest.register_craft({
	output = "vlc_lanterns:lantern_floor",
	recipe = {
		{"vlc_core:iron_nugget", "vlc_core:iron_nugget", "vlc_core:iron_nugget"},
		{"vlc_core:iron_nugget", "vlc_torches:torch"   , "vlc_core:iron_nugget"},
		{"vlc_core:iron_nugget", "vlc_core:iron_nugget", "vlc_core:iron_nugget"},
	},
})

minetest.register_craft({
	output = "vlc_lanterns:soul_lantern_floor",
	recipe = {
		{"vlc_core:iron_nugget", "vlc_core:iron_nugget"      , "vlc_core:iron_nugget"},
		{"vlc_core:iron_nugget", "vlc_blackstone:soul_torch" , "vlc_core:iron_nugget"},
		{"vlc_core:iron_nugget", "vlc_core:iron_nugget"      , "vlc_core:iron_nugget"},
	},
})
