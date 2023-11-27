--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

--###################
--################### VILLAGER
--###################
-- Summary: Villagers are complex NPCs, their main feature allows players to trade with them.

-- TODO: Particles
-- TODO: 4s Regeneration I after trade unlock
-- TODO: Behaviour:
-- TODO: Run into house on rain or danger, open doors
-- TODO: Internal inventory, trade with other villagers
-- TODO: Schedule stuff (work,sleep,father)
local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

local allow_nav_hacks = minetest.settings:get_bool("mcl_mob_allow_nav_hacks",false)
local work_dist = 4

local S = minetest.get_translator(modname)

local DEFAULT_WALK_CHANCE = 33 -- chance to walk in percent, if no player nearby
local PLAYER_SCAN_INTERVAL = 5 -- every X seconds, villager looks for players nearby
local PLAYER_SCAN_RADIUS = 4 -- scan radius for looking for nearby players

local RESETTLE_DISTANCE = 100 -- If a mob is transported this far from home, it gives up bed and job and resettles

local PATHFINDING = "gowp"

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

mobs_mc.jobsites = {}
mobs_mc.professions = {}
mobs_mc.villager = {}
mobs_mc.villager_mob = {}

function mobs_mc.register_villager_profession(title, record)

	-- TODO should we allow overriding jobs?
	-- If so what needs to be considered?
	if mobs_mc.professions[title] then
		minetest.log("warning", "[mobs_mc] Trying to register villager job "..title.." which already exists. Skipping.")
		return
	end

	mobs_mc.professions[title] = record

	if record.jobsite then
		table.insert(mobs_mc.jobsites, record.jobsite)
	end
end

for title, record in pairs(dofile(modpath.."/villagers/trades.lua")) do
	mobs_mc.register_villager_profession(title, record)
end

function mobs_mc.villager_mob:stand_still()
	self.walk_chance = 0
	self.jump = false
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

function mobs_mc.villager_mob:set_textures()
	local badge_textures = self:get_badge_textures()
	self.base_texture = badge_textures
	self.object:set_properties({textures=badge_textures})
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
	local weather = mcl_weather.get_weather()

	if weather == "thunder" or weather == "rain" or weather == "snow" then
		return true
	end

	local starts = 17000
	local ends = 18000

	if self._profession == "nitwit" then
		starts = 19000
		ends = 20000
	end

	local tod = minetest.get_timeofday()
	tod = (tod * 24000) % 24000
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
	if self:should_sleep() then
		activity = SLEEP
	elseif self:should_go_home() then
		activity = HOME
	elseif self._profession == "nitwit" then
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
	local p = self.object:get_pos()

	local unclaimed_beds = {}
	local nn2 = minetest.find_nodes_in_area(vector.offset(p,-48,-48,-48),vector.offset(p,48,48,48), {"group:bed"})
	if nn2 then
		for a,b in pairs(nn2) do
			local bed_node = minetest.get_node(b)
			local bed_name = bed_node.name
			local is_bed_bottom = string.find(bed_name,"_bottom")

			local bed_meta = minetest.get_meta(b)
			local owned_by = bed_meta:get_string("villager")

			-- TODO Why is it looking for a new bed if it has a bed and the bed is in the area?
			if (owned_by and owned_by == self._id) then
				bed_meta:set_string("villager", nil)
				bed_meta:set_string("infotext", nil)
				owned_by = nil
			end

			if is_bed_bottom then
				local bed_top_meta = minetest.get_meta(mcl_beds.get_bed_top (b))
				local owned_by_player = bed_top_meta:get_string("player")

				if owned_by == "" and (not owned_by_player or owned_by_player == "") then
					table.insert(unclaimed_beds, b)
				end
			end
		end
	end

	local distance_to_closest_block = nil
	local closest_block = nil

	if unclaimed_beds then
		for i,b in pairs(unclaimed_beds) do
			local distance_to_block = vector.distance(p, b)
			if not distance_to_closest_block or distance_to_closest_block > distance_to_block then
				closest_block = b
				distance_to_closest_block = distance_to_block
			end
		end
	end

	return closest_block
end

function mobs_mc.villager.find_closest_unclaimed_block(p, requested_block_types)
	local nn = minetest.find_nodes_in_area(vector.offset(p,-48,-48,-48),vector.offset(p,48,48,48), requested_block_types)

	local distance_to_closest_block = nil
	local closest_block = nil

	for i,n in pairs(nn) do
		local m = minetest.get_meta(n)

		if m:get_string("villager") == "" then
			local distance_to_block = vector.distance(p, n)
			if not distance_to_closest_block or distance_to_closest_block > distance_to_block then
				closest_block = n
				distance_to_closest_block = distance_to_block
			end
		end
	end
	return closest_block
end

function mobs_mc.villager_mob:check_bed()
	local b = self._bed
	if not b then
		return false
	end

	local n = minetest.get_node(b)

	local is_bed_bottom = string.find(n.name,"_bottom")
	if n and not is_bed_bottom then
		self._bed = nil --the stormtroopers have killed uncle owen
		return false
	else
		return true
	end
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
		if sleep then
			self.order = SLEEP
		end
	else
		if sleep and self.order == SLEEP then
			self.order = nil
			return
		end

		self:gopath(b,function(self,b)
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
				if self.order == "stand" then self.order = nil end
				return
			end

			if self.order ~= SLEEP then
				self.order = SLEEP
				m:set_string("villager", self._id)
				m:set_string("infotext", S("A villager sleeps here"))
				self._bed = closest_block
			end
		else
			self:gopath(closest_block,function(self) end)
		end
	else
		if self.order == "stand" then self.order = nil end
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

local below_vec = vector.new(0, -1, 0)

local function get_ground_below_floating_object (float_pos)
	local pos = float_pos
	repeat
		pos = vector.add(pos, below_vec)
		local node = minetest.get_node(pos)
	until node.name ~= "air"

	-- If pos is 1 below float_pos, then just return float_pos as there is no air below it
	if pos.y == float_pos.y - 1 then
		return float_pos
	end

	return pos
end

function mobs_mc.villager_mob:summon_golem()
	vector.offset(self.object:get_pos(),-10,-10,-10)
	local nn = minetest.find_nodes_in_area_under_air(vector.offset(self.object:get_pos(),-8,-6,-8),vector.offset(self.object:get_pos(),8,6,8),{"group:solid","group:water"})
	table.shuffle(nn)
	for _,n in pairs(nn) do
		local up = minetest.find_nodes_in_area(vector.offset(n,0,1,0),vector.offset(n,0,3,0),{"air"})
		if up and #up >= 3 then
			-- Set home for summoned golem
			local obj = minetest.add_entity(vector.offset(n,0,1,0),"mobs_mc:iron_golem")
			local ent = obj:get_luaentity()
			if ent then
				local bell = minetest.find_node_near(n, 48, {"mcl_bells:bell"})
				if not bell and self._bed then
					bell = minetest.find_node_near(self._bed, 48, {"mcl_bells:bell"})
				end

				if bell then
					ent._home = get_ground_below_floating_object(bell)
				else
					ent._home = n
				end

				return obj
			end
		end
	end
end

function mobs_mc.villager_mob:check_summon(dtime)
	-- TODO has selpt in last 20?
	if self._summon_timer and self._summon_timer > 30 then
		local pos = self.object:get_pos()
		self._summon_timer = 0
		if has_golem(pos) then return end
		if not self:monsters_near() then return end
		if not self:has_summon_participants() then return end
		self:summon_golem()
	elseif self._summon_timer == nil  then
		self._summon_timer = 0
	end
	self._summon_timer = self._summon_timer + dtime
end
--[[
local function debug_trades(self)
	if not self or not self._trades then return end
	local trades = minetest.deserialize(self._trades)
	if trades and type(trades) == "table" then
		for trader, trade in pairs(trades) do
			for tr3, tr4 in pairs (trade) do
				mcl_log("Key: ".. tostring(tr3))
				mcl_log("Value: ".. tostring(tr4))
			end
		end
	end
end
--]]
function mobs_mc.villager_mob:has_traded()
	if not self._trades then
		return false
	end
	local cur_trades_tab = minetest.deserialize(self._trades)
	if cur_trades_tab and type(cur_trades_tab) == "table" then
		for trader, trades in pairs(cur_trades_tab) do
			if trades.traded_once then
				return true
			end
		end
	end
	return false
end

function mobs_mc.villager_mob:unlock_trades()
	if not self._trades then
		return false
	end
	local has_unlocked = false

	local trades = minetest.deserialize(self._trades)
	if trades and type(trades) == "table" then
		for trader, trade in pairs(trades) do
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
	if p and m:get_string("villager") == "" then
		m:set_string("villager",self._id)
		m:set_string("infotext", S("A villager works here"))
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

	local closest_block = mobs_mc.villager.find_closest_unclaimed_block(p, requested_jobsites)

	if closest_block then
		local gp = self:gopath(closest_block,function(self)
			if self and self.state == "stand" then
				self.order = WORK
			end
		end)

		if gp then
			return closest_block
		end
	end

	return nil
end

function mobs_mc.villager_mob:get_a_job()
	if self.order == WORK then self.order = nil end

	local requested_jobsites = mobs_mc.jobsites
	if self:has_traded() then
		requested_jobsites = {mobs_mc.professions[self._profession].jobsite}
		-- Only pass in my jobsite to two functions here
	end

	local p = self.object:get_pos()
	local n = minetest.find_node_near(p,1,requested_jobsites)
	if n and self:employ(n) then return true end

	if self.state ~= PATHFINDING then
		self:look_for_job(requested_jobsites)
	end
end

function mobs_mc.villager_mob:retrieve_my_jobsite()
	if not self or not self._jobsite then
		return
	end
	local n = mcl_vars.get_node(self._jobsite)
	local m = minetest.get_meta(self._jobsite)
	if m:get_string("villager") == self._id then
		return n
	end
	return
end

function mobs_mc.villager_mob:remove_job()
	self._jobsite = nil
	if not self:has_traded() then
		self._profession = "unemployed"
		self._trades = nil
		self:set_textures()
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
	else
		local resettle = vector.distance(self.object:get_pos(),self._jobsite) > RESETTLE_DISTANCE
		if resettle then
			local m = minetest.get_meta(self._jobsite)
			m:set_string("villager", nil)
			m:set_string("infotext", nil)
			self:remove_job()
			return false
		end
		return true
	end
end

function mobs_mc.villager_mob:do_work()
	if self.child then
		return
	end

	-- Don't try if looking_for_work, or gowp possibly
	if self:validate_jobsite() then

		local jobsite2 = mobs_mc.villager_mob:retrieve_my_jobsite()
		local jobsite = self._jobsite

		if self and jobsite2 and self._jobsite then
			local distance_to_jobsite = vector.distance(self.object:get_pos(),self._jobsite)

			if distance_to_jobsite < work_dist then
				if self.state ~= PATHFINDING and  self.order ~= WORK then
					self.order = WORK
					self:unlock_trades()
				end
			else
				if self.order == WORK then
					self.order = nil
					return
				end
				self:gopath(jobsite, function(self,jobsite)
					if not self then
						return false
					end
					if not self._jobsite then
						return false
					end
					if vector.distance(self.object:get_pos(),self._jobsite) < work_dist then
						return true
					end
				end)
			end
		end
	elseif self._profession == "unemployed" or self:has_traded() then
		self:get_a_job()
	end
end

function mobs_mc.villager_mob:teleport_to_town_bell()
	local looking_for_type = {}
	table.insert(looking_for_type, "mcl_bells:bell")

	local p = self.object:get_pos()
	local nn =
		minetest.find_nodes_in_area(vector.offset(p, -48, -48, -48), vector.offset(p, 48, 48, 48), looking_for_type)

	for _, n in pairs(nn) do
		local target_point = get_ground_below_floating_object(n)

		if target_point then
			self.object:set_pos(target_point)
			return
		end
	end
end

function mobs_mc.villager_mob:go_to_town_bell()
	if self.order == GATHERING then
		return
	end

	if not self:ready_to_path() then
		return
	end

	local looking_for_type={}
	table.insert(looking_for_type, "mcl_bells:bell")

	local p = self.object:get_pos()
	local nn = minetest.find_nodes_in_area(vector.offset(p,-48,-48,-48),vector.offset(p,48,48,48), looking_for_type)

	--Ideally should check for closest available. It'll make pathing easier.
	for _,n in pairs(nn) do
		local target_point = get_ground_below_floating_object(n)

		local gp = self:gopath(target_point,function(self)
			if self then
				self.order = GATHERING
			end
		end)

		if gp then
			return n
		end

	end

	return nil
end
--[[
function mobs_mc.villager_mob:validate_bed()
	if not self or not self._bed then
		return false
	end
	local n = mcl_vars.get_node(self._bed)
	if not n then
		self._bed = nil
		return false
	end

	local bed_valid = true

	local m = minetest.get_meta(self._bed)

	local resettle = vector.distance(self.object:get_pos(),self._bed) > RESETTLE_DISTANCE
	if resettle then
		m:set_string("villager", nil)
		self._bed = nil
		bed_valid = false
		return false
	end

	local owned_by_player = m:get_string("player")
	if owned_by_player ~= "" then
		m:set_string("villager", nil)
		self._bed = nil
		bed_valid = false
		return false
	end

	if m:get_string("villager") ~= self._id then
		self._bed = nil
		return false
	else
		return true
	end

end
--]]

function mobs_mc.villager_mob:sleep_over()
	local p = self.object:get_pos()
	local distance_to_closest_bed = 1000
	local closest_bed = nil
	local nn2 =
		minetest.find_nodes_in_area(vector.offset(p, -48, -48, -48), vector.offset(p, 48, 48, 48), { "group:bed" })

	if nn2 then
		for a, b in pairs(nn2) do
			local distance_to_bed = vector.distance(p, b)
			if distance_to_closest_bed > distance_to_bed then
				closest_bed = b
				distance_to_closest_bed = distance_to_bed
			end
		end
	end

	if closest_bed and distance_to_closest_bed >= 3 then
		self:gopath(closest_bed)
	end
end

function mobs_mc.villager_mob:do_activity()
	-- Maybe just check we're pathfinding first?
	if self.following then
		return
	end

	-- If no bed then it's the first thing to do, even at night
	if not self:check_bed() then
		self:take_bed()
	end

	if not self:should_sleep() then
		if self.order == SLEEP then
			self.order = nil
		end
	else
		if allow_nav_hacks then
			-- When a night is skipped telport villagers to their bed or bell
			if self.last_skip == nil then
				self.last_skip = 0
			end
			local last_skip = mcl_beds.last_skip()
			if self.last_skip < last_skip then
				self.last_skip = last_skip
				if self:check_bed() then
					self.object:set_pos(self._bed)
				else
					self:teleport_to_town_bell()
				end
			end
		end
	end

	-- Only check in day or during thunderstorm but wandered_too_far code won't work
	local wandered_too_far = false
	if self:check_bed() then
		wandered_too_far = (self.state ~= PATHFINDING) and (vector.distance(self.object:get_pos(), self._bed) > 50)
	end

	local activity = self:get_activity()

	-- This needs to be most important to least important
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

dofile(modpath.."/villagers/trading.lua")

--[------[ MOB REGISTRATION AND SPAWNING ]-------]

local pick_up = { "mcl_farming:bread", "mcl_farming:carrot_item", "mcl_farming:beetroot_item" , "mcl_farming:potato_item" }


function mobs_mc.villager_mob:on_pick_up(itementity)
	local clicker
	local it = ItemStack(itementity.itemstring)
	for _,p in pairs(minetest.get_connected_players()) do
		if vector.distance(p:get_pos(),self.object:get_pos()) < 10 then
			clicker = p
		end
	end
	if clicker and not self.horny then
		self:feed_tame(clicker, 1, true, false, true)
		it:take_item(1)
	end
	return it
end

function mobs_mc.villager_mob:on_rightclick(clicker)
	if self.child or self._profession == "unemployed" or self._profession == "nitwit" then
		self.order = nil
		return
	end

	if self.state == PATHFINDING then
		self.state = "stand"
	end
	-- Can we remove now we possibly have fixed root cause
	if self.state == "attack" then
		-- Need to stop villager getting in attack state. This is a workaround to allow players to fix broken villager.
		self.state = "stand"
		self.attack = nil
	end
	-- Don't do at night. Go to bed? Maybe do_activity needs it's own method
	if self:validate_jobsite() and self.order ~= WORK then
		minetest.log("warning","[mobs_mc] villager has jobsite but doesn't work")
		--self:gopath(self._jobsite,function()
		--	minetest.log("sent to jobsite")
		--end)
	else
		self.state = "stand" -- cancel gowp in case it has messed up
		--self.order = nil -- cancel work if working
	end

	-- Initiate trading
	self:init_trader_vars()
	local name = clicker:get_player_name()
	self._trading_players[name] = true

	if self._trades == nil or self._trades == false then
		--minetest.log("Trades is nil so init")
		self:init_trades()
	end
	self:update_max_tradenum()
	if self._trades == false then
		--minetest.log("Trades is false. no right click op")
		-- Villager has no trades, rightclick is a no-op
		return
	end

	local inv = minetest.get_inventory({type="detached", name="mobs_mc:trade_"..name})
	if not inv then
		return
	end

	self:set_trade(clicker, inv, 1)

	self:show_trade_formspec(name)

	-- Behaviour stuff:
	-- Make villager look at player and stand still
	local selfpos = self.object:get_pos()
	local clickerpos = clicker:get_pos()
	local dir = vector.direction(selfpos, clickerpos)
	self.object:set_yaw(minetest.dir_to_yaw(dir))
	self:stand_still()
end

function mobs_mc.villager_mob:do_custom(dtime)
	self:check_summon(dtime)

	-- Stand still if player is nearby.
	if not self._player_scan_timer then
		self._player_scan_timer = 0
	end
	self._player_scan_timer = self._player_scan_timer + dtime

	-- Check infrequently to keep CPU load low
	if self._player_scan_timer > PLAYER_SCAN_INTERVAL then

		self._player_scan_timer = 0
		local selfpos = self.object:get_pos()
		local objects = minetest.get_objects_inside_radius(selfpos, PLAYER_SCAN_RADIUS)
		local has_player = false

		for o, obj in pairs(objects) do
			if obj:is_player() then
				has_player = true
				break
			end
		end
		if has_player then
			--minetest.log("verbose", "[mobs_mc] Player near villager found!")
			self:stand_still()
		else
			--minetest.log("verbose", "[mobs_mc] No player near villager found!")
			self.walk_chance = DEFAULT_WALK_CHANCE
			self.jump = true
		end

		self:do_activity()

	end
end

function mobs_mc.villager_mob:on_spawn()
	if not self._profession then
		self._profession = "unemployed"
		if math.random(100) == 1 then
			self._profession = "nitwit"
		end
	end
	if self._id then
		self:set_textures()
		return
	end
	self._id=minetest.sha1(minetest.get_gametime()..minetest.pos_to_string(self.object:get_pos())..tostring(math.random()))
	self:set_textures()
end

function mobs_mc.villager_mob:on_die(pos, cmi_cause)
	-- Close open trade formspecs and give input back to players
	local trading_players = self._trading_players
	if trading_players then
		for name, _ in pairs(trading_players) do
			minetest.close_formspec(name, "mobs_mc:trade_"..name)
			local player = minetest.get_player_by_name(name)
			if player then
				mobs_mc.villager.return_fields(player)
			end
		end
	end

	local bed = self._bed
	if bed then
		local bed_meta = minetest.get_meta(bed)
		bed_meta:set_string("villager", nil)
		bed_meta:set_string("infotext", nil)
	end
	local jobsite = self._jobsite
	if jobsite then
		local jobsite_meta = minetest.get_meta(jobsite)
		jobsite_meta:set_string("villager", nil)
		jobsite_meta:set_string("infotext", nil)
	end

	if cmi_cause and cmi_cause.puncher then
		local l = cmi_cause.puncher:get_luaentity()
		if l and math.random(2) == 1 and( l.name == "mobs_mc:zombie" or l.name == "mobs_mc:baby_zombie" or l.name == "mobs_mc:villager_zombie" or l.name == "mobs_mc:husk") then
			mcl_util.replace_mob(self.object,"mobs_mc:villager_zombie")
			return true
		end
	end
end

function mobs_mc.villager_mob:on_lightning_strike(pos, pos2, objects)
	 mcl_util.replace_mob(self.object, "mobs_mc:witch")
	 return true
end

table.update(mobs_mc.villager_mob, {
	description = S("Villager"),
	type = "npc",
	spawn_class = "passive",
	passive = true,
	hp_min = 20,
	hp_max = 20,
	head_swivel = "head.control",
	bone_eye_height = 6.3,
	head_eye_height = 2.2,
	curiosity = 10,
	runaway = true,
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.94, 0.3},
	visual = "mesh",
	mesh = "mobs_mc_villager.b3d",
	textures = {
		"mobs_mc_villager.png",
		"mobs_mc_villager.png", --hat
	},
	makes_footstep_sound = true,
	walk_velocity = 1.2,
	run_velocity = 2.4,
	drops = {},
	can_despawn = false,
	-- TODO: sounds
	sounds = {
		random = "mobs_mc_villager",
		damage = "mobs_mc_villager_hurt",
		distance = 10,
	},
	animation = {
		stand_start = 0, stand_end = 0,
		walk_start = 0, walk_end = 40, walk_speed = 25,
		run_start = 0, run_end = 40, run_speed = 25,
		head_shake_start = 60, head_shake_end = 70, head_shake_loop = false,
		head_nod_start = 50, head_nod_end = 60, head_nod_loop = false,
	},
	child_animations = {
		stand_start = 71, stand_end = 71,
		walk_start = 71, walk_end = 111, walk_speed = 37,
		run_start = 71, run_end = 111, run_speed = 37,
		head_shake_start = 131, head_shake_end = 141, head_shake_loop = false,
		head_nod_start = 121, head_nod_end = 131, head_nod_loop = false,
	},
	follow = pick_up,
	nofollow = true,
	view_range = 16,
	fear_height = 4,
	jump = true,
	walk_chance = DEFAULT_WALK_CHANCE,
	_bed = nil,
	_id = nil,
	_profession = "unemployed",
	look_at_player = true,
	pick_up = pick_up,
	can_open_doors = true,
	_player_scan_timer = 0,
	_trading_players = {}, -- list of playernames currently trading with villager (open formspec)

	after_activate = mobs_mc.villager_mob.set_textures,
})

mcl_mobs.register_mob("mobs_mc:villager", mobs_mc.villager_mob)

-- spawn eggs
mcl_mobs.register_egg("mobs_mc:villager", S("Villager"), "#563d33", "#bc8b72", 0)
