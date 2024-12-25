local S = minetest.get_translator(minetest.get_current_modname())

local fourdirs = {
	[0] = vector.new(0, 0, 1),
	[1] = vector.new(1, 0, 0),
	[2] = vector.new(0, 0, -1),
	[3] = vector.new(-1, 0, 0),
}

function vlf_redstone.update_comparators(pos)
	for _, dir in pairs(fourdirs) do
		local pos2 = pos:add(dir)
		local node2 = minetest.get_node(pos2)

		if dir == minetest.fourdir_to_dir(node2.param2) and node2.name:find("vlf_comparators:comparator_") then
			vlf_redstone.update_node(pos2)
		elseif vlf_redstone._solid_opaque_tab[node2.name] then
			local pos3 = pos2:add(dir)
			local node3 = minetest.get_node(pos3)
			if dir == minetest.fourdir_to_dir(node3.param2) and node3.name:find("vlf_comparators:comparator_") then
				vlf_redstone.update_node(pos3)
			end
		end
	end
end

local function get_inventory_data(pos, lists)
	if not lists or #lists == 0 then
		lists = { "main" }
	end

	local inv = minetest.get_inventory({type="node", pos=pos})

	if not inv then return 0 end

	local empty, fullness, slots = true, 0, 0

	for _, listname in pairs(lists) do
		slots = slots + inv:get_size(listname)
		if not inv:is_empty(listname) then
			empty = false
			for _, stack in pairs(inv:get_list(listname)) do
				if stack then
					fullness = fullness + stack:get_count() / stack:get_stack_max()
				end
			end
		end
	end

	return empty, fullness, slots
end

local function measure_inventory(pos, _, _, lists)
	local empty, fullness, slots = get_inventory_data(pos, lists)

	-- formula copied from wiki
	return empty and 0 or math.floor(1 + (fullness / slots) * 14)
end

--- wrap measure_inventory to measure non main invs
local function measure_complex_inventory(lists)
	return function(pos)
		return measure_inventory(pos, nil, nil, lists)
	end
end

local function measure_double_chest(side)
	return function(pos, node)
		local other_pos = vlf_util.get_double_container_neighbor_pos(pos, node.param2, side)
		local empty1, fullness1, slots1 = get_inventory_data(pos)
		local empty2, fullness2, slots2 = get_inventory_data(other_pos)
		local empty, fullness, slots = empty1 and empty2, fullness1 + fullness2, slots1 + slots2

		-- apply formula to cumulated data
		return empty and 0 or math.floor(1 + (fullness / slots) * 14), fullness, slots
	end
end

local function measure_constant(power_level)
	return function()
		return power_level
	end
end

local function measure_lectern(pos)
	local meta = minetest.get_meta(pos)
	local pages = tonumber(meta:get_string("pages")) or 1
	local page = tonumber(meta:get_string("page")) or 1
	local power = 15
	if pages > 1 then
		-- formula copied from wiki
		power = math.floor((14 * (page - 1)) / (pages - 1) + 1)
	end
	return power
end

local measure_double_chest_left = measure_double_chest("left")
local measure_double_chest_right = measure_double_chest("right")
local measure_furnace = measure_complex_inventory({"fuel", "src", "dst"})
local measure_brewing_stand = measure_complex_inventory({"fuel", "input", "stand"})

-- measurable nodes mapped to their measuring function
local measure_tab = {
	["vlf_barrels:barrel_closed"] = measure_inventory,
	["vlf_barrels:barrel_open"] = measure_inventory,
	["vlf_chests:chest_small"] = measure_inventory,
	["vlf_chests:chest_left"] = measure_double_chest_left,
	["vlf_chests:chest_right"] = measure_double_chest_right,
	["vlf_chests:trapped_chest_small"] = measure_inventory,
	["vlf_chests:trapped_chest_left"] = measure_double_chest_left,
	["vlf_chests:trapped_chest_right"] = measure_double_chest_right,
	["vlf_chests:trapped_chest_on_small"] = measure_inventory,
	["vlf_chests:trapped_chest_on_left"] = measure_double_chest_left,
	["vlf_chests:trapped_chest_on_right"] = measure_double_chest_right,
	["vlf_dispensers:dispenser"] = measure_inventory,
	["vlf_dispensers:dispenser_down"] = measure_inventory,
	["vlf_dispensers:dispenser_up"] = measure_inventory,
	["vlf_dispensers:dropper"] = measure_inventory,
	["vlf_dispensers:dropper_down"] = measure_inventory,
	["vlf_dispensers:dropper_up"] = measure_inventory,
	["vlf_hoppers:hopper"] = measure_inventory,
	["vlf_hoppers:hopper_disabled"] = measure_inventory,
	["vlf_hoppers:hopper_side"] = measure_inventory,
	["vlf_hoppers:hopper_side_disabled"] = measure_inventory,
	["vlf_furnaces:furnace"] = measure_furnace,
	["vlf_blast_furnace:blast_furnace"] = measure_furnace,
	["vlf_smoker:smoker"] = measure_furnace,
	["vlf_lectern:lectern_with_book"] = measure_lectern,
	--[[ initalized using after_mods_loaded
	["vlf_brewing:stand_xxx"] = measure_brewing_stand,
	["vlf_chests:xxx_shulker_box"] = measure_inventory,
	["vlf_cauldron:cauldron_xxx"] = measure_constant(comparator_signal),
	["vlf_cake:cake_x"] = measure_constant(comparator_signal),
	["vlf_copper:bulb_xxx"] = measure_constant(comparator_signal),
	["vlf_composters:composter_xxx"] = measure_constant(comparator_signal),
	["vlf_portals:end_portal_frame_xxx"] = measure_constant(comparator_signal),
	]]
	-- TODO:
	--["decorated_pot"] = measure_inventory,
	--["minecart_with_chest"] = measure_inventory,
	--["minecart_with_hopper"] = measure_inventory,
	--["beehive"] = measure_beehive,
	--["bees_nest"] = measure_beehive,
	--["chiseled_bookshelf"] = measure_bookshelf,
	--["command_block"] = measure_command_block,
	--["crafter"] = measure_crafter,
	--["item_frame"] = measure_item_frame,
	--["jukebox"] = measure_jukebox,
	--["respawn_anchor"] = measure_respawn_anchor,
	--["sculc_sensor"] = measure_sculc_sensor,
}

-- check if node at pos is 'interesting'
-- first result is true, iff node has an entry in measure_tab, 2nd result is
-- 1. node is measurable -> measuring function from measure_tab
-- 2. node is opaque -> true, iff node has opaque group set to non zero
-- 3rd and 4th results are node and nodedef
local function is_measurable_or_opaque(pos)
	local node = minetest.get_node_or_nil(pos)
	local def = node and minetest.registered_nodes[node.name]

	if not def then return false, false, nil, nil end

	local measuring_function = measure_tab[node.name]
	if measuring_function then
		return true, measuring_function, node, def
	end

	return false, def.groups and def.groups.opaque and (def.groups.opaque ~= 0), node, def
end

-- compute tile depending on state and mode
local function get_tiles(state, mode)
	local top = "vlf_comparators_"..state..".png^"..
		"vlf_comparators_"..mode..".png"
	local sides = "vlf_comparators_sides_"..state..".png^"..
		"vlf_comparators_sides_"..mode..".png"
	local ends = "vlf_comparators_ends_"..state..".png^"..
		"vlf_comparators_ends_"..mode..".png"
	return {
		top, "vlf_stairs_stone_slab_top.png",
		sides, sides.."^[transformFX",
		ends, ends,
	}
end

local node_boxes = {
	comp = {
		{ -8/16, -8/16, -8/16,
		   8/16, -6/16,  8/16 },	-- the main slab
		{ -1/16, -6/16,  6/16,
		   1/16, -4/16,  4/16 },	-- front torch
		{ -4/16, -6/16, -5/16,
		  -2/16, -1/16, -3/16 },	-- left back torch
		{  2/16, -6/16, -5/16,
		   4/16, -1/16, -3/16 },	-- right back torch
	},
	sub = {
		{ -8/16, -8/16, -8/16,
		   8/16, -6/16,  8/16 },	-- the main slab
		{ -1/16, -6/16,  6/16,
		   1/16, -3/16,  4/16 },	-- front torch (active)
		{ -4/16, -6/16, -5/16,
		  -2/16, -1/16, -3/16 },	-- left back torch
		{  2/16, -6/16, -5/16,
		   4/16, -1/16, -3/16 },	-- right back torch
	},
}

local collision_box = {
	type = "fixed",
	fixed = { -8/16, -8/16, -8/16, 8/16, -6/16, 8/16 },
}

local groups = {
	dig_immediate = 3,
	dig_by_water  = 1,
	destroy_by_lava_flow = 1,
	dig_by_piston = 1,
	unsticky = 1,
	attached_node = 1,
}

for _, mode in pairs{"comp", "sub"} do
	for _, state in pairs{"on", "off"} do
		local nodename = "vlf_comparators:comparator_"..state.."_"..mode

		local longdesc, usagehelp, use_help
		if state == "off" and mode == "comp" then
			longdesc = S("Redstone comparators are multi-purpose redstone components.").."\n"..
			S("They can transmit a redstone signal, detect whether a block contains any items and compare multiple signals.")

			usagehelp = S("A redstone comparator has 1 main input, 2 side inputs and 1 output. The output is in arrow direction, the main input is in the opposite direction. The other 2 sides are the side inputs.").."\n"..
				S("The main input can powered in 2 ways: First, it can be powered directly by redstone power like any other component. Second, it is powered if, and only if a container (like a chest) is placed in front of it and the container contains at least one item.").."\n"..
				S("The side inputs are only powered by normal redstone power. The redstone comparator can operate in two modes: Transmission mode and subtraction mode. It starts in transmission mode and the mode can be changed by using the block.").."\n\n"..
				S("Transmission mode:\nThe front torch is unlit and lowered. The output is powered if, and only if the main input is powered. The two side inputs are ignored.").."\n"..
				S("Subtraction mode:\nThe front torch is lit. The output is powered if, and only if the main input is powered and none of the side inputs is powered.")
		else
			use_help = false
		end

		local nodedef = {
			description = S("Redstone Comparator"),
			_doc_items_create_entry = use_help,
			_doc_items_longdesc = longdesc,
			_doc_items_usagehelp = usagehelp,
			drawtype = "nodebox",
			tiles = get_tiles(state, mode),
			use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "opaque" or false,
			walkable = true,
			selection_box = collision_box,
			collision_box = collision_box,
			node_box = {
				type = "fixed",
				fixed = node_boxes[mode],
			},
			groups = groups,
			paramtype = "light",
			paramtype2 = "4dir",
			sunlight_propagates = false,
			is_ground_content = false,
			drop = "vlf_comparators:comparator_off_comp",
			on_rightclick = function (pos, node, clicker)
				local protname = clicker:get_player_name()
				if minetest.is_protected(pos, protname) then
					minetest.record_protection_violation(pos, protname)
					return
				end
				local newmode = mode == "comp" and "sub" or "comp"
				minetest.set_node(pos, {
					name = "vlf_comparators:comparator_"..state.."_"..newmode,
					param2 = node.param2,
				})
			end,
			sounds = vlf_sounds.node_sound_stone_defaults(),
			on_rotate = screwdriver.disallow,
			_vlf_redstone = {
				connects_to = function(node, dir)
					return true
				end,
				get_power = function(node, dir)
					local fourdir = minetest.dir_to_fourdir(dir)
					if not fourdir or dir.y ~= 0 then
						return 0
					end
					return node.param2 % 4 == fourdir and math.floor(node.param2 / 4) or 0, true
				end,
				update = function(pos, node)
					-- TODO: should not accept side power from opaque blocks
					local back = -minetest.fourdir_to_dir(node.param2)
					local left = minetest.fourdir_to_dir((node.param2 - 1) % 4)
					local right = minetest.fourdir_to_dir((node.param2 + 1) % 4)
					local side_power = math.max(
						vlf_redstone.get_power(pos, left),
						vlf_redstone.get_power(pos, right)
					)
					local pos2 = vector.add(pos, back)
					local rear_power
					local is_measurable, o, node2, def2 = is_measurable_or_opaque(pos2)
					if is_measurable then
						-- o is measuring function
						rear_power = math.max(0, math.min (15, o(pos2, node2, def2)))
					elseif o then
						-- opaque
						local pos3 = vector.add(pos2, back)
						local is_measurable, o, node3, def3 = is_measurable_or_opaque(pos3)
						if is_measurable then
							rear_power = math.max(0, math.min (15, o(pos3, node3, def3)))
						else
							-- no measurable node in back direction
							-- try to get power normally
							rear_power = vlf_redstone.get_power(pos, back)
						end
					else
						rear_power = vlf_redstone.get_power(pos, back)
					end
					local output
					if mode == "comp" then
						output = rear_power >= side_power and rear_power or 0
					else
						output = math.max(rear_power - side_power, 0)
					end

					local newstate = output > 0 and "on" or "off"
					return {
						name = "vlf_comparators:comparator_"..newstate.."_"..mode,
						param2 = 4 * output + node.param2 % 4,
					}
				end,
			},
		}

		if mode == "comp" and state == "off" then
			nodedef._doc_items_create_entry = true
			nodedef.inventory_image = "vlf_comparators_item.png"
			nodedef.wield_image = "vlf_comparators_item.png"
		else
			nodedef.groups = table.copy(nodedef.groups)
			nodedef.groups.not_in_creative_inventory = 1
			if mode == "sub" or state == "on" then
				nodedef.inventory_image = nil
			end
			local desc = nodedef.description
			if mode ~= "sub" and state == "on" then
				desc = S("Redstone Comparator (Powered)")
			elseif mode == "sub" and state ~= "on" then
				desc = S("Redstone Comparator (Subtract)")
			elseif mode == "sub" and state == "on" then
				desc = S("Redstone Comparator (Subtract, Powered)")
			end
			nodedef.description = desc

			doc.add_entry_alias("nodes", "vlf_comparators:comparator_"..state.."_"..mode, "nodes", nodename)
		end

		minetest.register_node(nodename, nodedef)
	end
end

minetest.register_craft({
	output = "vlf_comparators:comparator_off_comp",
	recipe = {
		{ "",      "vlf_redstone_torch:redstone_torch_on", ""      },
		{ "vlf_redstone_torch:redstone_torch_on", "vlf_nether:quartz",  "vlf_redstone_torch:redstone_torch_on" },
		{ "vlf_core:stone",   "vlf_core:stone",   "vlf_core:stone"   },
	}
})

minetest.register_on_dignode(function (pos, node)
	if node and measure_tab[node.name] then
		vlf_redstone.update_comparators(pos)
	end
	-- double chest support
	local other_pos
	local container_type = minetest.get_item_group(node.name, "container")
	if container_type == 5 then
		other_pos = vlf_util.get_double_container_neighbor_pos(pos, node.param2, "left")
	elseif container_type == 6 then
		other_pos = vlf_util.get_double_container_neighbor_pos(pos, node.param2, "right")
	end
	if other_pos then
		--minetest.after(0.5, function ()
			vlf_redstone.update_comparators(other_pos)
		--end)
	end
end)

minetest.register_on_placenode(function (pos, newnode, _, oldnode)
	if (newnode and measure_tab[newnode.name]) or (oldnode and measure_tab[oldnode.name]) then
		vlf_redstone.update_comparators(pos)
	end
end)

minetest.register_on_mods_loaded(function()
	for name, def in pairs(minetest.registered_nodes) do
		if minetest.get_item_group(name, "shulker_box") ~= 0 then
			measure_tab[name] = measure_inventory
		elseif minetest.get_item_group(name, "brewing_stand") ~= 0 then
			measure_tab[name] = measure_brewing_stand
		elseif def.groups and def.groups.comparator_signal then
			measure_tab[name] = measure_constant(def.groups.comparator_signal)
		end
	end

	local measureable_nodes = {}
	for name, _ in pairs(measure_tab) do
		table.insert(measureable_nodes, name)
	end
	vlf_redstone.register_action(vlf_redstone.update_comparators, measureable_nodes)
end)
