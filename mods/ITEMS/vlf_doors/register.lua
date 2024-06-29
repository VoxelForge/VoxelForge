local S = minetest.get_translator(minetest.get_current_modname())

--- Iron Door ---
vlf_doors:register_door("vlf_doors:iron_door", {
	description = S("Iron Door"),
	_doc_items_longdesc = S("Iron doors are 2-block high barriers which can only be opened or closed by a redstone signal, but not by hand."),
	_doc_items_usagehelp = S("To open or close an iron door, supply its lower half with a redstone signal."),
	inventory_image = "doors_item_steel.png",
	groups = {pickaxey=1, mesecon_effector_on=1},
	_vlf_hardness = 5,
	_vlf_blast_resistance = 5,
	tiles_bottom = {"vlf_doors_door_iron_lower.png^[transformFX", "vlf_doors_door_iron_side_lower.png"},
	tiles_top = {"vlf_doors_door_iron_upper.png^[transformFX", "vlf_doors_door_iron_side_upper.png"},
	sounds = vlf_sounds.node_sound_metal_defaults(),
	sound_open = "vlf_doors_iron_door_open",
	sound_close = "vlf_doors_iron_door_close",

	only_redstone_can_open = true,
})

minetest.register_craft({
	output = "vlf_doors:iron_door 3",
	recipe = {
		{"vlf_core:iron_ingot", "vlf_core:iron_ingot"},
		{"vlf_core:iron_ingot", "vlf_core:iron_ingot"},
		{"vlf_core:iron_ingot", "vlf_core:iron_ingot"}
	}
})

vlf_doors:register_trapdoor("vlf_doors:iron_trapdoor", {
	description = S("Iron Trapdoor"),
	_doc_items_longdesc = S("Iron trapdoors are horizontal barriers which can only be opened and closed by redstone signals, but not by hand. They occupy the upper or lower part of a block, depending on how they have been placed. When open, they can be climbed like a ladder."),
	tile_front = "doors_trapdoor_steel.png",
	tile_side = "doors_trapdoor_steel_side.png",
	wield_image = "doors_trapdoor_steel.png",
	groups = {pickaxey=1, mesecon_effector_on=1},
	_vlf_hardness = 5,
	_vlf_blast_resistance = 5,
	sounds = vlf_sounds.node_sound_metal_defaults(),
	sound_open = "vlf_doors_iron_trapdoor_open",
	sound_close = "vlf_doors_iron_trapdoor_close",

	only_redstone_can_open = true,
})

minetest.register_craft({
	output = "vlf_doors:iron_trapdoor",
	recipe = {
		{"vlf_core:iron_ingot", "vlf_core:iron_ingot"},
		{"vlf_core:iron_ingot", "vlf_core:iron_ingot"},
	}
})
