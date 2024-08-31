-- Glass nodes
local S = minetest.get_translator(minetest.get_current_modname())
local mod_doc = minetest.get_modpath("doc")

minetest.register_node("vlf_core:glass", {
	description = S("Glass"),
	_doc_items_longdesc = S("A decorative and mostly transparent block."),
	drawtype = "glasslike_framed_optional",
	is_ground_content = false,
	tiles = {"default_glass.png", "default_glass_detail.png"},
	paramtype = "light",
	paramtype2 = "glasslikeliquidlevel",
	sunlight_propagates = true,
	groups = {handy=1, glass=1, building_block=1, material_glass=1},
	sounds = vlf_sounds.node_sound_glass_defaults(),
	drop = "",
	_vlf_blast_resistance = 0.3,
	_vlf_hardness = 0.3,
	_vlf_silk_touch_drop = true,
})

local messy_textures = {
	["grey"] = "gray",
}

------------------------
-- Create Color Glass --
------------------------
local canonical_color = "yellow"

for color,colordef in pairs(vlf_dyes.colors) do
	local longdesc, create_entry, entry_name
	if mod_doc then
		if color == canonical_color then
			longdesc = S("Stained glass is a decorative and mostly transparent block which comes in various different colors.")
			entry_name = S("Stained Glass")
		else
			create_entry = false
		end
	end
	local texcol = color
	if messy_textures[color] then
		texcol = messy_textures[color]
	end
	minetest.register_node("vlf_core:glass_"..color, {
		description = S("@1 Stained Glass", colordef.readable_name),
		_doc_items_create_entry = create_entry,
		_doc_items_entry_name = entry_name,
		_doc_items_longdesc = longdesc,
		drawtype = "glasslike_framed_optional",
		is_ground_content = false,
		tiles = {"vlf_core_glass_"..texcol..".png", "vlf_core_glass_"..texcol.."_detail.png"},
		paramtype = "light",
		paramtype2 = "glasslikeliquidlevel",
		sunlight_propagates = true,
		use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "blend" or true,
		groups = {handy=1, glass=1, building_block=1, material_glass=1, ["basecolor_"..color] = 1},
		sounds = vlf_sounds.node_sound_glass_defaults(),
		drop = "",
		_vlf_blast_resistance = 0.3,
		_vlf_hardness = 0.3,
		_vlf_silk_touch_drop = true,
	})

	minetest.register_craft({
		output = "vlf_core:glass_"..color.." 8",
		recipe = {
			{"vlf_core:glass","vlf_core:glass","vlf_core:glass"},
			{"vlf_core:glass","vlf_dyes:"..color,"vlf_core:glass"},
			{"vlf_core:glass","vlf_core:glass","vlf_core:glass"},
		}
	})

	if mod_doc and color ~= canonical_color then
		doc.add_entry_alias("nodes", "vlf_core:glass_"..canonical_color, "nodes", "vlf_core:glass_"..color)
	end
end

-- legacy: for some reason glass was the only place where grey was spelled with an a
minetest.register_alias("vlf_core:glass_gray","vlf_core:glass_grey")
