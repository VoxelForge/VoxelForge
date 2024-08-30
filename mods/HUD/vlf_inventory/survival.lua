local S = minetest.get_translator("vlf_inventory")
local F = minetest.formspec_escape

vlf_inventory.registered_survival_inventory_tabs = {}

function vlf_inventory.register_survival_inventory_tab(def)
	if #vlf_inventory.registered_survival_inventory_tabs == 7 then
		error("Too many tabs registered!")
	end

	assert(def.id)
	assert(def.description)
	assert(def.item_icon)
	assert(def.build)
	assert(def.handle)

	for _, d in ipairs(vlf_inventory.registered_survival_inventory_tabs) do
		assert(d.id ~= def.id, "Another tab exists with the same name!")
	end

	if not def.access then
		function def.access(_)
			return true
		end
	end

	if def.show_inventory == nil then
		def.show_inventory = true
	end

	table.insert(vlf_inventory.registered_survival_inventory_tabs, def)
end

local player_current_tab = {}

minetest.register_on_joinplayer(function(player)
	player_current_tab[player] = "main"
end)

minetest.register_on_leaveplayer(function(player)
	player_current_tab[player] = nil
end)

local function build_page(_, content, inventory, tabname)
	local tab_buttons = "style_type[image;noclip=true]"

	if #vlf_inventory.registered_survival_inventory_tabs ~= 1 then
		for i, d in ipairs(vlf_inventory.registered_survival_inventory_tabs) do
			local btn_name = "tab_" .. d.id

			tab_buttons = tab_buttons .. table.concat({
				"style[" .. btn_name .. ";border=false;bgimg=;bgimg_pressed=;noclip=true]",
				"image[" ..
					(0.2 + (i - 1) * 1.6) ..
					",-1.34;1.5,1.44;" .. (tabname == d.id and "crafting_creative_active.png" or "crafting_creative_inactive.png") ..
					"]",
				"item_image_button[" .. (0.44 + (i - 1) * 1.6) .. ",-1.1;1,1;" .. d.item_icon .. ";" .. btn_name .. ";]",
				"tooltip[" .. btn_name .. ";" .. F(d.description) .. "]"
			})
		end
	end

	return table.concat({
		"formspec_version[6]",
		"size[11.75,10.9]",

		inventory and table.concat({
			--Main inventory
			vlf_formspec.get_itemslot_bg_v4(0.375, 5.575, 9, 3),
			"list[current_player;main;0.375,5.575;9,3;9]",

			--Hotbar
			vlf_formspec.get_itemslot_bg_v4(0.375, 9.525, 9, 1),
			"list[current_player;main;0.375,9.525;9,1;]"
		}) or "",

		content,
		tab_buttons,
	})
end

local main_page_static = table.concat({
	--Armor slots
	vlf_formspec.get_itemslot_bg_v4(0.375, 0.375, 1, 4),
	"list[current_player;armor;0.375,0.375;1,1;1]",
	"list[current_player;armor;0.375,1.625;1,1;2]",
	"list[current_player;armor;0.375,2.875;1,1;3]",
	"list[current_player;armor;0.375,4.125;1,1;4]",

	--Player model background
	"image[1.57,0.343;3.62,4.85;vlf_inventory_background9.png;2]",

	--Offhand
	vlf_formspec.get_itemslot_bg_v4(5.375, 4.125, 1, 1),
	"list[current_player;offhand;5.375,4.125;1,1]",

	--Craft grid
	"label[6.61,0.5;" .. F(minetest.colorize(vlf_formspec.label_color, S("Crafting"))) .. "]",

	vlf_formspec.get_itemslot_bg_v4(6.625, 0.875, 2, 2),
	"list[current_player;craft;6.625,0.875;2,2]",

	"image[9.125,1;1,1;crafting_formspec_arrow.png]",

	vlf_formspec.get_itemslot_bg_v4(10.375, 1, 1, 1),
	"list[current_player;craftpreview;10.375,1;1,1;]",

	"image_button[9.125,2.125;1,1;vlf_crafting_table_inv_fill.png;__vlf_crafting_fillgrid;]",
	"tooltip[__vlf_crafting_fillgrid;" .. F(S("Fill Craft Grid")) .. "]",

	--Crafting guide button
	"image_button[6.575,4.075;1.1,1.1;craftguide_book.png;__vlf_craftguide;]",
	"tooltip[__vlf_craftguide;" .. F(S("Recipe book")) .. "]",

	--Help button
	"image_button[7.825,4.075;1.1,1.1;doc_button_icon_lores.png;__vlf_doc;]",
	"tooltip[__vlf_doc;" .. F(S("Help")) .. "]",

	--Skins button
	"image_button[9.075,4.075;1.1,1.1;vlf_skins_button.png;__vlf_skins;]",
	"tooltip[__vlf_skins;" .. F(S("Select player skin")) .. "]",

	--Achievements button
	"image_button[10.325,4.075;1.1,1.1;vlf_achievements_button.png;__vlf_achievements;]",
	"tooltip[__vlf_achievements;" .. F(S("Achievements")) .. "]",

	--Listring
	"listring[current_player;main]",
	"listring[current_player;sorter]",
	"listring[current_player;main]",
	"listring[current_player;craft]",
	"listring[current_player;main]",
	"listring[current_player;armor]",
	"listring[current_player;main]",
	"listring[current_player;offhand]",
	"listring[current_player;main]",
})

vlf_inventory.register_survival_inventory_tab({
	id = "main",
	description = "Main Inventory",
	item_icon = "vlf_crafting_table:crafting_table",
	show_inventory = true,
	build = function(player)
		local inv = player:get_inventory()

		local armor_slots = { "helmet", "chestplate", "leggings", "boots" }
		local armor_slot_imgs = ""

		for a = 1, 4 do
			if inv:get_stack("armor", a + 1):is_empty() then
				armor_slot_imgs = armor_slot_imgs ..
					"image[0.375," .. (0.375 + (a - 1) * 1.25) .. ";1,1;vlf_inventory_empty_armor_slot_" .. armor_slots[a] .. ".png]"
			end
		end

		if inv:get_stack("offhand", 1):is_empty() then
			armor_slot_imgs = armor_slot_imgs .. "image[5.375,4.125;1,1;vlf_inventory_empty_armor_slot_shield.png]"
		end
		return main_page_static .. armor_slot_imgs .. vlf_player.get_player_formspec_model(player, 1.57, 0.4, 3.62, 4.85, "")
	end,
	handle = function() end,
})

--[[
vlf_inventory.register_survival_inventory_tab({
	id = "test",
	description = "Test",
	item_icon = "vlf_core:stone",
	show_inventory = true,
	build = function(player)
		return "label[1,1;Hello hello]button[2,2;2,2;Hello;hey]"
	end,
	handle = function(player, fields)
		print(dump(fields))
	end,
})]]

function vlf_inventory.build_survival_formspec(player)
	local inv = player:get_inventory()

	inv:set_width("craft", 2)
	inv:set_size("craft", 4)

	local tab = player_current_tab[player]

	local tab_def = nil

	for _, d in ipairs(vlf_inventory.registered_survival_inventory_tabs) do
		if tab == d.id then
			tab_def = d
			break
		end
	end
	local form

	if tab_def then
		form = build_page(player, tab_def.build(player), tab_def.show_inventory, tab)
	end

	return form
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "" and #vlf_inventory.registered_survival_inventory_tabs ~= 1 and
		player:get_meta():get_string("gamemode") ~= "creative" then
		for _, d in ipairs(vlf_inventory.registered_survival_inventory_tabs) do
			if fields["tab_" .. d.id] and d.access(player) then
				player_current_tab[player] = d.id
				vlf_inventory.update_inventory(player)
				break
			end
		end

		for _, d in ipairs(vlf_inventory.registered_survival_inventory_tabs) do
			if player_current_tab[player] == d.id and d.access(player) then
				d.handle(player, fields)
				return
			end
		end
	end
end)

local function sort_stack(stack)
	if minetest.get_item_group(stack:get_name(), "offhand_item") > 0 then
		return "offhand"
	elseif minetest.get_item_group(stack:get_name(), "armor") > 0 then
		return "armor"
	end
end

local function find_empty_inv_slots(inv)
	local main, hotbar
	for i, stack in pairs(inv:get_list("main")) do
		if i > 9 and not main and stack:is_empty() then
			main = i
		elseif i <= 9 and not hotbar and stack:is_empty() then
			hotbar = i
		end
		if hotbar and main then break end
	end
	return main, hotbar
end

minetest.register_on_player_inventory_action(function(player, action, inv, info)
	if action == "move" and info.to_list == "sorter" then
		local stack = inv:get_stack(info.to_list, info.to_index)
		local trg = sort_stack(stack)
		local empty_main, empty_hotbar = find_empty_inv_slots(inv)
		if trg then
			if trg == "armor" then
				local newstack = vlf_armor.equip(stack, player, true)
				if newstack and not newstack:is_empty() then
					if inv:get_stack(info.from_list, info.from_index):is_empty() then
						inv:set_stack(info.from_list, info.from_index, newstack)
					elseif inv:room_for_item(info.from_list, newstack) then
						inv:add_item(info.from_list, newstack)
					end
				end
			else
				inv:add_item(trg, stack)
			end
		elseif info.from_list == "main" and info.from_index <= 9 and empty_main then --hotbar to inv
			inv:set_stack("main", empty_main, stack)
		elseif info.from_list == "main" and info.from_index > 9 and empty_hotbar then
			inv:set_stack("main", empty_hotbar, stack)
		else
			inv:set_stack(info.from_list, info.from_index, stack)
		end
		inv:set_stack("sorter", 1, ItemStack(""))
	end
end)

minetest.register_allow_player_inventory_action(function(_, action, inv, info)
	if info.to_list == "sorter" or info.from_list == "sorter" or info.listname == "sorter" then
		if action == "put" or action == "take" then return 0 end
		local stack = inv:get_stack(info.from_list, info.from_index)
		local trg = sort_stack(stack)
		local empty_main, empty_hotbar = find_empty_inv_slots(inv)
		if trg then
			if trg == "armor" then
				return 1
			end
			local stack1 = ItemStack(stack):take_item()
			if inv:room_for_item(trg, stack) then
				return stack:get_count()
			elseif inv:room_for_item(trg, stack1) then
				for k,v in pairs(inv:get_list(trg)) do
					if v:to_string() == stack:to_string() then
						return stack:get_stack_max() - inv:get_stack(trg, k):get_count()
					end
				end
			end
		elseif ( info.from_list == "main" and info.from_index <= 9 and empty_main ) or
			( info.from_list == "main" and info.from_index > 9 and empty_hotbar ) then
			return stack:get_count()
		end
		return 0
	end
end)
