vlf_hunger.registered_foods = {}

function vlf_hunger.init_player(player)
	local meta = player:get_meta()
	if meta:get_string("vlf_hunger:hunger") == "" then
		meta:set_string("vlf_hunger:hunger", tostring(20))
	end
	if meta:get_string("vlf_hunger:saturation") == "" then
		meta:set_string("vlf_hunger:saturation", tostring(vlf_hunger.SATURATION_INIT))
	end
	if meta:get_string("vlf_hunger:exhaustion") == "" then
		meta:set_string("vlf_hunger:exhaustion", tostring(0))
	end
end

if vlf_hunger.active then
	function vlf_hunger.get_hunger(player)
		local hunger = tonumber(player:get_meta():get_string("vlf_hunger:hunger")) or 20
		return hunger
	end

	function vlf_hunger.get_saturation(player)
		local saturation = tonumber(player:get_meta():get_string("vlf_hunger:saturation")) or vlf_hunger.SATURATION_INIT
		return saturation
	end

	function vlf_hunger.get_exhaustion(player)
		local exhaustion = tonumber(player:get_meta():get_string("vlf_hunger:exhaustion")) or 0
		return exhaustion
	end

	function vlf_hunger.set_hunger(player, hunger, update_hudbars)
		hunger = math.min(20, math.max(0, hunger))
		player:get_meta():set_string("vlf_hunger:hunger", tostring(hunger))
		if update_hudbars ~= false then
			hb.change_hudbar(player, "hunger", hunger)
			vlf_hunger.update_saturation_hud(player, nil, hunger)
		end
		return true
	end

	function vlf_hunger.set_saturation(player, saturation, update_hudbar)
		saturation = math.min(vlf_hunger.get_hunger(player), math.max(0, saturation))
		player:get_meta():set_string("vlf_hunger:saturation", tostring(saturation))
		if update_hudbar ~= false then
			vlf_hunger.update_saturation_hud(player, saturation)
		end
		return true
	end

	function vlf_hunger.set_exhaustion(player, exhaustion, update_hudbar)
		exhaustion = math.min(vlf_hunger.EXHAUST_LVL, math.max(0.0, exhaustion))
		player:get_meta():set_string("vlf_hunger:exhaustion", tostring(exhaustion))
		if update_hudbar ~= false then
			vlf_hunger.update_exhaustion_hud(player, exhaustion)
		end
		return true
	end

	function vlf_hunger.exhaust(playername, increase)
		local player = minetest.get_player_by_name(playername)
		if not player then return false end
		vlf_hunger.set_exhaustion(player, vlf_hunger.get_exhaustion(player) + increase)
		if vlf_hunger.get_exhaustion(player) >= vlf_hunger.EXHAUST_LVL then
			vlf_hunger.set_exhaustion(player, 0.0)
			local h = nil
			local satuchanged = false
			local s = vlf_hunger.get_saturation(player)
			if s > 0 then
				vlf_hunger.set_saturation(player, math.max(s - 1.5, 0))
				satuchanged = true
			elseif s <= 0.0001 then
				h = vlf_hunger.get_hunger(player)
				h = math.max(h-1, 0)
				vlf_hunger.set_hunger(player, h)
				satuchanged = true
			end
			if satuchanged then
				if h then h = h end
				vlf_hunger.update_saturation_hud(player, vlf_hunger.get_saturation(player), h)
			end
		end
		vlf_hunger.update_exhaustion_hud(player, vlf_hunger.get_exhaustion(player))
		return true
	end

	function vlf_hunger.saturate(playername, increase, update_hudbar)
		local player = minetest.get_player_by_name(playername)
		local ok = vlf_hunger.set_saturation(player,
			math.min(vlf_hunger.get_saturation(player) + increase, vlf_hunger.get_hunger(player)))
		if update_hudbar ~= false then
			vlf_hunger.update_saturation_hud(player, vlf_hunger.get_saturation(player), vlf_hunger.get_hunger(player))
		end
		return ok
	end

	function vlf_hunger.register_food(name, hunger_change, replace_with_item, poisontime, poison, exhaust, poisonchance, sound)
		if not vlf_hunger.active then
			return
		end
		local food = vlf_hunger.registered_foods
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

	function vlf_hunger.stop_poison(player)
		if not vlf_hunger.active then
			return
		end
		vlf_hunger.poison_hunger[player:get_player_name()] = 0
		vlf_hunger.reset_bars_poison_hunger(player)
	end

else
	-- When hunger is disabled, the functions are basically no-ops

	function vlf_hunger.get_hunger()
		return 20
	end

	function vlf_hunger.get_saturation()
		return vlf_hunger.SATURATION_INIT
	end

	function vlf_hunger.get_exhaustion()
		return 0
	end

	function vlf_hunger.set_hunger()
		return false
	end

	function vlf_hunger.set_saturation()
		return false
	end

	function vlf_hunger.set_exhaustion()
		return false
	end

	function vlf_hunger.exhaust()
		return false
	end

	function vlf_hunger.saturate()
		return false
	end

	function vlf_hunger.register_food() end

	function vlf_hunger.stop_poison() end

end
