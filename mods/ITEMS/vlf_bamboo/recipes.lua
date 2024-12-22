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
