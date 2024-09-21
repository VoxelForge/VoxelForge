local S = minetest.get_translator(minetest.get_current_modname())
-- 18 achievements missing
awards.register_achievement("vlf:husbandry", {
	title = S("Husbandry"),
	description = S("The world is full of friends and foodt"),
	icon = "vlf_entity_effects_effect_bad_omen.png",
	type = "Advancement",
	group = "Adventure",
})
awards.register_achievement("vlf:bee_our_guest", {
	title = S("Bee Our Guest"),
	description = S("Use a campfire to collect a bottle of honey from a beehive without aggrivating the bees inside."),
	icon = "vlf_honey_honey_bottle.png",
	type = "Advancement",
	group = "Husbandry",
})
-- ACHIEVEMENT: the parrots and the bats
-- ACHIEVEMENT: You've got a friend in me
-- ACHIEVEMENT: Whatever floats your boat
-- ACHIEVEMENT: Best friends forever
awards.register_achievement("vlf_itemframes:glowframe", {
	title = S("Glow and Behold!"),
	description = S("Craft a glow item frame."),
	icon = "vlf_itemframes_glow_item_frame.png",
	trigger = {
		type = "craft",
		item = "vlf_itemframes:glow_item_frame",
		target = 1
	},
	type = "Advancement",
	group = "Husbandry",
})
awards.register_achievement("vlf:fishyBusiness", {
	title = S("Fishy Business"),
	description = S("Catch a fish."),
	icon = "vlf_fishing_fishing_rod.png",
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
-- ACHIEVEMENT: Bukkit Bukkit
-- ACHIEVEMENT: Smells interesting
-- ACHIEVEMENT: a seedy place
awards.register_achievement("vlf:wax_on", {
	title = S("Wax On"),
	description = S("Apply honeycomb to a copper block to protect it from the elements."),
	icon = "vlf_honey_honeycomb.png",
	type = "Advancement",
	group = "Husbandry",
})
-- ACHIEVEMENT: Two by Two
-- ACHIEVEMENT: birthday song: secret
-- ACHIEVEMENT: A complete catalogue
awards.register_achievement("vlf:tacticalFishing", {
	title = S("Tactical Fishing"),
	description = S("Catch a fish... without a fishing rod!"),
	icon = "pufferfish_bucket.png",
	type = "Advancement",
	group = "Husbandry",
})
-- ACHIEVEMENT: When the squad hops into town
-- ACHIEVEMENT: Little Sniffs
-- ACHIEVEMENT: A balanced diet
awards.register_achievement("vlf:seriousDedication", {
	title = S("Serious Dedication"),
	description = S("Use a Netherite Ingot to upgrade a hoe, and then completely reevaluate your life choices."),
	icon = "farming_tool_netheritehoe.png",
	type = "Challenge",
	group = "Husbandry",
})
awards.register_achievement("vlf:wax_off", {
	title = S("Wax Off"),
	description = S("Scrape wax off of a copper block."),
	icon = "default_tool_stoneaxe.png",
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
-- ACHIEVEMENT: With our powers combined.
-- ACHIEVEMENT: Planting the Past.
-- ACHIEVEMENT: The healing power of friendship
awards.register_achievement("vlf:cookFish", {
	title = S("Delicious Fish"),
	description = S("Take a cooked fish from a furnace.\nHint: Use a fishing rod to catch a fish and cook it in a furnace."),
	icon = "vlf_fishing_fish_cooked.png",
	type = "Advancement",
	group = "Husbandry",
})
awards.register_achievement("vlf:repair_wolf_armor", {
	title = S("Good as New"),
	description = S("Repair a damaged Wolf Armor using Armadillo Scutes"),
	icon = "mobs_mc_wolf_armor_inventory.png^[multiply:#ffbdb9",
	type = "Advancement",
	group = "Husbandry",
})
-- ACHIEVEMENT: The Whole Pack
awards.register_achievement("vlf:remove_wolf_armor", {
	title = S("Shear Brilliance"),
	description = S("Remove Wolf Armor from a Wolf using Shears"),
	icon = "default_tool_shears.png",
	type = "Advancement",
	group = "Husbandry",
})
