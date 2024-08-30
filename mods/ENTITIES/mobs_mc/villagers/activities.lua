local modname = minetest.get_current_modname()

local allow_nav_hacks = minetest.settings:get_bool("vlf_mob_allow_nav_hacks",false)
local work_dist = 4
local gather_distance = 10

local VIL_DIST = 48
local RESETTLE_DISTANCE = VIL_DIST * 2 -- If a mob is transported this far from home, it gives up bed and job and resettles

local S = minetest.get_translator(modname)

local badges = {
	"mobs_mc_stone.png",
	"mobs_mc_iron.png",
	"mobs_mc_gold.png",
	"mobs_mc_emerald.png",
	"mobs_mc_diamond.png",
}

local WORK = "work"
local SLEEP = "sleep"
local HOME = "home"
local GATHERING = "gathering"
local PATHFINDING = "gowp"
local RUNAWAY = "runaway"

function mobs_mc.villager_mob:stand_still()
	self.walk_chance = 0
	self.jump = false
	self:set_state("stand")
end

function mobs_mc.villager_mob:get_badge_textures()
	local t = mobs_mc.professions[self._profession].texture
	if self._profession == "unemployed"	then
		t = mobs_mc.professions[self._profession].textures -- ideally both scenarios should be textures with a list containing 1 or multiple
	end

	if self._profession == "unemployed" or self._profession == "nitwit" then return t end
	local tier = self._max_trade_tier or 1
	return {
		t .. "^" .. badges[tier]
	}
end

function mobs_mc.villager_mob:should_sleep()
	local starts = 18000
	local ends = 6000

	if self._profession == "nitwit" then
		starts = 20000
		ends = 8000
	end

	local tod = minetest.get_timeofday()
	tod = (tod * 24000) % 24000
	return tod >= starts or tod < ends
end

function mobs_mc.villager_mob:should_go_home()
	local tod = (minetest.get_timeofday() * 24000) % 24000

	-- Hide for half an hour
	if self._last_alarm and self._last_alarm > (tod - 500) then
		return true
	end

	local weather = vlf_weather.get_weather()

	if weather == "thunder" or weather == "rain" or weather == "snow" then
		return true
	end

	local starts = 17000
	local ends = 18000

	if self._profession == "nitwit" then
		starts = 19000
		ends = 20000
	end

	return tod >= starts and tod < ends
end

function mobs_mc.villager_mob:get_activity(tod)
	if not tod then
		tod = minetest.get_timeofday()
	end
	tod = (tod * 24000) % 24000

	local work_start = 6000
	local lunch_start = 14000
	local lunch_end = 16000
	local work_end = 17000

	local activity
	if self.state == RUNAWAY then
		activity = RUNAWAY
	elseif self:should_sleep() then
		activity = SLEEP
	elseif self:should_go_home() then
		activity = HOME
	elseif self._profession == "nitwit" then
		activity = "chill"
	elseif self.child then
		-- TODO should be play
		activity = "chill"
	elseif tod >= lunch_start and tod < lunch_end then
		activity = GATHERING
	elseif tod >= work_start and tod < work_end then
		activity = WORK
	else
		activity = "chill"
	end

	return activity
end

function mobs_mc.villager_mob:find_closest_bed()
	-- This is only triggered when villager does not have a bed (see do_activity)
	local p = self.object:get_pos()
	if self._bed and vector.distance(p, self._bed) < VIL_DIST * 2 then return self._bed end

	local unclaimed_beds = {}
	local nn2 = minetest.find_nodes_in_area(
		vector.offset(p, -VIL_DIST, -VIL_DIST/2, -VIL_DIST),
		vector.offset(p, VIL_DIST, VIL_DIST/2, VIL_DIST),
		{ "group:bed" }
	)
	if nn2 then
		for _, b in pairs(nn2) do
			local bed_node = minetest.get_node(b)
			local bed_name = bed_node.name
			local is_bed_bottom = string.find(bed_name,"_bottom")

			local bed_meta = minetest.get_meta(b)
			local owned_by = bed_meta:get_string("villager")

			if (owned_by and owned_by == self._id) then
				bed_meta:set_string("villager", "")
				bed_meta:set_string("infotext", "")
				owned_by = nil
			end

			if is_bed_bottom then
				local bed_top_meta = minetest.get_meta(vlf_beds.get_bed_top (b))
				local owned_by_player = bed_top_meta:get_string("player")

				if owned_by == "" and (not owned_by_player or owned_by_player == "") then
					table.insert(unclaimed_beds, b)
				end
			end
		end
	end

	local distance_to_closest_block
	local closest_block

	if unclaimed_beds then
		for _, b in pairs(unclaimed_beds) do
			local distance_to_block = vector.distance(p, b)
			if not distance_to_closest_block or distance_to_closest_block > distance_to_block then
				closest_block = b
				distance_to_closest_block = distance_to_block
			end
		end
	end

	return closest_block
end

function mobs_mc.villager_mob:find_closest_unclaimed_block(p, requested_block_types)
	local nn = minetest.find_nodes_in_area(
		vector.offset(p, -VIL_DIST, -VIL_DIST/2, -VIL_DIST),
		vector.offset(p, VIL_DIST, VIL_DIST/2, VIL_DIST),
		requested_block_types
	)

	local distance_to_closest_block
	local closest_block

	for _, n in pairs(nn) do
		local m = minetest.get_meta(n)
		if m:get_string("villager") == "" or m:get_string("villager") == self._id then
			local distance_to_block = vector.distance(p, n)
			if not distance_to_closest_block or distance_to_closest_block > distance_to_block then
				closest_block = n
				distance_to_closest_block = distance_to_block
			end
		end
	end
	return closest_block
end

function mobs_mc.villager_mob:remove_bed()
	local b = self._bed
	if not b then
		return
	end

	local bed_meta = minetest.get_meta(b)
	local owner = bed_meta:get_string("villager")

	if owner and owner == self._id then
		bed_meta:set_string("villager", "")
		bed_meta:set_string("infotext", "")
	end

	self._bed = nil

end

function mobs_mc.villager_mob:check_bed()
	local b = self._bed
	if not b then
		return false
	end

	local n = minetest.get_node(b)

	local is_bed_bottom = string.find(n.name,"_bottom")
	if n and not is_bed_bottom then
		self:remove_bed()
		return false
	end

	local m = minetest.get_meta(b)
	local owner = m:get_string("villager")

	if not owner or owner == "" or owner ~= self._id then
		self:remove_bed()
		return false
	end

	local infotext = m:get_string("infotext")

	if self.nametag and self.nametag ~= "" and not string.match(infotext, self.nametag) then
		m:set_string("infotext", S("@1 sleeps here", self.nametag))
	end

	return true
end

function mobs_mc.villager_mob:go_home(sleep)
	local b = self._bed
	if not b then
		return
	end

	local bed_node = minetest.get_node(b)
	if not bed_node then
		self._bed = nil
		return
	end

	if vector.distance(self.object:get_pos(),b) < 2 then
		if self:should_sleep() then
			self.order = SLEEP
			self:look_at(b)
			-- TODO instead of look_at use set_rotation to lay on bed???
		end
	else
		if sleep and self.order == SLEEP then
			self.order = nil
			return
		end

		self:gopath(b,function(self, _)
			local b = self._bed

			if not b then
				return false
			end

			if not minetest.get_node(b) then
				return false
			end

			if vector.distance(self.object:get_pos(),b) < 2 then
				return true
			end
		end, true)
	end
end

function mobs_mc.villager_mob:get_bell()
	if not self._bell then
		local p = self.object:get_pos()
		local a_bell = minetest.find_node_near(p, VIL_DIST, { "vlf_bells:bell" }, true)

		if a_bell then
			self._bell = vector.offset(a_bell, 0, -2, 0)
		end
	end

	return self._bell
end

function mobs_mc.villager_mob:take_bed()
	if not self then return end

	local p = self.object:get_pos()

	local closest_block = self:find_closest_bed()

	if closest_block then
		local distance_to_block = vector.distance(p, closest_block)
		if distance_to_block < 2 then
			local m = minetest.get_meta(closest_block)
			local owner = m:get_string("villager")
			if owner and owner ~= "" and owner ~= self._id then
				if self.order == "stand" then
					self.order = nil
				end
				return
			end

			if self.order ~= SLEEP then
				self.order = SLEEP
				m:set_string("villager", self._id)

				if self.nametag  and self.nametag ~= "" then
					m:set_string("infotext", S("@1 sleeps here", self.nametag))
				else
					m:set_string("infotext", S("A villager sleeps here"))
				end

				self._bed = closest_block
				local bell_pos = m:get_string("bell_pos")
				if bell_pos ~= "" then
					self._bell = minetest.string_to_pos(bell_pos)
				else
					local bell = self:get_bell()
					if bell then
						m:set_string("bell_pos", minetest.pos_to_string(bell))
					end
				end
			end
			return true
		else
			self:gopath(closest_block,function() end)
		end
	else
		if self.order == "stand" then
			self.order = nil
		end
	end
end

local function has_golem(pos)
	for _,o in pairs(minetest.get_objects_inside_radius(pos,16)) do
		local l = o:get_luaentity()
		if l and l.name == "mobs_mc:iron_golem" then return true end
	end
end

function mobs_mc.villager_mob:monsters_near()
	for _,o in pairs(minetest.get_objects_inside_radius(self.object:get_pos(),10)) do
		local l = o:get_luaentity()
		if l and l.type =="monster" then return true end
	end
end

function mobs_mc.villager_mob:has_summon_participants()
	local r = 0
	for _,o in pairs(minetest.get_objects_inside_radius(self.object:get_pos(),10)) do
		local l = o:get_luaentity()
		--TODO check for gossiping
		if l and l.name == "mobs_mc:villager" then r = r + 1 end
	end
	return r > 2
end

function mobs_mc.villager_mob:summon_golem()
	vector.offset(self.object:get_pos(),-10,-10,-10)
	local nn = minetest.find_nodes_in_area_under_air(vector.offset(self.object:get_pos(),-8,-6,-8),vector.offset(self.object:get_pos(),8,6,8),{"group:solid","group:water"})
	table.shuffle(nn)
	for _,n in pairs(nn) do
		local up = minetest.find_nodes_in_area(vector.offset(n,0,1,0),vector.offset(n,0,3,0),{"air"})
		local down = minetest.find_nodes_in_area(n,vector.offset(n,0,-1,0),{"group:water"})
		local floor_is_water = minetest.get_item_group(minetest.get_node(n).name, "water") ~= 0
		if floor_is_water and down and #down == 1
		or not floor_is_water and up and #up >= 3 then
			local obj
			if floor_is_water then
				obj = minetest.add_entity(vector.offset(n,0,-0.5,0),"mobs_mc:iron_golem")
			else
				obj = minetest.add_entity(vector.offset(n,0,0.5,0),"mobs_mc:iron_golem")
			end

			local ent = obj:get_luaentity()
			if ent then
				local bell = self:get_bell()

				if bell then
					ent._home = bell
				else
					ent._home = n
				end

				return obj
			end
		end
	end
end

function mobs_mc.villager_mob:check_summon()
	-- TODO has selpt in last 20?
	if self:check_timer("summon_golem", 37) then
		local pos = self.object:get_pos()
		if has_golem(pos) then return end
		if not self:monsters_near() then return end
		if not self:has_summon_participants() then return end
		self:summon_golem()
	end
end

function mobs_mc.villager_mob:has_traded()
	return self._trade_xp and self._trade_xp > 0
end

function mobs_mc.villager_mob:unlock_trades()
	if not self._trades then
		return false
	end
	local has_unlocked = false

	local trades = minetest.deserialize(self._trades)
	if trades and type(trades) == "table" then
		for _, trade in pairs(trades) do
			local trade_tier_too_high = trade.tier > self._max_trade_tier
			if not trade_tier_too_high then
				if trade["locked"] == true then
					trade.locked = false
					trade.trade_counter = 0
					has_unlocked = true
				end
			end
		end
		if has_unlocked then
			self._trades = minetest.serialize(trades)
		end
	end
end

----- JOBSITE LOGIC
local function get_profession_by_jobsite(js)
	for k,v in pairs(mobs_mc.professions) do
		if v.jobsite == js then
			return k
		-- Catch Nitwit doesn't have a jobsite
		elseif v.jobsite and v.jobsite:find("^group:") then
			local group = v.jobsite:gsub("^group:", "")
			if minetest.get_item_group(js, group) > 0 then
				return k
			end
		end
	end
end

function mobs_mc.villager_mob:employ(jobsite_pos)
	local n = minetest.get_node(jobsite_pos)
	local m = minetest.get_meta(jobsite_pos)
	local p = get_profession_by_jobsite(n.name)
	if p and m:get_string("villager") == "" or m:get_string("villager") == self._id then
		m:set_string("villager",self._id)
		if self.nametag and self.nametag ~= "" then
			m:set_string("infotext", S("@1 works here", self.nametag))
		else
			m:set_string("infotext", S("A villager works here"))
		end

		self._jobsite = jobsite_pos

		if not self:has_traded() then
			self._profession=p
			self:set_textures()
		end
		return true
	end
end

function mobs_mc.villager_mob:look_for_job(requested_jobsites)
	local p = self.object:get_pos()

	local closest_block = self:find_closest_unclaimed_block(p, requested_jobsites)

	if closest_block then
		local n = minetest.find_nodes_in_area_under_air(
			vector.offset(closest_block, -1, -2, -1),
			vector.offset(closest_block, 1, 1, 1),
			{ "group:solid" }
		)

		for _, job_pos in pairs(n) do
			local gp = self:gopath(job_pos, function(self)
				self:get_a_job()
				if self and self.state == "stand" then
					self.order = WORK
				end
			end)

			if gp then
				return closest_block
			end
		end
	end

	return nil
end

function mobs_mc.villager_mob:get_a_job()
	if self.order == WORK then
		self.order = nil
	end

	local requested_jobsites = mobs_mc.jobsites
	if self:has_traded() then
		requested_jobsites = {mobs_mc.professions[self._profession].jobsite}
	end

	local p = self.object:get_pos()
	local n = minetest.find_node_near(p, work_dist, requested_jobsites)
	if n and self:employ(n) then return true end

	if self.state ~= PATHFINDING then
		local job_site = self:look_for_job(requested_jobsites)
		if not job_site then
			self:go_to_town_bell()
		end
	end
end

function mobs_mc.villager_mob:retrieve_my_jobsite()
	if not self or not self._jobsite then
		return
	end
	local n = vlf_vars.get_node(self._jobsite)
	local m = minetest.get_meta(self._jobsite)
	-- If job block isn't loaded then assume it's still valid
	if n.name == "ignore" or m:get_string("villager") == self._id then
		return n
	end
end

function mobs_mc.villager_mob:remove_job()
	if self._jobsite then
		local m = minetest.get_meta(self._jobsite)
		local owner = m:get_string("villager")
		if owner and owner == self._id then
			m:set_string("villager", "")
			m:set_string("infotext", "")
		end
	end

	self._jobsite = nil
	if not self:has_traded() then
		self._profession = "unemployed"
		self._trades = nil
		self:set_textures()
	end
end

function mobs_mc.villager_mob:resettle_check()

	local home

	if self._bed then
		home = self._bed
	elseif self._jobsite then
		home = self._jobsite
	elseif self._bell then
		home = self._bell
	end

	if home then
		local resettle = vector.distance(self.object:get_pos(), home) > RESETTLE_DISTANCE
		if resettle then
			self:remove_job()
			self:remove_bed()
			self._bell = nil
			return
		end
	end
end

function mobs_mc.villager_mob:validate_jobsite()
	if self._profession == "unemployed" then return false end

	local job_block = self:retrieve_my_jobsite()
	if not job_block then
		if self.order == WORK then
			self.order = nil
		end

		self:remove_job()
		return false
	end

	local m = minetest.get_meta(self._jobsite)
	local infotext = m:get_string("infotext")

	if self.nametag and self.nametag ~= "" and not string.match(infotext, self.nametag) then
		m:set_string("infotext", S("@1 works here", self.nametag))
	end

	return true
end

function mobs_mc.villager_mob:do_work()
	if self.child then
		return
	end

	if not self:check_timer("do_work", 15) then return end

	if self:validate_jobsite() then
		self.jump = false

		local jobsite = self._jobsite
		local distance_to_jobsite = vector.distance(self.object:get_pos(), jobsite)

		if distance_to_jobsite < work_dist then
			if self.state ~= PATHFINDING and self.order ~= WORK then
				self.order = WORK
				self:unlock_trades()
			end
		else
			if self.order == WORK then
				return
			end

			local n = minetest.find_nodes_in_area_under_air(
				vector.offset(jobsite, -1, -2, -1),
				vector.offset(jobsite, 1, 1, 1),
				{ "group:solid" }
			)

			for _, job_pos in pairs(n) do
				local gp = self:gopath(job_pos, function(self, _)
					if not self then
						return false
					end
					if not self._jobsite then
						return false
					end
					if vector.distance(self.object:get_pos(), self._jobsite) < work_dist then
						return true
					end
				end, true)

				if gp then
					return
				end
			end
		end
	else
		self:get_a_job()
	end
end

function mobs_mc.villager_mob:teleport_to_town_bell()
	local bell = self:get_bell()

	if bell then
		self.object:set_pos(bell)
	end
end

function mobs_mc.villager_mob:go_to_town_bell()
	local bell = self:get_bell()

	if bell then
		local dist = vector.distance(self.object:get_pos(), bell)
		if dist > gather_distance then
			local gp = self:gopath(bell, function(self)
				if self then
					self.order = GATHERING
				end
			end, true)

			if gp then
				return bell
			end
		end
	end

	return nil
end

function mobs_mc.villager_mob:sleep_over()
	if self:check_timer("sleep_over", self._sleep_over_interval) then
		local p = self.object:get_pos()
		local distance_to_closest_bed = 1000
		local closest_bed
		local nn2 = minetest.find_nodes_in_area(
			vector.offset(p, -VIL_DIST, -VIL_DIST / 2, -VIL_DIST),
			vector.offset(p, VIL_DIST, VIL_DIST / 2, VIL_DIST),
			{ "group:bed" }
		)

		if nn2 then
			for _, b in pairs(nn2) do
				local distance_to_bed = vector.distance(p, b)
				if distance_to_closest_bed > distance_to_bed then
					closest_bed = b
					distance_to_closest_bed = distance_to_bed
				end
			end
		else
			self._sleep_over_interval = math.min(self._sleep_over_interval + 5, 300)
			--this function is fairly expensive, increase interval by 5 if nothing is found (cap at 5 minutes)
		end

		if closest_bed and distance_to_closest_bed >= 3 then
			self:gopath(closest_bed)
		end
	end
end

function mobs_mc.villager_mob:do_activity(dtime)
	-- Don't do this often, but do it first so it preempts everything else.
	self._resettle_timer = (self._resettle_timer or (math.random() * 60)) - dtime
	if self._resettle_timer < 0 then
		self._resettle_timer = 60
		self:resettle_check()
	end

	if allow_nav_hacks then
		-- When a night is skipped telport villagers to their bed or bell
		if self.last_skip == nil then
			self.last_skip = 0
		end
		local last_skip = vlf_beds.last_skip()
		if self.last_skip < last_skip then
			self.last_skip = last_skip
			if self:check_bed() then
				self.object:set_pos(self._bed)
			else
				self:teleport_to_town_bell()
			end

			self.waypoints = nil
			self._target = nil
			self.current_target = nil
			self.attack = nil
			self.following = nil
			self.state = "stand"
			self.order = "stand"
			self._pf_last_failed = os.time()
			self.object:set_velocity(vector.zero())
			self.object:set_acceleration(vector.zero())
			self:set_animation("stand")
		end
	end

	if self.following or self.state == PATHFINDING then
		return
	end

	if self:check_timer("bed_search", self._bed_search_interval) then
		if not self:check_bed() then
			if not self:take_bed() then
				self._bed_search_interval = math.min(self._bed_search_interval + 5, 300)
				-- since this is pretty expensive: if no bed is found increment search interval by 5 each time with cap at 5 minutes
			end
		end
	end

	if (not self:should_sleep()) and self.order == SLEEP then
		self.order = nil
	end

	if self:check_timer("activity_check", 13) then
		-- Only check in day or during thunderstorm but wandered_too_far code won't work
		local wandered_too_far = false
		if self:check_bed() then
			wandered_too_far = (self.state ~= PATHFINDING) and (vector.distance(self.object:get_pos(), self._bed) > VIL_DIST - 10)
		end
		local activity = self:get_activity()
		-- TODO separate sleep and home activities when villagers can sleep
		if activity == SLEEP or activity == HOME then
			if self:check_bed() then
				self:go_home(true)
			else
				-- If it's sleepy time and we don't have a bed, hide in someone elses house
				self:sleep_over()
			end
		elseif activity == WORK then
			self:do_work()
		elseif activity == GATHERING then
			self:go_to_town_bell()
		elseif wandered_too_far then
			self:go_home(false)
		else
			self.order = nil
		end
	end
end
