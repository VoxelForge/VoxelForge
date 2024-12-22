--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")
local mob_class = vlf_mobs.mob_class

--###################
--################### SPIDER
--###################

-- Spider by AspireMint (fishyWET (CC-BY-SA 3.0 license for texture)
minetest.register_entity("mobs_mc:spider_eyes", {
	initial_properties = {
		pointable = false,
		visual = "mesh",
		mesh = "mobs_mc_spider.b3d",
		visual_size = {x=1.01/3, y=1.01/3},
		glow = 50,
		textures = {
			"mobs_mc_spider_eyes.png^[opacity:180",
		},
		selectionbox = {
			0, 0, 0, 0, 0, 0,
		},
		use_texture_alpha = true,
	},
	on_step = function(self)
		if self and self.object then
			if not self.object:get_attach() then
				self.object:remove()
			end
		end
	end,
})

local spider = {
	description = S("Spider"),
	type = "monster",
	spawn_class = "hostile",
	passive = false,
	attack_type = "melee",
	_melee_esp = true,
	damage = 2,
	reach = 2,
	hp_min = 16,
	hp_max = 16,
	xp_min = 5,
	xp_max = 5,
	head_eye_height = 0.65,
	armor = {
		fleshy = 100,
		arthropod = 100,
	},
	head_swivel = "Head_Control",
	bone_eye_height = 1,
	curiosity = 10,
	head_yaw = "z",
	collisionbox = {-0.7, -0.01, -0.7, 0.7, 0.89, 0.7},
	visual = "mesh",
	mesh = "mobs_mc_spider.b3d",
	textures = {
		{"mobs_mc_spider.png"},
	},
	visual_size = {x=1, y=1},
	makes_footstep_sound = false,
	sounds = {
		random = "mobs_mc_spider_random",
		attack = "mobs_mc_spider_attack",
		damage = "mobs_mc_spider_hurt",
		death = "mobs_mc_spider_death",
		-- TODO: sounds: walk
		distance = 16,
	},
	movement_speed = 6.0,
	floats = 1,
	drops = {
		{
			name = "vlf_mobitems:string",
			chance = 1, min = 0, max = 2,
			looting = "common",
		},
		{
			name = "vlf_mobitems:spider_eye",
			chance = 3, min = 1, max = 1,
			looting = "common",
			looting_chance_function = function(lvl)
				return 1 - 2 / (lvl + 3)
			end,
		},
	},
	specific_attack = {
		"player",
		"mobs_mc:iron_golem",
	},
	animation = {
		stand_speed = 10,
		walk_speed = 25,
		stand_start = 20,
		stand_end = 40,
		walk_start = 0,
		walk_end = 20,
	},
	always_climb = true,
	pace_bonus = 0.8,
}

------------------------------------------------------------------------
-- Spider movement and physics.
------------------------------------------------------------------------

spider.slowdown_nodes = table.copy (mob_class.slowdown_nodes)
spider.slowdown_nodes["vlf_core:cobweb"] = nil

function spider:gopath_internal (target, speed_bonus, animation, tolerance, penalties)
	-- Record the destination so that this spider may attempt to
	-- scale walls obstructing movement to it.
	local rc = mob_class.gopath_internal (self, target, speed_bonus,
						animation, tolerance, penalties)
	if rc then
		self._gopath_destination
			= vlf_util.get_nodepos (target)
		return rc
	else
		return nil
	end
end

-- Prevent animations from being reset if an obstruction is being
-- climbed.
function spider:set_animation (anim, fixed_frame)
	if self._climbing_obstruction then
		anim = "walk"
	end
	mob_class.set_animation (self, anim, fixed_frame)
end

function spider:navigation_step (dtime, moveresult)
	mob_class.navigation_step (self, dtime, moveresult)

	if self:navigation_finished () then
		-- If navigation has completed but this spider is
		-- still separated from its target by an obstruction,
		-- continuing moving forward so as to climb over the
		-- obstruction.

		if self._gopath_destination then
			self._climbing_obstruction = true

			-- This renders spiders liable to cross
			-- hazards or stupidly run into obstructions
			-- if they fail to navigate to a target
			-- location.  Identical behavior may be
			-- observed in Minecraft.
			local dest = vector.offset (self._gopath_destination, 0, -0.5, 0)
			local self_pos = self.object:get_pos ()
			local dx = self_pos.x - dest.x
			local dz = self_pos.z - dest.z
			local bb_width = (self.collisionbox[4] - self.collisionbox[1]) / 2
			local dist_xz = math.sqrt (dx * dx + dz * dz)
			if ((self_pos.y <= dest.y and dist_xz > bb_width / 2)
				or dist_xz > bb_width) then
				self.movement_goal = "go_pos"
				self.movement_target = dest
				self.movement_velocity
					= self.gowp_velocity or self.movement_speed
			else
				self._climbing_obstruction = false
				self._gopath_destination = nil
				self:halt_in_tracks ()
			end
		end
	end
end

------------------------------------------------------------------------
-- Spider mechanics.
------------------------------------------------------------------------

local spider_effects = {
	"swiftness",
	"strength",
	"regeneration",
	"invisibility",
}

function spider:mob_activate (staticdata, dtime)
	if not mob_class.mob_activate (self, staticdata, dtime) then
		return false
	end
	minetest.add_entity(self.object:get_pos (), "mobs_mc:spider_eyes")
		:set_attach(self.object, "body.head", vector.new(0,-0.98,2), vector.new(90,180,180))
	return true
end

function spider:on_spawn ()
	-- Spawn as jockeys ridden by skeletons 1% of the time.
	local self_pos = self.object:get_pos ()
	if math.random (100) == 1 then
		local skelly = minetest.add_entity (self_pos,
						"mobs_mc:skeleton")
		if skelly then
			local entity = skelly:get_luaentity ()
			local v = vector.zero ()
			entity:jock_to_existing (self.object, "", v, v)
		end
	end

	-- Occasionally spawn with various beneficial status effects
	-- on hard difficulty.
	if vlf_vars.difficulty == 3 then
		local random = math.random ()
		if random < 0.1 * vlf_worlds.get_special_difficulty (self_pos) then
			local effect = spider_effects[math.random (#spider_effects)]
			vlf_potions.give_effect (effect, self.object, 1, math.huge)
		end
	end
end

local function mc_light_value (self)
	local brightness, value
	local pos = self.object:get_pos ()
	brightness = (minetest.get_node_light (pos) or 0) / 15.0
	value = brightness / (4 - 3 * brightness)
	return value
end

------------------------------------------------------------------------
-- Spider AI.
------------------------------------------------------------------------

function spider:attack_melee (self_pos, dtime, target_pos, line_of_sight)
	if not self.attacking then
		self._leaping = false
	end

	local moveresult = self._moveresult
	if self._leaping then
		if moveresult.touching_ground
			or moveresult.standing_on_object then
			self._leaping = false
		end
		-- Trigger a repath after leaping.
		self._target_pos = nil
		self._attack_delay = 0
		return
	end

	-- Possibly leap at the target.
	local dist = vector.distance (self_pos, target_pos)
	local chance = math.round (5 * dtime / 0.05)
	local r = math.random (chance)

	if self.attacking
		and dist > 2 and dist < 4 and r == 1
		and moveresult.touching_ground
			or moveresult.standing_on_object then
		self._leaping = true
		self:cancel_navigation ()
		self:halt_in_tracks ()
		local leap = vector.direction (self_pos, target_pos)
		local v = self.object:get_velocity ()
		leap.x = leap.x * 8.0 + v.x * 0.2
		leap.y = 8.0
		leap.z = leap.z * 8.0 + v.z * 0.2
		self:set_yaw (math.atan2 (leap.z, leap.x) - math.pi / 2)
		self.object:set_velocity (leap)
		return
	end

	mob_class.attack_melee (self, self_pos, dtime, target_pos, line_of_sight)
end

function spider:should_continue_to_attack (target)
	if math.random (100) == 1 and mc_light_value (self) >= 0.5 then
		return false
	end
	return mob_class.should_continue_to_attack (self, target)
end

function spider:should_attack (target)
	return mob_class.should_attack (self, target)
		and mc_light_value (self) < 0.5
end

vlf_mobs.register_mob ("mobs_mc:spider", spider)

------------------------------------------------------------------------
-- Cave spider.
------------------------------------------------------------------------

local cave_spider = table.merge (spider, {
	description = S("Cave Spider"),
	textures = {
		{"mobs_mc_cave_spider.png^(mobs_mc_spider_eyes.png^[makealpha:0,0,0)"}
	},
	hp_min = 12,
	hp_max = 12,
	head_eye_height = 0.5625,
	collisionbox = {-0.35, -0.01, -0.35, 0.35, 0.46, 0.35},
	visual_size = {
		x=0.55,
		y=0.5,
	},
	sounds = table.merge (spider.sounds, {
		base_pitch = 1.25,
	}),
	animation = table.merge (spider.animation, {
		walk_speed = 40,
	}),
	dealt_effect = {
		name = "poison",
		level = 1,
		dur_easy = 0,
		dur = 7,
		dur_hard = 15,
	},
})

function cave_spider:on_spawn ()
	-- Cave spiders cannot receive special status effects or spawn
	-- as jockeys.
end

vlf_mobs.register_mob ("mobs_mc:cave_spider", cave_spider)

------------------------------------------------------------------------
-- Spider spawning.
------------------------------------------------------------------------

vlf_mobs.spawn_setup ({
	name = "mobs_mc:spider",
	type_of_spawning = "ground",
	dimension = "overworld",
	aoc = 9,
	biomes_except = {
		"MushroomIslandShore",
		"MushroomIsland"
	},
	chance = 1000,
})

-- spawn eggs
vlf_mobs.register_egg("mobs_mc:spider", S("Spider"), "#342d26", "#a80e0e", 0)
vlf_mobs.register_egg("mobs_mc:cave_spider", S("Cave Spider"), "#0c424e", "#a80e0e", 0)
