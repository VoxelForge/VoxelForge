local S = minetest.get_translator("vlf_dripstone")

minetest.register_node("vlf_dripstone:dripstone_block", {
	description = S("Dripstone Block"),
	tiles = {"vlf_dripstone_dripstone_block.png"},
	groups = {pickaxey=1, stone=1, building_block=1, material_stone=1},
	sounds = vlf_sounds.node_sound_stone_defaults(),
	_vlf_blast_resistance = 1,
	_vlf_hardness = 1.5,
})

minetest.register_node("vlf_dripstone:pointed_dripstone_down_tip", {
	description = S("Pointed Dripstone"),
	drawtype = "plantlike",
	inventory_image = "vlf_dripstone_pointed_dripstone.png",
	tiles = {"vlf_dripstone_pointed_dripstone_down_tip.png"},
	groups = {pickaxey=1, stone=1, building_block=1, material_stone=1},
	sounds = vlf_sounds.node_sound_stone_defaults(),
	paramtype = "light",
	light_propagates = true,
	sunlight_propagates = true,
	_vlf_blast_resistance = 3,
	_vlf_hardness = 1.5,
})

minetest.register_node("vlf_dripstone:pointed_dripstone_up_tip", {
	description = S("Pointed Dripstone"),
	drawtype = "plantlike",
	inventory_image = "vlf_dripstone_pointed_dripstone.png",
	tiles = {"vlf_dripstone_pointed_dripstone_up_tip.png"},
	groups = {pickaxey=1, stone=1, building_block=1, material_stone=1, not_in_creative_inventory=1, fall_damage_add_percent=50},
	sounds = vlf_sounds.node_sound_stone_defaults(),
	paramtype = "light",
	light_propagates = true,
	sunlight_propagates = true,
	_vlf_blast_resistance = 3,
	_vlf_hardness = 1.5,
})

minetest.register_node("vlf_dripstone:pointed_dripstone_down_frustum", {
	description = S("Pointed Dripstone"),
	drawtype = "plantlike",
	inventory_image = "vlf_dripstone_pointed_dripstone.png",
	tiles = {"vlf_dripstone_pointed_dripstone_down_frustum.png"},
	groups = {pickaxey=1, stone=1, building_block=1, material_stone=1},
	sounds = vlf_sounds.node_sound_stone_defaults(),
	paramtype = "light",
	light_propagates = true,
	sunlight_propagates = true,
	_vlf_blast_resistance = 3,
	_vlf_hardness = 1.5,
})

minetest.register_node("vlf_dripstone:pointed_dripstone_up_frustum", {
	description = S("Pointed Dripstone"),
	drawtype = "plantlike",
	inventory_image = "vlf_dripstone_pointed_dripstone.png",
	tiles = {"vlf_dripstone_pointed_dripstone_up_frustum.png"},
	groups = {pickaxey=1, stone=1, building_block=1, material_stone=1, not_in_creative_inventory=1, fall_damage_add_percent=50},
	sounds = vlf_sounds.node_sound_stone_defaults(),
	paramtype = "light",
	light_propagates = true,
	sunlight_propagates = true,
	_vlf_blast_resistance = 3,
	_vlf_hardness = 1.5,
})

minetest.register_node("vlf_dripstone:pointed_dripstone_down_middle", {
	description = S("Pointed Dripstone"),
	drawtype = "plantlike",
	inventory_image = "vlf_dripstone_pointed_dripstone.png",
	tiles = {"vlf_dripstone_pointed_dripstone_down_middle.png"},
	groups = {pickaxey=1, stone=1, building_block=1, material_stone=1},
	sounds = vlf_sounds.node_sound_stone_defaults(),
	paramtype = "light",
	light_propagates = true,
	sunlight_propagates = true,
	_vlf_blast_resistance = 3,
	_vlf_hardness = 1.5,
})

minetest.register_node("vlf_dripstone:pointed_dripstone_up_middle", {
	description = S("Pointed Dripstone"),
	drawtype = "plantlike",
	inventory_image = "vlf_dripstone_pointed_dripstone.png",
	tiles = {"vlf_dripstone_pointed_dripstone_up_middle.png"},
	groups = {pickaxey=1, stone=1, building_block=1, material_stone=1, not_in_creative_inventory=1, fall_damage_add_percent=50},
	sounds = vlf_sounds.node_sound_stone_defaults(),
	paramtype = "light",
	light_propagates = true,
	sunlight_propagates = true,
	_vlf_blast_resistance = 3,
	_vlf_hardness = 1.5,
})
minetest.register_node("vlf_dripstone:pointed_dripstone_down_base", {
	description = S("Pointed Dripstone"),
	drawtype = "plantlike",
	inventory_image = "vlf_dripstone_pointed_dripstone.png",
	tiles = {"vlf_dripstone_pointed_dripstone_down_base.png"},
	groups = {pickaxey=1, stone=1, building_block=1, material_stone=1},
	sounds = vlf_sounds.node_sound_stone_defaults(),
	paramtype = "light",
	light_propagates = true,
	sunlight_propagates = true,
	_vlf_blast_resistance = 3,
	_vlf_hardness = 1.5,
})

minetest.register_node("vlf_dripstone:pointed_dripstone_up_base", {
	description = S("Pointed Dripstone"),
	drawtype = "plantlike",
	inventory_image = "vlf_dripstone_pointed_dripstone.png",
	tiles = {"vlf_dripstone_pointed_dripstone_up_base.png"},
	groups = {pickaxey=1, stone=1, building_block=1, material_stone=1, not_in_creative_inventory=1, fall_damage_add_percent=50},
	sounds = vlf_sounds.node_sound_stone_defaults(),
	paramtype = "light",
	light_propagates = true,
	sunlight_propagates = true,
	_vlf_blast_resistance = 3,
	_vlf_hardness = 1.5,
})
