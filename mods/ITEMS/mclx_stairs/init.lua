local S = minetest.get_translator(minetest.get_current_modname())
local doc_mod = minetest.get_modpath("doc")
local extra_nodes = minetest.settings:get_bool("mcl_extra_nodes", true)

mcl_stairs.register_stair_and_slab("lapisblock", {
	baseitem="mcl_core:lapisblock",
	basedesc=S("Lapis Lazuli"),
	recipeitem=extra_nodes and "mcl_core:lapisblock" or "",
	extra_groups={not_in_creative_inventory=extra_nodes and 0 or 1},
	tiles={"mcl_core_lapis_block.png", "mcl_core_lapis_block.png", "mcl_stairs_lapis_block_slab.png"},
})
mcl_stairs.register_stair_and_slab("lapisblock", {
	baseitem="mcl_core:lapisblock",
	basedesc=S("Lapis Lazuli"),
	recipeitem=extra_nodes and "mcl_core:lapisblock" or "",
	extra_groups={not_in_creative_inventory=extra_nodes and 0 or 1},
})

mcl_stairs.register_stair_and_slab("goldblock", {
	baseitem="mcl_core:goldblock",
	basedesc=S("Gold"),
	recipeitem=extra_nodes and "mcl_core:goldblock" or "",
	extra_groups={not_in_creative_inventory=extra_nodes and 0 or 1},
	tiles={"default_gold_block.png", "default_gold_block.png", "mcl_stairs_gold_block_slab.png"},
})
mcl_stairs.register_stair_and_slab("goldblock", {
	baseitem="mcl_core:goldblock",
	basedesc=S("Gold"),
	recipeitem=extra_nodes and "mcl_core:goldblock" or "",
	extra_groups={not_in_creative_inventory=extra_nodes and 0 or 1},
})

mcl_stairs.register_stair_and_slab("ironblock", {
	baseitem="mcl_core:ironblock",
	basedesc=S("Iron"),
	recipeitem=extra_nodes and "mcl_core:ironblock" or "",
	extra_groups={not_in_creative_inventory=extra_nodes and 0 or 1},
	tiles={"default_steel_block.png", "default_steel_block.png", "mcl_stairs_iron_block_slab.png"},
})
mcl_stairs.register_stair_and_slab("ironblock", {
	baseitem="mcl_core:ironblock",
	basedesc=S("Iron"),
	recipeitem=extra_nodes and "mcl_core:ironblock" or "",
	extra_groups={not_in_creative_inventory=extra_nodes and 0 or 1},
})

mcl_stairs.register_stair_and_slab("stonebrickcracked", {
	baseitem="mcl_core:stonebrickcracked",
	basedesc=S("Cracked Stone Brick"),
	recipeitem=extra_nodes and "mcl_core:stonebrickcracked" or "",
	extra_groups={not_in_creative_inventory=extra_nodes and 0 or 1},
	tiles={"mcl_core_stonebrick_cracked.png"},
})
mcl_stairs.register_stair_and_slab("stonebrickcracked", {
	baseitem="mcl_core:stonebrickcracked",
	basedesc=S("Cracked Stone Brick"),
	recipeitem=extra_nodes and "mcl_core:stonebrickcracked" or "",
	extra_groups={not_in_creative_inventory=extra_nodes and 0 or 1},
	tiles={"mcl_core_stonebrick_cracked.png"},
})

local canonical_color = "yellow"
for name,cdef in pairs(mcl_dyes.colors) do
	local is_canonical = name == canonical_color
	mcl_stairs.register_stair_and_slab("concrete_"..name, {
		extra_groups={not_in_creative_inventory=extra_nodes and 0 or 1},
		baseitem="mcl_colorblocks:concrete_"..name,
		recipeitem=extra_nodes and "mcl_core:stonebrickcracked" or "",
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
