local S = minetest.get_translator(minetest.get_current_modname())
local F = minetest.formspec_escape
local C = minetest.colorize

local messy_textures = {
	grey = "mobs_mc_shulker_gray.png",
}

local canonical_shulker_color = "violet"
local normal_canonical_name = "vlf_chests:" .. canonical_shulker_color .. "_shulker_box"
local small_canonical_name = normal_canonical_name .. "_small"

--WARNING: after formspec v4 update, old shulker boxes will need to be placed again to get the new formspec
local function formspec_shulker_box(name)
	if not name or name == "" then
		name = S("Shulker Box")
	end

	return table.concat({
		"formspec_version[4]",
		"size[11.75,10.425]",

		"label[0.375,0.375;" .. F(C(vlf_formspec.label_color, name)) .. "]",
		vlf_formspec.get_itemslot_bg_v4(0.375, 0.75, 9, 3),
		"list[context;main;0.375,0.75;9,3;]",
		"label[0.375,4.7;" .. F(C(vlf_formspec.label_color, S("Inventory"))) .. "]",
		vlf_formspec.get_itemslot_bg_v4(0.375, 5.1, 9, 3),
		"list[current_player;main;0.375,5.1;9,3;9]",

		vlf_formspec.get_itemslot_bg_v4(0.375, 9.05, 9, 1),
		"list[current_player;main;0.375,9.05;9,1;]",

		"listring[context;main]",
		"listring[current_player;main]",
	})
end
vlf_chests.formspec_shulker_box = formspec_shulker_box

local function set_shulkerbox_meta(nmeta, imeta)
	local name = imeta:get_string("name")
	nmeta:set_string("description", imeta:get_string("description"))
	nmeta:set_string("name", name)
	nmeta:set_string("formspec", formspec_shulker_box(name))
end

for c, cdef in pairs(vlf_dyes.colors) do
	local mob_texture = messy_textures[c] or "mobs_mc_shulker_"..c..".png"
	local color = cdef.vlf2 or c --use the "legacy" colorname if present to preserve all itemstrings
	local desc = S("@1 Shulker Box", cdef.readable_name)
	local is_canonical = color == canonical_shulker_color
	local longdesc, usagehelp, create_entry, entry_name
	if doc then
		if is_canonical then
			longdesc = S(
				"A shulker box is a portable container which provides 27 inventory slots for any item " ..
				"except shulker boxes. Shulker boxes keep their inventory when broken, so shulker boxes " ..
				"as well as their contents can be taken as a single item. Shulker boxes come in many " ..
				"different colors."
			)
			usagehelp = S(
				"To access the inventory of a shulker box, place and right-click it. To take a shulker " ..
				"box and its contents with you, just break and collect it, the items will not fall out. " ..
				"Place the shulker box again to be able to retrieve its contents."
			)
			entry_name = S("Shulker Box")
		else
			create_entry = false
		end
	end

	local normal_name = "vlf_chests:" .. color .. "_shulker_box"
	local small_name = normal_name .. "_small"

	minetest.register_node(normal_name, {
		description = desc,
		_tt_help = S("27 inventory slots") .. "\n" .. S("Can be carried around with its contents"),
		_doc_items_create_entry = create_entry,
		_doc_items_entry_name = entry_name,
		_doc_items_longdesc = longdesc,
		_doc_items_usagehelp = usagehelp,
		tiles = { mob_texture },
		use_texture_alpha = "opaque",
		drawtype = "mesh",
		mesh = "vlf_chests_shulker.b3d",
		groups = {
			handy = 1,
			pickaxey = 1,
			container = 2,
			deco_block = 1,
			dig_by_piston = 1,
			shulker_box = 1,
			old_shulker_box_node = 1
		},
		is_ground_content = false,
		sounds = vlf_sounds.node_sound_stone_defaults(),
		stack_max = 1,
		drop = "",
		paramtype = "light",
		paramtype2 = "facedir",
		on_construct = function(pos)
			local node = minetest.get_node(pos)
			node.name = small_name
			minetest.set_node(pos, node)
		end,
		after_place_node = function(pos, placer, itemstack, pointed_thing)
			local nmeta = minetest.get_meta(pos)
			local imeta = itemstack:get_meta()

			-- Convert old itemstacks to not use get_metadata()
			if not imeta:contains("inv") and
					(itemstack:get_metadata() ~= "") then
				imeta:set_string("inv", itemstack:get_metadata())
				itemstack:set_metadata("") -- clear
			end

			local iinv_main = minetest.deserialize(imeta:get_string("inv"))
			local ninv = nmeta:get_inventory()
			ninv:set_list("main", iinv_main)
			ninv:set_size("main", 9 * 3)
			set_shulkerbox_meta(nmeta, imeta)

			if minetest.is_creative_enabled(placer:get_player_name()) then
				if not ninv:is_empty("main") then
					return nil
				else
					return itemstack
				end
			else
				return nil
			end
		end,
		_on_dispense = function(stack, pos, droppos, dropnode, dropdir)
			-- Place shulker box as node
			if minetest.registered_nodes[dropnode.name].buildable_to then
				minetest.set_node(droppos, { name = small_name, param2 = minetest.dir_to_facedir(dropdir) })
				local ninv = minetest.get_inventory({ type = "node", pos = droppos })
				local imeta = stack:get_meta()
				local iinv_main = minetest.deserialize(imeta:get_string("inv"))
				ninv:set_list("main", iinv_main)
				ninv:set_size("main", 9 * 3)
				set_shulkerbox_meta(minetest.get_meta(droppos), imeta)
				stack:take_item()
			end
			return stack
		end,
	})

	minetest.register_node(small_name, {
		description = desc,
		_tt_help = S("27 inventory slots") .. "\n" .. S("Can be carried around with its contents"),
		_doc_items_create_entry = create_entry,
		_doc_items_entry_name = entry_name,
		_doc_items_longdesc = longdesc,
		_doc_items_usagehelp = usagehelp,
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = { -0.48, -0.5, -0.48, 0.48, 0.489, 0.48 },
		},
		tiles = { "blank.png^[resize:16x16" },
		use_texture_alpha = "clip",
		_chest_entity_textures = { mob_texture },
		_chest_entity_sound = "vlf_chests_shulker",
		_chest_entity_mesh = "vlf_chests_shulker",
		_chest_entity_animation_type = "shulker",
		groups = {
			handy = 1,
			pickaxey = 1,
			container = 2,
			deco_block = 1,
			dig_by_piston = 1,
			shulker_box = 1,
			chest_entity = 1,
			not_in_creative_inventory = 1
		},
		is_ground_content = false,
		sounds = vlf_sounds.node_sound_stone_defaults(),
		stack_max = 1,
		drop = "",
		paramtype = "light",
		paramtype2 = "facedir",
		on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_string("formspec", formspec_shulker_box(nil))
			local inv = meta:get_inventory()
			inv:set_size("main", 9 * 3)
			vlf_chests.create_entity(pos, small_name, { mob_texture }, minetest.get_node(pos).param2, false,
				"vlf_chests_shulker", "vlf_chests_shulker", "shulker")
		end,
		after_place_node = function(pos, placer, itemstack, pointed_thing)
			local nmeta = minetest.get_meta(pos)
			local imeta = itemstack:get_meta()

			-- Convert old itemstacks to not use get_metadata()
			if not imeta:contains("inv") and
					(itemstack:get_metadata() ~= "") then
				imeta:set_string("inv", itemstack:get_metadata())
				itemstack:set_metadata("") -- clear
			end

			local iinv_main = minetest.deserialize(imeta:get_string("inv"))
			local ninv = nmeta:get_inventory()
			ninv:set_list("main", iinv_main)
			ninv:set_size("main", 9 * 3)
			set_shulkerbox_meta(nmeta, imeta)

			if minetest.is_creative_enabled(placer:get_player_name()) then
				if not ninv:is_empty("main") then
					return nil
				else
					return itemstack
				end
			else
				return nil
			end
		end,
		on_rightclick = function(pos, node, clicker)
			vlf_chests.player_chest_open(clicker, pos, small_name, { mob_texture }, node.param2, false,
				"vlf_chests_shulker", "vlf_chests_shulker", true)
		end,
		on_receive_fields = function(pos, formname, fields, sender)
			if fields.quit then
				vlf_chests.player_chest_close(sender)
			end
		end,
		on_destruct = function(pos)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			local items = {}
			for i = 1, inv:get_size("main") do
				local stack = inv:get_stack("main", i)
				items[i] = stack:to_string()
			end
			local data = minetest.serialize(items)
			local boxitem = ItemStack("vlf_chests:" .. color .. "_shulker_box")
			local boxitem_meta = boxitem:get_meta()
			boxitem_meta:set_string("description", meta:get_string("description"))
			boxitem_meta:set_string("name", meta:get_string("name"))
			boxitem_meta:set_string("inv", data)

			if minetest.is_creative_enabled("") then
				if not inv:is_empty("main") then
					minetest.add_item(pos, boxitem)
				end
			else
				minetest.add_item(pos, boxitem)
			end
		end,
		allow_metadata_inventory_move = vlf_chests.protection_check_move,
		allow_metadata_inventory_take = vlf_chests.protection_check_put_take,
		allow_metadata_inventory_put = function(pos, listname, index, stack, player)
			local name = player:get_player_name()
			if minetest.is_protected(pos, name) then
				minetest.record_protection_violation(pos, name)
				return 0
			end
			-- Do not allow to place shulker boxes into shulker boxes
			local group = minetest.get_item_group(stack:get_name(), "shulker_box")
			if group == 0 or group == nil then
				return stack:get_count()
			else
				return 0
			end
		end,
		on_rotate = vlf_chests.simple_rotate,
		_vlf_blast_resistance = 6,
		_vlf_hardness = 2,
		_vlf_hoppers_on_try_push = function(pos, hop_pos, hop_inv, hop_list)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			return inv, "main",
				vlf_util.select_stack(hop_inv, hop_list, inv, "main", vlf_chests.is_not_shulker_box, 1)
		end,
	})

	if doc and not is_canonical then
		doc.add_entry_alias("nodes", normal_canonical_name, "nodes", normal_name)
		doc.add_entry_alias("nodes", small_canonical_name, "nodes", small_name)
	end

	minetest.register_craft({
		type = "shapeless",
		output = normal_name,
		recipe = { "group:shulker_box", "vlf_dye:" .. color },
	})
end

minetest.register_craft({
	output = "vlf_chests:violet_shulker_box",
	recipe = {
		{ "vlf_mobitems:shulker_shell" },
		{ "vlf_chests:chest" },
		{ "vlf_mobitems:shulker_shell" },
	},
})

-- Save metadata of shulker box when used in crafting
minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
	if minetest.get_item_group(itemstack:get_name(), "shulker_box") ~= 1 then return end

	local original
	for i = 1, #old_craft_grid do
		local item = old_craft_grid[i]:get_name()
		if minetest.get_item_group(item, "shulker_box") == 1 then
			original = old_craft_grid[i]
			break
		end
	end
	if original then
		local ometa = original:get_meta():to_table()
		local nmeta = itemstack:get_meta()
		nmeta:from_table(ometa)
		return itemstack
	end
end)
