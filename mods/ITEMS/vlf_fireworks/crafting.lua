minetest.register_craft({
	type = "shapeless",
	output = "vlf_fireworks:rocket_1 3",
	recipe = {"vlf_core:paper", "vlf_mobitems:gunpowder"},
})

minetest.register_craft({
	type = "shapeless",
	output = "vlf_fireworks:rocket_2 3",
	recipe = {"vlf_core:paper", "vlf_mobitems:gunpowder", "vlf_mobitems:gunpowder"},
})

minetest.register_craft({
	type = "shapeless",
	output = "vlf_fireworks:rocket_3 3",
	recipe = {"vlf_core:paper", "vlf_mobitems:gunpowder", "vlf_mobitems:gunpowder", "vlf_mobitems:gunpowder"},
})