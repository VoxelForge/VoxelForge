-- Nodes

local S = minetest.get_translator(minetest.get_current_modname())

minetest.register_node("vlc_ocean:sea_lantern", {
	description = S("Sea Lantern"),
	_doc_items_longdesc = S("Sea lanterns are decorative light sources which look great underwater but can be placed anywhere."),
	paramtype2 = "facedir",
	is_ground_content = false,
	light_source = minetest.LIGHT_MAX,
	drop = {
		max_items = 1,
		items = {
			{ items = {"vlc_ocean:prismarine_crystals 3"}, rarity = 2 },
			{ items = {"vlc_ocean:prismarine_crystals 2"}}
		}
	},
	tiles = {{name="vlc_ocean_sea_lantern.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=1.25}}},
	groups = {handy=1, building_block=1, material_glass=1},
	sounds = vlc_sounds.node_sound_glass_defaults(),
	_vlc_blast_resistance = 0.3,
	_vlc_hardness = 0.3,
	_vlc_silk_touch_drop = true,
	_vlc_fortune_drop = {
		discrete_uniform_distribution = true,
		items = {"vlc_ocean:prismarine_crystals"},
		min_count = 2,
		max_count = 3,
		cap = 5,
	}
})

minetest.register_node("vlc_ocean:prismarine", {
	description = S("Prismarine"),
	_doc_items_longdesc = S("Prismarine is used as a building block. It slowly changes its color."),
	is_ground_content = false,
	-- Texture should have 22 frames for smooth transitions.
	tiles = {{name="vlc_ocean_prismarine_anim.png", animation={type="vertical_frames", aspect_w=32, aspect_h=32, length=45.0}}},
	groups = {pickaxey=1, building_block=1, material_stone=1, stonecuttable = 1},
	sounds = vlc_sounds.node_sound_stone_defaults(),
	_vlc_blast_resistance = 6,
	_vlc_hardness = 1.5,
})

minetest.register_node("vlc_ocean:prismarine_brick", {
	description = S("Prismarine Bricks"),
	_doc_items_longdesc = doc.sub.items.temp.build,
	is_ground_content = false,
	tiles = {"vlc_ocean_prismarine_bricks.png"},
	groups = {pickaxey=1, building_block=1, material_stone=1, stonecuttable = 1},
	sounds = vlc_sounds.node_sound_stone_defaults(),
	_vlc_blast_resistance = 1.5,
	_vlc_hardness = 1.5,
})

minetest.register_node("vlc_ocean:prismarine_dark", {
	description = S("Dark Prismarine"),
	_doc_items_longdesc = doc.sub.items.temp.build,
	is_ground_content = false,
	tiles = {"vlc_ocean_prismarine_dark.png"},
	groups = {pickaxey=1, building_block=1, material_stone=1, stonecuttable = 1},
	sounds = vlc_sounds.node_sound_stone_defaults(),
	_vlc_blast_resistance = 1.5,
	_vlc_hardness = 1.5,
})

vlc_stairs.register_stair_and_slab("prismarine", {
	baseitem = "vlc_ocean:prismarine",
	description_stair = S("Prismarine Stairs"),
	description_slab = S("Prismarine Slab"),
	overrides = {_vlc_stonecutter_recipes = { "vlc_ocean:prismarine" }},{_vlc_stonecutter_recipes = { "vlc_ocean:prismarine" }}
})
vlc_stairs.register_stair_and_slab("prismarine_brick", {
	baseitem = "vlc_ocean:prismarine_brick",
	description_stair = S("Prismarine Brick Stairs"),
	description_slab = S("Prismarine Brick Slab"),
	overrides = {_vlc_stonecutter_recipes = { "vlc_ocean:prismarine_brick" }},{_vlc_stonecutter_recipes = { "vlc_ocean:prismarine_brick" }}
})
vlc_stairs.register_stair_and_slab("prismarine_dark", {
	baseitem = "vlc_ocean:prismarine_dark",
	description_stair = S("Dark Prismarine Stairs"),
	description_slab = S("Dark Prismarine Slab"),
	overrides = {_vlc_stonecutter_recipes = { "vlc_ocean:prismarine_dark" }},{_vlc_stonecutter_recipes = { "vlc_ocean:prismarine_dark" }}
})

-- Craftitems

minetest.register_craftitem("vlc_ocean:prismarine_crystals", {
	description = S("Prismarine Crystals"),
	_doc_items_longdesc = doc.sub.items.temp.craftitem,
	inventory_image = "vlc_ocean_prismarine_crystals.png",
	groups = { craftitem = 1 },
})

minetest.register_craftitem("vlc_ocean:prismarine_shard", {
	description = S("Prismarine Shard"),
	_doc_items_longdesc = doc.sub.items.temp.craftitem,
	inventory_image = "vlc_ocean_prismarine_shard.png",
	groups = { craftitem = 1 },
})

-- Crafting

minetest.register_craft({
	output = "vlc_ocean:sea_lantern",
	recipe = {
		{"vlc_ocean:prismarine_shard", "vlc_ocean:prismarine_crystals", "vlc_ocean:prismarine_shard"},
		{"vlc_ocean:prismarine_crystals", "vlc_ocean:prismarine_crystals", "vlc_ocean:prismarine_crystals"},
		{"vlc_ocean:prismarine_shard", "vlc_ocean:prismarine_crystals", "vlc_ocean:prismarine_shard"},
	}
})

minetest.register_craft({
	output = "vlc_ocean:prismarine",
	recipe = {
		{"vlc_ocean:prismarine_shard", "vlc_ocean:prismarine_shard"},
		{"vlc_ocean:prismarine_shard", "vlc_ocean:prismarine_shard"},
	}
})

minetest.register_craft({
	output = "vlc_ocean:prismarine_brick",
	recipe = {
		{"vlc_ocean:prismarine_shard", "vlc_ocean:prismarine_shard", "vlc_ocean:prismarine_shard"},
		{"vlc_ocean:prismarine_shard", "vlc_ocean:prismarine_shard", "vlc_ocean:prismarine_shard"},
		{"vlc_ocean:prismarine_shard", "vlc_ocean:prismarine_shard", "vlc_ocean:prismarine_shard"},
	}
})

minetest.register_craft({
	output = "vlc_ocean:prismarine_dark",
	recipe = {
		{"vlc_ocean:prismarine_shard", "vlc_ocean:prismarine_shard", "vlc_ocean:prismarine_shard"},
		{"vlc_ocean:prismarine_shard", "vlc_dyes:black", "vlc_ocean:prismarine_shard"},
		{"vlc_ocean:prismarine_shard", "vlc_ocean:prismarine_shard", "vlc_ocean:prismarine_shard"},
	}
})

