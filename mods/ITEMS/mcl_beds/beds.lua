local S = minetest.get_translator(minetest.get_current_modname())
local mod_doc = minetest.get_modpath("doc")


local colors = {
	-- { ID, decription, wool, dye }
	{ "red", S("Red Bed"), "mcl_wool:red", "mcl_dyes:red" },
	{ "blue", S("Blue Bed"), "mcl_wool:blue", "mcl_dyes:blue" },
	{ "cyan", S("Cyan Bed"), "mcl_wool:cyan", "mcl_dyes:cyan" },
	{ "grey", S("Grey Bed"), "mcl_wool:grey", "mcl_dyes:dark_grey" },
	{ "silver", S("Light Grey Bed"), "mcl_wool:silver", "mcl_dyes:grey" },
	{ "black", S("Black Bed"), "mcl_wool:black", "mcl_dyes:black" },
	{ "yellow", S("Yellow Bed"), "mcl_wool:yellow", "mcl_dyes:yellow" },
	{ "green", S("Green Bed"), "mcl_wool:green", "mcl_dyes:dark_green" },
	{ "magenta", S("Magenta Bed"), "mcl_wool:magenta", "mcl_dyes:magenta" },
	{ "orange", S("Orange Bed"), "mcl_wool:orange", "mcl_dyes:orange" },
	{ "purple", S("Purple Bed"), "mcl_wool:purple", "mcl_dyes:violet" },
	{ "brown", S("Brown Bed"), "mcl_wool:brown", "mcl_dyes:brown" },
	{ "pink", S("Pink Bed"), "mcl_wool:pink", "mcl_dyes:pink" },
	{ "lime", S("Lime Bed"), "mcl_wool:lime", "mcl_dyes:green" },
	{ "light_blue", S("Light Blue Bed"), "mcl_wool:light_blue", "mcl_dyes:lightblue" },
	{ "white", S("White Bed"), "mcl_wool:white", "mcl_dyes:white" },
}
local canonical_color = "red"

for c=1, #colors do
	local colorid = colors[c][1]
	local is_canonical = colorid == canonical_color

	-- Recoloring recipe for white bed
	if minetest.get_modpath("mcl_dye") then
		minetest.register_craft({
			type = "shapeless",
			output = "mcl_beds:bed_"..colorid.."_bottom",
			recipe = { "mcl_beds:bed_white_bottom", colors[c][4] },
		})
	end

	-- Main bed recipe
	local main_recipe
	if minetest.get_modpath("mcl_wool") then
		main_recipe = {
			{colors[c][3], colors[c][3], colors[c][3]},
			{"group:wood", "group:wood", "group:wood"}
		}
	end

	local entry_name, create_entry
	if mod_doc then
		if is_canonical then
			entry_name = S("Bed")
		else
			create_entry = false
		end
	end
	-- Register bed
	mcl_beds.register_bed("mcl_beds:bed_"..colorid, {
		description = colors[c][2],
		_doc_items_entry_name = entry_name,
		_doc_items_create_entry = create_entry,
		inventory_image = "mcl_beds_bed_"..colorid.."_inv.png",
		wield_image = "mcl_beds_bed_"..colorid.."_inv.png",
						
		tiles = {
			"mcl_beds_bed_"..colorid..".png"
		},
		
		recipe = main_recipe,
	})
	if mod_doc and not is_canonical then
		doc.add_entry_alias("nodes", "mcl_beds:bed_"..canonical_color.."_bottom", "nodes", "mcl_beds:bed_"..colorid.."_bottom")
		doc.add_entry_alias("nodes", "mcl_beds:bed_"..canonical_color.."_bottom", "nodes", "mcl_beds:bed_"..colorid.."_top")
	end

end

minetest.register_alias("beds:bed_bottom", "mcl_beds:bed_red_bottom")
minetest.register_alias("beds:bed_top", "mcl_beds:bed_red_top")
