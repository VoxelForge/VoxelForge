--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")
local mobs_griefing = minetest.settings:get_bool("mobs_griefing", true)
local mob_class = mcl_mobs.mob_class

--###################
--################### GHAST
--###################

local ghast = {
	description = S("Ghast"),
	type = "monster",
	spawn_class = "hostile",
	hp_min = 10,
	hp_max = 10,
	xp_min = 5,
	xp_max = 5,
	collisionbox = {-2, 0, -2, 2, 4.0, 2},
	doll_size_override = { x = 1.05, y = 1.05 },
	visual = "mesh",
	mesh = "mobs_mc_ghast.b3d",
	spawn_in_group = 1,
	textures = {
		{"mobs_mc_ghast.png"},
	},
	attack_type = "null",
	visual_size = {x=12, y=12},
	sounds = {
		shoot_attack = "mobs_mc_ghast_shot",
		attack = "mobs_mc_ghast_shot",
		random = {name="mobs_eerie", gain=3},
		death = {name="mobs_mc_ghast_dying", gain=2},
		damage = "mobs_mc_ghast_hurt",
		distance = 80,
	},
	movement_speed = 14,
	drops = {
		{
			name = "mcl_mobitems:gunpowder",
			chance = 1, min = 0, max = 2,
			looting = "common",
		},
		{
			name = "mcl_mobitems:ghast_tear",
			chance = 10/6, min = 0, max = 1,
			looting = "common",
			looting_ignore_chance = true,
		},
	},
	animation = {
		stand_speed = 50,
		stand_start = 0,
		stand_end = 40,
	},
	fall_damage = 0,
	view_range = 100.0,
	tracking_distance = 100.0,
	arrow = "mobs_mc:fireball",
	shoot_offset = 0.3,
	jump_height = 4,
	head_eye_height = 2.6,
	floats = 1,
	fly = true,
	-- True flight.
	motion_step = mob_class.flying_step,
	makes_footstep_sound = false,
	instant_death = true,
	fire_resistant = true,
	lava_damage = 0,
	does_not_prevent_sleep = true,
	_projectile_gravity = false,
	_impulse_time = 0.0,
}

------------------------------------------------------------------------
-- Ghast AI.
------------------------------------------------------------------------

-- Ghasts should not notice players till they are within 4.0 blocks
-- vertically.
function ghast:should_attack (object)
	return mob_class.should_attack (self, object)
		and math.abs (object:get_pos ().y - self.object:get_pos ().y) <= 4.0
end

function ghast:do_go_pos (dtime, moveresult)
	local target = self.movement_target or vector.zero ()
	local self_pos = self.object:get_pos ()
	local dir = vector.direction (self_pos, target)
	local t = self._impulse_time - dtime

	if t <= 0 then
		t = (math.random (0, 5) + 2) / 20
		-- This acceleration circumvents the regular physics
		-- mechanism, as in Minecraft.
		self.object:add_velocity (dir * 2.0)
	end
	self._impulse_time = t

	if not self.attack then
		local dir = math.atan2 (dir.z, dir.x) - math.pi/2
		self:set_yaw (dir)
	end

	if moveresult.collides then
		if not self._ghast_collide_time then
			self._ghast_collide_time = dtime
		else
			self._ghast_collide_time
				= self._ghast_collide_time + dtime
		end

		if self._ghast_collide_time > 1 then
			-- If this mob has been colliding for
			-- over a second, abandon this target.
			self:halt_in_tracks ()
		end
	end
end

local function ghast_move_randomly (self, self_pos)
	local activate = false
	if self.movement_goal ~= "go_pos" then
		activate = true
	else
		local target = self.movement_target
		if not target then
			activate = true
		else
			local dist = vector.distance (self_pos, target)
			if dist < 1 or dist > 60 then
				activate = true
			end
		end
	end

	if activate then
		-- Select a random target position and guarantee that
		-- it is unobstructed.
		local x_delta, y_delta, z_delta
		x_delta = (math.random () - 0.5) * 32.0
		y_delta = (math.random () - 0.5) * 32.0
		z_delta = (math.random () - 0.5) * 32.0
		local position
			= vector.offset (self_pos, x_delta, y_delta, z_delta)
		if self:line_of_sight (self_pos, position) then
			self:go_to_pos (position)
			self._ghast_collide_time = 0
		end
	end
end

local function ghast_maybe_discharge (self, self_pos, dtime)
	if self.attack then
		local target_pos = self.attack:get_pos ()
		local distance = vector.distance (target_pos, self_pos)

		if distance < 64 then
			local dir = vector.subtract (target_pos, self_pos)
			local yaw = math.atan2 (dir.z, dir.x) - math.pi/2
			self:set_yaw (yaw)
		end

		if distance < 64 and self:target_visible (self_pos, self.attack) then
			self._charge_time = self._charge_time + dtime
			if self._charge_time >= 1.0 then
				self._charge_time = -2
				self:discharge_ranged (self_pos, target_pos)
			end
		elseif self._charge_time > 0 then
			self._charge_time = math.max (self._charge_time - dtime, 0)
		end
	end
end

function ghast:run_ai (dtime)
	local self_pos = self.object:get_pos ()
	ghast_move_randomly (self, self_pos)
	if self:check_attack (self_pos, dtime) then
		ghast_maybe_discharge (self, self_pos, dtime)
	end
end

function ghast:do_attack (target)
	self.attack = target
	self.target_invisible_time = 3.0
	self._sight_persistence = 3.0
	self._charge_time = 0
end

------------------------------------------------------------------------
-- Ghast visuals.
------------------------------------------------------------------------

function ghast:do_custom ()
	if self.firing == true then
		self:set_textures ({"mobs_mc_ghast_firing.png"})
	else
		self:set_textures ({"mobs_mc_ghast.png"})
	end
end

------------------------------------------------------------------------
-- Ghast spawning.
------------------------------------------------------------------------

function ghast.can_spawn (pos)
	if not minetest.get_item_group(minetest.get_node(pos).name,"solid") then return false end
	local p1=vector.offset(pos,-2,1,-2)
	local p2=vector.offset(pos,2,5,2)
	local nn = minetest.find_nodes_in_area(p1,p2,{"air"})
	if #nn< 41 then return false end
	return true
end

mcl_mobs.register_mob ("mobs_mc:ghast", ghast)

mcl_mobs.spawn_setup ({
	name = "mobs_mc:ghast",
	type_of_spawning = "ground",
	dimension = "nether",
	min_light = 0,
	max_light = 15,
	aoc = 2,
	biomes = {
		"Nether",
		"SoulsandValley",
		"BasaltDelta",
	},
	chance = 400,
})

-- spawn eggs
mcl_mobs.register_egg ("mobs_mc:ghast", S("Ghast"), "#f9f9f9", "#bcbcbc", 0)

------------------------------------------------------------------------
-- Big Fireball.
------------------------------------------------------------------------

-- blast damage to entities nearby
local function blast_damage(pos, radius, source)
	radius = radius * 2

	for obj in minetest.objects_inside_radius(pos, radius) do

		local obj_pos = obj:get_pos()
		local dist = vector.distance(pos, obj_pos)
		if dist < 1 then dist = 1 end

		local damage = math.floor((4 / dist) * radius)

		-- punches work on entities AND players
		obj:punch(source, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = damage},
		}, vector.direction(pos, obj_pos))
	end
end

-- no damage to nodes explosion
local function fireball_safe_boom (self, pos, strength, no_remove)
	minetest.sound_play(self.sounds and self.sounds.explode or "tnt_explode", {
		pos = pos,
		gain = 1.0,
		max_hear_distance = self.sounds and self.sounds.distance or 32
	}, true)
	local radius = strength
	blast_damage(pos, radius, self.object)
	mcl_mobs.effect(pos, 32, "mcl_particles_smoke.png", radius * 3, radius * 5, radius, 1, 0)
	if not no_remove then
		if self.is_mob then
			self:safe_remove()
		else
			self.object:remove()
		end
	end
end

-- make explosion with protection and tnt mod check
local function fireball_boom (self, pos, strength, fire, no_remove)
	if mobs_griefing and not minetest.is_protected(pos, "") then
		mcl_explosions.explode(pos, strength, { fire = fire }, self.object)
	else
		fireball_safe_boom(self, pos, strength, no_remove)
	end
	if not no_remove then
		if self.is_mob then
			self:safe_remove()
		else
			self.object:remove()
		end
	end
end

-- fireball (projectile)
mcl_mobs.register_arrow("mobs_mc:fireball", {
	description = S("Ghast Fireball"),
	visual = "sprite",
	visual_size = {x = 1, y = 1},
	textures = {"mcl_fire_fire_charge.png"},
	velocity = 19,
	collisionbox = {-.5, -.5, -.5, .5, .5, .5},
	_is_fireball = true,
	_mcl_fishing_hookable = true,
	_mcl_fishing_reelable = true,
	redirectable = true,
	hit_player = function(self, player)
		mcl_mobs.get_arrow_damage_func(6, "fireball")(self, player)
		local p = self.object:get_pos()
		if p then
			fireball_boom (self,p, 1, true)
		else
			fireball_boom (self,player:get_pos(), 1, true)
		end
	end,
	hit_mob = function(self, mob)
		if mob == self._shooter then
			mcl_mobs.get_arrow_damage_func (6000, "fireball") (self, mob)
		else
			mcl_mobs.get_arrow_damage_func(6, "fireball")(self, mob)
		end
		fireball_boom (self,self.object:get_pos(), 1, true)
	end,
	hit_node = function(self, pos, _)
		fireball_boom (self,pos, 1, true)
	end
})
