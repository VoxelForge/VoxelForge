--[[local S = minetest.get_translator(minetest.get_current_modname())

vlf_trialspawners = {}

local default_mob = "mobs_mc:pig"

-- Mob spawner
--local spawner_default = default_mob.." 0 15 4 15"

local function get_mob_textures(mob)
	local list = minetest.registered_entities[mob].texture_list
	if type(list[1]) == "table" then
		return list[1]
	else
		return list
	end
end

local function find_doll(pos)
	for  _,obj in pairs(minetest.get_objects_inside_radius(pos, 0.5)) do
		if not obj:is_player() then
			if obj and obj:get_luaentity().name == "vlf_trialspawners:doll" then
				return obj
			end
		end
	end
	return nil
end

local function spawn_doll(pos)
	return minetest.add_entity({x=pos.x, y=pos.y-0.3, z=pos.z}, "vlf_trialspawners:doll")
end

local spawn_count_overrides = {
	["mobs_mc:enderdragon"] = 1,
	["mobs_mc:wither"] = 1,
	["mobs_mc:ghast"] = 1,
	["mobs_mc:guardian_elder"] = 1,
	["mobs_mc:guardian"] = 2,
	["mobs_mc:iron_golem"] = 2,
}

local function set_doll_properties(doll, mob)
	local mobinfo = minetest.registered_entities[mob]
	if not mobinfo then return end
	local xs, ys
	if mobinfo.doll_size_override then
		xs = mobinfo.doll_size_override.x
		ys = mobinfo.doll_size_override.y
	else
		xs = mobinfo.initial_properties.visual_size.x * 0.33333
		ys = mobinfo.initial_properties.visual_size.y * 0.33333
	end
	local prop = {
		mesh = mobinfo.initial_properties.mesh,
		textures = get_mob_textures(mob),
		visual_size = {
			x = xs,
			y = ys,
		}
	}
	doll:set_properties(prop)
	doll:get_luaentity()._mob = mob
end

local function respawn_doll(pos)
	local meta = minetest.get_meta(pos)
	local mob = meta:get_string("Mob")
	local doll
	if mob and mob ~= "" then
		doll = find_doll(pos)
		if not doll then
			doll = spawn_doll(pos)
			if doll and doll:get_pos() then
				set_doll_properties(doll, mob)
			end
		end
	end
	return doll
end

--[[ Public function: Setup the spawner at pos.
This function blindly assumes there's actually a spawner at pos.
If not, then the results are undefined.
All the arguments are optional!

* Mob: ID of mob to spawn (default: mobs_mc:pig)
* MinLight: Minimum light to spawn (default: 0)
* MaxLight: Maximum light to spawn (default: 15)
* MaxMobsInArea: How many mobs are allowed in the area around the spawner (default: 4)
* PlayerDistance: Spawn mobs only if a player is within this distance; 0 to disable (default: 15)
* YOffset: Y offset to spawn mobs; 0 to disable (default: 0)
]]

--[[function vlf_trialspawners.setup_spawner(pos, Mob, MinLight, MaxLight, MaxMobsInArea, PlayerDistance, YOffset, MaxMobs)
    -- Activate mob spawner and disable editing functionality
    local dim = vlf_worlds.pos_to_dimension(pos)
    if Mob == nil then Mob = default_mob end
    local mn,mx = vlf_mobs.get_mob_light_level(Mob,dim)
    if MinLight == nil then MinLight = mn end
    if MaxLight == nil then MaxLight = mx end
    if MaxMobsInArea == nil then MaxMobsInArea = 2 end
    if PlayerDistance == nil then PlayerDistance = 10 end
    local players = minetest.get_connected_players()
    if YOffset == nil then YOffset = 0 end
    local meta = minetest.get_meta(pos)
    local ominous_adder = meta:get_string("ominous") and 1.5 or 0
    if MaxMobs == nil then MaxMobs = 2 end

    -- Calculate the number of players near the spawner
    local nearby_players_count = 0
    for _, player in ipairs(players) do
        local player_pos = player:get_pos()
        if vector.distance(player_pos, pos) <= PlayerDistance then
            nearby_players_count = nearby_players_count + 1
        end
    end

    -- Multiply max mobs by number of nearby players and add ominous factor
    MaxMobs = MaxMobs * nearby_players_count + ominous_adder
    meta:set_string("Mob", Mob)
    meta:set_int("MinLight", MinLight)
    meta:set_int("MaxLight", MaxLight)
    meta:set_int("MaxMobsInArea", MaxMobsInArea)
    meta:set_int("PlayerDistance", PlayerDistance)
    meta:set_int("YOffset", YOffset)
    meta:set_int("MaxMobs", MaxMobs)

    -- Create doll or replace existing doll
    local doll = find_doll(pos)
    if not doll then
        doll = spawn_doll(pos)
    end
    set_doll_properties(doll, Mob)

    -- Start spawning very soon
    local t = minetest.get_node_timer(pos)
    t:start(2)
end

-- Spawn mobs around pos
-- NOTE: The node is timer-based, rather than ABM-based.
local function spawn_mobs(pos, elapsed)
    -- get meta
    local meta = minetest.get_meta(pos)

    -- get settings
    local mob = meta:get_string("Mob")
    local mlig = meta:get_int("MinLight")
    local xlig = meta:get_int("MaxLight")
    local max_mobs_in_area = meta:get_int("MaxMobsInArea")
    local player_distance = meta:get_int("PlayerDistance")
    local y_offset = meta:get_int("YOffset")
    local max_mobs = meta:get_int("MaxMobs")
    
    -- Track the total number of mobs spawned over time
    local total_spawned = meta:get_int("TotalSpawned")

    -- If we have already spawned the maximum number of mobs, stop and turn the node to stone
    if total_spawned >= max_mobs then
        minetest.set_node(pos, {name = "default:stone"}) -- Change the spawner node to stone
        return
    end

    -- Check if the mob type is registered
    if not vlf_mobs.spawning_mobs[mob] then
        minetest.log("error", "[vlf_trialspawners] Mob Spawner: Mob doesn't exist: " .. mob)
        return
    end

    -- Check for players within the player distance radius
    local objs = minetest.get_objects_inside_radius(pos, player_distance)
    local in_range = false
    for _, obj in pairs(objs) do
        if obj:is_player() then
            in_range = true
            break
        end
    end

    -- If no players are in range, restart the timer and try again soon
    if not in_range then
        local timer = minetest.get_node_timer(pos)
        timer:start(2)
        return
    end

    -- Ensure the doll for the mob exists
    local doll = find_doll(pos)
    if not doll then
        doll = spawn_doll(pos)
        set_doll_properties(doll, mob)
    end

    -- Find air blocks within the spawning area (8x3x8)
    local air = minetest.find_nodes_in_area(
        {x = pos.x - 2, y = pos.y - 1 + y_offset, z = pos.z - 2},
        {x = pos.x + 2, y = pos.y + 1 + y_offset, z = pos.z + 2},
        {"air"}
    )

    -- Spawn mobs in random air blocks
    if air then
        local max_spawn = 2
        if spawn_count_overrides[mob] then
            max_spawn = spawn_count_overrides[mob]
        end
        for a = 1, max_spawn do
            -- Check if spawning this mob would exceed the MaxMobs limit
            if total_spawned >= max_mobs then
                -- If spawning this mob would exceed the limit, turn the node to stone and stop spawning
                minetest.set_node(pos, {name = "vlf_core:stone"})
                return
            end

            if #air <= 0 then
                break -- No more space to spawn
            end

            local air_index = math.random(#air)
            local spawn_pos = air[air_index]
            local light_level = minetest.get_node_light(spawn_pos) or 0

            spawn_pos.y = spawn_pos.y + 0.5

            -- Spawn mob if light levels are within range
            if light_level >= mlig and light_level <= xlig then
                minetest.add_entity(spawn_pos, mob)

                -- Increment the total number of mobs spawned
                total_spawned = total_spawned + 1
                meta:set_int("TotalSpawned", total_spawned)

                -- If the total number of spawned mobs reaches MaxMobs, change the node to stone
                if total_spawned >= max_mobs then
                    minetest.set_node(pos, {name = "vlf_core:stone"})
                    return
                end
            end

            table.remove(air, air_index)
        end
    end

    -- Schedule the next spawn attempt
    local timer = minetest.get_node_timer(pos)
    timer:start(math.random(6, 15))
end


-- The mob spawner node.
-- PLACEMENT INSTRUCTIONS:
-- If this node is placed by a player, minetest.item_place, etc. default settings are applied
-- automatially.
-- IF this node is placed by ANY other method (e.g. minetest.set_node, LuaVoxelManip), you
-- MUST call vlf_trialspawners.setup_spawner right after the spawner has been placed.
minetest.register_node("vlf_trialspawners:spawner", {
	tiles = {"mob_spawner.png"},
	drawtype = "glasslike",
	paramtype = "light",
	description = S("Mob Spawner"),
	_tt_help = S("Makes mobs appear"),
	_doc_items_longdesc = S("A mob spawner regularily causes mobs to appear around it while a player is nearby. Some mob spawners are disabled while in light."),
	_doc_items_usagehelp = S("If you have a spawn egg, you can use it to change the mob to spawn. Just place the item on the mob spawner. Player-set mob spawners always spawn mobs regardless of the light level."),
	groups = {pickaxey=1, material_stone=1, deco_block=1, trial_spawner=1},
	is_ground_content = false,
	drop = "",

	-- If placed by player, setup spawner with default settings
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" or not placer or not placer:is_player() then
			return itemstack
		end

		local rc = vlf_util.call_on_rightclick(itemstack, placer, pointed_thing)
		if rc then return rc end

		local name = placer:get_player_name()
		local privs = minetest.get_player_privs(name)
		if not privs.maphack then
			minetest.chat_send_player(name, "Placement denied. You need the “maphack” privilege to place mob spawners.")
			return itemstack
		end
		local node_under = minetest.get_node(pointed_thing.under)
		local new_itemstack, success = minetest.item_place(itemstack, placer, pointed_thing)
		if success then
			local placepos
			local def = minetest.registered_nodes[node_under.name]
			if def and def.buildable_to then
				placepos = pointed_thing.under
			else
				placepos = pointed_thing.above
			end
			vlf_trialspawners.setup_spawner(placepos)
		end
		return new_itemstack
	end,

	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		if not clicker:is_player() then return end
		if minetest.get_item_group(itemstack:get_name(),"spawn_egg") == 0 then return end
		local name = clicker:get_player_name()
		local privs = minetest.get_player_privs(name)
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return itemstack
		end
		if not privs.maphack then
			minetest.chat_send_player(name, S("You need the “maphack” privilege to change the mob spawner."))
			return itemstack
		end

		vlf_trialspawners.setup_spawner(pos, itemstack:get_name())

		if not minetest.is_creative_enabled(name) then
			itemstack:take_item()
		end
		return itemstack
	end,

	sounds = vlf_sounds.node_sound_metal_defaults(),

	_vlf_blast_resistance = 5,
	_vlf_hardness = 5,
})

minetest.register_node("vlf_trialspawners:active_spawner", {
	tiles = {"mob_spawner.png"},
	drawtype = "glasslike",
	paramtype = "light",
	description = S("Active Trial Spawner"),
	_tt_help = S("Makes mobs appear"),
	_doc_items_longdesc = S("A mob spawner regularily causes mobs to appear around it while a player is nearby. Some mob spawners are disabled while in light."),
	_doc_items_usagehelp = S("If you have a spawn egg, you can use it to change the mob to spawn. Just place the item on the mob spawner. Player-set mob spawners always spawn mobs regardless of the light level."),
	groups = {pickaxey=1, material_stone=1, deco_block=1},
	is_ground_content = false,
	drop = "",

	-- If placed by player, setup spawner with default settings
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" or not placer or not placer:is_player() then
			return itemstack
		end

		local rc = vlf_util.call_on_rightclick(itemstack, placer, pointed_thing)
		if rc then return rc end

		local name = placer:get_player_name()
		local privs = minetest.get_player_privs(name)
		if not privs.maphack then
			minetest.chat_send_player(name, "Placement denied. You need the “maphack” privilege to place mob spawners.")
			return itemstack
		end
		local node_under = minetest.get_node(pointed_thing.under)
		local new_itemstack, success = minetest.item_place(itemstack, placer, pointed_thing)
		if success then
			local placepos
			local def = minetest.registered_nodes[node_under.name]
			if def and def.buildable_to then
				placepos = pointed_thing.under
			else
				placepos = pointed_thing.above
			end
			vlf_trialspawners.setup_spawner(placepos)
		end
		return new_itemstack
	end,

	on_destruct = function(pos)
		-- Remove doll (if any)
		local obj = find_doll(pos)
		if obj then
			obj:remove()
		end
		vlf_experience.throw_xp(pos, math.random(15, 43))
	end,

	on_punch = function(pos)
		respawn_doll(pos)
	end,

	on_timer = spawn_mobs,

	sounds = vlf_sounds.node_sound_metal_defaults(),

	_vlf_blast_resistance = 5,
	_vlf_hardness = 5,
})

-- Mob spawner doll (rotating icon inside cage)

local doll_def = {
	initial_properties = {
		hp_max = 1,
		physical = false,
		pointable = false,
		visual = "mesh",
		makes_footstep_sound = false,
		automatic_rotate = math.pi * 2.9,
	},
	timer = 0,
	_mob = default_mob, -- name of the mob this doll represents
}

doll_def.get_staticdata = function(self)
	return self._mob
end

doll_def.on_activate = function(self, staticdata, dtime_s)
	local mob = staticdata
	if mob == "" or mob == nil then
		mob = default_mob
	end
	set_doll_properties(self.object, mob)
	self.object:set_velocity({x=0, y=0, z=0})
	self.object:set_acceleration({x=0, y=0, z=0})
	self.object:set_armor_groups({immortal=1})

end

doll_def.on_step = function(self, dtime)
	-- Check if spawner is still present. If not, delete the entity
	self.timer = self.timer + dtime
	local n = minetest.get_node_or_nil(self.object:get_pos())
	if self.timer > 1 then
		if n and n.name and n.name ~= "vlf_trialspawners:spawner" then
			self.object:remove()
		end
	end
end

doll_def.on_punch = function(self, hitter) end

minetest.register_entity("vlf_trialspawners:doll", doll_def)

-- FIXME: Doll can get destroyed by /clearobjects
minetest.register_lbm({
	label = "Respawn mob spawner dolls",
	name = "vlf_trialspawners:respawn_entities",
	nodenames = { "vlf_trialspawners:spawner" },
	run_at_every_load = true,
	action = function(pos, node)
		respawn_doll(pos)
	end,
})

minetest.register_globalstep(function(dtime)
	for _, player in ipairs(minetest.get_connected_players()) do
		local pos = player:get_pos()
		local nodes = minetest.find_nodes_in_area(vector.subtract(pos, 4), vector.add(pos, 4), {"group:vault"})
		for _, node_pos in ipairs(nodes) do
			local node = minetest.get_node(node_pos)
			if minetest.get_item_group(node.name, "trial_spawner") == 1 then
				minetest.set_node(node_pos, {name="vlf_trialspawners:active_spawner"})
			end
		end
	end
end)]]

local S = minetest.get_translator(minetest.get_current_modname())

vlf_trialspawners = {}

local default_mob = "mobs_mc:pig"

local function get_mob_textures(mob)
	local list = minetest.registered_entities[mob].texture_list
	return type(list[1]) == "table" and list[1] or list
end

local function find_doll(pos)
	for _, obj in pairs(minetest.get_objects_inside_radius(pos, 0.5)) do
		if not obj:is_player() and obj:get_luaentity().name == "vlf_trialspawners:doll" then
			return obj
		end
	end
	return nil
end

local function spawn_doll(pos)
	return minetest.add_entity({x = pos.x, y = pos.y - 0.3, z = pos.z}, "vlf_trialspawners:doll")
end

local function set_doll_properties(doll, mob)
	local mobinfo = minetest.registered_entities[mob]
	if not mobinfo then return end
	local prop = {
		mesh = mobinfo.initial_properties.mesh,
		textures = get_mob_textures(mob),
		visual_size = {
			x = mobinfo.initial_properties.visual_size.x * 0.33333,
			y = mobinfo.initial_properties.visual_size.y * 0.33333,
		}
	}
	doll:set_properties(prop)
	doll:get_luaentity()._mob = mob
end

local function respawn_doll(pos)
	local meta = minetest.get_meta(pos)
	local mob = meta:get_string("Mob")
	local doll = find_doll(pos) or spawn_doll(pos)
	set_doll_properties(doll, mob)
	return doll
end

local function set_cooldown(pos)
	local meta = minetest.get_meta(pos)
	meta:set_string("state", "cooldown")
	minetest.set_node(pos, {name = "vlf_trialspawners:inactive_spawner"})
end

local function eject_rewards(pos)
	local meta = minetest.get_meta(pos)
	local rewards = meta:get_string("rewards") -- Assuming rewards are defined in meta
	local player_pos = vector.new(pos.x, pos.y + 1, pos.z) -- Adjust for item placement
	for _, item in ipairs(rewards) do
		minetest.add_item(player_pos, item)
	end
end

local function spawn_mobs(pos, elapsed)
	local meta = minetest.get_meta(pos)
	local state = meta:get_string("state")

	if state == "cooldown" then
		return
	end

	local mob = meta:get_string("Mob")
	local max_mobs = meta:get_int("MaxMobs")
	local total_spawned = meta:get_int("TotalSpawned")

	if total_spawned >= max_mobs then
		eject_rewards(pos)
		set_cooldown(pos)
		return
	end

	local players = minetest.get_objects_inside_radius(pos, 10)
	if #players == 0 then return end

	respawn_doll(pos)

	local air_nodes = minetest.find_nodes_in_area(
		{x = pos.x - 2, y = pos.y - 1, z = pos.z - 2},
		{x = pos.x + 2, y = pos.y + 1, z = pos.z + 2},
		{"air"}
	)

	for _, air_pos in ipairs(air_nodes) do
		if total_spawned < max_mobs then
			minetest.add_entity({x = air_pos.x, y = air_pos.y + 0.5, z = air_pos.z}, mob)
			total_spawned = total_spawned + 1
			meta:set_int("TotalSpawned", total_spawned)
		end
	end

	minetest.get_node_timer(pos):start(math.random(6, 15))
end

minetest.register_node("vlf_trialspawners:inactive_spawner", {
	tiles = {"mob_spawner.png"},
	description = S("Inactive Mob Spawner"),
	drawtype = "glasslike",
	groups = {dig_immediate = 3, trial_spawner=1},
	on_timer = spawn_mobs,
})

minetest.register_node("vlf_trialspawners:active_spawner", {
	tiles = {"mob_spawner.png"},
	description = S("Active Mob Spawner"),
	drawtype = "glasslike",
	groups = {dig_immediate = 3, trial_spawner=2},
	on_timer = spawn_mobs,
})

minetest.register_entity("vlf_trialspawners:doll", {
	initial_properties = {
		hp_max = 1,
		physical = false,
		pointable = false,
		visual = "mesh",
		makes_footstep_sound = false,
		automatic_rotate = math.pi * 2.9,
	},
	_mob = default_mob,
	on_activate = function(self, staticdata)
		set_doll_properties(self.object, staticdata or self._mob)
	end,
})

minetest.register_globalstep(function(dtime)
	for _, player in ipairs(minetest.get_connected_players()) do
		local pos = player:get_pos()
		local nodes = minetest.find_nodes_in_area(vector.subtract(pos, 4), vector.add(pos, 4), {"group:trial_spawner"})
		for _, node_pos in ipairs(nodes) do
			local node = minetest.get_node(node_pos)
			if node.name == "vlf_trialspawners:inactive_spawner" then
				minetest.set_node(node_pos, {name = "vlf_trialspawners:active_spawner"})
			end
		end
	end
end)

