--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")
local mob_class = vlf_mobs.mob_class

local function check_light(_, _, artificial_light, _)
	local date = os.date("*t")
	local maxlight
	if (date.month == 10 and date.day >= 20) or (date.month == 11 and date.day <= 3) then
		maxlight = 6
	else
		maxlight = 3
	end

	if artificial_light > maxlight then
		return false, "Too bright"
	end

	return true, ""
end

local bat = {
	description = S("Bat"),
	type = "animal",
	spawn_class = "ambient",
	can_despawn = true,
	spawn_in_group = 8,
	passive = true,
	hp_min = 6,
	hp_max = 6,
	rotate = 180,
	head_eye_height = 0.45,
	collisionbox = {-0.25, -0.01, -0.25, 0.25, 0.89, 0.25},
	visual = "mesh",
	mesh = "mobs_mc_bat.b3d",
	textures = {
		{"mobs_mc_bat.png"},
	},
	visual_size = {x=2, y=2},
	sounds = {
		random = "mobs_mc_bat_idle",
		damage = "mobs_mc_bat_hurt",
		death = "mobs_mc_bat_death",
		distance = 16,
	},
	movement_speed = 14.0,
	animation = {
		stand_speed = 80,
		stand_start = 0,
		stand_end = 40,
		walk_speed = 80,
		walk_start = 0,
		walk_end = 40,
		run_speed = 80,
		run_start = 0,
		run_end = 40,
		die_speed = 60,
		die_start = 80,
		die_end = 120,
		die_loop = false,
		hang_start = 130,
		hang_end = 135,
		hang_speed = 4,
	},
	fall_damage = 0,
	fly = true,
	makes_footstep_sound = false,
	check_light = check_light,
	gravity_drag = 0.6,
	_apply_gravity_drag_on_ground = true,
	pushable = false,
}

------------------------------------------------------------------------
-- Bat movement and "AI".
------------------------------------------------------------------------

local function is_opaque_solid (node)
	local node = minetest.get_node (node)
	local def = minetest.registered_nodes[node.name]
	return def and def.groups.opaque and def.groups.solid
end

local function is_walkable (node)
	local node = minetest.get_node (node)
	local def = minetest.registered_nodes[node.name]
	return def and def.walkable
end

local function signum (number)
	return (number == -0.0 or number < 0) and -1
		or (number == 0.0 and 0.0 or 1)
end

local scale_chance = vlf_mobs.scale_chance

function bat:motion_step (dtime, moveresult, self_pos)
	local h_scale, v_scale
		= mob_class.motion_step (self, dtime, moveresult, self_pos)
	local old_y = self_pos.y
	local abovepos = {
		x = math.floor (self_pos.x + 0.5),
		y = math.floor (self_pos.y + 0.5) + 1,
		z = math.floor (self_pos.z + 0.5),
	}

	if self._resting then
		-- Verify that the block above is still walkable and
		-- whole.
		if not is_opaque_solid (abovepos) then
			self._resting = false
			self:set_animation ("walk")
		else
			-- Be startled off by players wihin 4 nodes.
			for player in vlf_util.connected_players (self_pos, 4) do
				self._resting = false
				self:set_animation ("walk")
				break
			end
		end

		if self._resting then
			self:set_animation ("hang")
			self.object:set_pos ({
					x = self_pos.x,
					y = abovepos.y - 0.5 - 0.9,
					z = self_pos.z,
			})
			self.object:set_velocity (vector.zero ())
			-- Rotate randomly.
			if math.random (scale_chance (200, dtime)) == 1 then
				self:set_yaw (math.random () * math.pi * 2)
			end
			return
		end
	end

	self_pos.y = self_pos.y + (self.collisionbox[5] - self.collisionbox[2]) / 2
	-- Bats feature no true AI and simply float aimlessly,
	-- applying input directly to their velocity.
	local target_pos = self._target_pos

	if not target_pos
		or is_walkable (target_pos)
		or math.random (scale_chance (30, dtime)) == 1
		or vector.distance (self_pos, target_pos) <= 2.0 then
		-- Switch target positions.
		local x = math.random (0, 6) - math.random (0, 6)
		local z = math.random (0, 6) - math.random (0, 6)
		local y = math.random (0, 5) - 2.0
		self_pos.y = old_y
		target_pos = vector.offset (self_pos, x, y, z)
		target_pos.x = math.floor (target_pos.x + 0.5)
		target_pos.y = math.floor (target_pos.y)
		target_pos.z = math.floor (target_pos.z + 0.5)
	end

	self_pos.y = old_y
	self._target_pos = target_pos
	local v = self.object:get_velocity ()
	local dx = target_pos.x + 0.5 - self_pos.x
	local dy = target_pos.y + 0.1 - self_pos.y
	local dz = target_pos.z + 0.5 - self_pos.z
	local x_mod = (signum (dx) * 10 - v.x) * 0.1 * h_scale
	local y_mod = (signum (dy) * 14 - v.y) * 0.1 * v_scale
	local z_mod = (signum (dz) * 10 - v.z) * 0.1 * h_scale
	v.x = v.x + x_mod
	v.y = v.y + y_mod
	v.z = v.z + z_mod
	self.object:set_velocity (v)
	local yaw = math.atan2 (v.z, v.x) - math.pi / 2
	self:set_yaw (yaw)

	if math.random (scale_chance (100, dtime)) == 1
		and is_opaque_solid (abovepos) then
		self._resting = true
	end
	return
end

function bat:run_ai (dtime, moveresult)
	return
end

vlf_mobs.register_mob ("mobs_mc:bat", bat)

------------------------------------------------------------------------
-- Bat spawning.
------------------------------------------------------------------------

--[[ If the game has been launched between the 20th of October and the 3rd of November system time,
-- the maximum spawn light level is increased. ]]
local date = os.date("*t")
local maxlight
if (date.month == 10 and date.day >= 20) or (date.month == 11 and date.day <= 3) then
	maxlight = 6
else
	maxlight = 3
end

vlf_mobs.spawn_setup({
	name = "mobs_mc:bat",
	type_of_spawning = "ground",
	dimension = "overworld",
	min_height = vlf_vars.mg_overworld_min,
	max_height = mobs_mc.water_level - 1,
	min_light = 0,
	max_light = maxlight,
	aoc = 3,
	chance = 100,
})

-- spawn eggs
vlf_mobs.register_egg("mobs_mc:bat", S("Bat"), "#4c3e30", "#0f0f0f", 0)
