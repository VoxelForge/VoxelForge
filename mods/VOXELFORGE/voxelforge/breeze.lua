-- daufinsyd
-- My work is under the LGPL terms
-- Model and mobs_breeze.png see https://github.com/22i/minecraft-voxel-blender-models -hi 22i ~jordan4ibanez
-- breeze.lua partial copy of mobs_mc/ghast.lua

local S = minetest.get_translator("mobs_mc")
local mob_class = mcl_mobs.mob_class

local breeze = {
    description = S("Breeze"),
    type = "monster",
    spawn_class = "hostile",
    spawn_in_group_min = 2,
    spawn_in_group = 3,
    group_attack = {
        "mobs_mc:breeze",
    },
    retaliates = true,
    hp_min = 30,
    hp_max = 30,
    xp_min = 15,
    xp_max = 15,
    collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.79, 0.3},
    rotate = -180,
    head_yaw_offset = math.rad(-180),
    visual = "mesh",
    mesh = "Breeze.b3d",
    head_swivel = "head.control",
    bone_eye_height = 4,
    head_pitch_multiplier = -1,
    textures = {
        {"the_breeze_mcl.png"},
    },
    armor = {
        fleshy = 100,
        snowball_vulnerable = 100,
        water_vulnerable = 100,
    },
    visual_size = {x = 1, y = 1},
    sounds = {
        shoot_attack = "mobs_fireball",
        random = "mobs_mc_breeze_breath",
        death = "mobs_mc_breeze_died",
        damage = "mobs_mc_breeze_hurt",
        distance = 16,
    },
    movement_speed = 6.6,
    damage = 0,
    reach = 2,
    drops = {
        {
            name = "mcl_mobitems:breeze_rod",
            chance = 1,
            min = 1,
            max = 3,
            looting = "common",
        },
    },
    animation = {
        stand_speed = 30,
        stand_start = 0,
        stand_end = 39,
        shoot_start = 50,
        shoot_end = 90,
        jump_start = 30,
        jump_end = 39,
        jump_speed = 30
    },
    water_damage = 0,
    _mcl_freeze_damage = 2,
    jump_height = 20,  -- Higher jumps!
    step_height = 1,
    lava_damage = 2,
    fire_damage = 0,
    fall_damage = 0,
    attack_type = "null",
    arrow = "mcl_charges:wind_charge_flying",
    passive = false,
    makes_footstep_sound = false,
    glow = 14,
    view_range = 48.0,
    tracking_distance = 48.0,
    _projectile_gravity = false,
}

function breeze:do_custom(dtime)

    if not self._height_diff_tolerance or self._height_diff_tolerance_age >= 5 then
        self._height_diff_tolerance = mcl_util.dist_triangular(0.5, 6.891)
        self._height_diff_tolerance_age = 0
    end
    self._height_diff_tolerance_age = self._height_diff_tolerance_age + dtime
end

function breeze:set_animation_speed(custom_speed)
    self.object:set_animation_frame_speed(25)
end

function breeze:attack_null(self_pos, dtime, target_pos, line_of_sight)
    if not self.attacking then
        self._visible_for = 0
        self._phase_remaining = 0
        self._phase = 0
        self.attacking = true
    end

    if line_of_sight then
        self._visible_for = self._visible_for + dtime
    else
        self._visible_for = 0
    end

    self._phase_remaining = self._phase_remaining - dtime

    local target_eye_height = target_pos.y + mcl_util.target_eye_height(self.attack)
    local self_eye_height = self_pos.y + self.head_eye_height

    if target_eye_height > self_eye_height + self._height_diff_tolerance then
        local v = self.object:get_velocity()
        v.y = v.y + (6 - v.y) * mcl_mobs.pow_by_step(0.3, dtime)
        self.object:set_velocity(v)
    end

    local distance = vector.distance(self_pos, target_pos)

    if distance < 0.1 then
        if not line_of_sight then
            return
        end
        if self._phase_remaining <= 0 then
            self._phase_remaining = 1
            self.attack:punch(self.object, 1.0, {
                full_punch_interval = 1.0,
                damage_groups = { fleshy = self.damage },
            }, vector.direction(self_pos, target_pos))
        end
        self:go_to_pos(target_pos)
    elseif distance < self.tracking_distance and line_of_sight then
        if self._phase_remaining > 0 then
            return
        end

        self._phase = self._phase + 1
        if self._phase == 1 then
            self._phase_remaining = 1  -- Faster charge time!
        elseif self._phase <= 4 then
            local dx, dy, dz
            local props = self.attack:get_properties()
            local cbox = props.collisionbox
            dx = target_pos.x - self_pos.x
            dy = (target_pos.y + cbox[2] + (cbox[5] - cbox[2]) / 2) - (self_pos.y + 0.9)
            dz = target_pos.z - self_pos.z

            local scatter = math.sqrt(distance) / 2
            local vec = vector.normalize({
                x = mcl_util.dist_triangular(dx, 2.297 * scatter),
                y = dy,
                z = mcl_util.dist_triangular(dz, 2.297 * scatter),
            })
            local pos = vector.offset(self_pos, 0, 0.9, 0)
            local arrow = minetest.add_entity(pos, self.arrow)
            if arrow then
                local luaentity = arrow:get_luaentity()
                self:mob_sound("shoot_attack")
                arrow:set_velocity(vector.multiply(vec, 30))
                luaentity.switch = 1
                luaentity.owner_id = tostring(self.object)
                luaentity._shooter = self.object
                luaentity._saved_shooter_pos = vector.copy(self_pos)
            end
            self._phase_remaining = 0.5  -- Faster shooting interval!
        else
            self._phase_remaining = 1  -- Shorter recharge time!
            self._phase = 0
        end

        -- Frequent movement while attacking
        local move_offset = {
            x = math.random(-3, 3),
            y = math.random(0, 4),
            z = math.random(-3, 3)
        }
        self:go_to_pos(vector.add(target_pos, move_offset))
    elseif self._visible_for < 0.25 then
        self:go_to_pos(target_pos)
    end
end

breeze.ai_functions = {
    mob_class.check_attack,
    mob_class.check_pace,
}

mcl_mobs.register_mob("voxelforge:breeze", breeze)

mcl_mobs.register_egg("voxelforge:breeze", S("Breeze"), "#a78dd5", "#714fae", 0)

