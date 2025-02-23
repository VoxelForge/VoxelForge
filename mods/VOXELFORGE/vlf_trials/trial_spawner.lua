local S = minetest.get_translator(minetest.get_current_modname())

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
	for obj in minetest.objects_inside_radius(pos, 0.5) do
		if not obj:is_player() then
			if obj and obj:get_luaentity().name == "vlf_trials:doll" then
				return obj
			end
		end
	end
end

local function spawn_doll(pos)
	return minetest.add_entity({x=pos.x, y=pos.y-0.3, z=pos.z}, "vlf_trials:doll")
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

function vlf_trials.setup_spawner(pos, Mob, MinLight, MaxLight, MaxMobsInArea, MaxMobs, SpawnedMobs, PlayerDistance, YOffset, SpawnInterval, MAPP, MMIAAPP)
    local dim = mcl_worlds.pos_to_dimension(pos)
    Mob = Mob or default_mob
    local mn, mx = mcl_mobs.get_mob_light_level(Mob, dim)
    MinLight = MinLight or 0
    MaxLight = MaxLight or 14
    MaxMobsInArea = MaxMobsInArea or 2
    MaxMobs = MaxMobs or 6
    SpawnedMobs = SpawnedMobs or 0
    PlayerDistance = PlayerDistance or 15
    YOffset = YOffset or 0
    SpawnInterval = SpawnInterval or 2
    MAPP = MAPP or 2
    MMIAAPP = MMIAAPP or 1
	local meta = minetest.get_meta(pos)
    meta:set_string("Mob", Mob)
    meta:set_int("MinLight", MinLight)
    meta:set_int("MaxLight", MaxLight)
    meta:set_int("MaxMobsInArea", MaxMobsInArea)
    meta:set_int("SpawnedMobs", SpawnedMobs)
    meta:set_int("MaxMobs", MaxMobs)
    meta:set_int("PlayerDistance", PlayerDistance)
    meta:set_int("YOffset", YOffset)
    meta:set_int("SpawnInterval", SpawnInterval)
    meta:set_string("Ominous", "false")
	meta:set_int("MaxAddPerPlayer", MAPP)
    meta:set_int("MaxMobsInAreaAddPerPlayer", MMIAAPP)

    local doll = find_doll(pos)
    if not doll then
        doll = spawn_doll(pos)
    end
    set_doll_properties(doll, Mob)

    local t = minetest.get_node_timer(pos)
    t:start(2)
end

local function check_player_proximity_and_los(pos)
    local meta = minetest.get_meta(pos)
    local mob = meta:get_string("Mob")

    local doll = find_doll(pos)
    if doll then
    doll:remove()
    end
        doll = spawn_doll(pos)
    set_doll_properties(doll, mob)

    local players = minetest.get_connected_players()

    for _, player in ipairs(players) do
        local player_pos = player:get_pos()
        player_pos.y = player_pos.y + 1.625 -- Adjust for player eye height

        local distance = vector.distance(pos, player_pos)
        if distance <= 14 then

            local direction = vector.normalize(vector.subtract(player_pos, pos))
            local has_los = true

            -- Iterate through each node along the line from pos to player_pos
            local step = 1
            for i = 1, math.floor(distance) do  -- Start at 1 to skip the origin position
                local check_pos = vector.add(pos, vector.multiply(direction, i * step))
                local node = minetest.get_node(check_pos)
                local node_def = minetest.registered_nodes[node.name]

                if node_def and node_def.walkable and node_def.drawtype ~= "airlike" then
                    has_los = false
                    break
                end
            end

            if has_los then
                if mcl_potions.has_effect(player, "bad_omen") then
                    local lv = mcl_potions.get_effect_level(player, "bad_omen")
                    mcl_potions.clear_effect(player, "bad_omen")
                    mcl_potions.give_effect("trial_omen", player, 0, tonumber(lv) * 900)
                    meta:set_string("Ominous", "true")
                    minetest.sound_play("trial_spawner_detect_player1", {pos = pos, gain = 1, max_hear_distance = 14})
                    local activate = {
						amount = 10,
						texpool = {
							{
								name = "ominous_trial_spawner_detection.png",
								animation = {type = "vertical_frames", aspect_w = 8, aspect_h = 8, length = 0.78},
							}
						},
						time = 1,
						minvel = vector.new(0.0, 1.5, 0.0),
						maxvel = vector.new(0.0, 2.5, 0.0),
						minexptime = 1.0,
						maxexptime = 1.25,
						minsize = 2,
						maxsize= 4.75,
						glow = 10,
						collisiondetection = true,
						collision_removal = false,
						vertical = true,
					}
					local minpos = vector.offset(pos, -0.5, -0.0, -0.5)
					local maxpos = vector.offset(pos, 0.5, 1, 0.5)
					minetest.add_particlespawner(table.merge(activate, {
						minpos = minpos,
						maxpos = maxpos,
					}))
					local playerposmin = vector.offset(player:get_pos(), -0.5, 0.0, -0.5)
					local playerposmax = vector.offset(player:get_pos(), 0.5, 0.0, 0.5)
					minetest.add_particlespawner(table.merge(activate, {
						minpos = playerposmin,
						maxpos = playerposmax,
						minvel = vector.new(0.0, 1.5, 0.0),
						maxvel = vector.new(0.0, 2.5, 0.0),
					}))
					minetest.add_particlespawner({
						amount = 15,
						time = 1,
						minpos = {x=player:get_pos().x-0.5,y=player:get_pos().y-0.5,z=player:get_pos().z-0.5},
						maxpos = {x=player:get_pos().x+0.5,y=player:get_pos().y+0.5,z=player:get_pos().z+0.5},
						minvel = {x = -0.0, y = -0.0, z = -0.0},
						maxvel = {x = 0.0, y = 0.0, z = 0.0},
						minacc = {x = 0, y = 0, z = 0},
						maxacc = {x = 0, y = 0, z = 0},
						minexptime = 0.8,
						maxexptime = 0.8,
						minsize = 0.4,
						maxsize = 1.2,
						collisiondetection = true,
						collision_removal = false,
						vertical = false,
						texture = "vlf_particles_soul_flame.png",
						glow = 10,
					})
                    minetest.swap_node(pos, { name = "vlf_trials:ominous_spawner_active" })
                elseif mcl_potions.has_effect(player, "trial_omen") then
                    meta:set_string("Ominous", "true")
                    minetest.sound_play("trial_spawner_detect_player1", {pos = pos, gain = 1, max_hear_distance = 14})
                    minetest.swap_node(pos, { name = "vlf_trials:ominous_spawner_active" })
                    local activate = {
						amount = 10,
						texpool = {
							{
								name = "ominous_trial_spawner_detection.png",
								animation = {type = "vertical_frames", aspect_w = 8, aspect_h = 8, length = 0.78},
							}
						},
						time = 1,
						minvel = vector.new(0.0, 1.5, 0.0),
						maxvel = vector.new(0.0, 2.5, 0.0),
						minexptime = 1.0,
						maxexptime = 1.25,
						minsize = 2,
						maxsize= 4.75,
						glow = 10,
						collisiondetection = true,
						collision_removal = false,
						vertical = true,
					}
					local minpos = vector.offset(pos, -0.5, -0.0, -0.5)
					local maxpos = vector.offset(pos, 0.5, 1, 0.5)
					minetest.add_particlespawner(table.merge(activate, {
						minpos = minpos,
						maxpos = maxpos,
					}))
					local playerposmin = vector.offset(player:get_pos(), -0.8, 0.5, -0.8)
					local playerposmax = vector.offset(player:get_pos(), 0.8, 1.5, 0.8)
					minetest.add_particlespawner(table.merge(activate, {
						minpos = playerposmin,
						maxpos = playerposmax,
						minvel = vector.new(0.0, 1.5, 0.0),
						maxvel = vector.new(0.0, 2.5, 0.0),
					}))
					minetest.add_particlespawner({
						amount = 15,
						time = 1,
						minpos = {x=player:get_pos().x-0.8,y=player:get_pos().y+1.5,z=player:get_pos().z-0.8},
						maxpos = {x=player:get_pos().x+0.8,y=player:get_pos().y+2,z=player:get_pos().z+0.8},
						minvel = {x = -0.0, y = -0.0, z = -0.0},
						maxvel = {x = 0.0, y = 0.0, z = 0.0},
						minacc = {x = 0, y = 0, z = 0},
						maxacc = {x = 0, y = 0, z = 0},
						minexptime = 0.8,
						maxexptime = 0.8,
						minsize = 0.4,
						maxsize = 1.2,
						collisiondetection = true,
						collision_removal = false,
						vertical = false,
						texture = "vlf_particles_soul_flame.png",
						glow = 10,
					})
                else
                	minetest.sound_play("trial_spawner_detect_player1", {pos = pos, gain = 1, max_hear_distance = 14})
                    minetest.swap_node(pos, { name = "vlf_trials:spawner_active" })
                    local activate = {
						amount = 10,
						texpool = {
							{
								name = "trial_spawner_detection.png",
								animation = {type = "vertical_frames", aspect_w = 8, aspect_h = 8, length = 0.78},
							}
						},
						time = 1,
						minvel = vector.new(0.0, 1.5, 0.0),
						maxvel = vector.new(0.0, 2.5, 0.0),
						minexptime = 1.0,
						maxexptime = 1.25,
						minsize = 2,
						maxsize= 4.75,
						glow = 10,
						collisiondetection = true,
						collision_removal = false,
						vertical = true,
					}
					local minpos = vector.offset(pos, -0.5, -0.0, -0.5)
					local maxpos = vector.offset(pos, 0.5, 1, 0.5)
					minetest.add_particlespawner(table.merge(activate, {
						minpos = minpos,
						maxpos = maxpos,
					}))
                end
            else
            end
        end
    end
    
	minetest.add_particlespawner({
		amount = 20,  -- Number of particles
		time = 2,  -- Spawner lasts forever (0 means infinite)
		minpos = {x=pos.x-0.5,y=pos.y-0.5,z=pos.z-0.5},
		maxpos = {x=pos.x+0.5,y=pos.y+0.5,z=pos.z+0.5},
		minvel = {x = -0.0, y = -0.0, z = -0.0},
		maxvel = {x = 0.0, y = 0.0, z = 0.0},
		minacc = {x = 0, y = 0, z = 0},
		maxacc = {x = 0, y = 0, z = 0},
		minexptime = 0.8,
		maxexptime = 0.8,
		minsize = 0.4,
		maxsize = 1.2,
		collisiondetection = true,
		collision_removal = false,
		vertical = false,
		texture = "voxelforge_flame.png",
		glow = 10,
	})

    minetest.get_node_timer(pos):start(2)
end

local function spawn_mobs(pos)
    local meta = minetest.get_meta(pos)
    local mob = meta:get_string("Mob")
    meta:set_int("MinLight", 0)
    meta:set_int("MaxLight", 12)
    local mlig = meta:get_int("MinLight")
    local xlig = meta:get_int("MaxLight")
    local numm = meta:get_int("MaxMobsInArea")
    local maxxx = meta:get_int("MaxMobs")
    local spawned = meta:get_int("SpawnedMobs")
    local yof = meta:get_int("YOffset")
    local spawn_interval = meta:get_int("SpawnInterval")
    local Ominous = meta:get_string("Ominous")
    local max_per_player = meta:get_int("MaxAddPerPlayer")
    local region_per_player = meta:get_int("MaxMobsInAreaAddPerPlayer")

    -- Count nearby players and check for effects
    local players_nearby = 0
    local bad_omen = false
    local trial_omen = false
    for _, player in pairs(minetest.get_connected_players()) do
        if player:get_pos():distance(pos) <= 14 then
            players_nearby = players_nearby + 1
            if mcl_potions.has_effect(player, "bad_omen") and Ominous ~= "true" then
                bad_omen = true
                local lv = mcl_potions.get_effect_level(player, "bad_omen")
                mcl_potions.clear_effect(player, "bad_omen")
				mcl_potions.give_effect("trial_omen", player, 0, tonumber(lv) * 900)
            elseif mcl_potions.has_effect(player, "trial_omen")  and Ominous ~= "true" then
            	trial_omen = true
            end
        end
    end
    
    local doll = find_doll(pos)
    if not doll then
        doll = spawn_doll(pos)
        set_doll_properties(doll, mob)
    end

    -- Adjust mob limits based on player count and mobs_per_player meta
    local maxx = Ominous == "true" and (maxxx * 2 + players_nearby * max_per_player) or (maxxx + players_nearby * max_per_player)
    local num = Ominous == "true" and (numm + 1 + players_nearby * region_per_player) or (numm + players_nearby * region_per_player)

    -- Clear mobs and convert to ominous variant if bad omen or trial omen is detected
    if bad_omen or trial_omen then
        for obj in minetest.objects_inside_radius(pos, 20) do
            local ent = obj:get_luaentity()
            if ent and ent.name == mob then
                obj:remove()
            end
        end
        meta:set_string("Ominous", "true")
        minetest.swap_node(pos, { name = "vlf_trials:ominous_spawner_active" })
        maxx = maxxx * 2 + players_nearby * max_per_player
        num = numm + 1 + players_nearby * region_per_player
    end

    if num == 0 or not mcl_mobs.spawning_mobs[mob] then return end

    local count = 0
    for obj in minetest.objects_inside_radius(pos, 18) do
        local ent = obj:get_luaentity()
        if ent and ent.name == mob and ent.origin_pos == pos then
            count = count + 1
        end
    end
    
    -- Every 8 cycles, add an ominous item spawner above
        local cycle_count = meta:get_int("CycleCount") or 0
        if players_nearby > 0 and cycle_count == 1  then
            local choice = math.random(0, 1)  -- Randomly pick mob or player
            local spawn_pos
            if choice == 0 then
                -- Pick a random summoned mob position
                for obj in minetest.objects_inside_radius(pos, 14) do
                    local ent = obj:get_luaentity()
                    if ent and ent.name == mob then
                        spawn_pos = obj:get_pos()
                        break
                    end
                end
            else
                -- Pick player position
                for _, player in pairs(minetest.get_connected_players()) do
                    if player:get_pos():distance(pos) <= 14 then
                        spawn_pos = player:get_pos()
                        break
                    end
                end
            end

            if spawn_pos and Ominous == "true" then
                spawn_pos.y = spawn_pos.y + 5  -- Place the item spawner slightly above
                minetest.add_entity(spawn_pos, "vlf_trials:ominous_item_spawner")
            end
        end

    if count >= num then
        minetest.get_node_timer(pos):start(spawn_interval)
        return
    end

    local air = minetest.find_nodes_in_area(
        {x = pos.x - 2, y = pos.y - 1 + yof, z = pos.z - 2},
        {x = pos.x + 2, y = pos.y + 1 + yof, z = pos.z + 2},
        {"air"}
    )

    if air and #air > 0 then
        for _ = 1, math.min(num - count, maxx - spawned) do
            local air_index = math.random(#air)
            local pos2 = air[air_index]
            local lig = minetest.get_node_light(pos2) or 0
            pos2.y = pos2.y + 0.5

            if lig >= mlig and lig <= xlig then
            	if Ominous == "true" then
            	
            	minetest.add_particlespawner({
					amount = 15,
					time = 1,
					minpos = {x=pos2.x-0.5,y=pos2.y-0.5,z=pos2.z-0.5},
					maxpos = {x=pos2.x+0.5,y=pos2.y+0.5,z=pos2.z+0.5},
					minvel = {x = -0.0, y = -0.0, z = -0.0},
					maxvel = {x = 0.0, y = 0.0, z = 0.0},
					minacc = {x = 0, y = 0, z = 0},
					maxacc = {x = 0, y = 0, z = 0},
					minexptime = 0.8,
					maxexptime = 0.8,
					minsize = 0.4,
					maxsize = 1.2,
					collisiondetection = true,
					collision_removal = false,
					vertical = false,
					texture = "vlf_particles_soul_flame.png",
					glow = 10,
				})
				
				else
            	
            	minetest.add_particlespawner({
					amount = 15,
					time = 1,
					minpos = {x=pos2.x-0.5,y=pos2.y-0.5,z=pos2.z-0.5},
					maxpos = {x=pos2.x+0.5,y=pos2.y+0.5,z=pos2.z+0.5},
					minvel = {x = -0.0, y = -0.0, z = -0.0},
					maxvel = {x = 0.0, y = 0.0, z = 0.0},
					minacc = {x = 0, y = 0, z = 0},
					maxacc = {x = 0, y = 0, z = 0},
					minexptime = 0.8,
					maxexptime = 0.8,
					minsize = 0.4,
					maxsize = 1.2,
					collisiondetection = true,
					collision_removal = false,
					vertical = false,
					texture = "voxelforge_flame.png",
					glow = 10,
				})
				end
				minetest.sound_play("trial_spawner_spawn", {pos = pos2, gain = 0.3, max_hear_distance = 14})
                local entity = minetest.add_entity(pos2, mob)
                local luaentity = entity:get_luaentity()
                luaentity.origin_pos = pos
                meta:set_int("SpawnedMobs", spawned + 1)
            end
            table.remove(air, air_index)
        end
    end
    
     if meta:get_int("SpawnedMobs") == maxx and count == 0 then
        if meta:get_string("Ominous") == "true" then
        	minetest.sound_play("trial_spawner_open_shutter", {pos = pos, gain = 1, max_hear_distance = 7})
            minetest.swap_node(pos, {name = "vlf_trials:ominous_spawner_ejecting"})
        else
        	minetest.sound_play("trial_spawner_open_shutter", {pos = pos, gain = 1, max_hear_distance = 7})
            minetest.swap_node(pos, {name = "vlf_trials:spawner_ejecting"})
        end
    end
    if meta:get_int("CycleCount") < 8 then
		meta:set_int("CycleCount", meta:get_int("CycleCount") + 1)
	else
		meta:set_int("Cycle_Count", 1)
	end
	if meta:get_string("Ominous") == "true" then
	minetest.add_particlespawner({
		amount = 20 * spawn_interval,  -- Number of particles
		time = spawn_interval,  -- Spawner lasts forever (0 means infinite)
		minpos = {x=pos.x-0.5,y=pos.y-0.5,z=pos.z-0.5},
		maxpos = {x=pos.x+0.5,y=pos.y+0.5,z=pos.z+0.5},
		minvel = {x = -0.0, y = -0.0, z = -0.0},
		maxvel = {x = 0.0, y = 0.0, z = 0.0},
		minacc = {x = 0, y = 0, z = 0},
		maxacc = {x = 0, y = 0, z = 0},
		minexptime = 0.8,
		maxexptime = 0.8,
		minsize = 0.4,
		maxsize = 1.2,
		texture = "vlf_particles_soul_flame.png",
		glow = 10,
	})
	else
	minetest.add_particlespawner({
		amount = 20 * spawn_interval,  -- Number of particles
		time = spawn_interval,  -- Spawner lasts forever (0 means infinite)
		minpos = {x=pos.x-0.5,y=pos.y-0.5,z=pos.z-0.5},
		maxpos = {x=pos.x+0.5,y=pos.y+0.5,z=pos.z+0.5},
		minvel = {x = -0.0, y = -0.0, z = -0.0},
		maxvel = {x = 0.0, y = 0.0, z = 0.0},
		minacc = {x = 0, y = 0, z = 0},
		maxacc = {x = 0, y = 0, z = 0},
		minexptime = 0.8 * spawn_interval,
		maxexptime = 0.8 * spawn_interval,
		minsize = 0.4,
		maxsize = 1.2,
		texture = "voxelforge_flame.png",
		glow = 10,
	})
	end
    minetest.get_node_timer(pos):start(spawn_interval)
end



local function eject_loot(pos)
    local meta = minetest.get_meta(pos)
    local Ominous = meta:get_string("Ominous")

    local doll = find_doll(pos)
    if not doll then
        doll = spawn_doll(pos)
        set_doll_properties(doll, mob)
    end

    local players = minetest.get_connected_players()

    -- Determine the resource pool to use
    local resource_pool 
    if Ominous == "true" then
    	resource_pool = math.random() < 0.3 and "key" or "consumables"
    else
    	resource_pool = math.random() < 0.5 and "key" or "consumables"
    end
    minetest.chat_send_all("Selected resource pool: " .. resource_pool)

    for _, player in ipairs(players) do
        local player_pos = player:get_pos()

        -- Check if player is within 14 blocks
        if vector.distance(pos, player_pos) <= 14 then
            minetest.chat_send_all("Player within range, fetching resource...")

            -- Fetch the resource using vl_datapacks.get_resource
            local resource 
            if Ominous == "true" then 
            	resource = vl_datapacks.get_resource("loot_table", "vanilla:spawners/ominous/trial_chamber/" .. resource_pool)
            else
            	resource = vl_datapacks.get_resource("loot_table", "vanilla:spawners/trial_chamber/" .. resource_pool)
            end
            if resource then
                minetest.chat_send_all("Resource loaded for player " .. player:get_player_name() .. ": " .. minetest.serialize(resource))
                local loot_stacks = vl_loot.engine.get_loot(resource, {})
                for _, itemstack in ipairs(loot_stacks) do
                    -- Drop each item at the player's position
                    minetest.sound_play("trial_spawner_eject_item", {pos = pos, gain = 1, max_hear_distance = 10})
                    minetest.add_item({x=pos.x,y=pos.y+1,z=pos.z}, itemstack)
                end
            else
                minetest.chat_send_all("Failed to load resource: " .. resource_pool)
            end
        end
    end
    if Ominous == "true" then
    	minetest.after(1, function()
    		minetest.sound_play("trial_spawner_close_shutter", {pos = pos, gain = 1, max_hear_distance = 10})
    		minetest.swap_node(pos, {name = "vlf_trials:ominous_spawner_cooldown"})
    	end)
    else
    	minetest.after(1, function()
    		minetest.sound_play("trial_spawner_close_shutter", {pos = pos, gain = 1, max_hear_distance = 10})
			minetest.swap_node(pos, {name = "vlf_trials:spawner_cooldown"})
		end)
	end
	
	local smoke_particlespawner = {
		amount = 1000,
		texture = "",
		texpool = {
			{
				name = "vlf_particles_generic.png^[colorize:#2c2c2c:255",
				animation = {type = "vertical_frames", aspect_w = 8, aspect_h = 8, length = 0.78},
			},
			{
				name = "vlf_particles_generic.png^[colorize:#424242:255",
				animation = {type = "vertical_frames", aspect_w = 8, aspect_h = 8, length = 0.78},
			},
			{
				name = "vlf_particles_generic.png^[colorize:#0f0f0f:255",
				animation = {type = "vertical_frames", aspect_w = 8, aspect_h = 8, length = 0.78},
			}
		},
		time = 900,
		minvel = vector.zero(),
		maxvel = vector.zero(),
		minacc = vector.new(0.0, 0.5, 0.0),
		maxacc = vector.new(0.0, 0.9, 0.0),
		minexptime = 2.0,
		maxexptime = 2.25,
		minsize = 1,
		maxsize= 1.75,
		glow = 1,
		collisiondetection = true,
		collision_removal = true,
	}
	local minpos = vector.offset(pos, -0.05, -0.0, -0.05)
	local maxpos = vector.offset(pos, 0.05, 0.1, 0.05)
	minetest.add_particlespawner(table.merge(smoke_particlespawner, {
		minpos = minpos,
		maxpos = maxpos,
	}))

    minetest.get_node_timer(pos):start(1800)
end

local function leave_cooldown(pos)
	local meta = minetest.get_meta(pos)
	meta:set_int("SpawnedMobs", 0)
	meta:set_string("Ominous", "false")
	minetest.swap_node(pos, {name = "vlf_trials:spawner_inactive"})
	minetest.get_node_timer(pos):start(1)
end

local function create_spawner_def(base_def, extra_def)
    return table.merge(base_def, extra_def)
end

local base_spawner_def = {
    drawtype = "allfaces",
    paramtype = "light",
    description = S("Trial Spawner"),
    groups = {pickaxey = 1, material_stone = 1, deco_block = 1, unmovable_by_piston = 1},
    is_ground_content = false,
    drop = "",
    
    	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" or not placer or not placer:is_player() then
			return itemstack
		end

		local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
		if rc then return rc end

		local name = placer:get_player_name()
		local privs = minetest.get_player_privs(name)
		if not privs.maphack then
			minetest.chat_send_player(name, "Placement denied. You need the “maphack” privilege to place mob spawners.")
			return itemstack
		end
		local node_under = minetest.get_node(pointed_thing.under)
		local new_itemstack, success = minetest.item_place_node(itemstack, placer, pointed_thing)
		if success then
			local placepos
			local def = minetest.registered_nodes[node_under.name]
			if def and def.buildable_to then
				placepos = pointed_thing.under
			else
				placepos = pointed_thing.above
			end
			vlf_trials.setup_spawner(placepos)
		end
		return new_itemstack
	end,

	on_rightclick = function(pos, _, clicker, itemstack, _)
		if not clicker:is_player() then return itemstack end
		if minetest.get_item_group(itemstack:get_name(),"spawn_egg") == 0 then return itemstack end
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

		vlf_trials.setup_spawner(pos, itemstack:get_name())

		if not minetest.is_creative_enabled(name) then
			itemstack:take_item()
		end
		return itemstack
	end,
	
	on_construct = function(pos, node)
		vlf_trials.setup_spawner(pos)
	end,

    on_destruct = function(pos)
        local obj = find_doll(pos)
        if obj then obj:remove() end
        mcl_experience.throw_xp(pos, math.random(15, 43))
    end,

    on_punch = function(pos)
        respawn_doll(pos)
    end,
    
        on_blast = function()
        end,
    sounds = mcl_sounds.node_sound_metal_defaults(),
    _mcl_blast_resistance = 50,
    _mcl_hardness = 50,
}

local spawner_states = {
    inactive = {tiles = {"trial_spawner_top_inactive.png", "trial_spawner_bottom.png", "trial_spawner_side_inactive.png"}, light_source = 4, on_timer = function(pos) check_player_proximity_and_los(pos) end},
    active = {tiles = {"trial_spawner_top_active.png", "trial_spawner_bottom.png", "trial_spawner_side_active.png"}, light_source = 8, groups = {not_in_creative_inventory=1}, on_timer = function(pos) spawn_mobs(pos) end},
    ejecting = {tiles = {"trial_spawner_top_ejecting_reward.png", "trial_spawner_bottom.png", "trial_spawner_side_active.png"}, light_source = 8, groups = {not_in_creative_inventory=1}, on_timer = function(pos) eject_loot(pos) end},
    cooldown = {tiles = {"trial_spawner_top_inactive.png", "trial_spawner_bottom.png", "trial_spawner_side_inactive.png"}, light_source = 4, groups = {not_in_creative_inventory=1}, on_timer = function(pos) leave_cooldown(pos) end},
}

local ominous_spawner_states = {
    active = {tiles = {"trial_spawner_top_active_ominous.png", "trial_spawner_bottom.png", "trial_spawner_side_active_ominous.png"}, light_source = 8, groups = {not_in_creative_inventory=1}, on_timer = function(pos) spawn_mobs(pos) end},
    ejecting = {tiles = {"trial_spawner_top_ejecting_reward_ominous.png", "trial_spawner_bottom.png", "trial_spawner_side_active_ominous.png"}, light_source = 8, groups = {not_in_creative_inventory=1}, on_timer = function(pos) eject_loot(pos) end},
    cooldown = {tiles = {"trial_spawner_top_inactive_ominous.png", "trial_spawner_bottom.png", "trial_spawner_side_inactive_ominous.png"}, light_source = 4, groups = {not_in_creative_inventory=1}, on_timer = function(pos) leave_cooldown(pos) end},
}
minetest.register_node("vlf_trials:spawner_inactive", create_spawner_def(base_spawner_def, spawner_states.inactive))
minetest.register_node("vlf_trials:spawner_active", create_spawner_def(base_spawner_def, spawner_states.active))
minetest.register_node("vlf_trials:spawner_ejecting", create_spawner_def(base_spawner_def, spawner_states.ejecting))
minetest.register_node("vlf_trials:spawner_cooldown", create_spawner_def(base_spawner_def, spawner_states.cooldown))
minetest.register_node("vlf_trials:ominous_spawner_active", create_spawner_def(base_spawner_def, ominous_spawner_states.active))
minetest.register_node("vlf_trials:ominous_spawner_ejecting", create_spawner_def(base_spawner_def, ominous_spawner_states.ejecting))
minetest.register_node("vlf_trials:ominous_spawner_cooldown", create_spawner_def(base_spawner_def, ominous_spawner_states.cooldown))


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
	_mcl_pistons_unmovable = true
}

doll_def.get_staticdata = function(self)
	return self._mob
end

doll_def.on_activate = function(self, staticdata)
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
	--local n = minetest.get_node_or_nil(self.object:get_pos())
	local n = minetest.get_node(self.object:get_pos())
	if self.timer > 1 then
		if n and n.name and (n.name ~= "vlf_trials:spawner_inactive" and n.name ~= "vlf_trials:spawner_active" and n.name ~= "vlf_trials:spawner_ejecting" and n.name ~= "vlf_trials:spawner_cooldown" and n.name ~= "vlf_trials:ominous_spawner_active" and n.name ~= "vlf_trials:ominous_spawner_ejecting" and n.name ~= "vlf_trials:ominous_spawner_cooldown") then
		--if n and n.name and n.name ~= "vlf_trials:spawner_active" then
			self.object:remove()
		end
	end
end

doll_def.on_punch = function() end

minetest.register_entity("vlf_trials:doll", doll_def)

-- FIXME: Doll can get destroyed by /clearobjects
minetest.register_lbm({
	label = "Respawn mob spawner dolls",
	name = "vlf_trials:respawn_entities",
	nodenames = { "vlf_trials:spawner_inactive", "vlf_trials:spawner_active", "vlf_trials:spawner_ejecting", "vlf_trials:spawner_cooldown", "vlf_trials:ominous_spawner_active", "vlf_trials:ominous_spawner_ejecting", "vlf_trials:ominous_spawner_cooldown" },
	run_at_every_load = true,
	action = function(pos)
		respawn_doll(pos)
	end,
})
