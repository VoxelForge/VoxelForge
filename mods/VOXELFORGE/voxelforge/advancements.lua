-- Define the node names for portal frame, bedrock, and stonebrick stair
local target_nodes = {
	portal_frame = "mcl_portals:end_portal_frame",
	bedrock = "mcl_core:bedrock",
	stonebrick_stair = "mcl_stairs:stair_stonebrick",
}

-- Function to check distance and send message
local function check_near_nodes(player)
	local pos = player:get_pos()
	local player_name = player:get_player_name()

	-- Check if the achievement is already unlocked
	if not mcl_achievements.award_unlocked(player_name, "mcl:follow_ender_eye") then
		local radius = 5
		local found_nodes = {
			portal_frame = false,
			bedrock = false,
			stonebrick_stair = false
		}

		-- Loop through a cube around the player to find target nodes
		for x = -radius, radius do
			for y = -radius, radius do
				for z = -radius, radius do
					-- Calculate the position to check
					local check_pos = vector.add(pos, {x = x, y = y, z = z})
					-- Get the node at the calculated position
					local node = minetest.get_node(check_pos)

					-- Check and mark the node if it's one of the target nodes
					if node.name == target_nodes.portal_frame then
						found_nodes.portal_frame = true
					elseif node.name == target_nodes.bedrock then
						found_nodes.bedrock = true
					elseif node.name == target_nodes.stonebrick_stair then
						found_nodes.stonebrick_stair = true
					end
				end
			end
		end

		-- If the player is near all three nodes, unlock the achievement
		if found_nodes.portal_frame and found_nodes.bedrock and found_nodes.stonebrick_stair then
			awards.unlock(player_name, "mcl:follow_ender_eye")
		end
	end
end

-- Register a globalstep callback to check players' positions regularly
minetest.register_globalstep(function(dtime)
	-- Iterate over all connected players
	for _, player in ipairs(minetest.get_connected_players()) do
		check_near_nodes(player)
	end
end)

local player_fall_data = {}

minetest.register_on_joinplayer(function(player)
	local player_name = player:get_player_name()
	player_fall_data[player_name] = {
		fell_from = nil,
		fell_distance = 0
	}
end)

minetest.register_on_leaveplayer(function(player)
	local player_name = player:get_player_name()
	player_fall_data[player_name] = nil
end)

minetest.register_globalstep(function(dtime)
	for _, player in ipairs(minetest.get_connected_players()) do
		local player_name = player:get_player_name()
		if not mcl_achievements.award_unlocked(player_name, "mcl:fall_from_world_height") then
			local pos = player:get_pos()
			if player:get_hp() > 0 then
				if player_fall_data[player_name].fell_from == nil then
					player_fall_data[player_name].fell_from = pos.y
				else
					local fall_distance = player_fall_data[player_name].fell_from - pos.y
					if fall_distance >= 379 and player:get_pos().y >= -120 then
						awards.unlock(player:get_player_name(), "mcl:fall_from_world_height")
						player_fall_data[player_name].fell_from = nil
					elseif pos.y > player_fall_data[player_name].fell_from then
						player_fall_data[player_name].fell_from = pos.y
					end
				end
			end
		end
	end
end)

-- Function to check the player's entire inventory for the required items
local function check_inventory_for_required_items(player)
	local inventory = player:get_inventory()
	local player_name = player:get_player_name()

	local armor_found = {
		iron = false,
		diamond = false,
		netherite = { chest = false, boots = false, helmet = false, leggings = false }
	}

	-- Loop through all the lists in the player's inventory
	for list_name, list in pairs(inventory:get_lists()) do
		for i = 1, inventory:get_size(list_name) do
			local stack = inventory:get_stack(list_name, i)
			local item_name = stack:get_name()

			-- Check for iron armor
			if not mcl_achievements.award_unlocked(player_name, "mcl:obtain_armor") then
				if item_name == "mcl_armor:chestplate_iron" or item_name == "mcl_armor:boots_iron"
				or item_name == "mcl_armor:helmet_iron" or item_name == "mcl_armor:leggings_iron" then
					armor_found.iron = true
				end
			end

			-- Check for diamond armor
			if not mcl_achievements.award_unlocked(player_name, "mcl:shiny_gear") then
				if item_name == "mcl_armor:chestplate_diamond" or item_name == "mcl_armor:boots_diamond"
				or item_name == "mcl_armor:helmet_diamond" or item_name == "mcl_armor:leggings_diamond" then
					armor_found.diamond = true
				end
			end

			-- Check for netherite armor
			if not mcl_achievements.award_unlocked(player_name, "mcl:netherite_armor") then
				if item_name == "mcl_armor:chestplate_netherite" then
					armor_found.netherite.chest = true
				elseif item_name == "mcl_armor:boots_netherite" then
					armor_found.netherite.boots = true
				elseif item_name == "mcl_armor:helmet_netherite" then
					armor_found.netherite.helmet = true
				elseif item_name == "mcl_armor:leggings_netherite" then
					armor_found.netherite.leggings = true
				end
			end
		end
	end

	-- Unlock achievements if conditions are met
	if armor_found.iron and not mcl_achievements.award_unlocked(player_name, "mcl:obtain_armor") then
		awards.unlock(player_name, "mcl:obtain_armor")
	end

	if armor_found.diamond and not mcl_achievements.award_unlocked(player_name, "mcl:shiny_gear") then
		awards.unlock(player_name, "mcl:shiny_gear")
	end

	if armor_found.netherite.chest and armor_found.netherite.boots and armor_found.netherite.helmet and armor_found.netherite.leggings
	and not mcl_achievements.award_unlocked(player_name, "mcl:netherite_armor") then
		awards.unlock(player_name, "mcl:netherite_armor")
	end
end

-- This function will handle inventory actions like putting, moving, or taking
minetest.register_on_player_inventory_action(function(player, action, inventory, info)
	if action == "put" or action == "move" or action == "take" then
		check_inventory_for_required_items(player)
	end
end)
