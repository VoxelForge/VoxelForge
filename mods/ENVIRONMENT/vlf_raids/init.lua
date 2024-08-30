-- vlf_raids
vlf_raids = {}

-- Define the amount of illagers to spawn each wave.
local waves = {
	{
		["mobs_mc:pillager"] = 5,
		["mobs_mc:vindicator"] = 1,
	},
	{
		["mobs_mc:pillager"] = 4,
		["mobs_mc:vindicator"] = 3,
	},
	{
		["mobs_mc:pillager"] = 4,
		["mobs_mc:vindicator"] = 1,
		["mobs_mc:witch"] = 1,
		--["mobs_mc:ravager"] = 1,
	},
	{
		["mobs_mc:pillager"] = 5,
		["mobs_mc:vindicator"] = 2,
		["mobs_mc:witch"] = 3,
	},
	{
		["mobs_mc:pillager"] = 5,
		["mobs_mc:vindicator"] = 5,
		["mobs_mc:witch"] = 1,
		["mobs_mc:evoker"] = 1,
	},
}

local extra_wave = {
	["mobs_mc:pillager"] = 5,
	["mobs_mc:vindicator"] = 5,
	["mobs_mc:witch"] = 1,
	["mobs_mc:evoker"] = 1,
	--["mobs_mc:ravager"] = 2,
}

local oban_layers = {
	{
		pattern = "rhombus",
		color = "unicolor_cyan"
	},
	{
		color = "unicolor_grey",
		pattern = "stripe_bottom"
	},
	{
		pattern = "stripe_center",
		color = "unicolor_darkgrey"
	},
	{
		color = "unicolor_black",
		pattern = "stripe_middle"
	},
	{
		pattern = "half_horizontal",
		color = "unicolor_grey"
	},
	{
		color = "unicolor_grey",
		pattern = "circle"
	},
	{
		pattern = "border",
		color = "unicolor_black"
	}
}


local oban_def = table.copy(minetest.registered_entities["vlf_banners:standing_banner"])
oban_def.initial_properties.visual_size = { x=1, y=1 }
local old_step = oban_def.on_step
oban_def.on_step = function(self)
	if not self.object:get_attach() then return self.object:remove() end
	if old_step then return old_step(self.dtime) end
end

minetest.register_entity(":vlf_raids:ominous_banner",oban_def)

function vlf_raids.drop_obanner(pos)
	local it = ItemStack("vlf_banners:banner_item_white")
	it:get_meta():set_string("layers",minetest.serialize(oban_layers))
	local banner_description = string.gsub(it:get_definition().description, "White Banner", "Ominous Banner")
	local description = vlf_banners.make_advanced_banner_description(banner_description, oban_layers)
	it:get_meta():set_string("description", description)
	minetest.add_item(pos,it)
end

function vlf_raids.promote_to_raidcaptain(c) -- object
	if not c or not c:get_pos() then return end
	local pos = c:get_pos()
	local l = c:get_luaentity()
	l._banner = minetest.add_entity(pos,"vlf_raids:ominous_banner")
	if not l._banner or not l._banner:get_pos() then return end
	l._banner:set_properties({textures = {vlf_banners.make_banner_texture("unicolor_white", oban_layers)}})
	l._banner:set_attach(c, "", vector.new(0, 6, -1), vector.new(0, 0, 0), true)
	l._raidcaptain = true
	local old_ondie = l.on_die
	l.on_die = function(self, pos, cmi_cause)
		if l._banner then
			l._banner:remove()
			l._banner = nil
			vlf_raids.drop_obanner(pos)
			if cmi_cause and cmi_cause.type == "punch" and cmi_cause.puncher:is_player() then
				awards.unlock(cmi_cause.puncher:get_player_name(), "vlf:voluntary_exile")
				local lv = vlf_entity_effects.get_entity_effect_level(cmi_cause.puncher, "bad_omen")
				if not lv then lv = 0 end
				lv = math.max(5,lv + 1)
				vlf_entity_effects.give_entity_effect_by_level("bad_omen", cmi_cause.puncher, lv, 6000)
			end
		end
		if old_ondie then return old_ondie(self,pos,cmi_cause) end
	end
end

function vlf_raids.is_raidcaptain_near(pos)
	for _, v in pairs(minetest.get_objects_inside_radius(pos,32)) do
		local l = v:get_luaentity()
		if l and l._raidcaptain then return true end
	end
end

function vlf_raids.register_possible_raidcaptain(mob)
	local old_on_spawn = minetest.registered_entities[mob].on_spawn
	local old_on_pick_up = minetest.registered_entities[mob].on_pick_up
	if not minetest.registered_entities[mob].pick_up then  minetest.registered_entities[mob].pick_up = {} end
	table.insert(minetest.registered_entities[mob].pick_up,"vlf_banners:banner_item_white")
	minetest.registered_entities[mob].on_pick_up = function(self,e)
		local stack = ItemStack(e.itemstring)
		if not self._raidcaptain and stack:get_meta():get_string("description"):find("Ominous Banner") then
			stack:take_item(1)
			vlf_raids.promote_to_raidcaptain(self.object)
			return stack
		end
		if old_on_pick_up then return old_on_pick_up(self,e) end
	end
	minetest.registered_entities[mob].on_spawn = function(self)
		if not vlf_raids.is_raidcaptain_near(self.object:get_pos()) then
			vlf_raids.promote_to_raidcaptain(self.object)
		end
		if old_on_spawn then return old_on_spawn(self) end
	end
end

vlf_raids.register_possible_raidcaptain("mobs_mc:pillager")
vlf_raids.register_possible_raidcaptain("mobs_mc:vindicator")
vlf_raids.register_possible_raidcaptain("mobs_mc:evoker")

function vlf_raids.spawn_raid(event)
	local pos = event.pos
	local r = 32
	local n = 12
	local i = math.random(1, n)
	local raid_pos = vector.offset(pos,r * math.cos(((i-1)/n) * (2*math.pi)),0,  r * math.sin(((i-1)/n) * (2*math.pi)))
	local sn = minetest.find_nodes_in_area_under_air(vector.offset(raid_pos,-5,-50,-5), vector.offset(raid_pos,5,50,5), {"group:grass_block", "group:grass_block_snow", "group:snow_cover", "group:sand", "vlf_core:ice"})
	vlf_bells.ring_once(pos)
	if sn and #sn > 0 then
		local spawn_pos = sn[math.random(#sn)]
		if spawn_pos then
			minetest.log("action", "[vlf_raids] Raid Spawn Position chosen at " .. minetest.pos_to_string(spawn_pos) .. ".")
			event.health_max = 0
			local w
			if event.stage <= #waves then
				w= waves[event.stage]
			else
				w = extra_wave
			end
			for m,c in pairs(w) do
				for _ = 1, c do
					local p = vector.offset(spawn_pos,0,1,0)
					local mob = vlf_mobs.spawn(p,m)
					if mob then
						local l = mob:get_luaentity()
						if l then
							l.raidmob = true
							event.health_max = event.health_max + l.health
							table.insert(event.mobs,mob)
							l:gopath(pos)
						end
					end
				end
			end
			if event.stage == 1 then
				table.shuffle(event.mobs)
				vlf_raids.promote_to_raidcaptain(event.mobs[1])
			end
			minetest.log("action", "[vlf_raids] Raid Spawned. Illager Count: " .. #event.mobs .. ".")
			return #event.mobs == 0
		else
			minetest.log("action", "[vlf_raids] Raid Spawn Postion not chosen.")
		end
	elseif not sn then
		minetest.log("action", "[vlf_raids] Raid Spawn Position error, no appropriate site found.")
	end
	return true
end

function vlf_raids.find_villager(pos)
	local obj = minetest.get_objects_inside_radius(pos, 8)
	for _, objects in pairs(obj) do
		local object = objects:get_luaentity()
		if object and object.name == "mobs_mc:villager" then
			return true
		end
	end
end

function vlf_raids.find_bed(pos)
	return minetest.find_node_near(pos,32,{"group:bed"})
end

function vlf_raids.find_village(pos)
	local bed = vlf_raids.find_bed(pos)
	if bed and vlf_raids.find_villager(bed) then
		return bed
	end
end

local function is_player_near(self)
	for _,pl in pairs(minetest.get_connected_players()) do
		if self.pos and vector.distance(pl:get_pos(),self.pos) < 64 then return true end
	end
end

local function check_mobs(self)
	local m = {}
	local h = 0
	for _, o in pairs(self.mobs) do
		if o and o:get_pos() then
			local l = o:get_luaentity()
			h = h + l.health
			table.insert(m,o)
		end
	end
	if #m == 0 then --if no valid mobs in table search if there are any (reloaded ones) in the area
		for _, o in pairs(minetest.get_objects_inside_radius(self.pos,64)) do
			local l = o:get_luaentity()
			if l and l.raidmob then
				local l = o:get_luaentity()
				h = h + l.health
				table.insert(m,o)
			end
		end
	end
	self.mobs = m
	return h
end

vlf_events.register_event("raid",{
	readable_name = "Raid",
	max_stage = 5,
	health = 1,
	health_max = 1,
	exclusive_to_area = 128,
	enable_bossbar = true,
	cond_start  = function()
		local r = {}
		for _,p in pairs(minetest.get_connected_players()) do
			if vlf_entity_effects.has_effect(p,"bad_omen") then
				local raid_pos = vlf_raids.find_village(p:get_pos())
				if raid_pos then
					table.insert(r,{ player = p:get_player_name(), pos = raid_pos })
				end
			end
		end
		if #r > 0 then return r end
	end,
	on_start = function(self)
		self.mobs = {}
		self.health_max = 1
		self.health = 0
		local lv = vlf_entity_effects.get_entity_effect_level(minetest.get_player_by_name(self.player), "bad_omen")
		if lv and lv > 1 then self.max_stage = 6 end
	end,
	cond_progress = function(self)
		if not is_player_near(self) then return false end
		self.health = check_mobs(self)
		self.percent = math.max(0,(self.health / self.health_max ) * 100)
		if #self.mobs < 1 then
			return true end
	end,
	on_stage_begin = vlf_raids.spawn_raid,
	cond_complete = function(self)
		if not is_player_near(self) then return false end
		--let the event api handle cancel the event when no players are near
		--without this check it would sort out the unloaded mob entities and
		--think the raid is defeated.
		check_mobs(self)
		return self.stage >= self.max_stage and #self.mobs < 1
	end,
	on_complete = function(self)
	    local player = minetest.get_player_by_name (self.player)
	    awards.unlock (self.player,"vlf:hero_of_the_village")

	    if player then
		vlf_entity_effects.clear_entity_effect (player, "bad_omen")
		vlf_entity_effects.give_entity_effect ("hero_of_village", player, 0, false)
	    end
	end,
})

minetest.register_chatcommand("raidcap",{
	privs = {debug = true},
	func = function(pname)
		local c = minetest.add_entity(minetest.get_player_by_name(pname):get_pos(),"mobs_mc:pillager")
		vlf_raids.promote_to_raidcaptain(c)
	end,
})

minetest.register_chatcommand("dump_banner_layers",{
	privs = {debug = true},
	func = function(pname)
		local p = minetest.get_player_by_name(pname)
		vlf_raids.drop_obanner(vector.offset(p:get_pos(),1,1,1))
		for _, v in pairs(minetest.get_objects_inside_radius(p:get_pos(),5)) do
			local l = v:get_luaentity()
			if l and l.name == "vlf_banners:standing_banner" then
				minetest.log(dump(l._base_color))
				minetest.log(dump(l._layers))
			end
		end
	end
})
