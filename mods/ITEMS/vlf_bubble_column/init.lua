local positions = {}
local entity_breath_timers = {}

local function check_bubble_column(pos, node)
    local below_pos = vector.offset(pos, 0, -1, 0)
    local below = minetest.get_node(below_pos)
    if below.name == "vlf_nether:soul_sand" or below.name == "vlf_nether:magma" then
        return true
    end

    if below.name == "vlf_core:water_source" and positions[minetest.hash_node_position(below_pos)] then
        return true
    end

    print("Tearing down bubble column at " .. vector.to_string(pos))

    local pos_hash = minetest.hash_node_position(pos)

    -- Don't continue upwards if this already wasn't a bubble column
    if not positions[pos_hash] then return end

    -- Remove this node from the column positions
    positions[pos_hash] = nil

    pos = vector.offset(pos, 0, 1, 0)

    node = minetest.get_node(pos)
    return check_bubble_column(pos, node)
end

minetest.register_abm({
    label = "Create Bubble Column",
    interval = 1,
    chance = 1,
    nodenames = { "vlf_nether:soul_sand", "vlf_nether:magma" },
    neighbors = { "vlf_core:water_source" },
    action = function(pos, node)
        local above_pos = vector.offset(pos, 0, 1, 0)
        local above_pos_2 = vector.offset(pos, 0, 1.5, 0)
        local above_pos_node = minetest.get_node(above_pos_2)
        local above = minetest.get_node(above_pos)
        if above.name ~= "vlf_core:water_source" and above_pos_node.name ~= "air"  then return end

        local direction = 1
        if node.name == "vlf_nether:magma" then
            direction = -1
        end

        -- Create the bubble column
        while above.name == "vlf_core:water_source" do
            local above_pos_hash = minetest.hash_node_position(above_pos)
            if positions[above_pos_hash] == direction then return end
            positions[above_pos_hash] = direction

            above_pos = vector.offset(above_pos, 0, 1, 0)
            above = minetest.get_node(above_pos)
        end
    end
})

local BUBBLE_TIME = 0.8
local BUBBLE_PARTICLE = {
    texture = "vlf_particles_bubble.png",
    collision_removal = false,
    expirationtime = BUBBLE_TIME,
    collisiondetection = false,
    size = 2.5,
}

minetest.register_globalstep(function(dtime)
    for hash, dir in pairs(positions) do
        if math.random(1, 17) == 1 then
            local pos = minetest.get_position_from_hash(hash)
            local node = minetest.get_node(pos)
            if check_bubble_column(pos, node) then
                local particle_pos = vector.offset(pos, math.random(-28, 28) / 64, -0.51 * dir, math.random(-28, 28) / 64)
                local particle_node = minetest.get_node(particle_pos)
                if particle_node.name == "vlf_core:water_source" then
                    local particle = table.copy(BUBBLE_PARTICLE)
                    particle.pos = particle_pos
                    particle.velocity = (vector.offset(pos, math.random(-28, 28) / 64, 0.51 * dir, math.random(-28, 28) / 64) - particle.pos) / BUBBLE_TIME
                    particle.acceleration = vector.zero()
                    minetest.add_particle(particle)
                end
            end
        end

        local pos = minetest.get_position_from_hash(hash)
        for _, entity in ipairs(minetest.get_objects_inside_radius(pos, 1)) do
            local entity_pos = entity:get_pos()
            local node = minetest.get_node(entity_pos)
            local below_pos = {x = entity_pos.x, y = entity_pos.y - 1, z = entity_pos.z}

            while true do
                local below = minetest.get_node(below_pos)
                if below.name == "vlf_nether:soul_sand" or below.name == "vlf_nether:magma" then
                    if node.name == "vlf_core:water_source" then
                        local dir = below.name == "vlf_nether:soul_sand" and 1 or -1
                        local speed = below.name == "vlf_nether:soul_sand" and 1 or 0.5

                        -- Check if the top of the entity's head is in water
                        local entity_height = entity:get_properties().collisionbox[5]
                        local head_pos = {x = entity_pos.x, y = entity_pos.y + entity_height - 0.8, z = entity_pos.z}
                        local head_node = minetest.get_node(head_pos)

                        if head_node.name == "vlf_core:water_source" then
                            entity:add_velocity({x = 0, y = dir * speed, z = 0})
                        end

                        if entity:is_player() then
                            -- Initialize breath timer for player if not already set
                            local player_name = entity:get_player_name()
                            if not entity_breath_timers[player_name] then
                                entity_breath_timers[player_name] = 0
                            end

                            -- Increment breath based on timer
                            entity_breath_timers[player_name] = entity_breath_timers[player_name] + dtime
                            if entity_breath_timers[player_name] >= 1 then
                                if entity:get_breath() < 10 then
                                    entity:set_breath(entity:get_breath() + 1)
                                end
                                entity_breath_timers[player_name] = 0
                            end
                        end
                    end
                    break
                elseif below.name ~= "vlf_core:water_source" then
                    break
                end
                below_pos.y = below_pos.y - 1
            end
        end
    end
end)
