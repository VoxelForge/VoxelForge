--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")
local is_valid = vlf_util.is_valid_objectref

local mobs_griefing = minetest.settings:get_bool("mobs_griefing", true)
local mob_class = vlf_mobs.mob_class

--###################
--################### CREEPER
--###################

local creeper_defs = {
	type = "monster",
	spawn_class = "hostile",
	hp_min = 20,
	hp_max = 20,
	xp_min = 5,
	xp_max = 5,
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.69, 0.3},
	visual = "mesh",
	mesh = "mobs_mc_creeper.b3d",
	visual_size = { x = 3, y = 3 },
	makes_footstep_sound = true,
	movement_speed = 5.0,
	runaway = true,
	runaway_from = { "mobs_mc:ocelot", "mobs_mc:cat", },
	attack_type = "melee",
	sounds = {
		attack = "tnt_ignite",
		death = "mobs_mc_creeper_death",
		damage = "mobs_mc_creeper_hurt",
		fuse = "tnt_ignite",
		explode = "tnt_explode",
		distance = 16,
	},
	drops = {
		{
			name = "vlf_mobitems:gunpowder",
			chance = 1,
			min = 0,
			max = 2,
			looting = "common",
		},

		-- Head
		{
			name = "vlf_heads:creeper",
			chance = 200, -- 0.5%
			min = 1,
			max = 1,
			mob_head = 1,
		},
	},
	animation = {
		stand_start = 0, stand_end = 0,
		walk_start = 0, walk_end = 40, walk_speed = 48,
		run_start = 0, run_end = 40, run_speed = 48,
		hurt_start = 110, hurt_end = 139,
		death_start = 140, death_end = 189,
		look_start = 50, look_end = 108,
	},
	floats = 1,
	reach = 3,
	pace_bonus = 0.8,
}

---------------------------------------------------------------
-- Creeper mechanics.
---------------------------------------------------------------

local CREEPER_SWELL_TIME = 30/20

function creeper_defs:on_rightclick (clicker)
	local item = clicker:get_wielded_item()
	if minetest.get_item_group(item:get_name(), "flint_and_steel") > 0 then
		if not minetest.is_creative_enabled(clicker:get_player_name()) then
			-- Wear tool
			local wdef = item:get_definition()
			item:add_wear(1000)
			-- Tool break sound
			if item:get_count() == 0 and wdef.sound and wdef.sound.breaks then
				minetest.sound_play(wdef.sound.breaks, {pos = clicker:get_pos(), gain = 0.5}, true)
			end
			clicker:set_wielded_item(item)
		end
		self.attack = self.object
		self:custom_attack ()
	end
end

function creeper_defs:update_swell ()
	local self_pos = self.object:get_pos ()
	local target_pos = self.attack and self.attack:get_pos ()
	local visual_size = self.initial_properties.visual_size
	self:cancel_navigation ()
	self:halt_in_tracks ()

	if not self.attack
		or not is_valid (self.attack)
		or self._swell_time <= 0
		or vector.distance (self_pos, target_pos) > 7.0
		or not self:target_visible (self_pos, self.attack) then
		-- Cancel swelling if the target is no longer valid.
		self._swell_dir = -1
	end

	if self._swell_time >= CREEPER_SWELL_TIME then
		self:boom (vlf_util.get_object_center (self.object),
			   self.explosion_strength, false)
		return
	end

	local swell = self._swell_time / CREEPER_SWELL_TIME
	local interpolated = 1 + math.sin (swell * 100) * swell * 0.01
	swell = swell * swell * swell
	local xz = (1.0 + swell * 0.4) * interpolated
	local y = (1.0 + swell * 0.1) / interpolated
	self:set_properties ({
			visual_size = {
				x = visual_size.x * xz,
				y = visual_size.y * y,
			},
	})

	local t = math.floor (self._swell_time * 20)
	if t % 12 == 6 or self._swell_dir == -1 then
		self:remove_texture_mod ("^[brighten")
	elseif t % 12 == 0 then
		self:add_texture_mod ("^[brighten")
	end
end

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
function creeper_defs:safe_boom(pos, strength, no_remove)
	minetest.sound_play(self.sounds and self.sounds.explode or "tnt_explode", {
		pos = pos,
		gain = 1.0,
		max_hear_distance = self.sounds and self.sounds.distance or 32
	}, true)
	local radius = strength
	blast_damage(pos, radius, self.object)
	vlf_mobs.effect(pos, 32, "vlf_particles_smoke.png", radius * 3, radius * 5, radius, 1, 0)
	if not no_remove then
		if self.is_mob then
			self:safe_remove()
		else
			self.object:remove()
		end
	end
end


-- make explosion with protection and tnt mod check
function creeper_defs:boom(pos, strength, fire, no_remove)
	if mobs_griefing and not minetest.is_protected(pos, "") then
		vlf_explosions.explode(pos, strength, { fire = fire }, self.object)
	else
		self:safe_boom(pos, strength, no_remove)
	end
	-- Dissipate active status effects.
	for name, val in pairs (vlf_potions.all_effects (self.object)) do
		local level = vlf_potions.get_effect_level (self.object,
							    name)
		vlf_potions.add_lingering_effect (pos, name, val.dur / 2,
						  level, 2.5)
	end
	if not no_remove then
		if self.is_mob then
			self:safe_remove()
		else
			self.object:remove()
		end
	end
end

function creeper_defs:do_custom (dtime)
	local swell_time = self._swell_time
	local swell_dir  = self._swell_dir
	if swell_dir == 1 then
		self._swell_time = swell_time + dtime
		self:update_swell ()
		return false
	elseif swell_dir == -1 then
		local t = swell_time - dtime
		self._swell_time = t
		if t <= 0 then
			self._swell_time = 0
		end
		self:update_swell ()
		-- Clear this after update_swell is called, to
		-- override any value it might set.
		if t <= 0 then
			self._swell_dir = nil
		end
		return false
	end
end

function creeper_defs:on_die (pos, vlf_reason)
	-- Drop a random music disc when killed by skeleton or stray
	if vlf_reason and vlf_reason.type == "arrow" then
		if vlf_reason.mob_name == "mobs_mc:skeleton"
			or vlf_reason.mob_name == "mobs_mc:stray" then
			local loot = vlf_jukebox.get_random_creeper_loot()
			if loot then
				minetest.add_item({x=pos.x, y=pos.y+1, z=pos.z}, loot)
			end
		end
	end
end

function creeper_defs:damage_mob (reason, damage)
	mob_class.damage_mob (self, reason, damage)
	if reason == "fall" then
		self._swell_time
			= ((self._swell_time or 0)
				+ math.floor (damage * 1.5) / 20)
		if self._swell_time > CREEPER_SWELL_TIME - 0.25 then
			self._swell_time = CREEPER_SWELL_TIME - 0.25
		end
	end
end

---------------------------------------------------------------
-- Creeper AI.
---------------------------------------------------------------

function creeper_defs:custom_attack ()
	-- Begin swelling.
	self:mob_sound ("attack")
	self._swell_time = self._swell_time or 0
	self._swell_dir = 1
	self:cancel_navigation ()
	self:halt_in_tracks ()
end

---------------------------------------------------------------
-- Creeper registration and spawning.
---------------------------------------------------------------

local regular_creeper = table.merge (creeper_defs, {
	description = S("Creeper"),
	spawn_in_group = 1,
	head_swivel = "Head_Control",
	bone_eye_height = 2.35,
	curiosity = 2,
	textures = {
		{
			"mobs_mc_creeper.png",
			"mobs_mc_empty.png",
		},
	},
	explosion_strength = 3,
	explosion_radius = 3.5,
	explosion_damage_radius = 3.5,
})

function regular_creeper:_on_lightning_strike ()
	vlf_util.replace_mob(self.object, "mobs_mc:creeper_charged")
	return true
end

vlf_mobs.register_mob ("mobs_mc:creeper", regular_creeper)

local charged_creeper = table.merge (creeper_defs, {
	description = S("Charged Creeper"),
	textures = {
		{
			"mobs_mc_creeper.png",
			"mobs_mc_creeper_charge.png^[opacity:95",
		},
	},
	explosion_strength = 6,
	explosion_radius = 8,
	explosion_damage_radius = 8,
	explosion_timer = 1.5,
	use_texture_alpha = true,
})

vlf_mobs.register_mob ("mobs_mc:creeper_charged", charged_creeper)

vlf_mobs.spawn_setup({
	name = "mobs_mc:creeper",
	type_of_spawning = "ground",
	dimension = "overworld",
	aoc = 2,
	biomes_except = {
		"MushroomIslandShore",
		"MushroomIsland"
	},
	chance = 1000,
})

-- spawn eggs
vlf_mobs.register_egg("mobs_mc:creeper", S("Creeper"), "#0da70a", "#000000", 0)
