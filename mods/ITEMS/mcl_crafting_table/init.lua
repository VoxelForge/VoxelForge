local S = minetest.get_translator(minetest.get_current_modname())
local F = minetest.formspec_escape
local C = minetest.colorize
mcl_crafting_table = {}

mcl_crafting_table.formspec = table.concat({
	"formspec_version[4]",
	"size[11.75,10.425]",

	"label[2.25,0.375;" .. F(C(mcl_formspec.label_color, S("Crafting"))) .. "]",

	mcl_formspec.get_itemslot_bg_v4(2.25, 0.75, 3, 3),
	"list[current_player;craft;2.25,0.75;3,3;]",

	"image[6.125,2;1.5,1;gui_crafting_arrow.png]",

	mcl_formspec.get_itemslot_bg_v4(8.2, 2, 1, 1, 0.2),
	"list[current_player;craftpreview;8.2,2;1,1;]",

	"label[0.375,4.7;" .. F(C(mcl_formspec.label_color, S("Inventory"))) .. "]",

	mcl_formspec.get_itemslot_bg_v4(0.375, 5.1, 9, 3),
	"list[current_player;main;0.375,5.1;9,3;9]",

	mcl_formspec.get_itemslot_bg_v4(0.375, 9.05, 9, 1),
	"list[current_player;main;0.375,9.05;9,1;]",

	"listring[current_player;craft]",
	"listring[current_player;main]",

	--Crafting guide button
	"image_button[0.325,1.95;1.1,1.1;craftguide_book.png;__mcl_craftguide;]",
	"tooltip[__mcl_craftguide;" .. F(S("Recipe book")) .. "]",

	"image_button[6.025,3.175;1,1;mcl_crafting_table_inv_fill.png;__mcl_crafting_fillgrid;]",
	"tooltip[__mcl_crafting_fillgrid;" .. F(S("Fill Craft Grid")) .. "]",
})

function mcl_crafting_table.has_crafting_table(player)
	local wdef = player:get_wielded_item():get_definition()
	local range = wdef and wdef.range or ItemStack():get_definition().range or tonumber(minetest.settings:get("mcl_hand_range")) or 4.5
	return minetest.is_creative_enabled(player:get_player_name()) or minetest.find_node_near(player:get_pos(), range, { "mcl_crafting_table:crafting_table" })
end

function mcl_crafting_table.show_crafting_form(player)
	if not mcl_crafting_table.has_crafting_table(player) then
		return
	end
	local inv = player:get_inventory()
	if inv then
		inv:set_width("craft", 3)
		inv:set_size("craft", 9)
	end

	minetest.show_formspec(player:get_player_name(), "main", mcl_crafting_table.formspec)
end

local function get_recipe_groups(pinv, craft)
	local grid_width = pinv:get_width("craft")
	if craft.width > grid_width then
		return false, "Recipe to large for crafting grid of width " .. grid_width
	end
	local r = { "", "", "", "", "", "", "", "", "" }
	local all_found = true
	local i = 0
	for k = 1, 3 * craft.width do
		local it = craft.items[k]
		if it then
			if it:sub(1,6) == "group:" then
				for _, stack in pairs(pinv:get_list("main")) do
					if minetest.get_item_group(stack:get_name(), it:sub(7)) > 0 then
						r[k+i] = stack:get_name()
					end
				end
				all_found = all_found and r[k+i]
			elseif pinv:contains_item("main", ItemStack(it)) then
				r[k+i] = it
			else
				all_found = false
			end
		end
		-- adapt from craft width to craft grid width
		if (k % craft.width) == 0 then
			i = i + grid_width - craft.width
		end
	end
	if all_found then
		return r
	else
		return false, "Some needed items not available"
	end
end

local function get_count_from_inv(itname, inv, list)
	list = list or "main"
	local c = 0
	for _, stack in pairs(inv:get_list(list)) do
		if stack:get_name() == itname then
			c = c + stack:get_count()
		end
	end
	return c
end

function mcl_crafting_table.put_recipe_from_inv(player, craft)
	mcl_inventory.return_fields(player, "craft")
	local pinv = player:get_inventory()
	if craft.type == "normal" then
		local recipe, msg = get_recipe_groups(pinv, craft)
		if recipe then
			for k,it in pairs(recipe) do
				local pit = ItemStack(it)
				if pinv:room_for_item("craft", pit) then
					local stack = pinv:remove_item("main", pit)
					pinv:set_stack("craft", k, stack)
				end
			end
		else
			minetest.log("error", "Cannot prefill crafting grid: " .. msg)
		end
	end
end

function mcl_crafting_table.fill_grid(player)
	local inv = player:get_inventory()
	local itcounts = {}
	local invcounts = {}
	for idx, stack in pairs(inv:get_list("craft")) do
		local name = stack:get_name()
		if name ~= "" then
			itcounts[name] = (itcounts[name] or 0) + 1
			invcounts[name] = get_count_from_inv(name, inv)
		end
	end
	for idx, tstack in pairs(inv:get_list("craft")) do
		local name = tstack:get_name()
		if itcounts[name] and invcounts[name] then
			local it = ItemStack(name)
			it:set_count(math.min(tstack:get_stack_max() - tstack:get_count(), math.floor(invcounts[name] / itcounts[name] or 1)))
			tstack:add_item(inv:remove_item("main", it))
			inv:set_stack("craft", idx, tstack)
		end
	end
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if fields.__mcl_crafting_fillgrid then
		mcl_crafting_table.fill_grid(player)
	end
end)

minetest.register_node("mcl_crafting_table:crafting_table", {
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
			mcl_crafting_table.show_crafting_form(player)
		end
	end,
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_blast_resistance = 2.5,
	_mcl_hardness = 2.5,
})

minetest.register_craft({
	output = "mcl_crafting_table:crafting_table",
	recipe = {
		{ "group:wood", "group:wood" },
		{ "group:wood", "group:wood" }
	},
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_crafting_table:crafting_table",
	burntime = 15,
})

minetest.register_alias("crafting:workbench", "mcl_crafting_table:crafting_table")
minetest.register_alias("mcl_inventory:workbench", "mcl_crafting_table:crafting_table")
