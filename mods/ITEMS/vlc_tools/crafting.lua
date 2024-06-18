minetest.register_craft({
	output = "vlc_tools:pick_wood",
	recipe = {
		{"group:wood", "group:wood", "group:wood"},
		{"", "vlc_core:stick", ""},
		{"", "vlc_core:stick", ""},
	}
})

minetest.register_craft({
	output = "vlc_tools:pick_stone",
	recipe = {
		{"group:cobble", "group:cobble", "group:cobble"},
		{"", "vlc_core:stick", ""},
		{"", "vlc_core:stick", ""},
	}
})

minetest.register_craft({
	output = "vlc_tools:pick_iron",
	recipe = {
		{"vlc_core:iron_ingot", "vlc_core:iron_ingot", "vlc_core:iron_ingot"},
		{"", "vlc_core:stick", ""},
		{"", "vlc_core:stick", ""},
	}
})

minetest.register_craft({
	output = "vlc_tools:pick_gold",
	recipe = {
		{"vlc_core:gold_ingot", "vlc_core:gold_ingot", "vlc_core:gold_ingot"},
		{"", "vlc_core:stick", ""},
		{"", "vlc_core:stick", ""},
	}
})

minetest.register_craft({
	output = "vlc_tools:pick_diamond",
	recipe = {
		{"vlc_core:diamond", "vlc_core:diamond", "vlc_core:diamond"},
		{"", "vlc_core:stick", ""},
		{"", "vlc_core:stick", ""},
	}
})

minetest.register_craft({
	output = "vlc_tools:shovel_wood",
	recipe = {
		{"group:wood"},
		{"vlc_core:stick"},
		{"vlc_core:stick"},
	}
})

minetest.register_craft({
	output = "vlc_tools:shovel_stone",
	recipe = {
		{"group:cobble"},
		{"vlc_core:stick"},
		{"vlc_core:stick"},
	}
})

minetest.register_craft({
	output = "vlc_tools:shovel_iron",
	recipe = {
		{"vlc_core:iron_ingot"},
		{"vlc_core:stick"},
		{"vlc_core:stick"},
	}
})

minetest.register_craft({
	output = "vlc_tools:shovel_gold",
	recipe = {
		{"vlc_core:gold_ingot"},
		{"vlc_core:stick"},
		{"vlc_core:stick"},
	}
})

minetest.register_craft({
	output = "vlc_tools:shovel_diamond",
	recipe = {
		{"vlc_core:diamond"},
		{"vlc_core:stick"},
		{"vlc_core:stick"},
	}
})

minetest.register_craft({
	output = "vlc_tools:axe_wood",
	recipe = {
		{"group:wood", "group:wood"},
		{"group:wood", "vlc_core:stick"},
		{"", "vlc_core:stick"},
	}
})
minetest.register_craft({
	output = "vlc_tools:axe_wood",
	recipe = {
		{"group:wood", "group:wood"},
		{"vlc_core:stick", "group:wood"},
		{"vlc_core:stick", ""},
	}
})

minetest.register_craft({
	output = "vlc_tools:axe_stone",
	recipe = {
		{"group:cobble", "group:cobble"},
		{"group:cobble", "vlc_core:stick"},
		{"", "vlc_core:stick"},
	}
})
minetest.register_craft({
	output = "vlc_tools:axe_stone",
	recipe = {
		{"group:cobble", "group:cobble"},
		{"vlc_core:stick", "group:cobble"},
		{"vlc_core:stick", ""},
	}
})

minetest.register_craft({
	output = "vlc_tools:axe_iron",
	recipe = {
		{"vlc_core:iron_ingot", "vlc_core:iron_ingot"},
		{"vlc_core:iron_ingot", "vlc_core:stick"},
		{"", "vlc_core:stick"},
	}
})
minetest.register_craft({
	output = "vlc_tools:axe_iron",
	recipe = {
		{"vlc_core:iron_ingot", "vlc_core:iron_ingot"},
		{"vlc_core:stick", "vlc_core:iron_ingot"},
		{"vlc_core:stick", ""},
	}
})

minetest.register_craft({
	output = "vlc_tools:axe_gold",
	recipe = {
		{"vlc_core:gold_ingot", "vlc_core:gold_ingot"},
		{"vlc_core:gold_ingot", "vlc_core:stick"},
		{"", "vlc_core:stick"},
	}
})
minetest.register_craft({
	output = "vlc_tools:axe_gold",
	recipe = {
		{"vlc_core:gold_ingot", "vlc_core:gold_ingot"},
		{"vlc_core:stick", "vlc_core:gold_ingot"},
		{"vlc_core:stick", ""},
	}
})

minetest.register_craft({
	output = "vlc_tools:axe_diamond",
	recipe = {
		{"vlc_core:diamond", "vlc_core:diamond"},
		{"vlc_core:diamond", "vlc_core:stick"},
		{"", "vlc_core:stick"},
	}
})
minetest.register_craft({
	output = "vlc_tools:axe_diamond",
	recipe = {
		{"vlc_core:diamond", "vlc_core:diamond"},
		{"vlc_core:stick", "vlc_core:diamond"},
		{"vlc_core:stick", ""},
	}
})

minetest.register_craft({
	output = "vlc_tools:sword_wood",
	recipe = {
		{"group:wood"},
		{"group:wood"},
		{"vlc_core:stick"},
	}
})

minetest.register_craft({
	output = "vlc_tools:sword_stone",
	recipe = {
		{"group:cobble"},
		{"group:cobble"},
		{"vlc_core:stick"},
	}
})

minetest.register_craft({
	output = "vlc_tools:sword_iron",
	recipe = {
		{"vlc_core:iron_ingot"},
		{"vlc_core:iron_ingot"},
		{"vlc_core:stick"},
	}
})

minetest.register_craft({
	output = "vlc_tools:sword_gold",
	recipe = {
		{"vlc_core:gold_ingot"},
		{"vlc_core:gold_ingot"},
		{"vlc_core:stick"},
	}
})

minetest.register_craft({
	output = "vlc_tools:sword_diamond",
	recipe = {
		{"vlc_core:diamond"},
		{"vlc_core:diamond"},
		{"vlc_core:stick"},
	}
})

minetest.register_craft({
	output = "vlc_tools:shears",
	recipe = {
		{ "vlc_core:iron_ingot", "" },
		{ "", "vlc_core:iron_ingot", },
	}
})
minetest.register_craft({
	output = "vlc_tools:shears",
	recipe = {
		{ "", "vlc_core:iron_ingot" },
		{ "vlc_core:iron_ingot", "" },
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "vlc_tools:pick_wood",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "vlc_tools:shovel_wood",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "vlc_tools:sword_wood",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "vlc_tools:axe_wood",
	burntime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlc_core:gold_nugget",
	recipe = "vlc_tools:sword_gold",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlc_core:gold_nugget",
	recipe = "vlc_tools:axe_gold",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlc_core:gold_nugget",
	recipe = "vlc_tools:shovel_gold",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlc_core:gold_nugget",
	recipe = "vlc_tools:pick_gold",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlc_core:iron_nugget",
	recipe = "vlc_tools:sword_iron",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlc_core:iron_nugget",
	recipe = "vlc_tools:axe_iron",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlc_core:iron_nugget",
	recipe = "vlc_tools:shovel_iron",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlc_core:iron_nugget",
	recipe = "vlc_tools:pick_iron",
	cooktime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "vlc_tools:pick_wood",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "vlc_tools:shovel_wood",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "vlc_tools:sword_wood",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "vlc_tools:axe_wood",
	burntime = 10,
})
