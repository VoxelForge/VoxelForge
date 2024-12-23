local S = minetest.get_translator(minetest.get_current_modname())

vlf_armor.register_set({
	name = "gold",
	descriptions = {
		head = S("Golden Helmet"),
		torso = S("Golden Chestplate"),
		legs = S("Golden Leggings"),
		feet = S("Golden Boots"),
	},
	durability = 112,
	enchantability = 25,
	points = {
		head = 2,
		torso = 5,
		legs = 3,
		feet = 1,
	},
	craft_material = "vlf_core:gold_ingot",
	cook_material = "vlf_core:gold_nugget",
	sound_equip = "vlf_armor_equip_iron",
	sound_unequip = "vlf_armor_unequip_iron",
	groups = {
		golden = 1,
	},
})

vlf_armor.register_set({
	name = "chain",
	descriptions = {
		head = S("Chainmail Helmet"),
		torso = S("Chainmail Chestplate"),
		legs = S("Chainmail Leggings"),
		feet = S("Chainmail Boots"),
	},
	durability = 240,
	enchantability = 12,
	points = {
		head = 2,
		torso = 5,
		legs = 4,
		feet = 1,
	},
	repair_material = "vlf_core:iron_ingot",
	cook_material = "vlf_core:iron_nugget",
	sound_equip = "vlf_armor_equip_iron",
	sound_unequip = "vlf_armor_unequip_iron",
})

vlf_armor.register_set({
	name = "iron",
	descriptions = {
		head = S("Iron Helmet"),
		torso = S("Iron Chestplate"),
		legs = S("Iron Leggings"),
		feet = S("Iron Boots"),
	},
	durability = 240,
	enchantability = 9,
	points = {
		head = 2,
		torso = 6,
		legs = 5,
		feet = 2,
	},
	craft_material = "vlf_core:iron_ingot",
	cook_material = "vlf_core:iron_nugget",
	sound_equip = "vlf_armor_equip_iron",
	sound_unequip = "vlf_armor_unequip_iron",
})

vlf_armor.register_set({
	name = "diamond",
	descriptions = {
		head = S("Diamond Helmet"),
		torso = S("Diamond Chestplate"),
		legs = S("Diamond Leggings"),
		feet = S("Diamond Boots"),
	},
	durability = 528,
	enchantability = 10,
	points = {
		head = 3,
		torso = 8,
		legs = 6,
		feet = 3,
	},
	toughness = 2,
	craft_material = "vlf_core:diamond",
	sound_equip = "vlf_armor_equip_diamond",
	sound_unequip = "vlf_armor_unequip_diamond",
	_vlf_upgradable = true,
	_vlf_upgrade_item_material = "_netherite",
})

vlf_armor.register_set({
	name = "netherite",
	descriptions = {
		head = S("Netherite Helmet"),
		torso = S("Netherite Chestplate"),
		legs = S("Netherite Leggings"),
		feet = S("Netherite Boots"),
	},	durability = 555,
	enchantability = 10,
	points = {
		head = 3,
		torso = 8,
		legs = 6,
		feet = 3,
	},
	groups = { fire_immune=1 },
	toughness = 2,
	sound_equip = "vlf_armor_equip_diamond",
	sound_unequip = "vlf_armor_unequip_diamond",
})

vlf_armor.register_protection_enchantment({
	id = "projectile_protection",
	name = S("Projectile Protection"),
	description = S("Reduces projectile damage."),
	power_range_table = {{1, 16}, {11, 26}, {21, 36}, {31, 46}, {41, 56}},
	incompatible = {blast_protection = true, fire_protection = true, protection = true},
	factor = 2,
	damage_flag = "is_projectile",
})

vlf_armor.register_protection_enchantment({
	id = "blast_protection",
	name = S("Blast Protection"),
	description = S("Reduces explosion damage and knockback."),
	power_range_table = {{5, 13}, {13, 21}, {21, 29}, {29, 37}},
	weight = 2,
	incompatible = {fire_protection = true, protection = true, projectile_protection = true},
	factor = 2,
	damage_flag = "is_explosion",
})

vlf_armor.register_protection_enchantment({
	id = "fire_protection",
	name = S("Fire Protection"),
	description = S("Reduces fire damage."),
	power_range_table = {{5, 13}, {13, 21}, {21, 29}, {29, 37}},
	incompatible = {blast_protection = true, protection = true, projectile_protection = true},
	factor = 2,
	damage_flag = "is_fire",
})

vlf_armor.register_protection_enchantment({
	id = "protection",
	name = S("Protection"),
	description = S("Reduces most types of damage by 4% for each level."),
	power_range_table = {{1, 12}, {12, 23}, {23, 34}, {34, 45}},
	incompatible = {blast_protection = true, fire_protection = true, projectile_protection = true},
	factor = 1,
})

vlf_armor.register_protection_enchantment({
	id = "feather_falling",
	name = S("Feather Falling"),
	description = S("Reduces fall damage."),
	power_range_table = {{5, 11}, {11, 17}, {17, 23}, {23, 29}},
	factor = 3,
	primary = {combat_armor_feet = true},
	damage_type = "fall",
})

-- requires engine change
--[[vlf_enchanting.enchantments.aqua_affinity = {
	name = S("Aqua Affinity"),
	max_level = 1,
	primary = {armor_head = true},
	secondary = {},
	disallow = {non_combat_armor = true},
	incompatible = {},
	weight = 2,
	description = S("Increases underwater mining speed."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{1, 41}},
	inv_combat_tab = true,
	inv_tool_tab = false,
}]]--

vlf_enchanting.enchantments.curse_of_binding = {
	name = S("Curse of Binding"),
	max_level = 1,
	primary = {},
	secondary = {armor_head = true, armor_torso = true, armor_legs = true, armor_feet = true},
	disallow = {},
	incompatible = {},
	weight = 1,
	description = S("Item cannot be removed from armor slots except due to death, breaking or in Creative Mode."),
	curse = true,
	on_enchant = function() end,
	requires_tool = false,
	treasure = true,
	power_range_table = {{25, 50}},
	inv_combat_tab = true,
	inv_tool_tab = false,
}

vlf_enchanting.enchantments.thorns = {
	name = S("Thorns"),
	max_level = 3,
	primary = {combat_armor_chestplate = true},
	secondary = {combat_armor = true},
	disallow = {},
	incompatible = {},
	weight = 1,
	description = S("Reflects some of the damage taken when hit, at the cost of reducing durability with each proc."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{10, 61}, {30, 71}, {50, 81}},
	inv_combat_tab = true,
	inv_tool_tab = false,
}

-- Elytra

minetest.register_tool("vlf_armor:elytra", {
	description = S("Elytra"),
	_doc_items_longdesc = vlf_armor.longdesc,
	_doc_items_usagehelp = vlf_armor.usage,
	inventory_image = "vlf_armor_inv_elytra.png",
	groups = {armor = 1, armor_torso = 1, non_combat_torso = 1, vlf_armor_uses = 10, elytra = 1, enchantability = 9},
	sounds = {
		_vlf_armor_equip = "vlf_armor_equip_leather",
		_vlf_armor_unequip = "vlf_armor_unequip_leather",
	},
	on_place = vlf_armor.equip_on_use,
	on_secondary_use = vlf_armor.equip_on_use,
	_vlf_armor_element = "torso",
	_vlf_armor_texture = "vlf_armor_elytra.png"
})

-- Function to check the player's entire inventory for the required items
local function check_inventory_for_required_items(player)
	local inventory = player:get_inventory()
	local player_name = player:get_player_name()

	local armor_found = {
		iron = false,
		diamond = false,
		netherite = { chest = false, boots = false, helmet = false, leggings = false }
	}

	-- Loop through all the lists in the player's inventory
	for list_name, list in pairs(inventory:get_lists()) do
		for i = 1, inventory:get_size(list_name) do
			local stack = inventory:get_stack(list_name, i)
			local item_name = stack:get_name()

			-- Check for iron armor
			if not vlf_achievements.award_unlocked(player_name, "vlf:obtain_armor") then
				if item_name == "vlf_armor:chestplate_iron" or item_name == "vlf_armor:boots_iron"
				or item_name == "vlf_armor:helmet_iron" or item_name == "vlf_armor:leggings_iron" then
					armor_found.iron = true
				end
			end

			-- Check for diamond armor
			if not vlf_achievements.award_unlocked(player_name, "vlf:shiny_gear") then
				if item_name == "vlf_armor:chestplate_diamond" or item_name == "vlf_armor:boots_diamond"
				or item_name == "vlf_armor:helmet_diamond" or item_name == "vlf_armor:leggings_diamond" then
					armor_found.diamond = true
				end
			end

			-- Check for netherite armor
			if not vlf_achievements.award_unlocked(player_name, "vlf:netherite_armor") then
				if item_name == "vlf_armor:chestplate_netherite" then
					armor_found.netherite.chest = true
				elseif item_name == "vlf_armor:boots_netherite" then
					armor_found.netherite.boots = true
				elseif item_name == "vlf_armor:helmet_netherite" then
					armor_found.netherite.helmet = true
				elseif item_name == "vlf_armor:leggings_netherite" then
					armor_found.netherite.leggings = true
				end
			end
		end
	end

	-- Unlock achievements if conditions are met
	if armor_found.iron and not vlf_achievements.award_unlocked(player_name, "vlf:obtain_armor") then
		awards.unlock(player_name, "vlf:obtain_armor")
	end

	if armor_found.diamond and not vlf_achievements.award_unlocked(player_name, "vlf:shiny_gear") then
		awards.unlock(player_name, "vlf:shiny_gear")
	end

	if armor_found.netherite.chest and armor_found.netherite.boots and armor_found.netherite.helmet and armor_found.netherite.leggings
	and not vlf_achievements.award_unlocked(player_name, "vlf:netherite_armor") then
		awards.unlock(player_name, "vlf:netherite_armor")
	end
end

-- This function will handle inventory actions like putting, moving, or taking
minetest.register_on_player_inventory_action(function(player, action, inventory, info)
	if action == "put" or action == "move" or action == "take" then
		check_inventory_for_required_items(player)
	end
end)
