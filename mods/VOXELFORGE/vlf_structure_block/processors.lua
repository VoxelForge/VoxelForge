processors = {} -- Ensure it's a global table
local Randomizer = dofile(minetest.get_modpath("vlf_lib").."/init.lua")

-- Cache parsed JSON files to prevent redundant file reads
local processor_cache = {}

function processors.generic_processor(json_path, pos, node)
    -- Compute randomizer seed
    local pos_hash = minetest.hash_node_position({x = pos.x * 7, y = pos.y * 12, z = pos.z * 18})
    local blockseed = minetest.get_mapgen_setting("seed")
    local rand = Randomizer.new(pos_hash, blockseed)

    -- Return nil if no json_path
    if not json_path then return nil end

    -- Check if JSON is already loaded
    local data = processor_cache[json_path]
    if not data then
        -- Load JSON from file
        local fpath = minetest.get_modpath("vlf_structure_block") .. "/data/voxelforge/worldgen/processor_list/" .. json_path .. ".json"
        local file = io.open(fpath, "r")

        -- Handle file read failure
        if not file then
            minetest.log("error", "Failed to open JSON file: " .. fpath)
            return nil
        end

        local content = file:read("*a")
        file:close()

        -- Parse JSON using Minetest's built-in function
        data, err = minetest.parse_json(content)
        if not data then
            minetest.log("error", "Failed to parse JSON: " .. err)
            return nil
        end

        -- Cache parsed data to avoid reloading the file
        processor_cache[json_path] = data
    end

    if not data.processors then
        minetest.log("error", "Invalid JSON structure: missing 'processors' key")
        return nil
    end

    -- Get node above for location predicate (only needed once)
    local pos_above = {x = pos.x, y = pos.y + 1, z = pos.z}
    local node_above = minetest.get_node(pos_above)

    -- Track the evolving node state
    local current_state = node
    local was_modified = false -- Track if any processor modified the node

    -- Iterate through all processors in order
    for _, processor in ipairs(data.processors) do
        if processor.processor_type == "minecraft:rule" and processor.rules then
            -- Process all rules within this processor **in order**
            for _, rule in ipairs(processor.rules) do
                local input_pred = rule.input_predicate
                local location_pred = rule.location_predicate
                local output_state = rule.output_state

                -- Early exit if output is invalid
                if not output_state or not output_state.Name then
                    minetest.log("error", "Invalid rule output state in processor")
                    break
                end

                -- Check input predicate (does current node match?)
                local matches_input = false
                if input_pred then
                    if input_pred.predicate_type == "minecraft:block_match" then
                        matches_input = (current_state.name == input_pred.block)
                    elseif input_pred.predicate_type == "minecraft:random_block_match" then
                        local probability = input_pred.probability or 1.0
                        local rand_value = rand:random() -- Generate a single random value
                        matches_input = (current_state.name == input_pred.block and rand_value <= probability)
                    end
                end

                -- Check location predicate (does the block above match?)
                local matches_location = false
                if location_pred then
                    if location_pred.predicate_type == "minecraft:block_match" then
                        matches_location = (node_above.name == location_pred.block)
                    elseif location_pred.predicate_type == "minecraft:always_true" then
                        matches_location = true
                    end
                end

                -- Apply the rule if both input and location match
                if matches_input and matches_location then
                    current_state = {name = output_state.Name}
                    was_modified = true -- Mark that a change occurred

                    -- Stop checking further rules in this processor
                    break
                end
            end
        end
    end

    -- If no processors matched, return nil
    return was_modified and current_state or nil
end

