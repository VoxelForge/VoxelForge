mcl_bonus_chest = {}

local bonus_loot = {
	{
		stacks_min = 1,
		stacks_max = 1,
		items = {
			{ itemstring = "mcl_tools:axe_wood", weight = 3 },
			{ itemstring = "mcl_tools:axe_stone", weight = 1 },
		}
	},
	{
		stacks_min = 1,
		stacks_max = 1,
		items = {
			{ itemstring = "mcl_tools:pick_wood", weight = 3 },
			{ itemstring = "mcl_tools:pick_stone", weight = 1 },
		}
	},
	{
		stacks_min = 1,
		stacks_max = 3,
		items = {
			{ itemstring = "mcl_core:apple", amount_min = 1, amount_max=3 },
			{ itemstring = "mcl_farming:bread", amount_min = 1, amount_max=2 },
			{ itemstring = "mcl_fishing:salmon_raw", amount_min = 1, amount_max=2 },
		}
	},
	{
		stacks_min = 1,
		stacks_max = 4,
		items = {
			{ itemstring = "mcl_trees:wood_oak", amount_min = 1, amount_max= 12 },
			{ itemstring = "mcl_core:stick", amount_min = 1, amount_max= 12 },
			{ itemstring = "mcl_trees:tree_acacia", amount_min = 1, amount_max=3 },
			{ itemstring = "mcl_trees:tree_birch", amount_min = 1, amount_max=3 },
			{ itemstring = "mcl_trees:tree_dark_oak", amount_min = 1, amount_max=3 },
			{ itemstring = "mcl_trees:tree_jungle", amount_min = 1, amount_max=3 },
			{ itemstring = "mcl_trees:tree_oak", amount_min = 1, amount_max=3 },
			{ itemstring = "mcl_trees:tree_spruce", amount_min = 1, amount_max=3 },
			{ itemstring = "mcl_trees:tree_mangrove", amount_min = 1, amount_max=3 },

		}
	},
}

function mcl_bonus_chest.place_bchest(pos, loot, pr)
	local pr = pr or PseudoRandom(minetest.get_mapgen_setting("seed"))
	local loot = loot or bonus_loot
	minetest.place_node(pos, {name = "mcl_chests:chest"})
	local m = minetest.get_meta(pos)
	local inv = m:get_inventory()
	local items = mcl_loot.get_multi_loot(loot, pr)
	mcl_loot.fill_inventory(inv, "main", items, pr)
end

minetest.register_chatcommand("bonus_chest", {
	privs = { server = true, },
	func = function(pn,pr)
		local pl = minetest.get_player_by_name(pn)
		mcl_bonus_chest.place_bchest(pl:get_pos())
	end,
})
