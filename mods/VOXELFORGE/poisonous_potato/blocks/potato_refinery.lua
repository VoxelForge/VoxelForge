local S = minetest.get_translator(minetest.get_modpath("poisonous_potato"))
local furnace_fire_sounds = {}

-- Formspecs for furnace active/inactive states
function voxelforge.get_furnace_formspec(fuel_percent, item_percent, is_active)
    return "size[8.8,9.2]" ..
           "background[-0.2,-0.3;9.3,10;potato_refinery_gui.png]" ..
           "image[2.4,2.35;1.15,1;lit_progress_off.png^[lowpart:"..
		(fuel_percent)..":lit_progress.png]" ..
           "image[3.35,0.65;3,0.98;burn_progress_off.png^[lowpart:"..
		(item_percent)..":burn_progress.png^[transformR270]" ..
           "list[current_name;input;2.48,1.45;1,1;]" ..
           "list[current_name;input_2;5.4,1.55;1,1;]" ..
           "list[current_name;fuel;2.48,3.45;1,1;]" ..
           "list[current_name;output;5.42,2.95;1,1;]" ..
           -- Top row for the player's inventory
           "list[current_player;main;0.15,5.25;1,1;9]" ..
           "list[current_player;main;1.11,5.25;1,1;10]" ..
           "list[current_player;main;2.06,5.25;1,1;11]" ..
           "list[current_player;main;3.01,5.25;1,1;12]" ..
           "list[current_player;main;3.96,5.25;1,1;13]" ..
           "list[current_player;main;4.91,5.25;1,1;14]" ..
           "list[current_player;main;5.86,5.25;1,1;15]" ..
           "list[current_player;main;6.81,5.25;1,1;16]" ..
           "list[current_player;main;7.76,5.25;1,1;17]" ..
           -- Second row
           "list[current_player;main;0.15,6.21;1,1;18]" ..
           "list[current_player;main;1.11,6.21;1,1;19]" ..
           "list[current_player;main;2.06,6.21;1,1;20]" ..
           "list[current_player;main;3.01,6.21;1,1;21]" ..
           "list[current_player;main;3.96,6.21;1,1;22]" ..
           "list[current_player;main;4.91,6.21;1,1;23]" ..
           "list[current_player;main;5.86,6.21;1,1;24]" ..
           "list[current_player;main;6.81,6.21;1,1;25]" ..
           "list[current_player;main;7.76,6.21;1,1;26]" ..
           -- Third row
           "list[current_player;main;0.15,7.16;1,1;27]" ..
           "list[current_player;main;1.11,7.16;1,1;28]" ..
           "list[current_player;main;2.06,7.16;1,1;29]" ..
           "list[current_player;main;3.01,7.16;1,1;30]" ..
           "list[current_player;main;3.96,7.16;1,1;31]" ..
           "list[current_player;main;4.91,7.16;1,1;32]" ..
           "list[current_player;main;5.86,7.16;1,1;33]" ..
           "list[current_player;main;6.81,7.16;1,1;34]" ..
           "list[current_player;main;7.76,7.16;1,1;35]" ..
           -- Bottom row
           "list[current_player;main;0.15,8.36;1,1;0]" ..
           "list[current_player;main;1.11,8.36;1,1;1]" ..
           "list[current_player;main;2.06,8.36;1,1;2]" ..
           "list[current_player;main;3.01,8.36;1,1;3]" ..
           "list[current_player;main;3.96,8.36;1,1;4]" ..
           "list[current_player;main;4.91,8.36;1,1;5]" ..
           "list[current_player;main;5.86,8.36;1,1;6]" ..
           "list[current_player;main;6.81,8.36;1,1;7]" ..
           "list[current_player;main;7.76,8.36;1,1;8]"
end

-- Furnace node interaction callbacks
local function can_dig(pos, player)
    local inv = minetest.get_meta(pos):get_inventory()
    return inv:is_empty("fuel") and inv:is_empty("output") and inv:is_empty("input")
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
    if minetest.is_protected(pos, player:get_player_name()) then return 0 end
    if listname == "fuel" then
        if minetest.get_craft_result({method = "fuel", width = 1, items = {stack}}).time ~= 0 then
            return stack:get_count()
        end
        return 0
    elseif listname == "input" then
        return stack:get_count()
    elseif listname == "input_2" then
		return stack:get_count()
    elseif listname == "output" then
        return 0
    end
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
    local inv = minetest.get_meta(pos):get_inventory()
    return allow_metadata_inventory_put(pos, to_list, to_index, inv:get_stack(from_list, from_index), player)
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
    if minetest.is_protected(pos, player:get_player_name()) then return 0 end
    return stack:get_count()
end

local function stop_furnace_sound(pos)
    local hash = minetest.hash_node_position(pos)
    local sound_ids = furnace_fire_sounds[hash]
    if sound_ids then
        for _, sound_id in ipairs(sound_ids) do
            minetest.sound_fade(sound_id, -1, 0)
        end
        furnace_fire_sounds[hash] = nil
    end
end

local function swap_node(pos, name)
    local node = minetest.get_node(pos)
    if node.name == name then return end
    node.name = name
    minetest.swap_node(pos, node)
end

local function furnace_node_timer(pos, elapsed)
	--
	-- Initialize metadata
	--
	local meta = minetest.get_meta(pos)
	local fuel_time = meta:get_float("fuel_time") or 0
	local input_time = meta:get_float("input_time") or 0
	local fuel_totaltime = meta:get_float("fuel_totaltime") or 0

	local inv = meta:get_inventory()
	local inputlist, input2list, fuellist
	local output_full = false

	local timer_elapsed = meta:get_int("timer_elapsed") or 0
	meta:set_int("timer_elapsed", timer_elapsed + 1)

	local cookable, cooked
	local fuel

	local update = true
	local items_smelt = 0
	while elapsed > 0 and update do
		update = false

		inputlist = inv:get_list("input")
		input2list = inv:get_list("input_2")
		fuellist = inv:get_list("fuel")

		--
		-- Cooking
		--

		-- Check if we have cookable content
		local aftercooked
		cooked, aftercooked = voxelforge.get_craft_result({method = "potato_refinery", width = 2, items = {inputlist[1], input2list[1]}})
		cookable = cooked.time ~= 0

						
			local el = math.min(elapsed, fuel_totaltime - fuel_time)
			if cookable then -- fuel lasts long enough, adjust el to cooking duration
				el = math.min(el, cooked.time - input_time)
			end

			-- Check if we have enough fuel to burn
			if fuel_time < fuel_totaltime then
				-- The furnace is currently active and has enough fuel
				fuel_time = fuel_time + el
				-- If there is a cookable item then check if it is ready yet
				if cookable then
					input_time = input_time + el
					if input_time >= cooked.time then
						-- Place result in output list if possible
						if inv:room_for_item("output", cooked.item) then
							local output_item = ItemStack(cooked.item)

							-- Add the item to the inventory first (without meta)
							inv:add_item("output", output_item)

							-- Retrieve the added ItemStack from the inventory
							output_item = inv:get_stack("output", 1)  -- Get the item that was added to the output

							-- Check if metadata exists in the recipe
							if cooked.meta then
								local meta = output_item:get_meta()

								-- Apply metadata from cooked.meta to the output item
								for key, value in pairs(cooked.meta) do
									if not cooked.meta.description then
										if type(value) == "string" then
											-- Set string metadata
											meta:set_string(key, value)
										elseif type(value) == "number" then
											-- Set integer metadata
											meta:set_int(key, value)
										elseif type(value) == "boolean" then
											-- Set boolean metadata
											meta:set_bool(key, value)
										end
									else
										local o_item = ItemStack(cooked.item)
										local registered_item = minetest.registered_items[o_item:get_name()]
										local registered_description = registered_item and registered_item.description
										local current_description-- = meta:get_string("description")
										local meta_description = meta:get_string("description")
										if not string.find(meta_description, cooked.meta.description) then
											current_description = registered_description .. "\n" .. cooked.meta.description
											meta:set_string("description", current_description)
										end
									end
								end
							end

							-- Update the inventory with the modified item (with metadata)
							inv:set_stack("output", 1, output_item)


							-- Remove one item from each input slot
							local input1 = inv:get_stack("input", 1)
							local input2 = inv:get_stack("input_2", 1)

							-- Take one item from input1 if it has at least one item
							if input1:get_count() > 0 then
								input1:take_item(1)  -- Removes 1 item from input1
								inv:set_stack("input", 1, input1)  -- Update inventory with the modified stack
							end

							-- Take one item from input2 if it has at least one item
							if input2:get_count() > 0 then
								input2:take_item(1)  -- Removes 1 item from input2
								inv:set_stack("input_2", 1, input2)  -- Update inventory with the modified stack
							end
							input_time = input_time - cooked.time
							update = true
						else
							output_full = true
						end
						items_smelt = items_smelt + 1
					else
						-- Item could not be cooked: probably missing fuel
						update = true
					end
				end
			else
				-- Furnace ran out of fuel
				if cookable then
					-- We need to get new fuel
					local afterfuel
					fuel, afterfuel = minetest.get_craft_result({method = "fuel", width = 1, items = fuellist})

					if fuel.time == 0 then
						-- No valid fuel in fuel list
						fuel_totaltime = 0
						input_time = 0
					else
						-- prevent blocking of fuel inventory (for automatization mods)
						local is_fuel = minetest.get_craft_result({method = "fuel", width = 1, items = {afterfuel.items[1]:to_string()}})
						if is_fuel.time == 0 then
							table.insert(fuel.replacements, afterfuel.items[1])
							inv:set_stack("fuel", 1, "")
						else
							-- Take fuel from fuel list
							inv:set_stack("fuel", 1, afterfuel.items[1])
						end
						-- Put replacements in output list or drop them on the furnace.
						local replacements = fuel.replacements
						if replacements[1] then
							local leftover = inv:add_item("output", replacements[1])
							if not leftover:is_empty() then
								local above = vector.new(pos.x, pos.y + 1, pos.z)
								local drop_pos = minetest.find_node_near(above, 1, {"air"}) or above
								minetest.item_drop(replacements[1], nil, drop_pos)
							end
						end
						update = true
						fuel_totaltime = fuel.time + (fuel_totaltime - fuel_time)
					end
				else
					-- We don't need to get new fuel since there is no cookable item
					fuel_totaltime = 0
					input_time = 0
				end
				fuel_time = 0
			end

			elapsed = elapsed - el
		end

		if items_smelt > 0 then
			-- Play cooling sound
			minetest.sound_play("voxelforge_cool_lava",
			{ pos = pos, max_hear_distance = 16, gain = 0.07 * math.min(items_smelt, 7) }, true)
		end
		if fuel and fuel_totaltime > fuel.time then
			fuel_totaltime = fuel.time
		end
		if inputlist and inputlist[1]:is_empty() then
			input_time = 0
		elseif input2list and input2list[1]:is_empty() then
			input_time = 0
		end

		-- Update formspec, infotext and node
		local formspec
		local item_state
		local item_percent = 0
		if cookable then
			item_percent = math.floor(input_time / cooked.time * 100)
			if output_full then
				item_state = S("100% (output full)")
			else
				item_state = S("@1%", item_percent)
			end
		else
			if inputlist and not inputlist[1]:is_empty() then
				item_state = S("Not refinable")
			else
				item_state = S("Empty")
			end
		end

		local fuel_state = S("Empty")
		local active = false
		local result = false

		if fuel_totaltime ~= 0 then
			active = true
			local fuel_percent = 100 - math.floor(fuel_time / fuel_totaltime * 100)
			fuel_state = S("@1%", fuel_percent)
			--formspec = voxelforge.get_furnace_active_formspec(fuel_percent, item_percent)
			formspec = voxelforge.get_furnace_formspec(fuel_percent, item_percent, fuel_totaltime > 0)
			swap_node(pos, "voxelforge:furnace_active")
			-- make sure timer restarts automatically
			result = true

			-- Play sound every 5 seconds while the furnace is active
			if timer_elapsed == 0 or (timer_elapsed + 1) % 5 == 0 then
				local sound_id = minetest.sound_play("voxelforge_furnace_active",
				{pos = pos, max_hear_distance = 16, gain = 0.25})
				local hash = minetest.hash_node_position(pos)
				furnace_fire_sounds[hash] = furnace_fire_sounds[hash] or {}
				table.insert(furnace_fire_sounds[hash], sound_id)
				-- Only remember the 3 last sound handles
				if #furnace_fire_sounds[hash] > 3 then
					table.remove(furnace_fire_sounds[hash], 1)
				end
				-- Remove the sound ID automatically from table after 11 seconds
				minetest.after(11, function()
				if not furnace_fire_sounds[hash] then
					return
				end
				for f=#furnace_fire_sounds[hash], 1, -1 do
					if furnace_fire_sounds[hash][f] == sound_id then
						table.remove(furnace_fire_sounds[hash], f)
					end
				end
				if #furnace_fire_sounds[hash] == 0 then
					furnace_fire_sounds[hash] = nil
				end
			end)
		end
	else
		if fuellist and not fuellist[1]:is_empty() then
			fuel_state = S("@1%", 0)
		end
		--formspec = voxelforge.get_furnace_inactive_formspec()
		formspec = voxelforge.get_furnace_formspec(0, item_percent, fuel_totaltime > 0)
		swap_node(pos, "voxelforge:furnace")
		-- stop timer on the inactive furnace
		minetest.get_node_timer(pos):stop()
		meta:set_int("timer_elapsed", 0)

		stop_furnace_sound(pos)
	end


	local infotext
	if active then
		infotext = S("Furnace active")
	else
		infotext = S("Furnace inactive")
	end
	infotext = infotext .. "\n" .. S("(Item: @1; Fuel: @2)", item_state, fuel_state)

	--
	-- Set meta values
	--
	meta:set_float("fuel_totaltime", fuel_totaltime)
	meta:set_float("fuel_time", fuel_time)
	meta:set_float("input_time", input_time)
	meta:set_string("formspec", formspec)
	meta:set_string("infotext", infotext)

	return result
end



-- Register Furnace Node
minetest.register_node(":voxelforge:furnace", {
    description = "Furnace",
    tiles = {"potato_refinery_top.png", "potato_refinery_bottom.png", "potato_refinery_side.png", "potato_refinery_side.png", "potato_refinery_side.png", "potato_refinery_front.png"},
    paramtype2 = "facedir",
    groups = {cracky = 3},
    on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size('input', 1)
		inv:set_size('input_2', 1)
		inv:set_size('fuel', 1)
		inv:set_size('output', 1)
		furnace_node_timer(pos, 0)
	end,
    can_dig = can_dig,
    allow_metadata_inventory_put = allow_metadata_inventory_put,
    allow_metadata_inventory_move = allow_metadata_inventory_move,
    allow_metadata_inventory_take = allow_metadata_inventory_take,
    on_metadata_inventory_move = function(pos)
		minetest.get_node_timer(pos):start(1.0)
	end,
	on_metadata_inventory_put = function(pos)
		-- start timer function, it will sort out whether furnace can burn or not.
		minetest.get_node_timer(pos):start(1.0)
	end,
	on_metadata_inventory_take = function(pos)
		-- check whether the furnace is empty or not.
		minetest.get_node_timer(pos):start(1.0)
	end,
    on_timer = furnace_node_timer,
})

-- Register Furnace (Active)
minetest.register_node(":voxelforge:furnace_active", {
    description = "Active Furnace",
    tiles = {
        "potato_refinery_top.png", "potato_refinery_bottom.png", "potato_refinery_side.png", "potato_refinery_side.png", "potato_refinery_side.png", {
				name = "potato_refinery_front_active.png",
				animation = { type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 48 }
			},
    },
    paramtype2 = "facedir",
    groups = {cracky = 3, not_in_creative_inventory = 1},
    drop = "voxelforge:furnace",  -- Drop the inactive furnace when broken
    on_timer = furnace_node_timer,
    can_dig = can_dig,
    allow_metadata_inventory_put = allow_metadata_inventory_put,
    allow_metadata_inventory_move = allow_metadata_inventory_move,
    allow_metadata_inventory_take = allow_metadata_inventory_take,
})

minetest.register_craftitem(":custom_mod:potato_oil", {
    description = "Potato Oil",
    inventory_image = "potato_oil.png",
})

minetest.register_craftitem(":custom_mod:poisonous_potato_oil", {
    description = "Poisonous Potato Oil",
    inventory_image = "poisonous_potato_oil.png",
})
