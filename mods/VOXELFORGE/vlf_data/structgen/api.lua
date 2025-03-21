local json = minetest.parse_json
vlf_structures.registered_structures = {}

local disabled_structures = minetest.settings:get("mcl_disabled_structures")
if disabled_structures then	
    disabled_structures = disabled_structures:split(",")
else 
    disabled_structures = {} 
end

local logging = minetest.settings:get_bool("mcl_logging_structures", true)
local rotations = { "0", "90", "180", "270" }
local EMPTY_SCHEMATIC = { size = {x = 0, y = 0, z = 0}, data = {} }

function vlf_structures.is_disabled(structname)
    return table.indexof(disabled_structures, structname) ~= -1
end

function vlf_structures.load_json_from_path(path)
    local file = io.open(path, "r")
    if file then
        local content = file:read("*all")
        file:close()
        return json(content)
    end
    return nil
end

local ruined_portal_schematics = {
    [1] = "data/voxelforge/structure/trial_chambers/corridor/end_1.gamedata",
    [2] = "data/voxelforge/structure/trial_chambers/corridor/end_2.gamedata",
}

function vlf_structures.load_structure_data()
    local worldpath = minetest.get_worldpath() .. "/data/voxelforge/worldgen/structure_set/"
    local modpath = minetest.get_modpath("vlf_data") .. "/data/voxelforge/worldgen/structure_set/"
    local world_files = minetest.get_dir_list(worldpath, false)
    local mod_files = minetest.get_dir_list(modpath, false)
    local loaded_files = {}
    
    -- Load structures from worldpath first (priority)
    for _, filename in ipairs(world_files) do
        local data = vlf_structures.load_json_from_path(worldpath .. filename)
        if data and data.placement and data.structures then
            for _, structure in ipairs(data.structures) do
                vlf_structures.register_structure(structure.structure, data, false)
            end
            loaded_files[filename] = true
        end
    end
    
    -- Load structures from modpath only if not already in worldpath
    for _, filename in ipairs(mod_files) do
        if not loaded_files[filename] then
            local data = vlf_structures.load_json_from_path(modpath .. filename)
            if data and data.placement and data.structures then
                for _, structure in ipairs(data.structures) do
                    vlf_structures.register_structure(structure.structure, data, false)
                end
            end
        end
    end
end

function vlf_structures.get_structure_file(structure_type)
    local filename = structure_type:gsub("minecraft:", "")
    local worldpath = minetest.get_worldpath() .. "/data/voxelforge/worldgen/structure/"
    local modpath = minetest.get_modpath("vlf_data") .. "/data/voxelforge/worldgen/structure/"
    
    local world_files = minetest.get_dir_list(worldpath, false)
    local mod_files = minetest.get_dir_list(modpath, false)
    
    if table.indexof(world_files, filename .. ".json") ~= -1 then
        return vlf_structures.load_json_from_path(worldpath .. filename .. ".json")
    elseif table.indexof(mod_files, filename .. ".json") ~= -1 then
        return vlf_structures.load_json_from_path(modpath .. filename .. ".json")
    end
    return nil
end

function vlf_structures.select_weighted_random(setups, pr)
    local total_weight = 0
    for _, setup in ipairs(setups) do
        total_weight = total_weight + (setup.weight or 1)
    end
    local choice = pr:next(1, total_weight)
    local cumulative = 0
    for _, setup in ipairs(setups) do
        cumulative = cumulative + (setup.weight or 1)
        if choice <= cumulative then
            return setup
        end
    end
    return setups[1]
end

function vlf_structures.pick_ruined_portal_schematic(pr)
    if #ruined_portal_schematics == 0 then return nil end
    local index = (pr:next() % #ruined_portal_schematics) + 1
    return ruined_portal_schematics[index]
end

function vlf_structures.place_schematic(pos, schematic, rotation, replacements, def, force_placement, flags, after_placement_callback, pr, data)
    vlf_structure_block.place_schematic(pos, schematic, 0, pos, "true", def.wom or "false", 
        def.include_entities or true, def.terrain_setting or "rigid", def.processor or nil, data)
    return true
end

function vlf_structures.place_structure(pos, def, pr, blockseed)
    if not def then return end
    local log_enabled = logging and not def.terrain_feature
    local y_offset = type(def.y_offset) == "function" and def.y_offset(pr) or (def.y_offset or 0)
    local pp = vector.offset(pos, 0, y_offset, 0)
    local sf

    -- Log the def details
    if log_enabled then
        minetest.log("error", "[mcl_structures] Attempting to place structure: " .. def.name .. " with definition: " .. minetest.serialize(def))
    end
    
    if def.solid_ground and def.sidelen then
        local ground_p1 = vector.offset(pos, -def.sidelen/2, -1, -def.sidelen/2)
        local ground_p2 = vector.offset(pos, def.sidelen/2, -1, def.sidelen/2)
        local solid = minetest.find_nodes_in_area(ground_p1, ground_p2, {"group:solid"})
        if #solid < (def.sidelen * def.sidelen) then
            if def.make_foundation then
                mcl_util.create_ground_turnip(vector.offset(pos, 0, -1, 0), def.sidelen, def.sidelen)
            else
                if log_enabled then
                    minetest.log("error", "[mcl_structures] " .. def.name .. " not placed. No solid ground.")
                end
                return false
            end
        end
    end
    
    if def.on_place and not def.on_place(pos, def, pr, blockseed) then
        if log_enabled then
            minetest.log("error", "[mcl_structures] " .. def.name .. " not placed. Conditions not satisfied.")
        end
        return false
    end
    
    local structure_data
    local structure_name
    for _, structure in ipairs(def.structures) do
        sf = structure.structure
    end
    structure_data = vlf_structures.get_structure_file(sf)
    if structure_data.type == "minecraft:ruined_portal" then
        structure_name = vlf_structures.pick_ruined_portal_schematic(pr)
    else
        structure_name = "data/voxelforge/structure/pillager_outpost/base_plate.gamedata"
    end

    -- Output the structure data content
    if structure_data then
        -- Log or output structure content
        minetest.log("error", "[mcl_structures] Structure data content for " .. def.name .. ": " .. minetest.serialize(structure_data))
        
        --local rot = rotations[pr:next(1, #rotations)]
        -- Pass the structure data directly to place_schematic
        vlf_structures.place_schematic(pp, structure_name, 0, def.replacements, def, true, "place_center_x,place_center_z", pr, structure_data)
        
        if log_enabled then
            minetest.log("error", "[mcl_structures] " .. def.name .. " placed at " .. minetest.pos_to_string(pp))
        end
        return true
    end
    
    if log_enabled then
        minetest.log("error", "[mcl_structures] placing " .. def.name .. " failed at " .. minetest.pos_to_string(pos))
    end
    return false
end

-- Function to get biomes by tag
function vlf_structures.get_biomes_by_tag(tag)
    local matching_biomes = {}

    -- Iterate through all registered biomes
    for biome_name, biome_data in pairs(minetest.registered_biomes) do
        -- Check if the biome has a matching tag
        if biome_data.tags then
            for _, biome_tag in ipairs(biome_data.tags) do
                if biome_tag == tag then
                    -- If the tag matches, add the biome to the matching_biomes list
                    table.insert(matching_biomes, biome_name)
                    break  -- Stop searching tags for this biome if a match is found
                end
            end
        end
    end

    return matching_biomes
end



function vlf_structures.register_structure(name, def, nospawn)
    if vlf_structures.is_disabled(name) then return end
    
    local flags = def.flags or "place_center_x, place_center_z, force_placement"
    def.name = name
    local structure_data = vlf_structures.get_structure_file(def.name)
    
    -- Log the def details at the registration step
    minetest.log("error", "[mcl_structures] Registering structure: " .. name .. " with definition: " .. minetest.serialize(def))
    
    def.noise_params = {
        offset = 0,
        scale = def.placement.separation / 100 / 100 / 100,
        spread = {x = def.placement.spacing * 10, y = def.placement.spacing * 10, z = def.placement.spacing * 10},
        seed = def.placement.salt,
        octaves = 1,
        persist = 0.5
    }

    -- Function to process and get biomes based on tags
    local function process_biomes(biomes_str)
        local processed_biomes = {}
        for biome in string.gmatch(biomes_str, "[^,]+") do  -- Split biomes by commas
            biome = biome:match("^%s*(.-)%s*$")  -- Trim leading/trailing spaces
            if string.match(biome, "#minecraft:") then
                -- Use the tag directly (no need to remove the '#minecraft:')
                local tag = biome  -- Tag includes '#minecraft:'
                
                -- Fetch registered biomes that match this tag
                local registered_biomes = vlf_structures.get_biomes_by_tag(tag)  -- Assume this function exists to get biomes by tag

                -- Add matching biomes to the list
                for _, registered_biome in ipairs(registered_biomes) do
                    table.insert(processed_biomes, registered_biome)
                end
            else
                -- If the biome doesn't have a tag, just add it directly
                --table.insert(processed_biomes, biome)
            end
        end
        return processed_biomes
    end

    -- Process biomes from structure data (as a string)
    local biomes = process_biomes(structure_data.biomes)

    if not nospawn then
        minetest.register_on_mods_loaded(function()
            def.deco = minetest.register_decoration({
                name = "vlf_structures:" .. name,
                deco_type = "schematic",
                schematic = EMPTY_SCHEMATIC,
                place_on = "mcl_core:dirt_with_grass",
                --spawn_by = def.spawn_by,
                --num_spawn_by = def.num_spawn_by,
                sidelen = 80,
                --fill_ratio = def.fill_ratio or 1.1 / 80 / 80,
                noise_params = def.noise_params,
                flags = flags,
                biomes = biomes,  -- Use processed biomes here
                y_max = 100,
                y_min = 0
            })
            def.deco_id = minetest.get_decoration_id("vlf_structures:" .. name)
            minetest.set_gen_notify({decoration = true}, {def.deco_id})
        end)
    end
    
    vlf_structures.registered_structures[name] = def
end


vlf_structures.load_structure_data()
