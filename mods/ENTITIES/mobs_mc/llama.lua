local S = minetest.get_translator("mobs_mc")
local mob_class = vlf_mobs.mob_class
local horse = mobs_mc.horse
local is_valid = vlf_util.is_valid_objectref

-- table mapping unified color names to non-conforming color names in carpet texture filenames
local messytextures = {
	grey = "gray",
	silver = "light_gray",
}

local llama = table.merge (horse, {
	description = S("Llama"),
	type = "animal",
	spawn_class = "passive",
	passive = false,
	attack_type = "ranged",
	ranged_interval_min = 4.0,
	ranged_interval_max = 4.0,
	ranged_attack_radius = 20.0,
	retaliates = true,
	spawn_in_group_min = 4,
	spawn_in_group = 6,
	head_swivel = "head.control",
	bone_eye_height = 11,
	head_eye_height = 1.7765,
	shoot_offset = 1.6,
	horizontal_head_height=0,
	curiosity = 10,
	head_yaw = "z",
	hp_min = 15,
	hp_max = 30,
	xp_min = 1,
	xp_max = 3,
	collisionbox = {-0.45, -0.01, -0.45, 0.45, 1.86, 0.45},
	visual_size = { x = 1, y = 1, },
	visual = "mesh",
	mesh = "mobs_mc_llama.b3d",
	textures = { -- 1: chest -- 2: decor (carpet) -- 3: llama base texture
		{"blank.png", "blank.png", "mobs_mc_llama_brown.png"},
		{"blank.png", "blank.png", "mobs_mc_llama_creamy.png"},
		{"blank.png", "blank.png", "mobs_mc_llama_gray.png"},
		{"blank.png", "blank.png", "mobs_mc_llama_white.png"},
		{"blank.png", "blank.png", "mobs_mc_llama.png"},
	},
	movement_speed = 3.5,
	drops = {
		{name = "vlf_mobitems:leather",
		 chance = 1,
		 min = 0,
		 max = 2,
		 looting = "common",},
	},
	sounds = {
		random = "mobs_mc_llama",
		eat = "mobs_mc_animal_eat_generic",
		-- TODO: Death and damage sounds
		distance = 16,
	},
	animation = {
		stand_start = 0, stand_end = 0,
		walk_start = 0, walk_end = 40, walk_speed = 25,
		run_start = 0, run_end = 40, run_speed = 30,
	},
	child_animations = {
		stand_start = 41, stand_end = 41,
		walk_start = 41, walk_end = 81, walk_speed = 25,
		run_start = 41, run_end = 81, run_speed = 30,
	},
	_food_items = {
		["vlf_farming:wheat_item"] = {
			2.0, -- Health
			10, -- Age delta in MC ticks.
			3, -- Temper.
		},
		["vlf_farming:hay_block"] = {
			10.0, -- Health.
			90, -- Age delta in MC ticks.
			6, -- Temper.
			true,
		},
	},
	_max_temper = 30,
	pace_bonus = 0.7,
	follow_bonus = 1.25,
	follow_herd_bonus = 1.0,
	follow = {
		"vlf_farming:hay_block",
	},
	view_range = 40,
	tracking_distance = 40,
	_default_decor_texture = "blank.png",
})

------------------------------------------------------------------------------
-- Llama spawning.
------------------------------------------------------------------------------

local pr = PcgRandom (os.time () + 410)
local r = 1 / 2147483647

function llama:on_breed (parent1, parent2)
	local pos = parent1.object:get_pos()
	local child, parent
	if math.random(1,2) == 1 then
		parent = parent1
	else
		parent = parent2
	end
	child = vlf_mobs.spawn_child(pos, parent.name)
	if child then
		local ent_c = child:get_luaentity()
		ent_c.base_texture = table.copy(ent_c.base_texture)
		ent_c.base_texture[2] = "blank.png"
		ent_c:set_textures (ent_c.base_texture)
		ent_c.owner = parent.owner

		local s1 = parent1._llama_strength
		local s2 = parent2._llama_strength
		local child_strength = pr:next (1, math.max (s1, s2))
		if pr:next (0, 2147483647) * r < 0.05
			and child_strength < 5 then
			child_strength = child_strength + 1
		end
		ent_c._llama_strength = child_strength
		ent_c._inv_size = child_strength * 5
		return false
	end
end

function llama:breeding_possible ()
	return self.tamed
end

function llama:initial_movement_properties ()
	local hp_max = self:generate_hp_max ()

	self.object:set_properties ({
			hp_max = hp_max,
	})
	self.hp_max = hp_max
	self.health = hp_max

	local chance = pr:next (0, 2147483647) * r
	local max_bonus = chance < 0.04 and 5 or 3
	self._llama_strength = 1 + pr:next (0, max_bonus - 1)
	self._inv_size = self._llama_strength * 5
end

function llama:on_spawn ()
	self._naked_texture = self.base_texture[3]
	horse.on_spawn (self)
end

function llama:mob_activate (staticdata, dtime)
	if not horse.mob_activate (self, staticdata, dtime) then
		return false
	end
	self:remove_physics_factor ("tracking_distance",
				    "mobs_mc:llama_wolf_attack")
	return true
end

------------------------------------------------------------------------------
-- Llama appearances.
------------------------------------------------------------------------------

function llama:extra_textures (colorstring)
	local carpet = ItemStack (self._saddle)
	local chest = self._chest
	local textures = {
		"blank.png",
		self._default_decor_texture,
		self._naked_texture,
	}
	if chest then
		textures[1] = self._naked_texture
	end
	local def = carpet:get_definition ()
	if def and def._color then
		local carpet_texture = table.concat ({
			"mobs_mc_llama_decor_",
			messytextures[def._color] or def._color,
			".png",
		})
		textures[2] = carpet_texture
	end
	return textures
end

function llama:is_saddle_item (item)
	local name = item:get_name ()
	local def = item:get_definition ()
	return minetest.get_item_group (name, "carpet") > 0
		and def and def._color
end

------------------------------------------------------------------------------
-- Llama AI.
------------------------------------------------------------------------------

function llama:discharge_ranged (self_pos, target_pos)
	local attack = self.attack
	local eye_height = vlf_util.target_eye_height (attack)
	local p = vector.offset (target_pos, 0, eye_height, 0)
	local s = vector.offset (self_pos, 0, self.shoot_offset, 0)
	local vec = vector.subtract (p, s)

	self:mob_sound ("shoot_attack")
	-- Offset by distance.
	vec.y = vec.y + 0.04 * vector.length (vec)
	vec = vector.normalize (vec)

	local arrow = minetest.add_entity (s, "mobs_mc:llama_spit")

	if arrow then
		local entity = arrow:get_luaentity ()
		entity._shooter = self.object
		arrow:set_velocity (vector.multiply (vec, 40))
	end

	-- Call off the attack after firing once.
	if self._is_retaliating then
		self.attack = nil
		self:attack_end ()
	end
end

function llama:join_caravan (head)
	local entity = head:get_luaentity ()
	self._caravan_head = head
	entity._caravan_tail = self.object
	self._caravan_timeout = 0
	self._caravan_speed_factor = 2.1
end

function llama:leave_caravan ()
	if self._caravan_head then
		local entity = self._caravan_head:get_luaentity ()
		if entity then
			entity._caravan_tail = nil
		end
		self._caravan_head = nil
	end
	self:cancel_navigation ()
	self:halt_in_tracks ()
end

function llama:check_caravan ()
	if self._caravan_head
		and not is_valid (self._caravan_head) then
		self._caravan_head = nil
	end
	-- Disband caravan if no longer leashed.
	if not self._caravan_head
		and not self:is_leashed ()
		and self._caravan_tail then
		local entity = self._caravan_tail:get_luaentity ()
		self._caravan_tail = nil

		if entity then
			entity._caravan_head = nil
		end
	end
	if self._caravan_tail
		and not is_valid (self._caravan_tail) then
		self._caravan_tail = nil
	end
end

function llama:is_leashed ()
	-- TODO: leashes
	-- -- For the present any llama with a driver is taken to be
	-- -- leashed.
	-- return self.tamed and self.driver ~= nil
	return false
end

function llama:count_ahead ()
	local n = 0
	local head = self._caravan_head
	while head ~= nil do
		local entity = head:get_luaentity ()
		n = n + 1
		head = entity and entity._caravan_head or nil
	end
	return n
end

function llama:follow_caravan (self_pos, dtime)
	self:check_caravan ()
	if self._caravan_head then
		local head_pos = self._caravan_head:get_pos ()
		local distance = vector.distance (self_pos, head_pos)
		local speed_factor = self._caravan_speed_factor
		if distance > 26 then
			if speed_factor < 3.0 then
				speed_factor = speed_factor * 1.2
				self._caravan_speed_factor = speed_factor
				self._caravan_timeout = 2
			end
			self.gowp_velocity
				= self.movement_speed * speed_factor
			if self._caravan_timeout == 0 then
				self:leave_caravan ()
				return false
			end
		end

		self._caravan_timeout
			= math.max (0, self._caravan_timeout - dtime)
		if distance > 3.0 then
			if self:check_timer ("llama_caravan", 0.3) then
				self:gopath (head_pos, self._caravan_speed_factor,
					     "run", 3.0)
			end
		else
			self:cancel_navigation ()
			self:halt_in_tracks ()
		end
		return true
	elseif not self:is_leashed () then
		-- Attempt to locate a llama within a 9 block radius
		-- that leashed or is fewer than 7 llamas removed from
		-- its leasher.
		if not self:check_timer ("llama_join_caravan", 0.3) then
			return false
		end
		local closest_straggler, closest_leashed, d1, d2

		for object in minetest.objects_inside_radius (self_pos, 9) do
			local entity = object:get_luaentity ()
			if entity and (entity.name == "mobs_mc:llama"
				       or entity.name == "mobs_mc:trader_llama") then
				local dist = vector.distance (object:get_pos (), self_pos)
				if (not closest_straggler or dist < d1)
					and entity._caravan_head
					and not entity._caravan_tail then
					closest_straggler = entity
					d1 = dist
				end
				if (not closest_leashed or dist < d2)
					and entity:is_leashed ()
					and not entity._caravan_tail then
					closest_leashed = entity
					d2 = dist
				end
			end
		end

		-- Minecraft punts very readily if the closest
		-- straggler is unavailable.
		if closest_straggler then
			local num_llamas = closest_straggler:count_ahead ()
			if num_llamas > 7 then
				return false
			end
			self:join_caravan (closest_straggler.object)
			return "_caravan_head"
		end
		if closest_leashed then
			self:join_caravan (closest_leashed.object)
			return "_caravan_head"
		end
		return false
	end
end

function llama:attack_end ()
	mob_class.attack_end (self)
	self:remove_physics_factor ("tracking_distance",
				    "mobs_mc:llama_wolf_attack")
end

function llama:ai_step (dtime)
	horse.ai_step (self, dtime)
	if not self.attack then
		self:remove_physics_factor ("tracking_distance",
					    "mobs_mc:llama_wolf_attack")
	end
end

function llama:targets_for_attack_default (self_pos, esp)
	-- The detection range of a llama is reduced with respect to
	-- wolves, which are the only targets they attack without
	-- provocation.
	return minetest.objects_inside_radius (self_pos, self.view_range * 0.25)
end

function llama:should_attack (object)
	local entity = object:get_luaentity ()
	return entity
		and entity.name == "mobs_mc:wolf"
		and not entity.tamed
		and entity:valid_enemy ()
end

function llama:retaliate_against (source)
	mob_class.retaliate_against (self, source)
	self._is_retaliating = true
end

function llama:do_attack (object, persistence)
	mob_class.do_attack (self, object, persistence)
	self._is_retaliating = false
end

function llama:attack_default (self_pos, dtime, esp)
	local rc = mob_class.attack_default (self, self_pos, dtime, esp)
	-- Don't be so dogged in pursuing wolves.
	if rc then
		local entity = rc:get_luaentity ()
		if entity and entity.name == "mobs_mc:wolf" then
			self:add_physics_factor ("tracking_distance",
						 "mobs_mc:llama_wolf_attack", 0.25)
		end
	end
	return rc
end

llama.ai_functions = {
	horse.check_tame,
	llama.follow_caravan,
	mob_class.check_attack,
	mob_class.check_frightened,
	mob_class.check_breeding,
	mob_class.check_following,
	mob_class.follow_herd,
	mob_class.check_pace,
}

------------------------------------------------------------------------------
-- Llama inventories.
------------------------------------------------------------------------------

function llama:generate_inventory_formspec ()
	if not self._armor_inv_name then
		return "formspec_version[6]"
	end
	local objectname = vlf_util.get_object_name (self.object)
	objectname = minetest.formspec_escape (objectname)
	local armorname = self._armor_inv_name
	armorname = minetest.formspec_escape ("detached:" .. armorname)
	local chest_itemslots
	if self._chest then
		chest_itemslots = string.format ("list[detached:%s;main;5.375,0.875;%d,3;]",
					 self._inv_id, self._llama_strength)
	else
		chest_itemslots = "image[5.375,0.825;6.10,3.625;vlf_formspec_itemslot.png;2]"
	end
	return table.concat ({
		"formspec_version[6]",
		"size[11.75,10.45]",
		"position[0.5,0.5]",
		string.format ("label[0.375,0.5;%s]", objectname),
		vlf_formspec.get_itemslot_bg_v4 (0.375, 2.25, 1, 1),
		string.format ("list[%s;main;0.375,2.25;1,1;]", armorname),
		"image[1.55,0.825;3.625,3.625;vlf_inventory_background9.png;2]",
		string.format ("model[1.55,0.875;3.625,3.5;horse;mobs_mc_llama_preview.b3d;%s;%s]",
			       table.concat (self.base_texture, ","), "-15,135,0"),
		self._chest and vlf_formspec.get_itemslot_bg_v4 (5.375, 0.875,
								 self._llama_strength, 3) or "",
		chest_itemslots,
		-- Main inventory.
		vlf_formspec.get_itemslot_bg_v4 (0.375, 5, 9, 3),
		"list[current_player;main;0.375,5;9,3;9]",
		-- Hotbar.
		vlf_formspec.get_itemslot_bg_v4 (0.375, 8.95, 9, 1),
		"list[current_player;main;0.375,8.95;9,1;]",
		string.format ("listring[%s;main]", armorname),
		self._chest and string.format ("listring[detached:%s;main]",
					self._inv_id) or "",
		"listring[current_player;main]",
	})
end

------------------------------------------------------------------------
-- Llama mounting.
------------------------------------------------------------------------

function llama:init_attachment_position ()
	local vsize = self.object:get_properties().visual_size
	self.driver_attach_at = {x = 0, y = 12.7, z = -5}
	self.driver_eye_offset = {x = 0, y = 6, z = 0}
	self.driver_scale = {x = 1/vsize.x, y = 1/vsize.y}
end

function llama:should_drive ()
	return false
end

vlf_mobs.register_mob ("mobs_mc:llama", llama)
mobs_mc.llama = llama
vlf_entity_invs.register_inv ("mobs_mc:llama", "Llama", nil, true)

------------------------------------------------------------------------
-- Llama spawning.
------------------------------------------------------------------------

vlf_mobs.spawn_setup ({
	name = "mobs_mc:llama",
	type_of_spawning = "ground",
	dimension = "overworld",
	aoc = 5,
	min_height = mobs_mc.water_level+15,
	biomes = {
		"Savanna",
		"SavannaM",
		"SavannaM_beach",
		"Savanna_beach",
		"Savanna_ocean",
		"ExtremeHills",
		"ExtremeHills_beach",
		"ExtremeHillsM",
	},
	chance = 50,
})

vlf_mobs.register_egg ("mobs_mc:llama", S("Llama"), "#c09e7d", "#995f40", 0)

------------------------------------------------------------------------
-- Llama spit entity.
------------------------------------------------------------------------

local llama_spit = {
	initial_properties = {
		visual = "mesh",
		mesh = "mobs_mc_llama_spit.b3d",
		textures = {
			"mobs_mc_llama_spit.png",
		},
		visual_size = {
			x = 0.745,
			y = 0.745,
		},
		collisionbox = {
			-0.15625,
			-0.15625,
			-0.15625,
			0.15625,
			0.15625,
			0.15625,
		},
		physical = true,
		collide_with_objects = false,
		static_save = false,
		use_texture_alpha = false,
	},
}

function llama_spit:hit_object (object)
	return vlf_mobs.get_arrow_damage_func (1, "spit", self._shooter) (self, object)
end

function llama_spit:on_activate (_, _)
	self._prev_pos = self.object:get_pos ()
	self.object:set_acceleration ({
		x = 0,
		y = -9.81,
		z = 0,
	})
	self._particlespawner = minetest.add_particlespawner ({
		time = 0,
		amount = 72,
		vel = {
			min = vector.new (-0.1, 0, -0.1),
			max = vector.new (0.1, 0, 0.1),
		},
		acc = {
			min = vector.new (0, -9.81 / 3, 0),
			max = vector.new (0, -9.81 / 3, 0),
		},
		pos = {
			min = vector.new (-0.2, -0.2, -0.2),
			max = vector.new (0.2, 0.2, 0.2),
		},
		size = {
			min = 1.3,
			max = 2.2,
		},
		exptime = {
			min = 1.0,
			max = 1.0,
		},
		texpool = {
			"vlf_particles_mob_death.png^[colorize:#2c2c2c2c:255",
			"vlf_particles_mob_death.png^[colorize:#c5c5c5c5:255",
			"vlf_particles_mob_death.png^[colorize:#f0f0f0f0:255",
		},
		attached = self.object,
	})
end

function llama_spit:on_deactivate (_)
	minetest.delete_particlespawner (self._particlespawner)
end

function llama_spit:on_step (dtime, moveresult)
	local self_pos = self.object:get_pos ()
	local prev_pos = self._prev_pos

	local raycast = minetest.raycast (prev_pos, self_pos, true, false)
	for hitpoint in raycast do
		if hitpoint.type == "object" then
			local object = hitpoint.ref
			local entity = object:get_luaentity ()
			if object:is_player () or (entity and entity.is_mob)
				and object ~= self._shooter then
				self:hit_object (object)
				self.object:remove ()
				return
			end
		end
	end

	for _, item in pairs (moveresult.collisions) do
		if item.type == "node" then
			self.object:remove ()
			return
		end
	end

	self._prev_pos = self_pos
end

function llama_spit:on_punch (_, _, _, _, _)
	return
end

minetest.register_entity ("mobs_mc:llama_spit", llama_spit)

------------------------------------------------------------------------
-- Obsolete Llama Spit.
------------------------------------------------------------------------

local old_llama_spit = {
	initial_properties = {},
	on_activate = function (self, _, _)
		self.object:remove ()
	end,
}

minetest.register_entity ("mobs_mc:llamaspit", old_llama_spit)
