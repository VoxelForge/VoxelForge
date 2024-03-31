local S = minetest.get_translator(minetest.get_current_modname())

mcl_flowers.register_simple_flower("poppy", {
	desc = S("Poppy"),
	image = "mcl_flowers_poppy.png",
	selection_box = { -5/16, -0.5, -5/16, 5/16, 5/16, 5/16 },
	potted = true,
})
mcl_flowers.register_simple_flower("dandelion", {
	desc = S("Dandelion"),
	image = "flowers_dandelion_yellow.png",
	selection_box = { -4/16, -0.5, -4/16, 4/16, 3/16, 4/16 },
	potted = true,
})
mcl_flowers.register_simple_flower("oxeye_daisy", {
	desc = S("Oxeye Daisy"),
	image = "mcl_flowers_oxeye_daisy.png",
	selection_box = { -4/16, -0.5, -4/16, 4/16, 4/16, 4/16 },
	potted = true,
})
mcl_flowers.register_simple_flower("tulip_orange", {
	desc = S("Orange Tulip"),
	image = "flowers_tulip.png",
	selection_box = { -3/16, -0.5, -3/16, 3/16, 5/16, 3/16 },
	potted = true,
})
mcl_flowers.register_simple_flower("tulip_pink", {
	desc = S("Pink Tulip"),
	image = "mcl_flowers_tulip_pink.png",
	selection_box = { -3/16, -0.5, -3/16, 3/16, 5/16, 3/16 },
	potted = true,
})
mcl_flowers.register_simple_flower("tulip_red", {
	desc = S("Red Tulip"),
	image = "mcl_flowers_tulip_red.png",
	selection_box = { -3/16, -0.5, -3/16, 3/16, 6/16, 3/16 },
	potted = true,
})
mcl_flowers.register_simple_flower("tulip_white", {
	desc = S("White Tulip"),
	image = "mcl_flowers_tulip_white.png",
	selection_box = { -3/16, -0.5, -3/16, 3/16, 4/16, 3/16 },
	potted = true,
})
mcl_flowers.register_simple_flower("allium", {
	desc = S("Allium"),
	image = "mcl_flowers_allium.png",
	selection_box = { -3/16, -0.5, -3/16, 3/16, 6/16, 3/16 },
	potted = true,
})
mcl_flowers.register_simple_flower("azure_bluet", {
	desc = S("Azure Bluet"),
	image = "mcl_flowers_azure_bluet.png",
	selection_box = { -5/16, -0.5, -5/16, 5/16, 3/16, 5/16 },
	potted = true,
})
mcl_flowers.register_simple_flower("blue_orchid", {
	desc = S("Blue Orchid"),
	image = "mcl_flowers_blue_orchid.png",
	selection_box = { -5/16, -0.5, -5/16, 5/16, 7/16, 5/16 },
	potted = true,
})
mcl_flowers.register_simple_flower("wither_rose", {
	desc = S("Wither Rose"),
	image = "mcl_flowers_wither_rose.png",
	selection_box = { -3/16, -0.5, -3/16, 3/16, 6/16, 3/16 },
	potted = true,
})
mcl_flowers.register_simple_flower("lily_of_the_valley", {
	desc = S("Lily of the Valley"),
	image = "mcl_flowers_lily_of_the_valley.png",
	selection_box = { -5/16, -0.5, -5/16, 4/16, 5/16, 5/16 },
	potted = true,
})
mcl_flowers.register_simple_flower("cornflower", {
	desc = S("Cornflower"),
	image = "mcl_flowers_cornflower.png",
	selection_box = { -4/16, -0.5, -4/16, 4/16, 3/16, 4/16 },
	potted = true,
})

mcl_flowers.add_large_plant("peony", {
--desc, longdesc, bottom_img, top_img, inv_img, selbox_radius, selbox_top_height, drop, shears_drop, is_flower, grass_color, fortune_drop, mesh)
	bottom = {
		description = S("Peony"),
		_doc_items_longdesc = S("A peony is a large plant which occupies two blocks. It is mainly used in dye production."),
		tiles = { "mcl_flowers_double_plant_paeonia_bottom.png" },
	},
	tiles_top = { "mcl_flowers_double_plant_paeonia_top.png" },
	selbox_radius = 5/16,
	selbox_top_height = 6/16,
	is_flower = true,
})


mcl_flowers.add_large_plant("rose_bush", {
	bottom = {
		description = S("Rose Bush"),
		_doc_items_longdesc = S("A rose bush is a large plant which occupies two blocks. It is safe to touch it. Rose bushes are mainly used in dye production."),
		tiles = { "mcl_flowers_double_plant_rose_bottom.png" },
	},
	tiles_top = { "mcl_flowers_double_plant_rose_top.png" },
	selbox_radius = 5/16,
	selbox_top_height = 1/16,
	is_flower = true,
})

mcl_flowers.add_large_plant("lilac", {
	bottom = {
		description = S("Lilac"),
		_doc_items_longdesc = S("A lilac is a large plant which occupies two blocks. It is mainly used in dye production."),
		tiles = { "mcl_flowers_double_plant_syringa_bottom.png" },
	},
	tiles_top = { "mcl_flowers_double_plant_syringa_top.png" },
	selbox_radius = 5/16,
	selbox_top_height = 6/16,
	is_flower = true,
})

mcl_flowers.add_large_plant("sunflower", {
	bottom = {
		description = S("Sunflower"),
		_doc_items_longdesc = S("A sunflower is a large plant which occupies two blocks. It is mainly used in dye production."),
		tiles = {"mcl_flowers_double_plant_sunflower_bottom.png", "mcl_flowers_double_plant_sunflower_bottom.png", "mcl_flowers_double_plant_sunflower_front.png", "mcl_flowers_double_plant_sunflower_back.png"},
		inventory_image = "mcl_flowers_double_plant_sunflower_front.png",
		drawtype = "mesh",
		mesh = "mcl_flowers_sunflower.obj",
		drop = "mcl_flowers:sunflower",
		use_texture_alpha = "clip",
	},
	top = {
		drawtype = "airlike",
	},
	selbox_radius = 5/16,
	selbox_top_height = 6/16,
	is_flower = true,
})

mcl_flowers.wheat_seed_drop = {
	max_items = 1,
	items = {
		{
			items = {"mcl_farming:wheat_seeds"},
			rarity = 8,
		},
	},
}

mcl_flowers.fortune_wheat_seed_drop = {
	discrete_uniform_distribution = true,
	items = {"mcl_farming:wheat_seeds"},
	chance = 1 / 8,
	min_count = 1,
	max_count = 1,
	factor = 2,
	overwrite = true,
}

mcl_flowers.add_large_plant("double_grass", {
	bottom = {
		description = S("Double Tallgrass"),
		_doc_items_longdesc = S("Double tallgrass a variant of tall grass and occupies two blocks. It can be harvested for wheat seeds."),
		tiles = { "mcl_flowers_double_plant_grass_bottom.png" },
		inventory_image = "mcl_flowers_double_plant_grass_inv.png",
		groups = { compostability = 50 },
		drop = mcl_flowers.wheat_seed_drop,
		_mcl_fortune_drop = mcl_flowers.fortune_wheat_seed_drop,
		_mcl_shears_drop = {"mcl_flowers:tallgrass 2"},
	},
	tiles_top = { "mcl_flowers_double_plant_grass_top.png" },
	selbox_radius = 6/16,
	selbox_top_height = 4/16,
	grass_color = true,
})

mcl_flowers.add_large_plant("double_fern", {
	bottom = {
		description = S("Large Fern"),
		_doc_items_longdesc = S("Large fern is a variant of fern and occupies two blocks. It can be harvested for wheat seeds."),
		tiles = { "mcl_flowers_double_plant_fern_bottom.png" },
		inventory_image = "mcl_flowers_double_plant_fern_inv.png",
		groups = { compostability = 50 },
		drop = mcl_flowers.wheat_seed_drop,
		_mcl_fortune_drop = mcl_flowers.fortune_wheat_seed_drop,
		_mcl_shears_drop = {"mcl_flowers:fern 2"},
	},
	tiles_top = { "mcl_flowers_double_plant_fern_top.png" },
	selbox_radius = 5/16,
	selbox_top_height = 5/16,
	grass_color = true,
})


--- Tall Grass ---
local def_tallgrass = {
	description = S("Tall Grass"),
	drawtype = "plantlike",
	_doc_items_longdesc = S("Tall grass is a small plant which often occurs on the surface of grasslands. It can be harvested for wheat seeds. By using bone meal, tall grass can be turned into double tallgrass which is two blocks high."),
	_doc_items_usagehelp = mcl_flowers.plant_usage_help,
	_doc_items_hidden = false,
	waving = 1,
	tiles = {"mcl_flowers_tallgrass.png"},
	inventory_image = "mcl_flowers_tallgrass_inv.png",
	wield_image = "mcl_flowers_tallgrass_inv.png",
	selection_box = {
		type = "fixed",
		fixed = {{ -6/16, -8/16, -6/16, 6/16, 4/16, 6/16 }},
	},
	paramtype = "light",
	paramtype2 = "color",
	palette = "mcl_core_palette_grass.png",
	sunlight_propagates = true,
	walkable = false,
	buildable_to = true,
	groups = {
		handy = 1, shearsy = 1, attached_node = 1, deco_block = 1,
		plant = 1, place_flowerlike = 2, non_mycelium_plant = 1,
		flammable = 3, fire_encouragement = 60, fire_flammability = 10, dig_by_piston = 1,
		dig_by_water = 1, destroy_by_lava_flow = 1, compostability = 30, grass_palette = 1
	},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	drop = mcl_flowers.wheat_seed_drop,
	_mcl_shears_drop = true,
	_mcl_fortune_drop = mcl_flowers.fortune_wheat_seed_drop,
	node_placement_prediction = "",
	on_place = mcl_flowers.on_place_flower,
	_mcl_blast_resistance = 0,
	_mcl_hardness = 0,
	_on_bone_meal = mcl_flowers.on_bone_meal,
}
minetest.register_node("mcl_flowers:tallgrass", def_tallgrass)

--- Fern ---
-- The fern is very similar to tall grass, so we can copy a lot from it.
minetest.register_node("mcl_flowers:fern", table.merge(def_tallgrass, {
	description = S("Fern"),
	_doc_items_longdesc = S("Ferns are small plants which occur naturally in jungles and taigas. They can be harvested for wheat seeds. By using bone meal, a fern can be turned into a large fern which is two blocks high."),
	tiles = { "mcl_flowers_fern.png" },
	inventory_image = "mcl_flowers_fern_inv.png",
	wield_image = "mcl_flowers_fern_inv.png",
	selection_box = {
		type = "fixed",
		fixed = { -6/16, -0.5, -6/16, 6/16, 5/16, 6/16 },
	},
	groups = table.merge(def_tallgrass.groups, { compostability = 65 })
}))

mcl_flowerpots.register_potted_flower("mcl_flowers:fern", {
	name = "fern",
	desc = S("Fern"),
	image = "mcl_flowers_fern_inv.png",
})
