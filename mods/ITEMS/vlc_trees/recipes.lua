
minetest.register_craft({
	output = "vlc_trees:stick 4",
	recipe = {
		{"group:wood"},
		{"group:wood"},
	}
})

minetest.register_craft({
	output = "vlc_trees:paper 3",
	recipe = {
		{"vlc_trees:reeds", "vlc_trees:reeds", "vlc_trees:reeds"},
	}
})

minetest.register_craft({
	output = "vlc_trees:ladder 3",
	recipe = {
		{"vlc_trees:stick", "", "vlc_trees:stick"},
		{"vlc_trees:stick", "vlc_trees:stick", "vlc_trees:stick"},
		{"vlc_trees:stick", "", "vlc_trees:stick"},
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "group:tree",
	burntime = 15,
})

minetest.register_craft({
	type = "fuel",
	recipe = "group:bark",
	burntime = 15,
})

minetest.register_craft({
	type = "fuel",
	recipe = "vlc_trees:ladder",
	burntime = 15,
})

minetest.register_craft({
	type = "fuel",
	recipe = "group:wood",
	burntime = 15,
})

minetest.register_craft({
	type = "fuel",
	recipe = "group:sapling",
	burntime = 5,
})

minetest.register_craft({
	type = "fuel",
	recipe = "vlc_trees:bowl",
	burntime = 5,
})

minetest.register_craft({
	type = "fuel",
	recipe = "vlc_trees:stick",
	burntime = 5,
})

minetest.register_craft({
	type = "fuel",
	recipe = "group:bark_stairs",
	burntime = 15,
})

minetest.register_craft({
	type = "fuel",
	recipe = "group:bark_slab",
	burntime = 8,
})

minetest.register_craft({
	output = "vlc_trees:bowl 4",
	recipe = {
		{"group:wood", "", "group:wood"},
		{"", "group:wood", ""},
	}
})

minetest.register_craft({
	output = "vlc_trees:apple_gold",
	recipe = {
		{"vlc_stone:ingot_gold", "vlc_stone:ingot_gold", "vlc_stone:ingot_gold"},
		{"vlc_stone:ingot_gold", "vlc_trees:apple", "vlc_stone:ingot_gold"},
		{"vlc_stone:ingot_gold", "vlc_stone:ingot_gold", "vlc_stone:ingot_gold"},
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "vlc_trees:charcoal",
	burntime = 80,
})

minetest.register_craft({
	type = "cooking",
	output = "vlc_trees:charcoal",
	recipe = "group:tree",
	cooktime = 10,
})
