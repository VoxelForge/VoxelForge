local mod_mcl_core = minetest.get_modpath("mcl_core")
------ LIGHTING
minetest.register_on_generated(function(minp, maxp, seed)
    local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
    if not vm then
        return
    end

    local light_data = vm:get_light_data()
    local area = VoxelArea:new{MinEdge = emin, MaxEdge = emax}

    local light_threshold = 4
    local light_value = 4

    -- Iterate over all positions in the chunk
    for z = minp.z, maxp.z do
        for y = minp.y, maxp.y do
            for x = minp.x, maxp.x do
                local vi = area:index(x, y, z) -- Get the voxel index
                local current_light = light_data[vi]
                if current_light < light_threshold then
                    -- Set the new light value
                    light_data[vi] = light_value
                end
            end
        end
    end

    -- Write the updated light data back
    vm:set_light_data(light_data)
    vm:write_to_map()
    vm:update_liquids()
end)
------ MEADOW
minetest.register_biome({
		name = "Meadow",
		node_top = "mcl_core:dirt_with_grass",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 2,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 10,
		y_max = mcl_vars.mg_overworld_max,
		humidity_point = 80,
		heat_point = 50,
		_mcl_biome_type = "cold",
		_mcl_palette_index = 3,
		_mcl_water_palette_index = 6,
		_mcl_skycolor = "#839EFF",
		_mcl_fogcolor = "#C0D8FF",
	})
---------
minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
		sidelen = 16,
		fill_ratio = 0.0002,
		biomes = {"Meadow"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		schematic = mod_mcl_core.."/schematics/mcl_core_oak_classic_bee_nest.mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
		spawn_by = "group:flower",
	})
minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"group:grass_block"},
		sidelen = 16,
		noise_params = {
			offset = 0.0,
			scale = 0.09,
			spread = {x = 15, y = 15, z = 15},
			seed = 420,
			octaves = 3,
			persist = 0.6,
		},
		biomes = {"Meadow"},
		y_min = 20,
		y_max = mcl_vars.mg_overworld_max,
		schematic = {
			size = { x=1, y=2, z=1 },
			data = {
				{ name = "vlf_core:dirt_with_grass", force_place=true, },
				{ name = "vlf_flowers:tallgrass", param2 = minetest.registered_biomes["Meadow"]._mcl_palette_index },
			},
		},
	})
    local register_flower = mcl_biomes.register_flower
    register_flower("azure_bluet", {"Meadow"}, 40)
	register_flower("oxeye_daisy", {"Meadow"}, 47)
	register_flower("dandelion", {"Meadow"}, 16)
	register_flower("poppy", {"Meadow"}, 47)
	register_flower("cornflower", {"Meadow"}, 24)
	register_flower("allium", {"Meadow"} , 15)
------ GROVE
minetest.register_biome({
		name = "Grove",
		node_dust = "mcl_core:snow",
		node_top = "mcl_core:snowblock",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 2,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 3,
		y_max = mcl_vars.mg_overworld_max,
		humidity_point = 116,
		heat_point = 16,
		_mcl_biome_type = "snowy",
		_mcl_palette_index = 3,
		_mcl_water_palette_index = 8,
		_mcl_skycolor = "#839EFF",
		_mcl_fogcolor = "#C0D8FF",
	})
local function quick_spruce(seed, offset, sprucename, biomes, y)
		if not y then
			y = 1
		end
		minetest.register_decoration({
			deco_type = "schematic",
			place_on = {"group:grass_block", "mcl_core:dirt", "mcl_core:podzol", "mcl_core:snowblock"},
			sidelen = 16,
			noise_params = {
				offset = offset,
				scale = 0.0006,
				spread = {x = 250, y = 250, z = 250},
				seed = seed,
				octaves = 3,
				persist = 0.66
			},
			biomes = biomes,
			y_min = y,
			y_max = mcl_vars.mg_overworld_max,
			schematic = mod_mcl_core.."/schematics/"..sprucename,
			flags = "place_center_x, place_center_z",
		})
	end

	-- Huge spruce
	quick_spruce(11000, 0.00150, "mcl_core_spruce_5.mts", {"Grove"})

	quick_spruce(2500, 0.00325, "mcl_core_spruce_1.mts", {"Grove"})
	quick_spruce(7000, 0.00425, "mcl_core_spruce_3.mts", {"Grove"})
	quick_spruce(9000, 0.00325, "mcl_core_spruce_4.mts", {"Grove"})

	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"group:grass_block", "mcl_core:podzol"},
		sidelen = 16,
		noise_params = {
			offset = 0.004,
			scale = 0.0022,
			spread = {x = 250, y = 250, z = 250},
			seed = 2500,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"Grove"},
		y_min = 2,
		y_max = mcl_vars.mg_overworld_max,
		schematic = mod_mcl_core.."/schematics/mcl_core_spruce_lollipop.mts",
		flags = "place_center_x, place_center_z",
	})

	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"mcl_core:snowblock", "mcl_core:dirt"},
		sidelen = 16,
		noise_params = {
			offset = 0.004,
			scale = 0.0022,
			spread = {x = 250, y = 250, z = 250},
			seed = 2500,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"Grove"},
		y_min = 2,
		y_max = mcl_vars.mg_overworld_max,
		schematic = mod_mcl_core.."/schematics/mcl_core_spruce_lollipop.mts",
		flags = "place_center_x, place_center_z",
	})

	-- Matchstick spruce: Very few leaves, tall trunk
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"group:grass_block", "mcl_core:podzol"},
		sidelen = 80,
		noise_params = {
			offset = -0.025,
			scale = 0.025,
			spread = {x = 250, y = 250, z = 250},
			seed = 2566,
			octaves = 5,
			persist = 0.60,
		},
		biomes = {"Grove"},
		y_min = 3,
		y_max = mcl_vars.mg_overworld_max,
        schematic = mod_mcl_core.."/schematics/mcl_core_spruce_matchstick.mts",
		flags = "place_center_x, place_center_z",
	})
	-- Grove Tree.
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"mcl_core:snowblock", "mcl_core:dirt"},
		sidelen = 80,
		noise_params = {
			offset = -0.025,
			scale = 0.025,
			spread = {x = 250, y = 250, z = 250},
			seed = 2566,
			octaves = 5,
			persist = 0.60,
		},
		biomes = {"Grove"},
		y_min = 3,
		y_max = mcl_vars.mg_overworld_max,
		schematic = mod_mcl_core.."/schematics/mcl_core_spruce_matchstick.mts",
		flags = "place_center_x, place_center_z",
	})
------
