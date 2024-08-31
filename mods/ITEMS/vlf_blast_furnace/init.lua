local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)

vlf_furnaces.register_furnace("vlf_blast_furnace:blast_furnace", {
	cook_group = "blast_furnace_smeltable",
	factor = 2,
	node_normal = {
		description = S("Blast Furnace"),
		_tt_help = S("Smelts ores faster than furnace"),
		_doc_items_longdesc = S(
			"Blast Furnaces smelt several items, mainly ores and armor, using a furnace fuel, but twice as fast as a normal furnace."),
		_doc_items_usagehelp =
			S("Use the blast furnace to open the furnace menu.") .. "\n" ..
			S("Place a furnace fuel in the lower slot and the source material in the upper slot.") .. "\n" ..
			S("The blast furnace will slowly use its fuel to smelt the item.") .. "\n" ..
			S("The result will be placed into the output slot at the right side.") .. "\n" ..
			S("Use the recipe book to see what ores you can smelt, what you can use as fuel and how long it will burn."),
		_doc_items_hidden = false,
		tiles = {
			"blast_furnace_top.png", "blast_furnace_top.png",
			"blast_furnace_side.png", "blast_furnace_side.png",
			"blast_furnace_side.png", "blast_furnace_front.png"
		},
	},
	node_active = {
		description = S("Burning Blast Furnace"),
		_doc_items_create_entry = false,
		tiles = {
			"blast_furnace_top.png", "blast_furnace_top.png",
			"blast_furnace_side.png", "blast_furnace_side.png",
			"blast_furnace_side.png", {
				name = "blast_furnace_front_on.png",
				animation = { type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 48 }
			},
		},
		drop = "vlf_blast_furnace:blast_furnace",
	},
})

minetest.register_craft({
	output = "vlf_blast_furnace:blast_furnace",
	recipe = {
		{ "vlf_core:iron_ingot",   "vlf_core:iron_ingot",   "vlf_core:iron_ingot" },
		{ "vlf_core:iron_ingot",   "vlf_furnaces:furnace",  "vlf_core:iron_ingot" },
		{ "vlf_core:stone_smooth", "vlf_core:stone_smooth", "vlf_core:stone_smooth" },
	}
})

-- Add entry alias for the Help
if minetest.get_modpath("doc") then
	doc.add_entry_alias("nodes", "vlf_blast_furnace:blast_furnace", "nodes", "vlf_blast_furnace:blast_furnace_active")
end
