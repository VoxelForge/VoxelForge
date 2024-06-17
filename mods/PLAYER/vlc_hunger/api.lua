vlc_hunger.registered_foods = {}

function vlc_hunger.init_player(player)
	local meta = player:get_meta()
	if meta:get_string("vlc_hunger:hunger") == "" then
		meta:set_string("vlc_hunger:hunger", tostring(20))
	end
	if meta:get_string("vlc_hunger:saturation") == "" then
		meta:set_string("vlc_hunger:saturation", tostring(vlc_hunger.SATURATION_INIT))
	end
	if meta:get_string("vlc_hunger:exhaustion") == "" then
		meta:set_string("vlc_hunger:exhaustion", tostring(0))
	end
end

if vlc_hunger.active then
	function vlc_hunger.get_hunger(player)
		local hunger = tonumber(player:get_meta():get_string("vlc_hunger:hunger")) or 20
		return hunger
	end

	function vlc_hunger.get_saturation(player)
		local saturation = tonumber(player:get_meta():get_string("vlc_hunger:saturation")) or vlc_hunger.SATURATION_INIT
		return saturation
	end

	function vlc_hunger.get_exhaustion(player)
		local exhaustion = tonumber(player:get_meta():get_string("vlc_hunger:exhaustion")) or 0
		return exhaustion
	end

	function vlc_hunger.set_hunger(player, hunger, update_hudbars)
		hunger = math.min(20, math.max(0, hunger))
		player:get_meta():set_string("vlc_hunger:hunger", tostring(hunger))
		if update_hudbars ~= false then
			hb.change_hudbar(player, "hunger", hunger)
			vlc_hunger.update_saturation_hud(player, nil, hunger)
		end
		return true
	end

	function vlc_hunger.set_saturation(player, saturation, update_hudbar)
		saturation = math.min(vlc_hunger.get_hunger(player), math.max(0, saturation))
		player:get_meta():set_string("vlc_hunger:saturation", tostring(saturation))
		if update_hudbar ~= false then
			vlc_hunger.update_saturation_hud(player, saturation)
		end
		return true
	end

	function vlc_hunger.set_exhaustion(player, exhaustion, update_hudbar)
		exhaustion = math.min(vlc_hunger.EXHAUST_LVL, math.max(0.0, exhaustion))
		player:get_meta():set_string("vlc_hunger:exhaustion", tostring(exhaustion))
		if update_hudbar ~= false then
			vlc_hunger.update_exhaustion_hud(player, exhaustion)
		end
		return true
	end

	function vlc_hunger.exhaust(playername, increase)
		local player = minetest.get_player_by_name(playername)
		if not player then return false end
		vlc_hunger.set_exhaustion(player, vlc_hunger.get_exhaustion(player) + increase)
		if vlc_hunger.get_exhaustion(player) >= vlc_hunger.EXHAUST_LVL then
			vlc_hunger.set_exhaustion(player, 0.0)
			local h = nil
			local satuchanged = false
			local s = vlc_hunger.get_saturation(player)
			if s > 0 then
				vlc_hunger.set_saturation(player, math.max(s - 1.5, 0))
				satuchanged = true
			elseif s <= 0.0001 then
				h = vlc_hunger.get_hunger(player)
				h = math.max(h-1, 0)
				vlc_hunger.set_hunger(player, h)
				satuchanged = true
			end
			if satuchanged then
				if h then h = h end
				vlc_hunger.update_saturation_hud(player, vlc_hunger.get_saturation(player), h)
			end
		end
		vlc_hunger.update_exhaustion_hud(player, vlc_hunger.get_exhaustion(player))
		return true
	end

	function vlc_hunger.saturate(playername, increase, update_hudbar)
		local player = minetest.get_player_by_name(playername)
		local ok = vlc_hunger.set_saturation(player,
			math.min(vlc_hunger.get_saturation(player) + increase, vlc_hunger.get_hunger(player)))
		if update_hudbar ~= false then
			vlc_hunger.update_saturation_hud(player, vlc_hunger.get_saturation(player), vlc_hunger.get_hunger(player))
		end
		return ok
	end

	function vlc_hunger.register_food(name, hunger_change, replace_with_item, poisontime, poison, exhaust, poisonchance, sound)
		if not vlc_hunger.active then
			return
		end
		local food = vlc_hunger.registered_foods
		food[name] = {}
		food[name].saturation = hunger_change	-- hunger points added
		food[name].replace = replace_with_item	-- what item is given back after eating
		food[name].poisontime = poisontime	-- time it is poisoning. If this is set, this item is considered poisonous,
							-- otherwise the following poison/exhaust fields are ignored
		food[name].poison = poison		-- poison damage per tick for poisonous food
		food[name].exhaust = exhaust		-- exhaustion per tick for poisonous food
		food[name].poisonchance = poisonchance	-- chance percentage that this item poisons the player (default: 100%)
		food[name].sound = sound		-- special sound that is played when eating
	end

	function vlc_hunger.stop_poison(player)
		if not vlc_hunger.active then
			return
		end
		vlc_hunger.poison_hunger[player:get_player_name()] = 0
		vlc_hunger.reset_bars_poison_hunger(player)
	end

else
	-- When hunger is disabled, the functions are basically no-ops

	function vlc_hunger.get_hunger()
		return 20
	end

	function vlc_hunger.get_saturation()
		return vlc_hunger.SATURATION_INIT
	end

	function vlc_hunger.get_exhaustion()
		return 0
	end

	function vlc_hunger.set_hunger()
		return false
	end

	function vlc_hunger.set_saturation()
		return false
	end

	function vlc_hunger.set_exhaustion()
		return false
	end

	function vlc_hunger.exhaust()
		return false
	end

	function vlc_hunger.saturate()
		return false
	end

	function vlc_hunger.register_food() end

	function vlc_hunger.stop_poison() end

end
