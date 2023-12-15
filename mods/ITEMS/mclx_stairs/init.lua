local S = minetest.get_translator(minetest.get_current_modname())
local doc_mod = minetest.get_modpath("doc")


mcl_stairs.register_slab("lapisblock", "mcl_core:lapisblock",
		{pickaxey=3},
		{"mcl_core_lapis_block.png", "mcl_core_lapis_block.png", "mcl_stairs_lapis_block_slab.png"},
		S("Lapis Lazuli Slab"),
		nil, nil, nil,
		S("Double Lapis Lazuli Slab"))
mcl_stairs.register_stair("lapisblock", "mcl_core:lapisblock",
		{pickaxey=3},
		{"mcl_stairs_lapis_block_slab.png", "mcl_core_lapis_block.png", "mcl_core_lapis_block.png", "mcl_core_lapis_block.png", "mcl_core_lapis_block.png", "mcl_stairs_lapis_block_slab.png"},
		S("Lapis Lazuli Stairs"),
		nil, 6, nil,
		"woodlike")

mcl_stairs.register_slab("goldblock", "mcl_core:goldblock",
		{pickaxey=4},
		{"default_gold_block.png", "default_gold_block.png", "mcl_stairs_gold_block_slab.png"},
		S("Slab of Gold"),
		nil, nil, nil,
		S("Double Slab of Gold"))
mcl_stairs.register_stair("goldblock", "mcl_core:goldblock",
		{pickaxey=4},
		{"mcl_stairs_gold_block_slab.png", "default_gold_block.png", "default_gold_block.png", "default_gold_block.png", "default_gold_block.png", "mcl_stairs_gold_block_slab.png"},
		S("Stairs of Gold"),
		nil, 6, nil,
		"woodlike")

mcl_stairs.register_slab("ironblock", "mcl_core:ironblock",
		{pickaxey=2},
		{"default_steel_block.png", "default_steel_block.png", "mcl_stairs_iron_block_slab.png"},
		S("Slab of Iron"),
		nil, nil, nil,
		S("Double Slab of Iron"))
mcl_stairs.register_stair("ironblock", "mcl_core:ironblock",
		{pickaxey=2},
		{"mcl_stairs_iron_block_slab.png", "default_steel_block.png", "default_steel_block.png", "default_steel_block.png", "default_steel_block.png", "mcl_stairs_iron_block_slab.png"},
		S("Stairs of Iron"),
		nil, 6, nil,
		"woodlike")

mcl_stairs.register_stair("stonebrickcracked", "mcl_core:stonebrickcracked",
		{pickaxey=1},
		{"mcl_core_stonebrick_cracked.png"},
		S("Cracked Stone Brick Stairs"),
		mcl_sounds.node_sound_stone_defaults(), 6, 1.5,
		"woodlike")

mcl_stairs.register_slab("stonebrickcracked", "mcl_core:stonebrickcracked",
		{pickaxey=1},
		{"mcl_core_stonebrick_cracked.png"},
		S("Cracked Stone Brick Slab"),
		mcl_sounds.node_sound_stone_defaults(), 6, 2,
		S("Double Cracked Stone Brick Slab"))

local canonical_color = "yellow"
for name,cdef in pairs(mcl_dyes.colors) do
	local is_canonical = name == canonical_color
	mcl_stairs.register_stair_and_slab_simple("concrete_"..name, "mcl_colorblocks:concrete_"..name,
		S(cdef.readable_name.. " Concrete Stairs"),
		S(cdef.readable_name.. " Concrete Slab"),
		S(cdef.readable_name.. " Double Slab"))

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
