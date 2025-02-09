local modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(modpath.."/mcl_trees.lua")
dofile(modpath.."/mcl_doors.lua")
dofile(modpath.."/mcl_tools.lua")
dofile(modpath.."/mcl_dyes.lua")
dofile(modpath.."/mcl_copper.lua")
dofile(modpath.."/mcl_stairs.lua")
dofile(modpath.."/mcl_crimson.lua")
dofile(modpath.."/mcl_armor.lua")
dofile(modpath.."/mcl_panes.lua")
dofile(modpath.."/mcl_bamboo.lua")
dofile(modpath.."/mesecons.lua")


minetest.register_chatcommand("place_all_blocks", {
    description = "Places all registered blocks in a square around you",
    privs = {server = true}, -- Adjust privileges as needed
    func = function(name)
        local player = minetest.get_player_by_name(name)
        if not player then
            return false, "Player not found!"
        end
        
        local pos = vector.round(player:get_pos())
        local nodes = {}
        for nodename in pairs(minetest.registered_nodes) do
            table.insert(nodes, nodename)
        end
        
        -- Square placement logic
        local side_length = math.ceil(math.sqrt(#nodes))
        local index = 1
        for x = 0, side_length - 1 do
            for z = 0, side_length - 1 do
                if index > #nodes then break end
                local block_pos = {x = pos.x + x, y = pos.y, z = pos.z + z}
                minetest.set_node(block_pos, {name = nodes[index]})
                index = index + 1
            end
        end
        
        return true, "Placed " .. #nodes .. " blocks in a square around your position."
    end,
})


local pos1, pos2 = nil, nil

minetest.register_chatcommand("set_pos1", {
    description = "Set the first position for the area check",
    privs = {server = true}, -- Adjust privileges if needed
    func = function(name)
        local player = minetest.get_player_by_name(name)
        if not player then
            return false, "Player not found!"
        end

        pos1 = vector.round(player:get_pos())
        return true, "Position 1 set to " .. minetest.pos_to_string(pos1)
    end,
})

minetest.register_chatcommand("set_pos2", {
    description = "Set the second position for the area check",
    privs = {server = true}, -- Adjust privileges if needed
    func = function(name)
        local player = minetest.get_player_by_name(name)
        if not player then
            return false, "Player not found!"
        end

        pos2 = vector.round(player:get_pos())
        return true, "Position 2 set to " .. minetest.pos_to_string(pos2)
    end,
})

minetest.register_chatcommand("find_unregistered_blocks", {
    description = "Find all unregistered blocks in the selected area and save to file",
    privs = {server = true}, -- Adjust privileges if needed
    func = function(name)
        if not pos1 or not pos2 then
            return false, "Please set both positions with /set_pos1 and /set_pos2 first."
        end

        local minp = vector.new(
            math.min(pos1.x, pos2.x),
            math.min(pos1.y, pos2.y),
            math.min(pos1.z, pos2.z)
        )
        local maxp = vector.new(
            math.max(pos1.x, pos2.x),
            math.max(pos1.y, pos2.y),
            math.max(pos1.z, pos2.z)
        )

        local unregistered_nodes = {}
        for x = minp.x, maxp.x do
            for y = minp.y, maxp.y do
                for z = minp.z, maxp.z do
                    local pos = {x = x, y = y, z = z}
                    local node = minetest.get_node_or_nil(pos)
                    if node and not minetest.registered_nodes[node.name] then
                        unregistered_nodes[node.name] = true
                    end
                end
            end
        end

        local file_path = minetest.get_worldpath() .. "/unregistered_blocks.txt"
        local file = io.open(file_path, "w")
        if not file then
            return false, "Failed to open file for writing."
        end

        for block_name in pairs(unregistered_nodes) do
            file:write(block_name .. "\n")
        end
        file:close()

        return true, "Unregistered blocks saved to " .. file_path
    end,
})


minetest.register_on_mods_loaded(function()
    local count = 0
    for node_name, _ in pairs(minetest.registered_nodes) do
        if node_name:sub(1, 3) == "mcl" then
            local alias_name = "vlf" .. node_name:sub(4) -- Replace "vlf:" with "mcl:"
            minetest.register_alias(alias_name, node_name)
            count = count + 1
        end
    end

    -- Log success message
    if count > 0 then
        minetest.log("error", "[Alias Creator] Registered " .. count .. " aliases from 'vlf:' to 'mcl:'.")
    else
        minetest.log("error", "[Alias Creator] No 'mcl:' nodes found to alias.")
    end
end)
