-- mcl_raids
mcl_raids = {}

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

mcl_raids.ominous_banner_layers = oban_layers

local oban_def = table.copy(minetest.registered_entities["mcl_banners:standing_banner"])
oban_def.initial_properties.visual_size = { x=1, y=1 }
local old_step = oban_def.on_step
oban_def.on_step = function(self)
	if not self.object:get_attach() then return self.object:remove() end
	if old_step then return old_step(self.dtime) end
end

minetest.register_entity(":mcl_raids:ominous_banner",oban_def)

function mcl_raids.drop_obanner(pos)
	local it = ItemStack("mcl_banners:banner_item_white")
	it:get_meta():set_string("layers",minetest.serialize(oban_layers))
	local banner_description = string.gsub(it:get_definition().description, "White Banner", "Ominous Banner")
	local description = mcl_banners.make_advanced_banner_description(banner_description, oban_layers)
	it:get_meta():set_string("description", description)
	minetest.add_item(pos,it)
end

function mcl_raids.is_banner_item (stack)
	local name = stack:get_name ()
	if name == "mcl_banners:banner_item_white" then
		local metadata = stack:get_meta ()
		local layers = metadata:get_string ("layers")
		if layers == "" then
			return false
		end
		layers = minetest.deserialize (layers)
		if #layers ~= #oban_layers then
			return false
		end
		for i = 1, #layers do
			if oban_layers[i].color ~= layers[i].color
				or oban_layers[i].pattern ~= layers[i].pattern then
				return false
			end
		end
		return true
	end
	return false
end

function mcl_raids.enroll_in_raid (raid, entity)
	entity._get_active_raid = function (raidmob)
		return not raid.completed
			and raid or nil
	end
	if table.indexof (raid.mobs, entity.object) == -1 then
		table.insert (raid.mobs, entity.object)
	end
	entity.raidmob = true
end

function mcl_raids.find_surface_position (node_pos)
	if node_pos.y < mcl_vars.mg_overworld_min then
		return node_pos
	else
		-- Raycast from a position 256 blocks above the
		-- overworld to the bottom of the world, and locate
		-- the first opaque or liquid non-leaf block.

		local v = vector.copy (node_pos)
		v.y = math.max (node_pos.y, 256)
		local lim
			= math.max (mcl_vars.mg_overworld_min, node_pos.y - 512)
		while v.y >= lim do
			local node = minetest.get_node (v)
			local def = minetest.registered_nodes[node.name]
			if node.name ~= "ignore"
				and (def.groups.liquid or def.walkable) then
				break
			end
			v.y = v.y - 1
		end
		v.y = v.y + 1
		return v
	end
end

function mcl_raids.find_active_raid (pos)
	for _, event in ipairs (mcl_events.active_events) do
		if event.exclusive_to_area
			and vector.distance (pos, event.pos)
				<= event.exclusive_to_area
			and event.health_max then
			return event
		end
	end
	return nil
end

local pr = PcgRandom (os.time () + 970)
local r = 1 / 2147483647

local function is_opaque (node)
	return minetest.get_item_group (node.name, "opaque") > 0
end

local function is_clear (node)
	return minetest.get_item_group (node.name, "liquid") == 0
		and not minetest.registered_nodes[node.name].walkable
end

local function is_opaque_or_snow (node)
	if is_opaque (node) then
		return true
	end
	local snow = minetest.get_item_group (node.name, "top_snow")
	return snow > 0 and snow <= 4
end

function mcl_raids.do_spawn_pos_phase (phaseno, center, attempts)
	local spread = phaseno == 0 and 2 or 2 - phaseno

	-- Perform twenty attempts to select a valid spawn position
	-- per phase.
	for i = 1, attempts or 20 do
		local random = pr:next (0, 2147483647) * r * math.pi * 2
		local xoff = math.floor (math.cos (random) * 32 * spread)
			+ pr:next (0, 4)
		local zoff = math.floor (math.sin (random) * 32 * spread)
			+ pr:next (0, 4)
		local new_pos = vector.offset (center, xoff, 0, zoff)
		local surface = mcl_raids.find_surface_position (new_pos)
		local below = vector.offset (surface, 0, -1, 0)
		local above = vector.offset (surface, 0, 1, 0)

		-- Is this surface outside of any village or is this
		-- the final attempt?
		if attempts == 2
			or mcl_villages.get_poi_heat (surface) < 4 then
			-- Is this surface walkable and loaded...
			local node = minetest.get_node (surface)
			local node_above = minetest.get_node (above)
			local node_below = minetest.get_node (below)
			if node.name ~= "ignore"
				and node_above.name ~= "ignore"
				and node_below.name ~= "ignore"
				and is_clear (node_above)
				and is_clear (node)
				and is_opaque_or_snow (node_below) then
				return surface
			end
		end
	end
end

function mcl_raids.select_spawn_position (center)
	local pos = mcl_raids.do_spawn_pos_phase (0, center, 20)
	if pos then
		return pos
	end
	local pos = mcl_raids.do_spawn_pos_phase (1, center, 20)
	if pos then
		return pos
	end
	local pos = mcl_raids.do_spawn_pos_phase (2, center, 20)
	return pos
end

function mcl_raids.spawn_raid(event)
	local pos = event.pos
	mcl_bells.ring_once (pos)
	local spawn_pos = mcl_raids.select_spawn_position (event.pos)
	if spawn_pos then
		minetest.log("action", "[mcl_raids] Raid Spawn Position selected at "
			     .. minetest.pos_to_string (spawn_pos) .. ".")
		event.health_max = 0
		local w
		if event.stage <= #waves then
			w= waves[event.stage]
		else
			w = extra_wave
		end
		local captain = nil
		for m,c in pairs(w) do
			for _ = 1, c do
				local p = vector.offset(spawn_pos,0,1,0)
				local datatable = {
					_raid_spawn = 1,
				}
				local staticdata = minetest.serialize (datatable)
				local mob = mcl_mobs.spawn (p, m, staticdata)
				if mob then
					local l = mob:get_luaentity()
					if l then
						l.raidmob = true
						event.health_max = event.health_max + l.health
						table.insert(event.mobs,mob)
						l._get_active_raid = function (raidmob)
							return not event.completed
								and event or nil
						end
					end

					if l._can_serve_as_captain and not captain then
						l:promote_to_raidcaptain ()
						captain = mob
					end
				end
			end
		end
		event._raidcaptain = captain
		minetest.log("action", "[mcl_raids] Raid Spawned. "
			     .. "Illager Count: " .. #event.mobs .. ".")
		return #event.mobs == 0
	else
		minetest.log("action", "[mcl_raids] Raid Spawn Postion not chosen.")
	end
	return true
end

function mcl_raids.find_villager(pos)
	for objects in minetest.objects_inside_radius(pos, 8) do
		local object = objects:get_luaentity()
		if object and object.name == "mobs_mc:villager" then
			return true
		end
	end
end

function mcl_raids.find_bed(pos)
	return minetest.find_node_near(pos,32,{"group:bed"})
end

function mcl_raids.find_village(pos)
	local bed = mcl_raids.find_bed(pos)
	if bed and mcl_raids.find_villager(bed) then
		return bed
	end
end

local function is_player_near(self)
	for _ in mcl_util.connected_players(self.pos, 63) do return true end
end

local function check_mobs(self)
	local m = {}
	local h = 0
	local accessor = function (raidmob)
		return not self.completed and self or nil
	end
	self._raidcaptain = nil
	for _, o in pairs(self.mobs) do
		if o and o:get_pos() then
			local l = o:get_luaentity()
			h = h + l.health
			if l._raidcaptain then
				self._raidcaptain = o
			end
			l._get_active_raid = accessor
			table.insert(m,o)
		end
	end
	if #m == 0 then --if no valid mobs in table search if there are any (reloaded ones) in the area
		for o in minetest.objects_inside_radius(self.pos, 128) do
			local l = o:get_luaentity()
			if l and l.raidmob then
				local l = o:get_luaentity()
				if l._raidcaptain then
					self._raidcaptain = o
				end
				l._get_active_raid = accessor
				h = h + l.health
				table.insert(m,o)
			end
		end
	end
	self.mobs = m
	return h
end

mcl_events.register_event("raid",{
	readable_name = "Raid",
	max_stage = 5,
	health = 1,
	health_max = 1,
	exclusive_to_area = 128,
	enable_bossbar = true,
	cond_start  = function()
		local r = {}
		for p in mcl_util.connected_players() do
			if mcl_potions.has_effect(p,"bad_omen") then
				local raid_pos = mcl_raids.find_village(p:get_pos())
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
		local lv = mcl_potions.get_effect_level(minetest.get_player_by_name(self.player), "bad_omen")
		if lv and lv > 1 then self.max_stage = 6 end
	end,
	cond_progress = function(self)
		if not is_player_near(self) then return false end
		self.health = check_mobs(self)
		self.percent = math.max(0,(self.health / self.health_max ) * 100)
		if #self.mobs < 1 then
			return true end
	end,
	on_stage_begin = mcl_raids.spawn_raid,
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
	    awards.unlock (self.player,"mcl:hero_of_the_village")

	    if player then
		mcl_potions.clear_effect (player, "bad_omen")
		mcl_potions.give_effect ("hero_of_village", player, 0, 2400)
	    end
	end,
})

minetest.register_chatcommand("dump_banner_layers",{
	privs = {debug = true},
	func = function(pname)
		local p = minetest.get_player_by_name(pname)
		mcl_raids.drop_obanner(vector.offset(p:get_pos(),1,1,1))
		for v in minetest.objects_inside_radius(p:get_pos(), 5) do
			local l = v:get_luaentity()
			if l and l.name == "mcl_banners:standing_banner" then
				minetest.log(dump(l._base_color))
				minetest.log(dump(l._layers))
			end
		end
	end
})
