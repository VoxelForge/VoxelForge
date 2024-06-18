vlc_weather.thunder = {
	next_strike = 0,
	min_delay = 3,
	max_delay = 12,
	init_done = false,
}

minetest.register_globalstep(function(dtime)
	if vlc_weather.get_weather() ~= "thunder" then
		return false
	end

	vlc_weather.rain.set_particles_mode("thunder")
	vlc_weather.rain.make_weather()

	if vlc_weather.thunder.init_done == false then
		vlc_weather.skycolor.add_layer("weather-pack-thunder-sky", {
			{r=0, g=0, b=0},
			{r=40, g=40, b=40},
			{r=85, g=86, b=86},
			{r=40, g=40, b=40},
			{r=0, g=0, b=0},
		})
		vlc_weather.skycolor.active = true
		for _, player in pairs(minetest.get_connected_players()) do
			player:set_clouds({color="#3D3D3FE8"})
		end
		vlc_weather.thunder.init_done = true
	end
	if (vlc_weather.thunder.next_strike <= minetest.get_gametime()) then
		vlc_lightning.strike()
		local delay = math.random(vlc_weather.thunder.min_delay, vlc_weather.thunder.max_delay)
		vlc_weather.thunder.next_strike = minetest.get_gametime() + delay
	end
end)

function vlc_weather.thunder.clear()
	vlc_weather.rain.clear()
	vlc_weather.skycolor.remove_layer("weather-pack-thunder-sky")
	vlc_weather.skycolor.remove_layer("lightning")
	vlc_weather.thunder.init_done = false
end

-- register thunderstorm weather
if vlc_weather.reg_weathers.thunder == nil then
	vlc_weather.reg_weathers.thunder = {
		clear = vlc_weather.thunder.clear,
		light_factor = 0.33333,
		-- 10min - 20min
		min_duration = 600,
		max_duration = 1200,
		transitions = {
			[100] = "rain",
		},
	}
end
