-- mods/default/crafting.lua

--
-- Crafting definition
--

minetest.register_craft({
	type = "shapeless",
	output = "mcl_core:mossycobble",
	recipe = { "mcl_core:cobble", "mcl_core:vine" },
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_core:stonebrickmossy",
	recipe = { "mcl_core:stonebrick", "mcl_core:vine" },
})

minetest.register_craft({
	output = "mcl_core:coarse_dirt 4",
	recipe = {
		{"mcl_core:dirt", "mcl_core:gravel"},
		{"mcl_core:gravel", "mcl_core:dirt"},
	}
})
minetest.register_craft({
	output = "mcl_core:coarse_dirt 4",
	recipe = {
		{"mcl_core:gravel", "mcl_core:dirt"},
		{"mcl_core:dirt", "mcl_core:gravel"},
	}
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_core:granite",
	recipe = {"mcl_core:diorite", "mcl_nether:quartz"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_core:andesite 2",
	recipe = {"mcl_core:diorite", "mcl_core:cobble"},
})

minetest.register_craft({
	output = "mcl_core:diorite 2",
	recipe = {
		{"mcl_core:cobble", "mcl_nether:quartz"},
		{"mcl_nether:quartz", "mcl_core:cobble"},
	}
})
minetest.register_craft({
	output = "mcl_core:diorite 2",
	recipe = {
		{"mcl_nether:quartz", "mcl_core:cobble"},
		{"mcl_core:cobble", "mcl_nether:quartz"},
	}
})

minetest.register_craft({
	output = "mcl_core:stick 4",
	recipe = {
		{"group:wood"},
		{"group:wood"},
	}
})

minetest.register_craft({
	output = "mcl_core:ladder 3",
	recipe = {
		{"mcl_core:stick", "", "mcl_core:stick"},
		{"mcl_core:stick", "mcl_core:stick", "mcl_core:stick"},
		{"mcl_core:stick", "", "mcl_core:stick"},
	}
})

minetest.register_craft({
	output = "mcl_core:apple_gold",
	recipe = {
		{"mcl_core:gold_ingot", "mcl_core:gold_ingot", "mcl_core:gold_ingot"},
		{"mcl_core:gold_ingot", "mcl_core:apple", "mcl_core:gold_ingot"},
		{"mcl_core:gold_ingot", "mcl_core:gold_ingot", "mcl_core:gold_ingot"},
	}
})

minetest.register_craft({
	output = "mcl_core:bowl 4",
	recipe = {
		{"group:wood", "", "group:wood"},
		{"", "group:wood", ""},
	}
})

minetest.register_craft({
	output = "mcl_core:snowblock",
	recipe = {
		{"mcl_throwing:snowball", "mcl_throwing:snowball"},
		{"mcl_throwing:snowball", "mcl_throwing:snowball"},
	}
})

minetest.register_craft({
	output = "mcl_core:snow 6",
	recipe = {
		{"mcl_core:snowblock", "mcl_core:snowblock", "mcl_core:snowblock"},
	}
})
--
-- Crafting (tool repair)
--
minetest.register_craft({
	type = "toolrepair",
	additional_wear = -mcl_core.repair,
})
