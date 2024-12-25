local S = minetest.get_translator(minetest.get_current_modname())
local D = vlf_util.get_dynamic_translator()

local messy_textures = { --translator table for the bed texture filenames names not adhering to the common color names of vlf_dyes
	["lightblue"] = "light_blue",
}

local canonical_color = "red"

for color, colordef in pairs(vlf_dyes.colors) do
	local is_canonical =

	minetest.register_craft({
		type = "shapeless",
		output = "vlf_beds:bed_"..color.."_bottom",
		recipe = { "group:bed", "vlf_dyes:"..color }
	})

	local entry_name, create_entry
	if is_canonical then
		entry_name = S("Bed")
	else
		create_entry = false
	end
	local texcol = color
	if messy_textures[color] then
		texcol = messy_textures[color]
	end
	-- Register bed
	vlf_beds.register_bed("vlf_beds:bed_"..color, {
		description = D(colordef.readable_name .. " Bed"),
		_doc_items_entry_name = entry_name,
		_doc_items_create_entry = create_entry,
		inventory_image = "vlf_beds_bed_"..texcol.."_inv.png",
		wield_image = "vlf_beds_bed_"..texcol.."_inv.png",

		tiles = {
			"vlf_beds_bed_"..texcol..".png"
		},
		recipe = {
			{"vlf_wool:"..color, "vlf_wool:"..color, "vlf_wool:"..color},
			{"group:wood", "group:wood", "group:wood"}
		},
	})

	if not is_canonical then
		doc.add_entry_alias("nodes", "vlf_beds:bed_"..canonical_color.."_bottom", "nodes", "vlf_beds:bed_"..color.."_bottom")
		doc.add_entry_alias("nodes", "vlf_beds:bed_"..canonical_color.."_bottom", "nodes", "vlf_beds:bed_"..color.."_top")
	end

	-- Alias old non-uniform node names
	if messy_textures[color] then
		minetest.register_alias("vlf_beds:bed_"..texcol.."_top","vlf_beds:bed_"..color.."_top")
		minetest.register_alias("vlf_beds:bed_"..texcol.."_bottom","vlf_beds:bed_"..color.."_bottom")
	end
end

minetest.register_alias("beds:bed_bottom", "vlf_beds:bed_red_bottom")
minetest.register_alias("beds:bed_top", "vlf_beds:bed_red_top")
