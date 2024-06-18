vlf_weather.thunder = {
	next_strike = 0,
	min_delay = 3,
	max_delay = 12,
	init_done = false,
}

minetest.register_globalstep(function(dtime)
	if vlf_weather.get_weather() ~= "thunder" then
		return false
	end

	vlf_weather.rain.set_particles_mode("thunder")
	vlf_weather.rain.make_weather()

	if vlf_weather.thunder.init_done == false then
		vlf_weather.skycolor.add_layer("weather-pack-thunder-sky", {
			{r=0, g=0, b=0},
			{r=40, g=40, b=40},
			{r=85, g=86, b=86},
			{r=40, g=40, b=40},
			{r=0, g=0, b=0},
		})
		vlf_weather.skycolor.active = true
		for _, player in pairs(minetest.get_connected_players()) do
			player:set_clouds({color="#3D3D3FE8"})
		end
		vlf_weather.thunder.init_done = true
	end
	if (vlf_weather.thunder.next_strike <= minetest.get_gametime()) then
		vlf_lightning.strike()
		local delay = math.random(vlf_weather.thunder.min_delay, vlf_weather.thunder.max_delay)
		vlf_weather.thunder.next_strike = minetest.get_gametime() + delay
	end
end)

function vlf_weather.thunder.clear()
	vlf_weather.rain.clear()
	vlf_weather.skycolor.remove_layer("weather-pack-thunder-sky")
	vlf_weather.skycolor.remove_layer("lightning")
	vlf_weather.thunder.init_done = false
end

-- register thunderstorm weather
if vlf_weather.reg_weathers.thunder == nil then
	vlf_weather.reg_weathers.thunder = {
		clear = vlf_weather.thunder.clear,
		light_factor = 0.33333,
		-- 10min - 20min
		min_duration = 600,
		max_duration = 1200,
		transitions = {
			[100] = "rain",
		},
	}
end
