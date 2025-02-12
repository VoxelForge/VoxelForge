minetest.register_entity("vlf_trials:ominous_item_spawner", {
	initial_properties = {
		visual = "wielditem",
		textures = {".png"},  -- Default texture if needed
		collide_with_objects = false,
		physical = false,
		pointable = false,
		automatic_face_movement_dir = true,
	},

	on_activate = function(self, staticdata)
	-- Get a random player or entity within a 5-block radius
        local pos = self.object:get_pos()
        local radius = 5
        local targets = minetest.get_objects_inside_radius(pos, radius)
        local target = nil

        -- Filter out players and entities to find a valid target
        for _, obj in ipairs(targets) do
            if obj:is_player() or obj:get_luaentity() then
                target = obj
                break
            end
        end

        -- If a target is found
        if target then
            -- Get the target's position
            local target_pos = target:get_pos()
            target_pos.y = target_pos.y + 3  -- 3 blocks over the target

            -- Choose a random entity to spawn
            local possible_entities = {"mcl_potions:strength_lingering_flying"}  -- Replace with your entity names
            local chosen_entity = possible_entities[math.random(#possible_entities)]

            -- Spawn the chosen entity
            local new_entity = minetest.add_entity(target_pos, chosen_entity)

            if new_entity then
                -- Copy texture from chosen entity
                --local entity_texture = minetest.registered_entities[chosen_entity].textures[1]
                --new_entity:set_properties({visual = "wielditem"})

                -- Rotate the entity randomly
                local rotation = vector.new(0, math.random(0, 360), 0)
                new_entity:set_rotation(rotation)

                -- Schedule to shoot the entity down after 3-6 seconds
                minetest.after(math.random(3, 6), function()
                    if new_entity and new_entity:get_pos() then
                        local new_entity_pos = new_entity:get_pos()
                        new_entity_pos.y = new_entity_pos.y - 0.3  -- 0.3 blocks under the original position
                        new_entity:set_velocity({x = 0, y = -9, z = 0})  -- Shoot down with velocity of 3
                        new_entity:set_pos(new_entity_pos)  -- Set new position slightly lower
                    end
                end)
            end
            
            minetest.add_particlespawner({
                amount = math.random(6, 10),
                time = 4, -- Particle spawner duration
                minpos = --[[vector.subtract(pos, ]]{x = pos.x+0.5, y = pos.y+0.5, z = pos.z+0.5},--),
                maxpos = --[[vector.add(pos, ]]{x = pos.x+1.5, y = pos.y+1.5, z = pos.z+1.5},--),
                minvel = {x = 0.0, y = 0, z = -0.0},
                maxvel = {x = 0.0, y = 0, z = 0.0},
                minacc = {x = 0, y = 0, z = 0},
                maxacc = {x = 0, y = 0, z = 0},
                minexptime = 0.5,
                maxexptime = 1,
                minsize = 3,
                maxsize = 5,
                collisiondetection = false,
                texture = "vlf_particles_ominous_item_spawner.png^[colorize:#0000FF:128",  -- Blue shades
                glow = 10,
            })

            -- Remove the spawner entity
            self.object:remove()
        else
            -- If no target is found, remove the entity immediately
            self.object:remove()
        end
    end,

})


minetest.register_craftitem("vlf_trials:ominous_item_spawner", {
    description = "Spawner Item",
    inventory_image = "spawner_item.png",  -- Replace with your item texture
    stack_max = 64,
    groups = {rare = 1},
    on_use = function(itemstack, user, pointed_thing)
        -- Spawn the spawner entity at the user's position
        local pos = user:get_pos()
        local spawner_entity = minetest.add_entity({x = pos.x, y = pos.y + 1.5, z = pos.z}, "vlf_trials:ominous_item_spawner")  -- Spawn slightly above the player
        
        -- Remove the item from the user's inventory
        itemstack:take_item()
        return itemstack
    end,
})
