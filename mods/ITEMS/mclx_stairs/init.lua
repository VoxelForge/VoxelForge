local S = minetest.get_translator(minetest.get_current_modname())
local D = mcl_util.get_dynamic_translator()
local extra_nodes = minetest.settings:get_bool("mcl_extra_nodes", true)

mcl_stairs.register_stair("lapisblock", {
	baseitem="mcl_core:lapisblock",
	description=S("Lapis Lazuli Stairs"),
	recipeitem=extra_nodes and "mcl_core:lapisblock" or "",
	groups={not_in_creative_inventory=extra_nodes and 0 or 1},
})
mcl_stairs.register_slab("lapisblock", {
	baseitem="mcl_core:lapisblock",
	description=S("Lapis Lazuli Slab"),
	recipeitem=extra_nodes and "mcl_core:lapisblock" or "",
	groups={not_in_creative_inventory=extra_nodes and 0 or 1},
	tiles={"mcl_core_lapis_block.png", "mcl_core_lapis_block.png", "mcl_stairs_lapis_block_slab.png"},
})

mcl_stairs.register_stair("goldblock", {
	baseitem="mcl_core:goldblock",
	description=S("Gold Stairs"),
	recipeitem=extra_nodes and "mcl_core:goldblock" or "",
	groups={not_in_creative_inventory=extra_nodes and 0 or 1},
})
mcl_stairs.register_slab("goldblock", {
	baseitem="mcl_core:goldblock",
	description=S("Gold Slab"),
	recipeitem=extra_nodes and "mcl_core:goldblock" or "",
	groups={not_in_creative_inventory=extra_nodes and 0 or 1},
	tiles={"default_gold_block.png", "default_gold_block.png", "mcl_stairs_gold_block_slab.png"},
})

mcl_stairs.register_stair("ironblock", {
	baseitem="mcl_core:ironblock",
	description=S("Iron Stairs"),
	recipeitem=extra_nodes and "mcl_core:ironblock" or "",
	groups={not_in_creative_inventory=extra_nodes and 0 or 1},
})
mcl_stairs.register_slab("ironblock", {
	baseitem="mcl_core:ironblock",
	description=S("Iron Slab"),
	recipeitem=extra_nodes and "mcl_core:ironblock" or "",
	groups={not_in_creative_inventory=extra_nodes and 0 or 1},
	tiles={"default_steel_block.png", "default_steel_block.png", "mcl_stairs_iron_block_slab.png"},
})

mcl_stairs.register_stair_and_slab("stonebrickcracked", {
	baseitem="mcl_core:stonebrickcracked",
	description_stair=S("Cracked Stone Brick Stairs"),
	description_slab=S("Cracked Stone Brick Slab"),
	recipeitem=extra_nodes and "mcl_core:stonebrickcracked" or "",
	groups={not_in_creative_inventory=extra_nodes and 0 or 1},
})
mcl_stairs.register_stair_and_slab("deepslate_bricks_cracked", {
	baseitem="mcl_deepslate:deepslate_bricks_cracked",
	description_stair=S("Cracked Deepslate Brick Stairs"),
	description_slab=S("Cracked Deepslate Brick Slab"),
	recipeitem=extra_nodes and "mcl_deepslate:deepslate_bricks_cracked" or "",
	groups={not_in_creative_inventory=extra_nodes and 0 or 1},
})
mcl_stairs.register_stair_and_slab("deepslate_tiles_cracked", {
	baseitem="mcl_deepslate:deepslate_tiles_cracked",
	description_stair=S("Cracked Deepslate Tile Stairs"),
	description_slab=S("Cracked Deepslate Tile Slab"),
	recipeitem=extra_nodes and "mcl_deepslate:deepslate_tiles_cracked" or "",
	groups={not_in_creative_inventory=extra_nodes and 0 or 1},
})

mcl_stairs.register_stair_and_slab("end_stone", {
	baseitem = "mcl_end:end_stone",
	description_stair=S("End Stone Stairs"),
	description_slab=S("End Stone Slab"),
	recipeitem = extra_nodes and "mcl_end:end_stone" or "",
	overrides = {_mcl_stonecutter_recipes = {"mcl_end:end_stone"}},
	groups = {not_in_creative_inventory=extra_nodes and 0 or 1},
})

mcl_stairs.register_stair("stone", {
	baseitem = "mcl_core:stone_smooth",
	description=S("Smooth Stone Stairs"),
	recipeitem = extra_nodes and "mcl_core:stone_smooth" or "",
	overrides = {_mcl_stonecutter_recipes = {"mcl_core:stone_smooth"}},
	groups = {not_in_creative_inventory = extra_nodes and 0 or 1},
})

mcl_stairs.register_stair_and_slab("hardened_clay", {
	baseitem="mcl_colorblocks:hardened_clay",
	description_stair = S("Terracotta Stairs"),
	description_slab = S("Terracotta Slab"),
	recipeitem=extra_nodes and "mcl_colorblocks:hardened_clay" or "",
	groups={not_in_creative_inventory=extra_nodes and 0 or 1},
})

local canonical_color = "yellow"
for name,cdef in pairs(mcl_dyes.colors) do
	local is_canonical = name == canonical_color
	local concrete_defs = core.registered_nodes["mcl_colorblocks:concrete_" .. name]
	local clay_defs = core.registered_nodes["mcl_colorblocks:hardened_clay_" .. name]

	concrete_defs.groups.stonecuttable = extra_nodes and 1
	clay_defs.groups.stonecuttable = extra_nodes and 1

	mcl_stairs.register_stair_and_slab("concrete_"..name, {
		description_stair = D(cdef.readable_name .. " Concrete Stairs"),
		description_slab = D(cdef.readable_name .. " Concrete Slab"),
		groups={not_in_creative_inventory=extra_nodes and 0 or 1},
		baseitem="mcl_colorblocks:concrete_"..name,
		recipeitem=extra_nodes and "mcl_colorblocks:concrete_"..name or "",
		overrides = {_mcl_stonecutter_recipes = {"mcl_colorblocks:concrete_"..name}}
	})

	mcl_stairs.register_stair_and_slab("hardened_clay_"..name, {
		description_stair = D(cdef.readable_name .. " Terracotta Stairs"),
		description_slab = D(cdef.readable_name .. " Terracotta Slab"),
		groups={not_in_creative_inventory=extra_nodes and 0 or 1},
		baseitem="mcl_colorblocks:hardened_clay_"..name,
		recipeitem=extra_nodes and "mcl_colorblocks:hardened_clay_"..name or "",
		overrides = {_mcl_stonecutter_recipes = {"mcl_colorblocks:hardened_clay_"..name}}
	})


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

	if not is_canonical then
		doc.add_entry_alias("nodes", "mcl_stairs:slab_hardened_clay_"..canonical_color, "nodes", "mcl_stairs:slab_hardened_clay_"..name)
		doc.add_entry_alias("nodes", "mcl_stairs:slab_hardened_clay_"..canonical_color.."_double", "nodes", "mcl_stairs:slab_hardened_clay_"..name.."_double")
		doc.add_entry_alias("nodes", "mcl_stairs:stair_hardened_clay_"..canonical_color, "nodes", "mcl_stairs:stair_hardened_clay_"..name)
		minetest.override_item("mcl_stairs:slab_hardened_clay_"..name, { _doc_items_create_entry = false })
		minetest.override_item("mcl_stairs:slab_hardened_clay_"..name.."_double", { _doc_items_create_entry = false })
		minetest.override_item("mcl_stairs:stair_hardened_clay_"..name, { _doc_items_create_entry = false })
	else
		minetest.override_item("mcl_stairs:slab_hardened_clay_"..name, { _doc_items_entry_name = S("Terracotta Slab") })
		minetest.override_item("mcl_stairs:slab_hardened_clay_"..name.."_double", { _doc_items_entry_name = S("Double Terracotta Slab") })
		minetest.override_item("mcl_stairs:stair_hardened_clay_"..name, { _doc_items_entry_name = S("Terracotta Stairs") })
	end

end
