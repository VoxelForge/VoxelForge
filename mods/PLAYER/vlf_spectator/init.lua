local function set_spectating_mode(player)
    if player:is_player() and vlf_gamemode.is_spectating(player:get_player_name()) then
        player:set_properties({
            visual_size = {x = 0, y = 0},
            collisionbox = {0, 0, 0, 0, 0, 0},
        })
        player:set_armor_groups({immortal = 1})
        player:set_nametag_attributes({
		text = "",
		color = {r = 0, g = 0, b = 0, a = 0}
	})
    else
        player:set_properties({
            visual_size = {x = 1, y = 1},
            collisionbox = {-0.35, -1, -0.35, 0.35, 0.8, 0.35},
        })
        player:set_armor_groups({immortal = 0})
        player:set_detach()
        player:set_nametag_attributes({
		text = player:get_player_name(),
		color = {r = 255, g = 255, b = 255, a = 255}
	})
    end
end

local pending_attach = {}

-- Globalstep function to check player interaction with entities
minetest.register_globalstep(function(dtime)
    for _, player in ipairs(minetest.get_connected_players()) do
        if vlf_gamemode.is_spectating(player:get_player_name()) then
            local controls = player:get_player_control()
            local attached_entity = player:get_attach()
            set_spectating_mode(player)

            if controls.RMB and attached_entity then
                player:set_detach()
                pending_attach[player:get_player_name()] = nil
            else
                local pos = player:get_pos()
                local look_dir = player:get_look_dir()
                local end_pos = vector.add(pos, vector.multiply(look_dir, 10))
                local ray = minetest.raycast(pos, end_pos, true, false)

                for pointed_thing in ray do
                    if pointed_thing.type == "object" then
                        local entity = pointed_thing.ref:get_luaentity()
                        if entity then
                            if not attached_entity then
                                pending_attach[player:get_player_name()] = pointed_thing.ref
                            end
                        end
                    end
                end
            end
        end

        if pending_attach[player:get_player_name()] then
            local target_entity = pending_attach[player:get_player_name()]
            if target_entity and target_entity:get_luaentity() then
                player:set_attach(target_entity, "", {x = 0, y = 0, z = 0}, {x = 0, y = 0, z = 0})
                minetest.chat_send_player(player:get_player_name(), "You are now spectating " .. target_entity:get_luaentity().name)
                pending_attach[player:get_player_name()] = nil -- Clear after attaching
            end
        end
    end
end)

local spectating_players = {}

minetest.register_chatcommand("spectate", {
    params = "<target_player>",
    description = "Start spectating a player",
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        local target_player = minetest.get_player_by_name(param)

        if not player then
            return false, "Player not found."
        end

        if not target_player then
            return false, "Target player not found."
        end

        spectating_players[name] = target_player:get_player_name()

        minetest.chat_send_player(name, "You are now spectating " .. param)
        return true, "Spectating " .. param .. "."
    end
})

minetest.register_chatcommand("unspectate", {
    description = "Stop spectating a player",
    func = function(name)
        if spectating_players[name] then
            spectating_players[name] = nil
            minetest.chat_send_player(name, "You have stopped spectating.")
            return true, "Stopped spectating."
        else
            return false, "You are not currently spectating anyone."
        end
    end
})

minetest.register_globalstep(function(dtime)
    for spectator_name, target_name in pairs(spectating_players) do
        local spectator = minetest.get_player_by_name(spectator_name)
        local target = minetest.get_player_by_name(target_name)

        if spectator and target then
            local t_pos = target:get_pos()
            local f_pos = {x=t_pos.x, y=t_pos.y+0.5, z=t_pos.z}

            spectator:set_pos(f_pos)

            spectator:set_look_vertical(target:get_look_vertical())
            spectator:set_look_horizontal(target:get_look_horizontal())
        else
            spectating_players[spectator_name] = nil
            minetest.chat_send_player(spectator_name, "The player you were spectating has left.")
        end
    end
end)
