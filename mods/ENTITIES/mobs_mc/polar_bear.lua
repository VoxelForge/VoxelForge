--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")
local mob_class = mcl_mobs.mob_class

--###################
--################### POLARBEAR
--###################

local polar_bear = {
	description = S("Polar Bear"),
	type = "animal",
	spawn_class = "passive",
	runaway = true,
	passive = false,
	retaliates = true,
	hp_min = 30,
	hp_max = 30,
	xp_min = 1,
	xp_max = 3,
        breath_max = -1,
	collisionbox = {-0.7, -0.01, -0.7, 0.7, 1.39, 0.7},
	visual = "mesh",
	mesh = "mobs_mc_polarbear.b3d",
	textures = {
		{"mobs_mc_polarbear.png"},
	},
	head_swivel = "head.control",
	bone_eye_height = 2.6,
	head_eye_height = 1,
	horizontal_head_height = 0,
	curiosity = 20,
	head_yaw = "z",
	visual_size = {x=3.0, y=3.0},
	makes_footstep_sound = true,
	_mcl_freeze_damage = 0,
	damage = 6,
	reach = 2,
	movement_speed = 5.0,
	follow_bonus = 1.25,
	attack_type = "melee",
	drops = {
		-- 3/4 chance to drop raw fish (poor approximation)
		{
			name = "mcl_fishing:fish_raw",
			chance = 2,
			min = 0,
			max = 2,
			looting = "common",
		},
		-- 1/4 to drop raw salmon
		{
			name = "mcl_fishing:salmon_raw",
			chance = 4,
			min = 0,
			max = 2,
			looting = "common",
		},

	},
	floats = 1,
	sounds = {
		random = "mobs_mc_bear_random",
		attack = "mobs_mc_bear_attack",
		damage = "mobs_mc_bear_hurt",
		death = "mobs_mc_bear_death",
		war_cry = "mobs_mc_bear_growl",
		distance = 16,
	},
	animation = {
		stand_start = 0, stand_end = 0,
		walk_start = 0, walk_end = 40, walk_speed = 40,
		run_start = 0, run_end = 40, run_speed = 40,
	},
	view_range = 20,
	tracking_distance = 20,
	group_attack = {
		"mobs_mc:polar_bear",
	},
	follow_herd_bonus = 1.25,
	water_friction = 0.98,
	_standing = false,
	_rearing_time = nil,
	spawn_in_group_min = 1,
	spawn_in_group_max = 2,
}

------------------------------------------------------------------------
-- Polar bear mechanics.
------------------------------------------------------------------------

function polar_bear.spawn_group_member_data (idx)
	if idx == 2 then
		return minetest.serialize ({
			child = true,
		})
	end
	return nil
end

------------------------------------------------------------------------
-- Polar bear visuals.
------------------------------------------------------------------------

function polar_bear:mob_activate (staticdata, dtime)
	if not mob_class.mob_activate (self, staticdata, dtime) then
		return false
	end
	self._rearing_time = nil
	return true
end

function polar_bear:do_custom (dtime, moveresult)
	local t = self._rearing_time
	if t then
		local cbox_extend
		if t >= 0 then
			t = math.min (0.5, t + dtime)
			cbox_extend = t * 1.0 / 0.6
		else
			t = t + dtime
			if t >= 0 then
				t = 0
			end
			cbox_extend = -t * 1.0 / 0.6
		end

		local cbox = self.collisionbox
		cbox[5] = 1.39 + cbox_extend
		self.object:set_properties ({
			collisionbox = cbox,
		})

		if t == 0 then
			self._rearing_time = nil
		else
			self._rearing_time = t
		end
	end
end

local SIXTY_FIVE_DEG = math.rad (64)

--- XXX: creating additional bone overrides prevents bone override
--- interpolation from functioning.

function polar_bear:check_head_swivel (self_pos, dtime, clear)
	if self._rearing_time
		and self._rearing_time < 0.3 then
		return
	end
	mob_class.check_head_swivel (self, self_pos, dtime, clear)
end

function polar_bear:rear_up ()
	if self._rearing_time and self._rearing_time > 0 then
		return nil
	end
	self:set_animation ("stand")
	self.object:set_bone_override ("body.back", {
	       rotation = {
		       vec = vector.new (-SIXTY_FIVE_DEG, 0, 0),
		       interpolation = 0.3,
		       absolute = true,
	       },
	       position = {
		       vec = vector.new (0, 0, 0.3),
		       interpolation = 0.3,
		       absolute = true,
	       }
	})
	self._rearing_time = 0
	self._head_pitch_offset = SIXTY_FIVE_DEG
end

function polar_bear:rear_down ()
	if not self._rearing_time or self._rearing_time < 0 then
		return
	end
	self.object:set_bone_override ("body.back", {
	       rotation = {
		       vec = vector.zero (),
		       interpolation = 0.3,
		       absolute = true,
	       },
	       position = {
		       vec = vector.zero (),
		       interpolation = 0.3,
		       absolute = true,
	       }
	})
	self._rearing_time = -self._rearing_time
	self._head_pitch_offset = 0
end

function polar_bear:attack_end ()
	mob_class.attack_end (self)
	self:rear_down ()
end

function polar_bear:pre_melee_attack (distance, delay, line_of_sight)
	local ok = mob_class.pre_melee_attack (self, distance, delay,
					line_of_sight)
	if ok then
		self:rear_down ()
		return true
	end

	local cbox = self.collisionbox
	if distance < cbox[4] - cbox[1] + 3.0
		and line_of_sight and delay < 0.5 then
		self:rear_up ()
	else
		self:rear_down ()
	end
	return false
end

------------------------------------------------------------------------
-- Polar bear AI.
------------------------------------------------------------------------

function polar_bear:should_attack (object)
	if self.child then
		return false
	end
	if object:is_player () then
		if self._child_nearby == nil then
			local self_pos = self.object:get_pos ()
			local aa = vector.offset (self_pos, -8, -4, -8)
			local bb = vector.offset (self_pos, 8, 4, 8)
			self._child_nearby = false

			for object in minetest.objects_in_area (aa, bb) do
				local entity = object:get_luaentity ()
				if entity and entity.name == self.name
					and entity.child then
					self._child_nearby = true
				end
			end
		end
		return self._child_nearby
	end
	return false
end

function polar_bear:ai_step (dtime)
	mob_class.ai_step (self, dtime)
	self._child_nearby = nil
	self.runaway = self.child
end

function polar_bear:is_frightened ()
	if self.child
		and self.runaway_timer
		and self.runaway_timer > 0 then
		return true
	end
	return mcl_burning.is_burning (self.object)
end

function polar_bear:check_attack (self_pos, dtime)
	if self.child then
		return false
	end
	return mob_class.check_attack (self, self_pos, dtime)
end

polar_bear.ai_functions = {
	polar_bear.check_attack,
	mob_class.check_frightened,
	mob_class.follow_herd,
	mob_class.check_pace,
}

mcl_mobs.register_mob ("mobs_mc:polar_bear", polar_bear)

------------------------------------------------------------------------
-- Polar bear spawning.
------------------------------------------------------------------------

mcl_mobs.spawn_setup ({
	name = "mobs_mc:polar_bear",
	type_of_spawning = "ground",
	dimension = "overworld",
	aoc = 3,
	biomes = {
		"ColdTaiga",
		"IcePlainsSpikes",
		"IcePlains",
	},
	chance = 50,
})

-- spawn egg
mcl_mobs.register_egg("mobs_mc:polar_bear", S("Polar Bear"), "#f2f2f2", "#959590", 0)
