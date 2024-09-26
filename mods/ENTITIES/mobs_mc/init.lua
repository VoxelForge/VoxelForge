--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes
mobs_mc = {}

local blacklisted_entities = {"mobs_mc:zombie", "mobs_mc:baby_zombie", --[["mobs_mc:drowned", ]]"mobs_mc:phantom", "mobs_mc:husk", "mobs_mc:baby_husk", "mobs_mc:skeleton_horse",
				"mobs_mc:skeleton_horse_trap", "mobs_mc:stray", "mobs_mc:wither", "mobs_mc:witherskeleton", "mobs_mc:zombie_horse", "mobs_mc:villager_zombie",
				"mobs_mc:zombified_piglin", "mobs_mc:zoglin"}
local speed_threshold = 5.0
local revert_delay = 6
local check_delay = 3

local pr = PseudoRandom(os.time()*5)

local offsets = {}
for x=-2, 2 do
	for z=-2, 2 do
		table.insert(offsets, {x=x, y=0, z=z})
	end
end

--[[ Periodically check and teleport mob to owner if not sitting (order ~= "sit") and
the owner is too far away. To be used with do_custom. Note: Optimized for mobs smaller than 1×1×1.
Larger mobs might have space problems after teleportation.

* dist: Minimum required distance from owner to teleport. Default: 12
* teleport_check_interval: Optional. Interval in seconds to check the mob teleportation. Default: 4 ]]

-- Assuming you have textures named "frame_0.png", "frame_1.png", ..., "frame_17.png"
local frames = {}
for i = 0, 17 do
    frames[i] = "mobs_mc_firefly_frame_" .. i .. ".png"
end

mobs_mc.firefly_animation = function()
	return function(self, dtime)
		self.timer = (self.timer or 0) + dtime
		local pos = self.object:get_pos()
		local light = minetest.get_node_light(pos)
		if self.timer > 0.1 and light <= 4 then  -- Change frame every 0.1 seconds
			self.timer = 0
			local frame = (self.frame or 0) + 1
			if frame > 17 then  -- Number of frames - 1
				frame = 0
			end
			self.object:set_properties({textures={frames[frame]}})
			self.frame = frame
			self:set_velocity(0.3)
		elseif self.timer > 0.1 and light >= 5 then
			self.object:set_properties({textures={"blank.png"}})
			self:set_velocity(0.0)
		else
			return
		end
	end
end

mobs_mc.armadillo_scare = function()
	return function(self, dtime)
		local pos = self.object:get_pos()
		local objs = minetest.get_objects_inside_radius(pos, self.view_range)
		local changed_to_tb = false

		-- Function to check if a table contains a value
		local function table_contains(tbl, value)
			for _, v in ipairs(tbl) do
				if v == value then
					return true
				end
			end
			return false
		end


		for _, obj in ipairs(objs) do
			local lua_entity = obj:get_luaentity()

			if (obj:is_player() or (lua_entity and table_contains(blacklisted_entities, lua_entity.name))) then
				local velocity = obj:get_velocity()
				local speed = vector.length(velocity)

				if obj:is_player() and speed > speed_threshold then
					local dir_to_armadillo = vector.direction(obj:get_pos(), pos)
					local dot_product = vector.dot(velocity, dir_to_armadillo)

					if dot_product > 0 then
						self.scared = true
						changed_to_tb = true
						self.walk_velocity = 0.0
						self.run_velocity = 0.0
						self.object:set_animation({x = 60, y = 72}, 10, 0, false)
						minetest.after(0.25, function()
							self.object:set_properties({textures = {"mobs_mc_armadillo-hiding.png"}})
						end)
						break
					end
				elseif lua_entity then
					self.scared = true
					changed_to_tb = true
					self.walk_velocity = 0.0
					self.run_velocity = 0.0
					break
				end
			end
		end

		if not changed_to_tb and self.scared then
			--self.object:set_animation({x = 76, y = 78}, 10, 0, false)
			minetest.after(check_delay, function()
				self.scared = false
				self.walk_velocity = 0.0
				self.run_velocity = 0.0
				self.object:set_animation({x = 96, y = 156}, 10, 0, false)
			end)
			minetest.after(revert_delay, function()
				if not self.scared then
					self.animation = {
						stand_start = 180, stand_end = 216, stand_speed = 10,
						walk_start = 180, walk_end = 216, speed_normal = 10
					}
					self.object:set_animation({x = 180, y = 216}, 10, 0, false)
					--self.state = "walk"
					minetest.after(1, function()
						self.object:set_properties({textures = {"mobs_mc_armadillo.png"}})
						self.walk_velocity = 0.14
						self.run_velocity = 0.14
						self.state = "walk"
						self.animation = {
							stand_start = 220, stand_end = 221, stand_speed = 0,
							walk_start = 0, walk_end = 35, speed_normal = 50
						}
					end)
				end
			end)
		end
		self.egg_timer = (self.egg_timer or math.random(300, 600)) - dtime
		if self.egg_timer > 0 then
			return
		end
		self.egg_timer = nil
		local pos = self.object:get_pos()
		minetest.add_item(pos, "vlf_mobitems:armadillo_scute")
	end
end

mobs_mc.armadillo_damage = function()
	return function(self, damage, reason)
		self.health = self.health - damage
		local changed_to_tb
		-- Blacklisted entity detected
		--self.object:set_properties({textures = {"mobs_mc_armadillo-hiding.png"}})
		self.scared = true
		changed_to_tb = true
		self:set_velocity(0.0)

		-- If no threats are detected, change back to t-c.png, then to t.png
		if not changed_to_tb and self.scared then
			minetest.after(check_delay, function()
				self.scared = false
				--self.object:set_properties({textures = {"mobs_mc_armadillo-peaking.png"}})
				self:set_velocity(0.0)
			end)
			minetest.after(revert_delay, function()
				-- Check if the armadillo is still not scared
				self.scared = false
				if not self.scared then
					--self.object:set_properties({textures = {"mobs_mc_armadillo.png"}})
					self:set_velocity(0.14)
				end
			end)
		end
	end
end

mobs_mc.make_owner_teleport_function = function(dist, teleport_check_interval)
	return function(self, dtime)
		-- No teleportation if no owner or if sitting
		if not self.owner or self.order == "sit" then
			return
		end
		if not teleport_check_interval then
			teleport_check_interval = 4
		end
		if not dist then
			dist = 12
		end
		if self._teleport_timer == nil then
			self._teleport_timer = teleport_check_interval
			return
		end
		self._teleport_timer = self._teleport_timer - dtime
		if self._teleport_timer <= 0 then
			self._teleport_timer = teleport_check_interval
			local mob_pos = self.object:get_pos()
			local owner = minetest.get_player_by_name(self.owner)
			if not owner then
				-- No owner found, no teleportation
				return
			end
			local owner_pos = owner:get_pos()
			local dist_from_owner = vector.distance(owner_pos, mob_pos)
			if dist_from_owner > dist then
				-- Check for nodes below air in a 5×1×5 area around the owner position
				local check_offsets = table.copy(offsets)
				-- Attempt to place mob near player. Must be placed on walkable node below a non-walkable one. Place inside that air node.
				while #check_offsets > 0 do
					local r = pr:next(1, #check_offsets)
					local telepos = vector.add(owner_pos, check_offsets[r])
					local telepos_below = {x=telepos.x, y=telepos.y-1, z=telepos.z}
					table.remove(check_offsets, r)
					-- Long story short, spawn on a platform
					local trynode = minetest.registered_nodes[minetest.get_node(telepos).name]
					local trybelownode = minetest.registered_nodes[minetest.get_node(telepos_below).name]
					if trynode and not trynode.walkable and
							trybelownode and trybelownode.walkable then
						-- Correct position found! Let's teleport.
						self.object:set_pos(telepos)
						return
					end
				end
			end
		end
	end
end

mobs_mc.shears_wear = 276
mobs_mc.water_level = tonumber(minetest.settings:get("water_level")) or 0

-- Auto load all lua files
local path = minetest.get_modpath("mobs_mc")
for _, file in pairs(minetest.get_dir_list(path, false)) do
	if file:sub(-4) == ".lua" and file ~= "init.lua" then
		dofile(path .. "/" ..file)
	end
end
