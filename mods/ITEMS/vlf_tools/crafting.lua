minetest.register_craft({
	output = "vlf_tools:pick_wood",
	recipe = {
		{"group:wood", "group:wood", "group:wood"},
		{"", "vlf_core:stick", ""},
		{"", "vlf_core:stick", ""},
	}
})

minetest.register_craft({
	output = "vlf_tools:pick_stone",
	recipe = {
		{"group:cobble", "group:cobble", "group:cobble"},
		{"", "vlf_core:stick", ""},
		{"", "vlf_core:stick", ""},
	}
})

minetest.register_craft({
	output = "vlf_tools:pick_iron",
	recipe = {
		{"vlf_core:iron_ingot", "vlf_core:iron_ingot", "vlf_core:iron_ingot"},
		{"", "vlf_core:stick", ""},
		{"", "vlf_core:stick", ""},
	}
})

minetest.register_craft({
	output = "vlf_tools:pick_gold",
	recipe = {
		{"vlf_core:gold_ingot", "vlf_core:gold_ingot", "vlf_core:gold_ingot"},
		{"", "vlf_core:stick", ""},
		{"", "vlf_core:stick", ""},
	}
})

minetest.register_craft({
	output = "vlf_tools:pick_diamond",
	recipe = {
		{"vlf_core:diamond", "vlf_core:diamond", "vlf_core:diamond"},
		{"", "vlf_core:stick", ""},
		{"", "vlf_core:stick", ""},
	}
})

minetest.register_craft({
	output = "vlf_tools:shovel_wood",
	recipe = {
		{"group:wood"},
		{"vlf_core:stick"},
		{"vlf_core:stick"},
	}
})

minetest.register_craft({
	output = "vlf_tools:shovel_stone",
	recipe = {
		{"group:cobble"},
		{"vlf_core:stick"},
		{"vlf_core:stick"},
	}
})

minetest.register_craft({
	output = "vlf_tools:shovel_iron",
	recipe = {
		{"vlf_core:iron_ingot"},
		{"vlf_core:stick"},
		{"vlf_core:stick"},
	}
})

minetest.register_craft({
	output = "vlf_tools:shovel_gold",
	recipe = {
		{"vlf_core:gold_ingot"},
		{"vlf_core:stick"},
		{"vlf_core:stick"},
	}
})

minetest.register_craft({
	output = "vlf_tools:shovel_diamond",
	recipe = {
		{"vlf_core:diamond"},
		{"vlf_core:stick"},
		{"vlf_core:stick"},
	}
})

minetest.register_craft({
	output = "vlf_tools:axe_wood",
	recipe = {
		{"group:wood", "group:wood"},
		{"group:wood", "vlf_core:stick"},
		{"", "vlf_core:stick"},
	}
})
minetest.register_craft({
	output = "vlf_tools:axe_wood",
	recipe = {
		{"group:wood", "group:wood"},
		{"vlf_core:stick", "group:wood"},
		{"vlf_core:stick", ""},
	}
})

minetest.register_craft({
	output = "vlf_tools:axe_stone",
	recipe = {
		{"group:cobble", "group:cobble"},
		{"group:cobble", "vlf_core:stick"},
		{"", "vlf_core:stick"},
	}
})
minetest.register_craft({
	output = "vlf_tools:axe_stone",
	recipe = {
		{"group:cobble", "group:cobble"},
		{"vlf_core:stick", "group:cobble"},
		{"vlf_core:stick", ""},
	}
})

minetest.register_craft({
	output = "vlf_tools:axe_iron",
	recipe = {
		{"vlf_core:iron_ingot", "vlf_core:iron_ingot"},
		{"vlf_core:iron_ingot", "vlf_core:stick"},
		{"", "vlf_core:stick"},
	}
})
minetest.register_craft({
	output = "vlf_tools:axe_iron",
	recipe = {
		{"vlf_core:iron_ingot", "vlf_core:iron_ingot"},
		{"vlf_core:stick", "vlf_core:iron_ingot"},
		{"vlf_core:stick", ""},
	}
})

minetest.register_craft({
	output = "vlf_tools:axe_gold",
	recipe = {
		{"vlf_core:gold_ingot", "vlf_core:gold_ingot"},
		{"vlf_core:gold_ingot", "vlf_core:stick"},
		{"", "vlf_core:stick"},
	}
})
minetest.register_craft({
	output = "vlf_tools:axe_gold",
	recipe = {
		{"vlf_core:gold_ingot", "vlf_core:gold_ingot"},
		{"vlf_core:stick", "vlf_core:gold_ingot"},
		{"vlf_core:stick", ""},
	}
})

minetest.register_craft({
	output = "vlf_tools:axe_diamond",
	recipe = {
		{"vlf_core:diamond", "vlf_core:diamond"},
		{"vlf_core:diamond", "vlf_core:stick"},
		{"", "vlf_core:stick"},
	}
})
minetest.register_craft({
	output = "vlf_tools:axe_diamond",
	recipe = {
		{"vlf_core:diamond", "vlf_core:diamond"},
		{"vlf_core:stick", "vlf_core:diamond"},
		{"vlf_core:stick", ""},
	}
})

minetest.register_craft({
	output = "vlf_tools:sword_wood",
	recipe = {
		{"group:wood"},
		{"group:wood"},
		{"vlf_core:stick"},
	}
})

minetest.register_craft({
	output = "vlf_tools:sword_stone",
	recipe = {
		{"group:cobble"},
		{"group:cobble"},
		{"vlf_core:stick"},
	}
})

minetest.register_craft({
	output = "vlf_tools:sword_iron",
	recipe = {
		{"vlf_core:iron_ingot"},
		{"vlf_core:iron_ingot"},
		{"vlf_core:stick"},
	}
})

minetest.register_craft({
	output = "vlf_tools:sword_gold",
	recipe = {
		{"vlf_core:gold_ingot"},
		{"vlf_core:gold_ingot"},
		{"vlf_core:stick"},
	}
})

minetest.register_craft({
	output = "vlf_tools:sword_diamond",
	recipe = {
		{"vlf_core:diamond"},
		{"vlf_core:diamond"},
		{"vlf_core:stick"},
	}
})

minetest.register_craft({
	output = "vlf_tools:shears",
	recipe = {
		{ "vlf_core:iron_ingot", "" },
		{ "", "vlf_core:iron_ingot", },
	}
})
minetest.register_craft({
	output = "vlf_tools:shears",
	recipe = {
		{ "", "vlf_core:iron_ingot" },
		{ "vlf_core:iron_ingot", "" },
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "vlf_tools:pick_wood",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "vlf_tools:shovel_wood",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "vlf_tools:sword_wood",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "vlf_tools:axe_wood",
	burntime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlf_core:gold_nugget",
	recipe = "vlf_tools:sword_gold",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlf_core:gold_nugget",
	recipe = "vlf_tools:axe_gold",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlf_core:gold_nugget",
	recipe = "vlf_tools:shovel_gold",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlf_core:gold_nugget",
	recipe = "vlf_tools:pick_gold",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlf_core:iron_nugget",
	recipe = "vlf_tools:sword_iron",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlf_core:iron_nugget",
	recipe = "vlf_tools:axe_iron",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlf_core:iron_nugget",
	recipe = "vlf_tools:shovel_iron",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlf_core:iron_nugget",
	recipe = "vlf_tools:pick_iron",
	cooktime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "vlf_tools:pick_wood",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "vlf_tools:shovel_wood",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "vlf_tools:sword_wood",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "vlf_tools:axe_wood",
	burntime = 10,
})
