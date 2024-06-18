local S = minetest.get_translator(minetest.get_current_modname())

--- Iron Door ---
vlc_doors:register_door("vlc_doors:iron_door", {
	description = S("Iron Door"),
	_doc_items_longdesc = S("Iron doors are 2-block high barriers which can only be opened or closed by a redstone signal, but not by hand."),
	_doc_items_usagehelp = S("To open or close an iron door, supply its lower half with a redstone signal."),
	inventory_image = "doors_item_steel.png",
	groups = {pickaxey=1, mesecon_effector_on=1},
	_vlc_hardness = 5,
	_vlc_blast_resistance = 5,
	tiles_bottom = {"vlc_doors_door_iron_lower.png^[transformFX", "vlc_doors_door_iron_side_lower.png"},
	tiles_top = {"vlc_doors_door_iron_upper.png^[transformFX", "vlc_doors_door_iron_side_upper.png"},
	sounds = vlc_sounds.node_sound_metal_defaults(),
	sound_open = "doors_steel_door_open",
	sound_close = "doors_steel_door_close",

	only_redstone_can_open = true,
})

minetest.register_craft({
	output = "vlc_doors:iron_door 3",
	recipe = {
		{"vlc_core:iron_ingot", "vlc_core:iron_ingot"},
		{"vlc_core:iron_ingot", "vlc_core:iron_ingot"},
		{"vlc_core:iron_ingot", "vlc_core:iron_ingot"}
	}
})

vlc_doors:register_trapdoor("vlc_doors:iron_trapdoor", {
	description = S("Iron Trapdoor"),
	_doc_items_longdesc = S("Iron trapdoors are horizontal barriers which can only be opened and closed by redstone signals, but not by hand. They occupy the upper or lower part of a block, depending on how they have been placed. When open, they can be climbed like a ladder."),
	tile_front = "doors_trapdoor_steel.png",
	tile_side = "doors_trapdoor_steel_side.png",
	wield_image = "doors_trapdoor_steel.png",
	groups = {pickaxey=1, mesecon_effector_on=1},
	_vlc_hardness = 5,
	_vlc_blast_resistance = 5,
	sounds = vlc_sounds.node_sound_metal_defaults(),
	sound_open = "doors_steel_door_open",
	sound_close = "doors_steel_door_close",

	only_redstone_can_open = true,
})

minetest.register_craft({
	output = "vlc_doors:iron_trapdoor",
	recipe = {
		{"vlc_core:iron_ingot", "vlc_core:iron_ingot"},
		{"vlc_core:iron_ingot", "vlc_core:iron_ingot"},
	}
})
