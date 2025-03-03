local Perlin = dofile(minetest.get_modpath("vlf_worldgen") .. "/perlin.lua")

local perlin = Perlin.new("0") -- Use a string or number as seed

--[[minetest.register_on_generated(function(minp, maxp, seed)
    local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
    local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
    local data = vm:get_data()

    local c_water = minetest.get_content_id("mcl_core:water_source")
    local c_stone = minetest.get_content_id("mcl_core:stone")
    local c_dirt = minetest.get_content_id("mcl_core:dirt")

    for x = minp.x, maxp.x do
        for z = minp.z, maxp.z do
            local height = math.floor(perlin:noise2d(x, z, 10, 0.5, 200) * 250 + 20)

            for y = minp.y, maxp.y do
                local vi = area:index(x, y, z)
                if y < height then
                    data[vi] = c_stone
                elseif y == height then
                    data[vi] = c_dirt
                elseif y <= 0 then
                    data[vi] = c_water
                end
            end
        end
    end

    vm:set_data(data)
    vm:write_to_map()
end)


]]

--[[Phase 1
minetest.register_on_generated(function(minp, maxp, seed)
    local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
    local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
    local data = vm:get_data()

    local c_air = minetest.get_content_id("air")
    local c_stone = minetest.get_content_id("mcl_core:stone")

    math.randomseed(seed) -- Seed the random generator

    for x = minp.x, maxp.x do
        for y = minp.y, maxp.y do
            for z = minp.z, maxp.z do
                local vi = area:index(x, y, z)
                
                if math.random() < 0.5 then
                    data[vi] = c_stone
                else
                    data[vi] = c_air
                end
            end
        end
    end

    vm:set_data(data)
    vm:write_to_map()
end)]]
--[[Phase 2
minetest.register_on_generated(function(minp, maxp, seed)
    local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
    local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
    local data = vm:get_data()

    local c_air = minetest.get_content_id("air")
    local c_stone = minetest.get_content_id("mcl_core:stone")

    math.randomseed(seed) -- Seed the random generator

    for x = minp.x, maxp.x do
        for y = minp.y, maxp.y do
            for z = minp.z, maxp.z do
                local vi = area:index(x, y, z)
                
                if y > 100 then
                    data[vi] = c_air
                else
                    data[vi] = c_stone
                end
            end
        end
    end

    vm:set_data(data)
    vm:write_to_map()
end)]]
--[[Phase 3
minetest.register_on_generated(function(minp, maxp, seed)
    local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
    local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
    local data = vm:get_data()

    local c_air = minetest.get_content_id("air")
    local c_stone = minetest.get_content_id("mcl_core:stone")

    math.randomseed(seed) -- Seed the random generator

    for x = minp.x, maxp.x do
        for z = minp.z, maxp.z do
        	local height_limit = math.random(100, 119) -- Random height for each X,Z area
            for y = minp.y, maxp.y do
                local vi = area:index(x, y, z)
                
                if y > height_limit then
                    data[vi] = c_air
                else
                    data[vi] = c_stone
                end
            end
        end
    end

    vm:set_data(data)
    vm:write_to_map()
end)]]
--Phase 4
--[[minetest.register_on_generated(function(minp, maxp, seed)
    local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
    local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
    local data = vm:get_data()

    local c_air = minetest.get_content_id("air")
    local c_stone = minetest.get_content_id("mcl_core:stone")

    math.randomseed(seed) -- Seed the random generator

    for x = minp.x, maxp.x do
        local height_limit = 100 + math.sin(x) * 10 -- Sinusoidal height variation
        for y = minp.y, maxp.y do
            for z = minp.z, maxp.z do
                local vi = area:index(x, y, z)
                
                if y > height_limit then
                    data[vi] = c_air
                else
                    data[vi] = c_stone
                end
            end
        end
    end

    vm:set_data(data)
    vm:write_to_map()
end)]]
--Phase 5
--[[minetest.register_on_generated(function(minp, maxp, seed)
    local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
    local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
    local data = vm:get_data()

    local c_air = minetest.get_content_id("air")
    local c_stone = minetest.get_content_id("mcl_core:stone")
    
    local frequency = 0.2
    local amplitude = 10

    math.randomseed(seed) -- Seed the random generator

    for x = minp.x, maxp.x do
        local height_limit = 100 + math.sin(x*frequency)*amplitude -- Sinusoidal height variation
        for y = minp.y, maxp.y do
            for z = minp.z, maxp.z do
                local vi = area:index(x, y, z)
                
                if y > height_limit then
                    data[vi] = c_air
                else
                    data[vi] = c_stone
                end
            end
        end
    end

    vm:set_data(data)
    vm:write_to_map()
end)]]
--[[Phase 6
minetest.register_on_generated(function(minp, maxp, seed)
    local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
    local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
    local data = vm:get_data()

    local c_air = minetest.get_content_id("air")
    local c_stone = minetest.get_content_id("mcl_core:stone")
    
    local frequency = 0.1
    local amplitude = 10

    math.randomseed(seed) -- Seed the random generator

    for x = minp.x, maxp.x do
    	local hlx = math.sin(x*frequency)*amplitude
        for z = minp.z, maxp.z do
        	local hlz = math.sin(z*frequency)*amplitude
            for y = minp.y, maxp.y do
            	local height_limit = 100 + hlx + hlz
                local vi = area:index(x, y, z)
                
                if y > height_limit then
                    --data[vi] = c_air
                else
                    data[vi] = c_stone
                end
            end
        end
    end

    vm:set_data(data)
    vm:write_to_map()
end)]]
--Phase 7
--[[minetest.register_on_generated(function(minp, maxp, seed)
    local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
    local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
    local data = vm:get_data()

    local c_air = minetest.get_content_id("air")
    local c_stone = minetest.get_content_id("mcl_core:stone")
    local c_water = minetest.get_content_id("mcl_core:water_source")
    
    local frequency = 0.1
    local amplitude = 10

    math.randomseed(seed) -- Seed the random generator

    for x = minp.x, maxp.x do
    	local hlx = math.sin(x*frequency)*amplitude
        for z = minp.z, maxp.z do
        	local hlz = math.sin(z*frequency)*amplitude
            for y = minp.y, maxp.y do
            	local height_limit = 100 + hlx + hlz
            	local sea_level = 102
                local vi = area:index(x, y, z)

                if y < height_limit then
                	data[vi] = c_stone
                elseif y <= sea_level then
                	data[vi] = c_water
                end
            end
        end
    end

    vm:set_data(data)
    vm:write_to_map()
end)]]
--Phase 8
--[[minetest.register_on_generated(function(minp, maxp, seed)
    local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
    local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
    local data = vm:get_data()

    local c_stone = minetest.get_content_id("mcl_core:stone")

    for x = minp.x, maxp.x do
        for z = minp.z, maxp.z do
            local height = 100 + math.floor(perlin:noise2d(x, z, 1, 1, 100) * 20)

            for y = minp.y, maxp.y do
                local vi = area:index(x, y, z)
                if y < height then
                    data[vi] = c_stone
                end
            end
        end
    end

    vm:set_data(data)
    vm:write_to_map()
end)]]
--Phase 9
--[[minetest.register_on_generated(function(minp, maxp, seed)
    local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
    local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
    local data = vm:get_data()

    local c_stone = minetest.get_content_id("mcl_core:stone")

    for x = minp.x, maxp.x do
        for z = minp.z, maxp.z do
            local height = 100 + math.floor(perlin:noise2d(x, z, 4, 0.5, 100) * 20)

            for y = minp.y, maxp.y do
                local vi = area:index(x, y, z)
                if y < height then
                    data[vi] = c_stone
                end
            end
        end
    end

    vm:set_data(data)
    vm:write_to_map()
end)]]
--Phase 10
--[[local continentalness_to_height = {
    {-1, 100},
    {1, 100},
}

-- Function to interpolate between points in the spline table
local function interpolate(x, table)
    for i = 1, #table - 1 do
        local x1, y1 = table[i][1], table[i][2]
        local x2, y2 = table[i + 1][1], table[i + 1][2]
        if x >= x1 and x <= x2 then
            local t = (x - x1) / (x2 - x1)
            return y1 + t * (y2 - y1)
        end
    end
    return 200 -- Default if no interpolation found
end

-- Initialize Perlin noise generator with a seed (can be passed as a string or number)
local perlin = Perlin.new("continental_noise_seed")

minetest.register_on_generated(function(minp, maxp, seed)
    local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
    local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
    local data = vm:get_data()

    local c_stone = minetest.get_content_id("mcl_core:stone")

    for x = minp.x, maxp.x do
        for z = minp.z, maxp.z do
            -- Get the continentalness value based on the Perlin noise
            local continentalness_value = perlin:noise2d(x, z, 4, 0.5, 100)  -- Adjust spread and persistence as needed
            -- Map continentalness value to height using the spline function
            local height = interpolate(continentalness_value, continentalness_to_height)

            for y = minp.y, maxp.y do
                local vi = area:index(x, y, z)
                if y < height then
                    data[vi] = c_stone
                end
            end
        end
    end

    vm:set_data(data)
    vm:write_to_map()
end)]]
--[[Phase 11: Basic idea.
local continentalness_to_height = {
    {-1, -64},
    {-0.7, 40},
    {-0.4, 64},
    {0.0, 80},
    {0.5, 100},
    {1.0, 256},
}

-- Function to interpolate height based on continentalness
local function interpolate(x, table)
    for i = 1, #table - 1 do
        local x1, y1 = table[i][1], table[i][2]
        local x2, y2 = table[i + 1][1], table[i + 1][2]
        if x >= x1 and x <= x2 then
            local t = (x - x1) / (x2 - x1)
            return y1 + t * (y2 - y1)
        end
    end
    return 200 -- Default height if out of range
end

local perlin = Perlin.new(58363)

minetest.register_on_generated(function(minp, maxp, seed)
    local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
    local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
    local data = vm:get_data()

    local c_stone = minetest.get_content_id("mcl_core:stone")

    for x = minp.x, maxp.x do
        for z = minp.z, maxp.z do
            local continentalness_value = perlin:noise2d(x, z, 4, 0.5, 100)
            local height = interpolate(continentalness_value, continentalness_to_height)

            for y = minp.y, maxp.y do
                local vi = area:index(x, y, z)
                if y < height then
                    data[vi] = c_stone
                end
            end
        end
    end

    vm:set_data(data)
    vm:write_to_map()
end)

-- HUD to show continentalness at player's position
local player_huds = {}

minetest.register_globalstep(function()
    for _, player in ipairs(minetest.get_connected_players()) do
        local player_name = player:get_player_name()
        local pos = player:get_pos()
        local continentalness_value = perlin:noise2d(pos.x, pos.z, 4, 0.5, 100)
        
        if not player_huds[player_name] then
            player_huds[player_name] = player:hud_add({
                hud_elem_type = "text",
                position = {x = 0.1, y = 0.1},
                offset = {x = 0, y = 0},
                text = "Continentalness: " .. string.format("%.2f", continentalness_value),
                scale = {x = 100, y = 100},
                alignment = {x = 1, y = 1},
                number = 0xFFFFFF,
            })
        else
            player:hud_change(player_huds[player_name], "text", "Continentalness: " .. string.format("%.2f", continentalness_value))
        end
    end
end)]]

--Phase 12
--[[ Table for continentalness to height
local continentalness_to_height = {
    {-1, -64},
    {-0.7, 40},
    {-0.4, 64},
    {0.0, 100},
    {0.5, 150},
    {1.0, 306},
}

-- Table for erosion to height reduction
local erosion_to_height_reduction = {
    {-1, 0},    -- No reduction at lowest erosion
    {-0.7, 5},
    {-0.4, 10},
    {0.0, 15},
    {0.5, 20},
    {1.0, 50},  -- Max reduction at highest erosion
}

-- Function to interpolate height based on a given table
local function interpolate(x, table)
    for i = 1, #table - 1 do
        local x1, y1 = table[i][1], table[i][2]
        local x2, y2 = table[i + 1][1], table[i + 1][2]
        if x >= x1 and x <= x2 then
            local t = (x - x1) / (x2 - x1)
            return y1 + t * (y2 - y1)
        end
    end
    return 200 -- Default height if out of range
end

local perlin = Perlin.new(58363)
local erosion_perlin = Perlin.new(58364) -- New Perlin noise for erosion

minetest.register_on_generated(function(minp, maxp, seed)
    local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
    local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
    local data = vm:get_data()

    local c_stone = minetest.get_content_id("mcl_core:stone")

    for x = minp.x, maxp.x do
        for z = minp.z, maxp.z do
            -- Get continentalness value
            local continentalness_value = perlin:noise2d(x, z, 4, 0.5, 100)
            -- Get erosion value (higher values make terrain lower and smoother)
            local erosion_value = erosion_perlin:noise2d(x, z, 1, 0.5, 200)

            -- Interpolate the height based on continentalness
            local height = interpolate(continentalness_value, continentalness_to_height)

            -- Interpolate height reduction based on erosion (higher erosion reduces height more)
            local erosion_reduction = interpolate(erosion_value, erosion_to_height_reduction)
            
            -- Apply erosion effect to the height
            height = height - erosion_reduction

            -- Generate terrain based on height
            for y = minp.y, maxp.y do
                local vi = area:index(x, y, z)
                if y < height then
                    data[vi] = c_stone
                end
            end
        end
    end

    vm:set_data(data)
    vm:write_to_map()
end)

-- HUD to show continentalness and erosion at player's position
local player_huds = {}

minetest.register_globalstep(function()
    for _, player in ipairs(minetest.get_connected_players()) do
        local player_name = player:get_player_name()
        local pos = player:get_pos()
        
        -- Get the continentalness and erosion values at the player's position
        local continentalness_value = perlin:noise2d(pos.x, pos.z, 4, 0.5, 100)
        local erosion_value = erosion_perlin:noise2d(pos.x, pos.z, 4, 0.5, 100)

        -- Update HUD with both continentalness and erosion
        if not player_huds[player_name] then
            player_huds[player_name] = player:hud_add({
                hud_elem_type = "text",
                position = {x = 0.1, y = 0.1},
                offset = {x = 0, y = 0},
                text = string.format("Continentalness: %.2f  Erosion: %.2f", continentalness_value, erosion_value),
                scale = {x = 100, y = 100},
                alignment = {x = 1, y = 1},
                number = 0xFFFFFF,
            })
        else
            player:hud_change(player_huds[player_name], "text", 
                string.format("Continentalness: %.2f  Erosion: %.2f", continentalness_value, erosion_value))
        end
    end
end)]]
--Phase 13
--[[ Table for continentalness to height
local continentalness_to_height = {
    {-1, -64},
    {-0.7, 20},
    {-0.4, 30},
    {0.0, 54},
    {0.5, 100},
    {1.0, 256},
}

-- Table for erosion to height reduction
local erosion_to_height_reduction = {
    {-1, 0},    -- No reduction at lowest erosion
    {-0.7, 5},
    {-0.4, 10},
    {0.0, 15},
    {0.5, 20},
    {1.0, 50},  -- Max reduction at highest erosion
}

-- Table for peaks and valleys to height variation
local peaks_and_valleys_to_variation = {
    {-1, -10},    -- Flattest terrain at lowest peaks
    {-0.7, 0},
    {-0.4, 10},
    {0.0, 20},
    {0.5, 60},
    {1.0, 110}, -- Largest peaks at highest values
}

-- Function to interpolate height based on a given table
local function interpolate(x, table)
    for i = 1, #table - 1 do
        local x1, y1 = table[i][1], table[i][2]
        local x2, y2 = table[i + 1][1], table[i + 1][2]
        if x >= x1 and x <= x2 then
            local t = (x - x1) / (x2 - x1)
            return y1 + t * (y2 - y1)
        end
    end
    return 200 -- Default height if out of range
end

local perlin = Perlin.new(58363)
local erosion_perlin = Perlin.new(58364) -- New Perlin noise for erosion
local peaks_perlin = Perlin.new(58365) -- New Perlin noise for peaks and valleys

minetest.register_on_generated(function(minp, maxp, seed)
    local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
    local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
    local data = vm:get_data()

    local c_stone = minetest.get_content_id("mcl_core:stone")
    local c_water = minetest.get_content_id("mcl_core:water_source")

    for x = minp.x, maxp.x do
        for z = minp.z, maxp.z do
        local continentalness_value = perlin:noise2d(x, z, 4, 0.5, 200)
        local erosion_value = erosion_perlin:noise2d(x, z, 1, 0.3, 300)
        local peaks_and_valleys_value = peaks_perlin:noise2d(x, z, 6, 0.4, 100)

            -- Interpolate the height based on continentalness
            local height = interpolate(continentalness_value, continentalness_to_height)

            -- Interpolate height reduction based on erosion (higher erosion reduces height more)
            local erosion_reduction = interpolate(erosion_value, erosion_to_height_reduction)
            
            -- Apply erosion effect to the height
            height = height - erosion_reduction

            -- Interpolate height variation based on peaks and valleys (higher values make larger mountains)
            local peak_variation = interpolate(peaks_and_valleys_value, peaks_and_valleys_to_variation)

            -- Apply peaks and valleys effect (higher peak_variation = larger mountains)
            height = height + peak_variation

            -- Generate terrain based on height
            for y = minp.y, maxp.y do
                local vi = area:index(x, y, z)
                if y < height then
                    data[vi] = c_stone
                elseif y <= 64 then
                	data[vi] = c_water
                end
            end
        end
    end

    vm:set_data(data)
    vm:write_to_map()
end)

-- HUD to show continentalness, erosion, and peaks at player's position
local player_huds = {}

minetest.register_globalstep(function()
    for _, player in ipairs(minetest.get_connected_players()) do
        local player_name = player:get_player_name()
        local pos = player:get_pos()
        
        -- Get the continentalness, erosion, and peaks values at the player's position
        local continentalness_value = perlin:noise2d(pos.x, pos.z, 4, 0.5, 200)
        local erosion_value = erosion_perlin:noise2d(pos.x, pos.z, 1, 0.3, 300)
        local peaks_and_valleys_value = peaks_perlin:noise2d(pos.x, pos.z, 6, 0.4, 100)

        -- Update HUD with continentalness, erosion, and peaks
        if not player_huds[player_name] then
            player_huds[player_name] = player:hud_add({
                hud_elem_type = "text",
                position = {x = 0.1, y = 0.1},
                offset = {x = 0, y = 0},
                text = string.format("Continentalness: %.2f  Erosion: %.2f  Peaks: %.2f", continentalness_value, erosion_value, peaks_and_valleys_value),
                scale = {x = 100, y = 100},
                alignment = {x = 1, y = 1},
                number = 0xFFFFFF,
            })
        else
            player:hud_change(player_huds[player_name], "text", 
                string.format("Continentalness: %.2f  Erosion: %.2f  Peaks: %.2f", continentalness_value, erosion_value, peaks_and_valleys_value))
        end
    end
end)]]
--Phase 14
--[[local continentalness_to_height = {
    {-1.1, 180},
    {-1.02, 20},
    {-0.51, 20},
    {-0.44, 63},
    {-0.18, 63},
    {-0.16, 106},
    {-0.15, 106},
    {-0.1, 120},
    {0.25, 150},
    {1.0, 150}
}

-- Table for erosion to height reduction
local erosion_to_height_reduction = {
	{-1, 0},
	{-0.8, 50},
	{-0.4, 70},
	{-0.34, 60},
	{-0.1, 110},
	{0.2, 125},
	{0.4, 125},
	{0.45, 80},
	{0.55, 80},
	{0.6, 120},
	{0.8, 130},
	{1, 130}
}

-- Table for peaks and valleys to height variation
local peaks_and_valleys_to_variation = {
    {-1, -10},    -- Flattest terrain at lowest peaks
    {-0.7, 0},
    {-0.4, 10},
    {0.0, 20},
    {0.5, 60},
    {1.0, 160}, -- Largest peaks at highest values
}

-- Function to interpolate height based on a given table
local function interpolate(x, table)
    for i = 1, #table - 1 do
        local x1, y1 = table[i][1], table[i][2]
        local x2, y2 = table[i + 1][1], table[i + 1][2]
        if x >= x1 and x <= x2 then
            local t = (x - x1) / (x2 - x1)
            return y1 + t * (y2 - y1)
        end
    end
    return 200 -- Default height if out of range
end

local perlin = Perlin.new(58363)
local erosion_perlin = Perlin.new(58364) -- New Perlin noise for erosion
local peaks_perlin = Perlin.new(58365) -- New Perlin noise for peaks and valleys
local weirdness_perlin = Perlin.new(58366) -- New 3D Perlin noise for weirdness

minetest.register_on_generated(function(minp, maxp, seed)
    local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
    local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
    local data = vm:get_data()

    local c_stone = minetest.get_content_id("mcl_core:stone")
    local c_water = minetest.get_content_id("mcl_core:water_source")
    local c_air = minetest.get_content_id("air") -- Air block

    for x = minp.x, maxp.x do
        for z = minp.z, maxp.z do
            local continentalness_value = perlin:noise2d(x, z, 4, 0.5, 300)
            local erosion_value = erosion_perlin:noise2d(x, z, 1, 0.5, 300)
            local peaks_and_valleys_value = peaks_perlin:noise2d(x, z, 6, 0.5, 200)
            local weirdness_value = weirdness_perlin:noise3d(x, minp.y, z, 4, 0.5, 200) -- Get weirdness value in 3D

            -- Interpolate the height based on continentalness
            local height = interpolate(continentalness_value, continentalness_to_height)

            -- Interpolate height reduction based on erosion (higher erosion reduces height more)
            local erosion_reduction = interpolate(erosion_value, erosion_to_height_reduction)
            
            -- Apply erosion effect to the height
            height = height - erosion_reduction

            -- Interpolate height variation based on peaks and valleys (higher values make larger mountains)
            local peak_variation = interpolate(peaks_and_valleys_value, peaks_and_valleys_to_variation)

            -- Apply peaks and valleys effect (higher peak_variation = larger mountains)
            height = height + peak_variation

            -- Disturb the height further with the weirdness value to create more irregular terrain
            height = height + weirdness_value * 100 -- Scale the weirdness to affect terrain more significantly

            -- Generate terrain based on height
            for y = minp.y, maxp.y do
                local vi = area:index(x, y, z)

                -- Decide block type based on height
                if y < height then
                    data[vi] = c_stone
                elseif y <= 64 then
                    data[vi] = c_water
                else
                    data[vi] = c_air -- Anything above water is air
                end
            end
        end
    end

    vm:set_data(data)
    vm:write_to_map()
end)

-- HUD to show continentalness, erosion, and peaks at player's position
local player_huds = {}

minetest.register_globalstep(function()
    for _, player in ipairs(minetest.get_connected_players()) do
        local player_name = player:get_player_name()
        local pos = player:get_pos()
        
        -- Get the continentalness, erosion, and peaks values at the player's position
            local continentalness_value = perlin:noise2d(pos.x, pos.z, 4, 0.5, 300)
            local erosion_value = erosion_perlin:noise2d(pos.x, pos.z, 1, 0.5, 300)
            local peaks_and_valleys_value = peaks_perlin:noise2d(pos.x, pos.z, 6, 0.5, 200)

        -- Update HUD with continentalness, erosion, and peaks
        if not player_huds[player_name] then
            player_huds[player_name] = player:hud_add({
                hud_elem_type = "text",
                position = {x = 0.1, y = 0.1},
                offset = {x = 0, y = 0},
                text = string.format("Continentalness: %.2f  Erosion: %.2f  Peaks: %.2f", continentalness_value, erosion_value, peaks_and_valleys_value),
                scale = {x = 100, y = 100},
                alignment = {x = 1, y = 1},
                number = 0xFFFFFF,
            })
        else
            player:hud_change(player_huds[player_name], "text", 
                string.format("Continentalness: %.2f  Erosion: %.2f  Peaks: %.2f", continentalness_value, erosion_value, peaks_and_valleys_value))
        end
    end
end)]]
--[[local continentalness_to_height = {
    {-1.1, 200},
    {-1.02, 40},
    {-0.51, 40},
    {-0.44, 83},
    {-0.18, 83},
    {-0.16, 126},
    {-0.15, 126},
    {-0.1, 140},
    {0.25, 150},
    {1.0, 150}
}

-- Table for erosion to height reduction
local erosion_to_height_reduction = {
    {-1, -70},
    {-0.8, -40},
    {-0.4, -60},
    {-0.34, -40},
    {-0.1, -10},
    {0.2, 125},
    {0.4, 125},
    {0.45, 80},
    {0.55, 80},
    {0.6, 120},
    {0.8, 130},
    {1, 130}
}

-- Table for peaks and valleys to height variation
local peaks_and_valleys_to_variation = {
    {-1, -20},    -- Flattest terrain at lowest peaks
    {-0.7, 0},
    {-0.4, 10},
    {0.0, 20},
    {0.5, 60},
    {1.0, 110}, -- Largest peaks at highest values
}

-- Function to interpolate height based on a given table
local function interpolate(x, table)
    for i = 1, #table - 1 do
        local x1, y1 = table[i][1], table[i][2]
        local x2, y2 = table[i + 1][1], table[i + 1][2]
        if x >= x1 and x <= x2 then
            local t = (x - x1) / (x2 - x1)
            return y1 + t * (y2 - y1)
        end
    end
    return 200 -- Default height if out of range
end

local perlin = Perlin.new(58363)
local erosion_perlin = Perlin.new(58364) -- New Perlin noise for erosion
local peaks_perlin = Perlin.new(58365) -- New Perlin noise for peaks and valleys
local weirdness_perlin = Perlin.new(58366, 2, 0.5, 10) -- Adjusted 3D Perlin noise settings

local weirdness_squash_factor = 0.5 -- Controls how much the weirdness flattens terrain
local weirdness_y_limit = 100 -- Y limit for weirdness effect
local density_adjustment = 1 -- Controls natural density increase with depth

minetest.register_on_generated(function(minp, maxp, seed)
    local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
    local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
    local data = vm:get_data()

    local c_stone = minetest.get_content_id("mcl_core:stone")
    local c_water = minetest.get_content_id("mcl_core:water_source")
    local c_air = minetest.get_content_id("air") -- Air block

    for x = minp.x, maxp.x do
        for z = minp.z, maxp.z do
            local continentalness_value = perlin:noise2d(x, z, 9, 1, 200)
            local erosion_value = erosion_perlin:noise2d(x, z, 5, 1, 300)
            local peaks_and_valleys_value = peaks_perlin:noise2d(x, z, 6, 1, 100)

            -- Interpolate the height based on continentalness
            local height = interpolate(continentalness_value, continentalness_to_height)

            -- Interpolate height reduction based on erosion (higher erosion reduces height more)
            local erosion_reduction = interpolate(erosion_value, erosion_to_height_reduction)
            
            -- Apply erosion effect to the height
            height = height - erosion_reduction

            -- Interpolate height variation based on peaks and valleys (higher values make larger mountains)
            local peak_variation = interpolate(peaks_and_valleys_value, peaks_and_valleys_to_variation)

            -- Apply peaks and valleys effect (higher peak_variation = larger mountains)
            height = height + peak_variation

            for y = minp.y, maxp.y do
                local weirdness_value = weirdness_perlin:noise3d(x, y, z, 2, 0.5, 10)
                weirdness_value = math.max(-1, math.min(1, weirdness_value)) -- Clamp weirdness
                
                -- Apply squash factor and Y limit
                if y < weirdness_y_limit then
                    weirdness_value = 0
                else
                    weirdness_value = weirdness_value * weirdness_squash_factor
                end
                
                -- Increase density naturally with depth
                local density = weirdness_value + (y * density_adjustment)
                local vi = area:index(x, y, z)

                if y < height then
                        data[vi] = c_stone
                elseif y <= 64 then
                    data[vi] = c_water
                end
            end
        end
    end

    vm:set_data(data)
    vm:write_to_map()
end)

-- HUD to show continentalness, erosion, and peaks at player's position
local player_huds = {}

minetest.register_globalstep(function()
    for _, player in ipairs(minetest.get_connected_players()) do
        local player_name = player:get_player_name()
        local pos = player:get_pos()
        
        -- Get the continentalness, erosion, and peaks values at the player's position
            local continentalness_value = perlin:noise2d(pos.x, pos.z, 9, 1, 300)
            local erosion_value = erosion_perlin:noise2d(pos.x, pos.z, 5, 1, 100)
            local peaks_and_valleys_value = peaks_perlin:noise2d(pos.x, pos.z, 6, 1, 200)

        -- Update HUD with continentalness, erosion, and peaks
        if not player_huds[player_name] then
            player_huds[player_name] = player:hud_add({
                hud_elem_type = "text",
                position = {x = 0.1, y = 0.1},
                offset = {x = 0, y = 0},
                text = string.format("Continentalness: %.2f  Erosion: %.2f  Peaks: %.2f", continentalness_value, erosion_value, peaks_and_valleys_value),
                scale = {x = 100, y = 100},
                alignment = {x = 1, y = 1},
                number = 0xFFFFFF,
            })
        else
            player:hud_change(player_huds[player_name], "text", 
                string.format("Continentalness: %.2f  Erosion: %.2f  Peaks: %.2f", continentalness_value, erosion_value, peaks_and_valleys_value))
        end
    end
end)]]
--[[local continentalness_to_height = {
    {-1.1, 0},      -- Ocean floor
    {-1.02, 10},    -- Shallow waters
    {-0.51, 15},    -- Beaches
    {-0.44, 20},    -- Coastal plains
    {-0.18, 30},   -- Plains
    {-0.16, 40},   -- Rolling hills
    {-0.15, 50},   -- Low mountain ranges
    {-0.1, 60},    -- High mountain foothills
    {0.25, 80},    -- Plateau and large mountains
    {1.0, 140}      -- Tallest mountains
}

-- Table for erosion to height reduction
local erosion_to_height_reduction = {
    {-1, -70},      -- Deep valleys (higher erosion reduces height drastically)
    {-0.8, -40},    
    {-0.4, -30},    
    {-0.34, -20},   
    {-0.1, -10},    
    {0.2, 20},      -- Light erosion (highlands)
    {0.4, 40},      
    {0.45, 60},     -- Strong erosion (river valleys)
    {0.55, 70},     -- Fjords and steep valleys
    {0.6, 80},      
    {0.8, 100},     -- Base level of plateaus
    {1, 130}        -- Erosion-heavy mountain ridges
}

-- Table for peaks and valleys to height variation (adjusted for more dramatic terrains)
local peaks_and_valleys_to_variation = {
    {-1, -20},      -- Flattest terrain at lowest peaks
    {-0.7, 0},      
    {-0.4, 10},     
    {0.0, 20},      
    {0.5, 60},      
    {1.0, 120},     -- Highest peaks at the largest values
}

-- Function to interpolate height based on a given table
local function interpolate(x, table)
    for i = 1, #table - 1 do
        local x1, y1 = table[i][1], table[i][2]
        local x2, y2 = table[i + 1][1], table[i + 1][2]
        if x >= x1 and x <= x2 then
            local t = (x - x1) / (x2 - x1)
            return y1 + t * (y2 - y1)
        end
    end
    return 200 -- Default height if out of range
end

local perlin = Perlin.new(58363)
local erosion_perlin = Perlin.new(58364) -- New Perlin noise for erosion
local peaks_perlin = Perlin.new(58365) -- New Perlin noise for peaks and valleys
local weirdness_perlin = Perlin.new(58366, 2, 0.5, 10) -- Adjusted 3D Perlin noise settings

local weirdness_squash_factor = 0.1 -- Controls how much the weirdness flattens terrain
local weirdness_y_limit = 100 -- Y limit for weirdness effect
local density_adjustment = -0.1 -- Controls natural density increase with depth

minetest.register_on_generated(function(minp, maxp, seed)
    local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
    local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
    local data = vm:get_data()

    local c_stone = minetest.get_content_id("mcl_core:stone")
    local c_water = minetest.get_content_id("mcl_core:water_source")
    local c_air = minetest.get_content_id("air") -- Air block

    for x = minp.x, maxp.x do
        for z = minp.z, maxp.z do
            local continentalness_value = perlin:noise2d(x, z, -9, 0.9, 1)
            local erosion_value = erosion_perlin:noise2d(x, z, -9, 0.6, 1)
            local peaks_and_valleys_value = peaks_perlin:noise2d(x, z, -7, 0.5, 1)

            -- Interpolate the height based on continentalness
            local height = interpolate(continentalness_value, continentalness_to_height)

            -- Interpolate height reduction based on erosion (higher erosion reduces height more)
            local erosion_reduction = interpolate(erosion_value, erosion_to_height_reduction)
            
            -- Apply erosion effect to the height
            height = height - erosion_reduction

            -- Interpolate height variation based on peaks and valleys (higher values make larger mountains)
            local peak_variation = interpolate(peaks_and_valleys_value, peaks_and_valleys_to_variation)

            -- Apply peaks and valleys effect (higher peak_variation = larger mountains)
            height = height + peak_variation

            for y = minp.y, maxp.y do
                local weirdness_value = weirdness_perlin:noise3d(x, y, z, 2, 0.5, 10)
                weirdness_value = math.max(-1, math.min(1, weirdness_value)) -- Clamp weirdness
                
                -- Apply squash factor and Y limit
                if y < weirdness_y_limit then
                    weirdness_value = 0
                else
                    weirdness_value = weirdness_value * weirdness_squash_factor
                end
                
                -- Increase density naturally with depth
                local density = weirdness_value + (y * density_adjustment)
                local vi = area:index(x, y, z)

                if y < height then
                        data[vi] = c_stone
                elseif y <= 64 then
                    data[vi] = c_water
                end
            end
        end
    end

    vm:set_data(data)
    vm:write_to_map()
end)

-- HUD to show continentalness, erosion, and peaks at player's position
local player_huds = {}

minetest.register_globalstep(function()
    for _, player in ipairs(minetest.get_connected_players()) do
        local player_name = player:get_player_name()
        local pos = player:get_pos()
        
        -- Get the continentalness, erosion, and peaks values at the player's position
            local continentalness_value = perlin:noise2d(x, z, -9, 0.9, 1)
            local erosion_value = erosion_perlin:noise2d(x, z, -9, 0.6, 1)
            local peaks_and_valleys_value = peaks_perlin:noise2d(x, z, -7, 0.5, 1)

        -- Update HUD with continentalness, erosion, and peaks
        if not player_huds[player_name] then
            player_huds[player_name] = player:hud_add({
                hud_elem_type = "text",
                position = {x = 0.1, y = 0.1},
                offset = {x = 0, y = 0},
                text = string.format("Continentalness: %.2f  Erosion: %.2f  Peaks: %.2f", continentalness_value, erosion_value, peaks_and_valleys_value),
                scale = {x = 100, y = 100},
                alignment = {x = 1, y = 1},
                number = 0xFFFFFF,
            })
        else
            player:hud_change(player_huds[player_name], "text", 
                string.format("Continentalness: %.2f  Erosion: %.2f  Peaks: %.2f", continentalness_value, erosion_value, peaks_and_valleys_value))
        end
    end
end)
]]

local continentalness_to_height = {
    {-1.1, 100},
    {-1.02, 10},
    {-0.51, 10},
    {-0.44, 30},
    {-0.18, 30},
    {-0.16, 80},
    {-0.15, 86},
    {-0.1, 93},
    {0.25, 96},
    {1.0, 100}
}

-- Table for erosion to height reduction
local erosion_to_height_reduction = {
    {-1, 0},
    {-0.8, 30},
    {-0.4, 40},
    {-0.34, 60},
    {-0.1, 80},
    {0.2, 125},
    {0.4, 125},
    {0.45, 80},
    {0.55, 80},
    {0.6, 120},
    {0.8, 130},
    {1, 130}
}

-- Table for erosion to flatten terrain
--[[local erosion_to_flattening = {
    {-1, 1},   -- No flattening at lowest erosion
    {-0.8, 0.6},
    {-0.4, 0.5},
    {-0.34, 0.55},
    {-0.1, 0.2},
    {0.3, 0.15},
    {0.4, 0.1},
    {0.45, 0.3},
    {0.55, 3},
    {0.6, 0.1},
    {0.8, 0.05},
    {1, 0}     -- Full flattening at highest erosion
}]]


-- Table for peaks and valleys to height variation
local peaks_and_valleys_to_variation = {
    {-1, 20},    -- Flattest terrain at lowest peaks
    {-0.7, 10},
    {-0.4, 50},
    {0.0, 60},
    {0.2, 70},
    {0.5, 90},
    {0.7, 100},
    {1.0, 190}, -- Largest peaks at highest values
}

-- Function to interpolate height based on a given table
local function interpolate(x, table)
    for i = 1, #table - 1 do
        local x1, y1 = table[i][1], table[i][2]
        local x2, y2 = table[i + 1][1], table[i + 1][2]
        if x >= x1 and x <= x2 then
            local t = (x - x1) / (x2 - x1)
            return y1 + t * (y2 - y1)
        end
    end
    return 200 -- Default height if out of range
end

-- Ensure amplitude_table is declared before usage

local perlin = Perlin.new(58363)
local erosion_perlin = Perlin.new(58364) -- New Perlin noise for erosion
local peaks_perlin = Perlin.new(58365) -- New Perlin noise for peaks and valleys
local weirdness_perlin = Perlin.new(58366, 2, 0.5, 10) -- Adjusted 3D Perlin noise settings

local weirdness_squash_factor = 0.1 -- Controls how much the weirdness flattens terrain
local weirdness_y_limit = 100 -- Y limit for weirdness effect
local density_adjustment = -0.1 -- Controls natural density increase with depth



minetest.register_on_generated(function(minp, maxp, seed)
    local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
    local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
    local data = vm:get_data()

    local c_stone = minetest.get_content_id("mcl_core:stone")
    local c_water = minetest.get_content_id("mcl_core:water_source")
    local c_air = minetest.get_content_id("air") -- Air block


    for x = minp.x, maxp.x do
        for z = minp.z, maxp.z do
            -- Adjusted noise calls with amplitude table and first octave
            --[[local continentalness_value = perlin:noise2d(x, z, #{1, 1, 1, 1, 1, 0.5, 0.5, 0.5, 0.5}, 0.4, 5000, {0.5, 0.5, 1, 1, 1, 0.5, 0.5, 0.5, 0.5}, 9)
            local erosion_value = erosion_perlin:noise2d(x, z, #{1,1,0,1,1}, 0.1, 10000, {1,1,0,0.5,0.5}, 9)
            local peaks_and_valleys_value = peaks_perlin:noise2d(x, z, #{1,1,1,0,0,0}, 1, 2000, {1,2,1,0,0,0}, 7)]]
            local continentalness_value = perlin:noise2d(x, z, 9, 0.4, 500)
            local erosion_value = erosion_perlin:noise2d(x, z, 5, 0.1, 100)
            local peaks_and_valleys_value = peaks_perlin:noise2d(x, z, 6, 1, 200)

            -- Interpolate the height based on continentalness
            local height = interpolate(continentalness_value, continentalness_to_height)

            -- Interpolate height reduction based on erosion (higher erosion reduces height more)
            local erosion_reduction = interpolate(erosion_value, erosion_to_height_reduction)
            
            -- Apply erosion effect to the height
            height = height - erosion_reduction

            -- Interpolate height variation based on peaks and valleys (higher values make larger mountains)
            local peak_variation = interpolate(peaks_and_valleys_value, peaks_and_valleys_to_variation)

            -- Apply peaks and valleys effect (higher peak_variation = larger mountains)
            height = height + peak_variation
           
           -- Get flattening effect from erosion value
			--[[local flattening_factor = interpolate(erosion_value, erosion_to_flattening)

			-- Adjust peak variation using flattening factor
			local peak_variation = interpolate(peaks_and_valleys_value, peaks_and_valleys_to_variation) * flattening_factor

			-- Apply adjusted peak variation instead of height reduction
			height = height + peak_variation]]
	

            for y = minp.y, maxp.y do
                local weirdness_value = weirdness_perlin:noise3d(x, y, z, 2, 0.5, 10, {1,1,1}, 9)
                weirdness_value = math.max(-1, math.min(1, weirdness_value)) -- Clamp weirdness
               
                
                -- Increase density naturally with depth
                local density = weirdness_value + (y * density_adjustment)
                local vi = area:index(x, y, z)

                if y < height then
                    data[vi] = c_stone
                elseif y <= 64 then
                    data[vi] = c_water
                end
            end
        end
    end

    vm:set_data(data)
    vm:write_to_map()
end)


-- HUD to show continentalness, erosion, and peaks at player's position
local player_huds = {}

minetest.register_globalstep(function()
    for _, player in ipairs(minetest.get_connected_players()) do
        local player_name = player:get_player_name()
        local pos = player:get_pos()
        local x = pos.x
        local z = pos.z

        -- Get the continentalness, erosion, and peaks values at the player's position
            --[[local continentalness_value = perlin:noise2d(x, z, #{1, 1, 1, 1, 1, 0.5, 0.5, 0.5, 0.5}, 0.1, 5000, {0.5, 0.5, 1, 1, 1, 0.5, 0.5, 0.5, 0.5}, 9)
            local erosion_value = erosion_perlin:noise2d(x, z, #{1,1,0,1,1}, 0.1, 10000, {1,1,0,0.5,0.5}, 9)
            local peaks_and_valleys_value = peaks_perlin:noise2d(x, z, #{1,1,1,0,0,0}, 1, 2000, {1,2,1,0,0,0}, 7)]]
            local continentalness_value = perlin:noise2d(x, z, 9, 0.4, 500)
            local erosion_value = erosion_perlin:noise2d(x, z, 5, 0.1, 100)
            local peaks_and_valleys_value = peaks_perlin:noise2d(x, z, 6, 1, 200)

        -- Update HUD with continentalness, erosion, and peaks
        if not player_huds[player_name] then
            player_huds[player_name] = player:hud_add({
                hud_elem_type = "text",
                position = {x = 0.1, y = 0.1},
                offset = {x = 0, y = 0},
                text = string.format("Continentalness: %.2f  Erosion: %.2f  Peaks: %.2f", continentalness_value, erosion_value, peaks_and_valleys_value),
                scale = {x = 100, y = 100},
                alignment = {x = 1, y = 1},
                number = 0xFFFFFF,
            })
        else
            player:hud_change(player_huds[player_name], "text", 
                string.format("Continentalness: %.2f  Erosion: %.2f  Peaks: %.2f", continentalness_value, erosion_value, peaks_and_valleys_value))
        end
    end
end)
