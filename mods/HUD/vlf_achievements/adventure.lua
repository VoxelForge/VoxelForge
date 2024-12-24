local S = minetest.get_translator(minetest.get_current_modname())
-- 23 achievements missing.
awards.register_achievement("vlf:adventure", {
	title = S("Adventure"),
	description = S("Adventure, exploration and combat"),
	icon = "default_paper.png",
	type = "Advancement",
	group = "Adventure",
})
awards.register_achievement("vlf:voluntary_exile", {
	title = S("Voluntary Exile"),
	description = S("Kill a raid captain. Maybe consider staying away from the local villages for the time being..."),
	icon = "vlf_potions_effect_bad_omen.png",
	type = "Advancement",
	group = "Adventure",
	secret = true,
})
awards.register_achievement("vlf:spyglass_at_parrot", {
	title = S("Is It a Bird?"),
	description = S("Look at a Parrot through a Spyglass"),
	icon = "vlf_spyglass.png",
	type = "Advancement",
	group = "Adventure",
})
awards.register_achievement("vlf:monsterHunter", {
	title = S("Monster Hunter"),
	description = S("Kill a monster."),
	icon = "mobs_mc_spawn_icon_zombie.png",
	type = "Advancement",
	group = "Adventure",
})
-- ACHIEVEMENT: The power of Books
awards.register_achievement("vlf:whatAdeal", {
	title = S("What A Deal!"),
	description = S("Successfully trade with a Villager."),
	icon = "vlf_core_emerald.png",
	type = "Advancement",
	group = "Adventure",
})
awards.register_achievement("vlf:trim", {
	title = S("Crafting a New Look"),
	description = S("Craft a trimmed armor at a Smithing Table"),
	icon = "dune_armor_trim_smithing_template.png",
	type = "Advancement",
	group = "Adventure",
})
-- ACHIEVEMENT: sticky situation
awards.register_achievement("vlf:ol_betsy", {
	title = S("Ol' Betsy"),
	description = S("Shoot a Crossbow"),
	icon = "vlf_bows_crossbow.png",
	type = "Advancement",
	group = "Adventure",
})
-- ACHIEVEMENT: Surge protector
awards.register_achievement("vlf:fall_from_world_height", {
	title = S("Caves & Cliffs"),
	description = S("Free fall from the top of the world (build limit) to the bottom of the world and survive"),
	icon = "bucket_water.png",
	type = "Advancement",
	group = "Adventure",
})
-- ACHIEVEMENT: Respecting the Remnants
-- ACHIEVEMENT: Sneak 100
awards.register_achievement("vlf:sweetDreams", {
	title = S("Sweet Dreams"),
	description = S("Sleep in a bed to change your respawn point."),
	icon = "vlf_beds_bed_red_inv.png",
	type = "Advancement",
	group = "Adventure",
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
awards.register_achievement("vlf:spyglass_at_ghast", {
	title = S("Is It a Balloon?"),
	description = S("Look at a Ghast through a Spyglass"),
	icon = "vlf_spyglass.png",
	type = "Advancement",
	group = "Adventure",
})
-- ACHIEVEMENT: A throwaway joke
-- ACHIEVEMENT: It spreads.
-- ACHIEVEMENT: Take aim.
-- ACHIEVEMENT: Monsters hunted.
awards.register_achievement("vlf:postMortal", {
	title = S("Postmortal"),
	description = S("Use a Totem of Undying to cheat death."),
	icon = "vlf_totems_totem.png",
	type = "Goal",
	group = "Adventure",
})
-- ACHIEVEMENT: Hired help.
awards.register_achievement("vlf:trade_at_world_height", {
	title = S("Star Trader"),
	description = S("Trade with a Villager at the build height limit"),
	icon = "vlf_core_emerald.png",
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
-- ACHIEVEMENT: two birds one arrow.
-- ACHIEVEMENT: who's the pillager now ?
-- ACHIEVEMENT: Arbalistic
-- ACHIEVEMENT: careful restoration
-- ACHIEVEMENT: Adventuring time
awards.register_achievement("vlf:play_jukebox_in_meadows", {
	title = S("Sound of Music"),
	description = S("Make the Meadows come alive with the sound of music from a Jukebox"),
	icon = "[inventorycube{vlf_jukebox_top.png{vlf_jukebox_side.png{vlf_jukebox_side.png",
	type = "Advancement",
	group = "Adventure",
})
awards.register_achievement("vlf:walk_on_powder_snow_with_leather_boots", {
	title = S("Light as a Rabbit"),
	description = S("Walk on Powder Snow... without sinking in it"),
	icon = "vlf_armor_inv_boots_leather.png",
	type = "Advancement",
	group = "Adventure",
})
awards.register_achievement("vlf:spyglass_at_dragon", {
	title = S("Is It a Plane?"),
	description = S("Look at the Ender Dragon through a Spyglass"),
	icon = "vlf_spyglass.png",
	type = "Advancement",
	group = "Adventure",
})
-- ACHIEVEMENT: Very Very frightening
awards.register_achievement("vlf:snipeSkeleton", {
	title = S("Sniper Duel"),
	-- TODO: The range should be 50, not 20. Nerfed because of reduced bow range
	description = S("Kill a skeleton, wither skeleton or stray by bow and arrow from a distance of at least 20 meters."),
	icon = "vlf_bows_bow.png",
	type = "Challenge",
	group = "Adventure",
	reward_xp = 50,
})
-- ACHIEVEMENT: Bullseye
awards.register_achievement("vlf:brush_armadillo", {
	title = S("Isn't It Scute?"),
	description = S("Get Armadillo Scutes from an Armadillo using a Brush"),
	icon = "vlf_mobitems_armadillo_scute.png",
	type = "Advancement",
	group = "Adventure",
})
-- ACHIEVEMENT: VoxelForge: Trial(s) Edition
-- ACHIEVEMENT: Crafters Crafting Crafters
awards.register_achievement("vlf:lighten_up", {
	title = S("Lighten Up"),
	description = S("Scrape a Copper Bulb with an Axe to make it brighter"),
	icon = "vlf_copper_copper_bulb_volumetric.png",
	type = "Advancement",
	group = "Adventure",
})
-- ACHIEVEMENT: Who needs Rockets?
awards.register_achievement("vlf:under_lock_and_key", {
	title = S("Under Lock and Key"),
	description = S("Use a Trial Key on a Vault"),
	icon = "vlf_trials_trial_key.png^(vlf_trials_trial_key_desat.png^[multiply:#FF896E)",
	type = "Advancement",
	group = "Adventure",
})
awards.register_achievement("vlf:revaulting", {
	title = S("Revaulting"),
	description = S("Use an Ominous Trial Key on an Ominous Vault"),
	icon = "vlf_trials_trial_key_ominous.png^(vlf_trials_trial_key_desat.png^[multiply:#98FFD9)",
	type = "Goal",
	group = "Adventure",
})
-- ACHIEVEMENT: blowback
awards.register_achievement("vlf:overoverkill", {
	title = S("Over-Overkill"),
	description = S("Deal 50 hearts of damage in a single hit using the Mace"),
	icon = "vlf_tools_mace.png",
	type = "Challenge",
	group = "Adventure",
})
