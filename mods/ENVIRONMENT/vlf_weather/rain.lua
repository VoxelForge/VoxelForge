local PARTICLES_COUNT_RAIN = 800
local PARTICLES_COUNT_THUNDER = 1700

local mgname = minetest.get_mapgen_setting("mg_name")

vlf_weather.rain = {
	-- max rain particles created at time
	particles_count = PARTICLES_COUNT_RAIN,

	-- flag to turn on/off extinguish fire for rain
	extinguish_fire = true,

	-- flag useful when mixing weathers
	raining = false,

	-- keeping last timeofday value (rounded).
	-- Defaulted to non-existing value for initial comparing.
	sky_last_update = -1,

	init_done = false,
}
local update_sound={}

local psdef= {
	amount = vlf_weather.rain.particles_count,
	time=0,
	minpos = vector.new(-15,20,-15),
	maxpos = vector.new(15,25,15),
	minvel = vector.new(0,-20,0),
	maxvel = vector.new(0,-15,0),
	minacc = vector.new(0,-0.8,0),
	maxacc = vector.new(0,-0.8,0),
	minexptime = 1,
	maxexptime = 4,
	minsize = 4,
	maxsize= 8,
	collisiondetection = true,
	collision_removal = true,
	vertical = true,
}

local textures = {"weather_pack_rain_raindrop_1.png", "weather_pack_rain_raindrop_2.png"}

function vlf_weather.has_rain(pos)
	if not vlf_worlds.has_weather(pos) then return false end
	if  mgname == "singlenode" then return true end
	local bd = minetest.registered_biomes[minetest.get_biome_name(minetest.get_biome_data(pos).biome)]
	if bd and bd._vlf_biome_type == "hot" then return false end
	if not vlf_weather.can_see_outdoors(pos) then
		return false
	end
	return true
end

function vlf_weather.rain.sound_handler(player)
	return minetest.sound_play("weather_rain", {
		to_player = player:get_player_name(),
		loop = true,
	})
end

-- set skybox based on time (uses skycolor api)
function vlf_weather.rain.set_sky_box()
	if vlf_weather.state == "rain" then
		vlf_weather.skycolor.add_layer(
			"weather-pack-rain-sky",
			{{r=0, g=0, b=0},
			{r=85, g=86, b=98},
			{r=135, g=135, b=151},
			{r=85, g=86, b=98},
			{r=0, g=0, b=0}})
		vlf_weather.skycolor.active = true
		for _, player in pairs(minetest.get_connected_players()) do
			player:set_clouds({color="#5D5D5FE8"})
		end
	end
end

-- no no no NO NO f*.. no. no manual particle creatin' PLS!! this sends EVERY particle over the net.
function vlf_weather.rain.add_rain_particles(player)
	vlf_weather.rain.last_rp_count = vlf_weather.rain.particles_count
	local l = false
	for k,v in pairs(textures) do
		psdef.texture=v
		l = l or vlf_weather.add_spawner_player(player,"rain"..k,psdef)
	end
	if l then
		update_sound[player:get_player_name()]=true
	end
end

-- register player for rain weather.
-- basically needs for origin sky reference and rain sound controls.
function vlf_weather.rain.add_player(player)
	if vlf_weather.players[player:get_player_name()] == nil then
		local player_meta = {}
		player_meta.origin_sky = {player:get_sky(true)}
		vlf_weather.players[player:get_player_name()] = player_meta
		update_sound[player:get_player_name()]=true
	end
end

-- remove player from player list entity_effected by rain.
-- be sure to remove sound before removing player otherwise soundhandler reference will be lost.
function vlf_weather.rain.remove_player(player)
	local player_meta = vlf_weather.players[player:get_player_name()]
	if player_meta and player_meta.origin_sky then
		player:set_clouds({color="#FFF0F0E5"})
		vlf_weather.players[player:get_player_name()] = nil
		update_sound[player:get_player_name()]=true
	end
end

-- adds and removes rain sound depending how much rain particles around player currently exist.
-- have few seconds delay before each check to avoid on/off sound too often
-- when player stay on 'edge' where sound should play and stop depending from random raindrop appearance.
function vlf_weather.rain.update_sound(player)
	if not update_sound[player:get_player_name()] then return end
	local player_meta = vlf_weather.players[player:get_player_name()]
	if player_meta then
		if player_meta.sound_updated and player_meta.sound_updated + 5 > minetest.get_gametime() then
			return false
		end

		if player_meta.sound_handler then
			if vlf_weather.rain.last_rp_count == 0 then
				minetest.sound_fade(player_meta.sound_handler, -0.5, 0.0)
				player_meta.sound_handler = nil
			end
		elseif vlf_weather.rain.last_rp_count > 0 then
			player_meta.sound_handler = vlf_weather.rain.sound_handler(player)
		end

		player_meta.sound_updated = minetest.get_gametime()
	end
	update_sound[player:get_player_name()]=false
end

-- rain sound removed from player.
function vlf_weather.rain.remove_sound(player)
	local player_meta = vlf_weather.players[player:get_player_name()]
	if player_meta and player_meta.sound_handler then
		minetest.sound_fade(player_meta.sound_handler, -0.5, 0.0)
		player_meta.sound_handler = nil
		player_meta.sound_updated = nil
	end
end

-- callback function for removing rain
function vlf_weather.rain.clear()
	vlf_weather.rain.raining = false
	vlf_weather.rain.sky_last_update = -1
	vlf_weather.rain.init_done = false
	vlf_weather.rain.set_particles_mode("rain")
	vlf_weather.skycolor.remove_layer("weather-pack-rain-sky")
	for _, player in pairs(minetest.get_connected_players()) do
		vlf_weather.rain.remove_sound(player)
		vlf_weather.rain.remove_player(player)
		vlf_weather.remove_spawners_player(player)
	end
end

minetest.register_globalstep(function(dtime)
	if vlf_weather.state ~= "rain" then
		return false
	end
	vlf_weather.rain.make_weather()
end)

function vlf_weather.rain.make_weather()
	if vlf_weather.rain.init_done == false then
		vlf_weather.rain.raining = true
		vlf_weather.rain.set_sky_box()
		vlf_weather.rain.set_particles_mode(vlf_weather.mode)
		vlf_weather.rain.init_done = true
	end

	for _, player in pairs(minetest.get_connected_players()) do
		local pos=player:get_pos()
		if vlf_weather.is_underwater(player) or not vlf_weather.has_rain(pos) then
			vlf_weather.rain.remove_sound(player)
			vlf_weather.remove_spawners_player(player)
			if vlf_worlds.has_weather(pos) then
				vlf_weather.set_sky_box_clear(player)
			end
		else
			if vlf_weather.has_snow(pos) then
				vlf_weather.rain.remove_sound(player)
				vlf_weather.snow.add_player(player)
				vlf_weather.snow.set_sky_box()
			else
				vlf_weather.rain.add_player(player)
				vlf_weather.rain.add_rain_particles(player)
				vlf_weather.rain.update_sound(player)
				vlf_weather.rain.set_sky_box()
			end
		end
	end
end

-- Switch the number of raindrops: "thunder" for many raindrops, otherwise for normal raindrops
function vlf_weather.rain.set_particles_mode(mode)
	if mode == "thunder" then
		psdef.amount=PARTICLES_COUNT_THUNDER
		vlf_weather.rain.particles_count = PARTICLES_COUNT_THUNDER
	else
		psdef.amount=PARTICLES_COUNT_RAIN
		vlf_weather.rain.particles_count = PARTICLES_COUNT_RAIN
	end
end

if vlf_weather.allow_abm then
	-- ABM for extinguish fire
	minetest.register_abm({
		label = "Rain extinguishes fire",
		nodenames = {"vlf_fire:fire"},
		interval = 2.0,
		chance = 2,
		action = function(pos, node, active_object_count, active_object_count_wider)
			-- Fire is extinguished if in rain or one of 4 neighbors is in rain
			if vlf_weather.rain.raining and vlf_weather.rain.extinguish_fire then
				local around = {
					{ x = 0, y = 0, z = 0 },
					{ x = -1, y = 0, z = 0 },
					{ x = 1, y = 0, z = 0 },
					{ x = 0, y = 0, z = -1 },
					{ x = 0, y = 0, z = 1 },
				}
				for a=1, #around do
					local apos = vector.add(pos, around[a])
					if vlf_weather.is_outdoor(apos) and vlf_weather.has_rain(apos) then
						minetest.remove_node(pos)
						minetest.sound_play("fire_extinguish_flame", {pos = pos, max_hear_distance = 8, gain = 0.1}, true)
						return
					end
				end
			end
		end,
	})

	-- Slowly fill up cauldrons
	minetest.register_abm({
		label = "Rain fills cauldrons with water",
		nodenames = {"vlf_cauldrons:cauldron", "vlf_cauldrons:cauldron_1", "vlf_cauldrons:cauldron_2"},
		interval = 56.0,
		chance = 1,
		action = function(pos, node, active_object_count, active_object_count_wider)
			-- Rain is equivalent to a water bottle
			if vlf_weather.rain.raining and vlf_weather.is_outdoor(pos) and vlf_weather.has_rain(pos) then
				if node.name == "vlf_cauldrons:cauldron" then
					minetest.swap_node(pos, {name="vlf_cauldrons:cauldron_1"})
				elseif node.name == "vlf_cauldrons:cauldron_1" then
					minetest.swap_node(pos, {name="vlf_cauldrons:cauldron_2"})
				elseif node.name == "vlf_cauldrons:cauldron_2" then
					minetest.swap_node(pos, {name="vlf_cauldrons:cauldron_3"})
				elseif node.name == "vlf_cauldrons:cauldron_1r" then
					minetest.swap_node(pos, {name="vlf_cauldrons:cauldron_2r"})
				elseif node.name == "vlf_cauldrons:cauldron_2r" then
					minetest.swap_node(pos, {name="vlf_cauldrons:cauldron_3r"})
				end
			end
		end
	})

	-- Wetten the soil
	minetest.register_abm({
		label = "Rain hydrates farmland",
		nodenames = {"vlf_farming:soil"},
		interval = 22.0,
		chance = 3,
		action = function(pos, node, active_object_count, active_object_count_wider)
			if vlf_weather.rain.raining and vlf_weather.is_outdoor(pos) and vlf_weather.has_rain(pos) then
				if node.name == "vlf_farming:soil" then
					minetest.set_node(pos, {name="vlf_farming:soil_wet"})
				end
			end
		end
	})
end

if vlf_weather.reg_weathers.rain == nil then
	vlf_weather.reg_weathers.rain = {
		clear = vlf_weather.rain.clear,
		light_factor = 0.9,
		-- 10min - 20min
		min_duration = 600,
		max_duration = 1200,
		transitions = {
			[30] = "none",
			[40] = "snow",
			[60] = "thunder",
		}
	}
end
