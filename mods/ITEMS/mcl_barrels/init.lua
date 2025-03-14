local S = minetest.get_translator("mcl_barrels")
local F = minetest.formspec_escape
local C = minetest.colorize

--TODO: fix barrel rotation placement

local open_barrels = {}

local drop_content = mcl_util.drop_items_from_meta_container({"main"})

local function on_blast(pos)
	local node = minetest.get_node(pos)
	drop_content(pos, node)
	minetest.remove_node(pos)
end

-- Simple protection checking functions
local function protection_check_move(pos, _, _, _, _, count, player)
	local name = player:get_player_name()
	if minetest.is_protected(pos, name) then
		minetest.record_protection_violation(pos, name)
		return 0
	else
		return count
	end
end

local function protection_check_put_take(pos, _, _, stack, player)
	local name = player:get_player_name()
	if minetest.is_protected(pos, name) then
		minetest.record_protection_violation(pos, name)
		return 0
	else
		return stack:get_count()
	end
end

local function barrel_open(pos, node, clicker)
	local name = minetest.get_meta(pos):get_string("name")

	if name == "" then
		name = S("Barrel")
	end

	local playername = clicker:get_player_name()

	minetest.show_formspec(playername,
		"mcl_barrels:barrel_" .. pos.x .. "_" .. pos.y .. "_" .. pos.z,
		table.concat({
			"formspec_version[4]",
			"size[11.75,10.425]",

			"label[0.375,0.375;" .. F(C(mcl_formspec.label_color, name)) .. "]",
			mcl_formspec.get_itemslot_bg_v4(0.375, 0.75, 9, 3),
			"list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z .. ";main;0.375,0.75;9,3;]",
			"label[0.375,4.7;" .. F(C(mcl_formspec.label_color, S("Inventory"))) .. "]",
			mcl_formspec.get_itemslot_bg_v4(0.375, 5.1, 9, 3),
			"list[current_player;main;0.375,5.1;9,3;9]",

			mcl_formspec.get_itemslot_bg_v4(0.375, 9.05, 9, 1),
			"list[current_player;main;0.375,9.05;9,1;]",
			"listring[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z .. ";main]",
			"listring[current_player;main]",
		})
	)

	minetest.swap_node(pos, { name = "mcl_barrels:barrel_open", param2 = node.param2 })
	open_barrels[playername] = pos
	minetest.sound_play({ name = "mcl_barrels_default_barrel_open" }, { pos = pos, gain = 0.5, max_hear_distance = 16 }, true)
	mobs_mc.enrage_piglins (clicker, true)
	local inventory = minetest.get_meta(pos):get_inventory()
	vl_loot.generate_container_loot_if_exists(pos, nil, inventory, "main")
end

local function close_forms(pos)
	local formname = "mcl_barrels:barrel_" .. pos.x .. "_" .. pos.y .. "_" .. pos.z
	for pl in mcl_util.connected_players(pos, 30) do
		minetest.close_formspec(pl:get_player_name(), formname)
	end
end

local function update_after_close(pos)
	local node = minetest.get_node_or_nil(pos)
	if not node then return end
	if node.name == "mcl_barrels:barrel_open" then
		minetest.swap_node(pos, { name = "mcl_barrels:barrel_closed", param2 = node.param2 })
		minetest.sound_play({ name = "mcl_barrels_default_barrel_close" }, { pos = pos, gain = 0.5, max_hear_distance = 16 }, true)
	end
end

local function close_barrel(player)
	local name = player:get_player_name()
	local open = open_barrels[name]
	if open == nil then
		return
	end

	update_after_close(open)

	open_barrels[name] = nil
end

minetest.register_node("mcl_barrels:barrel_closed", {
	description = S("Barrel"),
	_tt_help = S("27 inventory slots"),
	_doc_items_longdesc = S("Barrels are containers which provide 27 inventory slots."),
	_doc_items_usagehelp = S("To access its inventory, rightclick it. When broken, the items will drop out."),
	tiles = { "mcl_barrels_barrel_top.png^[transformR270", "mcl_barrels_barrel_bottom.png", "mcl_barrels_barrel_side.png" },
	is_ground_content = false,
	paramtype = "light",
	paramtype2 = "facedir",
	on_place = function(itemstack, placer, pointed_thing)
		if  not placer or not placer:is_player() then
			return itemstack
		end
		minetest.rotate_and_place(itemstack, placer, pointed_thing,
			minetest.is_creative_enabled(placer and placer:get_player_name() or ""), {}
			, false)
		return itemstack
	end,
	sounds = mcl_sounds.node_sound_wood_defaults(),
	groups = {
		handy = 1,
		axey = 1,
		container = 2,
		material_wood = 1,
		flammable = -1,
		deco_block = 1,
		piglin_protected = 1,
		barrel = 1,
	},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("main", 9 * 3)
	end,
	after_place_node = function(pos, _, itemstack)
		minetest.get_meta(pos):set_string("name", itemstack:get_meta():get_string("name"))
		local itemstack_meta = itemstack:get_meta()
		minetest.get_meta(pos):set_string("loot_table", itemstack_meta:get_string("loot_table"))
	end,
	allow_metadata_inventory_move = protection_check_move,
	allow_metadata_inventory_take = protection_check_put_take,
	allow_metadata_inventory_put = protection_check_put_take,
	on_metadata_inventory_move = function(pos, _, _, _, _, _, player)
		minetest.log("action", player:get_player_name() ..
			" moves stuff in barrel at " .. minetest.pos_to_string(pos))
	end,
	on_metadata_inventory_put = function(pos, _, _, _, player)
		minetest.log("action", player:get_player_name() ..
			" moves stuff to barrel at " .. minetest.pos_to_string(pos))
		mcl_redstone.update_comparators(pos)
	end,
	on_metadata_inventory_take = function(pos, _, _, _, player)
		minetest.log("action", player:get_player_name() ..
			" takes stuff from barrel at " .. minetest.pos_to_string(pos))
		mcl_redstone.update_comparators(pos)
	end,
	after_dig_node = drop_content,
	on_blast = on_blast,
	on_rightclick = barrel_open,
	on_destruct = close_forms,
	_mcl_blast_resistance = 2.5,
	_mcl_hardness = 2.5,
	_mcl_burntime = 15
})

minetest.register_node("mcl_barrels:barrel_open", {
	description = S("Barrel Open"),
	_tt_help = S("27 inventory slots"),
	_doc_items_longdesc = S("Barrels are containers which provide 27 inventory slots."),
	_doc_items_usagehelp = S("To access its inventory, rightclick it. When broken, the items will drop out."),
	_doc_items_create_entry = false,
	tiles = { "mcl_barrels_barrel_top_open.png", "mcl_barrels_barrel_bottom.png", "mcl_barrels_barrel_side.png" },
	is_ground_content = false,
	paramtype = "light",
	paramtype2 = "facedir",
	drop = "mcl_barrels:barrel_closed",
	sounds = mcl_sounds.node_sound_wood_defaults(),
	groups = {
		handy = 1,
		axey = 1,
		container = 2,
		material_wood = 1,
		flammable = -1,
		deco_block = 1,
		not_in_creative_inventory = 1,
		piglin_protected = 1,
		barrel = 1,
	},
	allow_metadata_inventory_move = protection_check_move,
	allow_metadata_inventory_take = protection_check_put_take,
	allow_metadata_inventory_put = protection_check_put_take,
	on_metadata_inventory_move = function(pos, _, _, _, _, _, player)
		minetest.log("action", player:get_player_name() ..
			" moves stuff in barrel at " .. minetest.pos_to_string(pos))
	end,
	on_metadata_inventory_put = function(pos, _, _, _, player)
		minetest.log("action", player:get_player_name() ..
			" moves stuff to barrel at " .. minetest.pos_to_string(pos))
		mcl_redstone.update_comparators(pos)
	end,
	on_metadata_inventory_take = function(pos, _, _, _, player)
		minetest.log("action", player:get_player_name() ..
			" takes stuff from barrel at " .. minetest.pos_to_string(pos))
		mcl_redstone.update_comparators(pos)
	end,
	after_dig_node = drop_content,
	on_blast = on_blast,
	on_rightclick = barrel_open,
	on_destruct = close_forms,
	_mcl_blast_resistance = 2.5,
	_mcl_hardness = 2.5,
	_mcl_baseitem = "mcl_barrels:barrel_closed",
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname:find("mcl_barrels:") == 1 and fields.quit then
		close_barrel(player)
	end
end)

minetest.register_on_leaveplayer(function(player)
	close_barrel(player)
end)

--Minecraft Java Edition craft
minetest.register_craft({
	output = "mcl_barrels:barrel_closed",
	recipe = {
		{ "group:wood", "group:wood_slab", "group:wood" },
		{ "group:wood", "",                "group:wood" },
		{ "group:wood", "group:wood_slab", "group:wood" },
	},
})
