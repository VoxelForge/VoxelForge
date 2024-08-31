--- Originally created by michieal.
-- These are just the recipes specific to bamboo now. The usual wood stuff is registered by vlf_trees


minetest.register_craft({
	output = "vlf_core:stick",
	recipe = {
		{"vlf_bamboo:bamboo"},
		{"vlf_bamboo:bamboo"},
	}
})

minetest.register_craft({
	output = "vlf_trees:tree_bamboo",
	recipe = {
		{"group:bamboo_tree","group:bamboo_tree","group:bamboo_tree"},
		{"group:bamboo_tree","group:bamboo_tree","group:bamboo_tree"},
		{"group:bamboo_tree","group:bamboo_tree","group:bamboo_tree"},
	}
})

minetest.register_craft({
	output = "vlf_trees:wood_bamboo",
	recipe = {
		{"group:bamboo_tree","group:bamboo_tree"},
		{"group:bamboo_tree","group:bamboo_tree"},
	}
})

minetest.register_craft({
	output = "vlf_bamboo:scaffolding 6",
	recipe = {{"group:bamboo_tree", "vlf_mobitems:string", "group:bamboo_tree"},
			 {"group:bamboo_tree", "", "group:bamboo_tree"},
			 {"group:bamboo_tree", "", "group:bamboo_tree"}}
})

minetest.register_craft({
	type = "fuel",
	recipe = "vlf_bamboo:scaffolding",
	burntime = 20
})

minetest.register_craft({
	type = "fuel",
	recipe = "vlf_bamboo:bamboo",
	burntime = 2.5,
})

minetest.register_craft({
	type = "fuel",
	recipe = "vlf_bamboo:bamboo_mosaic",
	burntime = 7.5,
})

minetest.register_craft({
	type = "fuel",
	recipe = "vlf_stairs:slab_bamboo_mosaic",
	burntime = 7.5,
})
minetest.register_craft({
	type = "fuel",
	recipe = "vlf_stairs:stair_bamboo_mosaic",
	burntime = 15,
})
