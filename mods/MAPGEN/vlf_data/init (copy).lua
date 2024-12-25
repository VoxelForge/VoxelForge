local modpath = minetest.get_modpath("vlf_data")
--dofile(modpath .. "/export.lua")
--dofile(modpath .. "/pgs.lua")
local binser = dofile(modpath .. "/binser.lua")
voxelforge = {}

minetest.register_alias("vlf_trial_chambers:temp_glass", "voxelforge:temp_glass")
minetest.register_alias("vlf_trial_chambers:jigsaw_block", "voxelforge:jigsaw")
minetest.register_alias("vlf_copper:waxed_oxidized_cut_copper_stairs", "vlf_stairs:stair_waxed_copper_oxidized_cut")
minetest.register_alias("minecraft:air", "air")
minetest.register_alias("minecraft:tuff_bricks", "vlf_deepslate:tuff_bricks")
minetest.register_alias("minecraft:waxed_oxidized_copper", "vlf_copper:waxed_oxidized_copper")
minetest.register_alias("minecraft:waxed_oxidized_cut_copper", "vlf_copper:waxed_oxidized_cut_copper")
minetest.register_alias("minecraft:waxed_copper_block", "vlf_copper:waxed_copper")
minetest.register_alias("minecraft:chiseled_tuff", "vlf_deepslate:tuff_chiseled")
minetest.register_alias("minecraft:waxed_copper_bulb", "vlf_copper:waxed_copper_bulb_lit")
minetest.register_alias("minecraft:chiseled_tuff_bricks", "vlf_deepslate:tuff_bricks_chiseled")
minetest.register_alias("minecraft:polished_tuff", "vlf_deepslate:tuff_polished")
minetest.register_alias("minecraft:trial_spawner", "vlf_mobspawners:spawner")
minetest.register_alias("minecraft:pointed_dripstone", "air")


local function convert_vlfschem_to_binary(directory)
    local function process_directory(dir)
        -- Get the list of files and subdirectories in the current directory
        local files = minetest.get_dir_list(dir, false)
        local subdirs = minetest.get_dir_list(dir, true)

        -- Process files in the current directory
        for _, file in ipairs(files) do
            local filepath = dir .. "/" .. file
            if filepath:sub(-18) == ".vlfschem.vlfschem" then
            --if filepath:sub(-9) == ".vlfschem" then
            	--local output_file_path = filepath .. ""
                local output_file_path = filepath:gsub(".vlfschem.vlfschem", ".vlfschem") .. ""
                minetest.log("action", "Converting file to binary: " .. filepath .. " -> " .. output_file_path)

                -- Attempt to open the input file in text mode
                local input_file = io.open(filepath, "r")
                if not input_file then
                    minetest.log("error", "Cannot open input file: " .. filepath)
                    return false
                end

                -- Read the input file content
                local content = input_file:read("*a")
                input_file:close()

                -- Attempt to deserialize the content into a Lua table
                local func, err = loadstring(content)
                if not func then
                    minetest.log("error", "Error loading input file: " .. err)
                    return false
                end

                local success, data = pcall(func)
                if not success then
                    minetest.log("error", "Error executing input file: " .. data)
                    return false
                end

                -- Serialize the Lua table into binary format
                local binary_data = binser.serialize(data)

                -- Attempt to open the output file in binary mode
                local output_file = io.open(output_file_path, "wb")
                if not output_file then
                    minetest.log("error", "Cannot open output file: " .. output_file_path)
                    return false
                end

                -- Write the binary data to the output file
                output_file:write(binary_data)
                output_file:close()

                minetest.log("action", "File successfully converted to binary: " .. output_file_path)
            end
        end

        -- Recursively process subdirectories
        for _, subdir in ipairs(subdirs) do
            process_directory(dir .. "/" .. subdir)
        end
    end

    -- Start processing from the specified directory
    process_directory(directory)
end

convert_vlfschem_to_binary(modpath.."/data/voxelforge/structure/trial_chambers")

-- Register the glass-like node
minetest.register_node(":voxelforge:temp_glass", {
	description = "Temporary Glass",
	drawtype = "glasslike",
	tiles = {"default_glass.png"},
	groups = {cracky = 3, oddly_breakable_by_hand = 3, not_in_creative_inventory = 1},
	drop = "",
	sunlight_propagates = true,
	paramtype = "light",
})

-- Helper function to place temporary glass-like nodes
local function place_temp_glass(pos, size, offset)
	local start_pos = vector.add(pos, offset)
	local end_pos = vector.add(start_pos, {x = size.x - 1, y = size.y - 1, z = size.z - 1})

	for x = start_pos.x, end_pos.x do
		for y = start_pos.y, end_pos.y do
			for z = start_pos.z, end_pos.z do
				if x == start_pos.x or x == end_pos.x or y == start_pos.y or y == end_pos.y or z == start_pos.z or z == end_pos.z then
					local node_pos = {x = x, y = y, z = z}
					if minetest.get_node(node_pos).name == "air" then
						minetest.set_node(node_pos, {name = "voxelforge:temp_glass"})
					end
				end
			end
		end
	end
end

-- Add a function to remove temporary glass-like nodes
local function remove_temp_glass(pos, size, offset)
	local start_pos = vector.add(pos, offset)
	local end_pos = vector.add(start_pos, {x = size.x - 1, y = size.y - 1, z = size.z - 1})

	for x = start_pos.x, end_pos.x do
		for y = start_pos.y, end_pos.y do
			for z = start_pos.z, end_pos.z do
				local node_pos = {x = x, y = y, z = z}
				if minetest.get_node(node_pos).name == "voxelforge:temp_glass" then
					minetest.set_node(node_pos, {name = "air"})
				end
			end
		end
	end
end

-- Register the schematic editor node
minetest.register_node(":voxelforge:schematic_editor", {
	description = "Schematic Editor",
	tiles = {"schematic_editor.png"},
	groups = {cracky = 3, oddly_breakable_by_hand = 3},

	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos)
		meta:set_string("owner", player:get_player_name()) -- Store the player name who opened the node
		local sx = meta:get_int("sx")
		local sy = meta:get_int("sy")
		local sz = meta:get_int("sz")
		local ox = meta:get_int("ox")
		local oy = meta:get_int("oy")
		local oz = meta:get_int("oz")
		local filename = meta:get_string("filename") or "schematic"
		local save_entities = meta:get_string("save_entities") == "true"
		local formspec = "size[8,8]" ..
			"field[0.5,1;2,1;sx;Size X;" .. sx .. "]" ..
			"field[2.5,1;2,1;sy;Size Y;" .. sy .. "]" ..
			"field[4.5,1;2,1;sz;Size Z;" .. sz .. "]" ..
			"field[0.5,3;2,1;ox;Offset X;" .. ox .. "]" ..
			"field[2.5,3;2,1;oy;Offset Y;" .. oy .. "]" ..
			"field[4.5,3;2,1;oz;Offset Z;" .. oz .. "]" ..
			"field[0.5,5;4,1;filename;Filename (without extension);" .. filename .. "]" ..
			"checkbox[6,3;save_entities;Save Entities;" .. (save_entities and "true" or "false") .. "]" ..
			"button[6,5;2,1;save_config;Save Configurations]" ..
			"button[6,6;2,1;export;Export Schematic]" ..
			"button[6,7;2,1;detect_size;Auto Detect Size/Offset]" ..
			"button[6,8;2,1;remove_temp_glass;Remove Temporary Glass]"
			minetest.show_formspec(player:get_player_name(), "voxelforge:schematic_editor", formspec)
	end,
})

-- Export schematic function
local function export_schematic(player, pos, size, offset, filename, save_entities)
    local start_pos = vector.add(pos, offset)
    local end_pos = vector.add(start_pos, {x = size.x - 1, y = size.y - 1, z = size.z - 1})
    local min_x, min_y, min_z = end_pos.x, end_pos.y, end_pos.z
    local max_x, max_y, max_z = start_pos.x, start_pos.y, start_pos.z

    local worldpath = minetest.get_worldpath()
    local file_path = worldpath .. "/" .. filename .. ".vlfschem"
    local file = io.open(file_path, "w")
    if not file then
        minetest.chat_send_player(player:get_player_name(), "Failed to export schematic.")
        return
    end

    file:write("return {\n")
    file:write("    size = {x = " .. size.x .. ", y = " .. size.y .. ", z = " .. size.z .. "},\n")

    -- Serialize and write nodes in batches with metadata first
    file:write("    nodes = {\n")
    for x = start_pos.x, end_pos.x do
        for y = start_pos.y, end_pos.y do
            for z = start_pos.z, end_pos.z do
                local node_pos = {x = x, y = y, z = z}
                local node = minetest.get_node(node_pos)
                if node.name ~= "voxelforge:temp_glass" and node.name ~= "voxelforge:schematic_editor" then
                    local meta = minetest.get_meta(node_pos):to_table().fields
                    local meta_str = minetest.serialize(meta):gsub("^return ", "")
                    local node_data = string.format(
                        "        {metadata = %s, name = %q, pos = {x = %d, y = %d, z = %d}, param2 = %d},\n",
                        meta_str, node.name, x - start_pos.x, y - start_pos.y, z - start_pos.z,
                        node.param2
                    )
                    file:write(node_data)

                    -- Update the bounds of the schematic
                    min_x = math.min(min_x, x)
                    min_y = math.min(min_y, y)
                    min_z = math.min(min_z, z)
                    max_x = math.max(max_x, x)
                    max_y = math.max(max_y, y)
                    max_z = math.max(max_z, z)
                end
            end
        end
    end
    file:write("    },\n")

    -- Calculate the actual size of the schematic excluding temp_glass and schematic_editor nodes
    local actual_size = {
        x = max_x - min_x + 1,
        y = max_y - min_y + 1,
        z = max_z - min_z + 1
    }

    -- Serialize and write entities if required
    if save_entities then
        file:write("    entities = {\n")
        local objects = minetest.get_objects_inside_radius(vector.add(start_pos, vector.divide(actual_size, 2)), math.max(actual_size.x, actual_size.y, actual_size.z) / 2)
        for _, obj in ipairs(objects) do
            if not obj:is_player() then
                local luaentity = obj:get_luaentity()
                if luaentity then
                    local entity_data = string.format(
                        "        {name = %q, pos = {x = %d, y = %d, z = %d}, properties = %s},\n",
                        luaentity.name, obj:get_pos().x - start_pos.x, obj:get_pos().y - start_pos.y, obj:get_pos().z - start_pos.z,
                        minetest.serialize(luaentity)
                    )
                    file:write(entity_data)
                end
            end
        end
        file:write("    },\n")
    else
        file:write("    entities = {},\n")
    end

    file:write("    probability = 1\n")
    file:write("}\n")
    file:close()

    minetest.chat_send_player(player:get_player_name(), "Schematic exported to " .. file_path)
end
-- Handle formspec input
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname == "voxelforge:schematic_editor" then
        -- Get position of the node from player's view
        local node_pos = minetest.get_player_by_name(player:get_player_name()):get_pos()
        node_pos = vector.floor(node_pos)

        -- Find all nodes of schematic editor in the area
        local nodes = minetest.find_nodes_in_area(vector.subtract(node_pos, 10), vector.add(node_pos, 10), "voxelforge:schematic_editor")
        local pos = nodes[1]  -- Assume we only handle one node

        if not pos then
            minetest.chat_send_player(player:get_player_name(), "No schematic editor node found.")
            return
        end

        -- Retrieve node meta
        local meta = minetest.get_meta(pos)

        -- Extract and save fields
        local sx = tonumber(fields.sx) or meta:get_int("sx")
        local sy = tonumber(fields.sy) or meta:get_int("sy")
        local sz = tonumber(fields.sz) or meta:get_int("sz")
        local ox = tonumber(fields.ox) or meta:get_int("ox")
        local oy = tonumber(fields.oy) or meta:get_int("oy")
        local oz = tonumber(fields.oz) or meta:get_int("oz")
        local filename = fields.filename or meta:get_string("filename") or "schematic"
        local save_entities = fields.save_entities == "true"

        -- Save settings to node meta
        meta:set_int("sx", sx)
        meta:set_int("sy", sy)
        meta:set_int("sz", sz)
        meta:set_int("ox", ox)
        meta:set_int("oy", oy)
        meta:set_int("oz", oz)
        meta:set_string("filename", filename)
        meta:set_string("save_entities", tostring(save_entities))

        if fields.save_config then
            minetest.chat_send_player(player:get_player_name(), "Configurations saved!")

            -- Place temporary glass-like nodes
            place_temp_glass(pos, {x = sx, y = sy, z = sz}, {x = ox, y = oy, z = oz})
        elseif fields.export then
            minetest.chat_send_player(player:get_player_name(), "Exporting schematic...")

            -- Export the schematic
            export_schematic(player, pos, {x = sx, y = sy, z = sz}, {x = ox, y = oy, z = oz}, filename, save_entities)
        elseif fields.remove_temp_glass then
            minetest.chat_send_player(player:get_player_name(), "Removing temporary glass...")

            -- Remove temporary glass-like nodes
            remove_temp_glass(pos, {x = sx, y = sy, z = sz}, {x = ox, y = oy, z = oz})
        end
    end
end)

local function process_copper_bulb(pos, node)
    local pos_hash = minetest.hash_node_position(pos)
    local blockseed = minetest.get_mapgen_setting("seed")

    -- Modify seed calculation for better randomness
    local seed = pos_hash + blockseed + minetest.hash_node_position({x = pos.x * 7, y = pos.y * 11, z = pos.z * 13})
    local rand = PcgRandom(seed)

    -- Generate a random float between 0.0 and 1.0
    local rand_value = rand:next(0, 2^31 - 1) / (2^31 - 1)
    
    local result_node = nil
    if node.name == "vlf_copper:waxed_copper_bulb_lit" then
        if rand_value <= 0.1 then
            result_node = {
                name = "vlf_copper:waxed_oxidized_copper_bulb_lit",
            }
        elseif rand_value <= 0.33333334 then
            result_node = {
                name = "vlf_copper:waxed_weathered_copper_bulb_lit",
            }
        elseif rand_value <= 0.5 then
            result_node = {
                name = "vlf_copper:waxed_exposed_copper_bulb_lit",
            }
        end
    end

    return result_node
end

local function load_vlfschem(file_name)
    if not file_name then
        minetest.log("error", "File name is nil.")
        return nil
    end
	-- If you're manually placing schematics in the world to modify them using the place_all_schematics_in_directory function the do --[[modpath .. "/" ..]in the line below.
    local file_path = modpath .. "/" .. file_name
    minetest.log("action", "Loading schematic from file: " .. file_path)

    -- Attempt to open the file in binary mode
    local file = io.open(file_path, "rb")
    if not file then
        minetest.log("error", "Cannot open file: " .. file_path)
        return nil
    end

    -- Read the binary file content
    local content = file:read("*a")
    file:close()

    -- Attempt to deserialize the binary content using binser
    local success, schematic_data = pcall(function() return binser.deserialize(content) end)
    if not success then
        minetest.log("error", "Error deserializing .vlfschem file: " .. schematic_data)
        return nil
    end

    -- Ensure the schematic data is a table
    if type(schematic_data) ~= "table" then
        minetest.log("error", "Schematic data is not a table in file: " .. file_name)
        return nil
    end

    -- Log the type and content of the schematic data
    minetest.log("action", "Schematic data type: " .. type(schematic_data[1])) -- schematic_data[1] is the first element if multiple items returned

    -- Check the structure of the schematic data
    if type(schematic_data[1].nodes) ~= "table" then
        minetest.log("error", "Invalid schematic data format in file: " .. file_name)
        return nil
    end

    return schematic_data[1] -- return the first item in case of multiple items
end

-- Function to check if a table contains a value
local function table_contains(tbl, value)
    for _, v in ipairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

local function set_metadata(metadata)
    if not metadata then
        return
    end

    local start_time = minetest.get_us_time()  -- Start timing

    -- Ensure the metadata is in the correct format
    local formatted_metadata = {}
    for pos, meta in pairs(metadata) do
        local meta_node_pos = vector.new(pos)
        formatted_metadata[meta_node_pos] = meta
    end

    -- Set metadata for each node position
    for pos, meta in pairs(formatted_metadata) do
        local node_meta = minetest.get_meta(pos)
        for key, value in pairs(meta) do
            node_meta:set_string(key, value)
        end
    end

    local end_time = minetest.get_us_time()  -- End timing
    local elapsed_time = (end_time - start_time) / 1000000  -- Convert microseconds to seconds
    minetest.log("action", string.format("Metadata setting finished in %.4f seconds.", elapsed_time))
end

-- Rotation function for positions
local function rotate_position(pos, rotation)
    local x, z = pos.x, pos.z
    if rotation == 270 then
        return {x = -z, y = pos.y, z = x}
    elseif rotation == 180 then
        return {x = -x, y = pos.y, z = -z}
    elseif rotation == 90 then
        return {x = z, y = pos.y, z = -x}
    else
        return pos
    end
end

--[[ Tables for directions and up orientations
local direction_table = {0, 1, 2, 3}       -- North, East, South, West
local up_orientation_table = {6, 15, 8, 17} -- Up North, Up East, Up South, Up West
local down_orientation_table = {4, 13, 10, 19}
local table2 = {4, 13, 10, 19}

-- Function to rotate param2 based on its table and rotation angle
local function rotate_param2(param2, rotation, is_up_orientation)
    local table_to_use = is_up_orientation and up_orientation_table or direction_table or down_orientation_table
    
    -- Normalize the rotation to one of the defined values (0, 90, 180, 270)
    local normalized_rotation = (rotation % 360)
    if normalized_rotation < 0 then
        normalized_rotation = normalized_rotation + 360
    end
    
    -- Determine the current index in the table
    local index = nil
    for i, val in ipairs(table_to_use) do
        if param2 == val then
            index = i
            break
        end
    end

    if not index then
        --error("Invalid param2 value: " .. tostring(param2))
        index = 0
    end

    -- Calculate the new index based on rotation
    local new_index = (index - 1 + (normalized_rotation / 90)) % 4 + 1
    local rotated_param2 = table_to_use[new_index]

    return rotated_param2
end

local function place_schematic(pos, file_name, rotation)
    local start_time = minetest.get_us_time()  -- Start timing

    local pos_hash = minetest.hash_node_position(pos)
    local blockseed = minetest.get_mapgen_setting("seed")
    local seed = pos_hash + blockseed
    local rng = PcgRandom(seed)
    local schematic = load_vlfschem(file_name)
    if not schematic then
        minetest.log("error", "Failed to load schematic data.")
        return
    end
    -- Set default rotation if not provided
    rotation = rotation or 0

    -- Calculate the bounding box of the schematic
    --local bounding_box = calculate_bounding_box(file_name, pos)
    --minetest.log("action", "Schematic bounding box: min=" .. minetest.pos_to_string(bounding_box.min_pos) .. ", max=" .. minetest.pos_to_string(bounding_box.max_pos))

    local nodes_by_type = {}
    local metadata = {}
    local rotated_param2

    -- Process nodes
    for _, node in ipairs(schematic.nodes) do
        -- Rotate node position and param2
        local rotated_pos = rotate_position(node.pos, rotation)
        local node_pos = vector.add(pos, rotated_pos)
        
        -- Determine if param2 belongs to the up orientation table
        local is_down_orientation = (node.param2 and (node.param2 == 4 or node.param2 == 13 or node.param2 == 10 or node.param2 == 19))
        local is_up_orientation = (node.param2 and (node.param2 == 6 or node.param2 == 15 or node.param2 == 8 or node.param2 == 17))
        local table = (node.param2 and (node.param2 == 0 or node.param2 == 1 or node.param2 == 2 or node.param2 == 3))
        if node.name ~= "voxelforge:jigsaw" then
        rotated_param2 = rotate_param2(node.param2 or 0, rotation, table)
        elseif table2 == 4 or table2 == 13 or table2 == 10 or table2 == 19 then
        	rotated_param2 = rotate_param2(node.param2 or 0, rotation, is_down_orientation)
        else
        rotated_param2 = rotate_param2(node.param2 or 0, rotation, is_up_orientation)
        end

        -- Process copper bulbs separately
        if node.name == "vlf_copper:waxed_copper_bulb_lit" then
            local processed_node = process_copper_bulb(node_pos, node)
            local node_name = processed_node and processed_node.name or node.name
            local node_param2 = processed_node and (rotated_param2 or 0) or rotated_param2

            -- Set copper bulb nodes individually
            minetest.set_node(node_pos, {name = node_name, param2 = node_param2})
        else
            -- Collect other nodes for bulk processing
            local node_key = node.name .. "_" .. rotated_param2

            if not nodes_by_type[node_key] then
                nodes_by_type[node_key] = {positions = {}, name = node.name, param2 = rotated_param2}
            end

            table.insert(nodes_by_type[node_key].positions, node_pos)

            -- Collect metadata if it exists
            if node.metadata and next(node.metadata) then
                metadata[node_pos] = node.metadata
            end
        end
    end

    -- Place other nodes in batches
    for _, node_group in pairs(nodes_by_type) do
        local positions = node_group.positions
        local total_positions = #positions
        local max_nodes_per_batch = 10000

        for i = 1, total_positions, max_nodes_per_batch do
            local end_index = math.min(i + max_nodes_per_batch - 1, total_positions)
            local batch_positions = {}
            for j = i, end_index do
                table.insert(batch_positions, positions[j])
            end

            minetest.bulk_set_node(batch_positions, {name = node_group.name, param2 = node_group.param2})
        end
    end

    -- Set metadata
    if next(metadata) then
        set_metadata(metadata)
    end

    local end_time = minetest.get_us_time()  -- End timing
    local elapsed_time = (end_time - start_time) / 1000000  -- Convert microseconds to seconds
    minetest.log("action", string.format("Schematic placed in %.4f seconds.", elapsed_time))
end]]

--[[ Tables for directions, up, and down orientations
local direction_table = {0, 1, 2, 3}       -- North, East, South, West
local up_orientation_table = {6, 15, 8, 17} -- Up North, Up East, Up South, Up West
local down_orientation_table = {4, 13, 10, 19} -- Down North, Down East, Down South, Down West

-- Function to rotate param2 based on its table and rotation angle
local function rotate_param2(param2, rotation)
    local table_to_use

    if param2 == 6 or param2 == 15 or param2 == 8 or param2 == 17 then
        table_to_use = up_orientation_table
    elseif param2 == 4 or param2 == 13 or param2 == 10 or param2 == 19 then
        table_to_use = down_orientation_table
    else
        table_to_use = direction_table
    end

    -- Normalize the rotation to one of the defined values (0, 90, 180, 270)
    local normalized_rotation = (rotation % 360)
    if normalized_rotation < 0 then
        normalized_rotation = normalized_rotation + 360
    end
    
    -- Determine the current index in the table
    local index = nil
    for i, val in ipairs(table_to_use) do
        if param2 == val then
            index = i
            break
        end
    end

    if not index then
        index = 0
    end

    -- Calculate the new index based on rotation
    local new_index = (index - 1 + (normalized_rotation / 90)) % 4 + 1
    local rotated_param2 = table_to_use[new_index]

    return rotated_param2
end

local function place_schematic(pos, file_name, rotation)
    local start_time = minetest.get_us_time()  -- Start timing

    local pos_hash = minetest.hash_node_position(pos)
    local blockseed = minetest.get_mapgen_setting("seed")
    local seed = pos_hash + blockseed
    local rng = PcgRandom(seed)
    local schematic = load_vlfschem(file_name)
    if not schematic then
        minetest.log("error", "Failed to load schematic data.")
        return
    end
    -- Set default rotation if not provided
    rotation = rotation or 0

    local nodes_by_type = {}
    local metadata = {}
    local rotated_param2

    -- Process nodes
    for _, node in ipairs(schematic.nodes) do
        -- Rotate node position and param2
        local rotated_pos = rotate_position(node.pos, rotation)
        local node_pos = vector.add(pos, rotated_pos)
        
        rotated_param2 = rotate_param2(node.param2 or 0, rotation)

        -- Process copper bulbs separately
        if node.name == "vlf_copper:waxed_copper_bulb_lit" then
            local processed_node = process_copper_bulb(node_pos, node)
            local node_name = processed_node and processed_node.name or node.name
            local node_param2 = processed_node and (rotated_param2 or 0) or rotated_param2

            -- Set copper bulb nodes individually
            minetest.set_node(node_pos, {name = node_name, param2 = node_param2})
        else
            -- Collect other nodes for bulk processing
            local node_key = node.name .. "_" .. rotated_param2

            if not nodes_by_type[node_key] then
                nodes_by_type[node_key] = {positions = {}, name = node.name, param2 = rotated_param2}
            end

            table.insert(nodes_by_type[node_key].positions, node_pos)

            -- Collect metadata if it exists
            if node.metadata and next(node.metadata) then
                metadata[node_pos] = node.metadata
            end
        end
    end

    -- Place other nodes in batches
    for _, node_group in pairs(nodes_by_type) do
        local positions = node_group.positions
        local total_positions = #positions
        local max_nodes_per_batch = 10000

        for i = 1, total_positions, max_nodes_per_batch do
            local end_index = math.min(i + max_nodes_per_batch - 1, total_positions)
            local batch_positions = {}
            for j = i, end_index do
                table.insert(batch_positions, positions[j])
            end

            minetest.bulk_set_node(batch_positions, {name = node_group.name, param2 = node_group.param2})
        end
    end

    -- Set metadata
    if next(metadata) then
        set_metadata(metadata)
    end

    local end_time = minetest.get_us_time()  -- End timing
    local elapsed_time = (end_time - start_time) / 1000000  -- Convert microseconds to seconds
    minetest.log("action", string.format("Schematic placed in %.4f seconds.", elapsed_time))
end

-- Function to rotate a position
local function rotate_position(pos, angle)
    local x, y, z = pos.x, pos.y, pos.z
    if angle == 90 then
        return vector.new(-z, y, x)
    elseif angle == 180 then
        return vector.new(-x, y, -z)
    elseif angle == 270 then
        return vector.new(z, y, -x)
    else
        return pos
    end
end]]

-- Tables for directions, up, and down orientations
local direction_table = {0, 1, 2, 3}        -- North, East, South, West
local up_orientation_table = {6, 15, 8, 17} -- Up North, Up East, Up South, Up West
local down_orientation_table = {4, 13, 10, 19} -- Down North, Down East, Down South, Down West

-- Function to rotate param2 based on its table and rotation angle
local function rotate_param2(param2, rotation)
    local table_to_use

    if param2 == 6 or param2 == 15 or param2 == 8 or param2 == 17 then
        table_to_use = up_orientation_table
    elseif param2 == 4 or param2 == 13 or param2 == 10 or param2 == 19 then
        table_to_use = down_orientation_table
    else
        table_to_use = direction_table
    end

    -- Normalize the rotation to one of the defined values (0, 90, 180, 270)
    local normalized_rotation = (rotation % 360)
    if normalized_rotation < 0 then
        normalized_rotation = normalized_rotation + 360
    end
    
    -- Determine the current index in the table
    local index = nil
    for i, val in ipairs(table_to_use) do
        if param2 == val then
            index = i
            break
        end
    end

    if not index then
        return param2 -- Return the original param2 if no match found
    end

    -- Calculate the new index based on rotation
    local new_index = (index - 1 + (normalized_rotation / 90)) % 4 + 1
    local rotated_param2 = table_to_use[new_index]

    return rotated_param2
end

local function place_schematic(pos, file_name, rotation)
    local start_time = minetest.get_us_time()  -- Start timing

    local pos_hash = minetest.hash_node_position(pos)
    local blockseed = minetest.get_mapgen_setting("seed")
    local seed = pos_hash + blockseed
    local rng = PcgRandom(seed)
    local schematic = load_vlfschem(file_name)
    if not schematic then
        minetest.log("error", "Failed to load schematic data.")
        return
    end
    -- Set default rotation if not provided
    rotation = rotation or 0

    local nodes_by_type = {}
    local metadata = {}
    local rotated_param2

    -- Process nodes
    for _, node in ipairs(schematic.nodes) do
        -- Rotate node position and param2
        local rotated_pos = rotate_position(node.pos, rotation)
        local node_pos = vector.add(pos, rotated_pos)

        -- Rotate param2 based on the node's orientation
        rotated_param2 = rotate_param2(node.param2 or 0, rotation)

        -- Process copper bulbs separately
        if node.name == "vlf_copper:waxed_copper_bulb_lit" then
            local processed_node = process_copper_bulb(node_pos, node)
            local node_name = processed_node and processed_node.name or node.name
            local node_param2 = processed_node and (rotated_param2 or 0) or rotated_param2

            -- Set copper bulb nodes individually
            minetest.set_node(node_pos, {name = node_name, param2 = node_param2})
        else
            -- Collect other nodes for bulk processing
            local node_key = node.name .. "_" .. rotated_param2

            if not nodes_by_type[node_key] then
                nodes_by_type[node_key] = {positions = {}, name = node.name, param2 = rotated_param2}
            end

            table.insert(nodes_by_type[node_key].positions, node_pos)

            -- Collect metadata if it exists
            if node.metadata and next(node.metadata) then
                metadata[node_pos] = node.metadata
            end
        end
    end

    -- Place other nodes in batches
    for _, node_group in pairs(nodes_by_type) do
        local positions = node_group.positions
        local total_positions = #positions
        local max_nodes_per_batch = 10000

        for i = 1, total_positions, max_nodes_per_batch do
            local end_index = math.min(i + max_nodes_per_batch - 1, total_positions)
            local batch_positions = {}
            for j = i, end_index do
                table.insert(batch_positions, positions[j])
            end

            minetest.bulk_set_node(batch_positions, {name = node_group.name, param2 = node_group.param2})
        end
    end

    -- Set metadata
    if next(metadata) then
        set_metadata(metadata)
    end

    local end_time = minetest.get_us_time()  -- End timing
    local elapsed_time = (end_time - start_time) / 1000000  -- Convert microseconds to seconds
    minetest.log("action", string.format("Schematic placed in %.4f seconds.", elapsed_time))
end


local json = minetest.parse_json

--[[local function spawn_struct(pos)
    local modpath = minetest.get_modpath("vlf_data")
    local pos_hash = minetest.hash_node_position(pos)
    local blockseed = minetest.get_mapgen_setting("seed") -- Get the world's seed
    local seed = pos_hash + blockseed -- Combine the position hash and world seed
    local rng = PcgRandom(seed)
    local meta = minetest.get_meta(pos)
    local pool = meta:get_string("pool")
    local name = meta:get_string("name")
    local target = meta:get_string("target")
    local final_state = meta:get_string("final_state")
    local levels = tonumber(meta:get_string("levels")) or 0
    local joint_type = meta:get_string("joint_type")
    local param2 = minetest.get_node(pos).param2
    local rotate
    local fallback_pool

    -- Load the JSON file containing the pool of schematics
    local real_pool = pool:gsub("minecraft:", "")
    local json_path = modpath .. "/data/voxelforge/worldgen/template_pool/" .. real_pool .. ".json"
    local file = io.open(json_path, "r")
    if not file then
        minetest.log("error", "Failed to open JSON file: " .. json_path)
        return
    end

    local json_content = file:read("*a")
    file:close()

    local pool_data = json(json_content)
    if not pool_data then
        minetest.log("error", "Failed to parse JSON content")
        return
    end

    local elements = pool_data.elements
    if not elements or #elements == 0 then
        minetest.log("error", "No elements found in the pool")
        return
    end

    fallback_pool = pool_data.fallback
    if fallback_pool then
        fallback_pool = fallback_pool:gsub("minecraft:", "")
    end

    -- Gather all valid schematics
    local valid_schematics = {}
    for _, element in ipairs(elements) do
        local selected_element = element.element
        if not selected_element.location then
            minetest.log("error", "Missing location field in file: " .. json_path)
            return
        end
        -- Replace ":" with "_" in the location path
        local location = selected_element.location:gsub("minecraft:", "")

        -- Determine rotation and suffix based on param2
        local suffix = ""

        -- Apply suffix if applicable
        local base_name = location:gsub("%.vlfschem$", "")
        local selecting_schematic = "/data/voxelforge/structure/" .. base_name .. ".vlfschem"

        -- Load the schematic
        local schematic_data = load_vlfschem(selecting_schematic)
        if not schematic_data then
            minetest.log("error", "Failed to load schematic: " .. selecting_schematic)
            return
        end

        -- Check nodes within the schematic
        local found_matching_node = false
        for _, node in ipairs(schematic_data.nodes) do
            if node.metadata and node.metadata.name == target then
                found_matching_node = true
                break
            end
        end

        if found_matching_node then
            table.insert(valid_schematics, selecting_schematic)
        end
    end

    if #valid_schematics == 0 then
        minetest.log("error", "No matching schematics found with name: " .. name .. " and target: " .. target)
        -- Use the fallback pool if available
        if fallback_pool then
            minetest.log("action", "Using fallback pool: " .. fallback_pool)
            pool = fallback_pool
            local fallback_json_path = modpath .. "/data/voxelforge/worldgen/template_pool/" .. fallback_pool .. ".json"
            local fallback_file = io.open(fallback_json_path, "r")
            if not fallback_file then
                minetest.log("error", "Failed to open fallback JSON file: " .. fallback_json_path)
                return
            end

            local fallback_json_content = fallback_file:read("*a")
            fallback_file:close()

            local fallback_pool_data = json(fallback_json_content)
            if not fallback_pool_data then
                minetest.log("error", "Failed to parse fallback JSON content")
                return
            end

            elements = fallback_pool_data.elements
            if not elements or #elements == 0 then
                minetest.log("error", "No elements found in fallback pool")
                return
            end

            -- Re-collect valid schematics from the fallback pool
            valid_schematics = {}
            for _, element in ipairs(elements) do
                local selected_element = element.element
                if not selected_element.location then
                    minetest.log("error", "Missing location field in fallback file: " .. fallback_json_path)
                    return
                end
                -- Replace ":" with "_" in the location path
                local location = selected_element.location:gsub("minecraft:", "")

                -- Determine rotation and suffix based on param2

                -- Apply suffix if applicable
                local base_name = location:gsub("%.vlfschem$", "")
                local selecting_schematic = "/data/voxelforge/structure/" .. base_name .. ".vlfschem"

                -- Load the schematic
                local schematic_data = load_vlfschem(selecting_schematic)
                if not schematic_data then
                    minetest.log("error", "Failed to load fallback schematic: " .. selecting_schematic)
                    return
                end

                -- Check nodes within the schematic
                local found_matching_node = false
                for _, node in ipairs(schematic_data.nodes) do
                    if node.metadata and node.metadata.name == target then
                        found_matching_node = true
                        break
                    end
                end

                if found_matching_node then
                    table.insert(valid_schematics, selecting_schematic)
                end
            end

            if #valid_schematics == 0 then
                minetest.log("error", "No matching schematics found in fallback pool with name: " .. name .. " and target: " .. target)
                return
            end
        else
            minetest.log("error", "No fallback pool defined and no matching schematics found.")
            return
        end
    end

    -- Randomly select one of the valid schematics
    local selected_schematic = valid_schematics[rng:next(1, #valid_schematics)]

    -- Determine offset based on param2 value
    local offset
    if param2 == 0 then
        offset = vector.new(0, 0, 1)  -- North
    elseif param2 == 1 then
        offset = vector.new(1, 0, 0)  -- East
    elseif param2 == 2 then
        offset = vector.new(0, 0, -1) -- South
    elseif param2 == 3 then
        offset = vector.new(-1, 0, 0) -- West
    elseif param2 == 6 or param2 == 8 or param2 == 15 or param2 == 17 then
        offset = vector.new(0, 1, 0)   -- Up
    else
        return
    end

    -- Load the schematic again to find the target position
    local schematic_data = load_vlfschem(selected_schematic)
    if not schematic_data then
        minetest.log("error", "Failed to load schematic: " .. selected_schematic)
        return
    else
        minetest.log("action", "Successfully loaded schematic: " .. selected_schematic)
    end

    local target_pos
    local check_pos 
    for _, node in ipairs(schematic_data.nodes) do
        if node.metadata and node.metadata.name == target then
            target_pos = node.pos
            check_pos = target_pos + offset
            break
        end
    end

    if not target_pos then
        minetest.log("error", "No node found with target: " .. target .. " in selected schematic")
        return
    end
    local pos_adjusted = {x=pos.x, y=pos.y-1, z=pos.z}
    --local check_pos = pos_adjusted + offset

    -- Log original target position
    minetest.log("action", "Original target position: " .. minetest.pos_to_string(target_pos))
    local target_node = minetest.get_node(check_pos)

    -- Adjust placement position and apply rotation
    
                if param2 == 3 and target_param2 == 1 then
                    rotate = 90
                elseif param2 == 2 and target_param2 == 0 then
                    rotate = 180
                elseif param2 == 1 and target_param2 == 3 then
                    rotate = 270
                elseif param2 == 0 and target_param2 == 2 then
                    rotate = 0
                elseif param2 == 0 and target_param2 == 1 then
                    rotate = 270
                else
        	error("Unknown param2: "..tostring(param2).. " And Target Param2: "..tostring(target_param2).." Target Pos: "..tostring(check_pos).."")
                end
    local rotated_target_pos = rotate_position(target_pos, rotate)
    local placement_pos = vector.add(vector.subtract(pos, rotated_target_pos), offset)
    local place_pos = pos + offset

    -- Log rotated target position
    minetest.log("action", "Rotated target position: " .. minetest.pos_to_string(rotated_target_pos))
    minetest.log("action", "Calculated placement position: " .. minetest.pos_to_string(placement_pos))
   

    -- Place the schematic with the calculated rotation
    place_schematic(placement_pos, selected_schematic, rotate)

    -- Turn the initial block into the final state
    minetest.set_node(pos, {name = final_state})

    -- Check if the targeted node has the final_state meta and update it
    local target_node_meta = minetest.get_meta(place_pos)
    local target_meta_pos = target_node_meta:get_string("final_state")
    if target_meta_pos then
    	--minetest.set_node(place_pos, {name = target_meta_pos})
    end
end]]

--[[local function spawn_struct(pos)
    local modpath = minetest.get_modpath("vlf_data")
    local pos_hash = minetest.hash_node_position(pos)
    local blockseed = minetest.get_mapgen_setting("seed")
    local seed = pos_hash + blockseed
    local rng = PcgRandom(seed)
    local meta = minetest.get_meta(pos)
    local pool = meta:get_string("pool")
    local name = meta:get_string("name")
    local target = meta:get_string("target")
    local final_state = meta:get_string("final_state")
    local levels = tonumber(meta:get_string("levels")) or 0
    local joint_type = meta:get_string("joint_type")
    local param2 = minetest.get_node(pos).param2
    local rotate
    local fallback_pool

    -- Load the JSON file containing the pool of schematics
    local real_pool = pool:gsub("minecraft:", "")
    local json_path = modpath .. "/data/voxelforge/worldgen/template_pool/" .. real_pool .. ".json"
    local file = io.open(json_path, "r")
    if not file then
        minetest.log("error", "Failed to open JSON file: " .. json_path)
        return
    end

    local json_content = file:read("*a")
    file:close()

    local pool_data = json(json_content)
    if not pool_data then
        minetest.log("error", "Failed to parse JSON content")
        return
    end

    local elements = pool_data.elements
    if not elements or #elements == 0 then
        minetest.log("error", "No elements found in the pool")
        return
    end

    fallback_pool = pool_data.fallback
    if fallback_pool then
        fallback_pool = fallback_pool:gsub("minecraft:", "")
    end

    -- Gather all valid schematics
    local valid_schematics = {}
    for _, element in ipairs(elements) do
        local selected_element = element.element
        if not selected_element.location then
            minetest.log("error", "Missing location field in file: " .. json_path)
            return
        end
        local location = selected_element.location:gsub("minecraft:", "")
        local base_name = location:gsub("%.vlfschem$", "")
        local selecting_schematic = "/data/voxelforge/structure/" .. base_name .. ".vlfschem"

        -- Load the schematic
        local schematic_data = load_vlfschem(selecting_schematic)
        if not schematic_data then
            minetest.log("error", "Failed to load schematic: " .. selecting_schematic)
            return
        end

        -- Check nodes within the schematic
        local found_matching_node = false
        for _, node in ipairs(schematic_data.nodes) do
            if node.metadata and node.metadata.name == target then
                found_matching_node = true
                break
            end
        end

        if found_matching_node then
            table.insert(valid_schematics, selecting_schematic)
        end
    end

    if #valid_schematics == 0 then
        minetest.log("error", "No matching schematics found with name: " .. name .. " and target: " .. target)
        if fallback_pool then
            minetest.log("action", "Using fallback pool: " .. fallback_pool)
            pool = fallback_pool
            local fallback_json_path = modpath .. "/data/voxelforge/worldgen/template_pool/" .. fallback_pool .. ".json"
            local fallback_file = io.open(fallback_json_path, "r")
            if not fallback_file then
                minetest.log("error", "Failed to open fallback JSON file: " .. fallback_json_path)
                return
            end

            local fallback_json_content = fallback_file:read("*a")
            fallback_file:close()

            local fallback_pool_data = json(fallback_json_content)
            if not fallback_pool_data then
                minetest.log("error", "Failed to parse fallback JSON content")
                return
            end

            elements = fallback_pool_data.elements
            if not elements or #elements == 0 then
                minetest.log("error", "No elements found in fallback pool")
                return
            end

            valid_schematics = {}
            for _, element in ipairs(elements) do
                local selected_element = element.element
                if not selected_element.location then
                    minetest.log("error", "Missing location field in fallback file: " .. fallback_json_path)
                    return
                end
                local location = selected_element.location:gsub("minecraft:", "")
                local base_name = location:gsub("%.vlfschem$", "")
                local selecting_schematic = "/data/voxelforge/structure/" .. base_name .. ".vlfschem"

                local schematic_data = load_vlfschem(selecting_schematic)
                if not schematic_data then
                    minetest.log("error", "Failed to load fallback schematic: " .. selecting_schematic)
                    return
                end

                local found_matching_node = false
                for _, node in ipairs(schematic_data.nodes) do
                    if node.metadata and node.metadata.name == target then
                        found_matching_node = true
                        break
                    end
                end

                if found_matching_node then
                    table.insert(valid_schematics, selecting_schematic)
                end
            end

            if #valid_schematics == 0 then
                minetest.log("error", "No matching schematics found in fallback pool with name: " .. name .. " and target: " .. target)
                return
            end
        else
            minetest.log("error", "No fallback pool defined and no matching schematics found.")
            return
        end
    end

    local selected_schematic = valid_schematics[rng:next(1, #valid_schematics)]

    local offset
    if param2 == 0 then
        offset = vector.new(0, 0, 1)
    elseif param2 == 1 then
        offset = vector.new(1, 0, 0)
    elseif param2 == 2 then
        offset = vector.new(0, 0, -1)
    elseif param2 == 3 then
        offset = vector.new(-1, 0, 0)
    elseif param2 == 6 or param2 == 8 or param2 == 15 or param2 == 17 then
        offset = vector.new(0, 1, 0)
    else
        return
    end

    local schematic_data = load_vlfschem(selected_schematic)
    if not schematic_data then
        minetest.log("error", "Failed to load schematic: " .. selected_schematic)
        return
    else
        minetest.log("action", "Successfully loaded schematic: " .. selected_schematic)
    end

    local target_pos
    local check_pos 
    local target_param2
    for _, node in ipairs(schematic_data.nodes) do
        if node.metadata and node.metadata.name == target then
            target_pos = node.pos
            --check_pos = target_pos + offset
            target_param2 = node.param2  -- Get the param2 value of the target node
            break
        end
    end

    if not target_pos then
        minetest.log("error", "No node found with target: " .. target .. " in selected schematic")
        return
    end
    local pos_adjusted = {x=pos.x, y=pos.y-1, z=pos.z}
    local place_pos = pos + offset

    minetest.log("action", "Original target position: " .. minetest.pos_to_string(target_pos))
    --local target_node = minetest.get_node(check_pos)

    if param2 == 3 and target_param2 == 1 then
        rotate = 90
    elseif param2 == 2 and target_param2 == 0 then
        rotate = 180
    elseif param2 == 1 and target_param2 == 3 then
        rotate = 270
    elseif param2 == 0 and target_param2 == 2 then
        rotate = 0
    elseif param2 == 0 and target_param2 == 1 then
        rotate = 270
    elseif param2 == 0 and target_param2 == 3 then
    	rotate = 90
    else
        error("Unknown param2: "..tostring(param2).. " And Target Param2: "..tostring(target_param2).." Target Pos: "..tostring(place_pos).."")
    end

    local rotated_target_pos = rotate_position(target_pos, rotate)
    local placement_pos = vector.add(vector.subtract(pos, rotated_target_pos), offset)

    minetest.log("action", "Rotated target position: " .. minetest.pos_to_string(rotated_target_pos))
    minetest.log("action", "Calculated placement position: " .. minetest.pos_to_string(placement_pos))
    
    place_schematic(placement_pos, selected_schematic, rotate)

    --minetest.set_node(pos, {name = final_state})

    local target_node_meta = minetest.get_meta(place_pos)
    local target_meta_pos = target_node_meta:get_string("final_state")
    if target_meta_pos then
        --minetest.set_node(placement_pos, {name = target_meta_pos})
    end
end]]

local function spawn_struct(pos)
    local modpath = minetest.get_modpath("vlf_data")
    local pos_hash = minetest.hash_node_position(pos)
    local blockseed = minetest.get_mapgen_setting("seed")
    local seed = pos_hash + blockseed
    local rng = PcgRandom(seed)
    local meta = minetest.get_meta(pos)
    local pool = meta:get_string("pool")
    local name = meta:get_string("name")
    local target = meta:get_string("target")
    local final_state = meta:get_string("final_state")
    local levels = tonumber(meta:get_string("levels")) or 0
    local joint_type = meta:get_string("joint_type")
    local param2 = minetest.get_node(pos).param2
    local rotate
    local fallback_pool

    -- Load the JSON file containing the pool of schematics
    local real_pool = pool:gsub("minecraft:", "")
    local json_path = modpath .. "/data/voxelforge/worldgen/template_pool/" .. real_pool .. ".json"
    local file = io.open(json_path, "r")
    if not file then
        minetest.log("error", "Failed to open JSON file: " .. json_path)
        return
    end

    local json_content = file:read("*a")
    file:close()

    local pool_data = json(json_content)
    if not pool_data then
        minetest.log("error", "Failed to parse JSON content")
        return
    end

    local elements = pool_data.elements
    if not elements or #elements == 0 then
        minetest.log("error", "No elements found in the pool")
        return
    end

    fallback_pool = pool_data.fallback
    if fallback_pool then
        fallback_pool = fallback_pool:gsub("minecraft:", "")
    end

    -- Gather all valid schematics
    local valid_schematics = {}
    for _, element in ipairs(elements) do
        local selected_element = element.element
        if not selected_element.location then
            minetest.log("error", "Missing location field in file: " .. json_path)
            return
        end
        local location = selected_element.location:gsub("minecraft:", "")
        local base_name = location:gsub("%.vlfschem$", "")
        local selecting_schematic = "/data/voxelforge/structure/" .. base_name .. ".vlfschem"

        -- Load the schematic
        local schematic_data = load_vlfschem(selecting_schematic)
        if not schematic_data then
            minetest.log("error", "Failed to load schematic: " .. selecting_schematic)
            return
        end

        -- Check nodes within the schematic
        local found_matching_node = false
        for _, node in ipairs(schematic_data.nodes) do
            if node.metadata and node.metadata.name == target then
                found_matching_node = true
                break
            end
        end

        if found_matching_node then
            table.insert(valid_schematics, selecting_schematic)
        end
    end

    if #valid_schematics == 0 then
        minetest.log("error", "No matching schematics found with name: " .. name .. " and target: " .. target)
        if fallback_pool then
            minetest.log("action", "Using fallback pool: " .. fallback_pool)
            pool = fallback_pool
            local fallback_json_path = modpath .. "/data/voxelforge/worldgen/template_pool/" .. fallback_pool .. ".json"
            local fallback_file = io.open(fallback_json_path, "r")
            if not fallback_file then
                minetest.log("error", "Failed to open fallback JSON file: " .. fallback_json_path)
                return
            end

            local fallback_json_content = fallback_file:read("*a")
            fallback_file:close()

            local fallback_pool_data = json(fallback_json_content)
            if not fallback_pool_data then
                minetest.log("error", "Failed to parse fallback JSON content")
                return
            end

            elements = fallback_pool_data.elements
            if not elements or #elements == 0 then
                minetest.log("error", "No elements found in fallback pool")
                return
            end

            valid_schematics = {}
            for _, element in ipairs(elements) do
                local selected_element = element.element
                if not selected_element.location then
                    minetest.log("error", "Missing location field in fallback file: " .. fallback_json_path)
                    return
                end
                local location = selected_element.location:gsub("minecraft:", "")
                local base_name = location:gsub("%.vlfschem$", "")
                local selecting_schematic = "/data/voxelforge/structure/" .. base_name .. ".vlfschem"

                local schematic_data = load_vlfschem(selecting_schematic)
                if not schematic_data then
                    minetest.log("error", "Failed to load fallback schematic: " .. selecting_schematic)
                    return
                end

                local found_matching_node = false
                for _, node in ipairs(schematic_data.nodes) do
                    if node.metadata and node.metadata.name == target then
                        found_matching_node = true
                        break
                    end
                end

                if found_matching_node then
                    table.insert(valid_schematics, selecting_schematic)
                end
            end

            if #valid_schematics == 0 then
                minetest.log("error", "No matching schematics found in fallback pool with name: " .. name .. " and target: " .. target)
                return
            end
        else
            minetest.log("error", "No fallback pool defined and no matching schematics found.")
            return
        end
    end

    local selected_schematic = valid_schematics[rng:next(1, #valid_schematics)]

    local offset
    if param2 == 0 then
        offset = vector.new(0, 0, 1) -- North-facing
    elseif param2 == 1 then
        offset = vector.new(1, 0, 0) -- East-facing
    elseif param2 == 2 then
        offset = vector.new(0, 0, -1) -- South-facing
    elseif param2 == 3 then
        offset = vector.new(-1, 0, 0) -- West-facing
    elseif param2 == 6 or param2 == 8 or param2 == 15 or param2 == 17 then
        offset = vector.new(0, 1, 0) -- Upward-facing
    else
        return
    end

    local schematic_data = load_vlfschem(selected_schematic)
    if not schematic_data then
        minetest.log("error", "Failed to load schematic: " .. selected_schematic)
        return
    else
        minetest.log("action", "Successfully loaded schematic: " .. selected_schematic)
    end

    local target_pos
    for _, node in ipairs(schematic_data.nodes) do
        if node.metadata and node.metadata.name == target then
            target_pos = node.pos
            target_param2 = node.param2
            break
        end
    end

    if not target_pos then
        minetest.log("error", "No node found with target: " .. target .. " in selected schematic")
        return
    end
    
    local size = schematic_data.size

    -- Rotation Logic: Rotate the target point around the initial position
    local rotated_target_pos = target_pos
    if param2 == 1 and target_param2 == 3 then
        rotated_target_pos = {x = target_pos.z, y = target_pos.y, z = -target_pos.x}
    elseif param2 == 2 and target_param2 == 0 then
        rotated_target_pos = {x = -target_pos.x, y = target_pos.y, z = -target_pos.z}
    elseif param2 == 3 and target_param2 == 1 then
        rotated_target_pos = {x = -target_pos.z, y = target_pos.y, z = target_pos.x}
    elseif param2 == 0 and target_param2 == 3 then
    	rotated_target_pos = {x = -target_pos.z, y = target_pos.y, z = target_pos.x}
    elseif param2 == 1 and target_param2 == 2 then
    	rotated_target_pos = {x = -target_pos.x+(size.x/2), y = target_pos.y, z = -target_pos.z-(size.z/2-1)}
    elseif param2 == 1 and target_param2 == 0 then
    	rotated_target_pos = {x = -target_pos.z--[[+size.x]], y = target_pos.y, z = target_pos.x--[[-(size.z/4)]]}
    elseif param2 == 15 and target_param2 == 4 then
    	rotated_target_pos = {x = target_pos.z--[[+(size.x)]], y = target_pos.y, z = -target_pos.x--[[-(size.z/4)]]}
    end
    local rot
    -- Normal
    if param2 == 0 and target_param2 == 2 then
    	rot = 0
    elseif param2 == 1 and target_param2 == 3 then
    	rot = 90
    elseif param2 == 2 and target_param2 == 0 then
    	rot = 180
    elseif param2 == 3 and target_param2 == 1 then
    	rot = 270
    -- Up
    elseif param2 == 6 and target_param2 == 4 then
    	rot = 0
    elseif param2 == 15 and target_param2 ==  4 then
    	rot = 90
    elseif param2 == 8 and target_param2 == 10 then
    	rot = 180
    elseif param2 == 17 and target_param2 == 19 then
    	rot = 270
    -- Hybrid
    elseif param2 == 0 and target_param2 == 3 then
    	rot = 270
    elseif param2 == 1 and target_param2 == 2 then
    	rot = 180
    elseif param2 == 1 and target_param2 == 0 then
    	rot = 270
    elseif param2 == 1 and target_param2 == 3 then
    	rot = 90
    end

    local placement_pos = vector.add(pos, vector.subtract(offset, rotated_target_pos))

    minetest.log("action", "Calculated placement position: " .. minetest.pos_to_string(placement_pos))

    place_schematic(placement_pos, selected_schematic, rot)

    minetest.set_node(pos, {name = final_state})

    local target_node_meta = minetest.get_meta(placement_pos)
    target_node_meta:set_string("pool", pool)
    target_node_meta:set_string("name", name)
    target_node_meta:set_string("target", target)
    target_node_meta:set_string("final_state", final_state)
    target_node_meta:set_string("levels", levels)
    target_node_meta:set_string("joint_type", joint_type)
end


-- Function to get the formspec
local function get_jigsaw_formspec(pos)
    local meta = minetest.get_meta(pos)
    local pool = meta:get_string("pool")
    local name = meta:get_string("name")
    local final_state = meta:get_string("final_state")
    local target = meta:get_string("target")
    local levels = meta:get_string("levels")
    local joint_type = meta:get_string("joint_type")
    
    return "size[12,10]" ..
           "field[0.5,0.5;7.5,1;pool;Target Pool:;" .. pool .. "]" ..
           "field[0.5,1.5;7.5,1;name;Name:;" .. name .. "]" ..
           "field[0.5,2.5;7.5,1;target;Target Name:;" .. target .. "]" ..
           "field[0.5,3.5;7.5,1;final_state;Turns into:;" .. final_state .. "]" ..
           "field[0.5,4.5;3.5,1;levels;Levels:;" .. levels .. "]" ..
           "field[4,4.5;3.5,1;joint_type;Joint Type:;" .. joint_type .. "]" ..
           "button[0.5,6.5;3,1;generate;Generate]" ..
           "button_exit[4.5,6.5;3,1;cancel;Cancel]"
end

-- Register the jigsaw block
minetest.register_node(":voxelforge:jigsaw", {
    description = "Jigsaw Block",
    tiles = {
    "jigsaw_lock.png",
    "jigsaw_side_0.png",
    "jigsaw_side_90.png",
    "jigsaw_side.png",
    "jigsaw_top.png",
    "jigsaw_bottom.png"
    },
    paramtype2 = "facedir",
    groups = {choppy = 2, oddly_breakable_by_hand = 2},
    on_rightclick = function(pos, node, player, itemstack, pointed_thing)
        if player:get_player_name() ~= "" and player:is_player() then
            minetest.show_formspec(player:get_player_name(), "voxelforge:jigsaw", get_jigsaw_formspec(pos))
        end
    end,
    on_construct = function(pos, node)
        local node = minetest.get_node(pos)
        local meta = minetest.get_meta(pos)
        
        -- Check if the node name matches the one you're interested in
        minetest.after(0.01, function()
        if node.name == "voxelforge:jigsaw" then
            meta:set_string("generate", "true")
            local generate = meta:get_string("generate")
            if generate == "true" then 
            	spawn_struct(pos)
            end
        end
        end)
end,
})

-- Handle form submissions
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "voxelforge:jigsaw" then
        return
    end
    
        local node_pos = minetest.get_player_by_name(player:get_player_name()):get_pos()
        node_pos = vector.floor(node_pos)

        -- Find all nodes of schematic editor in the area
        local nodes = minetest.find_nodes_in_area(vector.subtract(node_pos, 2), vector.add(node_pos, 2), "voxelforge:jigsaw")
        local pos = nodes[1]  -- Assume we only handle one node

        if not pos then
            minetest.chat_send_player(player:get_player_name(), "No jigsaw block node found.")
            return
        end

        -- Retrieve node meta
        local meta = minetest.get_meta(pos)

       	local pool = tostring(fields.pool) or meta:get_string("pool")
        local name = tostring(fields.name) or meta:get_string("name")
        local final_state = tostring(fields.final_state) or meta:get_string("final_state")
        local target = tostring(fields.target) or meta:get_string("target")
        local levels = tonumber(fields.levels) or meta:get_string("levels")
        local joint_type = tostring(fields.joint_type) or meta:get_string("joint_type")
    -- Update metadata fields
        meta:set_string("pool", pool)
        meta:set_string("name", name)
        meta:set_string("target", target)
        meta:set_string("final_state", final_state)
        meta:set_string("levels", levels)
        meta:set_string("joint_type", joint_type)
    if fields.generate then
	--meta:set_string("generate", "true")
	spawn_struct(pos)
    end
end)

minetest.register_chatcommand("place_test", {
	params = "",
	description = "Test for Procedural Structures.",
	func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then
            return false, "Player not found."
        end

        local pos = player:get_pos()
		place_schematic(pos, "/data/voxelforge/structure/trial_chambers/corridor/end_1.vlfschem", 0)
	end
})

minetest.register_chatcommand("set_meta_here", {
    params = "<key> <value>",
    description = "Sets node meta at the position where the player is standing.",
    func = function(name, param)
        -- Parse parameters
        local key, value = param:match("^(%S+) (.+)$")
        if not key or not value then
            return false, "Usage: /set_meta_here <key> <value>"
        end

        -- Get the player's position
        local player = minetest.get_player_by_name(name)
        if not player then
            return false, "Player not found."
        end

        local pos = player:get_pos()

        -- Get the node at the player's position
        local node_pos = {x = math.floor(pos.x + 0.5), y = math.floor(pos.y + 0.5), z = math.floor(pos.z + 0.5)}
        local meta = minetest.get_meta(node_pos)

        -- Set the meta value
        meta:set_string(key, value)

        -- Feedback
        return true, "Meta set at your current position (" .. node_pos.x .. ", " .. node_pos.y .. ", " .. node_pos.z .. ")"
    end
})

minetest.register_chatcommand("get_meta", {
    description = "Get metadata of the node at your position",
    privs = {interact = true},  -- Only allow players with the interact privilege to use this command
    func = function(name)
        -- Get the player object
        local player = minetest.get_player_by_name(name)
        if not player then
            return false, "Player not found."
        end

        -- Get the player's position
        local pos = player:get_pos()
        pos = vector.round(pos)  -- Round the position to the nearest node

        -- Get the metadata at the player's position
        local meta = minetest.get_meta(pos)
        if not meta then
            return false, "No metadata found at your position."
        end

        -- Retrieve all metadata fields
        local meta_table = meta:to_table()
        local meta_string = minetest.serialize(meta_table.fields)

        -- Return the metadata to the player
        return true, "Metadata at your position: " .. meta_string
    end,
})

minetest.register_on_joinplayer(function(pos)
	pos = {x=0, y=50, z=0}
	--place_schematic(pos, "/data/voxelforge/structure/trial_chambers/corridor/end_1.vlfschem", 0)
	--minetest.log("error", "schematic placed at" .. pos .. "")
end)

local placed_schematics = {}  -- Table to store placed schematic data for each player

local function is_directory(path)
    local success, _, code = os.rename(path, path)
    if not success and code == 13 then
        return true
    end
    return success, code
end

local function is_file(path)
    local f = io.open(path, "r")
    if f then
        f:close()
        return true
    else
        return false
    end
end

local function place_all_schematics_in_directory(directory, pos_start, player_name)
    --placed_schematics[playermeta:set_int("ox", minetest.serialize(schematic.size.x+1))_name] = {}  -- Initialize schematic data for the player

    local function place_schematics_in_dir(dir, pos)
        local items = minetest.get_dir_list(dir, false) -- Get all items (files and directories)

        -- Sort items alphabetically
        table.sort(items)

        minetest.log("action", "Scanning directory: " .. dir)
        for _, item in ipairs(items) do
            local filepath = dir .. DIR_DELIM .. item
		if is_file(filepath) and item:match("%.vlfschem$") then
                minetest.log("action", "Found schematic file: " .. filepath)

                local schematic = load_vlfschem(filepath)
                if not schematic then
                    minetest.log("error", "Failed to load schematic data: " .. filepath)
                else
                    -- Calculate the size of the schematic for positioning
                    local schematic_size = {
                        x = schematic.size.x,
                        y = schematic.size.y,
                        z = schematic.size.z
                    }

                    -- Place the schematic
                    place_schematic(pos, filepath, 0)
                    minetest.log("action", "Placed schematic at position: " .. minetest.pos_to_string(pos))

                    -- Determine the position for the voxelforge:schematic_editor block
                    local editor_pos = {
                        x = pos.x--[[ + schematic_size.x - 1]],  -- One node away in the X direction
                        y = pos.y - 1,                    -- One node below
                        z = pos.z--[[ + -schematic_size.z - 1]] -- One node away in the Z direction
                    }

                    -- Place the voxelforge:schematic_editor block
                    minetest.set_node(editor_pos, {name = "voxelforge:schematic_editor"})

                    -- Set metadata for the schematic_editor block
                    local meta = minetest.get_meta(editor_pos)
                    meta:set_string("filename", item)
                    meta:set_string("sx", schematic.size.x)
                    meta:set_string("sy", schematic.size.y)
                    meta:set_string("sz", schematic.size.z)
                    meta:set_string("ox", 0)
                    meta:set_string("oy", 1)
                    meta:set_string("oz", 0)

                    -- Save the schematic's placement data for the player
                    table.insert(placed_schematics, {
                        name = item,
                        position = table.copy(pos),
                        size = schematic_size,
                        editor_pos = editor_pos
                    })

                    -- Update position for the next schematic placement
                    pos.z = pos.z + schematic_size.z + 4 -- Move position to the right by schematic width + 4 blocks
                end
            else
                minetest.log("action", "Skipped non-schematic file: " .. filepath)
            end
        end

        return pos
    end

    local final_pos = place_schematics_in_dir(directory, pos_start)
    return final_pos
end

-- Usage example:
-- place_all_schematics_in_directory("/path/to/schematics", {x = 0, y = 10, z = 0}, "player_name")

--place_all_schematics_in_directory(modpath .. "/data/voxelforge/structure/trial_chambers", {x = 0, y = 100, z = 0})

--[[minetest.register_on_joinplayer(function(pos)
	local pos = {x=0, y=100, z=0}
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/trial_chambers/chamber", pos)
end)

minetest.register_on_joinplayer(function(pos)
	local pos = {x=40, y=100, z=0}
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/trial_chambers/chamber/addon", pos)
end)

minetest.register_on_joinplayer(function(pos)
	local pos = {x=60, y=100, z=0}
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/trial_chambers/assembly", pos)
end)

minetest.register_on_joinplayer(function(pos)
	local pos = {x=100, y=100, z=0}
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/trial_chambers/chamber/eruption", pos)
end)

minetest.register_on_joinplayer(function(pos)
	local pos = {x=160, y=100, z=0}
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/trial_chambers/chamber/pedestal", pos)

end)

minetest.register_on_joinplayer(function(pos)
	local pos = {x=200, y=100, z=0}
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/trial_chambers/chamber/slanted", pos)
end)

minetest.register_on_joinplayer(function(pos)
	local pos = {x=-10, y=100, z=0}
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/trial_chambers/chests", pos)
end)

minetest.register_on_joinplayer(function(pos)
	local pos = {x=-10, y=100, z=10}
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/trial_chambers/chests/connectors", pos)
end)
minetest.register_on_joinplayer(function(pos)
	local pos = {x=-40, y=100, z=0}
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/trial_chambers/corridor", pos)
end)

minetest.register_on_joinplayer(function(pos)
	local pos = {x=-70, y=100, z=0}
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/trial_chambers/corridor/atrium", pos)
end)

minetest.register_on_joinplayer(function(pos)
	local pos = {x=-100, y=100, z=0}
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/trial_chambers/corridor/addon", pos)
end)

minetest.register_on_joinplayer(function(pos)
	local pos = {x=-120, y=100, z=0}
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/trial_chambers/decor", pos)
end)

minetest.register_on_joinplayer(function(pos)
	local pos = {x=-140, y=100, z=0}
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/trial_chambers/dispensers", pos)
end)

minetest.register_on_joinplayer(function(pos)
	local pos = {x=-170, y=100, z=0}
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/trial_chambers/hallway", pos)
end)
]]
minetest.register_on_joinplayer(function(pos)
	local pos = {x=-200, y=100, z=0}
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/trial_chambers/intersection", pos)
end)
--[[
minetest.register_on_joinplayer(function(pos)
	local pos = {x=-220, y=100, z=0}
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/trial_chambers/reward", pos)
end)

minetest.register_on_joinplayer(function(pos)
	local pos = {x=-230, y=100, z=0}
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/trial_chambers/spawner/breeze", pos)
end)

minetest.register_on_joinplayer(function(pos)
	local pos = {x=-240, y=100, z=0}
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/trial_chambers/spawner/connectors", pos)
end)

minetest.register_on_joinplayer(function(pos)
	local pos = {x=-250, y=100, z=0}
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/trial_chambers/spawner/melee", pos)
end)

minetest.register_on_joinplayer(function(pos)
	local pos = {x=-260, y=100, z=0}
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/trial_chambers/spawner/ranged", pos)
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/trial_chambers/spawner/slow_ranged", {x=-270, y=100, z=0})
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/trial_chambers/spawner/small_melee", {x=-280, y=100, z=0})
	--minetest.log("error", "schematic placed at" .. pos .. "")
end)

minetest.register_on_joinplayer(function(pos)
	local pos = {x=-270, y=100, z=0}
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/trial_chambers/spawner/slow_ranged", pos)
end)

minetest.register_on_joinplayer(function(pos)
	local pos = {x=-280, y=100, z=0}
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/trial_chambers/spawner/small_melee", pos)
end)]]
