--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")
local mob_class = mcl_mobs.mob_class
local illager = mobs_mc.illager
local posing_humanoid = mcl_mobs.posing_humanoid
local mob_griefing = minetest.settings:get_bool ("mobs_griefing", true)

------------------------------------------------------------------------
-- Vindicator.
------------------------------------------------------------------------

local vindicator = table.merge (illager, table.merge (posing_humanoid, {
	description = S("Vindicator"),
	type = "monster",
	spawn_class = "hostile",
	pathfinding = 1,
	hp_min = 24,
	hp_max = 24,
	xp_min = 6,
	xp_max = 6,
	collisionbox = {-0.3, 0, -0.3, 0.3, 1.95, 0.3},
	visual = "mesh",
	mesh = "mobs_mc_vindicator.b3d",
	head_swivel = "head.control",
	bone_eye_height = 6.61948,
	head_eye_height = 2.2,
	curiosity = 10,
	textures = {
		{
			"mobs_mc_vindicator.png",
		},
	},
	makes_footstep_sound = true,
	damage = 12.0,
	tracking_distance = 12.0,
	follow_range = 12.0,
	view_range = 12.0,
	reach = 2,
	movement_speed = 7.0,
	attack_type = "melee",
	specific_attack = {
		"mobs_mc:iron_golem",
		"mobs_mc:villager",
		"mobs_mc:wandering_trader",
		"player",
	},
	group_attack = {
		"mobs_mc:evoker",
		"mobs_mc:vindicator",
		"mobs_mc:pillager",
		"mobs_mc:illusioner",
		"mobs_mc:witch",
	},
	drops = {
		{
			name = "mcl_core:emerald",
			chance = 1,
			min = 0,
			max = 1,
			looting = "common",
		},
	},
	animation = {
		stand_start = 0, stand_end = 0, stand_speed = 0,
		walk_start = 0, walk_end = 40, walk_speed = 20,
		punch_start = 41, punch_end = 61, punch_speed = 35,
	},
	can_wield_items = "no_pickup",
	wielditem_info = {
		toollike_position = vector.new (-1.0, 2.0, 0) * 2.75,
		toollike_rotation = vector.new (-180, 0, -135),
		bow_position = vector.new (0, 2.1, 0) * 2.75,
		bow_rotation = vector.new (-7, 7, -45),
		crossbow_position = vector.new (-0.45, 2.0, 0) * 2.75,
		crossbow_rotation = vector.new (90, 135, 90),
		blocklike_position = vector.new (-0.8, 2.0, -0.3) * 2.75,
		blocklike_rotation = vector.new (135, 0, 0),
		position = vector.new (-0.6, 2.0, 0) * 2.75,
		rotation = vector.new (-90, 0, 0),
		bone = "bow",
		rotate_bone = true,
	},
	wielditem_drop_probability = 0.085,
	_humanoid_superclass = illager,
	_is_johnny = false,
	floats = 1,
	pace_bonus = 0.6,
	_banner_bone = "head",
	_banner_bone_position = vector.new (0, 0, -2.556729),
}))

------------------------------------------------------------------------
-- Vindicator visuals.
------------------------------------------------------------------------

local vindicator_poses = {
	default = {
		["arm"] = {},
		["magic.arm.left"] = {
			nil,
			nil,
			vector.zero (),
		},
		["magic.arm.right"] = {
			nil,
			nil,
			vector.zero (),
		},
	},
	attack = {
		["arm"] = {
			nil,
			nil,
			vector.zero (),
		},
		["magic.arm.right"] = {
			vector.zero (),
			vector.new (0, 180, 80),
			vector.new (1.0, 1.0, 1.0),
		},
		["magic.arm.left"] = {
			vector.zero (),
			vector.new (0, 180, 180),
			vector.new (1.0, 1.0, 1.0),
		},
	},
}

vindicator._arm_poses = vindicator_poses

function vindicator:select_arm_pose ()
	if self.attack or self._aggressive
		or self._current_animation == "punch" then
		return "attack"
	else
		return "default"
	end
end

------------------------------------------------------------------------
-- Vindicator mechanics.
------------------------------------------------------------------------

local pr = PcgRandom (os.time () + 4)

function vindicator:apply_raid_buffs (stage)
	-- TODO: enchantments.
end

function vindicator:on_spawn ()
	illager.on_spawn (self)

	local self_pos = self.object:get_pos ()
	local mob_factor = mcl_worlds.get_special_difficulty (self_pos)
	local wielditem = ItemStack ("mcl_tools:axe_iron")
	self:set_wielditem (wielditem)
	self:enchant_default_weapon (mob_factor, pr)
end

function vindicator:set_nametag (nametag)
	mob_class.set_nametag (self, nametag)
	if nametag == "Johnny" then
		self._is_johnny = true
	end
end

------------------------------------------------------------------------
-- Vindicator AI.
------------------------------------------------------------------------

local door_penalties = table.merge (mob_class.gwp_penalties, {
	DOOR_WOOD_CLOSED = 0.0,
})

function vindicator:ai_step ()
	self.can_open_doors = false
	self.gwp_penalties = mob_class.gwp_penalties
	local raid = self:_get_active_raid ()

	if raid then
		self.can_open_doors = true
		self.gwp_penalties = door_penalties
	end
end

function vindicator:should_continue_to_attack (object)
	if self._is_johnny then
		return mob_class.should_continue_to_attack (self, object)
	else
		return illager.should_continue_to_attack (self, object)
	end
end

function vindicator:should_attack (object)
	if self._is_johnny then
		if object:is_player () then
			return self:attack_player_allowed (object)
		end

		local entity = object:get_luaentity ()
		return entity ~= self and entity.is_mob
			and entity.health > 0 and entity:valid_enemy ()
	end

	return mob_class.should_attack (self, object)
end

-- Vindicators do not close doors they have passed.

function vindicator:gwp_close_memorized_doors ()
end

function vindicator:gwp_memorize_door (door_node)
end

function vindicator:gwp_open_door (door, nodedef, dtime)
	-- On Normal and Hard, there is a 10% chance per tick that a
	-- vindicator will choose to break rather than open a door.

	if mob_griefing and mcl_vars.difficulty >= 2
		and pr:next (1, 10) == 1
		and not minetest.is_protected (door, "") then
		self:set_animation ("punch")
		self._punch_animation_timeout = 1.0
		minetest.dig_node (door)
		minetest.sound_play ("default_dig_choppy", {
			pos = door,
			gain = 0.5,
		})
	else
		mob_class.gwp_open_door (self, door, nodedef, dtime)
	end
end

function vindicator:gwp_initialize (targets, range, tolerance, penalties)
	-- Vindicators are assigned a relatively low tracking
	-- distance, but their pathfinding abilities should not be
	-- limited accordingly.
	if not range or range < 32.0 then
		range = 32.0
	end
	return mob_class.gwp_initialize (self, targets, range, tolerance, penalties)
end

vindicator.ai_functions = {
	illager.check_recover_banner,
	mob_class.check_attack,
	illager.check_pathfind_to_raid,
	illager.check_navigate_village,
	illager.check_distant_patrol,
	illager.check_celebrate,
	mob_class.check_pace,
}

mcl_mobs.register_mob ("mobs_mc:vindicator", vindicator)

------------------------------------------------------------------------
-- Vindicator spawning.
------------------------------------------------------------------------

-- spawn eggs
mcl_mobs.register_egg ("mobs_mc:vindicator", S("Vindicator"), "#959b9b", "#275e61", 0)
