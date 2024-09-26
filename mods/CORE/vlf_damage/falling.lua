local player_fall_data = {}

minetest.register_on_joinplayer(function(player)
	local player_name = player:get_player_name()
	player_fall_data[player_name] = {
		fell_from = nil,
		fell_distance = 0
	}
end)

minetest.register_on_leaveplayer(function(player)
	local player_name = player:get_player_name()
	player_fall_data[player_name] = nil
end)

minetest.register_globalstep(function(dtime)
	for _, player in ipairs(minetest.get_connected_players()) do
		local player_name = player:get_player_name()
		if not vlf_achievements.award_unlocked(player_name, "vlf:fall_from_world_height") then
			local pos = player:get_pos()
			if player:get_hp() > 0 then
				if player_fall_data[player_name].fell_from == nil then
					player_fall_data[player_name].fell_from = pos.y
				else
					local fall_distance = player_fall_data[player_name].fell_from - pos.y
					if fall_distance >= 379 and player:get_pos().y >= -120 then
						awards.unlock(player:get_player_name(), "vlf:fall_from_world_height")
						player_fall_data[player_name].fell_from = nil
					elseif pos.y > player_fall_data[player_name].fell_from then
						player_fall_data[player_name].fell_from = pos.y
					end
				end
			end
		end
	end
end)
