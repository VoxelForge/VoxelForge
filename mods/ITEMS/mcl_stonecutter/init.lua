--|||||||||||||||||||||||
--||||| STONECUTTER |||||
--|||||||||||||||||||||||


local S = minetest.get_translator("mcl_stonecutter")

local recipe_yield = { --maps itemgroup to the respective recipe yield, default is 1
	["slab"] = 2,
}

-- To add a recipe to the stonecutter:
-- Put the "ingredient" item in the "stonecuttable" group - this determines
-- if the item is usable on the stonecutter.

-- Add the _mcl_stonecutter_recipes field which is a table consisting of all
-- ingredient nodes that will result in this node to the node def of the crafted node.

local recipes = {}
local yields = {}

minetest.register_on_mods_loaded(function()
	for result,resultdef in pairs(minetest.registered_nodes) do
		if resultdef._mcl_stonecutter_recipes then
			local yield = 1
			for k,v in pairs(recipe_yield) do if minetest.get_item_group(result,k) > 0 then yield = v end end
			for _,recipe in pairs(resultdef._mcl_stonecutter_recipes) do
				if minetest.get_item_group(recipe,"stonecuttable") > 0 and minetest.get_item_group(result,"not_in_creative_inventory") == 0 then
					if not recipes[recipe] then recipes[recipe] = {} end
					table.insert(recipes[recipe],result)
					yields[result] = yield
				end
			end
		end
	end
end)

-- formspecs
local function show_stonecutter_formspec(input)
	local cut_items = {}
	local x_len = 0
	local y_len = 0.5

	if recipes[input] then
		for k,v in pairs(recipes[input]) do
			x_len = x_len + 1
			if x_len > 5 then
				y_len = y_len + 1
				x_len = 1
			end
			table.insert(cut_items,string.format("item_image_button[%f,%f;%f,%f;%s;%s;%s]",x_len+1,y_len,1,1, v, "item_button_"..v, v))
		end
	end

	local formspec = "size[9,8.75]"..
	"label[0,4.0;"..minetest.formspec_escape(minetest.colorize("#313131", S("Inventory"))).."]"..
	"label[1,0.1;"..minetest.formspec_escape(minetest.colorize("#313131", S("Stone Cutter"))).."]"..
	"list[context;main;0,0;8,4;]"..
	"list[current_player;main;0,4.5;9,3;9]"..
	mcl_formspec.get_itemslot_bg(0,4.5,9,3)..
	"list[current_player;main;0,7.74;9,1;]"..
	mcl_formspec.get_itemslot_bg(0,7.74,9,1)..
	"list[context;input;0.5,1.7;1,1;]"..
	mcl_formspec.get_itemslot_bg(0.5,1.7,1,1)..
	"list[context;output;7.5,1.7;1,1;]"..
	mcl_formspec.get_itemslot_bg(7.5,1.7,1,1)..
	table.concat(cut_items)..
	"listring[context;output]"..
	"listring[current_player;main]"..
	"listring[context;input]"..
	"listring[current_player;main]"

	return formspec
end

-- Updates the formspec
local function update_stonecutter_slots(pos,str)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local input = inv:get_stack("input", 1)
	local name = input:get_name()
	if minetest.get_item_group(name,"stonecuttable") > 0 then

		meta:set_string("formspec", show_stonecutter_formspec(name))
	else
		meta:set_string("formspec", show_stonecutter_formspec(nil))
	end

	-- Checks if the chosen item is a slab or not, if it's a slab set the output to be a stack of 2
	if table.indexof(recipes[name],str) ~= -1 and yields[str] then
		local cut_item = ItemStack(str)
		cut_item:set_count(yields[str])
		inv:set_stack("output", 1, cut_item)
	else
		inv:set_stack("output", 1, "")
	end
end

-- Only drop the items that were in the input slot
local function drop_stonecutter_items(pos, meta)
	local inv = meta:get_inventory()
	for i=1, inv:get_size("input") do
		local stack = inv:get_stack("input", i)
		if not stack:is_empty() then
			local p = {x=pos.x+math.random(0, 10)/10-0.5, y=pos.y, z=pos.z+math.random(0, 10)/10-0.5}
			minetest.add_item(p, stack)
		end
	end
end

minetest.register_node("mcl_stonecutter:stonecutter", {
	description = S("Stone Cutter"),
	_tt_help = S("Used to cut stone like materials."),
	_doc_items_longdesc = S("Stonecutters are used to create stairs and slabs from stone like materials. It is also the jobsite for the Stone Mason Villager."),
	tiles = {
		"mcl_stonecutter_top.png",
		"mcl_stonecutter_bottom.png",
		"mcl_stonecutter_side.png",
		"mcl_stonecutter_side.png",
		{name="mcl_stonecutter_saw.png",
		animation={
			type="vertical_frames",
			aspect_w=16,
			aspect_h=16,
			length=1
		}},
		{name="mcl_stonecutter_saw.png",
		animation={
			type="vertical_frames",
			aspect_w=16,
			aspect_h=16,
			length=1
		}}
	},
	use_texture_alpha = "clip",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { pickaxey=1, material_stone=1 },
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.0625, 0.5}, -- NodeBox1
			{-0.4375, 0.0625, 0, 0.4375, 0.5, 0}, -- NodeBox2
		}
	},
	_mcl_blast_resistance = 3.5,
	_mcl_hardness = 3.5,
	sounds = mcl_sounds.node_sound_stone_defaults(),

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local meta = minetest.get_meta(pos)
		meta:from_table(oldmetadata)
		drop_stonecutter_items(pos, meta)
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		else
			return stack:get_count()
		end
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		elseif to_list == "output" then
			return 0
		elseif from_list == "output" and to_list == "input" then
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			if inv:get_stack(to_list, to_index):is_empty() then
				return count
			else
				return 0
			end
		else
			return count
		end
	end,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		local meta = minetest.get_meta(pos)
		if from_list == "output" and to_list == "input" then
			local inv = meta:get_inventory()
			for i=1, inv:get_size("input") do
				if i ~= to_index then
					local istack = inv:get_stack("input", i)
					istack:set_count(math.max(0, istack:get_count() - count))
					inv:set_stack("input", i, istack)
				end
			end
		end
		update_stonecutter_slots(pos)
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		elseif listname == "output" then
			return 0
		else
			return stack:get_count()
		end
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		update_stonecutter_slots(pos)
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		if listname == "output" then
			local inv = meta:get_inventory()
			local input = inv:get_stack("input", 1)
			input:take_item()
			inv:set_stack("input", 1, input)
			if input:get_count() == 0 then
				meta:set_string("cut_stone", nil)
			end
		else
			meta:set_string("cut_stone", nil)
		end
		update_stonecutter_slots(pos)
	end,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("input", 1)
		inv:set_size("output", 1)
		local form = show_stonecutter_formspec()
		meta:set_string("formspec", form)
	end,
	on_rightclick = function(pos, node, player, itemstack)
		if not player:get_player_control().sneak then
			update_stonecutter_slots(pos)
		end
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		local sender_name = sender:get_player_name()
		if minetest.is_protected(pos, sender_name) then
			minetest.record_protection_violation(pos, sender_name)
			return
		end
		if fields then
			for k,v in pairs(fields) do
				if tostring(k) then
					local str = k:gsub("^item_button_","")
					local def = minetest.registered_nodes[str]
					if def and def._mcl_stonecutter_recipes then
						update_stonecutter_slots(pos, str)
					end
				end
			end
		end
	end,
})

minetest.register_craft({
	output = "mcl_stonecutter:stonecutter",
	recipe = {
		{ "", "", "" },
		{ "", "mcl_core:iron_ingot", "" },
		{ "mcl_core:stone", "mcl_core:stone", "mcl_core:stone" },
	}
})
