--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")
local mob_class = mcl_mobs.mob_class
local posing_humanoid = mcl_mobs.posing_humanoid

--###################
--################### SKELETON
--###################

local skeleton = table.merge (posing_humanoid, {
	description = S("Skeleton"),
	type = "monster",
	spawn_class = "hostile",
	hp_min = 20,
	hp_max = 20,
	xp_min = 6,
	xp_max = 6,
	breath_max = -1,
	armor = {undead = 100, fleshy = 100},
	collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.99, 0.3},
	head_swivel = "Head_Control",
	bone_eye_height = 2.38,
	head_eye_height = 1.74,
	curiosity = 6,
	visual = "mesh",
	mesh = "mobs_mc_skeleton.b3d",
	wears_armor = "no_pickup",
	armor_drop_probability = {
		head = 0.085,
		torso = 0.085,
		legs = 0.085,
		feet = 0.085,
	},
	makes_footstep_sound = true,
	textures = {
			"mobs_mc_empty.png", -- armor
			"mobs_mc_empty.png", -- stray overlay
			"mobs_mc_skeleton.png", -- texture
	},
	movement_speed = 5.0,
	sounds = {
		random = "mobs_mc_skeleton_random",
		death = "mobs_mc_skeleton_death",
		damage = "mobs_mc_skeleton_hurt",
		distance = 16,
	},
	runaway_from = {
		"mobs_mc:wolf",
	},
	runaway_view_range = 6,
	runaway_bonus_near = 1.2,
	runaway_bonus_far = 1.0,
	damage = 2,
	reach = 2,
	drops = {
		{
			name = "mcl_bows:arrow",
			chance = 1,
			min = 0,
			max = 2,
			looting = "common",
		},
		{
			name = "mcl_mobitems:bone",
			chance = 1,
			min = 0,
			max = 2,
			looting = "common",
		},
		{
			name = "mcl_heads:skeleton",
			chance = 200, -- 0.5% chance
			min = 1,
			max = 1,
			mob_head = true,
		},
	},
	animation = {
		stand_speed = 15,
		stand_start = 0,
		stand_end = 40,
		walk_speed = 15,
		walk_start = 40,
		walk_end = 60,
	},
	ignited_by_sunlight = true,
	avoids_sunlight = true,
	floats = 0,
	attack_type = "bowshoot",
	specific_attack = {
		"mobs_mc:iron_golem",
	},
	arrow = "mcl_bows:arrow_entity",
	shoot_interval = 1,
	shoot_offset = 1.5,
	harmed_by_heal = true,
	can_wield_items = "no_pickup",
	wielditem_info = {
		toollike_position = vector.new (1.1, 2.1, 0),
		toollike_rotation = vector.new (0, 0, -45),
		bow_position = vector.new (0, 2.1, -0.2),
		bow_rotation = vector.new (-7.107, 7.053, -45.439),
		crossbow_position = vector.new (0.2, 2.1, -0.2),
		crossbow_rotation = vector.new (-97, 45, -95),
		blocklike_position = vector.new (0.4, 2.1, 0),
		blocklike_rotation = vector.new (180, 45, 0),
		position = vector.new (0.2, 2.1, 0),
		rotation = vector.new (-90, 0, 0),
		bone = "wield_item",
		rotate_bone = true,
	},
	wielditem_drop_probability = 0.085,
	_humanoid_superclass = mob_class,
	_mcl_freeze_damage = 0,
	_frozen_time = 0,
})

------------------------------------------------------------------------
-- Skeleton visuals.
------------------------------------------------------------------------

local skeleton_poses = {
	default = {
		["arm.right"] = {},
		["arm.left"] = {},
	},
	shoot = {
		["arm.right"] = {
			nil,
			vector.new (90, 0, 90),
		},
		["arm.left"] = {
			nil,
			vector.new (110, 0, 90),
		},
	},
	attack = {
		["arm.right"] = {
			nil,
			vector.new (90, 0, 90),
		},
		["arm.left"] = {
			nil,
			vector.new (90, 0, 90),
		},
	},
}

mcl_mobs.define_composite_pose (skeleton_poses, "jockey", {
	["leg.right"] = {
		nil,
		vector.new (-115, 0, -90),
	},
	["leg.left"] = {
		nil,
		vector.new (115, 0, -90),
	},
})

skeleton._arm_poses = skeleton_poses

function skeleton:wielditem_transform (info, stack)
	local rot, pos, size
		= mob_class.wielditem_transform (self, info, stack)
	size.x = size.x / 3
	size.y = size.y / 3
	return rot, pos, size
end

function skeleton:select_arm_pose ()
	local basic_pose = "default"

	if self.attack and self.attack_type == "bowshoot" then
		basic_pose = "shoot"
	elseif self.attack then
		basic_pose = "attack"
	end

	if self.jockey_vehicle then
		return "jockey_" .. basic_pose
	else
		return basic_pose
	end
end

------------------------------------------------------------------------
-- Skeleton -> Stray conversion.
------------------------------------------------------------------------

function skeleton:conversion_step (dtime)
	self.shaking = false
	if self.standing_in == "mcl_powder_snow:powder_snow"
		or self.head_in == "mcl_powder_snow:powder_snow" then
		self._frozen_time = self._frozen_time + dtime

		if self._frozen_time > 7 then
			self.shaking = true

			if self._frozen_time > 22 then
				mcl_util.replace_mob (self.object, "mobs_mc:stray", true)
				return
			end
		end
	else
		self._frozen_time = 0
	end
end

------------------------------------------------------------------------
-- Skeleton mechanics.
------------------------------------------------------------------------

local pr = PcgRandom (os.time () + 332)

function skeleton:on_spawn ()
	local self_pos = self.object:get_pos ()
	local mob_factor = mcl_worlds.get_special_difficulty (self_pos)
	-- Enable picking up armor for a random subset of
	-- skeletons.
	if math.random () < 0.55 * mob_factor then
		self.wears_armor = true
		self.can_wield_items = true
	end
	self:skelly_generate_default_equipment (mob_factor)
	return true
end

function skeleton:skelly_generate_default_equipment (mob_factor)
	self:generate_default_equipment (mob_factor, true, false)
	self:set_wielditem (ItemStack ("mcl_bows:bow"))
	self:enchant_default_weapon (mob_factor, pr)
end

function skeleton:on_die (pos, mcl_reason)
	if mcl_reason
		and mcl_reason.type == "arrow"
		and mcl_reason.source then
		local source = mcl_reason.source
		if source:is_player ()
			and vector.distance (pos, source:get_pos ()) > 20 then
			awards.unlock(source:get_player_name (), "mcl:snipeSkeleton")
		end
	end
end

------------------------------------------------------------------------
-- Skeleton AI.
------------------------------------------------------------------------

function skeleton:validate_waypoints (waypoints)
	local self_pos = self.object:get_pos ()
	if self.armor_list.head == ""
		and self:endangered_by_sunlight ()
		and not mcl_weather.is_outdoor (self_pos)
		and #waypoints > 0 then
		local safe_waypoints = {}
		local n_waypoints = #waypoints
		for i = 0, n_waypoints - 1 do
			local r = n_waypoints - i
			if mcl_weather.is_outdoor (waypoints[r]) then
				break
			end
			table.insert (safe_waypoints, waypoints[r])
		end
		self.waypoints = safe_waypoints
		return
	end

	return mob_class.validate_waypoints (self, waypoints)
end

function skeleton:reconfigure_attack_type (wielditem)
	local name = wielditem:get_name ()

	if name ~= "" and minetest.get_item_group (name, "bow") > 0 then
		self:reset_attack_type ("bowshoot")
	else
		self:reset_attack_type ("melee")
	end
end

function skeleton:mob_activate (staticdata, dtime)
	if not posing_humanoid.mob_activate (self, staticdata, dtime) then
		return false
	end
	self:reconfigure_attack_type (self:get_wielditem ())
	return true
end

function skeleton:set_wielditem (stack, drop_probability)
	mob_class.set_wielditem (self, stack, drop_probability)
	self:reconfigure_attack_type (stack)
end

function skeleton:ai_step (dtime)
	mob_class.ai_step (self, dtime)

	if self.conversion_step then
		self:conversion_step (dtime)
	end

	if mcl_vars.difficulty < 3 then
		self.shoot_interval = 2
	else
		self.shoot_interval = 1
	end
end

function skeleton:shoot_arrow (pos, dir)
	local wielditem = self:get_wielditem ()
	mcl_bows.shoot_arrow ("mcl_bows:arrow", pos, dir,
			self:get_yaw (), self.object, 0.5333333, nil,
			false, wielditem)
end

skeleton.ai_functions = {
	mob_class.check_avoid_sunlight,
	mob_class.check_avoid,
	mob_class.check_attack,
	mob_class.check_pace,
}

mcl_mobs.register_mob ("mobs_mc:skeleton", skeleton)
mobs_mc.skeleton = skeleton

------------------------------------------------------------------------
-- Stray.
------------------------------------------------------------------------

local stray = table.merge (skeleton, {
	description = S("Stray"),
	mesh = "mobs_mc_skeleton.b3d",
	textures = {
		{
			"mobs_mc_empty.png", -- armor
			"mobs_mc_stray_overlay.png",
			"mobs_mc_stray.png",
		},
	},
	drops = table.insert (table.copy (skeleton.drops), {
		name = "mcl_potions:slowness_arrow",
		chance = 2,
		min = 1,
		max = 1,
		looting = "rare",
		looting_chance_function = function(lvl)
			local chance = 0.5
			for _ = 1, lvl do
				if chance > 1 then
					return 1
				end
				chance = chance + (1 - chance) / 2
			end
			return chance
		end,
	}),
	conversion_step = nil,
})

function stray:shoot_arrow (pos, dir)
	local wielditem = self:get_wielditem ()
	mcl_bows.shoot_arrow ("mcl_potions:slowness_arrow", pos, dir,
			self:get_yaw (), self.object, 0.5333333, nil,
			false, wielditem)
end

mcl_mobs.register_mob ("mobs_mc:stray", stray)

------------------------------------------------------------------------
-- Skeleton & Stray spawning.
------------------------------------------------------------------------

mcl_mobs.spawn_setup ({
	name = "mobs_mc:skeleton",
	type_of_spawning = "ground",
	dimension = "overworld",
	aoc = 2,
	biomes_except = {
		"MushroomIslandShore",
		"MushroomIsland"
	},
	chance = 800,
})

mcl_mobs.spawn_setup ({
	name = "mobs_mc:skeleton",
	type_of_spawning = "ground",
	dimension = "nether",
	aoc = 2,
	biomes = {
		"SoulsandValley",
	},
	chance = 800,
})

mcl_mobs.spawn_setup ({
	name = "mobs_mc:stray",
	type_of_spawning = "ground",
	dimension = "overworld",
	aoc = 2,
	biomes = {
		"ColdTaiga",
		"IcePlainsSpikes",
		"IcePlains",
		"ExtremeHills+_snowtop",
	},
	chance = 1200,
})

mcl_mobs.register_egg ("mobs_mc:skeleton", S("Skeleton"), "#c1c1c1", "#494949", 0)
mcl_mobs.register_egg ("mobs_mc:stray", S("Stray"), "#5f7476", "#dae8e7", 0)
