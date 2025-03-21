vlf_luscious = {}

local mgp = minetest.get_mapgen_params()
local chunksize = 16 * mgp.chunksize

-- Function to blend biomes, specifically with _c biomes' properties
function vlf_luscious.blend_biome_color(pos)
    local blend_distance = 5
    local heat_total, humidity_total, count = 0, 0, 0
    local is_c_biome = false

    -- Cache the biome data within a smaller range of blocks
    for x = -blend_distance, blend_distance do
        for z = -blend_distance, blend_distance do
            local sample_pos = {x = pos.x + x, y = pos.y, z = pos.z + z}
            local biome_data = minetest.get_biome_data(sample_pos)

            -- Check if biome data is found and valid
            if biome_data and biome_data.biome then
                local biome_name = minetest.get_biome_name(biome_data.biome)
                local biome = minetest.registered_biomes[biome_name]

                if biome and biome.temperature_c and biome.downfall_c then
                    -- The biome is _c, meaning it uses temperature_c and downfall_c
                    is_c_biome = true
                    -- Add temperature and downfall for blending
                    heat_total = heat_total + biome.temperature_c
                    humidity_total = humidity_total + biome.downfall_c
                    count = count + 1
                elseif biome and biome.temperature and biome.downfall then
                    -- The biome is a normal biome
                    -- Normal biomes blend with each other
                    heat_total = heat_total + biome.temperature
                    humidity_total = humidity_total + biome.downfall
                    count = count + 1
                end
            end
        end
    end

    -- If no valid biomes are found, return default color (136)
    if count == 0 then
        return 136  -- Default palette index
    end

    -- Calculate the average heat and humidity
    local heat = math.floor(math.min(math.max(math.floor(heat_total / count), 0), 100) / 6.6)
    local humidity = math.floor(math.min(math.max(math.floor(humidity_total / count), 0), 100) / 6.6)

    -- If the biome is _c, apply _c values for blending
    if is_c_biome then
        -- Use _c temperature_c and downfall_c to calculate param2
        local temp_c = math.floor(heat_total / count / 6.6)
        local down_c = math.floor(humidity_total / count / 6.6)
        return temp_c + (down_c * 16)
    end

    -- For normal biomes, blend normally
    return heat + (humidity * 16)
end

function vlf_luscious.on_construct(pos)
    local node = minetest.get_node(pos)
    node.param2 = vlf_luscious.blend_biome_color(pos)
    minetest.swap_node(pos, node)
end

core.register_mapgen_script(minetest.get_modpath("vlf_luscious").."/mg.lua")
