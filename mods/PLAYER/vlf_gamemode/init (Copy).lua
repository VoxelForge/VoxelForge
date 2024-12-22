-- game_mode_selector/init.lua

minetest.register_privilege("hardcore", {
    description = "Allows players to play in hardcore mode",
    give_to_singleplayer = false,
})

-- Open the game mode selection formspec
local function show_game_mode_formspec(player_name)
    minetest.show_formspec(player_name, "game_mode_selector:select_mode", [[
        size[10,6]
        bgcolor[#000000BB;true]
        label[4,0.5;Select Your Game Mode]
        button[1,2;3,1;creative;Creative Mode]
        button[4,2;3,1;survival;Survival Mode]
        button[7,2;3,1;hardcore;Hardcore Mode]
        textarea[1,4;8,1.5;;Info;Creative: Unlimited resources. \nSurvival: Default mode. \nHardcore: Higher difficulty. Reset progress on death.]
    ]])
end

-- Handle the formspec submission
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "game_mode_selector:select_mode" then return end

    local player_name = player:get_player_name()
    if not player_name then return end

    if fields.creative then
        minetest.chat_send_player(player_name, "You selected Creative Mode.")
        minetest.set_player_privs(player_name, {creative = true, interact = true})
        player:set_meta("game_mode", "creative")
    elseif fields.survival then
        minetest.chat_send_player(player_name, "You selected Survival Mode.")
        minetest.set_player_privs(player_name, {interact = true})
        player:set_meta("game_mode", "survival")
    elseif fields.hardcore then
        minetest.chat_send_player(player_name, "You selected Hardcore Mode. Be careful!")
        minetest.set_player_privs(player_name, {interact = true, hardcore = true})
        player:set_meta("game_mode", "hardcore")
        minetest.set_world_setting("hardcore_world", "true")
        minetest.save()
    end

    minetest.close_formspec(player_name, "game_mode_selector:select_mode")
end)

--[[ Register a command to open the formspec
minetest.register_chatcommand("gamemode", {
    description = "Select your game mode",
    func = function(name)
        local player = minetest.get_player_by_name(name)
        if player then
            show_game_mode_formspec(name)
            return true, "Opened game mode selector."
        else
            return false, "Player not found."
        end
    end,
})]]

-- Apply hardcore mode effects on player death
minetest.register_on_dieplayer(function(player)
    local player_name = player:get_player_name()
    if player:get_meta():get_string("game_mode") == "hardcore" then
        minetest.chat_send_all(player_name .. " has died in Hardcore Mode. The world is now permanently closed!")

        -- Mark the world as permanently closed
        local file = io.open(minetest.get_worldpath() .. "/hardcore_lock.txt", "w")
        if file then
            file:write("This world has been locked due to a hardcore death.")
            file:close()
        end

        minetest.request_shutdown("Hardcore death: World permanently closed.", true)
    end
end)

-- Prevent players from joining a locked hardcore world
minetest.register_on_prejoinplayer(function(name, ip)
    local file = io.open(minetest.get_worldpath() .. "/hardcore_lock.txt", "r")
    if file then
        file:close()
        return "This world is locked. You only had one life in Hardcore Mode."
    end
end)

