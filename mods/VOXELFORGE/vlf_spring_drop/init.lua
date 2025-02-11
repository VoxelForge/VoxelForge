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
    waving = 1,
	tiles = {"firefly_bush.png"},
	inventory_image = "firefly_bush.png",
    drawtype = "plantlike",
	wield_image = "firefly_bush.png",
	selection_box = {
		type = "fixed",
		fixed = {{ -6/16, -8/16, -6/16, 6/16, 4/16, 6/16 }},
	},
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	buildable_to = true,
	groups = {
		handy = 1, shearsy = 1, attached_node = 1, deco_block = 1,
		plant = 1, place_flowerlike = 2, non_mycelium_plant = 1,
		flammable = 3, fire_encouragement = 60, fire_flammability = 10, dig_by_piston = 1,
		dig_by_water = 1, destroy_by_lava_flow = 1, compostability = 30, grass_palette = 1
	},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	drop = mcl_flowers.wheat_seed_drop,
	_mcl_shears_drop = true,
	_mcl_fortune_drop = mcl_flowers.fortune_wheat_seed_drop,
	node_placement_prediction = "",
	on_place = mcl_flowers.on_place_flower,
    light_source = 3,
	_mcl_blast_resistance = 0,
	_mcl_hardness = 0,
    use_texture_alpha = "clip",
	_on_bone_meal = mcl_flowers.on_bone_meal,
    on_construct = function(pos)
		minetest.add_entity(pos, "voxelforge:firefly_bush_emissive")
        end,
})

minetest.register_entity(":voxelforge:firefly_bush_emissive", {
    initial_properties = {
		pointable = false,
		visual = "mesh",
		mesh = "plantlike.obj",
		visual_size = {x = 10, y = 10},
		textures = {"firefly_bush_emissive.png^[verticalframe:10:0"},
		glow = 15,
	},

    timer = 0,
    frame = 0,
    on_activate = function(self)
        self.object:set_yaw(math.rad(270))  -- Rotate -90 degrees
    end,

    on_step = function(self, dtime)
        self.timer = self.timer + dtime
        if self.timer >= 0.1 then  -- Change frame every 0.2 seconds
            self.timer = 0
            self.frame = (self.frame + 1) % 10  -- Loop through 4 frames
            self.object:set_properties({
                textures = {"firefly_bush_emissive.png^[verticalframe:10:" .. self.frame}
            })
            local pos = self.object:get_pos()
            local node = minetest.get_node(pos)
            if node.name ~= "voxelforge:firefly_bush" then
                self.object:remove()
                return
            end
        end
    end,
})


minetest.register_abm({
    label = "Firefly Emitter Behavior",
    nodenames = {"voxelforge:firefly_bush"},
    interval = 1.0,  -- Runs every 3 seconds
    chance = 1,  -- Runs on all matching nodes
    catch_up = false,

    action = function(pos)
        local time_of_day = minetest.get_timeofday()
            if time_of_day < 0.2 or time_of_day > 0.8 then -- Nighttime
                local above = {x = pos.x, y = pos.y + 1, z = pos.z}
                local above_node = minetest.get_node_or_nil(above)

                if above_node and above_node.name == "air" then
                    minetest.sound_play("Fireflies", {pos = pos, gain = 0.03, max_hear_distance = 10})
                end
            end

            local light_level = minetest.get_node_light(pos)
                if light_level < 7 then
                    local particle_lifetime = math.random(36, 180) / 20  -- Convert ticks to seconds
                    local size = 0.5  -- Scale of the particle
                    local vel = {
                        x = math.random(-50, 50) / 100,
                        y = math.random(-50, 50) / 100,
                        z = math.random(-50, 50) / 100
                    }

                    minetest.add_particlespawner({
                        amount = 2,
                           time = particle_lifetime,
                           minpos = {x = pos.x - 5, y = pos.y - 5, z = pos.z - 5},
                           maxpos = {x = pos.x + 5, y = pos.y + 5, z = pos.z + 5},
                           minvel = vel,
                           maxvel = vel,
                           minacc = {x = 0, y = 0, z = 0},
                           maxacc = {x = 0, y = 0, z = 0},
                           minexptime = particle_lifetime,
                           maxexptime = particle_lifetime,
                           minsize = size,
                           maxsize = size,
                           collisiondetection = true,
                           particlespawner_tweenable = true,
                           texture = { name = "firefly.png", alpha_tween = {0.0, 1.0, style="pulse", reps=1} },
                           glow = 14,
                    })
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
