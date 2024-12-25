-- By EliasFleckenstein03 and Code-Sploit

local S = minetest.get_translator("vlf_smithing_table")
local F = minetest.formspec_escape
local C = minetest.colorize

vlf_smithing_table = {}

local smithing_materials = {
	["vlf_nether:netherite_ingot"] = "netherite",
	["vlf_core:diamond"] = "diamond",
	["vlf_core:lapis"] = "lapis",
	["vlf_amethyst:amethyst_shard"]	= "amethyst",
	["vlf_redstone:redstone"]= "redstone",
	["vlf_core:iron_ingot"] = "iron",
	["vlf_core:gold_ingot"] = "gold",
	["vlf_copper:copper_ingot"] = "copper",
	["vlf_core:emerald"] = "emerald",
	["vlf_nether:quartz"] = "quartz"
}

---Function to upgrade diamond tool/armor to netherite tool/armor
function vlf_smithing_table.upgrade_item(itemstack)
	local def = itemstack:get_definition()

	if not def or not def._vlf_upgradable then
		return
	end
	local itemname = itemstack:get_name()
	local upgrade_item = itemname:gsub("diamond", "netherite")

	if def._vlf_upgrade_item and upgrade_item == itemname then
		return
	end

	itemstack:set_name(upgrade_item)
	vlf_armor.reload_trim_inv_image(itemstack)

	-- Reload the ToolTips of the tool

	tt.reload_itemstack_description(itemstack)

	-- Only return itemstack if upgrade was successfull
	return itemstack
end

local formspec = table.concat({
	"formspec_version[4]",
	"size[11.75,10.425]",

	"label[4.125,0.375;" .. F(C(vlf_formspec.label_color, S("Upgrade Gear"))) .. "]",
	"image[0.875,0.375;1.75,1.75;vlf_smithing_table_inventory_hammer.png]",

	vlf_formspec.get_itemslot_bg_v4(1.625,2.3,1,1),
	"list[context;upgrade_item;1.625,2.3;1,1;]",

	"image[3.5,2.3;1,1;vlf_anvils_inventory_cross.png]",

	vlf_formspec.get_itemslot_bg_v4(5.375, 2.3,1,1),
	"list[context;mineral;5.375, 2.3;1,1;]",

	vlf_formspec.get_itemslot_bg_v4(5.375,3.6,1,1),
	vlf_formspec.get_itemslot_bg_v4(5.375,3.6,1,1,0,"vlf_smithing_table_inventory_trim_bg.png"),
	"list[context;template;5.375,3.6;1,1;]",

	vlf_formspec.get_itemslot_bg_v4(9.125, 2.3,1,1),
	"list[context;upgraded_item;9.125, 2.3;1,1;]",

	-- Player Inventory

	vlf_formspec.get_itemslot_bg_v4(0.375, 5.1, 9, 3),
	"list[current_player;main;0.375,5.1;9,3;9]",

	vlf_formspec.get_itemslot_bg_v4(0.375, 9.05, 9, 1),
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
	["vlf_armor:spire"] = true,
	["vlf_armor:snout"] = true,
	["vlf_armor:rib"] = true,
	["vlf_armor:ward"] = true,
	["vlf_armor:silence"] = true,
	["vlf_armor:vex"] = true,
	["vlf_armor:tide"] = true,
	["vlf_armor:wayfinder"] = true
}

function vlf_smithing_table.upgrade_trimmed(itemstack, color_mineral, template)
	--get information required
	local material_name = color_mineral:get_name()
	material_name = smithing_materials[material_name]

	local overlay = template:get_name():gsub("vlf_armor:","")

	--trimming process
	if minetest.get_item_group(template:get_name(), "smithing_template") > 0 then
		vlf_armor.trim(itemstack, overlay, material_name)
		tt.reload_itemstack_description(itemstack)
	end

	return itemstack
end

function vlf_smithing_table.is_smithing_mineral(itemname)
	return smithing_materials[itemname] ~= nil
end

local function reset_upgraded_item(pos)
	local inv = minetest.get_meta(pos):get_inventory()
	local upgraded_item

	local original_itemname = inv:get_stack("upgrade_item", 1):get_name()
	local template_present = minetest.get_item_group(inv:get_stack("template",1):get_name(), "smithing_template") > 0
	local upgrade_template_present = inv:get_stack("template",1):get_name() == "vlf_nether:netherite_upgrade_template"
	local is_armor = original_itemname:find("vlf_armor:") ~= nil
	local is_trimmed = original_itemname:find("_trimmed") ~= nil

	if inv:get_stack("mineral", 1):get_name() == "vlf_nether:netherite_ingot" and upgrade_template_present then
		upgraded_item = vlf_smithing_table.upgrade_item(inv:get_stack("upgrade_item", 1))
	elseif template_present and is_armor and not is_trimmed and vlf_smithing_table.is_smithing_mineral(inv:get_stack("mineral", 1):get_name()) then
		upgraded_item = vlf_smithing_table.upgrade_trimmed(inv:get_stack("upgrade_item", 1),inv:get_stack("mineral", 1),inv:get_stack("template", 1))
	end

	inv:set_stack("upgraded_item", 1, upgraded_item)
end

local function sort_stack(stack, _)
	if minetest.get_item_group(stack:get_name(), "smithing_template") > 0 or minetest.get_item_group(stack:get_name(), "upgrade_template") > 0 then
		return "template"
	elseif vlf_smithing_table.is_smithing_mineral(stack:get_name()) then
		return "mineral"
	elseif (minetest.get_item_group(stack:get_name(),"armor") > 0
			or minetest.get_item_group(stack:get_name(),"tool") > 0
			or minetest.get_item_group(stack:get_name(),"sword") > 0)
			and not vlf_armor.trims.blacklisted[stack:get_name()] then
		return "upgrade_item"
	end
end

minetest.register_node("vlf_smithing_table:table", {
	description = S("Smithing Table"),
	_doc_items_longdesc = S("A smithing table is a utility block used to alter tools and armor at the cost of a smithing template and the appropriate material. This is the only way to obtain trimmed armor or upgrade diamond equipment with netherite. It also serves as a toolsmith's job site block."),
	_doc_items_usagehelp = S("Rightclick on a smithing table to access its interface. Put armor or tools in the upper left slot. The top right slot is reserved for mineral items. The bottom slot is for smithing templates. To upgrade your diamond armor and tools to netherite, the netherite upgrade template is required.").."\n"..
	S("To trim your armor, you need a mineral item and a smithing template. Each piece of armor can be given an trimming pattern. The items are consumed after trimming and the armor piece receives the pattern defined by the template.").."\n\n"..
	S("List of mineral items:\n• Amethyst Shard\n• Copper Ingot\n• Diamond\n• Emerald\n• Gold Ingot\n• Iron Ingot\n• Lapis Lazuli\n• Netherite Ingot\n• Quartz\n• Redstone"),
	groups = { pickaxey = 2, deco_block = 1 },

	tiles = {
		"vlf_smithing_table_top.png",
		"vlf_smithing_table_bottom.png",
		"vlf_smithing_table_side.png",
		"vlf_smithing_table_side.png",
		"vlf_smithing_table_side.png",
		"vlf_smithing_table_front.png",
	},

	sounds = vlf_sounds.node_sound_metal_defaults(),

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

	after_dig_node = vlf_util.drop_items_from_meta_container({"upgrade_item", "mineral", "template"}),

	allow_metadata_inventory_put = function(pos, listname, _, stack, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		end
		local r = 0
		if listname == "upgrade_item" then
			if (minetest.get_item_group(stack:get_name(),"armor") > 0
			or minetest.get_item_group(stack:get_name(),"tool") > 0
			or minetest.get_item_group(stack:get_name(),"sword") > 0)
			and not vlf_armor.trims.blacklisted[stack:get_name()] then
				r = stack:get_count()
			end
		elseif listname == "mineral" then
			if vlf_smithing_table.is_smithing_mineral(stack:get_name()) then
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

	allow_metadata_inventory_move = function()
		return 0
	end,

	allow_metadata_inventory_take = function(pos, listname, _, stack, player)
		if listname == "sorter" then return 0 end
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		else
			return stack:get_count()
		end
	end,

	on_metadata_inventory_put =  function(pos, listname, _, stack)
		if listname == "sorter" then
			local inv = minetest.get_meta(pos):get_inventory()
			inv:add_item(sort_stack(stack, pos), stack)
			inv:set_stack("sorter", 1, ItemStack(""))
		end
		reset_upgraded_item(pos)
	end,
	on_metadata_inventory_take = function(pos, listname, _, stack, player)
		local inv = minetest.get_meta(pos):get_inventory()

		local function take_item(listname)
			local itemstack = inv:get_stack(listname, 1)
			itemstack:take_item()
			inv:set_stack(listname, 1, itemstack)
		end

		if listname == "upgraded_item" then
			-- ToDo: make epic sound
			minetest.sound_play("vlf_smithing_table_upgrade", { pos = pos, max_hear_distance = 16 })

			if stack:get_name() == "vlf_farming:hoe_netherite" then
				awards.unlock(player:get_player_name(), "vlf:seriousDedication")
			elseif vlf_armor.is_trimmed(stack) then
				local template_name = inv:get_stack("template", 1):get_name()
				local playername = player:get_player_name()
				awards.unlock(playername, "vlf:trim")

				if not vlf_achievements.award_unlocked(playername, "vlf:lots_of_trimming") and achievement_trims[template_name] then
					local meta = player:get_meta()
					local used_achievement_trims = minetest.deserialize(meta:get_string("vlf_smithing_table:achievement_trims")) or {}
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
						awards.unlock(playername, "vlf:lots_of_trimming")
					else
						meta:set_string("vlf_smithing_table:achievement_trims", minetest.serialize(used_achievement_trims))
					end
				end
			end

			take_item("upgrade_item")
			take_item("mineral")
			take_item("template")
		end
		reset_upgraded_item(pos)
	end,

	_vlf_blast_resistance = 2.5,
	_vlf_hardness = 2.5,
	_vlf_burntime = 15
})


minetest.register_craft({
	output = "vlf_smithing_table:table",
	recipe = {
		{ "vlf_core:iron_ingot", "vlf_core:iron_ingot", "" },
		{ "group:wood", "group:wood", "" },
		{ "group:wood", "group:wood", "" }
	},
})

-- this is the exact same as vlf_smithing_table.upgrade_item_netherite , in case something relies on the old function
function vlf_smithing_table.upgrade_item_netherite(itemstack)
	return vlf_smithing_table.upgrade_item(itemstack)
end

minetest.register_lbm({
	label = "Update smithing table formspecs and invs to allow new sneak+click behavior",
	name = "vlf_smithing_table:update_coolsneak",
	nodenames = { "vlf_smithing_table:table" },
	run_at_every_load = false,
	action = function(pos)
		local m = minetest.get_meta(pos)
		m:get_inventory():set_size("sorter", 1)
		m:set_string("formspec", formspec)
	end,
})
