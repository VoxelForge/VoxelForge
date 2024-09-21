local S = minetest.get_translator(minetest.get_current_modname())
-- 4 Achievements missing.
awards.register_achievement("vlf:enterEndPortal", {
	title = S("The End"),
	description = S("Or the beginning?"),
	icon = "vlf_end_end_stone.png",
	type = "Advancement",
	group = "Overworld",
})
awards.register_achievement("vlf:freeTheEnd", {
	title = S("Free the End"),
	description = S("Good Luck!"),
	icon = "(spawn_egg.png^[multiply:#252525)^(spawn_egg_overlay.png^[multiply:#b313c9)", -- TODO: Dragon Head Icon
	type = "Advancement",
	group = "End",
})
awards.register_achievement("vlf:PickUpDragonEgg", {
	title = S("The Next Generation"),
	description = S("Hold the Dragon Egg.\nHint: Pick up the egg from the ground and have it in your inventory."),
	icon = "vlf_end_dragon_egg.png",
	type = "Goal",
	group = "End",
})
-- ACHIEVEMENT: remote gateway
awards.register_achievement("vlf:theEndAgain", {
	title = S("The End... Again..."),
	description = S("Respawn the Ender Dragon."),
	icon = "vlf_end_crystal_item.png",
	type = "Goal",
	group = "End",
})
-- ACHIEVEMENT: You need a mint
-- ACHIEVEMENT: The city at the end of the game
awards.register_achievement("vlf:skysTheLimit", {
	title = S("Sky's the Limit"),
	description = S("Find the elytra and prepare to fly above and beyond!"),
	icon = "vlf_armor_inv_elytra.png",
	type = "Goal",
	group = "End",
}) -- TODO: Make also unlock when moved to inventory, not just picking up from ground
-- ACHIEVEMENT: Great view from up here
