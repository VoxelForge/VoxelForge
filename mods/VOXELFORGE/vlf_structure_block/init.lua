local cpath = minetest.get_modpath("vlf_structure_block")
local modpath = minetest.get_modpath("vlf_structure_block")
local binser = dofile(minetest.get_modpath("vlf_lib") .. "/binser.lua")
vlf_structure_block = {}


minetest.register_on_mods_loaded(function()
    local worldpath = minetest.get_worldpath()
    local dir_name = "voxelforge/structure_block/export"
    local target_path = worldpath .. DIR_DELIM .. dir_name
    local dir_name2 = "voxelforge/structure_block/3d_models"
    local target_path2 = worldpath .. DIR_DELIM .. dir_name2

    local dir_name3 = "generated/voxelforge/structures"
    local target_path3 = worldpath .. DIR_DELIM .. dir_name3

    -- Attempt to create the directory
    local success = minetest.mkdir(target_path)
    if success then
        minetest.log("action", "[CustomDir] Directory ensured at: " .. target_path)
    else
        minetest.log("error", "[CustomDir] Failed to ensure directory at: " .. target_path)
    end
    local success2 = minetest.mkdir(target_path2)
    if success2 then
        minetest.log("action", "[CustomDir] Directory ensured at: " .. target_path2)
    else
        minetest.log("error", "[CustomDir] Failed to ensure directory at: " .. target_path2)
    end
    local success3 = minetest.mkdir(target_path3)
    if success3 then
        minetest.log("action", "[CustomDir] Directory ensured at: " .. target_path3)
    else
        minetest.log("error", "[CustomDir] Failed to ensure directory at: " .. target_path3)
    end
end)

-- Non Binary File
function vlf_structure_block.load_vlfschem_nb(file_name, worldpath)
    if not file_name then
        minetest.log("error", "File name is nil.")
        return nil
    end

    --local file_path = file_name
    local file_path
    if worldpath == true then
		file_path = minetest.get_worldpath().."/generated/voxelforge/structures/" .. file_name
    elseif worldpath == false then
		file_path = modpath .. "/" .. file_name
	end
    --minetest.log("action", "Loading schematic from file: " .. file_path)
    minetest.log("action", "Loading schematic from file: " .. file_path)

    -- Attempt to load the Lua file
    local chunk, load_err = loadfile(file_path)
    if not chunk then
        minetest.log("error", "Cannot load file: " .. file_path .. " - " .. load_err)
        return nil
    end

    -- Execute the Lua file and capture the returned data
    local success, schematic_data = pcall(chunk)
    if not success then
        minetest.log("error", "Error executing Lua file: " .. schematic_data)
        return nil
    end

    -- Ensure the returned data is a table
    if type(schematic_data) ~= "table" then
        minetest.log("error", "Schematic data is not a table in file: " .. file_name)
        return nil
    end

    -- Check if the 'nodes' field is present and is a table
    if type(schematic_data.nodes) ~= "table" then
        minetest.log("error", "Invalid schematic data: 'nodes' field is missing or not a table")
        return nil
    end

    -- Optionally log the type and content of the schematic data
    minetest.log("action", "Schematic data type: " .. type(schematic_data))

    return schematic_data -- Return the entire schematic table
end

function vlf_structure_block.load_vlfschem(file_name, worldpath)
    if not file_name or file_name == "" then
        minetest.log("error", "Invalid file name provided.")
        return nil
    end

    local file_path
    if worldpath == true then
        file_path = minetest.get_worldpath() .. "/generated/voxelforge/structures/" .. file_name
    elseif worldpath == false then
        file_path = modpath .. "/" .. file_name
    else
        minetest.log("error", "Invalid worldpath parameter.")
        return nil
    end

    -- Attempt to open the file in binary mode
    local file = io.open(file_path, "rb")
    if not file then
        minetest.log("error", "File not found or cannot be opened: " .. file_path)
        return nil
    end

    -- Read the binary file content
    local compressed_content = file:read("*a")
    file:close()
    
    if not compressed_content or compressed_content == "" then
        minetest.log("error", "File is empty or unreadable: " .. file_path)
        return nil
    end

    -- Decompress the content
    local content = core.decompress(compressed_content)
    if not content then
        minetest.log("error", "Failed to decompress file: " .. file_path)
        return nil
    end

    -- Attempt to deserialize the decompressed content
    local success, schematic_data = pcall(function() return binser.deserialize(content) end)
    if not success or not schematic_data then
        minetest.log("error", "Error deserializing file: " .. file_path)
        return nil
    end
    
    -- Ensure the schematic data is a table
    if type(schematic_data) ~= "table" or #schematic_data == 0 then
        minetest.log("error", "Invalid schematic data format in file: " .. file_path)
        return nil
    end

    -- Check the structure of the schematic data
    if not schematic_data[1] or type(schematic_data[1].nodes) ~= "table" then
        minetest.log("error", "Schematic data is missing required fields in file: " .. file_path)
        return nil
    end

    return schematic_data[1] -- return the first item in case of multiple items
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
end

-- Rotation function for positions, considering the rotation origin
local function rotate_position(pos, rotation, origin)
    local relative_pos = vector.subtract(pos, origin)
    local x, z = relative_pos.x, relative_pos.z

    local rotated_pos
    if rotation == 270 then
        rotated_pos = {x = -z, y = relative_pos.y, z = x}
    elseif rotation == 180 then
        rotated_pos = {x = -x, y = relative_pos.y, z = -z}
    elseif rotation == 90 then
        rotated_pos = {x = z, y = relative_pos.y, z = -x}
    else
        rotated_pos = relative_pos
    end

    return vector.add(rotated_pos, origin)
end

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
    return table_to_use[new_index]
end

-- Function to load the area around the position
local function load_area(minp, maxp)
    if not minetest.get_voxel_manip then
        return true  -- No voxel manipulator support, assume area is loaded
    end

    local manip = minetest.get_voxel_manip()
    local e1, e2 = manip:read_from_map(minp, maxp)
    if e1 and e2 then
        manip:calc_lighting()
        manip:update_map()
        return true
    else
        return false  -- Area couldn't be loaded
    end
end


function vlf_structure_block.place_schematic(pos, file_name, rotation, rotation_origin, binary, worldpath, include_entities)
    local start_time = minetest.get_us_time()  -- Start timing

    rotation = rotation or 0
    rotation_origin = rotation_origin or pos

    local pos_hash = minetest.hash_node_position(pos)
    local blockseed = minetest.get_mapgen_setting("seed")
    local seed = pos_hash + blockseed
    local schematic
    if binary == "true" then
    	schematic = vlf_structure_block.load_vlfschem(file_name, worldpath)
    elseif binary == "false" then
    	schematic = vlf_structure_block.load_vlfschem_nb(file_name, worldpath)
    else
    	schematic = vlf_structure_block.load_vlfschem(file_name, worldpath)
    end
    if not schematic then
        minetest.log("error", "Failed to load schematic data.")
        return
    end

    -- Determine the area to be loaded based on schematic size
    local schematic_size = schematic.size
    local minp, maxp

    local schem_size
    if rotation == 0 then
    minp = vector.subtract(pos, vector.multiply(schematic_size, 0.0))
    maxp = vector.add(pos, vector.multiply(schematic_size, 1.0))
    elseif rotation == 90 then
    schem_size = {x=schematic_size.z, y=schematic_size.y, z=schematic_size.x}
    minp = vector.add(pos, vector.multiply(schem_size, 1.0))
    maxp = vector.subtract(pos, vector.multiply(schem_size, 0.0))
    elseif rotation == 180 then
    minp = vector.subtract(pos, vector.multiply(schematic_size, 1.0))
    maxp = vector.add(pos, vector.multiply(schematic_size, 0.0))
    elseif rotation == 270 then
    schem_size = {x=schematic_size.z, y=schematic_size.y, z=schematic_size.x}
    minp = vector.add(pos, vector.multiply(schem_size, 0.0))
    maxp = vector.subtract(pos, vector.multiply(schem_size, 1.0))
    else
    minp = vector.subtract(pos, vector.multiply(schematic_size, 0.0))
    maxp = vector.add(pos, vector.multiply(schematic_size, 1.0))
    end


    minetest.log("error", "Schematic " .. file_name .. " bounds: minp=" .. minetest.pos_to_string(minp) .. ", maxp=" .. minetest.pos_to_string(maxp) .. "Schematic rotation: " .. tostring(rotation))

    -- Load the area
    if not load_area(minp, maxp) then
        --minetest.log("error", "Failed to load area for schematic placement.")
        return
    end

    local nodes_by_type = {}
    local metadata = {}

    -- Process nodes
    for _, node in ipairs(schematic.nodes) do
        -- Rotate node position and param2
        local rotated_pos = rotate_position(node.pos, rotation, rotation_origin)
        local node_pos = vector.add(pos, rotated_pos)

        -- Rotate param2 based on the node's orientation
        local rotated_param2 = rotate_param2(node.param2 or 0, rotation)

        -- Process copper bulbs separately
        --if node.name == "vlf_copper:waxed_copper_bulb_lit" then
            --local processed_node = process_copper_bulb(node_pos, node)
            --local node_name = processed_node and processed_node.name or node.name
            --local node_param2 = processed_node and (rotated_param2 or 0) or rotated_param2

            -- Set copper bulb nodes individually
            --minetest.set_node(node_pos, {name = node_name, param2 = node_param2})
        --else
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
        --end
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

    -- Handle loading entities
    if schematic.entities and include_entities == true then
        for _, entity_data in ipairs(schematic.entities) do
            -- Rotate entity position
            local rotated_pos = rotate_position(entity_data.pos, rotation, rotation_origin)
            local entity_pos = vector.add(pos, rotated_pos)

            -- Spawn entity if it's not excluded
            if entity_data.name ~= "vlf_structure_block:border" then
                local obj = minetest.add_entity(entity_pos, entity_data.name)
                if obj and entity_data.properties then
                    local luaentity = obj:get_luaentity()
                    if luaentity then
                        for key, value in pairs(entity_data.properties) do
                            luaentity[key] = value
                        end
                    end
                end
            end
        end
    end
end

dofile(cpath .. "/structure_block.lua")
