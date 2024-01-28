local S = minetest.get_translator(minetest.get_current_modname())
local doc_mod = minetest.get_modpath("doc")
local extra_nodes = minetest.settings:get_bool("mcl_extra_nodes", true)

mcl_stairs.register_stair_and_slab("lapisblock", {
	recipeitem="mcl_core:lapisblock",
	base_description=S("Lapis Lazuli"),
	extra_groups={not_in_creative_inventory=extra_nodes and 0 or 1},
	tiles={"mcl_core_lapis_block.png", "mcl_core_lapis_block.png", "mcl_stairs_lapis_block_slab.png"},
	register_craft=extra_nodes,
})
mcl_stairs.register_stair_and_slab("lapisblock", {
	recipeitem="mcl_core:lapisblock",
	base_description=S("Lapis Lazuli"),
	extra_groups={not_in_creative_inventory=extra_nodes and 0 or 1},
	register_craft=extra_nodes,
})

mcl_stairs.register_stair_and_slab("goldblock", {
	recipeitem="mcl_core:goldblock",
	base_description=S("Gold"),
	extra_groups={not_in_creative_inventory=extra_nodes and 0 or 1},
	tiles={"default_gold_block.png", "default_gold_block.png", "mcl_stairs_gold_block_slab.png"},
	register_craft=extra_nodes,
})
mcl_stairs.register_stair_and_slab("goldblock", {
	recipeitem="mcl_core:goldblock",
	base_description=S("Gold"),
	extra_groups={not_in_creative_inventory=extra_nodes and 0 or 1},
	register_craft=extra_nodes,
})

mcl_stairs.register_stair_and_slab("ironblock", {
	recipeitem="mcl_core:ironblock",
	base_description=S("Iron"),
	extra_groups={not_in_creative_inventory=extra_nodes and 0 or 1},
	tiles={"default_steel_block.png", "default_steel_block.png", "mcl_stairs_iron_block_slab.png"},
	register_craft=extra_nodes,
})
mcl_stairs.register_stair_and_slab("ironblock", {
	recipeitem="mcl_core:ironblock",
	base_description=S("Iron"),
	extra_groups={not_in_creative_inventory=extra_nodes and 0 or 1},
	register_craft=extra_nodes,
})

mcl_stairs.register_stair_and_slab("stonebrickcracked", {
	recipeitem="mcl_core:stonebrickcracked",
	base_description=S("Cracked Stone Brick"),
	extra_groups={not_in_creative_inventory=extra_nodes and 0 or 1},
	tiles={"mcl_core_stonebrick_cracked.png"},
	register_craft=extra_nodes,
})
mcl_stairs.register_stair_and_slab("stonebrickcracked", {
	recipeitem="mcl_core:stonebrickcracked",
	base_description=S("Cracked Stone Brick"),
	extra_groups={not_in_creative_inventory=extra_nodes and 0 or 1},
	tiles={"mcl_core_stonebrick_cracked.png"},
	register_craft=extra_nodes,
})

local canonical_color = "yellow"
for name,cdef in pairs(mcl_dyes.colors) do
	local is_canonical = name == canonical_color
	mcl_stairs.register_stair_and_slab("concrete_"..name, {
		extra_groups={not_in_creative_inventory=extra_nodes and 0 or 1},
		recipeitem="mcl_colorblocks:concrete_"..name,
		register_craft=extra_nodes,
	})

	if doc_mod then
		if not is_canonical then
			doc.add_entry_alias("nodes", "mcl_stairs:slab_concrete_"..canonical_color, "nodes", "mcl_stairs:slab_concrete_"..name)
			doc.add_entry_alias("nodes", "mcl_stairs:slab_concrete_"..canonical_color.."_double", "nodes", "mcl_stairs:slab_concrete_"..name.."_double")
			doc.add_entry_alias("nodes", "mcl_stairs:stair_concrete_"..canonical_color, "nodes", "mcl_stairs:stair_concrete_"..name)
			minetest.override_item("mcl_stairs:slab_concrete_"..name, { _doc_items_create_entry = false })
			minetest.override_item("mcl_stairs:slab_concrete_"..name.."_double", { _doc_items_create_entry = false })
			minetest.override_item("mcl_stairs:stair_concrete_"..name, { _doc_items_create_entry = false })
		else
			minetest.override_item("mcl_stairs:slab_concrete_"..name, { _doc_items_entry_name = S("Concrete Slab") })
			minetest.override_item("mcl_stairs:slab_concrete_"..name.."_double", { _doc_items_entry_name = S("Double Concrete Slab") })
			minetest.override_item("mcl_stairs:stair_concrete_"..name, { _doc_items_entry_name = S("Concrete Stairs") })
		end
	end
end
