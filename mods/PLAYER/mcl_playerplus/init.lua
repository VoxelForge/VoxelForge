local time = 0

minetest.register_globalstep(function(dtime)

	time = time + dtime
	-- Run the rest of the code every 0.5 seconds
	if time < 0.5 then
		return
	end

	-- reset time for next check
	-- FIXME: Make sure a regular check interval applies
	time = 0

	-- check players
	for _,player in pairs(minetest.get_connected_players()) do
		-- who am I?
		local name = player:get_player_name()

		-- where am I?
		local pos = player:get_pos()

		-- what is around me?
		local node_stand = mcl_player.players[player].nodes.stand
		local node_stand_below = mcl_player.players[player].nodes.stand_below
		local node_head = mcl_player.players[player].nodes.head
		local node_feet = mcl_player.players[player].nodes.feet
		local node_head_top = mcl_player.players[player].nodes.head_top
		if not node_stand or not node_stand_below or not node_head or not node_feet or not node_head_top then
			return
		end

		-- Standing on soul sand? If so, walk slower (unless player wears Soul Speed boots)
		if node_stand == "mcl_nether:soul_sand" then
			-- TODO: Tweak walk speed
			-- TODO: Also slow down mobs
			-- Slow down even more when soul sand is above certain block
			local boots = player:get_inventory():get_stack("armor", 5)
			local soul_speed = mcl_enchanting.get_enchantment(boots, "soul_speed")
			if soul_speed > 0 then
				playerphysics.add_physics_factor(player, "speed", "mcl_playerplus:surface", soul_speed * 0.105 + 1.3)
			else
				if node_stand_below == "mcl_core:ice" or node_stand_below == "mcl_core:packed_ice" or node_stand_below == "mcl_core:slimeblock" or node_stand_below == "mcl_core:water_source" then
					playerphysics.add_physics_factor(player, "speed", "mcl_playerplus:surface", 0.1)
				else
					playerphysics.add_physics_factor(player, "speed", "mcl_playerplus:surface", 0.4)
				end
			end
		elseif minetest.get_item_group(node_feet, "liquid") ~= 0 and mcl_enchanting.get_enchantment(player:get_inventory():get_stack("armor", 5), "depth_strider") then
			local boots = player:get_inventory():get_stack("armor", 5)
			local depth_strider = mcl_enchanting.get_enchantment(boots, "depth_strider")

			if depth_strider > 0 then
				playerphysics.add_physics_factor(player, "speed", "mcl_playerplus:surface", (depth_strider / 3) + 0.75)
			end
		else
			playerphysics.remove_physics_factor(player, "speed", "mcl_playerplus:surface")
		end

		-- Is player suffocating inside node? (Only for solid full opaque cube type nodes
		-- without group disable_suffocation=1)
		-- if swimming, check the feet node instead, because the head node will be above the player when swimming
		local ndef = minetest.registered_nodes[node_head]
		if mcl_player.players[player].is_swimming then
			ndef = minetest.registered_nodes[node_feet]
		end
		if (ndef.walkable == nil or ndef.walkable == true)
		and (ndef.collision_box == nil or ndef.collision_box.type == "regular")
		and (ndef.node_box == nil or ndef.node_box.type == "regular")
		and (ndef.groups.disable_suffocation ~= 1)
		and (ndef.groups.opaque == 1)
		and (node_head ~= "ignore")
		-- Check privilege, too
		and (not minetest.check_player_privs(name, {noclip = true})) then
			if player:get_hp() > 0 then
				mcl_util.deal_damage(player, 1, {type = "in_wall"})
			end
		end

		-- Am I near a cactus?
		local near = minetest.find_node_near(pos, 1, "mcl_core:cactus")
		if not near then
			near = minetest.find_node_near({x=pos.x, y=pos.y-1, z=pos.z}, 1, "mcl_core:cactus")
		end
		if near then
			-- Am I touching the cactus? If so, it hurts
			local dist = vector.distance(pos, near)
			local dist_feet = vector.distance({x=pos.x, y=pos.y-1, z=pos.z}, near)
			if dist < 1.1 or dist_feet < 1.1 then
				if player:get_hp() > 0 then
					mcl_util.deal_damage(player, 1, {type = "cactus"})
				end
			end
		end

		-- Underwater: Spawn bubble particles
		if minetest.get_item_group(node_head, "water") ~= 0 then
			minetest.add_particlespawner({
				amount = 10,
				time = 0.15,
				minpos = { x = -0.25, y = 0.3, z = -0.25 },
				maxpos = { x = 0.25, y = 0.7, z = 0.75 },
				attached = player,
				minvel = {x = -0.2, y = 0, z = -0.2},
				maxvel = {x = 0.5, y = 0, z = 0.5},
				minacc = {x = -0.4, y = 4, z = -0.4},
				maxacc = {x = 0.5, y = 1, z = 0.5},
				minexptime = 0.3,
				maxexptime = 0.8,
				minsize = 0.7,
				maxsize = 2.4,
				texture = "mcl_particles_bubble.png"
			})
		end

		-- Show positions of barriers when player is wielding a barrier
		local wi = player:get_wielded_item():get_name()
		if wi == "mcl_core:barrier" or wi == "mcl_core:realm_barrier" or minetest.get_item_group(wi, "light_block") ~= 0 then
			local pos = vector.round(player:get_pos())
			local r = 8
			local vm = minetest.get_voxel_manip()
			local emin, emax = vm:read_from_map({x=pos.x-r, y=pos.y-r, z=pos.z-r}, {x=pos.x+r, y=pos.y+r, z=pos.z+r})
			local area = VoxelArea:new{
				MinEdge = emin,
				MaxEdge = emax,
			}
			local data = vm:get_data()
			for x=pos.x-r, pos.x+r do
			for y=pos.y-r, pos.y+r do
			for z=pos.z-r, pos.z+r do
				local vi = area:indexp({x=x, y=y, z=z})
				local nodename = minetest.get_name_from_content_id(data[vi])
				local light_block_group = minetest.get_item_group(nodename, "light_block")

				local tex
				if nodename == "mcl_core:barrier" then
					tex = "mcl_core_barrier.png"
				elseif nodename == "mcl_core:realm_barrier" then
					tex = "mcl_core_barrier.png^[colorize:#FF00FF:127^[transformFX"
				elseif light_block_group ~= 0 then
					tex = "mcl_core_light_" .. (light_block_group - 1) .. ".png"
				end
				if tex then
					minetest.add_particle({
						pos = {x=x, y=y, z=z},
						expirationtime = 1,
						size = 8,
						texture = tex,
						glow = 14,
						playername = name
					})
				end
			end
			end
			end
		end

	end

end)

-- Don't change HP if the player falls in the water or through End Portal:
mcl_damage.register_modifier(function(obj, damage, reason)
	if reason.type == "fall" then
		local pos = obj:get_pos()
		local node = minetest.get_node(pos)
		local velocity = obj:get_velocity() or obj:get_player_velocity() or {x=0,y=-10,z=0}
		local v_axis_max = math.max(math.abs(velocity.x), math.abs(velocity.y), math.abs(velocity.z))
		local step = {x = velocity.x / v_axis_max, y = velocity.y / v_axis_max, z = velocity.z / v_axis_max}
		for i = 1, math.ceil(v_axis_max/5)+1 do -- trace at least 1/5 of the way per second
			if not node or node.name == "ignore" then
				minetest.get_voxel_manip():read_from_map(pos, pos)
				node = minetest.get_node(pos)
			end
			if node then
				local def = minetest.registered_nodes[node.name]
				if not def or def.walkable then
					return
				end
				if minetest.get_item_group(node.name, "water") ~= 0 then
					return 0
				end
				if node.name == "mcl_portals:portal_end" then
					if mcl_portals and mcl_portals.end_teleport then
						mcl_portals.end_teleport(obj)
					end
					return 0
				end
				if node.name == "mcl_core:cobweb" then
					return 0
				end
				if node.name == "mcl_core:vine" then
					return 0
				end
			end
			pos = vector.add(pos, step)
			node = minetest.get_node(pos)
		end
	end
end, -200)

minetest.register_on_respawnplayer(function(player)
	local pos = player:get_pos()
	minetest.add_particlespawner({
		amount = 50,
		time = 0.001,
		minpos = vector.add(pos, 0),
		maxpos = vector.add(pos, 0),
		minvel = vector.new(-5,-5,-5),
		maxvel = vector.new(5,5,5),
		minexptime = 1.1,
		maxexptime = 1.5,
		minsize = 1,
		maxsize = 2,
		collisiondetection = false,
		vertical = false,
		texture = "mcl_particles_mob_death.png^[colorize:#000000:255",
	})

	minetest.sound_play("mcl_mobs_mob_poof", {
		pos = pos,
		gain = 1.0,
		max_hear_distance = 8,
	}, true)
end)
