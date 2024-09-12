local S = minetest.get_translator(minetest.get_current_modname())

vlf_flowers.register_simple_flower("poppy", {
	desc = S("Poppy"),
	image = "vlf_flowers_poppy.png",
	paramtype2 = "4dir",
	selection_box = { -5/16, -0.5, -5/16, 5/16, 5/16, 5/16 },
	potted = true,
})
-- Not implimented yet.
--[[vlf_flowers.register_simple_flower("torchflower", {
	desc = S("Torch Flower"),
	image = "vlf_flowers_torchflower.png",
	paramtype2 = "4dir",
	selection_box = { -2/16, -0.5, -2/16, 2/16, 4/16, 2/16 },
	potted = true,
})]]
vlf_flowers.register_simple_flower("dandelion", {
	desc = S("Dandelion"),
	image = "flowers_dandelion_yellow.png",
	paramtype2 = "4dir",
	selection_box = { -4/16, -0.5, -4/16, 4/16, 3/16, 4/16 },
	potted = true,
})
vlf_flowers.register_simple_flower("oxeye_daisy", {
	desc = S("Oxeye Daisy"),
	image = "vlf_flowers_oxeye_daisy.png",
	paramtype2 = "4dir",
	selection_box = { -4/16, -0.5, -4/16, 4/16, 4/16, 4/16 },
	potted = true,
})
vlf_flowers.register_simple_flower("tulip_orange", {
	desc = S("Orange Tulip"),
	image = "flowers_tulip.png",
	paramtype2 = "4dir",
	selection_box = { -3/16, -0.5, -3/16, 3/16, 5/16, 3/16 },
	potted = true,
})
vlf_flowers.register_simple_flower("tulip_pink", {
	desc = S("Pink Tulip"),
	image = "vlf_flowers_tulip_pink.png",
	paramtype2 = "4dir",
	selection_box = { -3/16, -0.5, -3/16, 3/16, 5/16, 3/16 },
	potted = true,
})
vlf_flowers.register_simple_flower("tulip_red", {
	desc = S("Red Tulip"),
	image = "vlf_flowers_tulip_red.png",
	paramtype2 = "4dir",
	selection_box = { -3/16, -0.5, -3/16, 3/16, 6/16, 3/16 },
	potted = true,
})
vlf_flowers.register_simple_flower("tulip_white", {
	desc = S("White Tulip"),
	image = "vlf_flowers_tulip_white.png",
	paramtype2 = "4dir",
	selection_box = { -3/16, -0.5, -3/16, 3/16, 4/16, 3/16 },
	potted = true,
})
vlf_flowers.register_simple_flower("allium", {
	desc = S("Allium"),
	image = "vlf_flowers_allium.png",
	paramtype2 = "4dir",
	selection_box = { -3/16, -0.5, -3/16, 3/16, 6/16, 3/16 },
	potted = true,
})
vlf_flowers.register_simple_flower("azure_bluet", {
	desc = S("Azure Bluet"),
	image = "vlf_flowers_azure_bluet.png",
	paramtype2 = "4dir",
	selection_box = { -5/16, -0.5, -5/16, 5/16, 3/16, 5/16 },
	potted = true,
})
vlf_flowers.register_simple_flower("blue_orchid", {
	desc = S("Blue Orchid"),
	image = "vlf_flowers_blue_orchid.png",
	paramtype2 = "4dir",
	selection_box = { -5/16, -0.5, -5/16, 5/16, 7/16, 5/16 },
	potted = true,
})
vlf_flowers.register_simple_flower("wither_rose", {
	desc = S("Wither Rose"),
	image = "vlf_flowers_wither_rose.png",
	paramtype2 = "4dir",
	selection_box = { -3/16, -0.5, -3/16, 3/16, 6/16, 3/16 },
	potted = true,
})
vlf_flowers.register_simple_flower("lily_of_the_valley", {
	desc = S("Lily of the Valley"),
	image = "vlf_flowers_lily_of_the_valley.png",
	paramtype2 = "4dir",
	selection_box = { -5/16, -0.5, -5/16, 4/16, 5/16, 5/16 },
	potted = true,
})
vlf_flowers.register_simple_flower("cornflower", {
	desc = S("Cornflower"),
	image = "vlf_flowers_cornflower.png",
	paramtype2 = "4dir",
	selection_box = { -4/16, -0.5, -4/16, 4/16, 3/16, 4/16 },
	potted = true,
})

vlf_flowers.add_large_plant("peony", {
	desc = S("Peony"),
	longdesc = S("A peony is a large plant which occupies two blocks. It is mainly used in dye production."),
	tiles_bottom = { "vlf_flowers_double_plant_paeonia_bottom.png" },
	tiles_top = { "vlf_flowers_double_plant_paeonia_top.png" },
	selbox_radius = 5/16,
	selbox_top_height = 6/16,
	is_flower = true,
})


vlf_flowers.add_large_plant("rose_bush", {
	desc = S("Rose Bush"),
	longdesc = S("A rose bush is a large plant which occupies two blocks. It is safe to touch it. Rose bushes are mainly used in dye production."),
	tiles_bottom = { "vlf_flowers_double_plant_rose_bottom.png" },
	tiles_top = { "vlf_flowers_double_plant_rose_top.png" },
	selbox_radius = 5/16,
	selbox_top_height = 1/16,
	is_flower = true,
})

vlf_flowers.add_large_plant("lilac", {
	desc = S("Lilac"),
	longdesc = S("A lilac is a large plant which occupies two blocks. It is mainly used in dye production."),
	tiles_bottom = { "vlf_flowers_double_plant_syringa_bottom.png" },
	tiles_top = { "vlf_flowers_double_plant_syringa_top.png" },
	selbox_radius = 5/16,
	selbox_top_height = 6/16,
	is_flower = true,
})

vlf_flowers.add_large_plant("sunflower", {
	desc = S("Sunflower"),
	longdesc = S("A sunflower is a large plant which occupies two blocks. It is mainly used in dye production."),
	tiles_bottom = {"vlf_flowers_double_plant_sunflower_bottom.png", "vlf_flowers_double_plant_sunflower_bottom.png", "vlf_flowers_double_plant_sunflower_front.png", "vlf_flowers_double_plant_sunflower_back.png"},
	bottom = {
		inventory_image = "vlf_flowers_double_plant_sunflower_front.png",
		drawtype = "mesh",
		mesh = "vlf_flowers_sunflower.obj",
		drop = "vlf_flowers:sunflower",
		use_texture_alpha = "clip",
	},
	top = {
		drawtype = "airlike",
		drop = "vlf_flowers:sunflower",
	},
	selbox_radius = 5/16,
	selbox_top_height = 6/16,
	is_flower = true,
})

vlf_flowers.wheat_seed_drop = {
	max_items = 1,
	items = {
		{
			items = {"vlf_farming:wheat_seeds"},
			rarity = 8,
		},
	},
}

vlf_flowers.fortune_wheat_seed_drop = {
	discrete_uniform_distribution = true,
	items = {"vlf_farming:wheat_seeds"},
	chance = 1 / 8,
	min_count = 1,
	max_count = 1,
	factor = 2,
	overwrite = true,
}

vlf_flowers.add_large_plant("double_grass", {
	desc = S("Double Tallgrass"),
	longdesc = S("Double tallgrass a variant of tall grass and occupies two blocks. It can be harvested for wheat seeds."),
	tiles_bottom = { "vlf_flowers_double_plant_grass_bottom.png" },
	tiles_top = { "vlf_flowers_double_plant_grass_top.png" },
	inv_img = "vlf_flowers_double_plant_grass_inv.png",
	bottom = {
		groups = { compostability = 50 },
		drop = vlf_flowers.wheat_seed_drop,
		_vlf_fortune_drop = vlf_flowers.fortune_wheat_seed_drop,
		_vlf_shears_drop = {"vlf_flowers:tallgrass 2"},
	},
	selbox_radius = 6/16,
	selbox_top_height = 4/16,
	grass_color = true,
})

vlf_flowers.add_large_plant("double_fern", {
	desc = S("Large Fern"),
	longdesc = S("Large fern is a variant of fern and occupies two blocks. It can be harvested for wheat seeds."),
	tiles_bottom = { "vlf_flowers_double_plant_fern_bottom.png" },
	tiles_top = { "vlf_flowers_double_plant_fern_top.png" },
	inv_img = "vlf_flowers_double_plant_fern_inv.png",
	bottom = {
		groups = { compostability = 50 },
		drop = vlf_flowers.wheat_seed_drop,
		_vlf_fortune_drop = vlf_flowers.fortune_wheat_seed_drop,
		_vlf_shears_drop = {"vlf_flowers:fern 2"},
	},
	selbox_radius = 5/16,
	selbox_top_height = 5/16,
	grass_color = true,
})

local def_tallgrass = {
	description = S("Tall Grass"),
	drawtype = "mesh",
	mesh = "mc_plant.obj",
	longdesc = S("Tall grass is a small plant which often occurs on the surface of grasslands. It can be harvested for wheat seeds. By using bone meal, tall grass can be turned into double tallgrass which is two blocks high."),
	_doc_items_usagehelp = vlf_flowers.plant_usage_help,
	_doc_items_hidden = false,
	waving = 1,
	tiles = {"vlf_flowers_tallgrass.png"},
	inventory_image = "vlf_flowers_tallgrass_inv.png",
	wield_image = "vlf_flowers_tallgrass_inv.png",
	selection_box = {
		type = "fixed",
		fixed = {{ -6/16, -8/16, -6/16, 6/16, 4/16, 6/16 }},
	},
	paramtype = "light",
	paramtype2 = "color4dir",
	palette = "vlf_core_palette_grass.png",
	sunlight_propagates = true,
	walkable = false,
	use_texture_alpha = "clip",
	buildable_to = true,
	groups = {
		handy = 1, shearsy = 1, attached_node = 1, deco_block = 1,
		plant = 1, place_flowerlike = 2, non_mycelium_plant = 1,
		flammable = 3, fire_encouragement = 60, fire_flammability = 10, dig_by_piston = 1,
		dig_by_water = 1, destroy_by_lava_flow = 1, compostability = 30, grass_palette = 1
	},
	sounds = vlf_sounds.node_sound_leaves_defaults(),
	drop = vlf_flowers.wheat_seed_drop,
	_vlf_shears_drop = true,
	_vlf_fortune_drop = vlf_flowers.fortune_wheat_seed_drop,
	node_placement_prediction = "",
	on_place = vlf_flowers.on_place_flower,
	_vlf_blast_resistance = 0,
	_vlf_hardness = 0,
	_on_bone_meal = vlf_flowers.on_bone_meal,
}
minetest.register_node("vlf_flowers:tallgrass", def_tallgrass)

minetest.register_node("vlf_flowers:fern", table.merge(def_tallgrass, {
	description = S("Fern"),
	longdesc = S("Ferns are small plants which occur naturally in jungles and taigas. They can be harvested for wheat seeds. By using bone meal, a fern can be turned into a large fern which is two blocks high."),
	tiles = { "vlf_flowers_fern.png" },
	inventory_image = "vlf_flowers_fern_inv.png",
	wield_image = "vlf_flowers_fern_inv.png",
	use_texture_alpha = "clip",
	selection_box = {
		type = "fixed",
		fixed = { -6/16, -0.5, -6/16, 6/16, 5/16, 6/16 },
	},
	groups = table.merge(def_tallgrass.groups, { compostability = 65 })
}))

vlf_flowerpots.register_potted_flower("vlf_flowers:fern", {
	name = "fern",
	desc = S("Fern"),
	image = "vlf_flowers_fern_inv.png",
})

minetest.register_node("vlf_flowers:waterlily", {
	description = S("Lily Pad"),
	_doc_items_longdesc = S("A lily pad is a flat plant block which can be walked on. They can be placed on water sources, ice and frosted ice."),
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	tiles = {"flowers_waterlily.png", "flowers_waterlily.png^[transformFY"},
	use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "clip" or true,
	inventory_image = "flowers_waterlily.png",
	wield_image = "flowers_waterlily.png",
	liquids_pointable = true,
	sunlight_propagates = true,
	groups = {
		deco_block = 1, plant = 1, compostability = 65, destroy_by_lava_flow = 1,
		dig_immediate = 3, dig_by_water = 1, dig_by_piston = 1, dig_by_boat = 1,
	},
	sounds = vlf_sounds.node_sound_leaves_defaults(),
	node_placement_prediction = "",
	node_box = {
		type = "fixed",
		fixed = {-0.5, -31/64, -0.5, 0.5, -15/32, 0.5}
	},
	selection_box = {
		type = "fixed",
		fixed = {-7 / 16, -0.5, -7 / 16, 7 / 16, -15 / 32, 7 / 16}
	},

	on_place = function(itemstack, placer, pointed_thing)
		if not placer or not placer:is_player() then
			return itemstack
		end

		local rc = vlf_util.call_on_rightclick(itemstack, placer, pointed_thing)
		if rc then return rc end

		local pos = pointed_thing.above
		local node = minetest.get_node(pointed_thing.under)
		local nodename = node.name
		local def = minetest.registered_nodes[nodename]
		local node_above = minetest.get_node(pointed_thing.above).name
		local def_above = minetest.registered_nodes[node_above]
		local player_name = placer:get_player_name()

		if def then
			if (pointed_thing.under.x == pointed_thing.above.x and pointed_thing.under.z == pointed_thing.above.z) and
					((def.liquidtype == "source" and minetest.get_item_group(nodename, "water") > 0) or
					(nodename == "vlf_core:ice") or
					(minetest.get_item_group(nodename, "frosted_ice") > 0)) and
					(def_above.buildable_to and minetest.get_item_group(node_above, "liquid") == 0) then
				if not minetest.is_protected(pos, player_name) then
					minetest.set_node(pos, {name = "vlf_flowers:waterlily", param2 = math.random(0, 3)})
					local idef = itemstack:get_definition()

					if idef.sounds and idef.sounds.place then
						minetest.sound_play(idef.sounds.place, {pos=pointed_thing.above, gain=1}, true)
					end

					if not minetest.is_creative_enabled(player_name) then
						itemstack:take_item()
					end
				else
					minetest.record_protection_violation(pos, player_name)
				end
			end
		end
		return itemstack
	end,
	on_rotate = screwdriver.rotate_simple,
})
