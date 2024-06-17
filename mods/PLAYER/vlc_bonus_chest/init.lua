vlc_bonus_chest = {}

local storage = minetest.get_mod_storage()

local adj = {
	vector.new(1,0,0),
	vector.new(-1,0,0),
	vector.new(0,0,1),
	vector.new(0,0,-1),
}

vlc_bonus_chest.bonus_loot = {
	{
		stacks_min = 1,
		stacks_max = 1,
		items = {
			{ itemstring = "vlc_tools:axe_wood", weight = 3 },
			{ itemstring = "vlc_tools:axe_stone", weight = 1 },
		}
	},
	{
		stacks_min = 1,
		stacks_max = 1,
		items = {
			{ itemstring = "vlc_tools:pick_wood", weight = 3 },
			{ itemstring = "vlc_tools:pick_stone", weight = 1 },
		}
	},
	{
		stacks_min = 1,
		stacks_max = 1,
		items = {
			{ itemstring = "vlc_core:apple", amount_min = 1, amount_max=3 },
		}
	},
	{
		stacks_min = 1,
		stacks_max = 1,
		items = {
			{ itemstring = "vlc_farming:bread", amount_min = 1, amount_max=2 },
		}
	},
	{
		stacks_min = 1,
		stacks_max = 1,
		items = {
			{ itemstring = "vlc_fishing:salmon_raw", amount_min = 1, amount_max=2 },
		}
	},
	{
		stacks_min = 1,
		stacks_max = 1,
		items = {
			{ itemstring = "vlc_core:stick", amount_min = 1, amount_max= 12 },
		}
	},
	{
		stacks_min = 1,
		stacks_max = 1,
		items = {
			{ itemstring = "vlc_trees:wood_oak", amount_min = 1, amount_max= 12 },
		}
	},
	{
		stacks_min = 1,
		stacks_max = 1,
		items = {
			{ itemstring = "vlc_mushrooms:mushroom_brown", amount_min = 1, amount_max= 12 },
		}
	},
	{
		stacks_min = 1,
		stacks_max = 1,
		items = {
			{ itemstring = "vlc_trees:sapling_oak", amount_min = 1, amount_max= 4 },
			{ itemstring = "vlc_trees:sapling_spruce", amount_min = 1, amount_max= 4 },
			{ itemstring = "vlc_trees:sapling_birch", amount_min = 1, amount_max= 4 },
			{ itemstring = "vlc_trees:sapling_dark_oak", amount_min = 1, amount_max= 4 },
			{ itemstring = "vlc_trees:sapling_acacia", amount_min = 1, amount_max= 4 },
			{ itemstring = "vlc_trees:sapling_jungle", amount_min = 1, amount_max= 4 },
			{ itemstring = "vlc_trees:sapling_cherry_blossom", amount_min = 1, amount_max= 4 },
		}
	},
	{
		stacks_min = 1,
		stacks_max = 1,
		items = {
			{ itemstring = "vlc_trees:tree_acacia", amount_min = 1, amount_max=3 },
			{ itemstring = "vlc_trees:tree_dark_oak", amount_min = 1, amount_max=3 },
		}
	},
	{
		stacks_min = 1,
		stacks_max = 1,
		items = {
			{ itemstring = "vlc_trees:tree_birch", amount_min = 1, amount_max=3 },
			{ itemstring = "vlc_trees:tree_jungle", amount_min = 1, amount_max=3 },
			{ itemstring = "vlc_trees:tree_oak", amount_min = 1, amount_max=3 },
			{ itemstring = "vlc_trees:tree_spruce", amount_min = 1, amount_max=3 },

		}
	},
	{
		stacks_min = 1,
		stacks_max = 1,
		items = {
			{ itemstring = "vlc_farming:potato_item", amount_min = 1, amount_max= 2 },
			{ itemstring = "vlc_farming:carrot_item", amount_min = 1, amount_max= 2 },
		}
	},
	{
		stacks_min = 1,
		stacks_max = 1,
		items = {
			{ itemstring = "vlc_farming:pumpkin_seeds", amount_min = 1, amount_max= 2 },
			{ itemstring = "vlc_farming:melon_seeds", amount_min = 1, amount_max= 2 },
			{ itemstring = "vlc_farming:beetroot_seeds", amount_min = 1, amount_max= 2 },
		}
	},
	{
		stacks_min = 1,
		stacks_max = 1,
		items = {
			{ itemstring = "vlc_cocoas:cocoa_beans", amount_min = 1, amount_max= 2 },
			{ itemstring = "vlc_core:cactus", amount_min = 1, amount_max= 2 },
		}
	},
}

function vlc_bonus_chest.place_chest(pos, loot, pr)
	local pr = pr or PseudoRandom(minetest.hash_node_position(pos) + minetest.get_mapgen_setting("seed"))
	local loot = loot or vlc_bonus_chest.bonus_loot
	local pp = minetest.find_nodes_in_area_under_air(vector.offset(pos, -5,-3,-5), vector.offset(pos, 5,3,5), {"vlc_core:dirt_with_grass", "vlc_core:stone", "group:solid"})
	if pp and #pp > 0 then
		local cpos = vector.offset(pp[pr:next(1,#pp)], 0, 1, 0)
		minetest.place_node(cpos, {name = "vlc_chests:chest"})
		local m = minetest.get_meta(cpos)
		local inv = m:get_inventory()
		local items = vlc_loot.get_multi_loot(loot, pr)
		vlc_loot.fill_inventory(inv, "main", items, pr)
		for _,v in pairs(adj) do
			local tpos = vector.add(cpos, v)
			local def = minetest.registered_nodes[minetest.get_node(tpos).name]
			if def and def.buildable_to then
				minetest.place_node(tpos, {name = "vlc_torches:torch"})
			end
		end
	end
end

minetest.register_on_newplayer(function(pl)
	if minetest.settings:get_bool("vlc_bonus_chest", false) and storage:get_int("vlc_bonus_chest:deployed") ~= 1 then
		minetest.after(5, function(pl)
			if pl and pl.get_pos and pl:get_pos() then
				vlc_bonus_chest.place_chest(pl:get_pos())
				storage:set_int("vlc_bonus_chest:deployed", 1)
			end
		end, pl)
	end
end)

minetest.register_chatcommand("bonus_chest", {
	privs = { server = true, },
	func = function(pn,pr)
		local pl = minetest.get_player_by_name(pn)
		vlc_bonus_chest.place_chest(pl:get_pos())
	end,
})
