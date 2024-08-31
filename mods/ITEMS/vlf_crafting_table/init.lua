local S = minetest.get_translator(minetest.get_current_modname())
local F = minetest.formspec_escape
local C = minetest.colorize
vlf_crafting_table = {}

vlf_crafting_table.formspec = table.concat({
	"formspec_version[4]",
	"size[11.75,10.425]",

	"label[2.25,0.375;" .. F(C(vlf_formspec.label_color, S("Crafting"))) .. "]",

	vlf_formspec.get_itemslot_bg_v4(2.25, 0.75, 3, 3),
	"list[current_player;craft;2.25,0.75;3,3;]",

	"image[6.125,2;1.5,1;gui_crafting_arrow.png]",

	vlf_formspec.get_itemslot_bg_v4(8.2, 2, 1, 1, 0.2),
	"list[current_player;craftpreview;8.2,2;1,1;]",

	"label[0.375,4.7;" .. F(C(vlf_formspec.label_color, S("Inventory"))) .. "]",

	vlf_formspec.get_itemslot_bg_v4(0.375, 5.1, 9, 3),
	"list[current_player;main;0.375,5.1;9,3;9]",

	vlf_formspec.get_itemslot_bg_v4(0.375, 9.05, 9, 1),
	"list[current_player;main;0.375,9.05;9,1;]",

	"listring[current_player;craft]",
	"listring[current_player;main]",

	--Crafting guide button
	"image_button[0.325,1.95;1.1,1.1;craftguide_book.png;__vlf_craftguide;]",
	"tooltip[__vlf_craftguide;" .. F(S("Recipe book")) .. "]",

	"image_button[6.025,3.175;1,1;vlf_crafting_table_inv_fill.png;__vlf_crafting_fillgrid;]",
	"tooltip[__vlf_crafting_fillgrid;" .. F(S("Fill Craft Grid")) .. "]",
})

function vlf_crafting_table.has_crafting_table(player)
	local wdef = player:get_wielded_item():get_definition()
	local range = wdef and wdef.range or ItemStack():get_definition().range or tonumber(minetest.settings:get("vlf_hand_range")) or 4.5
	return minetest.is_creative_enabled(player:get_player_name()) or minetest.find_node_near(player:get_pos(), range, { "vlf_crafting_table:crafting_table" })
end

function vlf_crafting_table.show_crafting_form(player)
	if not vlf_crafting_table.has_crafting_table(player) then
		return
	end
	local inv = player:get_inventory()
	if inv then
		inv:set_width("craft", 3)
		inv:set_size("craft", 9)
	end

	minetest.show_formspec(player:get_player_name(), "main", vlf_crafting_table.formspec)
end

minetest.register_node("vlf_crafting_table:crafting_table", {
	description = S("Crafting Table"),
	_tt_help = S("3×3 crafting grid"),
	_doc_items_longdesc = S("A crafting table is a block which grants you access to a 3×3 crafting grid which allows you to perform advanced crafts."),
	_doc_items_usagehelp = S("Rightclick the crafting table to access the 3×3 crafting grid."),
	_doc_items_hidden = false,
	is_ground_content = false,
	tiles = { "crafting_workbench_top.png", "default_wood.png", "crafting_workbench_side.png",
		"crafting_workbench_side.png", "crafting_workbench_front.png", "crafting_workbench_front.png" },
	paramtype2 = "facedir",
	groups = { handy = 1, axey = 1, deco_block = 1, material_wood = 1, flammable = -1 },
	on_rightclick = function(pos, node, player, itemstack)
		if not player:get_player_control().sneak then
			vlf_crafting_table.show_crafting_form(player)
		end
	end,
	sounds = vlf_sounds.node_sound_wood_defaults(),
	_vlf_blast_resistance = 2.5,
	_vlf_hardness = 2.5,
})

minetest.register_craft({
	output = "vlf_crafting_table:crafting_table",
	recipe = {
		{ "group:wood", "group:wood" },
		{ "group:wood", "group:wood" }
	},
})

minetest.register_craft({
	type = "fuel",
	recipe = "vlf_crafting_table:crafting_table",
	burntime = 15,
})

minetest.register_alias("crafting:workbench", "vlf_crafting_table:crafting_table")
minetest.register_alias("vlf_inventory:workbench", "vlf_crafting_table:crafting_table")
