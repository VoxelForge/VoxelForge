local cpath = minetest.get_modpath("vlf_structure_block")
local modpath = minetest.get_modpath("vlf_structure_block")
local binser = dofile(minetest.get_modpath("vlf_lib") .. "/binser.lua")
dofile (modpath.."/processors.lua")
vlf_structure_block = {}

minetest.register_alias("vlf_trial_chambers:temp_glass", "voxelforge:temp_glass")
minetest.register_alias("vlf_trial_chambers:jigsaw_block", "voxelforge:jigsaw")
minetest.register_alias("vlf_copper:waxed_oxidized_cut_copper_stairs", "mcl_stairs:stair_waxed_copper_oxidized_cut")
minetest.register_alias("voxelforge:air", "air")
minetest.register_alias("voxelforge:tuff_bricks", "mcl_deepslate:tuff_bricks")
minetest.register_alias("voxelforge:waxed_oxidized_copper", "mcl_copper:waxed_oxidized_copper")
minetest.register_alias("voxelforge:waxed_oxidized_cut_copper", "mcl_copper:waxed_oxidized_cut_copper")
minetest.register_alias("voxelforge:waxed_copper_block", "mcl_copper:waxed_copper")
minetest.register_alias("voxelforge:chiseled_tuff", "mcl_deepslate:tuff_chiseled")
minetest.register_alias("voxelforge:waxed_copper_bulb", "mcl_copper:waxed_copper_bulb_lit")
minetest.register_alias("voxelforge:chiseled_tuff_bricks", "mcl_deepslate:tuff_chiseled_bricks")
minetest.register_alias("voxelforge:waxed_copper_bulb[lit=true]", "mcl_copper:waxed_copper_bulb_lit")
minetest.register_alias("voxelforge:polished_tuff", "mcl_deepslate:tuff_polished")
minetest.register_alias("voxelforge:trial_spawner", "mcl_mobspawners:spawner")
minetest.register_alias("voxelforge:pointed_dripstone", "mcl_dripstone:dripstone_up_tip")
minetest.register_alias("voxelforge:tripwire", "vlf_tripwire:tripwire")
minetest.register_alias("voxelforge:tripwire_hook_active", "vlf_tripwire:tripwire_hook_active")
minetest.register_alias("voxelforge:waxed_copper_grate", "mcl_copper:waxed_copper_grate")
minetest.register_alias("voxelforge:observer", "mcl_observers:observer_down_off")
minetest.register_alias("vlf_core:powdered_snow", "vlf_powder_snow:powder_snow")
minetest.register_alias("vlf_dripstone:pointed_dripstone_up_frustum", "mcl_dripstone:dripstone_up_frustum")
minetest.register_alias("vlf_dripstone:pointed_dripstone_up_tip", "mcl_dripstone:dripstone_up_tip")


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
        --minetest.log("error", "Invalid worldpath parameter.")
        --return nil
        file_path = modpath .. "/" .. file_name
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


    -- Ensure the metadata is in the correct format
    local formatted_metadata = {}
    for pos, meta in pairs(metadata) do
        local meta_node_pos = vector.new(pos)
        formatted_metadata[meta_node_pos] = meta
    end

    -- Set metadata for each node position
    --[[for pos, meta in pairs(formatted_metadata) do
        local node_meta = minetest.get_meta(pos)
        for key, value in pairs(meta) do
            node_meta:set_string(key, value)
        end
    end]]
    for pos, meta in pairs(formatted_metadata) do
    local node_meta = minetest.get_meta(pos)
    for key, value in pairs(meta) do
        if type(value) == "string" then
            node_meta:set_string(key, value)
        else
            minetest.log("error", "Attempted to set non-string metadata for key: " .. key)
        end
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

--[[function vlf_structure_block.place_schematic(pos, file_name, rotation, rotation_origin, binary, worldpath, include_entities, terrain_setting, processor)
    rotation = rotation or 0
    rotation_origin = rotation_origin or pos
    processor = processor or nil

    local schematic
    if binary == "true" then
        schematic = vlf_structure_block.load_vlfschem(file_name, worldpath)
    elseif binary == "false" then
        schematic = vlf_structure_block.load_vlfschem_nb(file_name, worldpath)
    else
        schematic = vlf_structure_block.load_vlfschem(file_name, worldpath)
    end
    if not schematic then
        minetest.log("error", "Failed to load schematic data. " .. file_name)
        return
    end

    local schematic_size = schematic.size
    local minp, maxp

    local schem_size = (rotation == 90 or rotation == 270)
                   and {x = schematic_size.z, y = schematic_size.y, z = schematic_size.x}
                   or schematic_size

    local min_offset = vector.new(0, 0, 0)
    local max_offset = vector.new(schem_size.x, schem_size.y, schem_size.z)

    minp = vector.add(pos, min_offset)
    maxp = vector.add(pos, max_offset)

    if minp.x > maxp.x then minp.x, maxp.x = maxp.x, minp.x end
    if minp.y > maxp.y then minp.y, maxp.y = maxp.y, minp.y end
    if minp.z > maxp.z then minp.z, maxp.z = maxp.z, minp.z end

    --minetest.log("error", "Schematic " .. file_name .. " bounds: minp=" .. minetest.pos_to_string(minp) .. ", maxp=" .. minetest.pos_to_string(maxp) .. "Schematic rotation: " .. tostring(rotation))

    if not load_area(minp, maxp) then
        return
    end

    local nodes_by_type = {}
    local metadata = {}

        if terrain_setting == "terrain_matching" then
        local highest_pos = nil

        -- Check from 40 blocks above down to pos
        for offset = 40, 0, -1 do
            local check_pos = vector.add(pos, vector.new(0, offset, 0))
            local check_node = minetest.get_node(check_pos)
            if minetest.registered_nodes[check_node.name].walkable then
                highest_pos = check_pos
                break  -- Take the first solid node from the top
            end
        end

        -- If no solid node was found above, check from pos down to -80
        if not highest_pos then
            for offset = 0, 80 do
                local check_pos = vector.add(pos, vector.new(0, -offset, 0))
                local check_node = minetest.get_node(check_pos)
                if minetest.registered_nodes[check_node.name].walkable then
                    highest_pos = check_pos
                    break  -- Take the first solid node below
                end
            end
        end

        -- If we found a valid position, update the Y-coordinate of the schematic block
        if highest_pos then
            pos.y = highest_pos.y
        end
    elseif terrain_setting == "rigid" and pos.y > 0 then
        --mcl_util.create_ground_turnip(pos, schematic.size.x / 2, 5)
        local center_pos = vector.add(pos, vector.new(schematic.size.x / 2, 0, schematic.size.z / 2))
        mcl_util.create_ground_turnip(center_pos, schematic.size.x / 2, 5)
    end


    for _, node in ipairs(schematic.nodes) do
        local rotated_pos = rotate_position(node.pos, rotation, rotation_origin)
        local node_pos = vector.add(pos, rotated_pos)
        local rotated_param2 = rotate_param2(node.param2 or 0, rotation)

        -- Adjust the Y-coordinate of the schematic block to match the terrain
        if terrain_setting == "terrain_matching" then
            local highest_pos = nil
            for offset = 1, 80 do
                local up_pos = vector.add(node_pos, vector.new(0, offset, 0))
                local down_pos = vector.add(node_pos, vector.new(0, -offset, 0))

                -- Check upwards (find highest solid node)
                if not highest_pos then
                    local up_node = minetest.get_node(up_pos)
                    if minetest.registered_nodes[up_node.name].walkable then
                        highest_pos = up_pos
                    end
                end

                -- Check downwards (find solid node within the allowed depth range)
                if not highest_pos then
                    local down_node = minetest.get_node(down_pos)
                    if minetest.registered_nodes[down_node.name].walkable then
                        highest_pos = down_pos
                    end
                end
            end

            -- If we found a valid position, update the Y-coordinate of the schematic block
            if highest_pos then
                node_pos.y = highest_pos.y + 1
            end
        end

        if processor ~= nil then
            local processed_node = processors.generic_processor(processor, node_pos, node)
            --if processed_node == true then
            if processed_node ~= nil and processed_node ~= "rotted" then
                minetest.set_node(node_pos, {name = processed_node.name, param2 = rotated_param2 or 0})
                goto continue
            elseif processed_node == "rotted" then
				goto continue
            else
                local node_key = node.name .. "_" .. rotated_param2
                if not nodes_by_type[node_key] then
                    nodes_by_type[node_key] = {positions = {}, name = node.name, param2 = rotated_param2}
                end
                table.insert(nodes_by_type[node_key].positions, node_pos)
                if node.metadata and next(node.metadata) then
                    metadata[node_pos] = node.metadata
                end
            end
        end
        --else
            local node_key = node.name .. "_" .. rotated_param2
            if not nodes_by_type[node_key] then
                nodes_by_type[node_key] = {positions = {}, name = node.name, param2 = rotated_param2}
            end
            table.insert(nodes_by_type[node_key].positions, node_pos)
			if node.name == "voxelforge:jigsaw" then
				local meta = minetest.get_meta(node_pos)
				meta:set_string("generate", "true")
			end
            if node.metadata and next(node.metadata) then
                metadata[node_pos] = node.metadata
            end

            ::continue::
        --end
    end

    for _, node_group in pairs(nodes_by_type) do
        local positions = node_group.positions
        local total_positions = #positions
        local max_nodes_per_batch = 20000

        for i = 1, total_positions, max_nodes_per_batch do
            local end_index = math.min(i + max_nodes_per_batch - 1, total_positions)
            local batch_positions = {}
            for j = i, end_index do
                table.insert(batch_positions, positions[j])
            end

            minetest.bulk_set_node(batch_positions, {name = node_group.name, param2 = node_group.param2})

        end
    end

    if next(metadata) then
        set_metadata(metadata)
    end

    if schematic.entities and include_entities == true then
        for _, entity_data in ipairs(schematic.entities) do
            local rotated_pos = rotate_position(entity_data.pos, rotation, rotation_origin)
            local entity_pos = vector.add(pos, rotated_pos)

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
end]]

--[[function vlf_structure_block.place_schematic(pos, file_name, rotation, rotation_origin, binary, worldpath, include_entities, terrain_setting, processor)
    rotation = rotation or 0
    rotation_origin = rotation_origin or pos
    processor = processor or nil

    local schematic = (binary == "true") and vlf_structure_block.load_vlfschem(file_name, worldpath) 
                      or vlf_structure_block.load_vlfschem_nb(file_name, worldpath)
    
    if not schematic then
        minetest.log("error", "Failed to load schematic data: " .. file_name)
        return
    end

    local schematic_size = schematic.size
    local schem_size = (rotation == 90 or rotation == 270) and {x = schematic_size.z, y = schematic_size.y, z = schematic_size.x} or schematic_size
    local minp = vector.add(pos, vector.new(0, 0, 0))
    local maxp = vector.add(pos, vector.new(schem_size.x, schem_size.y, schem_size.z))
    
    if terrain_setting == "terrain_matching" then
        local highest_pos = nil
        for offset = 40, 0, -1 do
            local check_pos = vector.add(pos, vector.new(0, offset, 0))
            local check_node = minetest.get_node(check_pos)
            if minetest.registered_nodes[check_node.name].walkable then
                highest_pos = check_pos
                break
            end
        end
        if not highest_pos then
            for offset = 0, 80 do
                local check_pos = vector.add(pos, vector.new(0, -offset, 0))
                local check_node = minetest.get_node(check_pos)
                if minetest.registered_nodes[check_node.name].walkable then
                    highest_pos = check_pos
                    break
                end
            end
        end
        if highest_pos then
            pos.y = highest_pos.y
        end
    elseif terrain_setting == "rigid" and pos.y > 0 then
        local center_pos = vector.add(pos, vector.new(schematic.size.x / 2, 0, schematic.size.z / 2))
        mcl_util.create_ground_turnip(center_pos, schematic.size.x / 2, 5)
    end
    
    if not load_area(minp, maxp) then return end

    local vm = minetest.get_voxel_manip()
    local emin, emax = vm:read_from_map(minp, maxp)
    local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
    local data = vm:get_data()
    local param2_data = vm:get_param2_data()
    
    local node_ids = {}
    for name, def in pairs(minetest.registered_nodes) do
        node_ids[name] = minetest.get_content_id(name)
    end
    
    local metadata = {}
    for _, node in ipairs(schematic.nodes) do
        local rotated_pos = rotate_position(node.pos, rotation, rotation_origin)
        local node_pos = vector.add(pos, rotated_pos)
        local rotated_param2 = rotate_param2(node.param2 or 0, rotation)
        
        if processor ~= nil then
            local processed_node = processors.generic_processor(processor, node_pos, node)
            if processed_node ~= nil and processed_node ~= "rotted" then
                node.name = processed_node.name
            elseif processed_node == "rotted" then
                goto continue
            end
        end

        if area:containsp(node_pos) then
            local index = area:indexp(node_pos)
            data[index] = node_ids[node.name] or node_ids["air"]
            param2_data[index] = rotated_param2
            
            if node.metadata and next(node.metadata) then
                metadata[node_pos] = node.metadata
            end
        end
        
        ::continue::
    end
    
    vm:set_data(data)
    vm:set_param2_data(param2_data)
    vm:write_to_map()
    vm:update_map()
    
    
    for node_pos, meta_data in pairs(metadata) do
        local meta = minetest.get_meta(node_pos)
        for key, value in pairs(meta_data) do
            meta:set_string(key, value)
        end
        if minetest.get_node(node_pos).name == "voxelforge:jigsaw" then
            meta:set_string("generate", "true")
            vlf_procedural_structures.spawn_struct(node_pos)
        end
    end
    if schematic.entities and include_entities then
        for _, entity_data in ipairs(schematic.entities) do
            local rotated_pos = rotate_position(entity_data.pos, rotation, rotation_origin)
            local entity_pos = vector.add(pos, rotated_pos)

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
end]]

function vlf_structure_block.place_schematic(pos, file_name, rotation, rotation_origin, binary, worldpath, include_entities, terrain_setting, processor)
    rotation = rotation or 0
    rotation_origin = rotation_origin or pos
    processor = processor or nil

    local schematic = (binary == "true") and vlf_structure_block.load_vlfschem(file_name, worldpath) 
                      or vlf_structure_block.load_vlfschem_nb(file_name, worldpath)
    
    if not schematic then
        minetest.log("error", "Failed to load schematic data: " .. file_name)
        return
    end

    local schematic_size = schematic.size
    local schem_size = (rotation == 90 or rotation == 270) and {x = schematic_size.z, y = schematic_size.y, z = schematic_size.x} or schematic_size
    local minp = vector.add(pos, vector.new(-schem_size.x, -schem_size.y, -schem_size.z))
    local maxp = vector.add(pos, vector.new(2 * schem_size.x, 2 * schem_size.y, 2 * schem_size.z))
    
    if terrain_setting == "terrain_matching" then
        local highest_pos = nil
        for offset = 40, 0, -1 do
            local check_pos = vector.add(pos, vector.new(0, offset, 0))
            local check_node = minetest.get_node(check_pos)
            if minetest.registered_nodes[check_node.name].walkable then
                highest_pos = check_pos
                break
            end
        end
        if not highest_pos then
            for offset = 0, 80 do
                local check_pos = vector.add(pos, vector.new(0, -offset, 0))
                local check_node = minetest.get_node(check_pos)
                if minetest.registered_nodes[check_node.name].walkable then
                    highest_pos = check_pos
                    break
                end
            end
        end
        if highest_pos then
            pos.y = highest_pos.y
        end
    elseif terrain_setting == "rigid" and pos.y > 0 then
        local center_pos = vector.add(pos, vector.new(schematic.size.x / 2, 0, schematic.size.z / 2))
        mcl_util.create_ground_turnip(center_pos, schematic.size.x / 2, 5)
    end
    
    if not load_area(minp, maxp) then return end

    local vm = minetest.get_voxel_manip()
    local emin, emax = vm:read_from_map(minp, maxp)
    local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
    local data = vm:get_data()
    local param2_data = vm:get_param2_data()
    
    local node_ids = {}
    for name, def in pairs(minetest.registered_nodes) do
        node_ids[name] = minetest.get_content_id(name)
    end
    
    local metadata = {}
    local constructed_nodes = {}
    for _, node in ipairs(schematic.nodes) do
        local rotated_pos = rotate_position(node.pos, rotation, rotation_origin)
        local node_pos = vector.add(pos, rotated_pos)
        local rotated_param2 = rotate_param2(node.param2 or 0, rotation)
        
        if processor ~= nil then
            local processed_node = processors.generic_processor(processor, node_pos, node)
            if processed_node ~= nil and processed_node ~= "rotted" then
                node.name = processed_node.name
            elseif processed_node == "rotted" then
                goto continue
            end
        end

        if area:containsp(node_pos) then
            local index = area:indexp(node_pos)
            data[index] = node_ids[node.name] or node_ids["air"]
            param2_data[index] = rotated_param2
            
            if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_construct then
                table.insert(constructed_nodes, node_pos)
            end
            
            if node.metadata and next(node.metadata) then
                metadata[node_pos] = node.metadata
            end
        end
        
        ::continue::
    end
    
    vm:set_data(data)
    vm:set_param2_data(param2_data)
    vm:write_to_map()
    vm:update_map()
    
    if next(metadata) then
        set_metadata(metadata)
    end
    
    for node_pos, meta_data in pairs(metadata) do
        local meta = minetest.get_meta(node_pos)
        --[[for key, value in pairs(meta_data) do
            meta:set_string(key, value)
        end]]
        if minetest.get_node(node_pos).name == "voxelforge:jigsaw" then
            meta:set_string("generate", "true")
            vlf_procedural_structures.spawn_struct(node_pos)
        end
    end
    
    for _, node_pos in ipairs(constructed_nodes) do
        local node = minetest.get_node(node_pos)
        if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_construct then
            minetest.registered_nodes[node.name].on_construct(node_pos)
        end
    end
    
    if schematic.entities and include_entities then
        for _, entity_data in ipairs(schematic.entities) do
            local rotated_pos = rotate_position(entity_data.pos, rotation, rotation_origin)
            local entity_pos = vector.add(pos, rotated_pos)

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





vlf_structure_block.schematic_bounds = {}

function vlf_structure_block.get_bounding_box(pos, file_name, rotation, rotation_origin, binary, worldpath)
    rotation = rotation or 0
    rotation_origin = rotation_origin or pos

    local schematic
    if binary == "true" then
        schematic = vlf_structure_block.load_vlfschem(file_name, worldpath)
    elseif binary == "false" then
        schematic = vlf_structure_block.load_vlfschem_nb(file_name, worldpath)
    else
        schematic = vlf_structure_block.load_vlfschem(file_name, worldpath)
    end
    if not schematic then
        minetest.log("error", "Failed to load schematic data." .. file_name)
        return
    end

    local nodes_by_type = {}
    local minp, maxp

    for _, node in ipairs(schematic.nodes) do
        local rotated_pos = rotate_position(node.pos, rotation, rotation_origin)
        local node_pos = vector.add(pos, rotated_pos)

        if not minp or not maxp then
            minp = vector.new(node_pos)
            maxp = vector.new(node_pos)
        else
            minp = vector.new(math.min(minp.x, node_pos.x), math.min(minp.y, node_pos.y), math.min(minp.z, node_pos.z))
            maxp = vector.new(math.max(maxp.x, node_pos.x), math.max(maxp.y, node_pos.y), math.max(maxp.z, node_pos.z))
        end

        local rotated_param2 = rotate_param2(node.param2 or 0, rotation)
        local node_key = node.name .. "_" .. rotated_param2

        if not nodes_by_type[node_key] then
            nodes_by_type[node_key] = {positions = {}, name = node.name, param2 = rotated_param2}
        end
        table.insert(nodes_by_type[node_key].positions, node_pos)

    end

    local result = "good"

    for existing_file, bounds in pairs(vlf_structure_block.schematic_bounds) do
        if not (maxp.x <= bounds.minp.x or minp.x >= bounds.maxp.x or
                maxp.y <= bounds.minp.y or minp.y >= bounds.maxp.y or
                maxp.z <= bounds.minp.z or minp.z >= bounds.maxp.z) then
            if not (minp.x >= bounds.minp.x and maxp.x <= bounds.maxp.x and
                    minp.y >= bounds.minp.y and maxp.y <= bounds.maxp.y and
                    minp.z >= bounds.minp.z and maxp.z <= bounds.maxp.z) then
                --minetest.log("error", "Schematic placement for " .. file_name .. " overlaps with " .. existing_file .. ". Aborting placement.")
                result = "bad"
                return result
            end
        end
    end

    vlf_structure_block.schematic_bounds[file_name] = {minp = minp, maxp = maxp}
    --minetest.log("error", "Schematic " .. file_name .. " bounds: minp=" .. minetest.pos_to_string(minp) .. ", maxp=" .. minetest.pos_to_string(maxp) .. " Schematic rotation: " .. tostring(rotation))
    return result
end


dofile(cpath .. "/structure_block.lua")
