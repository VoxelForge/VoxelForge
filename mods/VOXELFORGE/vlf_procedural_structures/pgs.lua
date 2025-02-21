local modpath = minetest.get_modpath("vlf_procedural_structures")
local mpath = minetest.get_modpath("vlf_structure_block")
local Randomizer = dofile(minetest.get_modpath("vlf_lib").."/init.lua")

local json = minetest.parse_json

local function spawn_struct(pos)
    local pos_hash_1 = minetest.hash_node_position(pos, terrain_match)
    local blockseed_1 = minetest.get_mapgen_setting("seed")
    local seed_1 = pos_hash_1 + blockseed_1
    local rng = PcgRandom(seed_1)
    local pos_hash = minetest.hash_node_position({x = pos.x * 256 * 8, y = pos.y * 12, z = pos.z * 18})
    local blockseed = minetest.get_mapgen_setting("seed")
    local seed = pos_hash + blockseed + minetest.hash_node_position({x = pos.x * rng:next(1, 47), y = pos.y * rng:next(1, 49), z = pos.z * rng:next(1, 45)}) -- For better randomization
    local rng = Randomizer.new(pos_hash, blockseed)
    local meta = minetest.get_meta(pos)
    local pool = meta:get_string("pool")
    local name = meta:get_string("name")
    local target = meta:get_string("target")
    local final_state = meta:get_string("final_state")
    local levels = tonumber(meta:get_string("levels")) or 0
    local joint_type = meta:get_string("joint_type")
    local param2 = minetest.get_node(pos).param2
    local projection

    local offsets = {
        [0] = vector.new(0, 0, 1),    -- North-facing
        [1] = vector.new(1, 0, 0),    -- East-facing
        [2] = vector.new(0, 0, -1),   -- South-facing
        [3] = vector.new(-1, 0, 0),   -- West-facing
        [6] = vector.new(0, 1, 0),    -- Upward-facing
        [8] = vector.new(0, 1, 0),    -- Upward-facing
        [15] = vector.new(0, 1, 0),   -- Upward-facing
        [17] = vector.new(0, 1, 0),   -- Upward-facing
        [4] = vector.new(0, -1, 0),   -- Downward-facing
        [10] = vector.new(0, -1, 0),  -- Downward-facing
        [13] = vector.new(0, -1, 0),  -- Downward-facing
        [19] = vector.new(0, -1, 0),  -- Downward-facing
    }

    local rotations = {
        -- Normal
        [0] = { [2] = 0 },
        [1] = { [3] = 0 },
        [2] = { [0] = 0 },
        [3] = { [1] = 0 },
        -- Up
        [6] = { [4] = 0, [19] = 90, [10] = 180, [13] = 270 },
        [8] = { [4] = 180, [19] = 270, [10] = 0, [13] = 90},
        [15] = { [4] = 90, [19] = 180, [10] = 270, [13] = 0 },
        [17] = { [19] = 0, [4] = 270, [10] = 90, [13] = 180},
        -- Down 
        [4] = { [6] = 0, [8] = 180, [15] = 90, [17] = 270},
        [10] = { [6] = 180, [8] = 0, [15] = 270, [17] = 90},
        [13] = { [6] = 90, [8] = 270, [15] = 0, [17] = 180},
        [19] = { [6] = 270, [8] = 90, [15] = 180, [17] = 0},
        -- Hybrid
        [0] = { [3] = 270, [1] = 90, [0] = 180 },
        [1] = { [2] = 90, [0] = 270, [1] = 180 },
        [2] = { [1] = 270, [3] = 90, [2] = 180 },
        [3] = { [2] = 270, [3] = 180, [0] = 90 },
    }

    local real_pool = pool:gsub("voxelforge:", "")
    local json_path = mpath .. "/data/voxelforge/worldgen/template_pool/" .. real_pool .. ".json"
    local file = io.open(json_path, "r")
    if not file then
        return
    end

    local json_content = file:read("*a")
    file:close()

    local pool_data = json(json_content)
    if not pool_data then
        return
    end

    local elements = pool_data.elements
    if not elements or #elements == 0 then
        return
    end

    local fallback_pool = pool_data.fallback
    if fallback_pool then
        fallback_pool = fallback_pool:gsub("voxelforge:", "")
    end

    local valid_schematics = {}
    local total_weight = 0

    local function process_elements(elements)
        for _, element_entry in ipairs(elements) do
            local element = element_entry.element
            local weight = element_entry.weight or 1
            if not element.location then
                table.insert(valid_schematics, {schematic = nil, weight = weight})
                total_weight = total_weight + weight
            else
            	projection = element_entry.element.projection or "rigid"
                local location = element.location:gsub("minecraft:", "")
                local base_name = location:gsub("%.gamedata$", "")
                local selecting_schematic = "data/voxelforge/structure/" .. base_name .. ".gamedata"
                minetest.log("error", "selected schematic:" .. selecting_schematic.." projection: " .. projection)

                local schematic_data = vlf_structure_block.load_vlfschem(selecting_schematic, false)
                if not schematic_data then
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
                    table.insert(valid_schematics, {schematic = selecting_schematic, weight = weight})
                    total_weight = total_weight + weight
                end
            end
        end
    end

    process_elements(elements)

    if #valid_schematics == 0 then
        if fallback_pool then
            local fallback_json_path = mpath .. "data/voxelforge/worldgen/template_pool/" .. fallback_pool .. ".json"
            local fallback_file = io.open(fallback_json_path, "r")
            if not fallback_file then
                return
            end

            local fallback_json_content = fallback_file:read("*a")
            fallback_file:close()

            local fallback_pool_data = json(fallback_json_content)
            if not fallback_pool_data then
                return
            end

            elements = fallback_pool_data.elements
            if not elements or #elements == 0 then
                return
            end

            valid_schematics = {}
            total_weight = 0
            process_elements(elements)

            if #valid_schematics == 0 then
                return
            end
        else
            return
        end
    end

    while #valid_schematics > 0 do
        local selected_weight = rng:random(1, total_weight)
        local cumulative_weight = 0
        local selected_schematic = nil

        for i, schematic_data in ipairs(valid_schematics) do
            cumulative_weight = cumulative_weight + schematic_data.weight
            if selected_weight <= cumulative_weight then
                selected_schematic = schematic_data.schematic
                table.remove(valid_schematics, i)  -- Remove the selected schematic to avoid re-selection
                total_weight = total_weight - schematic_data.weight
                break
            end
        end

        if not selected_schematic then
            minetest.set_node(pos, {name = final_state})
            return
        end

        local offset = offsets[param2] or vector.new(0, 0, 0)
        local target_param2 = 0
        local target_pos

        local schematic_data = vlf_structure_block.load_vlfschem(selected_schematic, false)
        if not schematic_data then
            return
        end

        for _, node in ipairs(schematic_data.nodes) do
            if node.metadata and node.metadata.name == target then
                target_pos = node.pos
                target_param2 = node.param2
                break
            end
        end

        if not target_pos then
            return
        end
        
        local rot = rotations[param2] and rotations[param2][target_param2] or 0
        local placement_pos = vector.add(pos, vector.subtract(offset, target_pos))

    	if vlf_structure_block.get_bounding_box(placement_pos, selected_schematic, rot, target_pos,"true", false) == "good" then

            vlf_structure_block.place_schematic(placement_pos, selected_schematic, rot, target_pos,"true", false, true, projection)
            minetest.set_node(pos, {name = final_state})
            local place_pos = pos + offset
            local target_node_meta = minetest.get_meta(place_pos)
            local target_final_state = target_node_meta:get_string("final_state")
            if target_final_state and target_final_state ~= "" then
                minetest.set_node(place_pos, {name = target_final_state})
            end
            return
        end
    end
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
       -- minetest.after(0.01, function()
        minetest.after(1, function()
        if node.name == "voxelforge:jigsaw" then
            meta:set_string("generate", "true")
            local generate = meta:get_string("generate")
            if generate == "true" then
            	spawn_struct(pos, false)
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

minetest.register_chatcommand("place_po", {
	params = "",
	description = "Test for Procedural Structures.",
	func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then
            return false, "Player not found."
        end

        local pos = player:get_pos()
		vlf_structure_block.place_schematic(pos, "data/voxelforge/structure/pillager_outpost/base_plate.gamedata", 0, pos, "true", false, true, "terrain_matching")
	end
})

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

local function place_all_schematics_in_directory(mopath, directory, pos_start, player_name, binary, file)
    local function place_schematics_in_dir(dir, pos, binary)
        local items = minetest.get_dir_list(dir, false) -- Get all items (files and directories)

        -- Sort items alphabetically
        table.sort(items)

        minetest.log("action", "Scanning directory: " .. dir)
        for _, item in ipairs(items) do
            if item:match("%.gamedata$") then  -- Check if the file has .gamedata extension
                local filepath = directory .. "/" .. item
                if is_file(mopath.."/"..filepath) then
                    minetest.log("error", "Found schematic file: " .. filepath)
                    local fpath = mopath .. dir .. DIR_DELIM .. item
                    local schematic = vlf_structure_block.load_vlfschem(filepath, false)

                    if not schematic then
                        minetest.log("error", "Failed to load schematic data: " .. fpath)
                    else
                        -- Calculate the size of the schematic for positioning
                        local schematic_size = {
                            x = schematic.size.x,
                            y = schematic.size.y,
                            z = schematic.size.z
                        }

                        -- Place the schematic
                        vlf_structure_block.place_schematic(pos, filepath, 0, pos, "true", false, true)
                        minetest.log("error", "Placed schematic at position: " .. minetest.pos_to_string(pos))

                        -- Determine the position for the voxelforge:schematic_editor block
                        local editor_pos = {
                            x = pos.x,
                            y = pos.y - 1,                    -- One node below
                            z = pos.z
                        }

                        -- Place the voxelforge:schematic_editor block
                        minetest.set_node(editor_pos, {name = "voxelforge:structure_block"})

                        -- Set metadata for the schematic_editor block
                        local meta = minetest.get_meta(editor_pos)
                        meta:set_string("filename", item)
                        meta:set_string("sx", schematic.size.x)
                        meta:set_string("sy", schematic.size.y)
                        meta:set_string("sz", schematic.size.z)
                        meta:set_string("ox", 0)
                        meta:set_string("oy", 1)
                        meta:set_string("oz", 0)

                        vlf_structure_block.mark_borders(editor_pos, {
                            x = schematic.size.x, y = schematic.size.y, z = schematic.size.z
                        }, {
                            x = 0, y = 1, z = 0
                        })

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
                    minetest.log("error", "Skipped non-schematic file: " .. filepath)
                end
            else
                minetest.log("action", "Skipped non-gamedata file: " .. item)
            end
        end

        return pos
    end

    local final_pos = place_schematics_in_dir(mopath.."/"..directory, pos_start, binary)
    return final_pos
end

minetest.register_chatcommand("place_schematics", {
    params = "",
    description = "Place all trial chamber schematics",
    func = function(name)
        local schematic_positions = {
            --{x=0, y=100, z=0, path="data/voxelforge/structure/trial_chambers/chamber", extra="false"},
            --{x=40, y=100, z=0, path="data/voxelforge/structure/trial_chambers/chamber/addon"},
            --{x=60, y=100, z=0, path="data/voxelforge/structure/trial_chambers/chamber/assembly"},
            --{x=100, y=100, z=0, path="data/voxelforge/structure/trial_chambers/chamber/eruption"},
            --{x=160, y=100, z=0, path="data/voxelforge/structure/trial_chambers/chamber/pedestal"},
           -- {x=200, y=100, z=0, path="data/voxelforge/structure/trial_chambers/chamber/slanted"},
            --{x=-10, y=100, z=0, path="data/voxelforge/structure/trial_chambers/chests"},
           -- {x=-10, y=100, z=10, path="data/voxelforge/structure/trial_chambers/chests/connectors"},
           -- {x=-40, y=100, z=0, path="data/voxelforge/structure/trial_chambers/corridor"},
           -- {x=-70, y=100, z=0, path="data/voxelforge/structure/trial_chambers/corridor/atrium"},
           -- {x=-100, y=100, z=0, path="data/voxelforge/structure/trial_chambers/corridor/addon"},
           -- {x=-120, y=100, z=0, path="data/voxelforge/structure/trial_chambers/decor"},
           -- {x=-140, y=100, z=0, path="data/voxelforge/structure/trial_chambers/dispensers"},
           -- {x=-170, y=100, z=0, path="data/voxelforge/structure/trial_chambers/hallway"},
           -- {x=-200, y=100, z=0, path="data/voxelforge/structure/trial_chambers/intersection"},
           -- {x=-220, y=100, z=0, path="data/voxelforge/structure/trial_chambers/reward"},
            {x=-230, y=100, z=0, path="data/voxelforge/structure/trial_chambers/spawner/breeze"},
            {x=-240, y=100, z=0, path="data/voxelforge/structure/trial_chambers/spawner/connectors"},
            {x=-250, y=100, z=0, path="data/voxelforge/structure/trial_chambers/spawner/melee"},
            {x=-260, y=100, z=0, path="data/voxelforge/structure/trial_chambers/spawner/ranged"},
            {x=-270, y=100, z=0, path="data/voxelforge/structure/trial_chambers/spawner/slow_ranged"},
            {x=-280, y=100, z=0, path="data/voxelforge/structure/trial_chambers/spawner/small_melee"},
            --{x=-300, y=100, z=0, path="data/voxelforge/structure/trial_chambers/chamber/assembly"},
        }

        for _, schematic in ipairs(schematic_positions) do
            place_all_schematics_in_directory(mpath, schematic.path, {x=schematic.x, y=schematic.y, z=schematic.z}, nil, "true", ".gamedata")
        end

        return true, "All schematics placed!"
    end,
})

minetest.register_abm({
    nodenames = {"voxelforge:jigsaw"},  -- Only check jigsaw blocks
    interval = 10,  -- Runs every 10 seconds
    chance = 1,  -- Check every block
    action = function(pos, node)
        -- Get the final_state meta field from the node
        local meta = minetest.get_meta(pos)
        local final_state = meta:get_string("final_state")
        
        -- Check if final_state is not empty
        if final_state ~= "" then
            -- Place the final_state block in place of the jigsaw block
            local final_node = minetest.registered_nodes[final_state]
            if final_node then
                minetest.set_node(pos, {name = final_state})
            end
        end
    end,
})


