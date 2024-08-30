local mods_loaded = false
local NIGHT_VISION_RATIO = 0.45

local water_color = "#3F76E4"

local mg_name = minetest.get_mapgen_setting("mg_name")

function vlf_weather.set_sky_box_clear(player, sky, fog)
	local pos = player:get_pos()
	if minetest.get_item_group(minetest.get_node(vector.new(pos.x,pos.y+1.5,pos.z)).name, "water") ~= 0 then return end
	local sc = {
			day_sky = "#7BA4FF",
			day_horizon = "#C0D8FF",
			dawn_sky = "#7BA4FF",
			dawn_horizon = "#C0D8FF",
			night_sky = "#000000",
			night_horizon = "#4A6790",
			indoors = "#C0D8FF",
			fog_sun_tint = "#ff5f33",
			fog_moon_tint = nil,
			fog_tint_type = "custom"
		}
	if sky then
		sc.day_sky = sky
		sc.dawn_sky = sky
	end
	if fog then
		sc.day_horizon = fog
		sc.dawn_horizon = fog
	end
	player:set_sky({
		type = "regular",
		sky_color = sc,
		clouds = true,
	})
end

function vlf_weather.set_sky_color(player, def)
	local pos = player:get_pos()
	if minetest.get_item_group(minetest.get_node(vector.offset(pos, 0, 1.5, 0)).name, "water") ~= 0 then return end
	player:set_sky({
		type = def.type,
		sky_color = def.sky_color,
		clouds = def.clouds,
	})
end

vlf_weather.skycolor = {
	-- Should be activated before do any entity_effect.
	active = true,

	-- To skip update interval
	force_update = true,

	-- Update interval.
	update_interval = 3,

	-- Main sky colors: starts from midnight to midnight.
	-- Please do not set directly. Use add_layer instead.
	colors = {},

	-- min value which will be used in color gradient, usualy its first user given color in 'pure' color.
	min_val = 0,

	-- number of colors while constructing gradient of user given colors
	max_val = 1000,

	-- Table for tracking layer order
	layer_names = {},

	-- To layer to colors table
	add_layer = function(layer_name, layer_color, instant_update)
		vlf_weather.skycolor.colors[layer_name] = layer_color
		table.insert(vlf_weather.skycolor.layer_names, layer_name)
		vlf_weather.skycolor.force_update = true
	end,

	current_layer_name = function()
		return vlf_weather.skycolor.layer_names[#vlf_weather.skycolor.layer_names]
	end,

	-- Retrieve layer from colors table
	retrieve_layer = function()
		local last_layer = vlf_weather.skycolor.current_layer_name()
		return vlf_weather.skycolor.colors[last_layer]
	end,

	-- Remove layer from colors table
	remove_layer = function(layer_name)
		for k, name in pairs(vlf_weather.skycolor.layer_names) do
			if name == layer_name then
				table.remove(vlf_weather.skycolor.layer_names, k)
				vlf_weather.skycolor.force_update = true
				return
			end
		end
	end,

		-- Wrapper for updating day/night ratio that respects night vision
	override_day_night_ratio = function(player, ratio)
		local meta = player:get_meta()
		local has_night_vision = meta:get_int("night_vision") == 1
		local has_darkness = meta:get_int("darkness") == 1
		local is_visited_shepherd = meta:get_int("vlf_shepherd:special") == 1
		local arg
		if has_darkness and not is_visited_shepherd then
			if has_night_vision then arg = 0.1
			else arg = 0 end
		else
			-- Apply night vision only for dark sky
			local is_dark = minetest.get_timeofday() > 0.8 or minetest.get_timeofday() < 0.2 or vlf_weather.state ~= "none"
			local pos = player:get_pos()
			local dim = vlf_worlds.pos_to_dimension(pos)
			if (has_night_vision or is_visited_shepherd) and is_dark and dim ~= "nether" and dim ~= "end" then
				if ratio == nil then
					arg = NIGHT_VISION_RATIO
				else
					arg = math.max(ratio, NIGHT_VISION_RATIO)
				end
			else
				arg = ratio
			end
		end
		player:override_day_night_ratio(arg)
	end,

	-- Update sky color. If players not specified update sky for all players.
	update_sky_color = function(players)
		-- Override day/night ratio as well
		players = vlf_weather.skycolor.utils.get_players(players)
		for _, player in ipairs(players) do
			local pos = player:get_pos()
			local dim = vlf_worlds.pos_to_dimension(pos)
			local has_weather = (vlf_worlds.has_weather(pos) and (vlf_weather.state == "snow" or vlf_weather.state =="rain" or vlf_weather.state == "thunder") and vlf_weather.has_snow(pos)) or ((vlf_weather.state =="rain" or vlf_weather.state == "thunder") and vlf_weather.has_rain(pos))
			local checkname = minetest.get_node(vector.new(pos.x,pos.y+1.5,pos.z)).name
			if minetest.get_item_group(checkname, "water") ~= 0 then
				local biome_index = minetest.get_biome_data(player:get_pos()).biome
				local biome_name = minetest.get_biome_name(biome_index)
				local biome = minetest.registered_biomes[biome_name]
				if biome then water_color = biome._vlf_waterfogcolor end
				if not biome then water_color = "#3F76E4" end
				if checkname == "vlfx_core:river_water_source" or checkname == "vlfx_core:river_water_flowing" then water_color = "#0084FF" end
				player:set_sky({ type = "regular",
					sky_color = {
						day_sky = water_color,
						day_horizon = water_color,
						dawn_sky = water_color,
						dawn_horizon = water_color,
						night_sky = water_color,
						night_horizon = water_color,
						indoors = water_color,
						fog_sun_tint = water_color,
						fog_moon_tint = water_color,
						fog_tint_type = "custom"
					},
					clouds = false,
				})
			end
			if dim == "overworld" then
				local biomesky
				local biomefog
				if mg_name ~= "v6" and mg_name ~= "singlenode" then
					local biome_index = minetest.get_biome_data(player:get_pos()).biome
					local biome_name = minetest.get_biome_name(biome_index)
					local biome = minetest.registered_biomes[biome_name]
					if biome then
						--minetest.log("action", string.format("Biome found for number: %s in biome: %s", tostring(biome_index), biome_name))
						biomesky = biome._vlf_skycolor
						biomefog = biome._vlf_fogcolor
					end
				end
				if (vlf_weather.state == "none") then
					-- Clear weather
					vlf_weather.set_sky_box_clear(player,biomesky,biomefog)
					player:set_sun({visible = true, sunrise_visible = true})
					player:set_moon({visible = true})
					player:set_stars({visible = true})
					vlf_weather.skycolor.override_day_night_ratio(player, nil)
				elseif not has_weather then
					local day_color = vlf_weather.skycolor.get_sky_layer_color(0.15)
					local dawn_color = vlf_weather.skycolor.get_sky_layer_color(0.27)
					local night_color = vlf_weather.skycolor.get_sky_layer_color(0.1)
					vlf_weather.set_sky_color(player, {
						type = "regular",
						sky_color = {
							day_sky = day_color,
							day_horizon = day_color,
							dawn_sky = dawn_color,
							dawn_horizon = dawn_color,
							night_sky = night_color,
							night_horizon = night_color,
						},
						clouds = true,
					})
					player:set_sun({visible = false, sunrise_visible = false})
					player:set_moon({visible = false})
					player:set_stars({visible = false})
				elseif has_weather then
					-- Weather skies
					local day_color = vlf_weather.skycolor.get_sky_layer_color(0.5)
					local dawn_color = vlf_weather.skycolor.get_sky_layer_color(0.75)
					local night_color = vlf_weather.skycolor.get_sky_layer_color(0)
					vlf_weather.set_sky_color(player, {
						type = "regular",
						sky_color = {
							day_sky = day_color,
							day_horizon = day_color,
							dawn_sky = dawn_color,
							dawn_horizon = dawn_color,
							night_sky = night_color,
							night_horizon = night_color,
						},
						clouds = true,
					})
					player:set_sun({visible = false, sunrise_visible = false})
					player:set_moon({visible = false})
					player:set_stars({visible = false})

					local lf = vlf_weather.get_current_light_factor()
					if vlf_weather.skycolor.current_layer_name() == "lightning" then
						vlf_weather.skycolor.override_day_night_ratio(player, 1)
					elseif lf then
						-- This used to be blatantly wrong and there appears to be another
						-- fairly complex solution around so I will explain what it's doing (now):
						-- The light is basically derived by the distance of the current time to
						-- 0.5 which means midday/noon. i.e. the key here is 1 - math.abs(0.5 - w)
						-- the rest is just modifications and a minimum light level of 0.2
						local w = minetest.get_timeofday()
						local light = math.max(0.2,((1 - math.abs(0.5 - w)) * lf) - 0.15)
						vlf_weather.skycolor.override_day_night_ratio(player, light)
					else
						vlf_weather.skycolor.override_day_night_ratio(player, nil)
					end
				end
			elseif dim == "end" then
				local biomesky = "#000000"
				--local biomefog = "#A080A0"
				if mg_name ~= "v6" and mg_name ~= "singlenode" then
					local biome_index = minetest.get_biome_data(player:get_pos()).biome
					local biome_name = minetest.get_biome_name(biome_index)
					local biome = minetest.registered_biomes[biome_name]
					if biome then
						--minetest.log("action", string.format("Biome found for number: %s in biome: %s", tostring(biome_index), biome_name))
						biomesky = biome._vlf_skycolor
						--biomefog = biome._vlf_fogcolor -- The End biomes seemingly don't use the fog colour, despite having this value according to the wiki. The sky colour is seemingly used for both sky and fog?
					end
				end
				local t = "vlf_playerplus_end_sky.png"
				player:set_sky({ type = "skybox",
					base_color = biomesky,
					textures = {t,t,t,t,t,t},
					clouds = false,
				})
				player:set_sun({visible = false , sunrise_visible = false})
				player:set_moon({visible = false})
				player:set_stars({visible = false})
				vlf_weather.skycolor.override_day_night_ratio(player, 0.5)
			elseif dim == "nether" then
				--local biomesky = "#6EB1FF"
				local biomefog = "#330808"
				if mg_name ~= "v6" and mg_name ~= "singlenode" then
					local biome_index = minetest.get_biome_data(player:get_pos()).biome
					local biome_name = minetest.get_biome_name(biome_index)
					local biome = minetest.registered_biomes[biome_name]
					if biome then
						--minetest.log("action", string.format("Biome found for number: %s in biome: %s", tostring(biome_index), biome_name))
						--biomesky = biome._vlf_skycolor -- The Nether biomes seemingly don't use the sky colour, despite having this value according to the wiki. The fog colour is used for both sky and fog.
						biomefog = biome._vlf_fogcolor
					end
				end
				vlf_weather.set_sky_color(player, {
					type = "regular",
					sky_color = {
						day_sky = biomefog,
						day_horizon = biomefog,
						dawn_sky = biomefog,
						dawn_horizon = biomefog,
						night_sky = biomefog,
						night_horizon = biomefog,
						indoors = biomefog,
						fog_sun_tint = biomefog,
						fog_moon_tint = biomefog,
						fog_tint_type = "custom"
					},
					clouds = false,
				})
				player:set_sun({visible = false , sunrise_visible = false})
				player:set_moon({visible = false})
				player:set_stars({visible = false})
				vlf_weather.skycolor.override_day_night_ratio(player, nil)
			elseif dim == "void" then
				player:set_sky({ type = "plain",
					base_color = "#000000",
					clouds = false,
				})
				player:set_sun({visible = false, sunrise_visible = false})
				player:set_moon({visible = false})
				player:set_stars({visible = false})
			end
		end
	end,

	-- Returns current layer color in {r, g, b} format
	get_sky_layer_color = function(timeofday)
		if #vlf_weather.skycolor.layer_names == 0 then
			return nil
		end

		-- min timeofday value 0; max timeofday value 1. So sky color gradient range will be between 0 and 1 * vlf_weather.skycolor.max_val.
		local rounded_time = math.floor(timeofday * vlf_weather.skycolor.max_val)
		local color = vlf_weather.skycolor.utils.convert_to_rgb(vlf_weather.skycolor.min_val, vlf_weather.skycolor.max_val, rounded_time, vlf_weather.skycolor.retrieve_layer())
		return color
	end,

	utils = {
		convert_to_rgb = function(minval, maxval, current_val, colors)
			local max_index = #colors - 1
			local val = (current_val-minval) / (maxval-minval) * max_index + 1.0
			local index1 = math.floor(val)
			local index2 = math.min(math.floor(val)+1, max_index + 1)
			local f = val - index1
			local c1 = colors[index1]
			local c2 = colors[index2]
			return {r=math.floor(c1.r + f*(c2.r - c1.r)), g=math.floor(c1.g + f*(c2.g-c1.g)), b=math.floor(c1.b + f*(c2.b - c1.b))}
		end,

		-- Simply getter. Ether returns user given players list or get all connected players if none provided
		get_players = function(players)
			if players == nil or #players == 0 then
				if mods_loaded then
					players = minetest.get_connected_players()
				elseif players == nil then
					players = {}
				end
			end
			return players
		end,

		-- Returns first player sky color. I assume that all players are in same color layout.
		get_current_bg_color = function()
			local players = vlf_weather.skycolor.utils.get_players(nil)
			if players[1] then
				return players[1]:get_sky(true).sky_color
			end
			return nil
		end
	},

}

local timer = 0
minetest.register_globalstep(function(dtime)
	if vlf_weather.skycolor.active ~= true or #minetest.get_connected_players() == 0 then
		return
	end

	if vlf_weather.skycolor.force_update then
		vlf_weather.skycolor.update_sky_color()
		vlf_weather.skycolor.force_update = false
		return
	end

	-- regular updates based on iterval
	timer = timer + dtime;
	if timer >= vlf_weather.skycolor.update_interval then
		vlf_weather.skycolor.update_sky_color()
		timer = 0
	end

end)

local function initsky(player)
	if player.set_lighting then
		player:set_lighting({
			shadows = { intensity = 0.33 },
			volumetric_light = { strength = 0.45 },
			exposure = {
				luminance_min = -3.5,
				luminance_max = -2.5,
				exposure_correction = 0.35,
				speed_dark_bright = 1500,
				speed_bright_dark = 700,
			},
			saturation = 1.1,
		})
	end

	if (vlf_weather.skycolor.active) then
		vlf_weather.skycolor.force_update = true
	end

	player:set_clouds(vlf_worlds.get_cloud_parameters() or {height=vlf_worlds.layer_to_y(127), speed={x=-2, z=0}, thickness=4, color="#FFF0FEF"})
end

minetest.register_on_joinplayer(initsky)
minetest.register_on_respawnplayer(initsky)

vlf_worlds.register_on_dimension_change(function(player)
	vlf_weather.skycolor.update_sky_color({player})
end)

minetest.register_on_mods_loaded(function()
	mods_loaded = true
end)
