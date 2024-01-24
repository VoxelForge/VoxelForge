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

		-- what is around me?
		local node_stand = mcl_player.players[player].nodes.stand
		local node_stand_below = mcl_player.players[player].nodes.stand_below
		local node_head = mcl_player.players[player].nodes.head
		local node_feet = mcl_player.players[player].nodes.feet
		local node_head_top = mcl_player.players[player].nodes.head_top
		if not node_stand or not node_stand_below or not node_head or not node_feet or not node_head_top then
			return
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


