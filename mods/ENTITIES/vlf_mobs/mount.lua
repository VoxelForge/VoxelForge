local mob_class = vlf_mobs.mob_class

local node_ok = function(pos, fallback)
	fallback = fallback or vlf_mobs.fallback_node
	local node = minetest.get_node_or_nil(pos)
	if node and minetest.registered_nodes[node.name] then
		return node
	end
	return {name = fallback}
end

local function node_is(pos)
	local node = node_ok(pos)
	if node.name == "air" then
		return "air"
	end
	if minetest.get_item_group(node.name, "lava") ~= 0 then
		return "lava"
	end
	if minetest.get_item_group(node.name, "liquid") ~= 0 then
		return "liquid"
	end
	if minetest.registered_nodes[node.name].walkable == true then
		return "walkable"
	end
	return "other"
end


local function get_sign(i)
	i = i or 0
	if i == 0 then
		return 0
	else
		return i / math.abs(i)
	end
end


local function get_velocity(v, yaw, y)
	local x = -math.sin(yaw) * v
	local z =  math.cos(yaw) * v
	return {x = x, y = y, z = z}
end


local function get_v(v)
	return math.sqrt(v.x * v.x + v.z * v.z)
end


local function force_detach(player)
	local attached_to = player:get_attach()
	if not attached_to then
		return
	end

	local entity = attached_to:get_luaentity()
	if entity.driver and entity.driver == player then
		entity.driver = nil
	end

	player:set_detach()
	vlf_player.players[player].attached = false
	player:set_eye_offset({x = 0, y = 0, z = 0}, {x = 0, y = 0, z = 0})
	vlf_player.player_set_animation(player, "stand" , 30)
	player:set_properties({visual_size = {x = 1, y = 1} })

end

minetest.register_on_shutdown(function()
	for _, player in pairs(minetest.get_connected_players()) do
		force_detach(player)
	end
end)
minetest.register_on_leaveplayer(force_detach)
minetest.register_on_dieplayer(force_detach)

function mob_class:attach(player)
	local attach_at, eye_offset
	self.player_rotation = self.player_rotation or {x = 0, y = 0, z = 0}
	self.driver_attach_at = self.driver_attach_at or {x = 0, y = 0, z = 0}
	self.driver_eye_offset = self.driver_eye_offset or {x = 0, y = 0, z = 0}
	self.driver_scale = self.driver_scale or {x = 1, y = 1}
	self._last_jump = 0

	local rot_view = 0

	if self.player_rotation.y == 90 then
		rot_view = math.pi/2
	end

	attach_at = self.driver_attach_at
	eye_offset = self.driver_eye_offset
	self.driver = player

	force_detach(player)

	player:set_attach(self.object, "", attach_at, self.player_rotation)
	vlf_player.players[player].attached = true
	player:set_eye_offset(eye_offset, {x = 0, y = 0, z = 0})

	player:set_properties({
		visual_size = {
			x = self.driver_scale.x,
			y = self.driver_scale.y
		}
	})

	minetest.after(0.2, function(name)
		local player = minetest.get_player_by_name(name)
		if player then
			vlf_player.player_set_animation(player, "sit_mount" , 30)
		end
	end, player:get_player_name())

	player:set_look_horizontal(self.object:get_yaw() - rot_view)
end


function vlf_mobs.detach(player, offset)
	force_detach(player)
	vlf_player.player_set_animation(player, "stand" , 30)
	player:add_velocity(vector.new(math.random(-6,6),math.random(5,8),math.random(-6,6))) --throw the rider off
end


function mob_class:drive(moving_anim, stand_anim, can_fly, dtime)
	local rot_view = 0
	if self.player_rotation.y == 90 then
		rot_view = math.pi/2
	end

	local acce_y = 0
	local velo = self.object:get_velocity()

	self.v = get_v(velo) * get_sign(self.v)

	if self.driver then
		local ctrl = self.driver:get_player_control()
		if ctrl.up then

			if ctrl.left then
				rot_view = rot_view - 70
			elseif ctrl.right then
				rot_view = rot_view + 70
			end

			self.v = self.v + self.accel / 10 * self.run_velocity / 2.6

		elseif ctrl.down then

			if self.max_speed_reverse == 0 and self.v == 0 then
				return
			end

			if ctrl.left then
				rot_view = rot_view + 70
			elseif ctrl.right then
				rot_view = rot_view - 70
			end

			self.v = self.v - self.accel / 10 - (self.max_speed_reverse * 0.5)

		elseif ctrl.left then

			rot_view = rot_view - 80
			self.v = self.v - self.accel / 10 - (self.max_speed_reverse * 0.5)

		elseif ctrl.right then

			rot_view = rot_view + 80
			self.v = self.v - self.accel / 10 - (self.max_speed_reverse * 0.5)

		else
			self.v = 0
			self:set_velocity(0)
			self:set_state("stand")
			self:set_animation("stand")
		end

		self.object:set_yaw(self.driver:get_look_horizontal() - self.rotate)

		if can_fly then

			if ctrl.jump then
				velo.y = velo.y + 1
				if velo.y > self.accel then velo.y = self.accel end
			elseif velo.y > 0 then
				velo.y = velo.y - 0.1
				if velo.y < 0 then velo.y = 0 end
			end
			if ctrl.sneak then
				velo.y = velo.y - 1
				if velo.y < -self.accel then velo.y = -self.accel end
			elseif velo.y < 0 then
				velo.y = velo.y + 0.1
				if velo.y > 0 then velo.y = 0 end
			end
		else
			if ctrl.jump then
				if velo.y == 0 then
					if self._last_jump == 0 then
						velo.y = velo.y + self.jump_height * 7
						acce_y = acce_y + (acce_y * 3) + 1
						self._last_jump = velo.y
						-- Throttle jumping
						minetest.after(0.5, function(self, velo)
							if self and self._last_jump == velo.y then
								self._last_jump = 0
							end
						end, self, velo)
					end
				end
			end
		end
	end

	-- if not moving then set animation and return
	if self.v == 0 and velo.x == 0 and velo.y == 0 and velo.z == 0 then
		if stand_anim then
			self:set_animation(stand_anim)
		end
		return
	end

	if moving_anim then
		self:set_animation(moving_anim)
	end

	local s = get_sign(self.v)
	self.v = self.v - 0.02 * s
	if s ~= get_sign(self.v) then

		self.object:set_velocity({x = 0, y = 0, z = 0})
		self.v = 0
		return
	end

	local max_spd = self.max_speed_reverse
	if get_sign(self.v) >= 0 then
		max_spd = self.max_speed_forward
	end
	if math.abs(self.v) > max_spd then
		self.v = self.v - get_sign(self.v)
	end

	local p = self.object:get_pos()
	local new_velo
	local new_acce = {x = 0, y = gravity, z = 0}
	p.y = p.y - 0.5
	local ni = node_is(p)
	local v = self.v
	
	-- slowed when submerged with water
	if minetest.registered_nodes[mcl_mobs.node_ok(vector.offset(p,0,1,0)).name].groups.water then
		v = v * 0.75
	end

	if ni == "air" then
		if can_fly == true then
			new_acce.y = 0
		end
	elseif ni == "liquid" or ni == "lava" then
		if ni == "lava" and self.lava_damage ~= 0 then
			self.lava_counter = (self.lava_counter or 0) + dtime
			if self.lava_counter > 1 then
				minetest.sound_play("default_punch", {
					object = self.object,
					max_hear_distance = 5
				}, true)
				self.object:punch(self.object, 1.0, {
					full_punch_interval = 1.0,
					damage_groups = {fleshy = self.lava_damage}
				}, nil)

				self.lava_counter = 0
			end
		end

		if self.terrain_type == 2
		or self.terrain_type == 3 then
			new_acce.y = 0
			p.y = p.y + 1
			if node_is(p) == "liquid" then
				if velo.y >= 5 then
					velo.y = 5
				elseif velo.y < 0 then
					new_acce.y = 20
				else
					new_acce.y = 5
				end
			else
				if math.abs(velo.y) < 1 then
					local pos = self.object:get_pos()
					pos.y = math.floor(pos.y) + 0.5
					self.object:set_pos(pos)
					velo.y = 0
				end
			end
		else
			v = v * 0.25
		end
	end

	new_velo = get_velocity(v, self.object:get_yaw() - rot_view, velo.y)
	new_acce.y = new_acce.y + acce_y

	self.object:set_velocity(new_velo)
	self.object:set_acceleration(new_acce)
	self.v2 = v
end

function mob_class:on_detach_child(child)
	if self.detach_child then
		if self.detach_child(self, child) then
			return
		end
	end
	if self.driver == child then
		self.driver = nil
	end
end
