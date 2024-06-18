local S = minetest.get_translator("vlc_copper")

minetest.register_craftitem("vlc_copper:copper_ingot", {
	description = S("Copper Ingot"),
	_doc_items_longdesc = S("Molten Raw Copper. It is used to craft blocks."),
	inventory_image = "vlc_copper_ingot.png",
	groups = { craftitem = 1 },
})

minetest.register_craftitem("vlc_copper:raw_copper", {
	description = S("Raw Copper"),
	_doc_items_longdesc = S("Raw Copper. Mine a Copper Ore to get it."),
	inventory_image = "vlc_copper_raw.png",
	groups = { craftitem = 1, blast_furnace_smeltable = 1 },
})
