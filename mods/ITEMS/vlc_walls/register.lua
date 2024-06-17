local S = minetest.get_translator(minetest.get_current_modname())

--vlc_walls.register_wall(nodename, description, source, tiles, inventory_image, groups, sounds, overrides)

vlc_walls.register_wall_def("vlc_walls:cobble",{
	source = "vlc_core:cobble",
	description = S("Cobblestone Wall"),
	tiles = {"vlc_walls_cobble_wall_top.png", "default_cobble.png", "vlc_walls_cobble_wall_side.png"},
	_vlc_stonecutter_recipes = { "vlc_core:cobble" },
})
vlc_walls.register_wall_def("vlc_walls:mossycobble", {
	source = "vlc_core:mossycobble",
	description = S("Mossy Cobblestone Wall"),
	tiles = {"vlc_walls_cobble_mossy_wall_top.png", "default_mossycobble.png", "vlc_walls_cobble_mossy_wall_side.png"},
	_vlc_stonecutter_recipes = { "vlc_core:mossycobble" },
})
vlc_walls.register_wall_def("vlc_walls:andesite", {
	description = S("Andesite Wall"),
	source = "vlc_core:andesite",
	_vlc_stonecutter_recipes = {"vlc_core:andesite"},
})
vlc_walls.register_wall_def("vlc_walls:granite", {
	description = S("Granite Wall"),
	source = "vlc_core:granite",
	_vlc_stonecutter_recipes = {"vlc_core:granite",},
})
vlc_walls.register_wall_def("vlc_walls:diorite", {
	description = S("Diorite Wall"),
	source = "vlc_core:diorite",
	_vlc_stonecutter_recipes = {"vlc_core:diorite",},
})
vlc_walls.register_wall_def("vlc_walls:brick", {
	description = S("Brick Wall"),
	source = "vlc_core:brick_block",
	_vlc_stonecutter_recipes = {"vlc_core:brick_block",},
})
vlc_walls.register_wall_def("vlc_walls:sandstone", {
	description = S("Sandstone Wall"),
	source = "vlc_core:sandstone",
	_vlc_stonecutter_recipes = {"vlc_core:sandstone",},
})
vlc_walls.register_wall_def("vlc_walls:redsandstone", {
	description = S("Red Sandstone Wall"),
	source = "vlc_core:redsandstone",
	_vlc_stonecutter_recipes = {"vlc_core:redsandstone",},
})
vlc_walls.register_wall_def("vlc_walls:stonebrick", {
	description = S("Stone Brick Wall"),
	source = "vlc_core:stonebrick",
	_vlc_stonecutter_recipes = {"vlc_core:stonebrick",},
})
vlc_walls.register_wall_def("vlc_walls:stonebrickmossy", {
	description = S("Mossy Stone Brick Wall"),
	source = "vlc_core:stonebrickmossy",
	_vlc_stonecutter_recipes = {"vlc_core:stonebrickmossy",},
})
vlc_walls.register_wall_def("vlc_walls:prismarine", {
	description = S("Prismarine Wall"),
	source = "vlc_ocean:prismarine",
	_vlc_stonecutter_recipes = {"vlc_ocean:prismarine",},
})
vlc_walls.register_wall_def("vlc_walls:endbricks", {
	description = S("End Stone Brick Wall"),
	source = "vlc_end:end_bricks",
	_vlc_stonecutter_recipes = {"vlc_end:end_bricks","vlc_end:end_stone"},
})
vlc_walls.register_wall_def("vlc_walls:netherbrick", {
	description = S("Nether Brick Wall"),
	source = "vlc_nether:nether_brick",
	_vlc_stonecutter_recipes = {"vlc_nether:nether_brick",},
})
vlc_walls.register_wall_def("vlc_walls:rednetherbrick", {
	description = S("Red Nether Brick Wall"),
	source = "vlc_nether:red_nether_brick",
	_vlc_stonecutter_recipes = {"vlc_nether:red_nether_brick",},
})
vlc_walls.register_wall_def("vlc_walls:mudbrick", {
	description = S("Mud Brick Wall"),
	source = "vlc_mud:mud_bricks",
	_vlc_stonecutter_recipes = {"vlc_mud:mud_bricks",},
})
