minetest.register_craftitem(":mcl_mobitems:phantom_membrane", {
	description = ("Phantom Membrane"),
	_tt_help = ("Use to repair the elytra"),
	_doc_items_longdesc = ("Dropped by the phantom."),
	_doc_items_usagehelp = ("The phantom membrane is dropped by phantoms and can be used to repair the elytra."),
	inventory_image = "mcl_mobitems_phantom_membrane.png",
	wield_image = "mcl_mobitems_phantom_membrane.png",
	groups = { craftitem = 1 },
})

minetest.register_craftitem(":mcl_mobitems:armadillo_scute", {
	description = ("Armadillo Scute"),
	_doc_items_longdesc = ("Use it to repair and craft wolf armor"),
	inventory_image = "mcl_mobitems_armadillo_scute.png",
	groups = { craftitem = 1 },
})

minetest.register_tool(":mcl_mobitems:wolf_armor", {
	description = ("Wolf Armor"),
	_doc_items_longdesc = ("Wolf armor can be worn by wolves to greatly increase their protection from harm."),
	inventory_image = "mobs_mc_wolf_armor_inventory.png^[multiply:#ffbdb9",
	_wolf_overlay_image = "(mobs_mc_wolf_armor.png^[multiply:#ffbdb9)^mobs_mc_wolf_armor_overlay_no_color.png",
	stack_max = 1,
	groups = {wolf_armor = 45},
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level = 0,
		groupcaps = {
			fleshy = {times = {[1] = 1.60}, uses = 64, maxlevel = 1},
		},
		damage_groups = {fleshy = 0},
	},
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_diamond",
	},
})

-- Color definitions for the wolf armors
local colordefs = {
	-- {name, dye}
	{"black", "Black"},
	{"blue", "Blue"},
	{"brown", "Brown"},
	{"cyan", "Cyan"},
	{"green", "Green"},
	{"grey", "Grey"},
	{"light_blue", "Light Blue"},
	{"light_grey", "Light Grey"},
	{"lime", "Lime"},
	{"magenta", "Magenta"},
	{"orange", "Orange"},
	{"pink", "Pink"},
	{"purple", "Purple"},
	{"red", "Red"},
	{"white", "White"},
	{"yellow", "Yellow"}
}

-- Function to register colored wolf armor based on dye combinations
local function register_colored_wolf_armor(color_name, color_display_name, dye_color)
	local item_name = ":mcl_mobitems:wolf_armor_" .. color_name
	local description = (color_display_name .. " Wolf Armor")

	-- Base armor image and overlay image
	local base_image = "(mobs_mc_wolf_armor_inventory.png^[multiply:#ffbdb9)"
	local overlay_image = "mobs_mc_wolf_armor_inventory_overlay.png"

	local wolf_base_image = "(mobs_mc_wolf_armor.png^[multiply:#ffbdb9)"
	local wolf_overlay_image = "mobs_mc_wolf_armor_overlay_desat.png"
	local wolf_combined_image
	local combined_image

	if dye_color then
		combined_image = base_image .. "^(" .. overlay_image .. "^[multiply:" .. dye_color .. ")"
		wolf_combined_image = wolf_base_image .. "^(" .. wolf_overlay_image .. "^[multiply:" .. dye_color .. ")"
	else
		combined_image = base_image .. "^" .. overlay_image
		wolf_combined_image = wolf_base_image .. "^" .. overlay_image
	end

	minetest.register_tool(item_name, {
		description = description,
		_doc_items_longdesc = ("Wolf armor can be worn by wolves to greatly increase their protection from harm."),
		inventory_image = combined_image,  -- Combine base and colored overlay images
		_wolf_overlay_image = wolf_combined_image,
		stack_max = 1,
		groups = {wolf_armor = 45, not_in_creative_inventory=1},
		tool_capabilities = {
			full_punch_interval = 1.0,
			max_drop_level = 0,
			groupcaps = {
				fleshy = {times = {[1] = 1.60}, uses = 64, maxlevel = 1},
			},
			damage_groups = {fleshy = 0},
		},
		sounds = {
			_mcl_armor_equip = "mcl_armor_equip_diamond",
		},
	})
end

-- Register all colors from colordefs
for _, color_def in ipairs(colordefs) do
	register_colored_wolf_armor(color_def[1], color_def[2], color_def[1])
end

-- Function to register crafts for colored wolf armor
local function register_wolf_armor_craft(color_name, dye_item)
	if not color_name or not dye_item then
		return
	end

	minetest.register_craft({
		type = "shapeless",
		output = "mcl_mobitems:wolf_armor_" .. color_name,
		recipe = {"mcl_mobitems:wolf_armor", "mcl_dyes:" .. dye_item},
	})
end

-- Register crafts for all colors defined in colordefs
for _, color_def in ipairs(colordefs) do
	local color_name = color_def[1]
	local dye_item = color_def[1]
	if color_name and dye_item then
		register_wolf_armor_craft(color_name, dye_item)
	end
end
