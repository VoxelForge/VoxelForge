local S = minetest.get_translator(minetest.get_current_modname())
-- Fletching Table Code. No use as of current Minecraft Updates. Basically a decor block. As of now, this is complete.
minetest.register_node("vlf_fletching_table:fletching_table", {
	description = S("Fletching Table"),
	_tt_help = S("A fletching table"),
	_doc_items_longdesc = S("This is the fletcher villager's work station. It currently has no use beyond decoration."),
	tiles = {
		"fletching_table_top.png", "fletching_table_bottom.png",
		"fletching_table_front.png", "fletching_table_front.png",
		"fletching_table_side.png", "fletching_table_side.png"
	},
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = { axey = 2, handy = 1, deco_block = 1, material_wood = 1, flammable = 1 },
	sounds = vlf_sounds.node_sound_wood_defaults(),
	_vlf_blast_resistance = 2.5,
	_vlf_hardness = 2.5
})

minetest.register_craft({
	output = "vlf_fletching_table:fletching_table",
	recipe = {
		{ "vlf_core:flint", "vlf_core:flint", "" },
		{ "group:wood", "group:wood", "" },
		{ "group:wood", "group:wood", "" },
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "vlf_fletching_table:fletching_table",
	burntime = 15,
})
