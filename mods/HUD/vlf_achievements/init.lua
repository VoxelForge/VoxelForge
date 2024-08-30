vlf_achievements = {}

function vlf_achievements.award_unlocked(playername, awardname)
	local unlocked = false
	for _, aw in pairs(awards.get_award_states(playername)) do
		if aw.name == awardname and aw.unlocked then
			unlocked = true
			break
		end
	end
	return unlocked
end
-- Settings

-- If true, activates achievements from other Minecraft editions (XBox, PS, etc.)
local non_pc_achievements = false

local S = minetest.get_translator(minetest.get_current_modname())

awards.register_on_unlock(function(name, def)
	if def.reward_xp then
		local player = minetest.get_player_by_name(name)
		vlf_experience.throw_xp(player:get_pos(), def.reward_xp)
	end
end)

-- Achievements from PC Edition

awards.register_achievement("vlf_buildWorkBench", {
	title = S("Benchmarking"),
	description = S("Craft a crafting table from 4 wooden planks."),
	icon = "crafting_workbench_front.png",
	trigger = {
		type = "craft",
		item = "vlf_crafting_table:crafting_table",
		target = 1
	},
	type = "Advancement",
	group = "Overworld",
})
awards.register_achievement("vlf:buildPickaxe", {
	title = S("Time to Mine!"),
	description = S("Use a crafting table to craft a wooden pickaxe from wooden planks and sticks."),
	icon = "default_tool_woodpick.png",
	trigger = {
		type = "craft",
		item = "vlf_tools:pick_wood",
		target = 1
	},
	type = "Advancement",
	group = "Overworld",
})
awards.register_achievement("vlf:buildFurnace", {
	title = S("Hot Topic"),
	description = S("Use 8 cobblestones to craft a furnace."),
	icon = "default_furnace_front.png",
	trigger = {
		type = "craft",
		item = "vlf_furnaces:furnace",
		target = 1
	},
	type = "Advancement",
	group = "Overworld",
})
awards.register_achievement("vlf:buildHoe", {
	title = S("Time to Farm!"),
	description = S("Use a crafting table to craft a wooden hoe from wooden planks and sticks."),
	icon = "farming_tool_woodhoe.png",
	trigger = {
		type = "craft",
		item = "vlf_farming:hoe_wood",
		target = 1
	},
	type = "Advancement",
	group = "Husbandry",
})
awards.register_achievement("vlf:makeBread", {
	title = S("Bake Bread"),
	description = S("Use wheat to craft a bread."),
	icon = "farming_bread.png",
	trigger = {
		type = "craft",
		item = "vlf_farming:bread",
		target = 1
	},
	type = "Advancement",
	group = "Husbandry",
})

awards.register_achievement("vlf:bakeCake", {
	title = S("The Lie"),
	description = S("Craft a cake using wheat, sugar, milk and an egg."),
	icon = "cake.png",
	trigger = {
		type = "craft",
		item = "vlf_cake:cake",
		target = 1
	},
	type = "Advancement",
	group = "Husbandry",
})
awards.register_achievement("vlf:buildBetterPickaxe", {
	title = S("Getting an Upgrade"),
	-- TODO: This achievement should support all non-wood pickaxes
	description = S("Craft a stone pickaxe using sticks and cobblestone."),
	icon = "default_tool_stonepick.png",
	trigger = {
		type = "craft",
		item = "vlf_tools:pick_stone",
		target = 1
	},
	type = "Advancement",
	group = "Overworld",
})
awards.register_achievement("vlf:buildSword", {
	title = S("Time to Strike!"),
	description = S("Craft a wooden sword using wooden planks and sticks on a crafting table."),
	icon = "default_tool_woodsword.png",
	trigger = {
		type = "craft",
		item = "vlf_tools:sword_wood",
		target = 1
	},
	type = "Advancement",
	group = "Adventure",
})

awards.register_achievement("vlf:bookcase", {
	title = S("Librarian"),
	description = S("Craft a bookshelf."),
	icon = "default_bookshelf.png",
	trigger = {
		type = "craft",
		item = "vlf_books:bookshelf",
		target = 1
	},
	type = "Advancement",
	group = "Overworld",
})

awards.register_achievement("vlf:buildIronPickaxe", {
	title = S("Isn't It Iron Pick"),
	description = S("Craft a iron pickaxe using sticks and iron."),
	icon = "default_tool_steelpick.png",
	trigger = {
		type = "craft",
		item = "vlf_tools:pick_iron",
		target = 1
	},
	type = "Advancement",
	group = "Overworld",
})

-- Item pickup achievements: These are awarded when picking up a certain item.
-- The achivements are manually given in the mod vlf_item_entity.
awards.register_achievement("vlf:diamonds", {
	title = S("DIAMONDS!"),
	description = S("Pick up a diamond from the floor."),
	icon = "vlf_core_diamond_ore.png",
	type = "Advancement",
})
awards.register_achievement("vlf:blazeRod", {
	title = S("Into Fire"),
	description = S("Pick up a blaze rod from the floor."),
	icon = "vlf_mobitems_blaze_rod.png",
	type = "Advancement",
	group = "Nether",
})

awards.register_achievement("vlf:killCow", {
	title = S("Cow Tipper"),
	description = S("Pick up leather from the floor.\nHint: Cows and some other animals have a chance to drop leather, when killed."),
	icon = "vlf_mobitems_leather.png",
	type = "Advancement",
	group = "Adventure",
})
awards.register_achievement("vlf:mineWood", {
	title = S("Getting Wood"),
	description = S("Pick up a wood item from the ground.\nHint: Punch a tree trunk until it pops out as an item."),
	icon = "default_tree.png",
	type = "Advancement",
	group = "Overworld",
})

awards.register_achievement("vlf:whosCuttingOnions", {
	title = S("Who is Cutting Onions?"),
	description = S("Pick up a crying obsidian from the floor."),
	icon = "default_obsidian.png^vlf_core_crying_obsidian.png",
	type = "Advancement",
	group = "Nether",
})

awards.register_achievement("vlf:hiddenInTheDepths", {
	title = S("Hidden in the Depths"),
	description = S("Pick up an Ancient Debris from the floor."),
	icon = "vlf_nether_ancient_debris_side.png",
	type = "Advancement",
	group = "Nether",
})

awards.register_achievement("vlf:PickUpDragonEgg", {
	title = S("The Next Generation"),
	description = S("Hold the Dragon Egg.\nHint: Pick up the egg from the ground and have it in your inventory."),
	icon = "vlf_end_dragon_egg.png",
	type = "Goal",
	group = "End",
})

awards.register_achievement("vlf:skysTheLimit", {
	title = S("Sky's the Limit"),
	description = S("Find the elytra and prepare to fly above and beyond!"),
	icon = "vlf_armor_inv_elytra.png",
	type = "Goal",
	group = "End",
}) -- TODO: Make also unlock when moved to inventory, not just picking up from ground

-- Smelting achivements: These are awarded when picking up an item from a furnace
-- output. They are given in vlf_furnaces.
awards.register_achievement("vlf:acquireIron", {
	title = S("Acquire Hardware"),
	description = S("Take an iron ingot from a furnace's output slot.\nHint: To smelt an iron ingot, put a fuel (like coal) and iron ore into a furnace."),
	icon = "default_steel_ingot.png",
	type = "Advancement",
	group = "Overworld",
})
awards.register_achievement("vlf:cookFish", {
	title = S("Delicious Fish"),
	description = S("Take a cooked fish from a furnace.\nHint: Use a fishing rod to catch a fish and cook it in a furnace."),
	icon = "vlf_fishing_fish_cooked.png",
	type = "Advancement",
	group = "Husbandry",
})

-- Other achievements triggered outside of vlf_achievements

-- Triggered in vlf_minecarts
awards.register_achievement("vlf:onARail", {
	title = S("On A Rail"),
	description = S("Travel by minecart for at least 1000 meters from your starting point in a single ride."),
	icon = "default_rail.png",
	type = "Challenge",
	group = "Adventure",
})

-- Triggered in mobs_mc/skeleton+stray.lua
awards.register_achievement("vlf:snipeSkeleton", {
	title = S("Sniper Duel"),
	-- TODO: The range should be 50, not 20. Nerfed because of reduced bow range
	description = S("Kill a skeleton, wither skeleton or stray by bow and arrow from a distance of at least 20 meters."),
	icon = "vlf_bows_bow.png",
	type = "Challenge",
	group = "Adventure",
	reward_xp = 50,
})

--Triggered in vlf_mobs/physics.lua

awards.register_achievement("vlf:monsterHunter", {
	title = S("Monster Hunter"),
	description = S("Kill a monster."),
	icon = "mobs_mc_spawn_icon_zombie.png",
	type = "Advancement",
	group = "Adventure",
})

-- Triggered in vlf_portals
awards.register_achievement("vlf:buildNetherPortal", {
	title = S("We Need to Go Deeper"),
	description = S("Use obsidian and a fire starter to construct a Nether portal."),
	icon = "vlf_fire_flint_and_steel.png",
	type = "Advancement",
	group = "Overworld",
})

awards.register_achievement("vlf:enterEndPortal", {
	title = S("The End?"),
	description = S("Or the beginning?\nHint: Enter an end portal."),
	icon = "vlf_end_end_stone.png",
	type = "Advancement",
	group = "Overworld",
})

awards.register_achievement("vlf:theNether", {
	title = S("The Nether"),
	description = S("Bring summer clothes.\nHint: Enter the Nether."),
	icon = "vlf_nether_netherrack.png",
	type = "Advancement",
	group = "Nether",
})

-- Triggered in vlf_totems
awards.register_achievement("vlf:postMortal", {
	title = S("Postmortal"),
	description = S("Use a Totem of Undying to cheat death."),
	icon = "vlf_totems_totem.png",
	type = "Goal",
	group = "Adventure",
})

-- Triggered in vlf_beds
awards.register_achievement("vlf:sweetDreams", {
	title = S("Sweet Dreams"),
	description = S("Sleep in a bed to change your respawn point."),
	icon = "vlf_beds_bed_red_inv.png",
	type = "Advancement",
	group = "Adventure",
})

awards.register_achievement("vlf:notQuiteNineLives", {
	title = S('Not Quite "Nine" Lives'),
	description = S("Charge a Respawn Anchor to the maximum."),
	icon = "respawn_anchor_side4.png",
	type = "Advancement",
	group = "Nether",
})

-- Triggered in mobs_mc
awards.register_achievement("vlf:whatAdeal", {
	title = S("What A Deal!"),
	description = S("Successfully trade with a Villager."),
	icon = "vlf_core_emerald.png",
	type = "Advancement",
	group = "Adventure",
})

awards.register_achievement("vlf:tacticalFishing", {
	title = S("Tactical Fishing"),
	description = S("Catch a fish... without a fishing rod!"),
	icon = "pufferfish_bucket.png",
	type = "Advancement",
	group = "Husbandry",
})

awards.register_achievement("vlf:cutestPredator", {
	title = S("The Cutest Predator"),
	description = S("Catch an Axolotl with a bucket!"),
	icon = "axolotl_bucket.png",
	type = "Advancement",
	group = "Husbandry",
})

awards.register_achievement("vlf:witheringHeights", {
	title = S("Withering Heights"),
	description = S("Summon the wither from the dead."),
	icon = "vlf_mobitems_nether_star.png",
	type = "Advancement",
	group = "Nether",
})

awards.register_achievement("vlf:freeTheEnd", {
	title = S("Free the End"),
	description = S("Kill the ender dragon. Good Luck!"),
	icon = "(spawn_egg.png^[multiply:#252525)^(spawn_egg_overlay.png^[multiply:#b313c9)", -- TODO: Dragon Head Icon
	type = "Advancement",
	group = "End",
})

-- Triggered in vlf_fishing
awards.register_achievement("vlf:fishyBusiness", {
	title = S("Fishy Business"),
	description = S("Catch a fish.\nHint: Catch a fish, salmon, clownfish, or pufferfish."),
	icon = "vlf_fishing_fishing_rod.png",
	type = "Advancement",
	group = "Husbandry",
})

-- Triggered in vlf_compass
awards.register_achievement("vlf:countryLode", {
	title = S("Country Lode, Take Me Home"),
	description = S("Use a compass on a Lodestone."),
	icon = "lodestone_side4.png",
	type = "Advancement",
	group = "Nether",
})

-- Triggered in vlf_smithing_table
awards.register_achievement("vlf:seriousDedication", {
	title = S("Serious Dedication"),
	description = S("Use a Netherite Ingot to upgrade a hoe, and then completely reevaluate your life choices."),
	icon = "farming_tool_netheritehoe.png",
	type = "Challenge",
	group = "Husbandry",
})

-- Triggered in vlf_brewing
awards.register_achievement("vlf:localBrewery", {
	title = S("Local Brewery"),
	description = S("Brew a Potion.\nHint: Take a entity_effect or glass bottle out of the brewing stand."),
	icon = "vlf_entity_effects_entity_effect_overlay.png^[colorize:#F82423:"..tostring(127).."^vlf_entity_effects_entity_effect_bottle.png",
	type = "Advancement",
	group = "Nether",
})

-- Triggered in vlf_enchanting
awards.register_achievement("vlf:enchanter", {
	title = S("Enchanter"),
	description = S("Enchant an item using an Enchantment Table."),
	icon = "vlf_enchanting_book_enchanted.png",
	type = "Advancement",
	group = "Overworld",
})

--Triggered in vlf_beacons
awards.register_achievement("vlf:beacon", {
	title = S("Bring Home the Beacon"),
	description = S("Use a beacon."),
	icon = "beacon_achievement_icon.png",
	type = "Advancement",
	group = "Nether",
})

awards.register_achievement("vlf:maxed_beacon", {
	title = S("Beaconator"),
	description = S("Use a fully powered beacon."),
	icon = "beacon_achievement_icon.png",
	type = "Goal",
	group = "Nether",
})

-- Triggered in vlf_end
awards.register_achievement("vlf:theEndAgain", {
	title = S("The End... Again..."),
	description = S("Respawn the Ender Dragon."),
	icon = "vlf_end_crystal_item.png",
	type = "Goal",
	group = "End",
})

-- Triggered in vlf_beehives
awards.register_achievement("vlf:bee_our_guest", {
	title = S("Bee Our Guest"),
	description = S("Use a campfire to collect a bottle of honey from a beehive without aggrivating the bees inside."),
	icon = "vlf_honey_honey_bottle.png",
	type = "Advancement",
	group = "Husbandry",
})

awards.register_achievement("vlf:total_beelocation", {
	title = S("Total Beelocation"),
	description = S("Move a bee nest, with 3 bees inside, using a silk touch enchanted tool."),
	icon = "vlf_beehives_bee_nest_front_honey.png",
	type = "Advancement",
	group = "Husbandry",
})

-- Triggered in vlf_copper
awards.register_achievement("vlf:wax_on", {
	title = S("Wax On"),
	description = S("Apply honeycomb to a copper block to protect it from the elements."),
	icon = "vlf_honey_honeycomb.png",
	type = "Advancement",
	group = "Husbandry",
})

awards.register_achievement("vlf:wax_off", {
	title = S("Wax Off"),
	description = S("Scrape wax off of a copper block."),
	icon = "default_tool_stoneaxe.png",
	type = "Advancement",
	group = "Husbandry",
})

-- Triggered in vlf_smithing_table
awards.register_achievement("vlf:trim", {
	title = S("Crafting a New Look"),
	description = S("Craft a trimmed armor at a Smithing Table"),
	icon = "dune_armor_trim_smithing_template.png",
	type = "Advancement",
	group = "Adventure",
})

awards.register_achievement("vlf:lots_of_trimming", {
	title = S("Smithing with Style"),
	description = S("Apply these smithing templates at least once: Spire, Snout, Rib, Ward, Silence, Vex, Tide, Wayfinder"),
	icon = "silence_armor_trim_smithing_template.png",
	type = "Advancement",
	group = "Adventure",
	on_unlock = function(name, awdef)
		-- delete json that is no longer needed
		minetest.get_player_by_name(name):get_meta():set_string("vlf_smithing_table:achievement_trims", "")
	end,
})

-- NON-PC ACHIEVEMENTS (XBox, Pocket Edition, etc.)

if non_pc_achievements then
	awards.register_achievement("vlf:n_placeDispenser", {
		title = S("Dispense With This"),
		description = S("Place a dispenser."),
		icon = "vlf_dispensers_dispenser_front_horizontal.png",
		trigger = {
			type = "place",
			node = "vlf_dispensers:dispenser",
			target = 1
		}
	})

	-- FIXME: Eating achievements don't work when you have exactly one of these items on hand
	awards.register_achievement("vlf:n_eatPorkchop", {
		title = S("Pork Chop"),
		description = S("Eat a cooked porkchop."),
		icon = "vlf_mobitems_porkchop_cooked.png",
		trigger = {
			type = "eat",
			item= "vlf_mobitems:cooked_porkchop",
			target = 1,
		}
	})
	awards.register_achievement("vlf:n_eatRabbit", {
		title = S("Rabbit Season"),
		icon = "vlf_mobitems_rabbit_cooked.png",
		description = S("Eat a cooked rabbit."),
		trigger = {
			type = "eat",
			item= "vlf_mobitems:cooked_rabbit",
			target = 1,
		}
	})
	awards.register_achievement("vlf:n_eatRottenFlesh", {
		title = S("Iron Belly"),
		description = S("Get really desperate and eat rotten flesh."),
		icon = "vlf_mobitems_rotten_flesh.png",
		trigger = {
			type = "eat",
			item= "vlf_mobitems:rotten_flesh",
			target = 1,
		}
	})
	awards.register_achievement("vlf:n_placeFlowerpot", {
		title = S("Pot Planter"),
		description = S("Place a flower pot."),
		icon = "vlf_flowerpots_flowerpot_inventory.png",
		trigger = {
			type = "place",
			node = "vlf_flowerpots:flower_pot",
			target = 1,
		}
	})

	awards.register_achievement("vlf:n_emeralds", {
		title = S("The Haggler"),
		description = S("Mine emerald ore."),
		icon = "default_emerald.png",
		trigger = {
			type = "dig",
			node = "vlf_core:emerald_ore",
			target = 1,
		}
	})
end

-- Show achievements formspec when the button was pressed
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if fields.__vlf_achievements then
		local name = player:get_player_name()
		awards.show_to(name, name, nil, false)
	end
end)


awards.register_achievement("vlf:stoneAge", {
	title		= S("Stone Age"),
	description	= S("Mine a stone with new pickaxe."),
	icon		= "default_cobble.png",
	type = "Advancement",
	group = "Overworld",
})
awards.register_achievement("vlf:hotStuff", {
	title		= S("Hot Stuff"),
	description	= S("Put lava in a bucket."),
	icon		= "bucket_lava.png",
	type = "Advancement",
	group = "Overworld",
})
awards.register_achievement("vlf:obsidian", {
	title		= S("Ice Bucket Challenge"),
	description	= S("Obtain an obsidian block."),
	icon		= "default_obsidian.png",
	type = "Advancement",
	group = "Overworld",
})

awards.register_achievement("vlf:hero_of_the_village", {
	title = S("Hero of the Village"),
	description = S("Successfully defend a village from a raid"),
	icon = "vlf_raids_hero_of_the_village_icon.png",
	type = "Advancement",
	group = "Adventure",
	secret = true,
	reward_xp = 100,
})

awards.register_achievement("vlf:voluntary_exile", {
	title = S("Voluntary Exile"),
	description = S("Kill a raid captain. Maybe consider staying away from the local villages for the time being..."),
	icon = "vlf_entity_effects_entity_effect_bad_omen.png",
	type = "Advancement",
	group = "Adventure",
	secret = true,
})
