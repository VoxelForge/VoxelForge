
minetest.register_craft({
	output = "vlf_trees:stick 4",
	recipe = {
		{"group:wood"},
		{"group:wood"},
	}
})

minetest.register_craft({
	output = "vlf_trees:paper 3",
	recipe = {
		{"vlf_trees:reeds", "vlf_trees:reeds", "vlf_trees:reeds"},
	}
})

minetest.register_craft({
	output = "vlf_trees:ladder 3",
	recipe = {
		{"vlf_trees:stick", "", "vlf_trees:stick"},
		{"vlf_trees:stick", "vlf_trees:stick", "vlf_trees:stick"},
		{"vlf_trees:stick", "", "vlf_trees:stick"},
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
	recipe = "vlf_trees:ladder",
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
	recipe = "vlf_trees:bowl",
	burntime = 5,
})

minetest.register_craft({
	type = "fuel",
	recipe = "vlf_trees:stick",
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
	output = "vlf_trees:bowl 4",
	recipe = {
		{"group:wood", "", "group:wood"},
		{"", "group:wood", ""},
	}
})

minetest.register_craft({
	output = "vlf_trees:apple_gold",
	recipe = {
		{"vlf_stone:ingot_gold", "vlf_stone:ingot_gold", "vlf_stone:ingot_gold"},
		{"vlf_stone:ingot_gold", "vlf_trees:apple", "vlf_stone:ingot_gold"},
		{"vlf_stone:ingot_gold", "vlf_stone:ingot_gold", "vlf_stone:ingot_gold"},
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "vlf_trees:charcoal",
	burntime = 80,
})

minetest.register_craft({
	type = "cooking",
	output = "vlf_trees:charcoal",
	recipe = "group:tree",
	cooktime = 10,
})
