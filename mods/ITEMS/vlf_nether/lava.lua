local S = minetest.get_translator(minetest.get_current_modname())

-- TODO: Increase flow speed. This could be done by reducing viscosity,
-- but this would also allow players to swim faster in lava.

minetest.register_node("vlf_nether:nether_lava_source", table.merge(minetest.registered_nodes["vlf_core:lava_source"], {
	description = S("Nether Lava Source"),
	_doc_items_create_entry = false,
	_doc_items_entry_name = nil,
	_doc_items_longdesc = nil,
	_doc_items_usagehelp = nil,
	liquid_range = 7,
	liquid_alternative_source = "vlf_nether:nether_lava_source",
	liquid_alternative_flowing = "vlf_nether:nether_lava_flowing",
}))

minetest.register_node("vlf_nether:nether_lava_flowing", table.merge(minetest.registered_nodes["vlf_core:lava_flowing"], {
	description = S("Flowing Nether Lava"),
	_doc_items_create_entry = false,
	liquid_range = 7,
	liquid_alternative_flowing = "vlf_nether:nether_lava_flowing",
	liquid_alternative_source = "vlf_nether:nether_lava_source",
}))
doc.add_entry_alias("nodes", "vlf_core:lava_source", "nodes", "vlf_nether:nether_lava_source")
doc.add_entry_alias("nodes", "vlf_core:lava_source", "nodes", "vlf_nether:nether_lava_flowing")

