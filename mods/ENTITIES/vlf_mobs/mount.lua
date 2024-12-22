local mob_class = vlf_mobs.mob_class

local function force_detach(player)
	if not player or not player:get_pos() or not player:is_player() then return end

	local attached_to = player:get_attach()
	if not attached_to then
		return
	end

	local entity = attached_to:get_luaentity()
	if entity and entity.driver and entity.driver == player then
		entity.driver = nil
	end

	player:set_detach()
	vlf_player.players[player].attached = false
	player:set_eye_offset({x = 0, y = 0, z = 0}, {x = 0, y = 0, z = 0})
	vlf_player.player_set_animation(player, "stand" , 30)
	player:set_properties({visual_size = {x = 1, y = 1} })
end

minetest.register_on_shutdown(function()
	for player in vlf_util.connected_players() do
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

	player:set_look_horizontal(self:get_yaw () - rot_view)
end


function mob_class:detach(player, offset)
	force_detach(player)
	vlf_player.player_set_animation(player, "stand" , 30)
	if offset then
		player:set_pos(vector.add(player:get_pos(), offset))
	else
		player:add_velocity(vector.new(math.random(-6,6),math.random(5,8),math.random(-6,6))) --throw the rider off
	end
end

function mob_class:should_drive ()
	-- Remove invalid drivers.
	if self.driver and not self.driver:get_pos () then
		self.driver = nil
		return nil
	end
	if self.steer_class == "controls" then
		return self.driver ~= nil
	else
		if not self.driver then
			return nil
		end
		local item = self.driver:get_wielded_item ()
		local itemname = item and item:get_name ()
		return self.steer_item == nil or itemname == self.steer_item
	end
end

function mob_class:expel_underwater_drivers ()
	-- Detach the driver if submerged.
	if self.driver then
		local headin = minetest.registered_nodes[self.head_in]

		if headin.groups.water then
			self:detach (self.driver)
			return
		end
	end
end

function mob_class:apply_driver_input (speed, self_pos, moveresult, dtime)
	if self.steer_class == "follow_item" then
		self.acc_speed = speed
		-- Since the entirety of SPEED will be applied,
		-- drive_bonus should be set to a suitably small value
		-- to compensate, unless driving is intended to be
		-- faster than this mob's ordinary movement speed.
		self.acc_dir.z = 1

		if self:check_jump (self_pos, moveresult) then
			self._jump = true
		end
	elseif self.steer_class == "controls" then
		local controls = self.driver:get_player_control ()
		if controls.movement_x then
			self.acc_dir.z = controls.movement_y
			self.acc_dir.x = controls.movement_x * 0.5
		else
			local x = (controls.left and -1.0 or 0.0)
				+ (controls.right and 1.0 or 0.0)
			local z = (controls.up and 1.0 or 0.0)
				+ (controls.down and -1.0 or 0.0)
			self.acc_dir.z = z
			self.acc_dir.x = x * 0.5
		end
		self.acc_speed = speed

		if self.acc_dir.z < 0 then
			self.acc_dir.z = self.acc_dir.z * 0.5
		end

		if controls.jump then
			self._jump = true
		end
	end
end

local MAX_PHYSICS_DTIME = 0.075

function mob_class:drive (moving_anim, stand_anim, can_fly, dtime, moveresult)
	local dir = self.driver:get_look_horizontal ()
	-- Move forward but steer the pig in the direction the
	-- driver is facing.
	local pos = self.object:get_pos ()
	local elapsed, total
	local phys_dtime = math.min (dtime, MAX_PHYSICS_DTIME)

	self:set_yaw (dir)

	-- Cancel any ongoing activity.
	if self._active_activity then
		self:replace_activity (nil)
	end
	if not self:navigation_finished () then
		self:cancel_navigation ()
	end
	
	if self._drive_boost_elapsed then
		self._drive_boost_elapsed = self._drive_boost_elapsed + dtime
		if self._drive_boost_elapsed > self._drive_boost_total then
			self._drive_boost_elapsed = nil
		else
			elapsed = self._drive_boost_elapsed
			total = self._drive_boost_total
		end
	end

	local speed = self.movement_speed * self.drive_bonus
	if elapsed then
		local f = 1.0 + 1.5 * math.sin (elapsed / total * math.pi)
		speed = speed * f
	end

	self:apply_driver_input (speed, pos, moveresult, dtime)
	self:motion_step (phys_dtime, moveresult, pos)

	-- This function is called after motion_step to apply forces
	-- (e.g. velocity changes for jumping) that must not be
	-- attenuated by motion_step.
	if self.post_apply_driver_input then
		self:post_apply_driver_input (speed, pos, moveresult, dtime)
	end

	if self:get_velocity () > 0.05 then
		self:set_animation (moving_anim)
	else
		self:set_animation (stand_anim)
	end
end

function mob_class:hog_boost ()
	if self._drive_boost_elapsed ~= nil then
		return false
	end
	self._drive_boost_elapsed = 0
	self._drive_boost_total = (math.random (841) + 140) / 20.0
	return true
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
