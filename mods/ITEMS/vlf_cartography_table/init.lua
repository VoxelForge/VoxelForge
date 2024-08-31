local S = minetest.get_translator(minetest.get_current_modname())
-- Cartography Table Code. Used to create and copy maps. Needs a GUI still.

minetest.register_node("vlf_cartography_table:cartography_table", {
	description = S("Cartography Table"),
	_tt_help = S("Used to create or copy maps"),
	_doc_items_longdesc = S("Is used to create or copy maps for use.."),
	tiles = {
		"cartography_table_top.png", "cartography_table_side3.png",
		"cartography_table_side3.png", "cartography_table_side2.png",
		"cartography_table_side3.png", "cartography_table_side1.png"
	},
	is_ground_content = false,
	paramtype2 = "facedir",
	groups = { axey = 2, handy = 1, deco_block = 1, material_wood = 1, flammable = 1 },
	sounds = vlf_sounds.node_sound_wood_defaults(),
	_vlf_blast_resistance = 2.5,
	_vlf_hardness = 2.5
	})


minetest.register_craft({
	output = "vlf_cartography_table:cartography_table",
	recipe = {
		{ "vlf_core:paper", "vlf_core:paper", "" },
		{ "group:wood", "group:wood", "" },
		{ "group:wood", "group:wood", "" },
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "vlf_cartography_table:cartography_table",
	burntime = 15,
})
