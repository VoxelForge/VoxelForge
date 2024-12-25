------------------------------------------------------------------------
-- Common Illager and raid mob definitions.  This file defines logic
-- and AI behavior for mobs that participate in raids and patrol over
-- long distances.
------------------------------------------------------------------------

local mob_class = vlf_mobs.mob_class
local is_valid = vlf_util.is_valid_objectref

------------------------------------------------------------------------
-- Patrols.
------------------------------------------------------------------------

local pr = PcgRandom (os.time () + 11)

local patrolling_mob = {
	_raidcaptain = false,
	_patrolling = false,
	_can_serve_as_captain = true,
	_banner_position = vector.new (0, 6, -1),
	_patrol_target = nil,
	_patrol_bonus_captain = 0.595,
	_patrol_bonus_minions = 0.7,
	_patrol_cooldown = 0,
	_patrol_n_retries = 0,
	_is_patrolling_mob = true,
	_banner_bone = "",
}

function patrolling_mob:promote_to_raidcaptain ()
	local self_pos = self.object:get_pos ()
	local entity = "vlf_raids:ominous_banner"
	local banner = minetest.add_entity (self_pos, entity)
	if not banner then
		return
	end
	local layers = vlf_raids.ominous_banner_layers
	local textures = {
		vlf_banners.make_banner_texture ("unicolor_white", layers)
	}
	banner:set_properties ({
			textures = textures,
	})
	banner:set_attach (self.object, self._banner_bone,
			   self._banner_position, nil, true)
	self._raidcaptain = true
end

function patrolling_mob:on_spawn ()
	if not self._structure_spawn
		and not self._raid_spawn
		and not self._patrol_spawn
	then
		if self._can_serve_as_captain
			and not self._raidcaptain then
			local random = pr:next (1, 100)
			if random <= 6 then
				self._raidcaptain = true
			end
		end
	end
end

function patrolling_mob:mob_activate (staticdata, dtime)
	if not mob_class.mob_activate (self, staticdata, dtime) then
		return false
	end
	if self._raidcaptain then
		self:promote_to_raidcaptain ()
	end
	return true
end

function patrolling_mob:despawn_ok (d_to_closest_player)
	return not self._patrolling or d_to_closest_player > 128
end

function patrolling_mob:is_valid_in_patrol ()
	return true
end

function patrolling_mob:find_allies (self_pos)
	local allies = {}
	local aa = vector.offset (self_pos, -16, -16, -16)
	local bb = vector.offset (self_pos, 16, 16, 16)
	for object in minetest.objects_in_area (aa, bb) do
		if object ~= self.object then
			local entity = object:get_luaentity ()
			if entity and entity.is_valid_in_patrol
				and entity:is_valid_in_patrol () then
				table.insert (allies, entity)
			end
		end
	end

	return allies
end

local Y_AXIS = vector.new (0, 1, 0)

local function rotate (v, yaw)
	return vector.rotate_around_axis (v, Y_AXIS, yaw)
end

function patrolling_mob:select_patrol_target (self_pos)
	local x = -500 + pr:next (0, 999)
	local z = -500 + pr:next (0, 999)
	self._patrol_n_retries = 0
	self._patrol_prev_pos = self_pos
	self._patrol_target = {
		x = math.floor (self_pos.x + 0.5) + x,
		y = math.floor (self_pos.y + 0.5),
		z = math.floor (self_pos.z + 0.5) + z,
	}
end

function mobs_mc.find_surface_position (node_pos)
	if node_pos.y < vlf_vars.mg_overworld_min then
		return node_pos
	else
		-- Raycast from a position 256 blocks above the
		-- overworld to the bottom of the world, and locate
		-- the first opaque or liquid non-leaf block.

		local v = vector.copy (node_pos)
		v.y = math.max (node_pos.y, 256)
		local lim
			= math.max (vlf_vars.mg_overworld_min, node_pos.y - 512)
		while v.y >= lim do
			local node = minetest.get_node (v)
			local def = minetest.registered_nodes[node.name]
			if node.name ~= "ignore"
				and not def.groups.leaves
				and (def.groups.liquid or def.walkable) then
				break
			end
			v.y = v.y - 1
		end
		v.y = v.y + 1
		return v
	end
end

function patrolling_mob:find_surface_position (node_pos)
	return mobs_mc.find_surface_position (node_pos)
end

function patrolling_mob:ai_step (dtime)
	mob_class.ai_step (self, dtime)
	self._patrol_cooldown
		= math.max (0, self._patrol_cooldown - dtime)
end

function patrolling_mob:drop_custom (looting_level)
	if self._raidcaptain then
		local self_pos = self.object:get_pos ()
		vlf_raids.drop_obanner (self_pos)
	end
end

function patrolling_mob:on_die (pos, vlf_reason)
	if self._raidcaptain
		and vlf_reason
		and vlf_reason.type == "player" then
		local playername = vlf_reason.source:get_player_name ()
		awards.unlock (playername, "vlf:voluntary_exile")
	end

	-- TODO
end

function patrolling_mob:patrol_unstuck (self_pos)
	local x = pr:next (-8, 8)
	local z = pr:next (-8, 8)
	local node_pos = vlf_util.get_nodepos (self_pos)
	local pos = vector.offset (node_pos, x, 0, z)
	local target = self:find_surface_position (pos)
	self:gopath (target, self._patrol_bonus_minions)
end

function patrolling_mob:check_distant_patrol (self_pos, dtime)
	if self._in_distant_patrol then
		local allies = self:find_allies (self_pos)
		local target = self._patrol_target

		if self._patrol_cooldown > 0 then
			if self:navigation_finished () then
				self._in_distant_patrol = false
				return false
			end
			return true
		end

		if not target or not self._patrolling then
			self._in_distant_patrol = false
			return false
		end
		if not self:navigation_finished () then
			return true
		end

		local prev_pos = self._patrol_prev_pos
		local distance = vector.distance (self_pos, prev_pos)
		self._patrol_prev_pos = self_pos

		if self._patrolling and #allies == 0 then
			self._patrolling = false
			self._in_distant_patrol = false
			return false
		elseif distance < 0.5 and self._patrol_n_retries > 4 then
			self._patrol_cooldown = 10
			self._patrol_n_retries = 0
			self:patrol_unstuck (self_pos)
			return true
		elseif self._raidcaptain
			and vector.distance (self_pos, target) < 10.0 then
			-- Locate a new target.
			self:select_patrol_target (self_pos)
		else
			-- If not enough motion has been registered
			-- since the previous pathfinding attempt,
			-- switch targets.
			if distance < 0.5 then
				self._patrol_n_retries
					= self._patrol_n_retries + 1
			end

			local target_surface
				= vector.subtract (target, 0, -0.5, 0)

			-- Select a position 0.4 * the distance to the
			-- target perpendicular to it.
			local away = vector.subtract (self_pos, target_surface)
			local offset = vector.multiply (rotate (away, math.pi / 2), 0.4)
			local offset_pos = vector.add (offset, target_surface)

			-- Move 10 blocks in the direction of that position.
			local dir = vector.direction (self_pos, offset_pos)
			local pos = vector.multiply (dir, 10)
			pos = vector.add (pos, self_pos)
			local node_pos = vlf_util.get_nodepos (pos)

			-- Find a position on the surface at this
			-- target position.
			node_pos = self:find_surface_position (node_pos)
			local bonus = self._patrol_bonus_captain

			if not self._raidcaptain then
				bonus = self._patrol_bonus_minions
			end
			self:gopath (node_pos, bonus)
			if self._raidcaptain then
				for _, ally in pairs (allies) do
					ally._patrol_target = node_pos
					ally._patrolling = true
				end
			end
			return true
		end
	elseif self._patrolling and self._patrol_target
		and self._patrol_cooldown == 0 then
		self._in_distant_patrol = true
		self._patrol_prev_pos = self_pos
		return "_in_distant_patrol"
	end
	return false
end

mobs_mc.patrolling_mob = patrolling_mob

------------------------------------------------------------------------
-- Raiders.
------------------------------------------------------------------------

local raid_mob = table.merge (patrolling_mob, {
	_can_join_raid = false,
	_aggressive = nil,
	_is_raid_mob = true,
	_locked_target = nil,
	_locked_target_visible_time = 0,
	_get_active_raid = function (self)
		return nil
	end,
	_visited_pois = {},
})

function raid_mob:apply_raid_buffs (stage)
end

function raid_mob:mob_activate (staticdata, dtime)
	if not patrolling_mob.mob_activate (self, staticdata, dtime) then
		return false
	end
	self._visited_pois = {}
	return true
end

function raid_mob:attack_end ()
	mob_class.attack_end (self)
	self._aggressive = nil
	self._locked_target = nil
end

function raid_mob:ai_step (dtime)
	patrolling_mob.ai_step (self, dtime)
	-- Verify that any target acquired by this patrol should
	-- continue to be attacked.
	local target = self._locked_target
	local d = self.tracking_distance
	local self_pos = self.object:get_pos ()
	if target and not is_valid (target) then
		target = nil
	elseif target
		and vector.distance (self_pos, target:get_pos ()) > d then
		target = nil
	elseif target and
		not self:target_visible (self_pos, target)
		and not self.esp then
		local t = self._locked_target_visible_time - dtime
		if t <= 0 then
			target = nil
		end
		self._locked_target_visible_time = t
	elseif target and not self:should_continue_to_attack (target) then
		target = nil
	end
	self._locked_target = target
end

function raid_mob:retaliate_against (source)
	local entity = source:get_luaentity ()

	if not entity or not entity._is_raid_mob then
		mob_class.retaliate_against (self, source)
	end
end

function raid_mob:attack_default (self_pos, dtime, esp)
	if self._locked_target
		and is_valid (self._locked_target) then
		return self._locked_target
	end

	return mob_class.attack_default (self, self_pos, dtime, esp)
end

function raid_mob:lock_target (target)
	self._locked_target = target
	self._locked_target_visible_time = 3
end

function raid_mob:notify_nearby_patrolmen (self_pos, target)
	for object in minetest.objects_inside_radius (self_pos, 8.0) do
		local entity = object:get_luaentity ()

		if entity and entity._is_raid_mob then
			entity:lock_target (target)
		end
	end
end

function raid_mob:target_detected (self_pos, target)
	if not self._patrolling or self.raidmob then
		return false
	end

	-- Remain stationary till the target flees, attacks, or
	-- approaches within 10 blocks, and notify surrounding raiders
	-- of this target also.
	local target_pos = target:get_pos ()
	if not self._aggressive
		and vector.distance (target_pos, self_pos) > 10 then
		if self._aggressive == nil then
			self._aggressive = false
			self:notify_nearby_patrolmen (self_pos, target)
		end
		self:cancel_navigation ()
		self:halt_in_tracks ()
		self:look_at (target_pos)
		return true
	end
	self._aggressive = true
	return false
end

local function decode_banner_item (entity)
	if entity.name ~= "__builtin:item" then
		return nil
	end
	local stack = ItemStack (entity.itemstring)
	if vlf_raids.is_banner_item (stack) then
		local def = stack:get_definition ()
		local name = stack:get_name ()
		return stack, def, name
	end
	return nil
end

function raid_mob:default_pickup (object, stack, def, itemname)
	if vlf_raids.is_banner_item (stack) and self._can_serve_as_captain then
		local raid = self:_get_active_raid ()
		if raid and not raid._raidcaptain then
			local item = stack:take_item ()
			if stack:is_empty () then
				object:remove ()
			else
				local entity = object:get_luaentity ()
				entity.itemstring = stack:to_string ()
			end
			if not item:is_empty () then
				self:promote_to_raidcaptain ()
				raid._raidcaptain = self.object
			end
			return true
		end
	end
	return mob_class.default_pickup (self, object, stack, def, itemname)
end

function raid_mob:check_recover_banner (self_pos, dtime)
	local banner = self._recovering_banner
	if banner then
		local banner = banner:get_pos ()
		if not banner then
			self._recovering_banner = nil
			self:cancel_navigation ()
			self:halt_in_tracks ()
			return false
		end
		if not self:navigation_finished () then
			if self:check_timer ("raid_recover_banner", 2.0) then
				self:gopath (banner, 1.15)
			end
			return true
		end
		if vector.distance (self_pos, banner) < 1.414 then
			for object in minetest.objects_inside_radius (self_pos, 4) do
				local entity = object:get_luaentity ()
				if entity then
					local stack, def, itemname
						= decode_banner_item (entity)
					if stack then
						self:default_pickup (object, stack, def, itemname)
					end
				end
			end
		end
		self._recovering_banner = nil
		return false
	elseif self._can_serve_as_captain then
		local raid = self:_get_active_raid ()
		if raid and not raid._raidcaptain then
			local aa = vector.offset (self_pos, -16, -8, -16)
			local bb = vector.offset (self_pos, 16, 8, 16)
			for object in minetest.objects_in_area (aa, bb) do
				local entity = object:get_luaentity ()
				if entity and decode_banner_item (entity) then
					local banner = object:get_pos ()
					self:gopath (banner, 1.15)
					self._recovering_banner = object
					return "_recovering_banner"
				end
			end
		end
	end
	return false
end

function raid_mob:recruit_reinforcements (self_pos, self_raid)
	local aa = vector.offset (self_pos, -16, -16, -16)
	local bb = vector.offset (self_pos, -16, -16, -16)
	for object in minetest.objects_in_area (self_pos, aa, bb) do
		local entity = object:get_luaentity ()
		if entity and entity._is_raid_mob then
			local raid = entity:_get_active_raid ()
			if not raid then
				vlf_raids.enroll_in_raid (self_raid, entity)
			end
		end
	end
end

local NINETY_DEG = math.pi / 2

function raid_mob:check_pathfind_to_raid (self_pos, dtime)
	local raid = self:_get_active_raid ()
	if not raid then
		self._raid_target_position = nil
		return false
	end
	local nodepos = {
		x = math.floor (self_pos.x + 0.5),
		y = math.floor (self_pos.y + 0.5),
		z = math.floor (self_pos.z + 0.5),
	}
	local proximity = vlf_villages.get_poi_heat (nodepos)
	if self._raid_target_position then
		if proximity >= 4 then
			self._raid_target_position = nil
			return false
		end

		if self:navigation_finished () then
			local target = self._raid_target_position
			local dir = vector.direction (self_pos, target)
			local random = self:target_in_direction (self_pos, 15, 4,
								 dir, NINETY_DEG)
			if random then
				self:gopath (random)
			end
		end

		if self:check_timer ("recruit_raiders", 1.0) then
			self:recruit_reinforcements (self_pos, raid)
		end
		return true
	elseif proximity < 4 then
		self._raid_target_position = raid.pos
		return "_raid_target_position"
	end
	return false
end

function raid_mob:has_visited_poi (poi)
	if #self._visited_pois >= 3 then
		-- Remove the first element.
		local new_list = {}
		table.insert (new_list, self._visited_pois[2])
		table.insert (new_list, self._visited_pois[3])
		self._visited_pois = new_list
	end

	for _, visited_poi in pairs (self._visited_pois) do
		if vector.equals (visited_poi, poi.min) then
			return true
		end
	end
	return false
end

function raid_mob:get_village_poi (self_pos)
	local aa = vector.offset (self_pos, -48, -48, -48)
	local bb = vector.offset (self_pos, 48, 48, 48)
	local poi = vlf_villages.random_poi_in (aa, bb, function (poi)
		local def = vlf_villages.registered_pois[poi.data]

		if def and def.is_home then
			return not self:has_visited_poi (poi)
		end
	end)
	return poi and poi.min or nil
end

local function select_random_position (self, self_pos, poi)
	local dir = vector.direction (self_pos, poi)
	local t1 = self:target_in_direction (self_pos, 16, 7, dir,
					     math.pi / 10)
	if not t1 then
		t1 = self:target_in_direction (self_pos, 8, 7,
					       dir, math.pi / 2)
	end
	return t1
end

function raid_mob:check_navigate_village (self_pos, dtime)
	if self._navigating_to_poi then
		local poi = self._navigating_to_poi
		local state = self:poll_navigation_state (self_pos, dtime)
		local reached = state == "arrived"

		if reached and not self._navigating_around_poi then
			table.insert (self._visited_pois, poi)
			self._poi_reached = true
		end

		if state ~= "wait" then
			if self._poi_reached then
				self._navigating_around_poi = false
				self._navigating_to_poi = false
				return false
			else
				-- Move randomly in the vicinity of
				-- this POI.
				local t1 = select_random_position (self, self_pos, poi)
				if t1 then
					self._navigating_around_poi = true
					self:session_navigate (t1, 1.05, 1.0, nil, nil, 1, 1)
				else
					self._navigating_around_poi = false
					self._navigating_to_poi = false
					return false
				end
			end
		end

		return true
	else
		local raid = self:_get_active_raid ()
		if not raid then
			return false
		end
		local poi = self:get_village_poi (self_pos)
		if not poi then
			return false
		end
		self._navigating_around_poi = false
		self._navigating_to_poi = poi
		self:session_navigate (poi, 1.05, 1.0, nil, nil, 1, 1)
		return "_navigating_to_poi"
	end
end

function raid_mob:check_celebrate (self_pos, dtime)
	-- TODO: raid victory or defeat.
end

mobs_mc.raid_mob = raid_mob

------------------------------------------------------------------------
-- Illagers.
------------------------------------------------------------------------

local illager = table.merge (raid_mob, {
	_is_illager = true,
})

function illager:should_attack (object)
	local entity = object:get_luaentity ()
	-- Illagers should never attack other illagers or villager
	-- children.
	if entity and (entity.name == "mobs_mc:villager" and entity.child
				or entity._is_illager) then
		return false
	end
	return mob_class.should_attack (self, object)
end

function illager:should_continue_to_attack (object)
	local entity = object:get_luaentity ()
	if entity and entity._is_illager then
		return false
	end
	return mob_class.should_continue_to_attack (self, object)
end

mobs_mc.illager = illager
