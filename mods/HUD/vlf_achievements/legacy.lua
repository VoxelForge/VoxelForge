local S = minetest.get_translator(minetest.get_current_modname())
-- Removed from MC. Thus, in the legacy file.

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
awards.register_achievement("vlf:mineWood", {
	title = S("Getting Wood"),
	description = S("Pick up a wood item from the ground.\nHint: Punch a tree trunk until it pops out as an item."),
	icon = "default_tree.png",
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
awards.register_achievement("vlf:killCow", {
	title = S("Cow Tipper"),
	description = S("Pick up leather from the floor.\nHint: Cows and some other animals have a chance to drop leather, when killed."),
	icon = "vlf_mobitems_leather.png",
	type = "Advancement",
	group = "Adventure",
})

awards.register_achievement("vlf:onARail", {
	title = S("On A Rail"),
	description = S("Travel by minecart for at least 1000 meters from your starting point in a single ride."),
	icon = "default_rail.png",
	type = "Challenge",
	group = "Adventure",
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
awards.register_achievement("vlf:cookFish", {
	title = S("Delicious Fish"),
	description = S("Take a cooked fish from a furnace.\nHint: Use a fishing rod to catch a fish and cook it in a furnace."),
	icon = "vlf_fishing_fish_cooked.png",
	type = "Advancement",
	group = "Husbandry",
})
