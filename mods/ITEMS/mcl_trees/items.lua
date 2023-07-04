local S = minetest.get_translator(minetest.get_current_modname())
local enable_fapples = minetest.settings:get_bool("mcl_enable_fapples",true)

minetest.register_craftitem("mcl_trees:paper", {
	description = S("Paper"),
	_doc_items_longdesc = S("Paper is used to craft books and maps."),
	inventory_image = "mcl_trees_paper.png",
	groups = { craftitem=1 },
})

minetest.register_craftitem("mcl_trees:bowl",{
	description = S("Bowl"),
	_doc_items_longdesc = S("Bowls are mainly used to hold tasty soups."),
	inventory_image = "mcl_trees_bowl.png",
	groups = { craftitem = 1 },
})

minetest.register_craftitem("mcl_trees:stick", {
	description = S("Stick"),
	_doc_items_longdesc = S("Sticks are a very versatile crafting material; used in countless crafting recipes."),
	_doc_items_hidden = false,
	inventory_image = "mcl_trees_stick.png",
	groups = { craftitem=1, stick=1 },
	_mcl_toollike_wield = true,
})

minetest.register_craftitem("mcl_trees:charcoal", {
	description = S("Charcoal"),
	_doc_items_longdesc = S("Charcoal is an alternative furnace fuel created by cooking wood in a furnace. It has the same burning time as coal and also shares many of its crafting recipes, but it can not be used to create coal blocks."),
	_doc_items_hidden = false,
	inventory_image = "mcl_trees_charcoal.png",
	groups = { craftitem=1, coal=1 },
})

minetest.register_craftitem("mcl_trees:apple", {
	description = S("Apple"),
	_doc_items_longdesc = S("Apples are food items which can be eaten."),
	wield_image = "mcl_trees_apple.png",
	inventory_image = "mcl_trees_apple.png",
	on_place = minetest.item_eat(4),
	on_secondary_use = minetest.item_eat(4),
	groups = { food = 2, eatable = 4, compostability = 65 },
	_mcl_saturation = 2.4,
})

local gapple_hunger_restore = minetest.item_eat(4)

local function eat_gapple(itemstack, placer, pointed_thing)
	if pointed_thing.type == "node" then
		local node = minetest.get_node(pointed_thing.under)
		if placer and not placer:get_player_control().sneak then
			if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
				return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, placer, itemstack) or itemstack
			end
		end
	elseif pointed_thing.type == "object" then
		return itemstack
	end

	local regen_duration, absorbtion_factor = 5, 1
	if itemstack:get_name() == "mcl_trees:apple_gold_enchanted" then
		regen_duration, absorbtion_factor = 20, 4
		mcl_potions.fire_resistance_func(placer, 1, 300)
		mcl_potions.leaping_func(placer, 1, 300)
		if enable_fapples then
			mcl_potions.swiftness_func(placer, absorbtion_factor, 120)
		end
	end
	-- TODO: Absorbtion
	mcl_potions.regeneration_func(placer, 2, regen_duration)
	return gapple_hunger_restore(itemstack, placer, pointed_thing)
end

minetest.register_craftitem("mcl_trees:apple_gold", {
	-- TODO: Add special highlight color
	description = S("Golden Apple"),
	_doc_items_longdesc = S("Golden apples are precious food items which can be eaten."),
	wield_image = "mcl_trees_apple_golden.png",
	inventory_image = "mcl_trees_apple_golden.png",
	on_place = eat_gapple,
	on_secondary_use = eat_gapple,
	groups = { food = 2, eatable = 4, can_eat_when_full = 1 },
	_mcl_saturation = 9.6,
})

minetest.register_craftitem("mcl_trees:apple_gold_enchanted", {
	description = S("Enchanted Golden Apple"),
	_doc_items_longdesc = S("Golden apples are precious food items which can be eaten."),
	wield_image = "mcl_trees_apple_golden.png" .. mcl_enchanting.overlay,
	inventory_image = "mcl_trees_apple_golden.png" .. mcl_enchanting.overlay,
	on_place = eat_gapple,
	on_secondary_use = eat_gapple,
	groups = { food = 2, eatable = 4, can_eat_when_full = 1 },
	_mcl_saturation = 9.6,
})