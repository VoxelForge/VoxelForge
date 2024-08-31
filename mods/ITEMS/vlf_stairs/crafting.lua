minetest.register_craft({
	output = "vlf_core:sandstonecarved",
	recipe = {
		{"vlf_stairs:slab_sandstone"},
		{"vlf_stairs:slab_sandstone"}
	}
})

minetest.register_craft({
	output = "vlf_core:redsandstonecarved",
	recipe = {
		{"vlf_stairs:slab_redsandstone"},
		{"vlf_stairs:slab_redsandstone"}
	}
})

minetest.register_craft({
	output = "vlf_core:stonebrickcarved",
	recipe = {
		{"vlf_stairs:slab_stonebrick"},
		{"vlf_stairs:slab_stonebrick"}
	}
})

minetest.register_craft({
	output = "vlf_end:purpur_pillar",
	recipe = {
		{"vlf_stairs:slab_purpur_block"},
		{"vlf_stairs:slab_purpur_block"}
	}
})

minetest.register_craft({
	output = "vlf_nether:quartz_chiseled 2",
	recipe = {
		{"vlf_stairs:slab_quartzblock"},
		{"vlf_stairs:slab_quartzblock"},
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

