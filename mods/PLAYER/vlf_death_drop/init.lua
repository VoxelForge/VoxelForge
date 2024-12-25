vlf_death_drop = {}

vlf_death_drop.registered_dropped_lists = {}

function vlf_death_drop.register_dropped_list(inv, listname, drop)
	table.insert(vlf_death_drop.registered_dropped_lists, {inv = inv, listname = listname, drop = drop})
end

vlf_death_drop.register_dropped_list("PLAYER", "main", true)
vlf_death_drop.register_dropped_list("PLAYER", "craft", true)
vlf_death_drop.register_dropped_list("PLAYER", "armor", true)
vlf_death_drop.register_dropped_list("PLAYER", "offhand", true)

minetest.register_on_dieplayer(function(player)
	local keep = minetest.settings:get_bool("vlf_keepInventory", false)
	if keep == false then
		-- Drop inventory, crafting grid and armor
		local playerinv = player:get_inventory()
		local pos = player:get_pos()
		-- No item drop if in deep void
		local _, void_deadly = vlf_worlds.is_in_void(pos)

		for l=1,#vlf_death_drop.registered_dropped_lists do
			local inv = vlf_death_drop.registered_dropped_lists[l].inv
			if inv == "PLAYER" then
				inv = playerinv
			elseif type(inv) == "function" then
				inv = inv(player)
			end
			local listname = vlf_death_drop.registered_dropped_lists[l].listname
			local drop = vlf_death_drop.registered_dropped_lists[l].drop
			local dropspots = minetest.find_nodes_in_area(vector.offset(pos,-3,0,-3),vector.offset(pos,3,0,3),{"air"})
			if #dropspots == 0 then
				table.insert(dropspots,pos)
			end
			if inv then
				for _, stack in ipairs(inv:get_list(listname)) do
					local p = vector.offset(dropspots[math.random(#dropspots)],math.random()-0.5,math.random()-0.5,math.random()-0.5)
					if not void_deadly and drop and not vlf_enchanting.has_enchantment(stack, "curse_of_vanishing") then
						local def = minetest.registered_items[stack:get_name()]
						if def and def.on_drop then
							stack = def.on_drop(stack, player, p)
						end
						minetest.add_item(p, stack)
					end
				end
				inv:set_list(listname, {})
			end
		end
		vlf_armor.update(player)
	end
end)
