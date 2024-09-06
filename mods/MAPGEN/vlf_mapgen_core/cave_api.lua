-- Cave Generation API for Minetest

local cave_api = {}

-- Configuration for the types of caves
cave_api.config = {
	cheese_cave = {
		noise_params = {
			offset = 0,
			scale = 1.6,
			spread = {x = 20, y = 10, z = 20}, -- Larger spread for giant caverns
			seed = 6736666,
			octaves = 3,
			persist = 0.1,
			lacunarity = 1.2,
		},
		threshold = 0.4, -- Lower threshold for larger hollowness, creating giant caverns
		max_threshold = 100.00,
		aquifer_threshold = 0.3, -- Threshold for determining aquifer presence
		num_layers = 3, -- Number of layers to generate
	},
	spaghetti_cave = {
		noise_params = {
			offset = 0,
			scale = 1,
			spread = {x = 11, y = 9, z = 11}, -- Spread for long, winding caves
			seed = 673656357,
			octaves = 4,
			persist = 0.2,
			lacunarity = 0.9,
		},
		threshold = 0.6, -- Balanced threshold for winding caves
		max_threshold = 100.00
	},
	noodle_cave = {
		noise_params = {
			offset = 0,
			scale = 1,
			spread = {x = 8, y = 8, z = 8}, -- Tighter spread for smaller, twisted caves
			seed = 46736552538,
			octaves = 5,
			persist = 0.2,
			lacunarity = 1.0,
		},
		threshold = 0.7, -- Higher threshold for smaller, more compact caves
		max_threshold = 100.00,
	},
	barrier_noise_params = {
		offset = 0,
		scale = 1,
		spread = {x = 30, y = 1, z = 30}, -- Spread for the barrier walls
		seed = 56789,
		octaves = 2,
		persist = 0.5,
		lacunarity = 1.5,
	},
	ocean_surface_y = 0, -- Ocean surface height
	liquid_fill_start_y = 0, -- Start height for liquid-filled areas
	liquid_fill_end_y = -30, -- End height for liquid-filled areas
}

-- Function to generate cheese caves with aquifers and layers
function cave_api.generate_cheese_caves(minp, maxp, seed)
	-- Adjust the height range for cave generation
	local min_y = math.max(minp.y, -128)
	local max_y = math.min(maxp.y, -20)
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
	local data = vm:get_data()
	local light = vm:get_light_data() -- Get light data for setting light levels
	-- Calculate the dimensions of the area
	local sidelen = maxp.x - minp.x + 1
	local map_dims = {x = sidelen, y = sidelen, z = sidelen}
	-- Generate noise maps for cheese caves and barriers
	local noise_cheese = minetest.get_perlin_map(cave_api.config.cheese_cave.noise_params, map_dims):get_3d_map_flat(minp)
	local c_air = minetest.get_content_id("air")
	local c_stone = minetest.get_content_id("vlf_core:stone")
	local c_water = minetest.get_content_id("vlf_core:water_source")
	local layers = {}
	-- Generate the cave structure
	for z = minp.z, maxp.z do
		for y = min_y, max_y do
			for x = minp.x, maxp.x do
				local vi = area:index(x, y, z)
				local idx = (z - minp.z) * sidelen * sidelen + (y - min_y) * sidelen + (x - minp.x) + 1
				local cheese_val = noise_cheese[idx]
				-- Cheese caves (large caverns)
				if cheese_val > cave_api.config.cheese_cave.threshold and cheese_val < cave_api.config.cheese_cave.max_threshold then
					data[vi] = c_air
					-- Determine if the current spot is part of an aquifer
					if cheese_val < cave_api.config.cheese_cave.aquifer_threshold then
						-- Randomly decide if this cave has water
						if math.random() < 0.1 then -- 10% chance to have water pools
							if y <= cave_api.config.liquid_fill_start_y and y >= cave_api.config.liquid_fill_end_y then
								data[vi] = c_water
							end
						end
					end
					if y < max_y then -- Underground caves only
						local light_level = light[vi] or 0
						if light_level < 5 then
							light[vi] = 5
						end
					end
				end
			end
		end
	end
	-- Create a barrier between liquid-filled and normal caves
	for z = minp.z, maxp.z do
		for x = minp.x, maxp.x do
			for y = cave_api.config.liquid_fill_end_y, cave_api.config.liquid_fill_end_y + 1 do
				local vi = area:index(x, y, z)
			end
		end
	end
	-- Write back the map data
	vm:set_data(data)
	vm:set_light_data(light) -- Write back the light data
	vm:calc_lighting()
	vm:update_liquids()
	vm:write_to_map()
end

-- Function to generate spaghetti caves
function cave_api.generate_spaghetti_caves(minp, maxp, seed)
	-- Adjust the height range for cave generation
	local min_y = math.max(minp.y, -128)
	local max_y = math.min(maxp.y, 200) 
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
	local data = vm:get_data()
	local light = vm:get_light_data() -- Get light data for setting light levels
	-- Calculate the dimensions of the area
	local sidelen = maxp.x - minp.x + 1
	local map_dims = {x = sidelen, y = sidelen, z = sidelen}
	-- Generate noise maps for spaghetti caves
	local noise_spaghetti = minetest.get_perlin_map(cave_api.config.spaghetti_cave.noise_params, map_dims):get_3d_map_flat(minp)
	local noise_noodle = minetest.get_perlin_map(cave_api.config.noodle_cave.noise_params, map_dims):get_3d_map_flat(minp)
	local c_air = minetest.get_content_id("air")
	local c_stone = minetest.get_content_id("vlf_core:stone")
	-- Iterate through all nodes in the area and carve out caves based on the noise values
	for z = minp.z, maxp.z do
		for y = min_y, max_y do
			for x = minp.x, maxp.x do
				local vi = area:index(x, y, z)
				local idx = (z - minp.z) * sidelen * sidelen + (y - min_y) * sidelen + (x - minp.x) + 1
				local spaghetti_val = noise_spaghetti[idx]
				local noodle_val = noise_noodle[idx]
				-- Spaghetti caves (thin, stringy, and winding)
				if spaghetti_val > cave_api.config.spaghetti_cave.threshold and spaghetti_val < cave_api.config.spaghetti_cave.max_threshold then
					data[vi] = c_air
					if y < max_y then -- Underground caves only
						local light_level = light[vi] or 0
						if light_level < 5 then
							light[vi] = 5
						end
					end
				end
				if noodle_val > cave_api.config.noodle_cave.threshold and noodle_val < cave_api.config.noodle_cave.max_threshold then
					data[vi] = c_air
					if y < max_y then -- Underground caves only
						local light_level = light[vi] or 0
						if light_level < 5 then
							light[vi] = 5
						end
					end
				end
			end
		end
	end
	-- Write back the map data
	vm:set_data(data)
	vm:set_light_data(light) -- Write back the light data
	vm:calc_lighting()
	vm:update_liquids()
	vm:write_to_map()
end

-- Register the cave generator with Minetest's mapgen
minetest.register_on_generated(function(minp, maxp, seed)
	cave_api.generate_spaghetti_caves(minp, maxp, seed)
	cave_api.generate_cheese_caves(minp, maxp, seed)
end)

return cave_api
