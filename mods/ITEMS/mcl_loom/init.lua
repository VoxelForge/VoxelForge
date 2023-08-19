local S = minetest.get_translator(minetest.get_current_modname())

local dyerecipes = {}
local preview_item_prefix = "mcl_banners:banner_preview_"

for name,pattern in pairs(mcl_banners.patterns) do
	for i=1,3 do for j = 1,3 do
		if pattern[i] and pattern[i][j] == "group:dye" and table.indexof(dyerecipes,name) == -1 then
			table.insert(dyerecipes,name) break
		end
	end	end
end

local function drop_items(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local bstack = inv:get_stack("banner", 1)
	local dstack = inv:get_stack("dye", 1)
	if not bstack:is_empty() then
		minetest.add_item(pos, bstack)
	end
	if not dstack:is_empty() then
		minetest.add_item(pos, dstack)
	end
end

local function show_loom_formspec(pos)
	local patterns = {}
	local count = 0
	if pos then
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local color
		local def = minetest.registered_items[inv:get_stack("dye",1):get_name()]
		if def and def.groups.dye and def._color then color = def._color end
		local x_len = 0
		local y_len = 0
		if dyerecipes and color then
			for k,v in pairs(dyerecipes) do
				x_len = x_len + 1
				count = count + 1
				if x_len > 4 then
					y_len = y_len + 1
					x_len = 1
				end
				local it = preview_item_prefix .. v .. "_" .. color
				local name = preview_item_prefix .. v .. "-" .. color
				table.insert(patterns,string.format("item_image_button[%f,%f;%f,%f;%s;%s;%s]",x_len,y_len,1,1, it, "item_button_"..name, ""))
			end
		end
	end

	local formspec = "size[9,8.75]"..
	"label[0,4.0;"..minetest.formspec_escape(minetest.colorize("#313131", S("Inventory"))).."]"..
	"label[1,0.1;"..minetest.formspec_escape(minetest.colorize("#313131", S("Loom"))).."]"..
	"list[current_player;main;0,4.5;9,3;9]"..
	mcl_formspec.get_itemslot_bg(0,4.5,9,3)..
	"list[current_player;main;0,7.74;9,1;]"..
	mcl_formspec.get_itemslot_bg(0,7.74,9,1)..
	"list[context;banner;0.5,0.7;1,1;]"..
	mcl_formspec.get_itemslot_bg(0.5,0.7,1,1)..
	"list[context;dye;1.5,0.7;1,1;]"..
	mcl_formspec.get_itemslot_bg(1.5,0.7,1,1)..
	--"list[context;pattern;0.5,1.7;1,1;]"..
	--mcl_formspec.get_itemslot_bg(0.5,1.7,1,1)..
	"list[context;output;7.5,0.7;1,1;]"..
	mcl_formspec.get_itemslot_bg(7.5,0.7,1,1)..
	"scroll_container[2,0.15;6.8,5;pattern_scroll;vertical;0.1]"..
	table.concat(patterns)..
	"scroll_container_end[]"..
	"scrollbaroptions[arrows=show;thumbsize=30;min=0;max="..(count * 2).."]"..
	"scrollbar[6.7,0;0.4,4;vertical;pattern_scroll;]"..
	"listring[context;output]"..
	"listring[current_player;main]"..
	"listring[context;input]"..
	"listring[current_player;main]"

	return formspec
end

local function update_slots(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	--local banner = inv:get_stack("banner", 1)
	local dye = inv:get_stack("dye", 1)
	--local pattern = inv:get_stack("pattern", 1)
	if minetest.get_item_group(dye:get_name(),"dye") > 0 then
		meta:set_string("formspec", show_loom_formspec(pos))
	else
		meta:set_string("formspec", show_loom_formspec(pos))
	end
end

local function create_banner(stack,pattern,color)
	local im = stack:get_meta()
	local layers = {}
	local old_layers = im:get_string("layers")
	if old_layers ~= "" then
		layers = minetest.deserialize(old_layers)
	end
	table.insert(layers,{
		pattern = pattern,
		color = "unicolor_"..mcl_dyes.colors[color].unicolor
	})
	im:set_string("description", mcl_banners.make_advanced_banner_description(stack:get_definition().description, layers))
	im:set_string("layers", minetest.serialize(layers))
	return stack
end

minetest.register_node("mcl_loom:loom", {
	description = S("Loom"),
	_tt_help = S("Used to create banner designs"),
	_doc_items_longdesc = S("This is the shepherd villager's work station. It is used to create banner designs."),
	tiles = {
		"loom_top.png", "loom_bottom.png",
		"loom_side.png", "loom_side.png",
		"loom_side.png", "loom_front.png"
	},
	paramtype2 = "facedir",
	groups = { axey = 2, handy = 1, deco_block = 1, material_wood = 1, flammable = 1 },
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_blast_resistance = 2.5,
	_mcl_hardness = 2.5,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("banner", 1)
		inv:set_size("dye", 1)
		inv:set_size("pattern", 1)
		inv:set_size("output", 1)
		local form = show_loom_formspec(pos)
		meta:set_string("formspec", form)
	end,
	on_destruct = drop_items,
	on_rightclick = function(pos, node, player, itemstack)
		if not player:get_player_control().sneak then
			update_slots(pos)
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
				if tostring(k) and k:find("^item_button_"..preview_item_prefix) then
					local str = k:gsub("^item_button_","")
					str = str:gsub("^"..preview_item_prefix,"")
					str = str:split("-")
					local pattern = str[1]
					local meta = minetest.get_meta(pos)
					local inv = meta:get_inventory()
					local cdef = minetest.registered_items[inv:get_stack("dye",1):get_name()]
					if not inv:is_empty("banner") and not inv:is_empty("dye") and cdef
						and mcl_dyes.colors[cdef._color] and table.indexof(dyerecipes,pattern) ~= -1 then
						inv:set_stack("output", 1, create_banner(inv:get_stack("banner",1),pattern,cdef._color))
					end
				end
			end
		end
		update_slots(pos)
	end,

	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		elseif listname == "output" then
			local inv = minetest.get_meta(pos):get_inventory()
			return math.min(inv:get_stack("banner",1):get_count(),inv:get_stack("dye",1):get_count())
		else
			return stack:get_count()
		end
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		return 0
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		elseif listname == "output" then return 0
		elseif listname == "banner" and minetest.get_item_group(stack:get_name(),"banner") == 0 then return 0
		elseif listname == "dye" and minetest.get_item_group(stack:get_name(),"dye") == 0 then return 0
		elseif listname == "pattern" and minetest.get_item_group(stack:get_name(),"banner_pattern") == 0 then return 0
		else
			return stack:get_count()
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
		update_slots(pos)
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		update_slots(pos)
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		if listname == "output" then
			local inv = meta:get_inventory()
			local banner = inv:get_stack("banner", 1)
			local dye = inv:get_stack("dye", 1)
			banner:take_item(stack:get_count())
			dye:take_item(stack:get_count())
			inv:set_stack("banner", 1, banner)
			inv:set_stack("dye", 1, dye)
		end
		update_slots(pos)
	end,
})


minetest.register_craft({
	output = "mcl_loom:loom",
	recipe = {
		{ "", "", "" },
		{ "mcl_mobitems:string", "mcl_mobitems:string", "" },
		{ "group:wood", "group:wood", "" },
	}
})
