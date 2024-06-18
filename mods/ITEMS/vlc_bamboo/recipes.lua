--- Originally created by michieal.
-- These are just the recipes specific to bamboo now. The usual wood stuff is registered by vlc_trees


minetest.register_craft({
	output = "vlc_core:stick",
	recipe = {
		{"vlc_bamboo:bamboo"},
		{"vlc_bamboo:bamboo"},
	}
})

minetest.register_craft({
	output = "vlc_trees:tree_bamboo",
	recipe = {
		{"group:bamboo_tree","group:bamboo_tree","group:bamboo_tree"},
		{"group:bamboo_tree","group:bamboo_tree","group:bamboo_tree"},
		{"group:bamboo_tree","group:bamboo_tree","group:bamboo_tree"},
	}
})

minetest.register_craft({
	output = "vlc_trees:wood_bamboo",
	recipe = {
		{"group:bamboo_tree","group:bamboo_tree"},
		{"group:bamboo_tree","group:bamboo_tree"},
	}
})

minetest.register_craft({
	output = "vlc_bamboo:scaffolding 6",
	recipe = {{"group:bamboo_tree", "vlc_mobitems:string", "group:bamboo_tree"},
			 {"group:bamboo_tree", "", "group:bamboo_tree"},
			 {"group:bamboo_tree", "", "group:bamboo_tree"}}
})

minetest.register_craft({
	type = "fuel",
	recipe = "vlc_bamboo:scaffolding",
	burntime = 20
})

minetest.register_craft({
	type = "fuel",
	recipe = "vlc_bamboo:bamboo",
	burntime = 2.5,
})

minetest.register_craft({
	type = "fuel",
	recipe = "vlc_bamboo:bamboo_mosaic",
	burntime = 7.5,
})

minetest.register_craft({
	type = "fuel",
	recipe = "vlc_stairs:slab_bamboo_mosaic",
	burntime = 7.5,
})
minetest.register_craft({
	type = "fuel",
	recipe = "vlc_stairs:stair_bamboo_mosaic",
	burntime = 15,
})
