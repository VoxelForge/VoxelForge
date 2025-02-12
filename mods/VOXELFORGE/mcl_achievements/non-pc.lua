local S = minetest.get_translator(minetest.get_current_modname())
-- NON-PC ACHIEVEMENTS (XBox, Pocket Edition, etc.)

-- If true, activates achievements from other Minecraft editions (XBox, PS, etc.)
local non_pc_achievements = false

if non_pc_achievements then
	awards.register_achievement("mcl:n_placeDispenser", {
		title = S("Dispense With This"),
		description = S("Place a dispenser."),
		icon = "mcl_dispensers_dispenser_front_horizontal.png",
		trigger = {
			type = "place",
			node = "mcl_dispensers:dispenser",
			target = 1
		}
	})

	-- FIXME: Eating achievements don't work when you have exactly one of these items on hand
	awards.register_achievement("mcl:n_eatPorkchop", {
		title = S("Pork Chop"),
		description = S("Eat a cooked porkchop."),
		icon = "mcl_mobitems_porkchop_cooked.png",
		trigger = {
			type = "eat",
			item= "mcl_mobitems:cooked_porkchop",
			target = 1,
		}
	})
	awards.register_achievement("mcl:n_eatRabbit", {
		title = S("Rabbit Season"),
		icon = "mcl_mobitems_rabbit_cooked.png",
		description = S("Eat a cooked rabbit."),
		trigger = {
			type = "eat",
			item= "mcl_mobitems:cooked_rabbit",
			target = 1,
		}
	})
	awards.register_achievement("mcl:n_eatRottenFlesh", {
		title = S("Iron Belly"),
		description = S("Get really desperate and eat rotten flesh."),
		icon = "mcl_mobitems_rotten_flesh.png",
		trigger = {
			type = "eat",
			item= "mcl_mobitems:rotten_flesh",
			target = 1,
		}
	})
	awards.register_achievement("mcl:n_placeFlowerpot", {
		title = S("Pot Planter"),
		description = S("Place a flower pot."),
		icon = "mcl_flowerpots_flowerpot_inventory.png",
		trigger = {
			type = "place",
			node = "mcl_flowerpots:flower_pot",
			target = 1,
		}
	})

	awards.register_achievement("mcl:n_emeralds", {
		title = S("The Haggler"),
		description = S("Mine emerald ore."),
		icon = "default_emerald.png",
		trigger = {
			type = "dig",
			node = "mcl_core:emerald_ore",
			target = 1,
		}
	})
end
