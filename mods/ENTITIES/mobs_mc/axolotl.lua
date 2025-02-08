local S = minetest.get_translator(minetest.get_current_modname())
local mob_class = mcl_mobs.mob_class
local is_valid = mcl_util.is_valid_objectref

------------------------------------------------------------------------
-- Axolotl
------------------------------------------------------------------------

local axolotl = {
	description = S("Axolotl"),
	type = "animal",
	spawn_class = "water",
	can_despawn = true,
	passive = false,
	passive_towards_players = true,
	hp_min = 14,
	hp_max = 14,
	xp_min = 1,
	xp_max = 7,
	head_swivel = "head.control",
	bone_eye_height = -1,
	head_eye_height = -0.5,
	horizontal_head_height = 0,
	curiosity = 10,
	head_yaw="z",
	armor = 100,
	rotate = 180,
	spawn_in_group_min = 1,
	spawn_in_group = 4,
	tilt_swim = true,
	collisionbox = {-0.375, 0.0, -0.375, 0.375, 0.42, 0.375},
	visual = "mesh",
	mesh = "mobs_mc_axolotl.b3d",
	textures = {
		{"mobs_mc_axolotl_brown.png"},
		{"mobs_mc_axolotl_yellow.png"},
		{"mobs_mc_axolotl_green.png"},
		{"mobs_mc_axolotl_pink.png"},
		{"mobs_mc_axolotl_black.png"},
		{"mobs_mc_axolotl_purple.png"},
		{"mobs_mc_axolotl_white.png"}
	},
	sounds = {
		random = "mobs_mc_axolotl",
		damage = "mobs_mc_axolotl_hurt",
		distance = 16,
	},
	animation = {-- Stand: 1-20; Walk: 20-60; Swim: 61-81
		stand_start = 61, stand_end = 81, stand_speed = 15,
		walk_start = 61, walk_end = 81, walk_speed = 15,
		run_start = 61, run_end = 81, run_speed = 20,
	},
	follow = {
		"mcl_buckets:bucket_tropical_fish"
	},
	on_rightclick = function(self, clicker)
		local bn = clicker:get_wielded_item():get_name()
		if bn == "mcl_buckets:bucket_water" or bn == "mcl_buckets:bucket_river_water" then
			if clicker:set_wielded_item("mcl_buckets:bucket_axolotl") then
				local it = clicker:get_wielded_item()
				local m = it:get_meta()
				m:set_string("properties",minetest.serialize(self.object:get_properties()))
				clicker:set_wielded_item(it)
				self:safe_remove()
			end
			awards.unlock(clicker:get_player_name(), "mcl:cutestPredator")
			return
		end
		if self:follow_holding (clicker)
			and self:feed_tame (clicker, 4, true, false) then
			return
		end
	end,
	makes_footstep_sound = false,
	amphibious = true,
	do_go_pos = mcl_mobs.mob_class.pitchswim_do_go_pos,
	idle_gravity_in_liquids = true,
	breathes_in_water = true,
	damage = 2,
	reach = 2,
	attack_type = "melee",
	specific_attack = {
		"mobs_mc:dolphin",
		"mobs_mc:cod",
		"mobs_mc:salmon",
		"mobs_mc:tropical_fish",
		"mobs_mc:guardian",
		"mobs_mc:elder_guardian",
		"mobs_mc:squid",
		"mobs_mc:glow_squid"
	},
	runaway = true,
	movement_speed = 20,
	stepheight = 1.02,
	pace_bonus = 0.5,
	follow_bonus = 0.6,
	run_bonus = 0.6,
	pursuit_bonus = 0.6,
	breed_bonus = 0.2,
	pace_chance = 10,
	pace_interval = 0.5,
	swim_speed_factor = 0.1,
	grounded_speed_factor = 0.5,
	fixed_grounded_speed = 3.0,
	breath_max = 300,
}

------------------------------------------------------------------------
-- Axolotl AI.  Axolotls may play dead when hurt, and periodically
-- surface onto land, before returning to water.  While swimming, they
-- occasionally move towards the player or other mob at which they are
-- gazing, rather than a random position.
------------------------------------------------------------------------

function axolotl:valid_enemy ()
	return self._regeneration_time == nil
end

local function axolotl_regenerate (self, self_pos, dtime)
	if self._regeneration_time then
		self:cancel_navigation ()
		self:halt_in_tracks ()
		self._regeneration_time
			= self._regeneration_time - dtime
		if self._regeneration_time <= 0 then
			self._regeneration_time = nil
		end
		return true
	else
		-- This activity is only initialized by damage
		-- callbacks.
		return false
	end
end

local function manhattan3d (v1, v2)
	return math.abs (v1.x - v2.x)
		+ math.abs (v1.y - v2.y)
		+ math.abs (v1.z - v2.z)
end

local function axolotl_find_water_1 (self_pos)
	local aa = vector.offset (self_pos, -6, -6, -6)
	local bb = vector.offset (self_pos, 6, 6, 6)
	local nodes = minetest.find_nodes_in_area (aa, bb, {
		"group:water",
	})
	table.sort (nodes, function (v1, v2)
		return manhattan3d (self_pos, v1)
			< manhattan3d (self_pos, v2)
	end)
	for _, node in ipairs (nodes) do
		local node_above = vector.offset (node, 0, 1, 0)
		-- Initially search for water above air, but settle
		-- for water in general.
		if minetest.get_node (node_above).name == "air" then
			return node
		end
	end
	return #nodes > 1 and nodes[math.random (#nodes)] or nil
end

local function axolotl_find_water (self, self_pos, dtime)
	if self._moving_to_water then
		if self:navigation_finished () then
			self:halt_in_tracks ()
			self:cancel_navigation ()
			self._moving_to_water = false
			return false
		end
		return true
	end
	if self.pacing then
		return false
	end
	if minetest.get_item_group (self.standing_in, "water") ~= 0 then
		return false
	end
	local node = axolotl_find_water_1 (self_pos)
	if node and self:gopath (node) then
		self._moving_to_water = true
		return "_moving_to_water"
	end
	return false
end

function axolotl:receive_damage (mcl_reason, damage)
	-- If a 50% chance is realized and either the damage is
	-- greater than a number between 0 and 2 or this mob is at
	-- half health or worse, and this mob is waterborne, play dead
	-- while regenerating.
	if math.random (2) == 1
		and (math.random (3) - 1 < damage
			or self.health / self.initial_properties.hp_max < 0.5)
		and damage < self.health
		and minetest.get_item_group (self.standing_in, "water")
		and mcl_reason and mcl_reason.source
		and not self._regeneration_time then
		self._regeneration_time = 10
		self:replace_activity ("_regeneration_time")
		mcl_potions.give_effect_by_level ("regeneration", self.object, 1, 10)
	end

	return mob_class.receive_damage (self, mcl_reason, damage)
end

function axolotl:should_continue_to_attack (object)
	local result = mob_class.should_continue_to_attack (self, object)
	local entity = object:get_luaentity ()

	-- If this entity was just slain by a player, grant
	-- regeneration and remove mining fatigue.
	if entity and entity.dead then
		local attacker = entity._last_attacker
		if attacker and is_valid (attacker)
			and attacker:is_player ()
			and vector.distance (attacker:get_pos (),
						self.object:get_pos ()) < 20 then
			local effect = mcl_potions.get_effect (attacker, "regeneration")
			if not effect or effect.dur < 120 then
				local current_dur = 0
				if effect then
					current_dur = math.max (0, effect.dur - effect.timer)
				end
				local dur = math.min (120, current_dur + 5)
				mcl_potions.give_effect_by_level ("regeneration", attacker,
								1, dur)
			end
			mcl_potions.clear_effect (attacker, "fatigue")
		end
		-- Wait for a cooldown period before hunting another mob.
		self._hunting_cooldown = 120
	end
	return result
end

local axolotl_prey = {
	"mobs_mc:dolphin",
	"mobs_mc:cod",
	"mobs_mc:salmon",
	"mobs_mc:tropical_fish",
	"mobs_mc:squid",
	"mobs_mc:glow_squid",
}

function axolotl:should_attack (object)
	local entity = object:get_luaentity ()
	if entity and table.indexof (axolotl_prey, entity.name) ~= -1
		and self._hunting_cooldown
		and self._hunting_cooldown > 0 then
		return false
	end
	return mob_class.should_attack (self, object)
end

function axolotl:ai_step (dtime)
	mob_class.ai_step (self, dtime)
	if self._hunting_cooldown then
		self._hunting_cooldown
			= math.max (0, self._hunting_cooldown - dtime)
	end
end

axolotl.ai_functions = {
	axolotl_regenerate,
	mob_class.check_breeding,
	mob_class.check_attack,
	mob_class.check_following,
	mob_class.follow_herd,
	axolotl_find_water,
	mob_class.check_pace,
}

------------------------------------------------------------------------
-- Axolotl spawning.
------------------------------------------------------------------------

function axolotl.can_spawn (pos)
	for i = 1, 4 do
		local block = minetest.get_node (vector.offset (pos, 0, -i, 0))
		if block.name == "mcl_core:clay" then
			return true
		end
	end
	return false
end

mcl_mobs.register_mob ("mobs_mc:axolotl", axolotl)

mcl_mobs.spawn_setup ({
	name = "mobs_mc:axolotl",
	type_of_spawning = "water",
	dimension = "overworld",
	min_light = 0,
	max_light = minetest.LIGHT_MAX + 1,
	aoc = 7,
	chance = 100,
	biomes = {
		"LushCaves",
		"LushCaves_underground",
	},
})

-- spawn eggs
mcl_mobs.register_egg("mobs_mc:axolotl", S("Axolotl"), "#e890bf", "#b83D7e", 0)
