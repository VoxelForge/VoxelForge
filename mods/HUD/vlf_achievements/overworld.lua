local S = minetest.get_translator(minetest.get_current_modname())
-- 2 Missing Achievements.
awards.register_achievement("vlf_VoxelForge", {
	title = S("VoxelForge"),
	description = S("The heart and story of the game"),
	icon = "crafting_workbench_front.png",
	trigger = {
		type = "craft",
		item = "vlf_crafting_table:crafting_table",
		target = 1
	},
	type = "Advancement",
	group = "Overworld",
})
awards.register_achievement("vlf:stoneAge", {
	title		= S("Stone Age"),
	description	= S("Mine a stone with new pickaxe."),
	icon		= "default_cobble.png",
	type = "Advancement",
	group = "Overworld",
})
awards.register_achievement("vlf:buildBetterPickaxe", {
	title = S("Getting an Upgrade"),
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
awards.register_achievement("vlf:acquireIron", {
	title = S("Acquire Hardware"),
	description = S("Take an iron ingot from a furnace's output slot.\nHint: To smelt an iron ingot, put a fuel (like coal) and iron ore into a furnace."),
	icon = "default_steel_ingot.png",
	type = "Advancement",
	group = "Overworld",
})
awards.register_achievement("vlf:obtain_armor", {
	title		= S("Suit Up"),
	description	= S("Protect yourself with a piece of iron armor"),
	icon		= "vlf_armor_inv_chestplate_iron.png",
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
-- ACHIEVEMENT: Not today Thank You
awards.register_achievement("vlf:obsidian", {
	title		= S("Ice Bucket Challenge"),
	description	= S("Obtain an obsidian block."),
	icon		= "default_obsidian.png",
	type = "Advancement",
	group = "Overworld",
})
awards.register_achievement("vlf:diamonds", {
	title = S("DIAMONDS!"),
	description = S("Pick up a diamond from the floor."),
	icon = "default_diamond.png",
	type = "Advancement",
})
awards.register_achievement("vlf:buildNetherPortal", {
	title = S("We Need to Go Deeper"),
	description = S("Use obsidian and a fire starter to construct a Nether portal."),
	icon = "vlf_fire_flint_and_steel.png",
	type = "Advancement",
	group = "Overworld",
})
awards.register_achievement("vlf:shiny_gear", {
	title		= S("Cover Me with Diamonds"),
	description	= S("Diamond armor saves lives"),
	icon		= "vlf_armor_inv_chestplate_diamond.png",
	type = "Advancement",
	group = "Overworld",
})
awards.register_achievement("vlf:enchanter", {
	title = S("Enchanter"),
	description = S("Enchant an item using an Enchantment Table."),
	icon = "vlf_enchanting_book_enchanted.png",
	type = "Advancement",
	group = "Overworld",
})
-- ACHIEVEMENT: Zombie Doctor
awards.register_achievement("vlf:follow_ender_eye", {
	title = S("Eye Spy"),
	description = S("Follow an Eye of Ender"),
	icon = "vlf_end_ender_eye.png",
	type = "Advancement",
	group = "Overworld",
})
awards.register_achievement("vlf:enterEndPortal", {
	title = S("The End?"),
	description = S("Enter an end portal."),
	icon = "vlf_end_end_stone.png",
	type = "Advancement",
	group = "Overworld",
})
