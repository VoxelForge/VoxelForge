local S = minetest.get_translator(minetest.get_current_modname())

-- TODO: Increase flow speed. This could be done by reducing viscosity,
-- but this would also allow players to swim faster in lava.


liquid.register_liquid({
	liquid_tick = 1.0 / 2.0,
	liquid_range = 7,
	liquid_renewable = false,
	name_source = "mcl_nether:nether_lava_source",
	ndef_source = table.merge(minetest.registered_nodes["mcl_core:lava_source"], {
		description = S("Nether Lava Source"),
		_doc_items_create_entry = false,
		_doc_items_entry_name = nil,
		_doc_items_longdesc = nil,
		_doc_items_usagehelp = nil,
	}),

	name_flowing = "mcl_nether:nether_lava_flowing",
	ndef_flowing = table.merge(minetest.registered_nodes["mcl_core:lava_flowing"], {
		description = S("Flowing Nether Lava"),
		_doc_items_create_entry = false,
	}),
})

doc.add_entry_alias("nodes", "mcl_core:lava_source", "nodes", "mcl_nether:nether_lava_source")
doc.add_entry_alias("nodes", "mcl_core:lava_source", "nodes", "mcl_nether:nether_lava_flowing")

