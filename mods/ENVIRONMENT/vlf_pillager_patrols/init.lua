--[[local function check_spawn_pos(pos)
	return minetest.get_natural_light(pos) < 8  -- Check for light level between 0 and 7
end

local function spawn_pillagers(self)
	local nn = minetest.find_nodes_in_area_under_air(vector.offset(self.pos, -8, -8, -8), vector.offset(self.pos, 16, 16, 16), {"group:solid"})
	table.shuffle(nn)
	local count = math.random(2, 5)  -- Randomly select between 2 to 5 mobs
	for i = 1, count do
		local p = vector.offset(nn[i % #nn], 0, 1, 0)
		if check_spawn_pos(p) then
			local m = vlf_mobs.spawn(p, "mobs_mc:pillager")  -- Spawn pillagers instead of zombies
			if m then
				local l = m:get_luaentity()
				m:get_luaentity():gopath(self.pos)
				table.insert(self.mobs, m)
				self.health_max = self.health_max + l.health
			end
		end
	end
end

vlf_events.register_event("pillager_siege", {
	readable_name = "Pillager Siege",
	max_stage = 1,
	health = 1,
	health_max = 1,
	exclusive_to_area = 128,
	enable_bossbar = false,
	cond_start = function(self)
		local r = {}
		local t = minetest.get_timeofday()
		local pr = PseudoRandom(minetest.get_day_count())
		local rnd = pr:next(1, 10)

		-- Check if the world is 5 in-game days old
		if minetest.get_day_count() >= 5 and t < 0.04 and rnd == 1 then
			for _, p in pairs(minetest.get_connected_players()) do
				local village = vlf_raids.find_village(p:get_pos())
				if village then
					table.insert(r, { player = p:get_player_name(), pos = village })
				end
			end
		end
		if #r > 0 then return r end
	end,
	on_start = function(self)
		self.mobs = {}
		self.health_max = 1
		self.health = 0
		self.check_interval = 600 + math.random(0, 60)  -- Check every 10-11 minutes (600 to 660 seconds)
		self.next_check = minetest.get_gametime() + self.check_interval  -- Schedule the next check
	end,
	cond_progress = function(self)
		local m = {}
		local h = 0
		for k, o in pairs(self.mobs) do
			if o and o:get_pos() then
				local l = o:get_luaentity()
				h = h + l.health
				table.insert(m, o)
			end
		end
		self.mobs = m
		self.health = h
		self.percent = math.max(0, (self.health / self.health_max) * 100)

		-- Check if mobs are still present
		if #m < 1 then
			return true
		end
	end,
	on_stage_begin = spawn_pillagers,
	cond_complete = function(self)
		local m = {}
		for k, o in pairs(self.mobs) do
			if o and o:get_pos() then
				table.insert(m, o)
			end
		end
		return self.stage >= self.max_stage and #m < 1
	end,
	on_complete = function(self)
	end,
	on_check = function(self)
		-- Check if enough time has passed for the next spawn check
		if minetest.get_gametime() >= self.next_check then
			local chance = math.random(1, 100)
			if chance <= 20 then  -- 20% chance to spawn mobs
				self:begin_stage()
			end
			self.next_check = minetest.get_gametime() + self.check_interval  -- Schedule the next check
		end
	end,
})
]]

local function check_spawn_pos(pos)
	return minetest.get_natural_light(pos) < 8  -- Check for light level between 0 and 7
end

local function spawn_pillagers(self)
	local nn = minetest.find_nodes_in_area_under_air(vector.offset(self.pos, -16, -16, -16), vector.offset(self.pos, 16, 16, 16), {"group:solid"})
	table.shuffle(nn)
	local count = math.random(2, 5)  -- Randomly select between 2 to 5 mobs
	for i = 1, count do
		local p = vector.offset(nn[i % #nn], 0, 1, 0)
		if check_spawn_pos(p) then
			local m = vlf_mobs.spawn(p, "mobs_mc:pillager")  -- Spawn pillagers instead of zombies
			if m then
				local l = m:get_luaentity()
				m:get_luaentity():gopath(self.pos)
				table.insert(self.mobs, m)
				self.health_max = self.health_max + l.health
			end
		end
	end
end

vlf_events.register_event("pillager_siege", {
	readable_name = "Pillager Siege",
	max_stage = 1,
	health = 1,
	health_max = 1,
	exclusive_to_area = 128,
	enable_bossbar = false,
	cond_start = function(self)
		local r = {}
		local pr = PseudoRandom(minetest.get_day_count())
		local rnd = pr:next(1, 10)

		-- Check if the world is 5 in-game days old
		if minetest.get_day_count() >= 5 and rnd == 1 then
			for _, p in pairs(minetest.get_connected_players()) do
				local village = vlf_raids.find_village(p:get_pos())
				if village then
					local village_pos = village
					if vector.distance(p:get_pos(), village_pos) > 16 then  -- Check if the player is more than 16 blocks away from the village
						table.insert(r, { player = p:get_player_name(), pos = village })
					end
				end
			end
		end
		if #r > 0 then return r end
	end,
	on_start = function(self)
		self.mobs = {}
		self.health_max = 1
		self.health = 0
		self.check_interval = 600 + math.random(0, 60)  -- Check every 10-11 minutes (600 to 660 seconds)
		self.next_check = minetest.get_gametime() + self.check_interval  -- Schedule the next check
	end,
	cond_progress = function(self)
		local m = {}
		local h = 0
		for k, o in pairs(self.mobs) do
			if o and o:get_pos() then
				local l = o:get_luaentity()
				h = h + l.health
				table.insert(m, o)
			end
		end
		self.mobs = m
		self.health = h
		self.percent = math.max(0, (self.health / self.health_max) * 100)

		-- Check if mobs are still present
		if #m < 1 then
			return true
		end
	end,
	on_stage_begin = spawn_pillagers,
	cond_complete = function(self)
		local m = {}
		for k, o in pairs(self.mobs) do
			if o and o:get_pos() then
				table.insert(m, o)
			end
		end
		return self.stage >= self.max_stage and #m < 1
	end,
	on_complete = function(self)
		--minetest.log("SIEGE complete")
		awards.unlock(self.player, "vlf:hero_of_the_village")
	end,
	on_check = function(self)
		-- Check if enough time has passed for the next spawn check
		if minetest.get_gametime() >= self.next_check then
			local chance = math.random(1, 100)
			if chance <= 20 then  -- 20% chance to spawn mobs
				self:begin_stage()
			end
			self.next_check = minetest.get_gametime() + self.check_interval  -- Schedule the next check
		end
	end,
})

