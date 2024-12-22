local S = minetest.get_translator(minetest.get_current_modname())

minetest.register_entity("mobs_mc:creaking_eyes", {
    initial_properties = {
        textures = {"creaking_eyes.png"},
        hp_max = 10,
        glow = 15,
        visual = "mesh",
        mesh = "creaking_eyes.obj",
        visual_size = {x = 0.16, y = 0.16},
        rotate = 180,
        collisionbox = {0, 0, 0, 0, 0, 0},
        pointable = false,
        physical = true,
        collide_with_objects = false,
    },
    on_step = function(self, dtime, moveresult)
        -- Remove entity if it is not attached
        if not self.object:get_attach() then
            self.object:remove()
        end
    end,
})

local function is_player_looking_at_mob(mob_pos, player)
    local eye_offset = player:get_eye_offset()
    local player_pos = vector.add(player:get_pos(), eye_offset)
    local look_dir = player:get_look_dir()
    local to_mob = vector.direction(player_pos, mob_pos)
    local dot_product = vector.dot(look_dir, to_mob)

    -- Consider looking if the angle is less than 30 degrees (dot_product > cos(30 degrees))
    return dot_product > 0.45
end

local function remove_particles_when_target_reached(self, pos, target_pos, spawner_id)
    minetest.after(0.1, function()
        -- Continuously check if particles have reached the target
        local distance = vector.distance(pos, target_pos)

        -- Remove particles when the target is reached
        if distance <= 0.1 then
            minetest.delete_particlespawner(spawner_id)
        else
            -- Recheck until particles are removed
            remove_particles_when_target_reached(self, pos, target_pos, spawner_id)
        end
    end)
end

local creaking = {
    description = S("Creaking"),
    type = "monster",
    spawn_class = "hostile",
    can_despawn = true,
    passive = false,
    knockback = false,
    hp_min = 1,
    hp_max = 1,
    curiosity = 7,
    collisionbox = {-0.4, 0, -0.4, 0.4, 1, 0.4},
    visual = "mesh",
    mesh = "mobs_mc_creaking-3.b3d",
    textures = {"creaking.png"},
    visual_size = {x = 1, y = 1},
    animation = {
        stand_start = 48, stand_end = 48, stand_speed = 2,
        walk_start = 0, walk_end = 36, speed_normal = 100,
        punch_start = 0, punch_end = 36, punch_speed = 50,
    },
    sounds = {},
    walk_velocity = 3,
    run_velocity = 3,
    walk_chance = 80,
    attack_type = "dogfight",
    damage = 2,
    fall_damage = 10,
    view_range = 16,
    fear_height = 4,
    pathfinding = 1,
    reach = 2,
    jump = true,
    jump_height = 4,
    makes_footstep_sound = false,
    _heart_pos = nil,
    spawn_from_heart = false,
    creaking_eyes = false,
    
    on_spawn = function(self)
        if not self.creaking_eyes then
            local positions = {
                {x = -0.0209, y = 0.127, z = -0.0302},
                {x = 0.009, y = 0.107, z = -0.0302},
                {x = -0.011, y = 0.077, z = -0.0302}
            }
            for _, pos in ipairs(positions) do
                minetest.add_entity(self.object:get_pos(), "mobs_mc:creaking_eyes"):set_attach(self.object, "body", pos, {x = 0, y = 0, z = 0})
            end
            self.creaking_eyes = true
        end
    end,

    do_custom = function(self, dtime)
        local pos = self.object:get_pos()
        local players = minetest.get_connected_players()
        local being_watched, close_to_player = false, false

        -- Check players within range and if they're looking at the mob
        for _, player in ipairs(players) do
            local meta = player:get_meta()
            local player_pos = player:get_pos()

            -- Check if the player is within one block of the mob
            if vector.distance(pos, player_pos) <= 1 then
                close_to_player = true
            end

            -- Check if the player is looking at the mob
            if is_player_looking_at_mob(pos, player) and meta:get_string("pumpkin_hud") ~= "active" then
                being_watched = true
                break
            end
        end

        if being_watched then
            -- Stop movement and animations when being watched
            self.object:set_velocity({x = 0, y = 0, z = 0})
            self.object:set_animation({x = 48, y = 48}, 2)
            self.randomly_turn, self.attack_type, self.damage, self.jump = false, nil, 0, false
        else
            -- Behavior when not being watched or outside range
            if self._heart_pos and vector.distance(pos, self._heart_pos) > 31 then
                local dir_to_heart = vector.direction(pos, self._heart_pos)
                local velocity = vector.multiply(dir_to_heart, self.walk_velocity)
                self.object:set_velocity(velocity)
            end
            -- Animation when close to a player
            local anim = close_to_player and {x = 60, y = 69} or {x = 0, y = 36}
            self.object:set_animation(anim, 50)
            self.randomly_turn, self.attack_type, self.damage, self.jump = true, "dogfight", 2, true
        end
    end,
}

local creaking_transient = table.copy(creaking)
creaking_transient.on_punch = function(self, damage)
    self.object:set_animation({x = 96, y = 102}, 20)
    self.health = self.spawn_from_heart and self.health or self.health - 2

    if not self._heart_pos then return end

    local pos = self.object:get_pos()
    self.particlespawner_grey_id = particles.trail(pos, self._heart_pos, "#606060")
    self.particlespawner_orange_id = particles.trail(self._heart_pos, pos, "#EC7214")
    remove_particles_when_target_reached(self, pos, self._heart_pos, self.particlespawner_grey_id)
    remove_particles_when_target_reached(self, self._heart_pos, pos, self.particlespawner_orange_id)
end

creaking.deal_damage = function(self, damage)
    -- Prevent further damage processing for this mob type
    self.health = self.health
end

-- Register mobs and spawn eggs
vlf_mobs.register_mob("mobs_mc:creaking", creaking)
vlf_mobs.register_mob("mobs_mc:creaking_transient", creaking_transient)
vlf_mobs.register_egg("mobs_mc:creaking", S("Creaking"), "#A56C68", "#663939", 0)
