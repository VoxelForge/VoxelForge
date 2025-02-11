local S = minetest.get_translator(minetest.get_current_modname())
local mob_class = mcl_mobs.mob_class

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
    collisionbox = {-0.4, 0.5, -0.4, 0.4, 1, 0.4},
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
    head_swivel = "upper_body.head",
    stepheight = 1.01,
    movement_speed = 10.0,
    attack_type = "melee",
    damage = 3,
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
}

minetest.register_entity("vlf_pale_garden:creaking_eyes", {
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

function creaking:mob_activate (staticdata, dtime)
	if not mob_class.mob_activate (self, staticdata, dtime) then
		return false
	end
	local positions = {
                {x = -0.0209, y = 0.127, z = -0.0302},
                {x = 0.009, y = 0.107, z = -0.0302},
                {x = -0.011, y = 0.077, z = -0.0302}
            }
            for _, pos in ipairs(positions) do
                minetest.add_entity(self.object:get_pos(), "vlf_pale_garden:creaking_eyes"):set_attach(self.object, "body", pos, {x = 0, y = 0, z = 0})
            end
	return true
end

local function creaking_play(self, dtime)
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
        -- Behavior when not being watched
        if self._heart_pos and vector.distance(pos, self._heart_pos) > 31 then
            local dir_to_heart = vector.direction(pos, self._heart_pos)
            local velocity = vector.multiply(dir_to_heart, math.min(self.movement_speed, 2.5)) -- Reduced speed
            self.object:set_velocity(velocity)
        end

        -- Handle jumping for obstacles
        local node_below = minetest.get_node_or_nil({x = pos.x, y = pos.y - 1, z = pos.z})

        if node_below and node_below.name and minetest.registered_nodes[node_below.name] and minetest.registered_nodes[node_below.name].walkable then
            self.object:add_velocity({x = 0, y = self.jump_height * 0.5, z = 0}) -- More controlled jumping
        end

        -- Animation control
        local anim = close_to_player and {x = 60, y = 69} or {x = 0, y = 36}
        local anim_speed = close_to_player and 20 or 30 -- Slower animation speeds
        self.object:set_animation(anim, anim_speed)

        -- Update mob behavior
        self.randomly_turn = true
        self.attack_type = "melee"
        self.damage = 2
        self.jump = true

        -- Gradual speed adjustment
        local current_velocity = self.object:get_velocity()
        if vector.length(current_velocity) > 3 then
            self.object:set_velocity(vector.multiply(current_velocity, 0.8)) -- Damp high speeds
        end
    end
end


creaking.ai_functions = {
	creaking_play,
	mob_class.check_pace
}

local creaking_transient = table.copy(creaking)

function creaking_transient:on_punch()
	self.object:set_animation({x = 96, y = 102}, 5)
	self.particle = true
end

-- Table to track when the next resin placement is allowed for each entity
local resin_placement_timers = {}

-- Function to get all nodes within a 2-block taxicab distance
local function find_nearby_trees(pos)
    local positions = {}
    for x = -2, 2 do
        for y = -2, 2 do
            for z = -2, 2 do
                if math.abs(x) + math.abs(y) + math.abs(z) <= 2 then
                    local check_pos = vector.add(pos, {x = x, y = y, z = z})
                    local node = minetest.get_node_or_nil(check_pos)
                    if node and node.name == "mcl_trees:tree_pale_oak" then
                        table.insert(positions, check_pos)
                    end
                end
            end
        end
    end
    return positions
end

-- Function to place resin clumps
local function place_resin_clumps(hit_pos)
    local trees = find_nearby_trees(hit_pos)
    if #trees > 0 then
        -- Randomly select 1-3 trees
        local count = math.min(#trees, math.random(1, 3))
        for i = 1, count do
            local tree_pos = trees[math.random(#trees)]
            local air_positions = {}

            -- Find adjacent air nodes
            for dx = -1, 1 do
                for dy = -1, 1 do
                    for dz = -1, 1 do
                        if math.abs(dx) + math.abs(dy) + math.abs(dz) == 1 then
                            local air_pos = vector.add(tree_pos, {x = dx, y = dy, z = dz})
                            local node = minetest.get_node_or_nil(air_pos)
                            if node and node.name == "air" then
                                table.insert(air_positions, air_pos)
                            end
                        end
                    end
                end
            end

            -- Place resin clump on a random air position if available
            if #air_positions > 0 then
                local target_pos = air_positions[math.random(#air_positions)]
                minetest.set_node(target_pos, {name = "vlf_pale_garden:resin_clump"})
            end
        end
    end
end

-- AI step logic for creaking_transient
function creaking_transient:ai_step(dtime)
    mob_class.ai_step(self, dtime)

    local t = self.particle
    if t == true and self._heart_pos ~= nil then
        local current_time = minetest.get_us_time()

        -- Check if the 5-second timer has elapsed
        if not resin_placement_timers[self] or (current_time - resin_placement_timers[self]) >= 5 * 1000000 then
            resin_placement_timers[self] = current_time

            -- Get position and place resin clumps
            place_resin_clumps(self._heart_pos)
        end

        -- Particle trail logic
        local pos = self.object:get_pos()
        particles.trail(pos, self._heart_pos, "#606060", "in", 1)
        particles.trail(self._heart_pos, pos, "#EC7214", "out", 1)
        self.particle = false
        if self._heart_pos == nil then
			self.object:remove()
        end
    end
end


--[[function creaking_transient:ai_step (dtime)
	mob_class.ai_step (self, dtime)
	local t = self.particle

	if t == true then
		local pos = self.object:get_pos()
		particles.trail(pos, self._heart_pos, "#606060", "in", 1)
		particles.trail(self._heart_pos, pos, "#EC7214", "out", 1)
		self.particle = false
	end
end]]

function creaking_transient:receive_damage (self, damage)
    self.health = self.health
end

-- Register mobs and spawn eggs
mcl_mobs.register_mob("vlf_pale_garden:creaking", creaking)
mcl_mobs.register_mob("vlf_pale_garden:creaking_transient", creaking_transient)
mcl_mobs.register_egg("vlf_pale_garden:creaking", S("Creaking"), "#A56C68", "#663939", 0)
