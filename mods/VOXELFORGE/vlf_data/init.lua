
local cpath = minetest.get_modpath("vlf_data")

dofile(cpath .. "/procedural_structure/pgs.lua")
dofile(cpath .. "/procedural_structure/alias.lua")
dofile(cpath .. "/structure/place.lua")
dofile(cpath .. "/structure_block.lua")
dofile(cpath .. "/structgen/main.lua")

--[[local mod_storage = minetest.get_mod_storage()

-- Ensure vlf_structures exists
vlf_structures = vlf_structures or {}
vlf_structures.registered_structures = vlf_structures.registered_structures or {}

-- Function to get or set structure positions in mod storage
local function get_structure_positions(structure_name)
    local data = mod_storage:get_string(structure_name)
    if data and data ~= "" then
        return minetest.deserialize(data) or {}
    end
    return {}
end

local function save_structure_positions(structure_name, positions)
    mod_storage:set_string(structure_name, minetest.serialize(positions))
end

-- Function to find a valid placement spot
local function find_nearest_structure_pos(player, structure_name)
    local def = vlf_structures.registered_structures[structure_name]
    if not def then
        return nil, "Structure definition not found."
    end

    local spacing = def.spacing or 34
    local separation = def.separation or 12
    local salt = def.salt or 94251327
    
    local player_pos = player:get_pos()
    local grid_x = math.floor(player_pos.x / spacing)
    local grid_z = math.floor(player_pos.z / spacing)
    
    local best_pos = nil
    local min_distance = math.huge
    local existing_positions = get_structure_positions(structure_name)
    
    for dx = -1, 1 do
        for dz = -1, 1 do
            local x = (grid_x + dx) * spacing + (salt % spacing)
            local z = (grid_z + dz) * spacing + (salt % spacing)
            local candidate_pos = {x = x, y = player_pos.y, z = z}
            
            -- Ensure it respects the separation distance
            local too_close = false
            for _, pos in ipairs(existing_positions) do
                if vector.distance(pos, candidate_pos) < separation * 16 then
                    too_close = true
                    break
                end
            end
            
            if not too_close then
                local dist = vector.distance(player_pos, candidate_pos)
                if dist < min_distance then
                    min_distance = dist
                    best_pos = candidate_pos
                end
            end
        end
    end
    
    if best_pos then
        table.insert(existing_positions, best_pos)
        save_structure_positions(structure_name, existing_positions)
    end
    
    return best_pos
end

-- Register chat command to find the nearest placement for a structure
minetest.register_chatcommand("find_structure", {
    params = "<structure_name>",
    description = "Finds the nearest valid placement for a structure",
    func = function(name, param)
        if param == "" then
            return false, "Usage: /find_structure <name>"
        end
        
        local structure_name = param
        local player = minetest.get_player_by_name(name)
        if not player then
            return false, "Player not found."
        end
        
        local pos, err = find_nearest_structure_pos(player, structure_name)
        if pos then
            return true, string.format("Nearest %s location: (%.1f, %.1f, %.1f)", structure_name, pos.x, pos.y, pos.z)
        else
            return false, err or "No valid position found."
        end
    end
})

-- Callback for when a position is loaded
minetest.register_on_generated(function(minp, maxp, seed)
    for structure_name, positions in pairs(vlf_structures.registered_structures) do
        local structure_positions = get_structure_positions(structure_name)
        for _, pos in ipairs(structure_positions) do
            if pos.x >= minp.x and pos.x <= maxp.x and pos.z >= minp.z and pos.z <= maxp.z then
                local def = vlf_structures.registered_structures[structure_name]
                if def then
                    vlf_structures.place_structure(pos, def, minetest.hash_node_position(pos), seed)
                end
            end
        end
    end
end)]]

local mod_storage = minetest.get_mod_storage()

-- Function to get or set structure positions in mod storage
local function get_structure_positions(structure_name)
    local data = mod_storage:get_string(structure_name)
    if data and data ~= "" then
        return minetest.deserialize(data) or {}
    end
    return {}
end

local function save_structure_positions(structure_name, positions)
    mod_storage:set_string(structure_name, minetest.serialize(positions))
end

-- Function to check if the position is valid based on the structure's biomes
local function is_valid_biome(pos, def)
    if def.biomes then
        local biome = minetest.get_biome_name(pos)  -- Get the biome at the position
        for _, biome_name in ipairs(def.biomes) do
            if biome == biome_name then
                return true
            end
        end
        return false
    end
    return true  -- If no biomes are defined, assume valid
end

-- Function to check if a candidate position aligns with existing positions based on separation and spacing
local function is_valid_position(candidate_pos, existing_positions, separation, spacing)
    -- Ensure it respects the separation distance
    for _, pos in ipairs(existing_positions) do
        if vector.distance(pos, candidate_pos) < separation * 16 then
            return false
        end
    end
    -- Check if the position aligns correctly based on the spacing
    local grid_x = math.floor(candidate_pos.x / spacing)
    local grid_z = math.floor(candidate_pos.z / spacing)
    local aligned = math.abs(candidate_pos.x - (grid_x * spacing)) < 1 and math.abs(candidate_pos.z - (grid_z * spacing)) < 1
    if not aligned then
        return false
    end
    return true
end

-- Function to calculate positions and store them in mod storage
local function calculate_and_store_positions()
    -- First, gather all the structure definitions
    local all_positions = {}  -- Stores all the calculated positions

    for structure_name, def in pairs(vlf_structures.registered_structures) do
        local existing_positions = get_structure_positions(structure_name)
        local spacing = def.spacing or 34
        local separation = def.separation or 12
        local seed = def.seed or 94251327  -- Use structure-specific seed, fall back to default

        -- Initialize random number generator with the seed
        math.randomseed(seed)

        local x, z = 0, 0  -- Starting point (0, 0)
        local candidate_pos = {x = x, y = 0, z = z}
        
        -- Start calculating positions from (0, 0, 0)
        while true do
            -- Apply randomization based on seed, spacing, and separation
            local randomized_x = candidate_pos.x + (math.random() * 2 - 1) * (spacing / 2)
            local randomized_z = candidate_pos.z + (math.random() * 2 - 1) * (spacing / 2)
            candidate_pos = {x = randomized_x, y = 0, z = randomized_z}
            
            -- Check if the position is valid
            if is_valid_position(candidate_pos, existing_positions, separation, spacing) and is_valid_biome(candidate_pos, def) then
                -- If valid, add it to the existing positions
                table.insert(existing_positions, candidate_pos)
                -- Store the position in mod storage
                save_structure_positions(structure_name, existing_positions)
                -- Add the position to all positions
                table.insert(all_positions, candidate_pos)
            end

            -- Move to the next potential position (in grid pattern)
            x = x + spacing
            if x >= 1000 then  -- Arbitrary max range to stop the search
                x = 0
                z = z + spacing
            end
            candidate_pos = {x = x, y = 0, z = z}

            -- Exit condition (if you've calculated enough positions or reached an arbitrary limit)
            if #all_positions >= 10 then  -- This can be adjusted to control how many positions are found
                break
            end
        end
    end
end

-- Register chat command to find the nearest placement for a structure
minetest.register_chatcommand("find_structure", {
    params = "<structure_name>",
    description = "Finds the nearest valid placement for a structure",
    func = function(name, param)
        if param == "" then
            return false, "Usage: /find_structure <name>"
        end
        
        local structure_name = param
        local player = minetest.get_player_by_name(name)
        if not player then
            return false, "Player not found."
        end
        
        -- Calculate positions and store them in mod storage if they aren't calculated already
        calculate_and_store_positions()
        
        -- Try to find the nearest valid position after calculating
        local def = vlf_structures.registered_structures[structure_name]
        if not def then
            return false, "Structure definition not found."
        end
        
        local spacing = def.spacing or 34
        local player_pos = player:get_pos()
        
        -- Retrieve all calculated positions
        local existing_positions = get_structure_positions(structure_name)
        
        -- Find the nearest position
        local best_pos = nil
        local min_distance = math.huge
        for _, pos in ipairs(existing_positions) do
            local dist = vector.distance(player_pos, pos)
            if dist < min_distance then
                min_distance = dist
                best_pos = pos
            end
        end

        if best_pos then
            return true, string.format("Nearest %s location: (%.1f, %.1f, %.1f)", structure_name, best_pos.x, best_pos.y, best_pos.z)
        else
            return false, "No valid position found."
        end
    end
})

-- Callback for when a position is loaded
minetest.register_on_generated(function(minp, maxp, seed)
    for structure_name, positions in pairs(vlf_structures.registered_structures) do
        local structure_positions = get_structure_positions(structure_name)
        for _, pos in ipairs(structure_positions) do
            if pos.x >= minp.x and pos.x <= maxp.x and pos.z >= minp.z and pos.z <= maxp.z then
                local def = vlf_structures.registered_structures[structure_name]
                if def then
                    vlf_structures.place_structure(pos, def, minetest.hash_node_position(pos), seed)
                end
            end
        end
    end
end)

minetest.register_chatcommand("get_player_meta", {
    params = "<player_name>",
    description = "Get metadata of an offline player",
    privs = { server = true },  -- Requires server privileges
    func = function(name, param)
        if param == "" then
            return false, "Please provide a player name."
        end

        local function get_offline_playermeta_table(player_name)
            local auth_handler = minetest.get_auth_handler()
            if not auth_handler.get_auth(player_name) then
                return nil, "Player does not exist or has no auth entry."
            end

            local player_meta = minetest.get_player_meta(player_name)
            if not player_meta then
                return nil, "Failed to get player meta."
            end

            -- Convert meta data into a table
            local meta_table = {}
            local keys = player_meta:get_meta_keys()
            
            for _, key in ipairs(keys) do
                meta_table[key] = player_meta:get_string(key)  -- Assuming all data is stored as strings
            end

            return meta_table
        end

        local meta_table, err = get_offline_playermeta_table(param)
        if meta_table then
            minetest.chat_send_player(name, "Metadata for " .. param .. ":")
            for key, value in pairs(meta_table) do
                minetest.chat_send_player(name, key .. " = " .. value)
            end
            return true
        else
            return false, "Error: " .. err
        end
    end
})



