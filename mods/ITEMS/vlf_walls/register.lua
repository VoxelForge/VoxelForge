local S = minetest.get_translator(minetest.get_current_modname())

--vlf_walls.register_wall(nodename, description, source, tiles, inventory_image, groups, sounds, overrides)

vlf_walls.register_wall_def("vlf_walls:cobble",{
	source = "vlf_core:cobble",
	description = S("Cobblestone Wall"),
	tiles = {"vlf_walls_cobble_wall_top.png", "default_cobble.png", "vlf_walls_cobble_wall_side.png"},
	_vlf_stonecutter_recipes = { "vlf_core:cobble" },
})
vlf_walls.register_wall_def("vlf_walls:mossycobble", {
	source = "vlf_core:mossycobble",
	description = S("Mossy Cobblestone Wall"),
	tiles = {"vlf_walls_cobble_mossy_wall_top.png", "default_mossycobble.png", "vlf_walls_cobble_mossy_wall_side.png"},
	_vlf_stonecutter_recipes = { "vlf_core:mossycobble" },
})
vlf_walls.register_wall_def("vlf_walls:andesite", {
	description = S("Andesite Wall"),
	source = "vlf_core:andesite",
	_vlf_stonecutter_recipes = {"vlf_core:andesite"},
})
vlf_walls.register_wall_def("vlf_walls:granite", {
	description = S("Granite Wall"),
	source = "vlf_core:granite",
	_vlf_stonecutter_recipes = {"vlf_core:granite",},
})
vlf_walls.register_wall_def("vlf_walls:diorite", {
	description = S("Diorite Wall"),
	source = "vlf_core:diorite",
	_vlf_stonecutter_recipes = {"vlf_core:diorite",},
})
vlf_walls.register_wall_def("vlf_walls:brick", {
	description = S("Brick Wall"),
	source = "vlf_core:brick_block",
	_vlf_stonecutter_recipes = {"vlf_core:brick_block",},
})
vlf_walls.register_wall_def("vlf_walls:sandstone", {
	description = S("Sandstone Wall"),
	source = "vlf_core:sandstone",
	_vlf_stonecutter_recipes = {"vlf_core:sandstone",},
})
vlf_walls.register_wall_def("vlf_walls:redsandstone", {
	description = S("Red Sandstone Wall"),
	source = "vlf_core:redsandstone",
	_vlf_stonecutter_recipes = {"vlf_core:redsandstone",},
})
vlf_walls.register_wall_def("vlf_walls:stonebrick", {
	description = S("Stone Brick Wall"),
	source = "vlf_core:stonebrick",
	_vlf_stonecutter_recipes = {"vlf_core:stonebrick",},
})
vlf_walls.register_wall_def("vlf_walls:stonebrickmossy", {
	description = S("Mossy Stone Brick Wall"),
	source = "vlf_core:stonebrickmossy",
	_vlf_stonecutter_recipes = {"vlf_core:stonebrickmossy",},
})
vlf_walls.register_wall_def("vlf_walls:prismarine", {
	description = S("Prismarine Wall"),
	source = "vlf_ocean:prismarine",
	_vlf_stonecutter_recipes = {"vlf_ocean:prismarine",},
})
vlf_walls.register_wall_def("vlf_walls:endbricks", {
	description = S("End Stone Brick Wall"),
	source = "vlf_end:end_bricks",
	_vlf_stonecutter_recipes = {"vlf_end:end_bricks","vlf_end:end_stone"},
})
vlf_walls.register_wall_def("vlf_walls:netherbrick", {
	description = S("Nether Brick Wall"),
	source = "vlf_nether:nether_brick",
	_vlf_stonecutter_recipes = {"vlf_nether:nether_brick",},
})
vlf_walls.register_wall_def("vlf_walls:rednetherbrick", {
	description = S("Red Nether Brick Wall"),
	source = "vlf_nether:red_nether_brick",
	_vlf_stonecutter_recipes = {"vlf_nether:red_nether_brick",},
})
vlf_walls.register_wall_def("vlf_walls:mudbrick", {
	description = S("Mud Brick Wall"),
	source = "vlf_mud:mud_bricks",
	_vlf_stonecutter_recipes = {"vlf_mud:mud_bricks",},
})
