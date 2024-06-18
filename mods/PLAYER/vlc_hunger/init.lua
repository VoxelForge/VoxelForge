local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

local S = minetest.get_translator(modname)

vlc_hunger = {}

--[[ This variable tells you if the hunger gameplay mechanic is active.
The state of the hunger mechanic will be determined at game start.
Hunger is enabled when damage is enabled.
If the damage setting is changed within the game, this does NOT
update the hunger mechanic, so the game must be restarted for this
to take effect. ]]
vlc_hunger.active = false
if minetest.settings:get_bool("enable_damage") == true and minetest.settings:get_bool("vlc_enable_hunger") ~= false then
	vlc_hunger.active = true
end

vlc_hunger.HUD_TICK = 0.1

-- Exhaustion increase
vlc_hunger.EXHAUST_DIG = 5  -- after digging node
vlc_hunger.EXHAUST_JUMP = 50 -- jump
vlc_hunger.EXHAUST_SPRINT_JUMP = 200 -- jump while sprinting
vlc_hunger.EXHAUST_ATTACK = 100 -- hit an enemy
vlc_hunger.EXHAUST_SWIM = 10 -- player movement in water
vlc_hunger.EXHAUST_SPRINT = 100 -- sprint (per node)
vlc_hunger.EXHAUST_DAMAGE = 100 -- taking damage (protected by armor)
vlc_hunger.EXHAUST_REGEN = 6000 -- Regenerate 1 HP
vlc_hunger.EXHAUST_HUNGER = 5 -- Hunger status effect at base level.
vlc_hunger.EXHAUST_LVL = 4000 -- at what exhaustion player saturation gets lowered

vlc_hunger.SATURATION_INIT = 5 -- Initial saturation for new/respawning players

-- Debug Mode. If enabled, saturation and exhaustion are shown as well.
-- NOTE: Only updated when settings are loaded.
vlc_hunger.debug = false

-- Cooldown timers for each player, to force a short delay between consuming 2 food items
vlc_hunger.last_eat = {}

dofile(modpath.."/api.lua")
dofile(modpath.."/hunger.lua")
dofile(modpath.."/register_foods.lua")

--[[ IF HUNGER IS ENABLED ]]
if vlc_hunger.active == true then

-- Read debug mode setting
-- The setting should only be read at the beginning, this mod is not
-- prepared to change this setting later.
vlc_hunger.debug = minetest.settings:get_bool("vlc_hunger_debug")
if vlc_hunger.debug == nil then
	vlc_hunger.debug = false
end

--[[ Data value format notes:
	Hunger values is identical to Minecraft's and ranges from 0 to 20.
	Exhaustion and saturation values are stored as integers, unlike in Minecraft.
	Exhaustion is Minecraft exhaustion times 1000 and ranges from 0 to 4000.
	Saturation is Minecraft saturation and ranges from 0 to 20.

	Food saturation is stored in the custom item definition field _vlc_saturation.
	This field uses the original Minecraft value.
]]

-- Count number of poisonings a player has at once
vlc_hunger.poison_hunger = {} -- food poisoning, increasing hunger

-- HUD
local function init_hud(player)
	hb.init_hudbar(player, "hunger", vlc_hunger.get_hunger(player))
	if vlc_hunger.debug then
		hb.init_hudbar(player, "saturation", vlc_hunger.get_saturation(player), vlc_hunger.get_hunger(player))
		hb.init_hudbar(player, "exhaustion", vlc_hunger.get_exhaustion(player))
	end
end

-- HUD updating functions for Debug Mode. No-op if not in Debug Mode
function vlc_hunger.update_saturation_hud(player, saturation, hunger)
	if vlc_hunger.debug then
		hb.change_hudbar(player, "saturation", saturation, hunger)
	end
end
function vlc_hunger.update_exhaustion_hud(player, exhaustion)
	if vlc_hunger.debug then
		if not exhaustion then
			exhaustion =  vlc_hunger.get_exhaustion(player)
		end
		hb.change_hudbar(player, "exhaustion", exhaustion)
	end
end

-- register saturation hudbar
hb.register_hudbar("hunger", 0xFFFFFF, S("Food"), { icon = "hbhunger_icon.png", bgicon = "hbhunger_bgicon.png",  bar = "hbhunger_bar.png" }, 20, 20, false, nil, nil, 1)
if vlc_hunger.debug then
	hb.register_hudbar("saturation", 0xFFFFFF, S("Saturation"), { icon = "vlc_hunger_icon_saturation.png", bgicon = "vlc_hunger_bgicon_saturation.png", bar = "vlc_hunger_bar_saturation.png" }, vlc_hunger.SATURATION_INIT, 200, false, nil, nil, 1)
	hb.register_hudbar("exhaustion", 0xFFFFFF, S("Exhaust."), { icon = "vlc_hunger_icon_exhaustion.png", bgicon = "vlc_hunger_bgicon_exhaustion.png", bar = "vlc_hunger_bar_exhaustion.png" }, 0, vlc_hunger.EXHAUST_LVL, false, nil, nil, 1)
end

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	vlc_hunger.init_player(player)
	init_hud(player)
	vlc_hunger.poison_hunger[name] = 0
	vlc_hunger.last_eat[name] = -1
end)

minetest.register_on_respawnplayer(function(player)
	-- reset hunger, related values and poison
	local name = player:get_player_name()

	vlc_hunger.stop_poison(player)
	vlc_hunger.last_eat[name] = -1

	local h, s, e = 20, vlc_hunger.SATURATION_INIT, 0
	vlc_hunger.set_hunger(player, h, false)
	vlc_hunger.set_saturation(player, s, false)
	vlc_hunger.set_exhaustion(player, e, false)
	hb.change_hudbar(player, "hunger", h)
	vlc_hunger.update_saturation_hud(player, s, h)
	vlc_hunger.update_exhaustion_hud(player, e)
end)

-- PvP combat exhaustion
minetest.register_on_punchplayer(function(victim, puncher, time_from_last_punch, tool_capabilities, dir, damage)
	if puncher:is_player() then
		vlc_hunger.exhaust(puncher:get_player_name(), vlc_hunger.EXHAUST_ATTACK)
	end
end)

-- Exhaust on taking damage
minetest.register_on_player_hpchange(function(player, hp_change)
	if hp_change < 0 then
		local name = player:get_player_name()
		vlc_hunger.exhaust(name, vlc_hunger.EXHAUST_DAMAGE)
	end
end)

local food_tick_timers = {} -- one food_tick_timer per player, keys are the player-objects
minetest.register_globalstep(function(dtime)
	for _,player in pairs(minetest.get_connected_players()) do

		local food_tick_timer = food_tick_timers[player] and food_tick_timers[player] + dtime or 0
		local player_name = player:get_player_name()
		local food_level = vlc_hunger.get_hunger(player)
		local food_saturation_level = vlc_hunger.get_saturation(player)
		local player_health = player:get_hp()

		if food_tick_timer > 4.0 then
			food_tick_timer = 0

			-- let hunger work always
			if player_health > 0 and player_health <= 20 then
				--vlc_hunger.exhaust(player_name, vlc_hunger.EXHAUST_HUNGER) -- later for hunger status effect
				vlc_hunger.update_exhaustion_hud(player)
			end

			if food_level >= 18 then -- slow regeneration
				if player_health > 0 and player_health < 20 then
					player:set_hp(player_health+1)
					vlc_hunger.exhaust(player_name, vlc_hunger.EXHAUST_REGEN)
					vlc_hunger.update_exhaustion_hud(player)
				end

			elseif food_level == 0 then -- starvation
				-- the amount of health at which a player will stop to get
				-- harmed by starvation (10 for Easy, 1 for Normal, 0 for Hard)
				local maximum_starvation = 1
				-- TODO: implement Minecraft-like difficulty modes and the update maximumStarvation here
				if player_health > maximum_starvation then
					vlc_util.deal_damage(player, 1, {type = "starve"})
				end
			end

		elseif food_tick_timer > 0.5 and food_level == 20 and food_saturation_level > 0 then -- fast regeneration
			if player_health > 0 and player_health < 20 then
				food_tick_timer = 0
				player:set_hp(player_health+1)
				vlc_hunger.exhaust(player_name, vlc_hunger.EXHAUST_REGEN)
				vlc_hunger.update_exhaustion_hud(player)
			end
		end

		food_tick_timers[player] = food_tick_timer -- update food_tick_timer table
	end
end)

-- JUMP EXHAUSTION
vlc_player.register_globalstep(function(player, dtime)
	local name = player:get_player_name()
	local node_stand, node_stand_below, node_head, node_feet, node_head_top

	-- Update jump status immediately since we need this info in real time.
	-- WARNING: This section is HACKY as hell since it is all just based on heuristics.

	if vlc_player.players[player].jump_cooldown > 0 then
		vlc_player.players[player].jump_cooldown = vlc_player.players[player].jump_cooldown - dtime
	end

	if player:get_player_control().jump and vlc_player.players[player].jump_cooldown <= 0 then

		--pos = player:get_pos()

		node_stand = vlc_player.players[player].nodes.stand
		node_stand_below = vlc_player.players[player].nodes.stand_below
		node_head = vlc_player.players[player].nodes.head
		node_feet = vlc_player.players[player].nodes.feet
		node_head_top = vlc_player.players[player].nodes.head_top
		if not node_stand or not node_stand_below or not node_head or not node_feet then
			return
		end
		if (not minetest.registered_nodes[node_stand]
		or not minetest.registered_nodes[node_stand_below]
		or not minetest.registered_nodes[node_head]
		or not minetest.registered_nodes[node_feet]
		or not minetest.registered_nodes[node_head_top]) then
			return
		end

		-- Cause buggy exhaustion for jumping

		--[[ Checklist we check to know the player *actually* jumped:
			* Not on or in liquid
			* Not on or at climbable
			* On walkable
			* Not on disable_jump
		FIXME: This code is pretty hacky and it is possible to miss some jumps or detect false
		jumps because of delays, rounding errors, etc.
		What this code *really* needs is some kind of jumping “callback” which this engine lacks
		as of 0.4.15.
		]]

		if minetest.get_item_group(node_feet, "liquid") == 0 and
				minetest.get_item_group(node_stand, "liquid") == 0 and
				not minetest.registered_nodes[node_feet].climbable and
				not minetest.registered_nodes[node_stand].climbable and
				(minetest.registered_nodes[node_stand].walkable or minetest.registered_nodes[node_stand_below].walkable)
				and minetest.get_item_group(node_stand, "disable_jump") == 0
				and minetest.get_item_group(node_stand_below, "disable_jump") == 0 then
		-- Cause exhaustion for jumping
		if vlc_sprint.is_sprinting(name) then
			vlc_hunger.exhaust(name, vlc_hunger.EXHAUST_SPRINT_JUMP)
		else
			vlc_hunger.exhaust(name, vlc_hunger.EXHAUST_JUMP)
		end

		-- Reset cooldown timer
			vlc_player.players[player].jump_cooldown = 0.45
		end
	end
end)

vlc_player.register_globalstep_slow(function(player, dtime)
	--[[ Swimming: Cause exhaustion.
	NOTE: As of 0.4.15, it only counts as swimming when you are with the feet inside the liquid!
	Head alone does not count. We respect that for now. ]]
	if not player:get_attach() and (minetest.get_item_group(vlc_player.players[player].nodes.node_feet, "liquid") ~= 0 or
			minetest.get_item_group(vlc_player.players[player].nodes.node_stand, "liquid") ~= 0) then
		local lastPos = vlc_player.players[player].lastPos
		if lastPos then
			local dist = vector.distance(lastPos, player:get_pos())
			vlc_player.players[player].swimDistance = vlc_player.players[player].swimDistance + dist
			if vlc_player.players[player].swimDistance >= 1 then
				local superficial = math.floor(vlc_player.players[player].swimDistance)
				vlc_hunger.exhaust(player:get_player_name(), vlc_hunger.EXHAUST_SWIM * superficial)
				vlc_player.players[player].swimDistance = vlc_player.players[player].swimDistance - superficial
			end
		end

	end
end)


--[[ IF HUNGER IS NOT ENABLED ]]
else

minetest.register_on_joinplayer(function(player)
	vlc_hunger.init_player(player)
	vlc_hunger.last_eat[player:get_player_name()] = -1
end)

end
