local S = minetest.get_translator(minetest.get_current_modname())
--local cooldown = {}

local mod_target = minetest.get_modpath("vlf_target")
local enable_pvp = minetest.settings:get_bool("enable_pvp")

local TRIDENT_TIMEOUT = 600

local YAW_OFFSET = -math.pi/2

local STUCK_RECHECK_TIME = 5

minetest.register_on_joinplayer(function(player)
	--cooldown[player:get_player_name()] = false
end)

minetest.register_on_leaveplayer(function(player)
	--cooldown[player:get_player_name()] = false
end)

local GRAVITY = 9.81
local TRIDENT_DURABILITY = 251

local TRIDENT_ENTITY = {
	initial_properties = {
		physical = true,
		pointable = false,
		visual = "mesh",
		mesh = "vlf_trident.obj",
		visual_size = {x=-1, y=1},
		textures = {"vlf_trident.png"},
		collisionbox = {-.1, -.1, -1, .1, .1, 0.5},
		collide_with_objects = true,
	},

	_fire_damage_resistant = true,
	_lastpos={},
	_startpos=nil,
	_damage=8,
	_is_critical=false,
	_stuck=false,
	_stucktimer=nil,
	_stuckrechecktimer=nil,
	_stuckin=nil,
	_shooter=nil,

	_viscosity=0,   -- Viscosity of node the trident is currently in
	_deflection_cooloff=0,
}

minetest.register_entity("vlf_tridents:trident_entity", TRIDENT_ENTITY)

local spawn_trident = function(player)
	local wielditem = player:get_wielded_item()

	local player_pos = player:get_pos()
    local player_look_dir = player:get_look_dir()
    local trident_offset = {x = -0.2, y = 0, z = 0.2}

    local trident_start_pos = {
        x = player_pos.x + player_look_dir.x * trident_offset.z - player_look_dir.z * trident_offset.x,
        y = player_pos.y + trident_offset.y,
        z = player_pos.z + player_look_dir.z * trident_offset.z + player_look_dir.x * trident_offset.x
    }

	local obj = minetest.add_entity(vector.add(trident_start_pos, {x = 0, y = 1.5, z = 0}), "vlf_tridents:trident_entity")
	local yaw = player:get_look_horizontal()+math.pi/2

	if obj then
		local durability = TRIDENT_DURABILITY
		local unbreaking = vlf_enchanting.get_enchantment(wielditem, "unbreaking")
		if unbreaking > 0 then
			durability = durability * (unbreaking + 1)
		end
		wielditem:add_wear(65535/durability)
		obj:set_velocity(vector.multiply(player:get_look_dir(), 20))
		obj:set_acceleration({x=0, y=-GRAVITY, z=0})
		obj:set_yaw(yaw)
	end
end

local function dir_to_pitch(dir)
	--local dir2 = vector.normalize(dir)
	local xz = math.abs(dir.x) + math.abs(dir.z)
	return -math.atan2(-dir.y, xz)
end

local function damage_particles(pos, is_critical)
	if is_critical then
		minetest.add_particlespawner({
			amount = 15,
			time = 0.1,
			minpos = vector.offset(pos, -0.5, -0.5, -0.5),
			maxpos = vector.offset(pos, 0.5, 0.5, 0.5),
			minvel = vector.new(-0.1, -0.1, -0.1),
			maxvel = vector.new(0.1, 0.1, 0.1),
			minexptime = 1,
			maxexptime = 2,
			minsize = 1.5,
			maxsize = 1.5,
			collisiondetection = false,
			vertical = false,
			texture = "vlf_particles_crit.png^[colorize:#bc7a57:127",
		})
	end
end

local function spawn_item(self, pos)
	if not minetest.is_creative_enabled("") then
		local item = minetest.add_item(pos, "vlf_tridents")
		if item and item:get_pos() then
			item:set_velocity(vector.new(0, 0, 0))
			item:set_yaw(self.object:get_yaw())
		end
	end
	vlf_burning.extinguish(self.object)
	self.object:remove()
end


local function random_trident_positions(positions, placement)
	if positions == "x" then
		return math.random(-4, 4)
	elseif positions == "y" then
		return math.random(0, 10)
	end
	if placement == "front" and positions == "z" then
		return 3
	elseif placement == "back" and positions == "z" then
		return -3
	end
	return 0
end

function TRIDENT_ENTITY.get_staticdata(self)
	local out = {
		lastpos = self._lastpos,
		startpos = self._startpos,
		damage = self._damage,
		is_critical = self._is_critical,
		stuck = self._stuck,
		stuckin = self._stuckin,
		stuckin_player = self._in_player,
	}
	if self._stuck then
		if not self._stucktimer then
			self._stucktimer = TRIDENT_TIMEOUT
		end
		out.stuckstarttime = minetest.get_gametime() - self._stucktimer
	end
	if self._shooter and self._shooter:is_player() then
		out.shootername = self._shooter:get_player_name()
	end
	return minetest.serialize(out)
end

function TRIDENT_ENTITY.on_activate(self, staticdata, dtime_s)
	self._time_in_air = 1.0
	local data = minetest.deserialize(staticdata)
	if data then
		self._stuck = data.stuck
		if data.stuck then
			if data.stuckstarttime then
				self._stucktimer = minetest.get_gametime() - data.stuckstarttime
				if self._stucktimer > TRIDENT_TIMEOUT then
					vlf_burning.extinguish(self.object)
					self.object:remove()
					return
				end
			end
			self._stuckrechecktimer = STUCK_RECHECK_TIME

			self._stuckin = data.stuckin
		end

		self._lastpos = data.lastpos
		self._startpos = data.startpos
		self._damage = data.damage
		self._is_critical = data.is_critical
		if data.shootername then
			local shooter = minetest.get_player_by_name(data.shootername)
			if shooter and shooter:is_player() then
				self._shooter = shooter
			end
		end

		if data.stuckin_player then
			self.object:remove()
		end
	end
	self.object:set_armor_groups({ immortal = 1 })
end

function TRIDENT_ENTITY.on_step(self, dtime)
	vlf_burning.tick(self.object, dtime, self)
	-- vlf_burning.tick may remove object immediately
	if not self.object:get_pos() then return end

	self._time_in_air = self._time_in_air + .001

	local pos = self.object:get_pos()
	local dpos = vector.round(vector.new(pos)) -- digital pos
	local node = minetest.get_node(dpos)

	if self._stuck then
		self._stucktimer = self._stucktimer + dtime
		self._stuckrechecktimer = self._stuckrechecktimer + dtime
		if self._stucktimer > TRIDENT_TIMEOUT then
			vlf_burning.extinguish(self.object)
			self.object:remove()
			return
		end
		-- Drop trident as item when it is no longer stuck
		-- FIXME: Tridents are a bit slow to react and continue to float in mid air for a few seconds.
		if self._stuckrechecktimer > STUCK_RECHECK_TIME then
			local stuckin_def
			if self._stuckin then
				stuckin_def = minetest.registered_nodes[minetest.get_node(self._stuckin).name]
			end
			if stuckin_def and stuckin_def.walkable == false then
				spawn_item(self, pos)
				return
			end
			self._stuckrechecktimer = 0
		end

		-- Pickup trident if player is nearby (not in Creative Mode)
		local objects = minetest.get_objects_inside_radius(pos, 1)
		for _,obj in ipairs(objects) do
			if obj:is_player() then
				if not minetest.is_creative_enabled(obj:get_player_name()) then
					if obj:get_inventory():room_for_item("main", "vlf_tridents") then
						obj:get_inventory():add_item("main", "vlf_tridents:trident")
						minetest.sound_play("item_drop_pickup", {
							pos = pos,
							max_hear_distance = 16,
							gain = 1.0,
						}, true)
					end
				end
				vlf_burning.extinguish(self.object)
				self.object:remove()
				return
			end
		end

	-- Check for object "collision". Done every tick (hopefully this is not too stressing)
	else

		if self._damage >= 9 and self._in_player == false then
			minetest.add_particlespawner({
				amount = 20,
				time = .2,
				minpos = vector.new(0,0,0),
				maxpos = vector.new(0,0,0),
				minvel = vector.new(-0.1,-0.1,-0.1),
				maxvel = vector.new(0.1,0.1,0.1),
				minexptime = 0.5,
				maxexptime = 0.5,
				minsize = 2,
				maxsize = 2,
				attached = self.object,
				collisiondetection = false,
				vertical = false,
				texture = "mobs_mc_trident_particle.png",
				glow = 1,
			})
		end

		local closest_object
		local closest_distance

		if self._deflection_cooloff > 0 then
			self._deflection_cooloff = self._deflection_cooloff - dtime
		end

		local trident_dir = self.object:get_velocity()
		-- create a raycast from the trident based on the velocity of the trident to deal with lag
		local raycast = minetest.raycast(pos, vector.add(pos, vector.multiply(trident_dir, 0.1)), true, false)
		for hitpoint in raycast do
			if hitpoint.type == "object" then
				-- find the closest object that is in the way of the trident
				local ok = false
				if hitpoint.ref:is_player() and enable_pvp then
					ok = true
				elseif not hitpoint.ref:is_player() and hitpoint.ref:get_luaentity() then
					if (hitpoint.ref:get_luaentity().is_mob or hitpoint.ref:get_luaentity()._hittable_by_projectile) then
						ok = true
					end
				end
				if ok then
					local dist = vector.distance(hitpoint.ref:get_pos(), pos)
					if not closest_object or not closest_distance then
						closest_object = hitpoint.ref
						closest_distance = dist
					elseif dist < closest_distance then
						closest_object = hitpoint.ref
						closest_distance = dist
					end
				end
			end
		end

		if closest_object then
			local obj = closest_object
			local is_player = obj:is_player()
			local lua = obj:get_luaentity()
			if obj == self._shooter and self._time_in_air > 1.02 or obj ~= self._shooter and (is_player or (lua and (lua.is_mob or lua._hittable_by_projectile))) then
				if obj:get_hp() > 0 then
					-- Check if there is no solid node between trident and object
					local ray = minetest.raycast(self.object:get_pos(), obj:get_pos(), true)
					for pointed_thing in ray do
						if pointed_thing.type == "object" and pointed_thing.ref == closest_object then
							-- Target reached! We can proceed now.
							break
						elseif pointed_thing.type == "node" then
							local nn = minetest.get_node(minetest.get_pointed_thing_position(pointed_thing)).name
							local def = minetest.registered_nodes[nn]
							if (not def) or def.walkable then
								-- There's a node in the way. Delete trident without damage
								vlf_burning.extinguish(self.object)
								self.object:remove()
								return
							end
						end
					end

					-- Punch target object but avoid hurting enderman.
					if not lua or lua.name ~= "mobs_mc:enderman" then
						if not self._in_player then
							damage_particles(vector.add(pos, vector.multiply(self.object:get_velocity(), 0.1)), self._is_critical)
						end
						if vlf_burning.is_burning(self.object) then
							vlf_burning.set_on_fire(obj, 5)
						end

						if not self._in_player and not self._blocked then
							 obj:punch(self.object, 1.0, {
								full_punch_interval=1.0,
								damage_groups={fleshy=self._damage},
							}, self.object:get_velocity())

							if obj:is_player() then
								if not vlf_shields.is_blocking(obj) then
									local placement
									self._placement = math.random(1, 2)
									if self._placement == 1 then
										placement = "front"
									else
										placement = "back"
									end
									self._in_player = true
									if self._placement == 2 then
										self._rotation_station = 90
									else
										self._rotation_station = -90
									end
									self._y_position = random_trident_positions("y", placement)
									self._x_position = random_trident_positions("x", placement)
									if self._y_position > 6 and self._x_position < 2 and self._x_position > -2 then
										self._attach_parent = "Head"
										self._y_position = self._y_position - 6
									elseif self._x_position > 2 then
										self._attach_parent = "Arm_Right"
										self._y_position = self._y_position - 3
										self._x_position = self._x_position - 2
									elseif self._x_position < -2 then
										self._attach_parent = "Arm_Left"
										self._y_position = self._y_position - 3
										self._x_position = self._x_position + 2
									else
										self._attach_parent = "Body"
									end
									self._z_rotation = math.random(-30, 30)
									self._y_rotation = math.random( -30, 30)
									self.object:set_attach(
										obj, self._attach_parent,
										vector.new(self._x_position, self._y_position, random_trident_positions("z", placement)),
										vector.new(0, self._rotation_station + self._y_rotation, self._z_rotation)
									)
								else
									self._blocked = true
									self.object:set_velocity(vector.multiply(self.object:get_velocity(), -0.25))
								end
								minetest.after(150, function()
									self.object:remove()
								end)
							end
						end
					end


					--if is_player then
					--	if self._shooter and self._shooter:is_player() and not self._in_player and not self._blocked then
							-- “Ding” sound for hitting another player
							-- TODO: Add sound
							-- minetest.sound_play({name="vlf_bows_hit_player", gain=0.1}, {to_player=self._shooter:get_player_name()}, true)
					--	end
					--end

					--if not self._in_player and not self._blocked then
						-- TODO: Add sound
						-- minetest.sound_play({name="vlf_bows_hit_other", gain=0.3}, {pos=self.object:get_pos(), max_hear_distance=16}, true)
					--end
				end
				if not obj:is_player() then
					vlf_burning.extinguish(self.object)
					if self._piercing == 0 then
						self.object:remove()
					end
				end
				return
			end
		end
	end

	-- Check for node collision
	if self._lastpos.x~=nil and not self._stuck then
		local def = minetest.registered_nodes[node.name]
		local vel = self.object:get_velocity()
		-- Trident has stopped in one axis, so it probably hit something.
		-- This detection is a bit clunky, but sadly, MT does not offer a direct collision detection for us. :-(
		if (math.abs(vel.x) < 0.0001) or (math.abs(vel.z) < 0.0001) or (math.abs(vel.y) < 0.00001) then
			-- Check for the node to which the trident is pointing
			local dir
			if math.abs(vel.y) < 0.00001 then
				if self._lastpos.y < pos.y then
					dir = vector.new(0, 1, 0)
				else
					dir = vector.new(0, -1, 0)
				end
			else
				dir = minetest.facedir_to_dir(minetest.dir_to_facedir(minetest.yaw_to_dir(self.object:get_yaw()-YAW_OFFSET)))
			end
			self._stuckin = vector.add(dpos, dir)
			local snode = minetest.get_node(self._stuckin)
			local sdef = minetest.registered_nodes[snode.name]

			-- If node is non-walkable, unknown or ignore, don't make trident stuck.
			-- This causes a deflection in the engine.
			if not sdef or sdef.walkable == false or snode.name == "ignore" then
				self._stuckin = nil
				if self._deflection_cooloff <= 0 then
					-- Lose 1/3 of velocity on deflection
					local newvel = vector.multiply(vel, 0.6667)

					self.object:set_velocity(newvel)
					-- Reset deflection cooloff timer to prevent many deflections happening in quick succession
					self._deflection_cooloff = 1.0
				end
			else

				-- Node was walkable, make trident stuck
				self._stuck = true
				self._stucktimer = 0
				self._stuckrechecktimer = 0

				self.object:set_velocity(vector.new(0, 0, 0))
				self.object:set_acceleration(vector.new(0, 0, 0))

				-- TODO: Add sound
				-- minetest.sound_play({name="vlf_bows_hit_other", gain=0.3}, {pos=self.object:get_pos(), max_hear_distance=16}, true)

				if vlf_burning.is_burning(self.object) and snode.name == "vlf_tnt:tnt" then
					tnt.ignite(self._stuckin)
				end

				-- Activate target
				if mod_target and snode.name == "vlf_target:target_off" then
					vlf_target.hit(self._stuckin, 1) --10 redstone ticks
				end

				-- Push the button! Push, push, push the button!
				-- TODO: Buttons
				--if mod_button and minetest.get_item_group(node.name, "button") > 0 and minetest.get_item_group(node.name, "button_push_by_trident") == 1 then
					--local bdir = minetest.wallmounted_to_dir(node.param2)
					-- Check the button orientation
					--if vector.equals(vector.add(dpos, bdir), self._stuckin) then
						--mesecon.push_button(dpos, node)
					--end
				--end
			end
		elseif (def and def.liquidtype ~= "none") then
			-- Slow down trident in liquids
			local v = def.liquid_viscosity
			if not v then
				v = 0
			end
			--local old_v = self._viscosity
			self._viscosity = v
			local vpenalty = math.max(0.1, 0.98 - 0.1 * v)
			if math.abs(vel.x) > 0.001 then
				vel.x = vel.x * vpenalty
			end
			if math.abs(vel.z) > 0.001 then
				vel.z = vel.z * vpenalty
			end
			self.object:set_velocity(vel)
		end
	end

	if not self._stuck then
		local vel = self.object:get_velocity()
		local yaw = minetest.dir_to_yaw(vel)+YAW_OFFSET
		local pitch = dir_to_pitch(vel)
		self.object:set_rotation({ x = 0, y = yaw, z = pitch })
	end
	self._lastpos = pos
end

local function throw_trident(itemstack, placer, pointed_thing)
	local player_name = placer:get_player_name()
	if not minetest.is_creative_enabled(player_name) then
		itemstack:take_item()
		placer:set_wielded_item(itemstack)
	end
	spawn_trident(placer)
	return itemstack
end

minetest.register_tool("vlf_tridents:trident", {
	description = S("Trident"),
	_tt_help = S("Launches a trident when you rightclick and it is in your hand"),
	_doc_items_durability = TRIDENT_DURABILITY,
	inventory_image = "vlf_trident_inv.png",
	stack_max = 1,
	groups = {weapon=1,weapon_ranged=1,trident=1,enchantability=1},
	_vlf_uses = TRIDENT_DURABILITY,
	on_place = throw_trident,
	on_secondary_use =throw_trident,
})
