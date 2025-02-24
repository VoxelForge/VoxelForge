minetest.register_entity("vlf_trials:ominous_item_spawner", {
    initial_properties = {
        visual = "wielditem",
        textures = {".png"},
        collide_with_objects = false,
        physical = false,
        pointable = false,
        automatic_face_movement_dir = true,
    },
    chosen_entity = nil,

    on_activate = function(self, staticdata)
        local pos = self.object:get_pos()

        -- Check for other ominous item spawners in a 10-block radius
        local nearby_spawners = minetest.get_objects_inside_radius(pos, 10)
        local spawner_count = 0

        for _, obj in ipairs(nearby_spawners) do
            local lua_entity = obj:get_luaentity()
            if lua_entity and lua_entity.name == "vlf_trials:ominous_item_spawner" then
                spawner_count = spawner_count + 1
                if spawner_count > 1 then
                    -- More than one spawner detected, remove this new one
                    self.object:remove()
                    return
                end
            end
        end

        local radius = 5
        local targets = minetest.get_objects_inside_radius(pos, radius)
        local target = nil

        -- Find a valid target (player or entity)
        for _, obj in ipairs(targets) do
            if obj:is_player() or obj:get_luaentity() then
                target = obj
                break
            end
        end

        -- If a target is found
        if target then
            local target_pos = target:get_pos()
            target_pos.y = target_pos.y + 3

            -- Get the loot table resource
            local resource = vl_datapacks.get_resource("loot_table", "vanilla:spawners/trial_chamber/items_to_drop_when_ominous")
            local loot_stacks = vl_loot.engine.get_loot(resource, {})

            -- Pick a random item from the loot table
            if #loot_stacks > 0 then
                local chosen_loot = loot_stacks[math.random(#loot_stacks)]
                local chosen_entity = chosen_loot:get_name()

                -- Spawn the chosen entity
                local new_entity = minetest.add_entity(target_pos, chosen_entity)

                if new_entity then
                    local rotation = vector.new(0, math.random(0, 360), 0)
                    new_entity:set_rotation(rotation)

                    -- Shoot the entity down after 3-6 seconds
                    minetest.after(math.random(3, 6), function()
                        if new_entity and new_entity:get_pos() then
                            local new_entity_pos = new_entity:get_pos()
                            new_entity_pos.y = new_entity_pos.y - 0.3
                            new_entity:set_velocity({x = 0, y = -9, z = 0})
                            new_entity:set_pos(new_entity_pos)
                        end
                    end)
                end

                -- Particle effects
                minetest.add_particlespawner({
                    amount = math.random(6, 10),
                    time = 4,
                    minpos = {x = pos.x + 0.5, y = pos.y + 0.5, z = pos.z + 0.5},
                    maxpos = {x = pos.x + 1.5, y = pos.y + 1.5, z = pos.z + 1.5},
                    minvel = {x = 0.0, y = 0, z = -0.0},
                    maxvel = {x = 0.0, y = 0, z = 0.0},
                    minexptime = 0.5,
                    maxexptime = 1,
                    minsize = 3,
                    maxsize = 5,
                    collisiondetection = false,
                    texture = "vlf_particles_ominous_item_spawner.png^[colorize:#0000FF:128",
                    glow = 10,
                })
            end

            -- Remove the spawner entity
            self.object:remove()
        else
            -- No target, remove the spawner entity
            self.object:remove()
        end
    end,
})
