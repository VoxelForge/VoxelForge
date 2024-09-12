vlf_trials = {
	registered_vaults = {}
}

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
dofile(modpath.."/api.lua")
dofile(modpath.."/ominous.lua")

vlf_trials.register_vault("vault",{
	key = "vlf_trials:trial_key",
	node_off = {
		tiles = { "vlf_trials_vault_top_off.png", "vlf_trials_vault_bottom.png",
			"vlf_trials_vault_side_off.png", "vlf_trials_vault_side_off.png",
			"vlf_trials_vault_side_off.png", "vlf_trials_vault_front_off.png",
		},
	},
	node_on = {
		tiles = { "vlf_trials_vault_top_on.png", "vlf_trials_vault_bottom.png",
			"vlf_trials_vault_side_on.png", "vlf_trials_vault_side_on.png",
			"vlf_trials_vault_side_on.png", "vlf_trials_vault_front_on.png",
		},
	},
	node_ejecting = {
		tiles = { "vlf_trials_vault_top_ejecting.png", "vlf_trials_vault_bottom.png",
			"vlf_trials_vault_side_ejecting.png", "vlf_trials_vault_side_ejecting.png",
			"vlf_trials_vault_side_ejecting.png", "vlf_trials_vault_front_ejecting.png",
		},
	},
	loot = {
		{
			stacks_min = 1,
			stacks_max = 1,
			items = {
				{ itemstring = "vlf_core:emerald", weight = 392, amount_min = 2, amount_max = 4 },
				{ itemstring = "vlf_bows:arrow", weight = 92, amount_min = 2, amount_max = 8 },
				--{ itemstring = "TODO:arrow_of_poison", weight = 92, amount_min = 2, amount_max = 8 },
				{ itemstring = "vlf_core:iron_ingot", weight = 69, amount_min = 1, amount_max = 4 },
				{ itemstring = "vlf_charges:wind_charge", weight = 69, amount_min = 1, amount_max = 3 },
				{ itemstring = "vlf_honey:honey_bottle", weight = 69, amount_min = 1, amount_max = 2 },
				{ itemstring = "vlf_trials:ominous_bottle_1", weight = 46, amount_min = 1, amount_max = 1 },
				{ itemstring = "vlf_trials:ominous_bottle_2", weight = 46, amount_min = 1, amount_max = 1 },
				{ itemstring = "vlf_shields:shield", weight = 300, amount_min = 1, amount_max = 1 },
				{ itemstring = "vlf_bows:bow", weight = 300, func = function(stack, pr)vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlf_charges:wind_charge", weight = 23, amount_min = 4, amount_max = 12 },
				{ itemstring = "vlf_core:diamond", weight = 23, amount_min = 1, amount_max = 2 },
				{ itemstring = "vlf_farming:carrot_item_gold", weight = 200, amount_min = 1, amount_max = 2 },
				{ itemstring = "vlf_farming:carrot_item_gold", weight = 200, amount_min = 1, amount_max = 2 },
				{ itemstring = "vlf_books:book", weight = 1, func = function(stack, pr)vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlf_books:book", weight = 1, func = function(stack, pr)vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlf_bows:crossbow", weight = 200, func = function(stack, pr)vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlf_tools:axe_iron", weight = 200, func = function(stack, pr)vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlf_armor:chestplate_iron", weight = 200, func = function(stack, pr)vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlf_tools:axe_diamond", weight = 100, func = function(stack, pr)vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlf_armor:chestplate_diamond", weight = 100, func = function(stack, pr)vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },

			}
		},
		{
			stacks_min = 1,
			stacks_max = 3,
			items = {
				{ itemstring = "vlf_core:emerald", weight = 4, amount_min = 2, amount_max = 4 },
				{ itemstring = "vlf_bows:arrow", weight = 4, amount_min = 2, amount_max = 8 },
				--{ itemstring = "TODO:arrow_of_poison", weight = 4, amount_min = 2, amount_max = 8 },
				{ itemstring = "vlf_core:iron_ingot", weight = 3, amount_min = 1, amount_max = 4 },
				{ itemstring = "vlf_charges:wind_charge", weight = 3, amount_min = 1, amount_max = 3 },
				{ itemstring = "vlf_honey:honey_bottle", weight = 3, amount_min = 1, amount_max = 2 },
				{ itemstring = "vlf_trials:ominous_bottle_1", weight = 2, amount_min = 1, amount_max = 2 },
				{ itemstring = "vlf_trials:ominous_bottle_2", weight = 2, amount_min = 1, amount_max = 2 },
				{ itemstring = "vlf_charges:wind_charge", weight = 1, amount_min = 4, amount_max = 12 },
				{ itemstring = "vlf_core:diamond", weight = 1, amount_min = 1, amount_max = 2 },
			},
		},
		{
			stacks_min = 1,
			stacks_max = 1,
			items = {
				{ itemstring = "vlf_core:apple_gold", weight = 4, amount_min = 1, amount_max = 2 },
				{ itemstring = "vlf_armor:bolt", weight = 3 },
				{ itemstring = "vlf_jukebox:record_8", weight = 2 },
				{ itemstring = "vlf_banners:pattern_guster", weight = 2 },
				--{ itemstring = "TODO:trident", weight = 1 },
			}
		}
}
})

--[[vlf_trials.register_vault("ominous_vault",{
	key = "vlf_trials:ominous_trial_key",
	node_off = {
		tiles = { "vlf_trials_ominous_vault_top_off.png", "vlf_trials_ominous_vault_bottom.png",
			"vlf_trials_ominous_vault_side_off.png", "vlf_trials_ominous_vault_side_off.png",
			"vlf_trials_ominous_vault_side_off.png", "vlf_trials_ominous_vault_front_off.png",
		},
	},
	node_on = {
		tiles = { "vlf_trials_ominous_vault_top_on.png", "vlf_trials_ominous_vault_bottom.png",
			"vlf_trials_ominous_vault_side_on.png", "vlf_trials_ominous_vault_side_on.png",
			"vlf_trials_ominous_vault_side_on.png", "vlf_trials_ominous_vault_front_on.png",
		},
	},
	node_ejecting = {
		tiles = { "vlf_trials_ominous_vault_top_ejecting.png", "vlf_trials_ominous_vault_bottom.png",
			"vlf_trials_ominous_vault_side_ejecting.png", "vlf_trials_ominous_vault_side_ejecting.png",
			"vlf_trials_ominous_vault_side_ejecting.png", "vlf_trials_ominous_vault_front_ejecting.png",
		},
	},
	loot = {
		{
			stacks_min = 1,
			stacks_max = 2,
			items = {
				{ itemstring = "vlf_core:emerald", weight = 392, amount_min = 4, amount_max = 10 },
				{ itemstring = "vlf_charges:wind_charge", weight = 116, amount_min = 8, amount_max = 12 },
				--{ itemstring = "TODO:arrow_of_slowness_IV", weight = 87, amount_min = 2, amount_max = 8 },
				{ itemstring = "vlf_core:diamond", weight = 58, amount_min = 2, amount_max = 3 },
				{ itemstring = "vlf_trials:ominous_bottle_3", weight = 29, amount_min = 1, amount_max = 1 },
				{ itemstring = "vlf_trials:ominous_bottle_4", weight = 29, amount_min = 1, amount_max = 1 },
				{ itemstring = "vlf_trials:ominous_bottle_5", weight = 29, amount_min = 1, amount_max = 1 },
				{ itemstring = "vlf_core:emeraldblock", weight = 300, amount_min = 1, amount_max = 1 },
				{ itemstring = "vlf_bows:crossbow", weight = 240, func = function(stack, pr)vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlf_core:ironblock", weight = 240, amount_min = 1, amount_max = 1 },
				{ itemstring = "vlf_core:apple_gold", weight = 180, amount_min = 1, amount_max = 1 },
				{ itemstring = "vlf_tools:axe_diamond", weight = 180, func = function(stack, pr)vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlf_armor:chestplate_diamond", weight = 180, func = function(stack, pr)vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "vlf_books:book", weight = 200, func = function(stack, pr)vlf_enchanting.enchant_uniform_specific_randomly(stack, {"breach", "density"}, pr) end },
				{ itemstring = "vlf_books:book", weight = 200, func = function(stack, pr)vlf_enchanting.enchant_uniform_specific_randomly(stack, {"knockback", "punch", "smite", "looting", "multishot"}, pr) end },
				{ itemstring = "vlf_books:book", weight = 200, func = function(stack)vlf_enchanting.enchant(stack, "wind_burst", 1) end },
				{ itemstring = "vlf_core:diamondblock", weight = 600, amount_min = 1, amount_max = 1 },
			}
		},
		{
			stacks_min = 1,
			stacks_max = 2,
			items = {
				{ itemstring = "vlf_trials:ominous_bottle_3", weight = 1, amount_min = 1, amount_max = 1 },
				{ itemstring = "vlf_trials:ominous_bottle_4", weight = 1, amount_min = 1, amount_max = 1 },
				{ itemstring = "vlf_trials:ominous_bottle_5", weight = 1, amount_min = 1, amount_max = 1 },
			},
		},
		{
			stacks_min = 1,
			stacks_max = 1,
			items = {
				{ itemstring = "vlf_armor:flow", weight = 9 },
				{ itemstring = "vlf_core:apple_gold_enchanted", weight = 9, amount_min = 1, amount_max = 2 },
				{ itemstring = "vlf_banners:pattern_flow", weight = 6 },
				--{ itemstring = "TODO Music Disk: Creator.", weight = 3, amount_min = 1, amount_max = 1 },
				{ itemstring = "vlf_tools:heavy_core", weight = 3, amount_min = 1, amount_max = 1 },
			}
		}
}
})]]
