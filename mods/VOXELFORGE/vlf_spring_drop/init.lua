-- Leaf Litter
minetest.register_craftitem(":voxelforge:leaf_litter", {
    description = "Leaf Litter",
    inventory_image = "leaf_litter_4.png",
    wield_image = "leaf_litter_4.png",
    groups = {craftitem=1},
    stack_max = 64,
    
    on_place = function(itemstack, placer, pointed_thing)
        if not pointed_thing or not pointed_thing.under then
            return itemstack
        end

        local pos = pointed_thing.under
        local node = minetest.get_node(pos)
        local above_pos = {x=pos.x, y=pos.y+1, z=pos.z}
        local above_node = minetest.get_node(above_pos)
        local node_def = minetest.registered_nodes[node.name]
        
        -- Swap the node in place if it's part of the progression
        local swap_map = {
            ["voxelforge:leaf_litter_1"] = "voxelforge:leaf_litter_2",
            ["voxelforge:leaf_litter_2"] = "voxelforge:leaf_litter_3",
            ["voxelforge:leaf_litter_3"] = "voxelforge:leaf_litter_4",
        }
        
        if swap_map[node.name] then
            minetest.set_node(pos, {name = swap_map[node.name]})
        else
            -- If not already part of the cycle, place _1 above
            if above_node.name == "air" and not (node_def and node_def.groups and node_def.groups.leaf and node_def.groups.leaf > 0 and node_def.groups.leaf < 5) then
                minetest.set_node(above_pos, {name = "voxelforge:leaf_litter_1"})
            end
        end

        return itemstack
    end
})



for i = 1,4 do
minetest.register_node(":voxelforge:leaf_litter_"..i, {
	description = ("Leaf Litter"),
	drawtype = "signlike",
	tiles = {"leaf_litter_"..i..".png"},
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "none",
	walkable = false,
	climbable = false,
	buildable_to = true,
	selection_box = {
		type = "wallmounted",
	},
	groups = {
		handy = 1, shearsy = 1, hoey = 1, swordy = 1, deco_block = 1,
		dig_by_piston = 1, leaf = i, attached_block = 1, dig_by_water = 1, destroy_by_lava_flow = 1,
	},
	drop = "voxelforge:leaf_litter " ..i,
	_mcl_shears_drop = true,
	node_placement_prediction = "",
	_mcl_blast_resistance = 0.2,
	_mcl_hardness = 0.2,
	on_rotate = false,
})
end
-- Wildflowers.

minetest.register_craftitem(":voxelforge:wildflowers", {
    description = "Wildflowers",
    inventory_image = "wildflower.png",
    wield_image = "wildflower.png",
    groups = {craftitem=1},
    
    on_place = function(itemstack, placer, pointed_thing)
        if not pointed_thing or not pointed_thing.under then
            return itemstack
        end

        local pos = pointed_thing.under
        local node = minetest.get_node(pos)
        local above_pos = {x=pos.x, y=pos.y+1, z=pos.z}
        local above_node = minetest.get_node(above_pos)
        local node_def = minetest.registered_nodes[node.name]
        
        -- Swap the node in place if it's part of the progression
        local swap_map = {
            ["voxelforge:wildflower_1"] = "voxelforge:wildflower_2",
            ["voxelforge:wildflower_2"] = "voxelforge:wildflower_3",
            ["voxelforge:wildflower_3"] = "voxelforge:wildflower_4",
        }
        
        if swap_map[node.name] then
            minetest.set_node(pos, {name = swap_map[node.name]})
        else
            -- If not already part of the cycle, place _1 above
            if above_node.name == "air" and not (node_def and node_def.groups and node_def.groups.wildflower and node_def.groups.wildflower > 0 and node_def.groups.wildflower < 5) then
                minetest.set_node(above_pos, {name = "voxelforge:wildflower_1"})
            end
        end

        return itemstack
    end
})



for i = 1,4 do
minetest.register_node(":voxelforge:wildflower_"..i, {
	description = ("WildFlower"),
	drawtype = "mesh",
	tiles = {"wildflower.png", "wildflower_stem.png"},
	paramtype = "light",
    mesh = "wildflower_"..i..".obj",
	sunlight_propagates = true,
	walkable = false,
	climbable = false,
	buildable_to = true,
    selection_box = {type = "fixed", fixed = {-1/2, -1/2, -1/2, 1/2, -5/16, 1/2}},
    stack_max = 64,
	groups = {
		handy = 1, hoey = 1, shearsy = 1, swordy = 1, deco_block = 1,
		dig_by_piston = 1, wildflower = i, attached_block = 1, dig_by_water = 1, destroy_by_lava_flow = 1,
	},
	drop = "voxelforge:wildflowers " ..i,
	_mcl_shears_drop = true,
	node_placement_prediction = "",
    use_texture_alpha = "clip",
	_mcl_blast_resistance = 0.2,
	_mcl_hardness = 0.2,
	on_rotate = false,
})
end

-- FireFly Bush

minetest.register_node(":voxelforge:firefly_bush", {
    description = "Firefly Bush",
    tiles = {"default_wood.png"},
    groups = {choppy = 2, oddly_breakable_by_hand = 1},
})

minetest.register_abm({
    label = "Firefly Emitter Behavior",
    nodenames = {"voxelforge:firefly_bush"},
    interval = 3.0,  -- Runs every 3 seconds
    chance = 1,  -- Runs on all matching nodes
    catch_up = false,
    --bulk_abm = true,  -- Enables bulk processing

    action = function(pos)
        local time_of_day = minetest.get_timeofday()
        if time_of_day < 0.2 or time_of_day > 0.8 then -- Nighttime
            --for _, pos in ipairs(pos_list) do
                local above = {x = pos.x, y = pos.y + 1, z = pos.z}
                local above_node = minetest.get_node_or_nil(above)

                if above_node and above_node.name == "air" then
                    minetest.sound_play("firefly_sound", {pos = pos, gain = 0.5, max_hear_distance = 10})

                    local light_level = minetest.get_node_light(pos) or 0
                    if light_level < 5 then
                        minetest.add_particlespawner({
                            amount = 5,
                            time = 2,
                            glow = 10,
                            minpos = {x = pos.x - 2.5, y = pos.y, z = pos.z - 2.5},
                            maxpos = {x = pos.x + 2.5, y = pos.y + 2.5, z = pos.z + 2.5},
                            minvel = {x = 0, y = 0.2, z = 0},
                            maxvel = {x = 0, y = 0.4, z = 0},
                            minacc = {x = 0, y = 0, z = 0},
                            maxacc = {x = 0, y = 0, z = 0},
                            minexptime = 1,
                            maxexptime = 2,
                            minsize = 1,
                            maxsize = 2,
                            texpool = {
			{
				name = "default_wood.png^[colorize:#FFFF00",
				scale = {x = 1, y = 1},
				alpha_tween = {{x = 1, y = 1}, {x = 0, y = 0}}
			},
                        {
				name = "default_wood.png^[colorize:#FFFF00",
				scale = {x = 1, y = 1},
				alpha_tween = {{x = 1, y = 1}, {x = 0, y = 0}}
			},
		},
                        })
                    end
                --end
            end
        end
    end
})


-----------------
---===MAPGEN===--
-----------------
----- WildFlower
minetest.register_decoration({
		deco_type = "simple",
		place_on = {"mcl_core:dirt_with_grass"},
		fill_ratio = 0.03,
		biomes = {"BirchForest", "BirchForestM", "Meadow"},
		y_min = mcl_vars.mg_overworld_min,
		y_max = mcl_vars.mg_overworld_max,
		decoration = "voxelforge:wildflower_1",
	})
minetest.register_decoration({
		deco_type = "simple",
		place_on = {"mcl_core:dirt_with_grass"},
		fill_ratio = 0.03,
		biomes = {"BirchForest", "BirchForestM", "Meadow"},
		y_min = mcl_vars.mg_overworld_min,
		y_max = mcl_vars.mg_overworld_max,
		decoration = "voxelforge:wildflower_2",
	})
minetest.register_decoration({
		deco_type = "simple",
		place_on = {"mcl_core:dirt_with_grass"},
		fill_ratio = 0.03,
		biomes = {"BirchForest", "BirchForestM", "Meadow"},
		y_min = mcl_vars.mg_overworld_min,
		y_max = mcl_vars.mg_overworld_max,
		decoration = "voxelforge:wildflower_3",
	})
minetest.register_decoration({
		deco_type = "simple",
		place_on = {"mcl_core:dirt_with_grass"},
		fill_ratio = 0.03,
		biomes = {"BirchForest", "BirchForestM", "Meadow"},
		y_min = mcl_vars.mg_overworld_min,
		y_max = mcl_vars.mg_overworld_max,
		decoration = "voxelforge:wildflower_4",
	})
----- Fallen Leaves
minetest.register_decoration({
		deco_type = "simple",
		place_on = {"mcl_core:dirt_with_grass"},
		fill_ratio = 0.05,
		biomes = {"Forest", "RoofedForest", "MesaPlateauF_grasstop", "MesaPlateauFM_grasstop"},
		y_min = mcl_vars.mg_overworld_min,
		y_max = mcl_vars.mg_overworld_max,
		decoration = "voxelforge:leaf_litter_1",
	})
minetest.register_decoration({
		deco_type = "simple",
		place_on = {"mcl_core:dirt_with_grass"},
		fill_ratio = 0.05,
		biomes = {"Forest", "RoofedForest", "MesaPlateauF_grasstop", "MesaPlateauFM_grasstop"},
		y_min = mcl_vars.mg_overworld_min,
		y_max = mcl_vars.mg_overworld_max,
		decoration = "voxelforge:leaf_litter_2",
	})
minetest.register_decoration({
		deco_type = "simple",
		place_on = {"mcl_core:dirt_with_grass"},
		fill_ratio = 0.05,
		biomes = {"Forest", "RoofedForest", "MesaPlateauF_grasstop", "MesaPlateauFM_grasstop"},
		y_min = mcl_vars.mg_overworld_min,
		y_max = mcl_vars.mg_overworld_max,
		decoration = "voxelforge:leaf_litter_3",
	})
minetest.register_decoration({
		deco_type = "simple",
		place_on = {"mcl_core:dirt_with_grass"},
		fill_ratio = 0.05,
		biomes = {"Forest", "RoofedForest", "MesaPlateauF_grasstop", "MesaPlateauFM_grasstop"},
		y_min = mcl_vars.mg_overworld_min,
		y_max = mcl_vars.mg_overworld_max,
		decoration = "voxelforge:leaf_litter_4",
	})
