minetest.register_craft({
	output = "vlc_core:sandstonecarved",
	recipe = {
		{"vlc_stairs:slab_sandstone"},
		{"vlc_stairs:slab_sandstone"}
	}
})

minetest.register_craft({
	output = "vlc_core:redsandstonecarved",
	recipe = {
		{"vlc_stairs:slab_redsandstone"},
		{"vlc_stairs:slab_redsandstone"}
	}
})

minetest.register_craft({
	output = "vlc_core:stonebrickcarved",
	recipe = {
		{"vlc_stairs:slab_stonebrick"},
		{"vlc_stairs:slab_stonebrick"}
	}
})

minetest.register_craft({
	output = "vlc_end:purpur_pillar",
	recipe = {
		{"vlc_stairs:slab_purpur_block"},
		{"vlc_stairs:slab_purpur_block"}
	}
})

minetest.register_craft({
	output = "vlc_nether:quartz_chiseled 2",
	recipe = {
		{"vlc_stairs:slab_quartzblock"},
		{"vlc_stairs:slab_quartzblock"},
	}
})

-- Fuel
minetest.register_craft({
	type = "fuel",
	recipe = "group:wood_stairs",
	burntime = 15,
})
minetest.register_craft({
	type = "fuel",
	recipe = "group:wood_slab",
	-- Original burn time: 7.5 (PC edition)
	burntime = 8,
})

