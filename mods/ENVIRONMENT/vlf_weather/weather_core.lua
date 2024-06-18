local S = minetest.get_translator(minetest.get_current_modname())

-- weather states, 'none' is default, other states depends from active mods
vlf_weather.state = "none"

-- player list for saving player meta info
vlf_weather.players = {}

-- default weather check interval for global step
vlf_weather.check_interval = 5

-- weather min duration
vlf_weather.min_duration = 600

-- weather max duration
vlf_weather.max_duration = 9000

-- weather calculated end time
vlf_weather.end_time = nil

-- registered weathers
vlf_weather.reg_weathers = {}

-- global flag to disable/enable ABM logic.
vlf_weather.allow_abm = true

vlf_weather.reg_weathers["none"] = {
	min_duration = vlf_weather.min_duration,
	max_duration = vlf_weather.max_duration,
	light_factor = nil,
	transitions = {
		[50] = "rain",
		[100] = "snow",
	},
	clear = function() end,
}

local storage = minetest.get_mod_storage()
-- Save weather into mod storage, so it can be loaded after restarting the server
local function save_weather()
	if not vlf_weather.end_time then return end
	storage:set_string("vlf_weather_state", vlf_weather.state)
	storage:set_int("vlf_weather_end_time", vlf_weather.end_time)
	minetest.log("verbose", "[vlf_weather] Weather data saved: state="..vlf_weather.state.." end_time="..vlf_weather.end_time)
end
minetest.register_on_shutdown(save_weather)

local particlespawners={}
function vlf_weather.add_spawner_player(pl,id,ps)
	local name=pl:get_player_name()
	if not particlespawners[name] then
		particlespawners[name] = {}
	end
	if not particlespawners[name][id] then
		vlf_weather.remove_spawners_player(pl)
		particlespawners[name] = {}
		ps.playername =name
		ps.attached = pl
		particlespawners[name][id]=minetest.add_particlespawner(ps)
		return particlespawners[name][id]
	end
end
function vlf_weather.remove_spawners_player(pl)
	local name=pl:get_player_name()
	if not particlespawners[name] then return end
	for k,v in pairs(particlespawners[name]) do
		minetest.delete_particlespawner(v)
	end
	particlespawners[name] = nil
	return true
end

function vlf_weather.remove_all_spawners()
	for k,v in pairs(minetest.get_connected_players()) do
		vlf_weather.remove_spawners_player(v)
	end
end

function vlf_weather.get_rand_end_time(min_duration, max_duration)
	local r
	if min_duration and max_duration then
		r = math.random(min_duration, max_duration)
	else
		r = math.random(vlf_weather.min_duration, vlf_weather.max_duration)
	end
	return minetest.get_gametime() + r
end

function vlf_weather.get_current_light_factor()
	if vlf_weather.state == "none" then
		return nil
	else
		return vlf_weather.reg_weathers[vlf_weather.state].light_factor
	end
end

-- Returns true if pos is outdoor.
-- Outdoor is defined as any node in the Overworld under open sky.
-- FIXME: Nodes below glass also count as “outdoor”, this should not be the case.
function vlf_weather.is_outdoor(pos)
	local cpos = vector.offset(pos,0,1,0)
	local dim = vlf_worlds.pos_to_dimension(cpos)
	if minetest.get_node_light(cpos, 0.5) == 15 and dim == "overworld" then
		return true
	end
	return false
end

function vlf_weather.can_see_outdoors(pos)
	local light = minetest.get_natural_light(pos, 0.5)
	if light ~= nil and light >= 1 then
		return true
	end
	return false
end

-- checks if player is undewater. This is needed in order to
-- turn off weather particles generation.
function vlf_weather.is_underwater(player)
	local ppos = player:get_pos()
	local offset = player:get_eye_offset()
	local player_eye_pos = {x = ppos.x + offset.x,
				y = ppos.y + offset.y + 1.5,
				z = ppos.z + offset.z}
	local node_level = minetest.get_node_level(player_eye_pos)
	if node_level == 8 or node_level == 7 then
		return true
	end
	return false
end

local t = 0

minetest.register_globalstep(function(dtime)
	t = t + dtime
	if t < vlf_weather.check_interval then return end
	t = 0

	if vlf_weather.end_time == nil then
		vlf_weather.end_time = vlf_weather.get_rand_end_time()
	end
	-- recalculate weather
	if vlf_weather.end_time <= minetest.get_gametime() then
		local changeWeather = minetest.settings:get_bool("vlf_doWeatherCycle")
		if changeWeather == nil then
			changeWeather = true
		end
		if changeWeather then
			vlf_weather.set_random_weather(vlf_weather.state, vlf_weather.reg_weathers[vlf_weather.state])
		else
			vlf_weather.end_time = vlf_weather.get_rand_end_time()
		end
	end
end)

-- Sets random weather (which could be 'none' (no weather)).
function vlf_weather.set_random_weather(weather_name, weather_meta)
	if weather_meta == nil then return end
	local transitions = weather_meta.transitions
	local random_roll = math.random(0,100)
	local new_weather
	for v, weather in pairs(transitions) do
		if random_roll < v then
			new_weather = weather
			break
		end
	end
	if new_weather then
		vlf_weather.change_weather(new_weather)
	end
end

-- Change weather to new_weather.
-- * explicit_end_time is OPTIONAL. If specified, explicitly set the
--   gametime (minetest.get_gametime) in which the weather ends.
-- * changer is OPTIONAL, for logging purposes.
function vlf_weather.change_weather(new_weather, explicit_end_time, changer_name)
	local changer_name = changer_name or debug.getinfo(2).name.."()"

	if (vlf_weather.reg_weathers and vlf_weather.reg_weathers[new_weather]) then
		if (vlf_weather.state and vlf_weather.reg_weathers[vlf_weather.state]) then
			vlf_weather.reg_weathers[vlf_weather.state].clear()
		end

		local old_weather = vlf_weather.state

		vlf_weather.state = new_weather

		if old_weather == "none" then
			old_weather = "clear"
		end
		if new_weather == "none" then
			new_weather = "clear"
		end
		minetest.log("info", "[vlf_weather] " .. changer_name .. " changed the weather from " .. old_weather .. " to " .. new_weather)

		local weather_meta = vlf_weather.reg_weathers[vlf_weather.state]
		if explicit_end_time then
			vlf_weather.end_time = explicit_end_time
		else
			vlf_weather.end_time = vlf_weather.get_rand_end_time(weather_meta.min_duration, weather_meta.max_duration)
		end
		vlf_weather.skycolor.update_sky_color()
		save_weather()
		return true
	end
	return false
end

function vlf_weather.get_weather()
	return vlf_weather.state
end

minetest.register_privilege("weather_manager", {
	description = S("Gives ability to control weather"),
	give_to_singleplayer = false
})

-- Weather command definition. Set
minetest.register_chatcommand("weather", {
	params = "(clear | rain | snow | thunder) [<duration>]",
	description = S("Changes the weather to the specified parameter."),
	privs = {weather_manager = true},
	func = function(name, param)
		if (param == "") then
			return false, S("Error: No weather specified.")
		end
		local new_weather, end_time
		local parse1, parse2 = string.match(param, "(%w+) ?(%d*)")
		if parse1 then
			if parse1 == "clear" then
				new_weather = "none"
			else
				new_weather = parse1
			end
		else
			return false, S("Error: Invalid parameters.")
		end
		if parse2 then
			if type(tonumber(parse2)) == "number" then
				local duration = tonumber(parse2)
				if duration < 1 then
					return false, S("Error: Duration can't be less than 1 second.")
				end
				end_time = minetest.get_gametime() + duration
			end
		end

		local success = vlf_weather.change_weather(new_weather, end_time, name)
		if success then
			return true
		else
			return false, S("Error: Invalid weather specified. Use “clear”, “rain”, “snow” or “thunder”.")
		end
	end
})

minetest.register_chatcommand("toggledownfall", {
	params = "",
	description = S("Toggles between clear weather and weather with downfall (randomly rain, thunderstorm or snow)"),
	privs = {weather_manager = true},
	func = function(name, param)
		-- Currently rain/thunder/snow: Set weather to clear
		if vlf_weather.state ~= "none" then
			return vlf_weather.change_weather("none", nil, name)

		-- Currently clear: Set weather randomly to rain/thunder/snow
		else
			local new = { "rain", "thunder", "snow" }
			local r = math.random(1, #new)
			return vlf_weather.change_weather(new[r], nil, name)
		end
	end
})

-- Configuration setting which allows user to disable ABM for weathers (if they use it).
-- Weather mods expected to be use this flag before registering ABM.
local weather_allow_abm = minetest.settings:get_bool("weather_allow_abm")
if weather_allow_abm == false then
	vlf_weather.allow_abm = false
end


local function load_weather()
	local weather = storage:get_string("vlf_weather_state")
	if weather and weather ~= "" then
		vlf_weather.state = weather
		vlf_weather.end_time = storage:get_int("vlf_weather_end_time")
		vlf_weather.change_weather(weather, vlf_weather.end_time)
		if type(vlf_weather.end_time) ~= "number" then
			-- Fallback in case of corrupted end time
			vlf_weather.end_time = vlf_weather.min_duration
		end
		minetest.log("info", "[vlf_weather] Weather restored.")
	else
		minetest.log("info", "[vlf_weather] No weather data found. Starting with clear weather.")
	end
end

load_weather()
