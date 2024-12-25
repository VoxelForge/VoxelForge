local S = minetest.get_translator("mobs_mc")
local mob_class = vlf_mobs.mob_class
local posing_humanoid = vlf_mobs.posing_humanoid
local is_valid = vlf_util.is_valid_objectref

------------------------------------------------------------------------
-- Abstract piglin.  Models and armor.
------------------------------------------------------------------------

local formspec_escapes = {
	["\\"] = "\\\\",
	["^"] = "\\^",
	[":"] = "\\:",
}

local function modifier_escape (text)
	return string.gsub (text, "[\\^:]", formspec_escapes)
end

local piglin_base = {
	type = "monster",
	passive = false,
	mesh = "mobs_mc_piglin.b3d",
	spawn_class = "hostile",
	persist_in_peaceful = true,
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.94, 0.3},
	visual = "mesh",
	head_eye_height = 1.79,
	floats = 0,
	can_open_doors = true,
	wears_armor = true,
	armor_drop_probability = {
		head = 0.085,
		torso = 0.085,
		legs = 0.085,
		feet = 0.085,
	},
	_armor_texture_slots = {
		[3] = {
			"head",
			"torso",
			"feet",
		},
		[2] = {
			"legs",
		},
	},
	_armor_transforms = {
		head = function (texture)
			return table.concat ({
				"[combine:64x32:-32,0=",
				"(",
				modifier_escape (texture),
				")",
			})
		end,
	},
	can_wield_items = true,
	wielditem_drop_probability = 0.085,
	wielditem_info = {
		toollike_position = vector.new (0, 4.7, 3.1),
		toollike_rotation = vector.new (-90, 225, 90),
		bow_position = vector.new (1, 4, 0),
		bow_rotation = vector.new (90, 130, 115),
		crossbow_position = vector.new (0, 5.2, 1.2),
		crossbow_rotation = vector.new (0, 0, -45),
		blocklike_position = vector.new (0, 6, 2),
		blocklike_rotation = vector.new (180, -45, 0),
		position = vector.new (0, 5.3, 2),
		rotation = vector.new (90, 0, 0),
		bone = "Wield_Item",
		rotate_bone = true,
	},
	_offhand_wielditem_info = {
		toollike_position = vector.new (0, 4.7, 3.1),
		toollike_rotation = vector.new (-90, 225, 90),
		bow_position = vector.new (1, 4, 0),
		bow_rotation = vector.new (90, 130, 115),
		crossbow_position = vector.new (0, 5.2, 1.2),
		crossbow_rotation = vector.new (0, 0, -45),
		blocklike_position = vector.new (0, 6, 2),
		blocklike_rotation = vector.new (180, -45, 0),
		position = vector.new (0, 5.3, 2),
		rotation = vector.new (90, 0, 0),
		rotate_bone = false,
		bone = "Arm_Left",
	},
	head_swivel = "Head",
	bone_eye_height = 6.7495,
	head_pitch_multiplier = -1,
	animation = {
		stand_start = 0, stand_end = 79, stand_speed = 30,
		walk_start = 168, walk_end = 187, walk_speed = 12,
		run_start = 168, run_end = 187, run_speed = 12,
		punch_start = 189, punch_end = 198, punch_speed = 45,
		jockey_start = 483, jockey_end = 483, jockey_speed = 0,
		dance_start = 500, dance_end = 520, dance_speed = 25,
	},
	makes_footstep_sound = true,
	frame_speed_multiplier = 0.6,
	_inventory_size = 8,
}

------------------------------------------------------------------------
-- Piglin conversion.
------------------------------------------------------------------------

function piglin_base:ai_step (dtime)
	mob_class.ai_step (self, dtime)
	if self._convert_to then
		local self_pos = self.object:get_pos ()
		self:conversion_step (self_pos, dtime)
	end
end

function piglin_base:conversion_step (self_pos, dtime)
	local dimension = vlf_worlds.pos_to_dimension (self_pos)
	if dimension == "overworld" then
		if not self._conversion_time then
			self._conversion_time = 0
		end
		self.shaking = true
		self._conversion_time
			= self._conversion_time + dtime
		if self._conversion_time > 15 then
			local object
				= self:replace_with (self._convert_to, true)
			if object then
				vlf_potions.give_effect ("nausea", object, 1, 10, false)
			end
		end
	else
		self.shaking = false
		self._conversion_time = 0
	end
end

piglin_base.gwp_penalties = table.merge (mob_class.gwp_penalties, {
	DANGER_FIRE = 16.0,
	DAMAGE_FIRE = -1.0,
})

------------------------------------------------------------------------
-- Piglin.  Models, animations, and item wielding.
------------------------------------------------------------------------

local trading_items = {
	{ itemstring = "vlf_core:obsidian", weight = 40, amount_min = 1, amount_max = 1 },
	{ itemstring = "vlf_core:gravel", weight = 40, amount_min = 8, amount_max = 16 },
	{ itemstring = "vlf_mobitems:leather", weight = 40, amount_min = 4, amount_max = 10 },
	{ itemstring = "vlf_nether:soul_sand", weight = 40, amount_min = 4, amount_max = 16 },
	{ itemstring = "vlf_nether:nether_brick", weight = 40, amount_min = 4, amount_max = 16 },
	{ itemstring = "vlf_mobitems:string", weight = 20, amount_min = 3, amount_max = 9 },
	{ itemstring = "vlf_nether:quartz", weight = 20, amount_min = 4, amount_max = 10 },
	{ itemstring = "vlf_potions:water", weight = 40, amount_min = 1, amount_max = 1 },
	{ itemstring = "vlf_core:iron_nugget", weight = 10, amount_min = 10, amount_max = 36 },
	{ itemstring = "vlf_throwing:ender_pearl", weight = 10, amount_min = 2, amount_max = 6 },
	{ itemstring = "vlf_potions:fire_resistance", weight = 8, amount_min = 1, amount_max = 1 },
	{ itemstring = "vlf_potions:fire_resistance_splash", weight = 8, amount_min = 1, amount_max = 1 },
	{ itemstring = "vlf_books:book", weight = 5, func = function(stack, pr) vlf_enchanting.enchant(stack, "soul_speed", vlf_enchanting.random(pr, 1, vlf_enchanting.enchantments["soul_speed"].max_level)) end },
	{ itemstring = "vlf_armor:boots_iron", weight = 8, func = function(stack, pr) vlf_enchanting.enchant(stack, "soul_speed", vlf_enchanting.random(pr, 1, vlf_enchanting.enchantments["soul_speed"].max_level)) end },
	{ itemstring = "vlf_blackstone:blackstone", weight = 40, amount_min = 8, amount_max = 16 },
	{ itemstring = "vlf_bows:arrow", weight = 40, amount_min = 6, amount_max = 12 },
	{ itemstring = "vlf_core:crying_obsidian", weight = 40, amount_min = 1, amount_max = 1 },
	{ itemstring = "vlf_fire:fire_charge", weight = 40, amount_min = 1, amount_max = 1 },
	--{ itemstring = "FIXME:spectral_arrow", weight = 40, amount_min = 6, amount_max = 12 },
}

function mobs_mc.player_wears_gold(player)
	for i=1, 6 do
		local stack = player:get_inventory():get_stack("armor", i)
		local item = stack:get_name()
		if minetest.get_item_group(item, "golden") ~= 0 then
			return true
		end
	end
end

local piglin = table.merge (piglin_base, table.merge (posing_humanoid, {
	description = S("Piglin"),
	hp_min = 16,
	hp_max = 16,
	xp_min = 9,
	xp_max = 9,
	head_eye_height = 1.79,
	armor = {fleshy = 90},
	damage = 5,
	reach = 3,
	spawn_in_group = 4,
	spawn_in_group_min = 2,
	_child_mesh = "mobs_mc_baby_piglin.b3d",
	textures = {
		{
			"extra_mobs_piglin.png",
			"blank.png",
			"blank.png",
		}
	},
	visual_size = {
		x = 1,
		y = 1,
	},
	sounds = {
		random = "mobs_mc_zombiepig_random",
		war_cry = "mobs_mc_zombiepig_war_cry",
		damage = "mobs_mc_zombiepig_hurt",
		death = "mobs_mc_zombiepig_death",
		distance = 16,
	},
	movement_speed = 7.0,
	attack_type = "crossbow",
	specific_attack = {
		"player",
		"mobs_mc:hoglin",
	},
	_admire_cooldown = 0,
	_feed_cooldown = 0,
	_hunting_cooldown = 0,
	pace_bonus = 0.6,
	ranged_attack_radius = 7,
	_crossbow_backoff_threshold = 3.0,
	shoot_offset = 0.5,
	-- ESP is handled in `attack_custom' and `should_continue_to_attack'.
	esp = true,
	_time_to_ride_start = 0,
	_dominant_in_jockeys = false,
	_convert_to = "mobs_mc:zombified_piglin",
	_humanoid_superclass = mob_class,
	_nearby_adults = {},
	_furthest_visible_adults = {},
}))

------------------------------------------------------------------------
-- Piglin visuals.
------------------------------------------------------------------------

function piglin_base:wielditem_transform (info, stack)
	local rot, pos, size
		= mob_class.wielditem_transform (self, info, stack)
	if self.child then
		size.x = size.x * 0.5
		size.y = size.y * 0.5
	end
	return rot, pos, size
end

function piglin:who_are_you_looking_at ()
	if self._interacting_with then
		self._locked_object = self._interacting_with
	else
		mob_class.who_are_you_looking_at (self)
	end
end

function piglin:select_arm_pose ()
	if self.attack and self.attack_type == "crossbow" then
		if self._crossbow_state == 1 then
			return "crossbow_1"
		elseif self._crossbow_state == 2 then
			return "crossbow_2"
		end
	end
	if self._admiring_item then
		return "admire"
	end
	if self._current_animation == "dance" then
		return "gloat"
	end
	return "default"
end

function piglin:get_pitch_of_target ()
	if self.attack then
		local target_pos = self.attack:get_pos ()
		if target_pos then
			local self_pos = self.object:get_pos ()
			local dx = target_pos.x - self_pos.x
			local dy = target_pos.y - (self_pos.y + self.head_eye_height)
			local dz = target_pos.z - self_pos.z
			local xz_mag = math.sqrt (dx * dx + dz * dz)
			local pitch = math.atan2 (dy, xz_mag)
			return vector.new (pitch, 0, 0)
		end
	end
	return vector.zero ()
end

local piglin_poses = {
	default = {
		Arm_Left = {},
		Arm_Right = {},
		Arm_Left_Pitch_Control = {},
		Arm_Right_Pitch_Control = {},
	},
	crossbow_1 = {
		Arm_Left = {
			vector.new (0, 0, 0),
			vector.new (90, -18, 0),
		},
		Arm_Right = {
			vector.new (0, 0, 0),
			vector.new (90, 18, 0),
		},
		Arm_Left_Pitch_Control = {
			nil,
			piglin.get_pitch_of_target,
		},
		Arm_Right_Pitch_Control = {
			nil,
			piglin.get_pitch_of_target,
		},
	},
	crossbow_2 = {
		Arm_Left = {
			vector.new (0, 0, 0),
			vector.new (90, -45, 0),
		},
		Arm_Right = {
			vector.new (0, 0, 0),
			vector.new (90, 18, 0),
		},
		Arm_Left_Pitch_Control = {
			nil,
			piglin.get_pitch_of_target,
		},
		Arm_Right_Pitch_Control = {
			nil,
			piglin.get_pitch_of_target,
		},
	},
	admire = {
		Head = {
			nil,
			vector.new (-25, 0, 0),
		},
		Arm_Right = {},
		Arm_Left = {
			vector.new (0, 0, 0),
			vector.new (60, -25, 0),
		},
		Arm_Left_Pitch_Control = {},
		Arm_Right_Pitch_Control = {},
	},
	gloat = {
		Head = {},
		Arm_Right = {},
		Arm_Left = {},
		Arm_Left_Pitch_Control = {},
		Arm_Right_Pitch_Control = {},
	},
}

local piglin_pose_continuous = {
	crossbow_1 = true,
	crossbow_2 = true,
}

piglin._arm_poses = piglin_poses
piglin._arm_pose_continuous = piglin_pose_continuous

function piglin:ai_step (dtime)
	piglin_base.ai_step (self, dtime)
	if self:check_timer ("piglin_sensing", 0.20) then
		local self_pos = self.object:get_pos ()
		self:step_sensors (self_pos)
	end
	self._admire_cooldown
		= math.max (0, self._admire_cooldown - dtime)
	self._feed_cooldown
		= math.max (0, self._feed_cooldown - dtime)
	self._hunting_cooldown
		= math.max (0, self._hunting_cooldown - dtime)
	if self._piglin_provoker
		and (not is_valid (self._piglin_provoker)
			or self._piglin_provoker_timeout - dtime < 0) then
		self._piglin_provoker = nil
		self._piglin_provoker_timeout = nil
	elseif self._piglin_provoker then
		self._piglin_provoker_timeout
			= self._piglin_provoker_timeout - dtime
	end
	if self._offhand_item ~= "" and not self._admiring_item then
		local self_pos = self.object:get_pos ()
		self:dispose_of_wielditem (self_pos, true)
	end
	self:register_death_of_target ()
	if self.jockey_vehicle and not self._ride_target then
		self:dismount_jockey ()
	end
end

function piglin:check_head_swivel (self_pos, dtime, clear)
	-- Not supported on 5.8.0 or earlier, where bone overrides
	-- cannot be cleared.
	if not self.object or not self.object.set_bone_override then
		mob_class.check_head_swivel (self, self_pos, dtime, clear)
		return
	end

	if self._arm_pose == "admire"
		or self._arm_pose == "gloat" then
		return
	end
	mob_class.check_head_swivel (self, self_pos, dtime, clear)
end

------------------------------------------------------------------------
-- Piglin mechanics.
------------------------------------------------------------------------

local pr = PcgRandom (os.time () + 970)

function piglin:register_death_of_target ()
	if self.attack then
		local entity = self.attack:get_luaentity ()
		if entity and entity.dead and entity.name == "mobs_mc:hoglin" then
			self._hunting_cooldown = pr:next (30, 120)
			if pr:next (1, 10) == 1 then
				self:gloat (self.attack)
			end
		end
	end
end

function piglin:post_load_staticdata ()
	mob_class.post_load_staticdata (self)
	if not self._piglin_initialized
		and not self._structure_spawn
		and pr:next (1, 10) <= 2 then
		self.child = true
		self.movement_speed = self.movement_speed * 1.2
	end
	self._piglin_initialized = true
end

function piglin:tick_breeding ()
	-- Baby Piglins never mature.
end

function piglin:on_spawn ()
	if not self.child and not self._converted_from_old_piglin then
		local f = pr:next (1, 10)
		if f == 1 then
			self.armor_list.head = "vlf_armor:helmet_gold"
		end
		local f = pr:next (1, 10)
		if f == 1 then
			self.armor_list.torso = "vlf_armor:chestplate_gold"
		end
		local f = pr:next (1, 10)
		if f == 1 then
			self.armor_list.legs = "vlf_armor:leggings_gold"
		end
		local f = pr:next (1, 10)
		if f == 1 then
			self.armor_list.feet = "vlf_armor:boots_gold"
		end

		local self_pos = self.object:get_pos ()
		local mob_factor = vlf_worlds.get_special_difficulty (self_pos)
		self:enchant_default_armor (mob_factor, pr)
		self:set_armor_texture ()

		if pr:next (1, 2) == 1 then
			self:set_wielditem (ItemStack ("vlf_bows:crossbow"))
		else
			self:set_wielditem (ItemStack ("vlf_tools:sword_gold"))
		end
		self:enchant_default_weapon (mob_factor, pr)
	end

	self._hunting_cooldown = pr:next (30, 120)
end

function piglin:set_wielditem (stack, drop_probability)
	mob_class.set_wielditem (self, stack, drop_probability)
	local name = stack:get_name ()

	if minetest.get_item_group (name, "crossbow") > 0 then
		self:reset_attack_type ("crossbow")
	else
		self:reset_attack_type ("melee")
	end
end

------------------------------------------------------------------------
-- Piglin AI.
------------------------------------------------------------------------

function mobs_mc.enrage_piglins (player, need_line_of_sight)
	local pos = player:get_pos ()
	local aa = vector.offset (pos, -16, -16, -16)
	local bb = vector.offset (pos, 16, 16, 16)

	for object in minetest.objects_in_area (aa, bb) do
		local entity = object:get_luaentity ()
		if entity and entity.name == "mobs_mc:piglin" then
			local object_pos = object:get_pos ()
			if not need_line_of_sight
				or entity:target_visible (object_pos, player) then
				entity:enrage (player)
			end
		end
	end
end

local function player_ok(player)
	return player and player.is_player and player:is_player ()
		and not player.is_fake_player
end

minetest.register_on_dignode (function (pos, node, player)
	if not player_ok (player) or not pos or not node then
		return
	end

	if minetest.get_item_group (node.name, "piglin_protected") > 0 then
		mobs_mc.enrage_piglins (player, false)
	end
end)

local function piglin_loves_item (itemname)
	return itemname == "vlf_core:stone_with_gold"
		or itemname == "vlf_core:deepslate_with_gold"
		or itemname == "vlf_blackstone:nether_gold"
		-- or itemname == light_weighted_pressure_plate
		or itemname == "vlf_core:gold_ingot"
		or itemname == "vlf_bells:bell"
		or minetest.get_item_group (itemname, "clock") > 0
		or itemname == "vlf_farming:carrot_item_gold"
		or itemname == "vlf_potions:speckled_melon"
		or itemname == "vlf_core:apple_gold"
		or itemname == "vlf_core:apple_gold_enchanted"
		or minetest.get_item_group (itemname, "golden") > 0
		or (minetest.get_item_group (itemname, "tool") > 0
			and itemname:find ("gold"))
		or (minetest.get_item_group (itemname, "weapon") > 0
			and itemname:find ("gold"))
		or itemname == "vlf_raw_ores:raw_gold"
		or itemname == "vlf_raw_ores:raw_gold_block"
end

local function is_piglin_food (itemname)
	return itemname == "vlf_mobitems:porkchop"
		or itemname == "vlf_mobitems:cooked_porkchop"
end

function piglin:should_pick_up (stack)
	local name = stack:get_name ()
	if self.child and name == "vlf_mobitems:leather" then
		return false
	elseif minetest.get_item_group (name, "soul_firelike") > 0 then
		return false
	elseif self._admire_cooldown > 0 and self.attack then
		return false
	elseif name == "vlf_core:gold_ingot" then
		local offhand = self:get_offhand_item ()
		return not piglin_loves_item (offhand:get_name ())
	else
		local fits = self:has_inventory_space (stack)
		if is_piglin_food (name) then
			return fits and self._feed_cooldown == 0
		elseif name == "vlf_core:gold_nugget" then
			return fits
		elseif piglin_loves_item (name) then
			local offhand = self:get_offhand_item ()
			return not piglin_loves_item (offhand:get_name ()) and fits
		else
			-- Piglins don't equip dropped equipment
			-- unless there is room in their inventory for
			-- non-equipment items.
			return self:evaluate_new_item (stack) and fits
		end
	end
end

function piglin:shoot_arrow (pos, dir)
	local wielditem = self:get_wielditem ()
	if minetest.get_item_group (wielditem:get_name (), "crossbow") == 0 then
		wielditem = nil
	end
	vlf_bows.shoot_arrow_crossbow ("vlf_bows:arrow", pos, dir, self:get_yaw (),
				       self.object, 32.0, nil, true, wielditem, false)
end
local function piglin_attracted_to_player (player)
	local item = player:get_wielded_item ()
	return piglin_loves_item (item:get_name ())
end

function piglin:wielditem_better_than (stack, current)
	if vlf_enchanting.has_enchantment (current, "curse_of_binding") then
		return false
	end

	local itemname = stack:get_name ()
	local currentname = current:get_name ()
	local want_first = piglin_loves_item (itemname)
		or minetest.get_item_group (itemname, "crossbow") > 0
	local want_second = piglin_loves_item (currentname)
		or minetest.get_item_group (currentname, "crossbow") > 0

	if want_first and not want_second then
		return true
	elseif not want_first and want_second then
		return false
	end

	if not self.child
	-- Nothing should be able to replace crossbows.
		and minetest.get_item_group (itemname, "crossbow") == 0
		and minetest.get_item_group (currentname, "crossbow") > 0 then
		return false
	end

	return not self.child
		and mob_class.wielditem_better_than (self, stack, current)
end

local piglin_repellents = {
	"group:soul_firelike",
}

function piglin:step_sensors (self_pos)
	local aa = vector.offset (self_pos, -16, -16, -16)
	local bb = vector.offset (self_pos, 16, 16, 16)
	local all = minetest.get_objects_in_area (aa, bb)
	table.sort (all, function (a, b)
		local vis_a = self:target_visible (self_pos, a) and 1 or 0
		local vis_b = self:target_visible (self_pos, b) and 1 or 0
		if vis_a > vis_b then
			return true
		elseif vis_a < vis_b then
			return false
		else
			return vector.distance (a:get_pos (), self_pos)
				> vector.distance (b:get_pos (), self_pos)
		end
	end)

	local nearest_witherlike = nil
	local nearest_prey = nil
	local n_visible_adult_hoglins = 0
	local nearest_baby = nil
	local nearest_baby_hoglin = nil
	local nearest_player_target = nil
	local nearest_attractive_player = nil
	local nearby_adults = {}
	local furthest_visible_adults = {}
	local nearest_zombified = nil
	local nearest_visible_player = nil
	local nearest_target_item = nil
	for _, obj in ipairs (all) do
		local entity = obj:get_luaentity ()
		if not self:target_visible (self_pos, obj) then
			if entity
				and entity.name == "mobs_mc:piglin"
				and not entity.child then
				table.insert (nearby_adults, obj)
			end
			break
		end

		local is_player = obj:is_player ()

		if entity then
			if entity.name == "mobs_mc:wither"
				or entity.name == "mobs_mc:witherskeleton" then
				nearest_witherlike = obj
			elseif entity.name == "mobs_mc:hoglin" then
				nearest_prey = obj
				n_visible_adult_hoglins
					= n_visible_adult_hoglins + 1
			elseif entity.name == "mobs_mc:baby_hoglin" then
				nearest_baby_hoglin = obj
			elseif entity.name == "mobs_mc:piglin_brute" then
				table.insert (furthest_visible_adults, obj)
			elseif entity.name == "mobs_mc:piglin" then
				if entity.child then
					nearest_baby = obj
				else
					table.insert (nearby_adults, obj)
					table.insert (furthest_visible_adults, obj)
				end
			elseif entity.name == "mobs_mc:zoglin"
				or entity.name == "mobs_mc:baby_zoglin"
				or entity.name == "mobs_mc:zombified_piglin" then
				nearest_zombified = obj
			elseif entity.name == "__builtin:item" then
				local stack = ItemStack (entity.itemstring)
				if self:should_pick_up (stack) then
					nearest_target_item = obj
				end
			end
		elseif is_player then
			if not mobs_mc.player_wears_gold (obj)
				and self:attack_player_allowed (obj) then
				nearest_player_target = obj
			end

			if piglin_attracted_to_player (obj) then
				nearest_attractive_player = obj
			end
			nearest_visible_player = obj
		end
	end

	self._nearest_witherlike = nearest_witherlike
	self._nearest_prey = nearest_prey
	self._n_visible_adult_hoglins = n_visible_adult_hoglins
	self._nearest_baby = nearest_baby
	self._nearest_baby_hoglin = nearest_baby_hoglin
	self._nearest_player_target = nearest_player_target
	self._nearest_attractive_player = nearest_attractive_player
	self._nearby_adults = nearby_adults
	self._furthest_visible_adults = furthest_visible_adults
	self._nearest_zombified = nearest_zombified
	self._nearest_visible_player = nearest_visible_player
	self._nearest_target_item = nearest_target_item

	local aa = vector.offset (self_pos, -8, -4, -8)
	local bb = vector.offset (self_pos, 8, 4, 8)
	local blocks = minetest.find_nodes_in_area (aa, bb, piglin_repellents)
	if #blocks > 0 then
		table.sort (blocks, function (a, b)
				    return vector.distance (self_pos, a)
					    < vector.distance (self_pos, b)
		end)
		self._closest_repellent = blocks[1]
	else
		self._closest_repellent = nil
	end
end

function piglin:get_staticdata_table ()
	local staticdata = mob_class.get_staticdata_table (self)
	if staticdata then
		staticdata._nearest_witherlike = nil
		staticdata._nearest_prey = nil
		staticdata._n_visible_adult_hoglins = nil
		staticdata._nearest_baby = nil
		staticdata._nearest_baby_hoglin = nil
		staticdata._nearest_player_target = nil
		staticdata._nearest_attractive_player = nil
		staticdata._nearby_adults = nil
		staticdata._furthest_visible_adults = nil
		staticdata._nearest_zombified = nil
		staticdata._nearest_visible_player = nil
		staticdata._nearest_target_item = nil
		staticdata._piglin_provoker = nil
		staticdata._piglin_provoker_timeout = nil
	end
	return staticdata
end

function piglin:can_accept_offer (itemname)
	return itemname == "vlf_core:gold_ingot"
		and not self._admiring_item
		and not self.child
		and self._admire_cooldown == 0
end

function piglin:on_rightclick (clicker)
	local stack = clicker:get_wielded_item ()
	local name = stack:get_name ()

	if not stack:is_empty () and self:can_accept_offer (name) then
		local playername = clicker:get_player_name ()
		local item = stack:take_item ()
		if not minetest.is_creative_enabled (playername) then
			clicker:set_wielded_item (stack)
		end

		self:set_offhand_item (item)
		self._admiring_item = 6.0
		self:replace_activity ("_admiring_item", false)
	end
end

function piglin:set_offhand_item (stack)
	mob_class.set_offhand_item (self, stack)

	if not stack:is_empty () then
		local name = stack:get_name ()
		if name == "vlf_core:gold_ingot" then
			self.persistent = true
		end
		self._effective_offhand_drop_probability = 1.0
	end
end

function piglin:chuck_at_player (self_pos, object)
	local player = self._nearest_visible_player
	if player and is_valid (player) then
		local dir = vector.direction (object:get_pos (), player:get_pos ())
		local v = vector.multiply (dir, 5.0)
		v.y = v.y + 1.0
		object:set_velocity (v)
	else
		self:chuck_randomly (self_pos, object)
	end
end

function piglin:chuck_randomly (self_pos, object)
	local target = self:pacing_target (self_pos, 2, 4)
	if target then
		local dir = vector.direction (object:get_pos (), target)
		local v = vector.multiply (dir, 5.0)
		v.y = v.y + 1.0
		object:set_velocity (v)
	end
end

function piglin:drop_custom (looting)
	local self_pos = self.object:get_pos ()
	self:drop_inventory (self_pos)
end

function piglin:dispose_of_wielditem (self_pos, no_bartering)
	local wielditem = self:get_offhand_item ()
	if not self.child then
		local pos = vector.offset (self_pos, 0, 1.16, 0)
		local name = wielditem:get_name ()
		if name == "vlf_core:gold_ingot" then
			if no_bartering then
				return
			end
			local loot = vlf_loot.get_loot ({
				stacks_min = 1,
				stacks_max = 1,
				items = trading_items,
			}, pr)

			if loot and #loot >= 1 then
				local obj = minetest.add_item (pos, loot[1])
				if obj then
					self:chuck_at_player (self_pos, obj)
				end
			end
		elseif not wielditem:is_empty () then
			local def = wielditem:get_definition ()
			local equipped = self:try_equip_item (wielditem, def, name)
			if not equipped then
				local remainder = self:add_to_inventory (wielditem)
				if not remainder:is_empty () then
					local obj = minetest.add_item (pos, remainder)
					if obj then
						self:chuck_randomly (self_pos, obj)
					end
				end
			end
		end
	else
		local def = wielditem:get_definition ()
		local name = wielditem:get_name ()
		local equipped = self:try_equip_item (wielditem, def, name)
		local pos = vector.offset (self_pos, 0, 1.16, 0)

		if not equipped then
			local remainder = self:add_to_inventory (wielditem)
			if not remainder:is_empty () then
				local obj = minetest.add_item (pos, remainder)
				if obj then
					self:chuck_randomly (self_pos, obj)
				end
			end
		end
	end
	self:set_offhand_item (ItemStack ())
end

function piglin:default_pickup (object, stack, def, itemname)
	if not self:should_pick_up (stack) then
		return true
	end
	self:cancel_navigation ()
	self:halt_in_tracks ()

	local taken

	if itemname == "vlf_core:gold_nugget" then
		taken = stack:take_item (stack:get_count ())
	else
		taken = stack:take_item ()
	end

	local name = taken:get_name ()
	if piglin_loves_item (name) then
		self:set_offhand_item (taken)
		self._admiring_item = 6.0
		self:replace_activity ("_admiring_item", false)
	elseif is_piglin_food (name) and self._feed_cooldown == 0 then
		self._feed_cooldown = 10
	else
		local equipped = self:try_equip_item (taken, def, itemname)
		if not equipped then
			local remainder = self:add_to_inventory (taken)
			if not remainder:is_empty () then
				local self_pos = self.object:get_pos ()
				local pos = vector.offset (self_pos, 0, 1.16, 0)
				local obj = minetest.add_item (pos, remainder)
				if obj then
					self:chuck_randomly (self_pos, obj)
				end
			end
		end
	end

	if stack:is_empty () then
		object:remove ()
	else
		local entity = object:get_luaentity ()
		entity.itemstring = stack:to_string ()
	end
	return true
end

local function piglin_admire_item (self, self_pos, dtime)
	-- This activity is only initialized manually.
	if self._admiring_item then
		self:cancel_navigation ()
		self:halt_in_tracks ()
		-- Tick admire counter.
		self._admiring_item = self._admiring_item - dtime
		if self._admiring_item <= 0 then
			self:dispose_of_wielditem (self_pos, false)
			self._admiring_item = nil
		end
		return true
	end
	return false
end

local function piglin_seek_treasure (self, self_pos, dtime)
	local wielditem_name = self:get_offhand_item ()

	if self._seeking_treasure then
		self._seeking_treasure
			= self._seeking_treasure + dtime
		if self._seeking_treasure >= 10
			or not is_valid (self._treasure) then
			self._seeking_treasure = nil
			return false
		end
		local treasure_pos = self._treasure:get_pos ()
		if vector.distance (treasure_pos, self_pos) <= 1 then
			self:cancel_navigation ()
			self:halt_in_tracks ()
			self._seeking_treasure = nil
			return false
		end
		if self:check_timer ("_treasure_repath", 2.0) then
			self:gopath (treasure_pos)
		end
		return true
	elseif self._nearest_target_item
		and is_valid (self._nearest_target_item)
		and not piglin_loves_item (wielditem_name) then
		local treasure_pos = self._nearest_target_item:get_pos ()
		if vector.distance (treasure_pos, self_pos) <= 1 then
			return false
		end
		self._seeking_treasure = 0
		self._treasure = self._nearest_target_item
		self:gopath (treasure_pos)
		return "_seeking_treasure"
	end
	return false
end

function piglin:broadcast_anger (source, is_hoglin)
	for _, object in pairs (self._nearby_adults) do
		if object ~= self.object and object ~= source then
			local entity1 = object:get_luaentity ()
			if entity1 then
				entity1:maybe_swap_provoker (source, is_hoglin)
			end
		end
	end
end

function piglin:enrage (source, broadcast)
	local self_pos = self.object:get_pos ()
	if (not source:is_player () or self:attack_player_allowed (source))
		and self:default_rangecheck (self_pos, source) then
		self._piglin_provoker = source
		self._piglin_provoker_timeout = 30

		local entity = source:get_luaentity ()
		local is_hoglin = false
		if entity and entity.name == "mobs_mc:hoglin" then
			self._hunting_cooldown = pr:next (30, 120)
			is_hoglin = true
		end

		if broadcast then
			self:broadcast_anger (source, is_hoglin)
		end
	end
end

local function check_provoker_distance (self, candidate_target)
	local pos = candidate_target:get_pos ()
	local self_pos = self.object:get_pos ()
	local attack_pos = self.attack:get_pos ()

	return vector.distance (self_pos, attack_pos) + 4
		>= vector.distance (self_pos, pos)
end

local RETREAT_ATTEMPTS = 5

function piglin:retaliate_against (source)
	-- Confiscate any item being admired.
	if self._admiring_item then
		self._admiring_item = nil
	end

	if source:is_player () then
		self._admire_cooldown = 20
	end

	local entity = source:get_luaentity ()
	if entity and (entity.name == "mobs_mc:piglin"
			or entity.name == "mobs_mc:piglin_brute") then
		return
	end

	-- Cease retreating if interrupted by a different species of
	-- mob.
	if self._retreat then
		local retreat = self._retreat:get_luaentity ()
		if (entity and retreat and retreat.name ~= entity.name)
			or (not entity and retreat) then
			self._retreat = nil
			self:cancel_navigation ()
			self:halt_in_tracks ()
		end
	end

	if self.child then
		self._retreat_asap = RETREAT_ATTEMPTS
		self._retreat_from = source
		self._retreat_time = 5
		self:broadcast_anger (source)
	elseif entity and entity.name == "mobs_mc:hoglin"
		and #self._nearby_adults < self._n_visible_adult_hoglins then
		self:beat_a_retreat (source)
	elseif not self._retreat then
		if not self.attack or not is_valid (self.attack)
			or check_provoker_distance (self, source) then
			self:enrage (source, true)
		end
	end
end

function piglin:maybe_swap_provoker (source, is_hoglin)
	if self.child then
		return
	end
	if not self._piglin_provoker then
		self._piglin_provoker = source
		self._piglin_provoker_timeout = 30

		if is_hoglin then
			self._hunting_cooldown = pr:next (30, 120)
		end
	else
		local self_pos = self.object:get_pos ()
		local src_pos = source:get_pos ()
		local current_pos = self._piglin_provoker:get_pos ()
		local d1 = vector.distance (self_pos, src_pos)
		local d2 = vector.distance (self_pos, current_pos)
		if d1 <= d2 then
			self._piglin_provoker = source
			self._piglin_provoker_timeout = 30

			if is_hoglin then
				self._hunting_cooldown = pr:next (30, 120)
			end
		end
	end
end

function piglin:attack_custom (self_pos, dtime)
	if self.child then
		return
	end

	local zombie = self._nearest_zombified
	local zombie_pos = zombie and zombie:get_pos () or nil
	if zombie_pos and vector.distance (zombie_pos, self_pos) < 6 then
		return false
	end

	local provoker = self._piglin_provoker
	if provoker and is_valid (provoker)
		and self:default_rangecheck (self_pos, provoker) then
		self:do_attack (provoker, 15)
		return true
	elseif self._nearest_witherlike
		and is_valid (self._nearest_witherlike) then
		self:do_attack (self._nearest_witherlike)
		return true
	else
		local player = self._nearest_player_target
		if player and is_valid (player)
			and self:default_rangecheck (self_pos, player)
			and self:target_visible (self_pos, player) then
			self:do_attack (player)
			return true
		end
	end

	-- Otherwise, if no nearby piglins have recently hunted, and
	-- huntable hoglins are in the vicinity, initiate a hunt.
	if self._hunting_cooldown == 0 and self._nearest_prey
		and is_valid (self._nearest_prey) then
		for _, object in pairs (self._nearby_adults) do
			local entity = object:get_luaentity ()
			if entity and entity._hunting_cooldown > 0 then
				return false
			end
		end

		self:enrage (self._nearest_prey, true)
	end

	return false
end

function piglin:should_continue_to_attack (object)
	if self.child then
		return false
	end
	local self_pos = self.object:get_pos ()
	local zombie = self._nearest_zombified
	local zombie_pos = zombie and zombie:get_pos () or nil
	if zombie_pos and vector.distance (zombie_pos, self_pos) < 6 then
		return false
	end

	local provoker = self._piglin_provoker
	if provoker and is_valid (provoker)
		and self:default_rangecheck (self_pos, provoker) then
		return object == provoker
	elseif self._nearest_witherlike
		and is_valid (self._nearest_witherlike) then
		return object == self._nearest_witherlike
	else
		local player = self._nearest_player_target
		if player and is_valid (player)
			and self:default_rangecheck (self_pos, player)
			and self:target_visible (self_pos, player) then
			self:do_attack (player)
			return object == player
		end
	end

	return false
end

function piglin:gloat (victim)
	if not self._gloat_at then
		self._gloat_at = victim:get_pos ()
		self._gloat_time = 15
		self:gopath (self._gloat_at, 1.0, nil, 2)
		self:replace_activity ("_gloat_at", false)
	end
end

local function piglin_gloat (self, self_pos, dtime)
	if self._gloat_at then
		self._gloat_time = self._gloat_time - dtime
		if self._gloat_time < 0 then
			self._gloat_at = nil
			self:cancel_navigation ()
			self:halt_in_tracks ()
			return false
		end

		if self:navigation_finished () then
			if vector.distance (self_pos, self._gloat_at) <= 3 then
				self:set_animation ("dance")
			else
				self._gloat_at = nil
				return false
			end
		end

		return true
	end
	return false
end

local function get_jock_target (object, n)
	local entity = object:get_luaentity ()
	local rider = entity._jockey_rider
	if rider and rider:get_attach () == object then
		if n == 0 then
			return nil
		end
		local entity = rider:get_luaentity ()
		if entity and entity.name == "mobs_mc:piglin" then
			return get_jock_target (rider, n and n - 1 or 2)
		end
	end
	return object
end

local function get_attachment_pos (object)
	local entity = object:get_luaentity ()
	if entity.name == "mobs_mc:piglin" then
		return {
			x = 0,
			y = 6.25015,
			z = 0,
		}
	else
		return {
			x = 0,
			y = 6.778012,
			z = 0,
		}
	end
end

function piglin:mob_controlling_movement ()
	return self
end

local function baby_piglin_mount_baby_hoglin (self, self_pos, dtime)
	if not self.child then
		return
	end

	if self._ride_target then
		if not is_valid (self._ride_target) then
			self._ride_target = nil
			return false
		end
		self._ride_duration = self._ride_duration - dtime
		if self._ride_duration <= 0 then
			self._ride_target = nil
			return false
		end
		if not self.jockey_vehicle then
			if self._ride_target_mounted then
				self._ride_target = nil
				return false
			end
			local target_pos = self._ride_target:get_pos ()
			local distance = vector.distance (self_pos, target_pos)
			local jock_target = get_jock_target (self._ride_target)

			if not jock_target then
				self._ride_target = nil
				return false
			end

			if distance > 1.0
				and (self:check_timer ("mount_repath", 1.0)
				     or self:navigation_finished ()) then
				self:gopath (target_pos, 0.8)
			elseif distance <= 1.0 then
				self:jock_to_existing (jock_target, "",
						       get_attachment_pos (jock_target))
				self._ride_target_mounted = true
			end
		else
			local entity = self.jockey_vehicle:get_luaentity ()
			if not entity
			-- Disband piglin pile if the member beneath
			-- is no longer riding anything.
				or (entity.name == "mobs_mc:piglin"
					and not entity.jockey_vehicle) then
				self:dismount_jockey ()
				self._ride_target = nil
				return nil
			end
		end
		return true
	else
		local t = self._time_to_ride_start - dtime
		self._time_to_ride_start = t
		if t < 0 then
			self._time_to_ride_start = pr:next (10, 40)
			if self._nearest_baby_hoglin
				and is_valid (self._nearest_baby_hoglin)
				and get_jock_target (self._nearest_baby_hoglin) then
				self._ride_target = self._nearest_baby_hoglin
				self._ride_target_mounted = false
				self._ride_duration = pr:next (10, 30)
				local target_pos = self._ride_target:get_pos ()
				self:gopath (target_pos, 0.8)
				return "_ride_target"
			end
		end
	end
end

local scale_chance = vlf_mobs.scale_chance

local function piglin_interact_with (self, self_pos, dtime)
	if self._interacting_with then
		local object = self._interacting_with
		local object_pos = object:get_pos ()
		if not object_pos
			or vector.distance (object_pos, self_pos) < 2 then
			self:cancel_navigation ()
			self:halt_in_tracks ()
			self._interacting_with = nil
			return false
		end
		if self:navigation_finished () then
			self:look_at (object_pos)
			self._interacting_with = nil
			return false
		end
		if self:check_timer ("interact_repath", 0.5) then
			self:gopath (object_pos, 0.6, nil, 2)
		end
		return true
	elseif self.ai_idle_time >= 5
		and pr:next (1, scale_chance (60, dtime)) == 1 then
		for _, object in ipairs (self._nearby_adults) do
			if object ~= self.object and is_valid (object) then
				local pos = object:get_pos ()
				if vector.distance (pos, self_pos) <= 8 then
					if self:gopath (pos, 0.6, nil, 2) then
						self._interacting_with = object
						return "_interacting_with"
					end
				end
			end
		end
	end

	return false
end

function piglin:should_cancel_retreat (target)
	local entity = target:get_luaentity ()
	if not entity then
		return false
	end
	if entity.name == "mobs_mc:hoglin"
		and #self._nearby_adults >= self._n_visible_adult_hoglins then
		return true
	elseif (entity.name == "mobs_mc:zoglin"
		or entity.name == "mobs_mc:baby_zoglin"
		or entity.name == "mobs_mc:zombified_piglin")
			and target ~= self._nearest_zombified then
		return true
	end
	return false
end

local function piglin_check_avoid (self, self_pos, dtime)
	if self._nearest_zombified then
		self._retreat_asap = RETREAT_ATTEMPTS
		self._retreat_from = self._nearest_zombified
		self._retreat_time = pr:next (5, 7)
	elseif self.child and self._nearest_witherlike then
		self._retreat_asap = RETREAT_ATTEMPTS
		self._retreat_from = self._nearest_witherlike
		self._retreat_time = pr:next (5, 7)
	end
end

local function piglin_retreat (self, self_pos, dtime)
	if self._retreating then
		self._retreat_asap = nil
		self._retreat_time = self._retreat_time - dtime
		local retreat_pos = self._retreating:get_pos ()
		if self._retreat_time <= 0
			or not retreat_pos
			or self:should_cancel_retreat (self._retreating)
			or vector.distance (self_pos, retreat_pos) > 12 then
			self:cancel_navigation ()
			self:halt_in_tracks ()
			self._retreating = nil
			return false
		end
		if self:navigation_finished () then
			local target = self:target_away_from (self_pos, retreat_pos)
			if target then
				self:gopath (target, 1.3)
			end
		end
		return true
	elseif self._retreat_asap then
		local hoglin = self._retreat_from or self.attack
		if not hoglin then
			return false
		end
		-- Retreat from the current target if one exists.
		local pos = hoglin:get_pos ()
		if not pos then
			return false
		end
		self._retreat_asap = self._retreat_asap - 1
		if self._retreat_asap <= 0 then
			self._retreat_asap = nil
		end
		local target = self:target_away_from (self_pos, pos)
		if target then
			self:gopath (target, 1.0)
			self._retreating = hoglin
			return "_retreating"
		end
	end
	return false
end

function piglin:beat_a_retreat (hitter)
	self._retreat_asap = RETREAT_ATTEMPTS
	self._retreat_from = hitter
	self._retreat_time = math.random (5, 20)
	self._hunting_cooldown = pr:next (30, 120)
	for _, piglin in pairs (self._furthest_visible_adults) do
		if piglin ~= self.object then
			local entity = piglin:get_luaentity ()
			if entity then
				entity._retreat_asap = RETREAT_ATTEMPTS
				entity._retreat_time = math.random (5, 20)
				entity._hunting_cooldown = pr:next (30, 120)
			end
		end
	end
end

local function piglin_avoid_repellent (self, self_pos, dtime)
	if self._avoiding_repellent then
		if self:navigation_finished () then
			self._avoiding_repellent = false
			return false
		end
		return true
	elseif self._closest_repellent
		and vector.distance (self_pos, self._closest_repellent) < 8 then
		local target
			= self:target_away_from (self_pos, self._closest_repellent)
		if target then
			self:gopath (target)
			self._avoiding_repellent = true
			return true
		end
	end
	return false
end

function piglin:init_ai ()
	mob_class.init_ai (self)
	self._retreat_asap = nil
end

piglin._is_idle_activity = table.merge (mob_class._is_idle_activity, {
	_interacting_with = true,
})

piglin.ai_functions = {
	piglin_admire_item,
	piglin_seek_treasure,
	piglin_check_avoid,
	piglin_retreat,
	mob_class.check_attack,
	piglin_gloat,
	piglin_avoid_repellent,
	baby_piglin_mount_baby_hoglin,
	mob_class.check_pace,
	piglin_interact_with,
}

------------------------------------------------------------------------
-- Piglin spawning.
------------------------------------------------------------------------

function piglin:check_light (_, _, artificial_light, _)
	if artificial_light > 11 then
		return false, "Too bright"
	end
	return true, ""
end

function piglin.can_spawn (pos)
	local block = minetest.get_node (vector.offset (pos, 0, -1, 0))
	return block.name ~= "vlf_nether:nether_wart_block"
end

vlf_mobs.register_mob ("mobs_mc:piglin", piglin)

------------------------------------------------------------------------
-- Legacy sword piglin.
------------------------------------------------------------------------

local old_sword_piglin = {}

function old_sword_piglin:on_activate (staticdata, dtime)
	local data = staticdata
		and minetest.deserialize (staticdata)
		or {}
	local self_pos = self.object:get_pos ()
	minetest.add_entity (self_pos, "mobs_mc:piglin", minetest.serialize ({
		_wielditem = "vlf_tools:sword_gold",
		nametag = data.nametag,
		_piglin_initialized = true,
		_converted_from_old_piglin = true,
	}))
	self.object:remove ()
end

minetest.register_entity ("mobs_mc:sword_piglin", old_sword_piglin)

------------------------------------------------------------------------
-- Piglin Brute.
------------------------------------------------------------------------

local piglin_brute = table.merge (piglin_base, {
	description = S("Piglin Brute"),
	persist_in_peaceful = false,
	xp_min = 20,
	xp_max = 20,
	hp_min = 50,
	hp_max = 50,
	textures = {
		"extra_mobs_piglin_brute.png",
		"blank.png",
		"blank.png",
	},
	attack_type = "melee",
	can_despawn = false,
	specific_attack = {
		"mobs_mc:witherskeleton",
		"mobs_mc:wither",
	},
	restriction_bonus = 0.6,
	pace_bonus = 0.6,
	damage = 7.0,
	_convert_to = "mobs_mc:zombified_piglin",
	movement_speed = 7.0,
})

------------------------------------------------------------------------
-- Piglin Brute mechanics.
------------------------------------------------------------------------

function piglin_brute:on_spawn ()
	local self_pos = self.object:get_pos ()
	self:set_wielditem (ItemStack ("vlf_tools:axe_gold"))
	self:restrict_to (self_pos, 100)
end

------------------------------------------------------------------------
-- Piglin Brute AI.
------------------------------------------------------------------------

function piglin_brute:ai_step (dtime)
	piglin_base.ai_step (self, dtime)

	if self._piglin_provoker
		and (not is_valid (self._piglin_provoker)
			or self._piglin_provoker_timeout - dtime < 0) then
		self._piglin_provoker = nil
		self._piglin_provoker_timeout = nil
	elseif self._piglin_provoker then
		self._piglin_provoker_timeout
			= self._piglin_provoker_timeout - dtime
	end
end

function piglin_brute:attack_custom (self_pos, dtime)
	local provoker = self._piglin_provoker
	if provoker and is_valid (provoker)
		and self:default_rangecheck (self_pos, provoker) then
		self:do_attack (provoker, 15)
		return true
	end

	local attack = self:attack_default (self_pos, dtime, self.esp)
	if attack then
		self:do_attack (attack)
		return attack
	end
	return false
end

function piglin_brute:should_continue_to_attack (object)
	local provoker = self._piglin_provoker
	local self_pos = self.object:get_pos ()
	if provoker and is_valid (provoker)
		and self:default_rangecheck (self_pos, provoker) then
		return object == self._piglin_provoker
	end

	-- XXX: isn't the dtime parameter to attack_default redundant.
	local attack = self:attack_default (self_pos, 0, self.esp)
	if attack then
		return object == attack
	end
	return false
end

function piglin_brute:maybe_swap_provoker (source, is_hoglin)
	piglin.maybe_swap_provoker (self, source, false)
end

function piglin_brute:broadcast_anger (source, is_hoglin)
	local self_pos = self.object:get_pos ()
	local aa = vector.offset (self_pos, -16, -16, -16)
	local bb = vector.offset (self_pos, 16, 16, 16)
	for object in minetest.objects_in_area (aa, bb) do
		if object ~= self.object and object ~= source then
			local entity = object:get_luaentity ()
			if entity and (entity.name == "mobs_mc:piglin"
				       or entity.name == "mobs_mc:piglin_brute") then
				entity:maybe_swap_provoker (source, is_hoglin)
			end
		end
	end
end

function piglin_brute:enrage (source, broadcast)
	local self_pos = self.object:get_pos ()
	if (not source:is_player () or self:attack_player_allowed (source))
		and self:default_rangecheck (self_pos, source) then
		self._piglin_provoker = source
		self._piglin_provoker_timeout = 30

		if broadcast then
			local entity = source:get_luaentity ()
			local is_hoglin
				= entity and entity.name == "mobs_mc:hoglin"
			self:broadcast_anger (source, is_hoglin)
		end
	end
end

function piglin_brute:retaliate_against (source)
	local entity = source:get_luaentity ()
	if entity and (entity.name == "mobs_mc:piglin"
			or entity.name == "mobs_mc:piglin_brute") then
		return
	end

	if not self.attack or not is_valid (self.attack)
		or check_provoker_distance (self, source) then
		self:enrage (source, true)
	end
end

piglin_brute.ai_functions = {
	mob_class.check_attack,
	mob_class.return_to_restriction,
	mob_class.check_pace,
}

vlf_mobs.register_mob ("mobs_mc:piglin_brute", piglin_brute)

------------------------------------------------------------------------
-- Zombified Piglin.
------------------------------------------------------------------------

local zombie = mobs_mc.zombie

local zombified_piglin = table.merge (zombie, {
	description = S("Zombified Piglin"),
	spawn_class = "passive",
	prevents_sleep_when_hostile = true,
	_neutral_to_players = true,
	attack_npcs = false,
	hp_min = 20,
	hp_max = 20,
	xp_min = 6,
	xp_max = 6,
	damage = 5.0,
	reach = 2,
	specific_attack = {},
	mesh = "mobs_mc_piglin.b3d",
	_child_mesh = "mobs_mc_baby_piglin.b3d",
	textures = {
		{
			"extra_mobs_zombified_piglin.png",
			"blank.png",
			"blank.png",
		}
	},
	visual_size = {
		x = 1.0,
		y = 1.0,
	},
	attack_type = "melee",
	animation = {
		stand_start = 0, stand_end = 79, stand_speed = 30,
		walk_start = 168, walk_end = 187, walk_speed = 12,
		run_start = 168, run_end = 187, run_speed = 12,
		punch_start = 189, punch_end = 198, punch_speed = 45,
		dance_start = 500, dance_end = 520, dance_speed = 25,
	},
	drops = {
		{
			name = "vlf_mobitems:rotten_flesh",
			chance = 1,
			min = 1,
			max = 1,
			looting = "common",
		},
		{
			name = "vlf_core:gold_nugget",
			chance = 1,
			min = 0,
			max = 1,
			looting = "common",
		},
		{
			name = "vlf_core:gold_ingot",
			chance = 40, -- 2.5%
			min = 1,
			max = 1,
			looting = "rare",
		},
	},
	head_swivel = "Head",
	bone_eye_height = 6.7495,
	head_eye_height = 1.79,
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.94, 0.3},
	makes_footstep_sound = true,
	lava_damage = 0,
	fire_damage = 0,
	view_range = 16,
	harmed_by_heal = true,
	fire_damage_resistant = true,
	sounds = {
		random = "mobs_mc_zombiepig_random",
		war_cry = "mobs_mc_zombiepig_war_cry",
		death = "mobs_mc_zombiepig_death",
		damage = "mobs_mc_zombiepig_hurt",
		distance = 16,
	},
	_armor_texture_slots = piglin._armor_texture_slots,
	_armor_transforms = piglin._armor_transforms,
	wielditem_info = piglin.wielditem_info,
	_offhand_wielditem_info = piglin._offhand_wielditem_info,
	_reinforcement_type = "mobs_mc:zombified_piglin",
	_alert_interval = 0,
	ignited_by_sunlight = false,
	group_attack = {
		"mobs_mc:zombified_piglin",
	},
})

------------------------------------------------------------------------
-- Zombified Piglin mechanics.
------------------------------------------------------------------------

function zombified_piglin:zombie_post_spawn ()
	self:set_physics_factor_base ("_spawn_reinforcements_chance", 0.0)
end

function zombified_piglin:tick_breeding ()
end

function zombified_piglin:generate_default_equipment (mob_factor, do_armor, do_wielditems)
	mob_class.generate_default_equipment (self, mob_factor, do_armor, false)

	if do_wielditems then
		self:set_wielditem (ItemStack ("vlf_tools:sword_gold"))
		self:enchant_default_weapon (mob_factor, pr)
	end
end

------------------------------------------------------------------------
-- Zombified Piglin visuals.
------------------------------------------------------------------------

local zombified_piglin_poses = {
	default = {
		Arm_Left_Pitch_Control = {
			nil,
			vector.new (85, 0, 0),
		},
		Arm_Right_Pitch_Control = {
			nil,
			vector.new (85, 0, 0),
		},
		Arm_Left = {
			nil,
			vector.zero (),
		},
		Arm_Right = {
			nil,
			vector.zero (),
		},
	},
	aggressive = {
		Arm_Left_Pitch_Control = {
			nil,
			vector.new (110, 0, 0),
		},
		Arm_Right_Pitch_Control = {
			nil,
			vector.new (110, 0, 0),
		},
		Arm_Left = {
			nil,
			vector.zero (),
		},
		Arm_Right = {
			nil,
			vector.zero (),
		},
	},
}

vlf_mobs.define_composite_pose (zombified_piglin_poses, "jockey", {
	["Leg_Left"] = {
		vector.new (-1, 0, 0),
		vector.new (-90, 35, 0),
	},
	["Leg_Right"] = {
		vector.new (1, 0, 0),
		vector.new (-90, -35, 0),
	},
})

zombified_piglin._arm_poses = zombified_piglin_poses

------------------------------------------------------------------------
-- Zombified Piglin AI.
------------------------------------------------------------------------

function zombified_piglin:alert_other_piglins ()
	local self_pos = self.object:get_pos ()
	local aa = vector.offset (self_pos, -self.view_range, -10, -self.view_range)
	local bb = vector.offset (self_pos, self.view_range, 10, self.view_range)
	for object in minetest.objects_in_area (aa, bb) do
		local entity = object:get_luaentity ()
		if entity and entity.name == "mobs_mc:zombified_piglin"
			and not entity.attack and entity ~= self then
			entity:do_attack (self.attack, 15)
		end
	end
end

function zombified_piglin:ai_step (dtime)
	zombie.ai_step (self, dtime)
	if self.attack and not self.dead then
		if self._alert_interval <= 0 then
			self:alert_other_piglins ()
			self._alert_interval = pr:next (4, 6) / 20.0
		end
	end

	if self.child then
		return
	end

	if self.attack then
		self:add_physics_factor ("movement_speed",
				"mobs_mc:zombified_piglin_attack_modifier",
				1.0, "add")
	else
		self:remove_physics_factor ("movement_speed",
				"mobs_mc:zombified_piglin_attack_modifier")
	end
end

zombified_piglin.ai_functions = {
	mob_class.check_attack,
	mob_class.check_pace,
}

vlf_mobs.register_mob ("mobs_mc:zombified_piglin", zombified_piglin)

------------------------------------------------------------------------
-- Piglin & Zombie Pigman spawning.
------------------------------------------------------------------------

vlf_mobs.spawn_setup({
	name = "mobs_mc:piglin",
	type_of_spawning = "ground",
	dimension = "nether",
	min_light = 0,
	max_light = minetest.LIGHT_MAX+1,
	min_height = vlf_vars.mg_lava_nether_max,
	aoc = 3,
	biomes = {
		"Nether",
		"CrimsonForest"
	},
	chance = 300,
})

vlf_mobs.spawn_setup({
	name = "mobs_mc:zombified_piglin",
	type_of_spawning = "lava",
	dimension = "nether",
	min_light = 0,
	max_light = minetest.LIGHT_MAX+1,
	min_height = vlf_vars.mg_lava_nether_max,
	aoc = 4,
	biomes = {
		"Nether",
		"CrimsonForest"
	},
	chance = 1000,
})

vlf_mobs.register_egg("mobs_mc:piglin", S("Piglin"), "#7b4a17","#d5c381", 0)
vlf_mobs.register_egg("mobs_mc:piglin_brute", S("Piglin Brute"), "#562b0c","#ddc89d", 0)
vlf_mobs.register_egg("mobs_mc:zombified_piglin", S("Zombie Piglin"), "#ea9393", "#4c7129", 0)
