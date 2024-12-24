local S = minetest.get_translator(minetest.get_current_modname())
-- 15 achievements missing
awards.register_achievement("vlf:theNether", {
	title = S("The Nether"),
	description = S("Bring summer clothes.\nHint: Enter the Nether."),
	icon = "vlf_nether_netherrack.png",
	type = "Advancement",
	group = "Nether",
})
-- ACHIEVEMENT: Return to Sender
-- ACHIEVEMENT: Those were the Days
awards.register_achievement("vlf:hiddenInTheDepths", {
	title = S("Hidden in the Depths"),
	description = S("Pick up an Ancient Debris from the floor."),
	icon = "vlf_nether_ancient_debris_side.png",
	type = "Advancement",
	group = "Nether",
})
-- ACHIEVEMENT: Subspace Bubble
awards.register_achievement("vlf:whosCuttingOnions", {
	title = S("Who is Cutting Onions?"),
	description = S("Pick up a crying obsidian from the floor."),
	icon = "default_obsidian.png^vlf_core_crying_obsidian.png",
	type = "Advancement",
	group = "Nether",
})
-- ACHIEVEMENT: Oh Shiny
-- ACHIEVEMENT: This boat has legs
-- ACHIEVEMENT: Uneasy Alliance
-- ACHIEVEMENT: War Pigs
awards.register_achievement("vlf:countryLode", {
	title = S("Country Lode, Take Me Home"),
	description = S("Use a compass on a Lodestone."),
	icon = "lodestone_side4.png",
	type = "Advancement",
	group = "Nether",
})
awards.register_achievement("vlf:netherite_armor", {
	title		= S("Cover Me in Debris"),
	description	= S("Get a full suit of Netherite armor"),
	icon		= "vlf_armor_inv_chestplate_netherite.png",
	type = "Challenge",
	group = "Overworld",
	reward_xp = 100,
})
-- ACHIEVEMENT: Spooky scary Skeleton
awards.register_achievement("vlf:blazeRod", {
	title = S("Into Fire"),
	description = S("Pick up a blaze rod from the floor."),
	icon = "vlf_mobitems_blaze_rod.png",
	type = "Advancement",
	group = "Nether",
})
awards.register_achievement("vlf:notQuiteNineLives", {
	title = S('Not Quite "Nine" Lives'),
	description = S("Charge a Respawn Anchor to the maximum."),
	icon = "respawn_anchor_side4.png",
	type = "Advancement",
	group = "Nether",
})
-- ACHIEVEMENT: Feels like home
-- ACHIEVEMENT: Hot tourist destinations
awards.register_achievement("vlf:witheringHeights", {
	title = S("Withering Heights"),
	description = S("Summon the wither from the dead."),
	icon = "vlf_mobitems_nether_star.png",
	type = "Advancement",
	group = "Nether",
})
-- Triggered in vlf_brewing
awards.register_achievement("vlf:localBrewery", {
	title = S("Local Brewery"),
	description = S("Brew a Potion.\nHint: Take a effect or glass bottle out of the brewing stand."),
	icon = "vlf_potions_potion_overlay.png^[colorize:#F82423:"..tostring(127).."^vlf_potions_potion_bottle.png",
	type = "Advancement",
	group = "Nether",
})
--Triggered in vlf_beacons
awards.register_achievement("vlf:beacon", {
	title = S("Bring Home the Beacon"),
	description = S("Use a beacon."),
	icon = "beacon_achievement_icon.png",
	type = "Advancement",
	group = "Nether",
})
-- ACHIEVEMENT: A furious cocktail
awards.register_achievement("vlf:maxed_beacon", {
	title = S("Beaconator"),
	description = S("Use a fully powered beacon."),
	icon = "beacon_achievement_icon.png",
	type = "Goal",
	group = "Nether",
})
-- ACHIEVEMENT: How did we get here ?
