-- By EliasFleckenstein03 and Code-Sploit

local S = minetest.get_translator("vlc_smithing_table")
local F = minetest.formspec_escape
local C = minetest.colorize

vlc_smithing_table = {}

local smithing_materials = {
	["vlc_nether:netherite_ingot"] = "netherite",
	["vlc_core:diamond"] = "diamond",
	["vlc_core:lapis"] = "lapis",
	["vlc_amethyst:amethyst_shard"]	= "amethyst",
	["mesecons:wire_00000000_off"]= "redstone",
	["vlc_core:iron_ingot"] = "iron",
	["vlc_core:gold_ingot"] = "gold",
	["vlc_copper:copper_ingot"] = "copper",
	["vlc_core:emerald"] = "emerald",
	["vlc_nether:quartz"] = "quartz"
}

---Function to upgrade diamond tool/armor to netherite tool/armor
function vlc_smithing_table.upgrade_item(itemstack)
	local def = itemstack:get_definition()

	if not def or not def._vlc_upgradable then
		return
	end
	local itemname = itemstack:get_name()
	local upgrade_item = itemname:gsub("diamond", "netherite")

	if def._vlc_upgrade_item and upgrade_item == itemname then
		return
	end

	itemstack:set_name(upgrade_item)
	vlc_armor.reload_trim_inv_image(itemstack)

	-- Reload the ToolTips of the tool

	tt.reload_itemstack_description(itemstack)

	-- Only return itemstack if upgrade was successfull
	return itemstack
end

local formspec = table.concat({
	"formspec_version[4]",
	"size[11.75,10.425]",

	"label[4.125,0.375;" .. F(C(vlc_formspec.label_color, S("Upgrade Gear"))) .. "]",
	"image[0.875,0.375;1.75,1.75;vlc_smithing_table_inventory_hammer.png]",

	vlc_formspec.get_itemslot_bg_v4(1.625,2.3,1,1),
	"list[context;upgrade_item;1.625,2.3;1,1;]",

	"image[3.5,2.3;1,1;vlc_anvils_inventory_cross.png]",

	vlc_formspec.get_itemslot_bg_v4(5.375, 2.3,1,1),
	"list[context;mineral;5.375, 2.3;1,1;]",

	vlc_formspec.get_itemslot_bg_v4(5.375,3.6,1,1),
	vlc_formspec.get_itemslot_bg_v4(5.375,3.6,1,1,0,"vlc_smithing_table_inventory_trim_bg.png"),
	"list[context;template;5.375,3.6;1,1;]",

	vlc_formspec.get_itemslot_bg_v4(9.125, 2.3,1,1),
	"list[context;upgraded_item;9.125, 2.3;1,1;]",

	-- Player Inventory

	vlc_formspec.get_itemslot_bg_v4(0.375, 5.1, 9, 3),
	"list[current_player;main;0.375,5.1;9,3;9]",

	vlc_formspec.get_itemslot_bg_v4(0.375, 9.05, 9, 1),
	"list[current_player;main;0.375,9.05;9,1;]",

	-- Listrings
	"listring[context;upgraded_item]",
	"listring[current_player;main]",
	"listring[context;sorter]",
	"listring[current_player;main]",
	"listring[context;upgrade_item]",
	"listring[current_player;main]",
	"listring[context;mineral]",
	"listring[current_player;main]",
	"listring[context;template]",
	"listring[current_player;main]",
})

local achievement_trims = {
	["vlc_armor:spire"] = true,
	["vlc_armor:snout"] = true,
	["vlc_armor:rib"] = true,
	["vlc_armor:ward"] = true,
	["vlc_armor:silence"] = true,
	["vlc_armor:vex"] = true,
	["vlc_armor:tide"] = true,
	["vlc_armor:wayfinder"] = true
}

function vlc_smithing_table.upgrade_trimmed(itemstack, color_mineral, template)
	--get information required
	local material_name = color_mineral:get_name()
	material_name = smithing_materials[material_name]

	local overlay = template:get_name():gsub("vlc_armor:","")

	--trimming process
	if minetest.get_item_group(template:get_name(), "smithing_template") > 0 then
		vlc_armor.trim(itemstack, overlay, material_name)
		tt.reload_itemstack_description(itemstack)
	end

	return itemstack
end

function vlc_smithing_table.is_smithing_mineral(itemname)
	return smithing_materials[itemname] ~= nil
end

local function reset_upgraded_item(pos)
	local inv = minetest.get_meta(pos):get_inventory()
	local upgraded_item

	local original_itemname = inv:get_stack("upgrade_item", 1):get_name()
	local template_present = minetest.get_item_group(inv:get_stack("template",1):get_name(), "smithing_template") > 0
	local upgrade_template_present = inv:get_stack("template",1):get_name() == "vlc_nether:netherite_upgrade_template"
	local is_armor = original_itemname:find("vlc_armor:") ~= nil
	local is_trimmed = original_itemname:find("_trimmed") ~= nil

	if inv:get_stack("mineral", 1):get_name() == "vlc_nether:netherite_ingot" and upgrade_template_present then
		upgraded_item = vlc_smithing_table.upgrade_item(inv:get_stack("upgrade_item", 1))
	elseif template_present and is_armor and not is_trimmed and vlc_smithing_table.is_smithing_mineral(inv:get_stack("mineral", 1):get_name()) then
		upgraded_item = vlc_smithing_table.upgrade_trimmed(inv:get_stack("upgrade_item", 1),inv:get_stack("mineral", 1),inv:get_stack("template", 1))
	end

	inv:set_stack("upgraded_item", 1, upgraded_item)
end

local function sort_stack(stack, pos)
	if minetest.get_item_group(stack:get_name(), "smithing_template") > 0 or minetest.get_item_group(stack:get_name(), "upgrade_template") > 0 then
		return "template"
	elseif vlc_smithing_table.is_smithing_mineral(stack:get_name()) then
		return "mineral"
	elseif (minetest.get_item_group(stack:get_name(),"armor") > 0
			or minetest.get_item_group(stack:get_name(),"tool") > 0
			or minetest.get_item_group(stack:get_name(),"sword") > 0)
			and not vlc_armor.trims.blacklisted[stack:get_name()] then
		return "upgrade_item"
	end
end

minetest.register_node("vlc_smithing_table:table", {
	description = S("Smithing Table"),
	-- ToDo: Add _doc_items_longdesc and _doc_items_usagehelp

	groups = { pickaxey = 2, deco_block = 1 },

	tiles = {
		"vlc_smithing_table_top.png",
		"vlc_smithing_table_bottom.png",
		"vlc_smithing_table_side.png",
		"vlc_smithing_table_side.png",
		"vlc_smithing_table_side.png",
		"vlc_smithing_table_front.png",
	},

	sounds = vlc_sounds.node_sound_metal_defaults(),

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", formspec)

		local inv = meta:get_inventory()

		inv:set_size("upgrade_item", 1)
		inv:set_size("mineral", 1)
		inv:set_size("template",1)
		inv:set_size("upgraded_item", 1)
		inv:set_size("sorter", 1)
	end,

	after_dig_node = vlc_util.drop_items_from_meta_container({"upgrade_item", "mineral", "template"}),

	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local r = 0
		if listname == "upgrade_item" then
			if (minetest.get_item_group(stack:get_name(),"armor") > 0
			or minetest.get_item_group(stack:get_name(),"tool") > 0
			or minetest.get_item_group(stack:get_name(),"sword") > 0)
			and not vlc_armor.trims.blacklisted[stack:get_name()] then
				r = stack:get_count()
			end
		elseif listname == "mineral" then
			if vlc_smithing_table.is_smithing_mineral(stack:get_name()) then
				r= stack:get_count()
			end
		elseif listname == "template" then
			if minetest.get_item_group(stack:get_name(),"smithing_template") > 0 or  minetest.get_item_group(stack:get_name(),"upgrade_template") > 0 then
				r = stack:get_count()
			end
		elseif listname == "sorter" then
			local inv = minetest.get_meta(pos):get_inventory()
			local trg = sort_stack(stack, pos)
			if trg then
				local stack1 = ItemStack(stack):take_item()
				if inv:room_for_item(trg, stack) then
					return stack:get_count()
				elseif inv:room_for_item(trg, stack1) then
					return stack:get_stack_max() - inv:get_stack(trg, 1):get_count()
				end
			end
			return 0
		end

		return r
	end,

	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		return 0
	end,

	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		if listname == "sorter" then return 0 end
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		else
			return stack:get_count()
		end
	end,

	on_metadata_inventory_put =  function(pos, listname, index, stack, player)
		if listname == "sorter" then
			local inv = minetest.get_meta(pos):get_inventory()
			inv:add_item(sort_stack(stack, pos), stack)
			inv:set_stack("sorter", 1, ItemStack(""))
		end
		reset_upgraded_item(pos)
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		local inv = minetest.get_meta(pos):get_inventory()

		local function take_item(listname)
			local itemstack = inv:get_stack(listname, 1)
			itemstack:take_item()
			inv:set_stack(listname, 1, itemstack)
		end

		if listname == "upgraded_item" then
			-- ToDo: make epic sound
			minetest.sound_play("vlc_smithing_table_upgrade", { pos = pos, max_hear_distance = 16 })

			if stack:get_name() == "vlc_farming:hoe_netherite" then
				awards.unlock(player:get_player_name(), "vlc:seriousDedication")
			elseif vlc_armor.is_trimmed(stack) then
				local template_name = inv:get_stack("template", 1):get_name()
				local playername = player:get_player_name()
				awards.unlock(playername, "vlc:trim")

				if not vlc_achievements.award_unlocked(playername, "vlc:lots_of_trimming") and achievement_trims[template_name] then
					local meta = player:get_meta()
					local used_achievement_trims = minetest.deserialize(meta:get_string("vlc_smithing_table:achievement_trims")) or {}
					if not used_achievement_trims[template_name] then
						used_achievement_trims[template_name] = true
					end

					local used_all = true
					for name, _ in pairs(achievement_trims) do
						if not used_achievement_trims[name] then
							used_all = false
							break
						end
					end

					if used_all then
						awards.unlock(playername, "vlc:lots_of_trimming")
					else
						meta:set_string("vlc_smithing_table:achievement_trims", minetest.serialize(used_achievement_trims))
					end
				end
			end

			take_item("upgrade_item")
			take_item("mineral")
			take_item("template")
		end
		reset_upgraded_item(pos)
	end,

	_vlc_blast_resistance = 2.5,
	_vlc_hardness = 2.5
})


minetest.register_craft({
	output = "vlc_smithing_table:table",
	recipe = {
		{ "vlc_core:iron_ingot", "vlc_core:iron_ingot", "" },
		{ "group:wood", "group:wood", "" },
		{ "group:wood", "group:wood", "" }
	},
})

minetest.register_craft({
	type = "fuel",
	recipe = "vlc_smithing_table:table",
	burntime = 15,
})

-- this is the exact same as vlc_smithing_table.upgrade_item_netherite , in case something relies on the old function
function vlc_smithing_table.upgrade_item_netherite(itemstack)
	return vlc_smithing_table.upgrade_item(itemstack)
end

minetest.register_lbm({
	label = "Update smithing table formspecs and invs to allow new sneak+click behavior",
	name = "vlc_smithing_table:update_coolsneak",
	nodenames = { "vlc_smithing_table:table" },
	run_at_every_load = false,
	action = function(pos, node)
		local m = minetest.get_meta(pos)
		m:get_inventory():set_size("sorter", 1)
		m:set_string("formspec", formspec)
	end,
})
