local S
if minetest.get_translator then
	S = minetest.get_translator("vlf_structure_block")
else
	S = function(s) return s end
end
local F = minetest.formspec_escape

local vlf_structure_block = {}

-- Directory separator
local DIR_DELIM = "/"
-- Set to true to enable `make_vlf_structure_block_readme` command
local MAKE_README = false

local import_path_full = table.concat({minetest.get_modpath("vlf_schematics"), "schems"}, DIR_DELIM)
local export_path_full = table.concat({minetest.get_modpath("vlf_schematics"), "schems"}, DIR_DELIM)

-- truncated export path so the server directory structure is not exposed publicly
local export_path_trunc = table.concat({S("<mod path>"), "output_schems"}, DIR_DELIM)

-- Text colors
local TEXT_COLOR_GUI = "#D79E9E"
local TEXT_COLOR_GUI_NUMBER = 0xD79E9E
local TEXT_COLOR_ERROR = "#FF0000"
local TEXT_COLOR_SUCCESS = "#00FF00"

-- Text symbol for force placement
local FORCE_SYMBOL = "[F]"



local can_import = minetest.read_schematic ~= nil

vlf_structure_block.markers = {}

-- [local function] Renumber table
local function renumber(t)
	local res = {}
	for _, i in pairs(t) do
		res[#res + 1] = i
	end
	return res
end

local get_border_texture = function()
	local val = minetest.settings:get("vlf_structure_block_border_style")
	if val == "checkers" then
		-- checkers style
		return "vlf_structure_block_border_checkers.png"
	else
		-- edges style
		return "vlf_structure_block_border.png"
	end
end

local NEEDED_PRIV = "server"
local function check_priv(player_name, quit)
	local privs = minetest.get_player_privs(player_name)
	if privs[NEEDED_PRIV] then
		return true
	else
		if not quit then
			minetest.chat_send_player(player_name, minetest.colorize(TEXT_COLOR_ERROR,
					S("Insufficient privileges! You need the “@1” privilege to use this.", NEEDED_PRIV)))
		end
		return false
	end
end

-- Lua export
local export_schematic_to_lua
if can_import then
	export_schematic_to_lua = function(schematic, filepath, options)
		if not options then options = {} end
		local str = minetest.serialize_schematic(schematic, "lua", options)
		local file = io.open(filepath, "w")
		if file and str then
			file:write(str)
			file:flush()
			file:close()
			return true
		else
			return false
		end
	end
end

-- Export nodes between pos1 and pos2 into filepath.
-- The area MUST be emerged and loaded before calling this function.
-- * path: path name (without file name)
-- * schem_name: raw schematic name (without ".mts" suffix)
-- * pos1, pos2: Area bounds (vectors)
-- * player_name: Player name for chat messages
-- * slice_list: y_slice list for minetest.create_schematic
--
-- returns true on success
local export_schematic_to_mts = function(pos1, pos2, path, schem_name, player_name, slice_list)
	local plist = vlf_structure_block.scan_metadata(pos1, pos2)
	local probability_list = {}
	for hash, i in pairs(plist) do
		local prob = vlf_structure_block.lua_prob_to_schematic_prob(i.prob)
		if i.force_place == true then
			prob = prob + 128
		end

		table.insert(probability_list, {
			pos = minetest.get_position_from_hash(hash),
			prob = prob,
		})
	end

	local filepath = path..schem_name..".mts"
	local res = minetest.create_schematic(pos1, pos2, probability_list, filepath, slice_list)

	if res then
		minetest.chat_send_player(player_name, minetest.colorize(TEXT_COLOR_SUCCESS,
				S("Exported schematic to @1", filepath)))
		-- Additional export to Lua file if MTS export was successful
		local schematic = minetest.read_schematic(filepath, {})
		if schematic and minetest.settings:get_bool("vlf_structure_block_export_lua") and export_schematic_to_lua then
			local filepath_lua = path..schem_name..".lua"
			res = export_schematic_to_lua(schematic, filepath_lua)
			if res then
				minetest.chat_send_player(player_name, minetest.colorize(TEXT_COLOR_SUCCESS,
						S("Exported schematic to @1", filepath_lua)))
			end
		end
		return true
	else
		minetest.chat_send_player(player_name, minetest.colorize(TEXT_COLOR_ERROR,
				S("Failed to export schematic to @1", filepath)))
		return false
	end
end

---
--- Formspec API
---

local contexts = {}
local form_data = {}
local tabs = {}
local forms = {}
local displayed_waypoints = {}

-- Sadly, the probabilities presented in Lua (0-255) are not identical to the REAL probabilities in the
-- schematic file (0-127). There are two converter functions to convert from one probability type to another.
-- This mod tries to retain the “Lua probability” as long as possible and only switches to “schematic probability”
-- on an actual export to a schematic.

function vlf_structure_block.lua_prob_to_schematic_prob(lua_prob)
	return math.floor(lua_prob / 2)
end

function vlf_structure_block.schematic_prob_to_lua_prob(schematic_prob)
	return schematic_prob * 2

end

-- [function] Add form
function vlf_structure_block.add_form(name, def)
	def.name = name
	forms[name] = def

	if def.tab then
		tabs[#tabs + 1] = name
	end
end

-- [function] Generate tabs
function vlf_structure_block.generate_tabs(current)
	local retval = "tabheader[0,0;tabs;"
	for _, t in pairs(tabs) do
		local f = forms[t]
		if f.tab ~= false and f.caption then
			retval = retval..f.caption..","

			if type(current) ~= "number" and current == f.name then
				current = _
			end
		end
	end
	retval = retval:sub(1, -2) -- Strip last comma
	retval = retval..";"..current.."]" -- Close tabheader
	return retval
end

-- [function] Handle tabs
function vlf_structure_block.handle_tabs(pos, name, fields)
	local tab = tonumber(fields.tabs)
	if tab and tabs[tab] and forms[tabs[tab]] then
		vlf_structure_block.show_formspec(pos, name, forms[tabs[tab]].name)
		return true
	end
end

-- [function] Show formspec
function vlf_structure_block.show_formspec(pos, player, tab, show, ...)
	if forms[tab] then
		if type(player) == "string" then
			player = minetest.get_player_by_name(player)
		end
		local name = player:get_player_name()

		if show ~= false then
			if not form_data[name] then
				form_data[name] = {}
			end

			local form = forms[tab].get(form_data[name], pos, name, ...)
			if forms[tab].tab then
				form = form..vlf_structure_block.generate_tabs(tab)
			end

			minetest.show_formspec(name, "vlf_structure_block:"..tab, form)
			contexts[name] = pos

			-- Update player attribute
			if forms[tab].cache_name ~= false then
				local pmeta = player:get_meta()
				pmeta:set_string("vlf_structure_block:tab", tab)
			end
		else
			minetest.close_formspec(pname, "vlf_structure_block:"..tab)
		end
	end
end

-- [event] On receive fields
minetest.register_on_player_receive_fields(function(player, formname, fields)
	local formname = formname:split(":")

	if formname[1] == "vlf_structure_block" and forms[formname[2]] then
		local handle = forms[formname[2]].handle
		local name = player:get_player_name()
		if contexts[name] then
			if not form_data[name] then
				form_data[name] = {}
			end

			if not vlf_structure_block.handle_tabs(contexts[name], name, fields) and handle then
				handle(form_data[name], contexts[name], name, fields)
			end
		end
	end
end)

-- Helper function. Scans probabilities of all nodes in the given area and returns a prob_list
vlf_structure_block.scan_metadata = function(pos1, pos2)
	local prob_list = {}

	for x=pos1.x, pos2.x do
	for y=pos1.y, pos2.y do
	for z=pos1.z, pos2.z do
		local scanpos = {x=x, y=y, z=z}
		local node = minetest.get_node_or_nil(scanpos)

		local prob, force_place
		if node == nil or node.name == "vlf_structure_block:void" then
			prob = 0
			force_place = false
		else
			local meta = minetest.get_meta(scanpos)

			prob = tonumber(meta:get_string("vlf_structure_block_prob")) or 255
			local fp = meta:get_string("vlf_structure_block_force_place")
			if fp == "true" then
				force_place = true
			else
				force_place = false
			end
		end

		local hashpos = minetest.hash_node_position(scanpos)
		prob_list[hashpos] = {
			pos = scanpos,
			prob = prob,
			force_place = force_place,
		}
	end
	end
	end

	return prob_list
end

-- alignment for probtool item count
local PROBTOOL_COUNT_ALIGN = 5 -- top left

-- Sets probability and force_place metadata of an item.
-- Also updates item description.
-- The itemstack is updated in-place.
local function set_item_metadata(itemstack, prob, force_place)
	local smeta = itemstack:get_meta()
	local prob_desc = "\n"..S("Probability: @1", prob or
			smeta:get_string("vlf_structure_block_prob") or S("Not Set"))
	-- Update probability
	if prob and prob >= 0 and prob < 255 then
		smeta:set_string("vlf_structure_block_prob", tostring(prob))
		local print_count = tostring(prob)
		if force_place then
			print_count = print_count .. FORCE_SYMBOL
		end
		-- Display a number in the item icon
		smeta:set_string("count_meta", print_count)
		smeta:set_int("count_alignment", PROBTOOL_COUNT_ALIGN)
	elseif prob and prob == 255 then
		-- Clear prob metadata for default probability
		prob_desc = ""
		smeta:set_string("vlf_structure_block_prob", nil)
		if force_place == true then
			smeta:set_string("count_meta", FORCE_SYMBOL)
			smeta:set_string("count_alignment", PROBTOOL_COUNT_ALIGN)
		else
			smeta:set_string("count_meta", nil)
			smeta:set_string("count_alignment", nil)
		end
	else
		prob_desc = "\n"..S("Probability: @1", smeta:get_string("vlf_structure_block_prob") or
				S("Not Set"))
	end

	-- Update force place
	if force_place == true then
		smeta:set_string("vlf_structure_block_force_place", "true")
	elseif force_place == false then
		smeta:set_string("vlf_structure_block_force_place", nil)
	end

	-- Update description
	local desc = minetest.registered_items[itemstack:get_name()].description
	local meta_desc = smeta:get_string("description")
	if meta_desc and meta_desc ~= "" then
		desc = meta_desc
	end

	local original_desc = smeta:get_string("original_description")
	if original_desc and original_desc ~= "" then
		desc = original_desc
	else
		smeta:set_string("original_description", desc)
	end

	local force_desc = ""
	if smeta:get_string("vlf_structure_block_force_place") == "true" then
		force_desc = "\n"..S("Force placement")
	end

	desc = desc..minetest.colorize(TEXT_COLOR_GUI, prob_desc..force_desc)

	smeta:set_string("description", desc)

	return itemstack
end

---
--- Formspec Tabs
---
local import_btn = ""
if can_import then
	import_btn = "button[0.5,2.5;6,1;import;"..F(S("Import schematic")).."]"
end
vlf_structure_block.add_form("main", {
	tab = true,
	caption = S("Main"),
	get = function(self, pos, name)
		local meta = minetest.get_meta(pos):to_table().fields
		local strpos = minetest.pos_to_string(pos)
		local hashpos = minetest.hash_node_position(pos)

		local border_button
		if meta.schem_border == "true" and vlf_structure_block.markers[hashpos] then
			border_button = "button[3.5,7.5;3,1;border;"..F(S("Hide border")).."]"
		else
			border_button = "button[3.5,7.5;3,1;border;"..F(S("Show border")).."]"
		end

		local xs, ys, zs = meta.x_size or 1, meta.y_size or 1, meta.z_size or 1
		local size = {x=xs, y=ys, z=zs}
		local schem_name = meta.schem_name or ""

		local form = [[
			size[7,8]
			label[0.5,-0.1;]]..F(S("Position: @1", strpos))..[[]
			label[3,-0.1;]]..F(S("Owner: @1", name))..[[]
			label[0.5,0.4;]]..F(S("Schematic name: @1", F(schem_name)))..[[]
			label[0.5,0.9;]]..F(S("Size: @1", minetest.pos_to_string(size)))..[[]

			field[0.8,2;5,1;name;]]..F(S("Schematic name:"))..[[;]]..F(schem_name or "")..[[]
			button[5.3,1.69;1.2,1;save_name;]]..F(S("OK"))..[[]
			tooltip[save_name;]]..F(S("Save schematic name"))..[[]
			field_close_on_enter[name;false]

			button[0.5,3.5;6,1;export;]]..F(S("Export schematic")).."]"..
			import_btn..[[
			textarea[0.8,4.5;6.2,1;;]]..F(S("Export/import path:\n@1",
			export_path_trunc .. DIR_DELIM .. F(S("<name>"))..".mts"))..[[;]
			button[0.5,5.5;3,1;air2void;]]..F(S("Air to voids"))..[[]
			button[3.5,5.5;3,1;void2air;]]..F(S("Voids to air"))..[[]
			tooltip[air2void;]]..F(S("Turn all air nodes into schematic void nodes"))..[[]
			tooltip[void2air;]]..F(S("Turn all schematic void nodes into air nodes"))..[[]
			field[0.8,7;2,1;x;]]..F(S("X size:"))..[[;]]..xs..[[]
			field[2.8,7;2,1;y;]]..F(S("Y size:"))..[[;]]..ys..[[]
			field[4.8,7;2,1;z;]]..F(S("Z size:"))..[[;]]..zs..[[]
			field_close_on_enter[x;false]
			field_close_on_enter[y;false]
			field_close_on_enter[z;false]
			button[0.5,7.5;3,1;save;]]..F(S("Save size"))..[[]
		]]..
		border_button
		if minetest.get_modpath("doc") then
			form = form .. "image_button[6.4,-0.2;0.8,0.8;doc_button_icon_lores.png;doc;]" ..
			"tooltip[doc;"..F(S("Help")).."]"
		end
		return form
	end,
	handle = function(self, pos, name, fields)
		if fields.doc then
			doc.show_entry(name, "nodes", "vlf_structure_block:creator", true)
			return
		end

		if not check_priv(name, fields.quit) then
			return
		end

		local realmeta = minetest.get_meta(pos)
		local meta = realmeta:to_table().fields
		local hashpos = minetest.hash_node_position(pos)

		-- Save size vector values
		if (fields.x and fields.x ~= "") then
			local x = tonumber(fields.x)
			if x then
				meta.x_size = math.max(x, 1)
			end
		end
		if (fields.y and fields.y ~= "") then
			local y = tonumber(fields.y)
			if y then
				meta.y_size = math.max(y, 1)
			end
		end
		if (fields.z and fields.z ~= "") then
			local z = tonumber(fields.z)
			if z then
				meta.z_size = math.max(z, 1)
			end
		end

		-- Save schematic name
		if fields.name then
			meta.schem_name = fields.name
		end

		-- Node conversion
		if (fields.air2void) then
			local pos1, pos2 = vlf_structure_block.size(pos)
			pos1, pos2 = vlf_structure_block.sort_pos(pos1, pos2)
			local nodes = minetest.find_nodes_in_area(pos1, pos2, {"air"})
			minetest.bulk_set_node(nodes, {name="vlf_structure_block:void"})
			return
		elseif (fields.void2air) then
			local pos1, pos2 = vlf_structure_block.size(pos)
			pos1, pos2 = vlf_structure_block.sort_pos(pos1, pos2)
			local nodes = minetest.find_nodes_in_area(pos1, pos2, {"vlf_structure_block:void"})
			minetest.bulk_set_node(nodes, {name="air"})
			return
		end

		-- Toggle border
		if fields.border then
			if meta.schem_border == "true" and vlf_structure_block.markers[hashpos] then
				vlf_structure_block.unmark(pos)
				meta.schem_border = "false"
			else
				vlf_structure_block.mark(pos)
				meta.schem_border = "true"
			end
		end

		-- Export schematic
		if fields.export and meta.schem_name and meta.schem_name ~= "" then
			local pos1, pos2 = vlf_structure_block.size(pos)
			pos1, pos2 = vlf_structure_block.sort_pos(pos1, pos2)
			local path = export_path_full .. DIR_DELIM
			minetest.mkdir(path)

			local slist = minetest.deserialize(meta.slices)
			local slice_list = {}
			for _, i in pairs(slist) do
				slice_list[#slice_list + 1] = {
					ypos = i.ypos,
					prob = vlf_structure_block.lua_prob_to_schematic_prob(i.prob),
				}
			end

			-- We emerge the entire area before exporting first.
			-- This is required to so make sure we don't export
			-- unloaded areas (=ignore nodes).

			-- callback for minetest.emerge_area
			local after_emerged = function(blockpos, action, calls_remaining, param)
				if action == minetest.EMERGE_CANCELLED then
					minetest.chat_send_player(param.player_name, minetest.colorize(TEXT_COLOR_ERROR,
						S("Could not emerge area from @1 to @2: Emerging was cancelled. Nothing was exported.")))
				elseif action == minetest.EMERGE_ERRORED then
					minetest.chat_send_player(param.player_name, minetest.colorize(TEXT_COLOR_ERROR,
						S("Could not emerge area from @1 to @2: Error while emerging. Nothing was exported.")))
				elseif action == minetest.EMERGE_GENERATED or action == minetest.EMERGE_FROM_MEMORY or action == minetest.EMERGE_FROM_DISK then
					if calls_remaining > 0 then
						return
					end

					-- Start the export!
					export_schematic_to_mts(param.pos1, param.pos2, param.path, param.schem_name, param.player_name, param.slice_list)

					-- Note: Player chat message is handled in the export function
				else
					minetest.chat_send_player(param.player_name, minetest.colorize(TEXT_COLOR_ERROR,
						S("Could not emerge area from @1 to @2: Unknown action in emerge callback. Nothing was exported.")))

				end
			end
			local emerge_param = {
				pos1 = pos1,
				pos2 = pos2,
				path = path,
				schem_name = meta.schem_name,
				player_name = name,
				slice_list = slice_list
			}
			minetest.emerge_area(pos1, pos2, after_emerged, emerge_param)
		end

		-- Import schematic
		if fields.import and meta.schem_name and meta.schem_name ~= "" then
			if not can_import then
				return
			end
			local pos1
			local node = minetest.get_node(pos)
			local path = import_path_full .. DIR_DELIM

			local filepath = path..meta.schem_name..".mts"
			local schematic = minetest.read_schematic(filepath, {write_yslice_prob="low"})
			local success = false

			if schematic then
				meta.x_size = schematic.size.x
				meta.y_size = schematic.size.y
				meta.z_size = schematic.size.z
				meta.slices = minetest.serialize(renumber(schematic.yslice_prob))
				local special_x_size = meta.x_size
				local special_y_size = meta.y_size
				local special_z_size = meta.z_size

				if node.param2 == 1 then
					pos1 = vector.add(pos, {x=1,y=0,z=-meta.z_size+1})
					meta.x_size, meta.z_size = meta.z_size, meta.x_size
				elseif node.param2 == 2 then
					pos1 = vector.add(pos, {x=-meta.x_size+1,y=0,z=-meta.z_size})
				elseif node.param2 == 3 then
					pos1 = vector.add(pos, {x=-meta.x_size,y=0,z=0})
					meta.x_size, meta.z_size = meta.z_size, meta.x_size
				else
					pos1 = vector.add(pos, {x=0,y=0,z=1})
				end

				local schematic_for_meta = table.copy(schematic)
				-- Strip probability data for placement
				schematic.yslice_prob = {}
				for d=1, #schematic.data do
					schematic.data[d].prob = nil
				end

				-- Place schematic
				success = minetest.place_schematic(pos1, schematic, "0", nil, true)

				-- Add special schematic data to nodes
				if success then
					local d = 1
					for z=0, special_z_size-1 do
					for y=0, special_y_size-1 do
					for x=0, special_x_size-1 do
						local data = schematic_for_meta.data[d]
						local pp = {x=pos1.x+x, y=pos1.y+y, z=pos1.z+z}
						if data.prob == 0 then
							minetest.set_node(pp, {name="vlf_structure_block:void"})
						else
							local meta = minetest.get_meta(pp)
							if data.prob and data.prob ~= 255 and data.prob ~= 254 then
								meta:set_string("vlf_structure_block_prob", tostring(data.prob))
							else
								meta:set_string("vlf_structure_block_prob", "")
							end
							if data.force_place then
								meta:set_string("vlf_structure_block_force_place", "true")
							else
								meta:set_string("vlf_structure_block_force_place", "")
							end
						end
						d = d + 1
					end
					end
					end
				end
			end
			if success then
				minetest.chat_send_player(name, minetest.colorize(TEXT_COLOR_SUCCESS,
						S("Imported schematic from @1", filepath)))
			else
				minetest.chat_send_player(name, minetest.colorize(TEXT_COLOR_ERROR,
						S("Failed to import schematic from @1", filepath)))
			end
		end



		-- Save meta before updating visuals
		local inv = realmeta:get_inventory():get_lists()
		realmeta:from_table({fields = meta, inventory = inv})

		-- Update border
		if not fields.border and meta.schem_border == "true" then
			vlf_structure_block.mark(pos)
		end

		-- Update formspec
		if not fields.quit then
			vlf_structure_block.show_formspec(pos, minetest.get_player_by_name(name), "main")
		end
	end,
})

vlf_structure_block.add_form("slice", {
	caption = S("Y Slices"),
	tab = true,
	get = function(self, pos, name, visible_panel)
		local meta = minetest.get_meta(pos):to_table().fields

		self.selected = self.selected or 1
		local selected = tostring(self.selected)
		local slice_list = minetest.deserialize(meta.slices)
		local slices = ""
		for _, i in pairs(slice_list) do
			local insert = F(S("Y = @1; Probability = @2", tostring(i.ypos), tostring(i.prob)))
			slices = slices..insert..","
		end
		slices = slices:sub(1, -2) -- Remove final comma

		local form = [[
			size[7,8]
			table[0,0;6.8,6;slices;]]..slices..[[;]]..selected..[[]
		]]

		-- Close edit panel if no slices
		if self.panel_edit and slices == "" then
			self.panel_edit = nil
		end

		if self.panel_add or self.panel_edit then
			local ypos_default, prob_default = "", ""
			local done_button = "button[5,7.18;2,1;done_add;"..F(S("Add")).."]"
			if self.panel_edit then
				done_button = "button[5,7.18;2,1;done_edit;"..F(S("Apply")).."]"
				if slice_list[self.selected] then
					ypos_default = slice_list[self.selected].ypos
					prob_default = slice_list[self.selected].prob
				end
			end

			local field_ypos = ""
			if self.panel_add then
				field_ypos = "field[0.3,7.5;2.5,1;ypos;"..F(S("Y position (max. @1):", (meta.y_size - 1)))..";"..ypos_default.."]"
			end

			form = form..[[
				]]..field_ypos..[[
				field[2.8,7.5;2.5,1;prob;]]..F(S("Probability (0-255):"))..[[;]]..prob_default..[[]
				field_close_on_enter[ypos;false]
				field_close_on_enter[prob;false]
			]]..done_button
		end

		if not self.panel_edit then
			if self.panel_add then
				form = form.."button[0,6;2.4,1;add;"..F(S("Cancel")).."]"
			else
				form = form.."button[0,6;2.4,1;add;"..F(S("Add slice")).."]"
			end
		end

		if slices ~= "" and self.selected and not self.panel_add then
			if not self.panel_edit then
				form = form..[[
					button[2.4,6;2.4,1;remove;]]..F(S("Remove slice"))..[[]
					button[4.8,6;2.4,1;edit;]]..F(S("Edit slice"))..[[]
				]]
			else
				form = form..[[
					button[4.8,6;2.4,1;edit;]]..F(S("Back"))..[[]
				]]
			end
		end

		return form
	end,
	handle = function(self, pos, name, fields)
		if not check_priv(name, fields.quit) then
			return
		end

		local meta = minetest.get_meta(pos)
		local player = minetest.get_player_by_name(name)

		if fields.slices then
			local slices = fields.slices:split(":")
			self.selected = tonumber(slices[2])
		end

		if fields.add then
			if not self.panel_add then
				self.panel_add = true
				vlf_structure_block.show_formspec(pos, player, "slice")
			else
				self.panel_add = nil
				vlf_structure_block.show_formspec(pos, player, "slice")
			end
		end

		local ypos, prob = tonumber(fields.ypos), tonumber(fields.prob)
		if fields.done_edit then
			ypos = 0
		end
		if (fields.done_add or fields.done_edit) and ypos and prob and
				 ypos <= (meta:get_int("y_size") - 1) and prob >= 0 and prob <= 255 then
			local slice_list = minetest.deserialize(meta:get_string("slices"))
			local index = #slice_list + 1
			if fields.done_edit then
				index = self.selected
			end

			local dupe = false
			if fields.done_add then
				for k,v in pairs(slice_list) do
					if v.ypos == ypos then
						v.prob = prob
						dupe = true
					end
				end
			end
			if fields.done_edit and slice_list[index] then
				ypos = slice_list[index].ypos
			end
			if not dupe then
				slice_list[index] = {ypos = ypos, prob = prob}
			end

			meta:set_string("slices", minetest.serialize(slice_list))

			-- Update and show formspec
			self.panel_add = nil
			vlf_structure_block.show_formspec(pos, player, "slice")
		end

		if fields.remove and self.selected then
			local slice_list = minetest.deserialize(meta:get_string("slices"))
			slice_list[self.selected] = nil
			meta:set_string("slices", minetest.serialize(renumber(slice_list)))

			-- Update formspec
			self.selected = math.max(1, self.selected-1)
			self.panel_edit = nil
			vlf_structure_block.show_formspec(pos, player, "slice")
		end

		if fields.edit then
			if not self.panel_edit then
				self.panel_edit = true
				vlf_structure_block.show_formspec(pos, player, "slice")
			else
				self.panel_edit = nil
				vlf_structure_block.show_formspec(pos, player, "slice")
			end
		end
	end,
})

vlf_structure_block.add_form("probtool", {
	cache_name = false,
	caption = S("Schematic Node Probability Tool"),
	get = function(self, pos, name)
		local player = minetest.get_player_by_name(name)
		if not player then
			return
		end
		local probtool = player:get_wielded_item()
		if probtool:get_name() ~= "vlf_structure_block:probtool" then
			return
		end

		local meta = probtool:get_meta()
		local prob = tonumber(meta:get_string("vlf_structure_block_prob"))
		local force_place = meta:get_string("vlf_structure_block_force_place")

		if not prob then
			prob = 255
		end
		if force_place == nil or force_place == "" then
			force_place = "false"
		end
		if force_place == "true" then
			self.force_place = true
		else
			self.force_place = false
		end
		local form = "size[5,4]"..
			"label[0,0;"..F(S("Schematic Node Probability Tool")).."]"..
			"field[0.75,1;4,1;prob;"..F(S("Probability (0-255)"))..";"..prob.."]"..
			"checkbox[0.60,1.5;force_place;"..F(S("Force placement"))..";" .. force_place .. "]" ..
			"button_exit[0.25,3;2,1;cancel;"..F(S("Cancel")).."]"..
			"button_exit[2.75,3;2,1;submit;"..F(S("Apply")).."]"..
			"tooltip[prob;"..F(S("Probability that the node will be placed")).."]"..
			"tooltip[force_place;"..F(S("If enabled, the node will replace nodes other than air and ignore")).."]"..
			"field_close_on_enter[prob;false]"
		return form
	end,
	handle = function(self, pos, name, fields)
		if not check_priv(name, fields.quit) then
			return
		end

		if fields.submit then
			local prob = tonumber(fields.prob)
			if prob then
				local player = minetest.get_player_by_name(name)
				if not player then
					return
				end
				local probtool = player:get_wielded_item()
				if probtool:get_name() ~= "vlf_structure_block:probtool" then
					return
				end

				local force_place = self.force_place == true

				set_item_metadata(probtool, prob, force_place)

				-- Repurpose the tool's wear bar to display the set probability
				probtool:set_wear(math.floor(((255-prob)/255)*65535))

				player:set_wielded_item(probtool)
			end
		end
		if fields.force_place == "true" then
			self.force_place = true
		elseif fields.force_place == "false" then
			self.force_place = false
		end
	end,
})

---
--- API
---

--- Copies and modifies positions `pos1` and `pos2` so that each component of
-- `pos1` is less than or equal to the corresponding component of `pos2`.
-- Returns the new positions.
function vlf_structure_block.sort_pos(pos1, pos2)
	if not pos1 or not pos2 then
		return
	end

	pos1, pos2 = table.copy(pos1), table.copy(pos2)
	if pos1.x > pos2.x then
		pos2.x, pos1.x = pos1.x, pos2.x
	end
	if pos1.y > pos2.y then
		pos2.y, pos1.y = pos1.y, pos2.y
	end
	if pos1.z > pos2.z then
		pos2.z, pos1.z = pos1.z, pos2.z
	end
	return pos1, pos2
end

-- [function] Prepare size
function vlf_structure_block.size(pos)
	local pos1   = vector.new(pos)
	local meta   = minetest.get_meta(pos)
	local node   = minetest.get_node(pos)
	local param2 = node.param2
	local size   = {
		x = meta:get_int("x_size"),
		y = math.max(meta:get_int("y_size") - 1, 0),
		z = meta:get_int("z_size"),
	}

	if param2 == 1 then
		local new_pos = vector.add({x = size.z, y = size.y, z = -size.x}, pos)
		pos1.x = pos1.x + 1
		new_pos.z = new_pos.z + 1
		return pos1, new_pos
	elseif param2 == 2 then
		local new_pos = vector.add({x = -size.x, y = size.y, z = -size.z}, pos)
		pos1.z = pos1.z - 1
		new_pos.x = new_pos.x + 1
		return pos1, new_pos
	elseif param2 == 3 then
		local new_pos = vector.add({x = -size.z, y = size.y, z = size.x}, pos)
		pos1.x = pos1.x - 1
		new_pos.z = new_pos.z - 1
		return pos1, new_pos
	else
		local new_pos = vector.add(size, pos)
		pos1.z = pos1.z + 1
		new_pos.x = new_pos.x - 1
		return pos1, new_pos
	end
end

-- [function] Mark region
function vlf_structure_block.mark(pos)
	vlf_structure_block.unmark(pos)

	local id = minetest.hash_node_position(pos)
	local owner = minetest.get_meta(pos):get_string("owner")
	local pos1, pos2 = vlf_structure_block.size(pos)
	pos1, pos2 = vlf_structure_block.sort_pos(pos1, pos2)

	local thickness = 0.2
	local sizex, sizey, sizez = (1 + pos2.x - pos1.x) / 2, (1 + pos2.y - pos1.y) / 2, (1 + pos2.z - pos1.z) / 2
	local m = {}
	local low = true
	local offset

	-- XY plane markers
	for _, z in ipairs({pos1.z - 0.5, pos2.z + 0.5}) do
		if low then
			offset = -0.01
		else
			offset = 0.01
		end
		local marker = minetest.add_entity({x = pos1.x + sizex - 0.5, y = pos1.y + sizey - 0.5, z = z + offset}, "vlf_structure_block:display")
		if marker ~= nil then
			marker:set_properties({
				visual_size={x=(sizex+0.01) * 2, y=(sizey+0.01) * 2},
			})
			marker:get_luaentity().id = id
			marker:get_luaentity().owner = owner
			table.insert(m, marker)
		end
		low = false
	end

	low = true
	-- YZ plane markers
	for _, x in ipairs({pos1.x - 0.5, pos2.x + 0.5}) do
		if low then
			offset = -0.01
		else
			offset = 0.01
		end

		local marker = minetest.add_entity({x = x + offset, y = pos1.y + sizey - 0.5, z = pos1.z + sizez - 0.5}, "vlf_structure_block:display")
		if marker ~= nil then
			marker:set_properties({
				visual_size={x=(sizez+0.01) * 2, y=(sizey+0.01) * 2},
			})
			marker:set_rotation({x=0, y=math.pi / 2, z=0})
			marker:get_luaentity().id = id
			marker:get_luaentity().owner = owner
			table.insert(m, marker)
		end
		low = false
	end

	low = true
	-- XZ plane markers
	for _, y in ipairs({pos1.y - 0.5, pos2.y + 0.5}) do
		if low then
			offset = -0.01
		else
			offset = 0.01
		end

		local marker = minetest.add_entity({x = pos1.x + sizex - 0.5, y = y + offset, z = pos1.z + sizez - 0.5}, "vlf_structure_block:display")
		if marker ~= nil then
			marker:set_properties({
				visual_size={x=(sizex+0.01) * 2, y=(sizez+0.01) * 2},
			})
			marker:set_rotation({x=math.pi/2, y=0, z=0})
			marker:get_luaentity().id = id
			marker:get_luaentity().owner = owner
			table.insert(m, marker)
		end
		low = false
	end



	vlf_structure_block.markers[id] = m
	return true
end

-- [function] Unmark region
function vlf_structure_block.unmark(pos)
	local id = minetest.hash_node_position(pos)
	if vlf_structure_block.markers[id] then
		local retval
		for _, entity in ipairs(vlf_structure_block.markers[id]) do
			entity:remove()
			retval = true
		end
		return retval
	end
end

---
--- Mark node probability values near player
---

-- Show probability and force_place status of a particular position for player in HUD.
-- Probability is shown as a number followed by the FORCE_SYMBOL if the node is force-placed.
function vlf_structure_block.display_node_prob(player, pos, prob, force_place)
	local wpstring
	if prob and force_place == true then
		wpstring = string.format("%s "..FORCE_SYMBOL, prob)
	elseif prob and type(tonumber(prob)) == "number" then
		wpstring = prob
	elseif force_place == true then
		wpstring = FORCE_SYMBOL
	end
	if wpstring then
		return player:hud_add({
			hud_elem_type = "waypoint",
			name = wpstring,
			precision = 0,
			text = "m", -- For the distance artifact [legacy]
			number = TEXT_COLOR_GUI_NUMBER,
			world_pos = pos,
			z_index = -300,
		})
	end
end

-- Display the node probabilities and force_place status of the nodes in a region.
-- By default, this is done for nodes near the player (distance: 5).
-- But the boundaries can optionally be set explicitly with pos1 and pos2.
function vlf_structure_block.display_node_probs_region(player, pos1, pos2)
	local playername = player:get_player_name()
	local pos = vector.round(player:get_pos())

	local dist = 5
	-- Default: 5 nodes away from player in any direction
	if not pos1 then
		pos1 = vector.subtract(pos, dist)
	end
	if not pos2 then
		pos2 = vector.add(pos, dist)
	end
	for x=pos1.x, pos2.x do
		for y=pos1.y, pos2.y do
			for z=pos1.z, pos2.z do
				local checkpos = {x=x, y=y, z=z}
				local nodehash = minetest.hash_node_position(checkpos)

				-- If node is already displayed, remove it so it can re replaced later
				if displayed_waypoints[playername][nodehash] then
					player:hud_remove(displayed_waypoints[playername][nodehash])
					displayed_waypoints[playername][nodehash] = nil
				end

				local prob, force_place
				local meta = minetest.get_meta(checkpos)
				prob = meta:get_string("vlf_structure_block_prob")
				force_place = meta:get_string("vlf_structure_block_force_place") == "true"
				local hud_id = vlf_structure_block.display_node_prob(player, checkpos, prob, force_place)
				if hud_id then
					displayed_waypoints[playername][nodehash] = hud_id
					displayed_waypoints[playername].display_active = true
				end
			end
		end
	end
end

-- Remove all active displayed node statuses.
function vlf_structure_block.clear_displayed_node_probs(player)
	local playername = player:get_player_name()
	for nodehash, hud_id in pairs(displayed_waypoints[playername]) do
		if nodehash ~= "display_active" then
			player:hud_remove(hud_id)
			displayed_waypoints[playername][nodehash] = nil
			displayed_waypoints[playername].display_active = false
		end
	end
end

minetest.register_on_joinplayer(function(player)
	displayed_waypoints[player:get_player_name()] = {
		display_active = false	-- If true, there *might* be at least one active node prob HUD display
					-- If false, no node probabilities are displayed for sure.
	}
end)

minetest.register_on_leaveplayer(function(player)
	displayed_waypoints[player:get_player_name()] = nil
end)

-- Regularily clear the displayed node probabilities and force_place
-- for all players who do not wield the probtool.
-- This makes sure the screen is not spammed with information when it
-- isn't needed.
local cleartimer = 0
minetest.register_globalstep(function(dtime)
	cleartimer = cleartimer + dtime
	if cleartimer > 2 then
		local players = minetest.get_connected_players()
		for p = 1, #players do
			local player = players[p]
			local pname = player:get_player_name()
			if displayed_waypoints[pname].display_active then
				local item = player:get_wielded_item()
				if item:get_name() ~= "vlf_structure_block:probtool" then
					vlf_structure_block.clear_displayed_node_probs(player)
				end
			end
		end
		cleartimer = 0
	end
end)

---
--- Registrations
---

-- [priv] schematic_override
minetest.register_privilege("schematic_override", {
	description = S("Allows you to access vlf_structure_block nodes not owned by you"),
	give_to_singleplayer = false,
})

local help_import = ""
if can_import then
	help_import = S("Importing a schematic will load a schematic from the world directory, place it in front of the schematic creator and sets probability and force-place data accordingly.").."\n"
end

function get_eye_pos(player)
	local player_pos = player:get_pos()
	local eye_height = player:get_properties().eye_height
	local eye_offset = player:get_eye_offset()
	player_pos.y = player_pos.y + eye_height
	player_pos = vector.add(player_pos, eye_offset)

	return player_pos
end

function place_in_air(itemstack, user, pointed_thing)
	local pos = get_eye_pos(user)
	local look_dir = user:get_look_dir()
	look_dir = vector.multiply(look_dir, 4)

	pos = vector.add(pos, look_dir)

	minetest.set_node(pos, {name = itemstack:get_name()})
	itemstack:take_item(1)
	return itemstack
end

-- [node] Schematic creator
minetest.register_node("vlf_structure_block:creator", {
	description = S("Schematic Creator"),
	_doc_items_longdesc = S("The schematic creator is used to save a region of the world into a schematic file (.mts)."),
	_doc_items_usagehelp = S("To get started, place the block facing directly in front of any bottom left corner of the structure you want to save. This block can only be accessed by the placer or by anyone with the “schematic_override” privilege.").."\n"..
S("To save a region, use the block, enter the size and a schematic name and hit “Export schematic”. The file will always be saved in the world directory. Note you can use this name in the /placeschem command to place the schematic again.").."\n\n"..
help_import..
S("The other features of the schematic creator are optional and are used to allow to add randomness and fine-tuning.").."\n\n"..
S("Y slices are used to remove entire slices based on chance. For each slice of the schematic region along the Y axis, you can specify that it occurs only with a certain chance. In the Y slice tab, you have to specify the Y slice height (0 = bottom) and a probability from 0 to 255 (255 is for 100%). By default, all Y slices occur always.").."\n\n"..
S("With a schematic node probability tool, you can set a probability for each node and enable them to overwrite all nodes when placed as schematic. This tool must be used prior to the file export."),
	tiles = {"vlf_structure_block_creator_top.png", "vlf_structure_block_creator_bottom.png",
			"vlf_structure_block_creator_sides.png"},
	groups = { dig_immediate = 2},
	paramtype2 = "facedir",
	is_ground_content = false,

	after_place_node = function(pos, player)
		local name = player:get_player_name()
		local meta = minetest.get_meta(pos)

		meta:set_string("owner", name)
		meta:set_string("infotext", S("Schematic Creator").."\n"..S("(owned by @1)", name))
		meta:set_string("prob_list", minetest.serialize({}))
		meta:set_string("slices", minetest.serialize({}))

		local node = minetest.get_node(pos)
		local dir  = minetest.facedir_to_dir(node.param2)

		meta:set_int("x_size", 1)
		meta:set_int("y_size", 1)
		meta:set_int("z_size", 1)

		-- Don't take item from itemstack
		return true
	end,
	can_dig = function(pos, player)
		local name = player:get_player_name()
		local meta = minetest.get_meta(pos)
		if meta:get_string("owner") == name or
				minetest.check_player_privs(player, "schematic_override") == true then
			return true
		end

		return false
	end,
	on_rightclick = function(pos, node, player)
		local meta = minetest.get_meta(pos)
		local name = player:get_player_name()
		if meta:get_string("owner") == name or
				minetest.check_player_privs(player, "schematic_override") == true then
			-- Get player attribute
			local pmeta = player:get_meta()
			local tab = pmeta:get_string("vlf_structure_block:tab")
			if not forms[tab] or not tab then
				tab = "main"
			end

			vlf_structure_block.show_formspec(pos, player, tab, true)
		end
	end,
	after_destruct = function(pos)
		vlf_structure_block.unmark(pos)
	end,

	-- No support for Minetest Game's screwdriver
	on_rotate = false,
})

minetest.register_tool("vlf_structure_block:probtool", {
	description = S("Schematic Node Probability Tool"),
	_doc_items_longdesc =
S("This is an advanced tool which only makes sense when used together with a schematic creator. It is used to finetune the way how nodes from a schematic are placed.").."\n"..
S("It allows you to set two things:").."\n"..
S("1) Set probability: Chance for any particular node to be actually placed (default: always placed)").."\n"..
S("2) Enable force placement: These nodes replace node other than air and ignore when placed in a schematic (default: off)"),
	_doc_items_usagehelp = "\n"..
S("BASIC USAGE:").."\n"..
S("Punch to configure the tool. Select a probability (0-255; 255 is for 100%) and enable or disable force placement. Now place the tool on any node to apply these values to the node. This information is preserved in the node until it is destroyed or changed by the tool again. This tool has no effect on schematic voids.").."\n"..
S("Now you can use a schematic creator to save a region as usual, the nodes will now be saved with the special node settings applied.").."\n\n"..
S("NODE HUD:").."\n"..
S("To help you remember the node values, the nodes with special values are labelled in the HUD. The first line shows probability and force placement (with “[F]”). The second line is the current distance to the node. Nodes with default settings and schematic voids are not labelled.").."\n"..
S("To disable the node HUD, unselect the tool or hit “place” while not pointing anything.").."\n\n"..
S("UPDATING THE NODE HUD:").."\n"..
S("The node HUD is not updated automatically and may be outdated. The node HUD only updates the HUD for nodes close to you whenever you place the tool or press the punch and sneak keys simultaneously. If you sneak-punch a schematic creator, then the node HUD is updated for all nodes within the schematic creator's region, even if this region is very big."),
	wield_image = "vlf_structure_block_probtool.png",
	inventory_image = "vlf_structure_block_probtool.png",
	liquids_pointable = true,
	groups = { disable_repair = 1 },
	on_use = function(itemstack, user, pointed_thing)
		local uname = user:get_player_name()
		if uname and not check_priv(uname) then
			return
		end

		local ctrl = user:get_player_control()
		-- Simple use
		if not ctrl.sneak then
			-- Open dialog to change the probability to apply to nodes
			vlf_structure_block.show_formspec(user:get_pos(), user, "probtool", true)

		-- Use + sneak
		else
			-- Display the probability and force_place values for nodes.

			-- If a schematic creator was punched, only enable display for all nodes
			-- within the creator's region.
			local use_creator_region = false
			if pointed_thing and pointed_thing.type == "node" and pointed_thing.under then
				local punchpos = pointed_thing.under
				local node = minetest.get_node(punchpos)
				if node.name == "vlf_structure_block:creator" then
					local pos1, pos2 = vlf_structure_block.size(punchpos)
					pos1, pos2 = vlf_structure_block.sort_pos(pos1, pos2)
					vlf_structure_block.display_node_probs_region(user, pos1, pos2)
					return
				end
			end

			-- Otherwise, just display the region close to the player
			vlf_structure_block.display_node_probs_region(user)
		end
	end,
	on_secondary_use = function(itemstack, user, pointed_thing)
		local uname = user:get_player_name()
		if uname and not check_priv(uname) then
			return
		end

		vlf_structure_block.clear_displayed_node_probs(user)
	end,
	-- Set note probability and force_place and enable node probability display
	on_place = function(itemstack, placer, pointed_thing)
		local pname = placer:get_player_name()
		if pname and not check_priv(pname) then
			return
		end

		-- Use pointed node's on_rightclick function first, if present
		local node = minetest.get_node(pointed_thing.under)
		if placer and not placer:get_player_control().sneak then
			if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
				return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, placer, itemstack) or itemstack
			end
		end

		-- This sets the node probability of pointed node to the
		-- currently used probability stored in the tool.
		local pos = pointed_thing.under
		local node = minetest.get_node(pos)
		-- Schematic void are ignored, they always have probability 0
		if node.name == "vlf_structure_block:void" then
			return itemstack
		end
		local nmeta = minetest.get_meta(pos)
		local imeta = itemstack:get_meta()
		local prob = tonumber(imeta:get_string("vlf_structure_block_prob"))
		local force_place = imeta:get_string("vlf_structure_block_force_place")

		if not prob or prob == 255 then
			nmeta:set_string("vlf_structure_block_prob", nil)
		else
			nmeta:set_string("vlf_structure_block_prob", prob)
		end
		if force_place == "true" then
			nmeta:set_string("vlf_structure_block_force_place", "true")
		else
			nmeta:set_string("vlf_structure_block_force_place", nil)
		end

		-- Enable node probablity display
		vlf_structure_block.display_node_probs_region(placer)

		return itemstack
	end,
})

local use_texture_alpha_void
if minetest.features.use_texture_alpha_string_modes then
	use_texture_alpha_void = "clip"
else
	use_texture_alpha_void = true
end

minetest.register_node("vlf_structure_block:void", {
	description = S("Schematic Void"),
	_doc_items_longdesc = S("This is an utility block used in the creation of schematic files. It should be used together with a schematic creator. When saving a schematic, all nodes with a schematic void will be left unchanged when the schematic is placed again. Technically, this is equivalent to a block with the node probability set to 0."),
	_doc_items_usagehelp = S("Just place the schematic void like any other block and use the schematic creator to save a portion of the world."),
	tiles = { "vlf_structure_block_void.png" },
	use_texture_alpha = use_texture_alpha_void,
	drawtype = "nodebox",
	is_ground_content = false,
	paramtype = "light",
	walkable = false,
	sunlight_propagates = true,
	node_box = {
		type = "fixed",
		fixed = {
			{ -4/16, -4/16, -4/16, 4/16, 4/16, 4/16 },
		},
	},
	groups = { dig_immediate = 3},
})

-- [entity] Visible schematic border
minetest.register_entity("vlf_structure_block:display", {
	visual = "upright_sprite",
	textures = {get_border_texture()},
	visual_size = {x=10, y=10},
	pointable = false,
	physical = false,
	static_save = false,
	glow = minetest.LIGHT_MAX,

	on_step = function(self, dtime)
		if not self.id then
			self.object:remove()
		elseif not vlf_structure_block.markers[self.id] then
			self.object:remove()
		end
	end,
	on_activate = function(self)
		self.object:set_armor_groups({immortal = 1})
	end,
})

minetest.register_lbm({
	label = "Reset schematic creator border entities",
	name = "vlf_structure_block:reset_border",
	nodenames = "vlf_structure_block:creator",
	run_at_every_load = true,
	action = function(pos, node)
		local meta = minetest.get_meta(pos)
		meta:set_string("schem_border", "false")
	end,
})

local function add_suffix(schem)
	-- Automatically add file name suffix if omitted
	local schem_full, schem_lua
	if string.sub(schem, string.len(schem)-3, string.len(schem)) == ".mts" then
		schem_full = schem
		schem_lua = string.sub(schem, 1, -5) .. ".lua"
	else
		schem_full = schem .. ".mts"
		schem_lua = schem .. ".lua"
	end
	return schem_full, schem_lua
end

-- [chatcommand] Place schematic
minetest.register_chatcommand("placeschem", {
	description = S("Place schematic at the position specified or the current player position (loaded from @1). “-c” will clear the area first", export_path_trunc),
	privs = {server = true},
	params = S("<schematic name>[.mts] [-c] [<x> <y> <z>]"),
	func = function(name, param)
		local schem, clear, p = string.match(param, "^([^ ]+) +(%-c) *(.*)$")
		if not schem then
			schem, p = string.match(param, "^([^ ]+) *(.*)$")
		end
		clear = clear == "-c"

		local ppos = minetest.get_player_by_name(name):get_pos()

		local pos
		if p and p ~= "" then
			local pp = string.split(p, " ")
			local nums = {}
			local axes = { "x", "y", "z" }
			for a=1, #axes do
				local axis = axes[a]
				local parsed
				if minetest.parse_relative_number then
					parsed = minetest.parse_relative_number(pp[a], ppos[axis])
				else
					parsed = tonumber(ppos[axis])
				end
				if not parsed then
					return false
				end
				table.insert(nums, parsed)
			end
			pos = vector.new(nums[1], nums[2], nums[3])
		else
			pos = ppos
		end

		pos = vector.round(pos)

		if not schem then
			return false, S("No schematic file specified.")
		end

		local schem_full, schem_lua = add_suffix(schem)
		local success = false
		local schem_path = import_path_full .. DIR_DELIM .. schem_full
		if minetest.read_schematic then
			-- We don't call minetest.place_schematic with the path name directly because
			-- this would trigger the caching and we wouldn't get any updates to the schematic
			-- files when we reload. minetest.read_schematic circumvents that.
			local schematic = minetest.read_schematic(schem_path, {})
			if schematic then
				if clear then
					-- Clear same size for X and Z because
					-- because schematic is randomly rotated
					local max_xz = math.max(schematic.size.x, schematic.size.z)
					local posses = {}
					for z=pos.z, pos.z+max_xz-1 do
					for y=pos.y, pos.y+schematic.size.y-1 do
					for x=pos.x, pos.x+max_xz-1 do
						table.insert(posses, {x=x,y=y,z=z})
					end
					end
					end
					minetest.bulk_set_node(posses, {name="air"})
				end
				minetest.log("action", "[vlf_structure_block] Placing schematic '"..schem.."' at: "..minetest.pos_to_string(pos))
				success = minetest.place_schematic(pos, schematic, "random", nil, false)
			end
		else
			-- Legacy support for Minetest versions that do not have minetest.read_schematic.
			-- Note: "-c" is ignored here.
			minetest.log("action", "[vlf_structure_block] Placing schematic '"..schem.."' at: "..minetest.pos_to_string(pos))
			success = minetest.place_schematic(schem_path, schematic, "random", nil, false)
		end

		if success == nil then
			return false, S("Schematic file could not be loaded!")
		else
			return true
		end
	end,
})


if can_import then
-- [chatcommand] Convert MTS schematic file to .lua file
minetest.register_chatcommand("mts2lua", {
	description = S("Convert .mts schematic file to .lua file (loaded from @1)", export_path_trunc),
	privs = {server = true},
	params = S("<schematic name>[.mts] [comments]"),
	func = function(name, param)
		local schem, comments_str = string.match(param, "^([^ ]+) *(.*)$")

		if not schem then
			return false, S("No schematic file specified.")
		end

		local comments = comments_str == "comments"

		-- Automatically add file name suffix if omitted
		local schem_full, schem_lua = add_suffix(schem)
		local schem_path = import_path_full .. DIR_DELIM .. schem_full
		local schematic = minetest.read_schematic(schem_path, {})

		if schematic then
			local str = minetest.serialize_schematic(schematic, "lua", {lua_use_comments=comments})
			local lua_path = export_path_full .. DIR_DELIM .. schem_lua
			local file = io.open(lua_path, "w")
			if file and str then
				file:write(str)
				file:flush()
				file:close()
				return true, S("Exported schematic to @1", lua_path)
			else
				return false, S("Failed!")
			end
		end
	end,
})
end

if MAKE_README then
	dofile(minetest.get_modpath("vlf_structure_block")..DIR_DELIM.."make_readme.lua")
end


