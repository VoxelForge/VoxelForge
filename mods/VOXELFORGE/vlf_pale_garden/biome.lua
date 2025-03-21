local schem = minetest.get_modpath("vlf_pale_garden")

minetest.register_biome({
		name = "PaleGarden",
		node_top = "mcl_core:dirt_with_grass",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 0,
		y_max = mcl_vars.mg_overworld_max,
		--humidity_point = 70,
		--heat_point = 60,
		humidity_point = 90,
		heat_point = 25,
		_mcl_biome_type = "medium",
		_mcl_palette_index = 30,
		_mcl_skycolor = "#B9B9B9",
		_mcl_water_palette_index = 9,
		_mcl_fogcolor = "#817770"
	})

--====================--
--=== Pale Garden. ===--
--====================--
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"group:grass_block_no_snow"},
		sidelen = 16,
		noise_params = {
			offset = 0.01,
			scale = 0.0015,
			spread = {x = 100, y = 100, z = 100},
			seed = 223,
			octaves = 3,
			persist = 0.55
		},
		biomes = {"PaleGarden", "PaleGarden_ocean"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		schematic = schem.."/schems/pale_oak_tree_1.mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"group:grass_block_no_snow"},
		sidelen = 16,
		noise_params = {
			offset = 0.007,
			scale = 0.0015,
			spread = {x = 100, y = 100, z = 100},
			seed = 483,
			octaves = 3,
			persist = 0.55
		},
		biomes = {"PaleGarden", "PaleGarden_ocean"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		schematic = schem.."/schems/pale_oak_tree_2.mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"group:grass_block_no_snow"},
		sidelen = 16,
		noise_params = {
			offset = 0.006,
			scale = 0.0015,
			spread = {x = 100, y = 100, z = 100},
			seed = 5836,
			octaves = 3,
			persist = 0.55
		},
		biomes = {"PaleGarden", "PaleGarden_ocean"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		schematic = schem.."/schems/pale_oak_tree_3.mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"group:grass_block_no_snow"},
		sidelen = 16,
		noise_params = {
			offset = 0.004,
			scale = 0.0015,
			spread = {x = 100, y = 100, z = 100},
			seed = 4830,
			octaves = 3,
			persist = 0.55
		},
		biomes = {"PaleGarden", "PaleGarden_ocean"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		schematic = schem.."/schems/pale_oak_tree_4.mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"group:grass_block_no_snow"},
		sidelen = 16,
		noise_params = {
			offset = 0.005,
			scale = 0.0015,
			spread = {x = 100, y = 100, z = 100},
			seed = 67483,
			octaves = 3,
			persist = 0.55
		},
		biomes = {"PaleGarden", "PaleGarden_ocean"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		schematic = schem.."/schems/pale_oak_tree_5.mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})

mcl_structures.register_structure("pale_moss", {
	place_on = {"mcl_core:dirt_with_grass"},
	sidelen = 80,
	noise_params = {
		offset = 0.016,
		scale = 0.00004,
		spread = {x = 500, y = 500, z = 500},
		seed = 2137,
		octaves = 4,
		persist = 0.67,
	},
	biomes = {"PaleGarden"},
	y_min = 1,
	y_max = mcl_vars.mg_overworld_max,
	place_func = function(pos)

		local pale_oak_found = false
		local moss_positions = {}

		-- Search for pale oak trees and valid dirt_with_grass positions around them
		for i = -4, 4 do
			for j = -4, 4 do
				local check_pos = vector.offset(pos, i, 0, j)
				local check_node = minetest.get_node(check_pos).name
				-- Check for pale oak tree
				if check_node == "mcl_trees:tree_pale_oak" then
					pale_oak_found = true
					-- Search for dirt_with_grass nodes within the 4-block radius
					for x = -4, 4 do
						for z = -4, 4 do
							local grass_pos = vector.offset(check_pos, x, 0, z)
							local ground_node = minetest.get_node(grass_pos).name
							-- Place moss only where dirt_with_grass exists
							if ground_node == "mcl_core:dirt_with_grass" then
								table.insert(moss_positions, grass_pos)
								minetest.set_node(grass_pos, {name = "vlf_pale_garden:pale_moss"})
							end
						end
					end
				end
			end
		end

		-- If pale oak found, place tallgrass, carpet, or leave air on top of moss blocks
		if pale_oak_found then
			for _, moss_pos in ipairs(moss_positions) do
				local top_choice = math.random(3)
				local top_pos = vector.offset(moss_pos, 0, 1, 0)
				if top_choice == 1 and minetest.get_node(top_pos).name == "air" then
					minetest.set_node(top_pos, {name = "vlf_pale_garden:pale_moss_carpet"})  -- Place carpet
				elseif top_choice == 2 and minetest.get_node(top_pos).name == "air" then
					local param2 = minetest.registered_biomes["PaleGarden"]._mcl_palette_index
					minetest.set_node(top_pos, {name = "vlf_flowers:tallgrass", param2=param2})  -- Place tallgrass
				--[[elseif
					-- Leave air on top
					minetest.set_node(top_pos, {name = "air"})]]
				end
			end
		end

		return true
	end
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
	sidelen = 80,
	noise_params= {
		offset = 0.0008*40,
		scale = 0.003,
		spread = {x = 100, y = 100, z = 100},
		seed = 575663,
		octaves = 3,
		persist = 0.6,
	},
	y_min = 1,
	y_max = mcl_vars.mg_overworld_max,
	biomes = {"PaleGarden"},
	decoration = "vlf_pale_garden:closed_eyeblossom",
})
