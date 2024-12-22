-- game_mode_selector/init.lua

local function write_hardcore_lock(reason)
    local file = io.open(minetest.get_worldpath() .. "/hardcore_lock.txt", "w")
    if file then
        file:write(reason)
        file:close()
    end
end

local function is_world_locked()
    local file = io.open(minetest.get_worldpath() .. "/hardcore_lock.txt", "r")
    if file then
        file:close()
        return true
    end
    return false
end

minetest.register_on_dieplayer(function(player)
    local player_name = player:get_player_name()
    local meta = player:get_meta()

    if meta:get_string("gamemode") == "hardcore" then
        minetest.chat_send_all(player_name .. " has died in Hardcore Mode. The world is now permanently closed!")

        -- Lock the world and shut down the server
        write_hardcore_lock("This world has been locked due to a hardcore death.")
        minetest.request_shutdown("Hardcore death: World permanently closed.", true)
    end
end)

minetest.register_on_prejoinplayer(function(name, ip)
    if is_world_locked() then
        return "This world is locked. You only had one life in Hardcore Mode."
    end
end)

minetest.register_on_joinplayer(function(player)
    local meta = player:get_meta()
    local player_name = player:get_player_name()

    -- Assign hardcore meta if not already set
    if not meta:get_string("gamemode") or meta:get_string("gamemode") == "" then
        meta:set_string("gamemode", "creative")
    end
end)
