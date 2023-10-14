local modname			   = minetest.get_current_modname()
local mod_registername	  = modname .. ":"
local S					 = minetest.get_translator(modname)

for _, template_name in pairs(mcl_armor.trims.overlays) do
	minetest.register_craftitem(mod_registername .. template_name, {
		description	  = S("Smithing Template '@1'", template_name),
		inventory_image  = template_name .. "_armor_trim_smithing_template.png",
		groups = { smithing_template  = 1 },
	})

	minetest.register_craft({
		output = mod_registername .. template_name .. " 2",
		recipe = {
			{"mcl_core:diamond",mod_registername .. template_name,"mcl_core:diamond"},
			{"mcl_core:diamond","mcl_core:cobble","mcl_core:diamond"},
			{"mcl_core:diamond","mcl_core:diamond","mcl_core:diamond"},
		}
	})
end
