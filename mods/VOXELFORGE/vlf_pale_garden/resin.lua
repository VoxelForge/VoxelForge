local S = minetest.get_translator(minetest.get_current_modname())
minetest.register_node("vlf_pale_garden:resin_block", {
	description = S("Block of Resin"),
	tiles = {"resin_block.png"},
	groups = {handy=3, building_block=1, dig_by_piston=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 0.0,
	_mcl_hardness = 0.0,
})
minetest.register_node("vlf_pale_garden:resin_bricks", {
	description = S("Resin Bricks"),
	tiles = {"resin_bricks.png"},
	groups = {building_block=1, dig_by_piston=1, pickaxey=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 1.5,
})

minetest.register_node("vlf_pale_garden:chiseled_resin_bricks", {
	description = S("Chiseled Resin Bricks"),
	tiles = {"chiseled_resin_bricks.png"},
	groups = {building_block=1, dig_by_piston=1, pickaxey=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 1.5,
})

mcl_walls.register_wall_def("vlf_pale_garden:resinbrickwall",{
	source = "vlf_pale_garden:resin_bricks",
	description = S("Resin Brick Wall"),
	tiles = {"resin_bricks.png"},
	_mcl_stonecutter_recipes = { "vlf_pale_garden:resin_bricks" },
})

mcl_stairs.register_stair_and_slab("resin_bricks", {
	baseitem = "vlf_pale_garden:resin_bricks",
	description_stair = S("Resin Brick Stairs"),
	description_slab = S("Resin Brick Slab"),
	overrides = {_mcl_stonecutter_recipes = {"vlf_pale_garden:resin_bricks"}},
})
minetest.register_node("vlf_pale_garden:resin_clump", {
	description = S("Resin Clump"),
	tiles = {"resin_clump.png"},
	inventory_image = "resin_clump_inv.png",
	groups = {handy=3, building_block=1, dig_by_piston=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 0.0,
	_mcl_hardness = 0.0,
	paramtype = "light",
	sunlight_propagates = true,
	light_propagates = true,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16, -8/16, -8/16, 8/16, -7/16, 8/16},
		},
	},
	use_texture_alpha = "clip",
})
