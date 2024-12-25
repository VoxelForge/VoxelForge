local S = minetest.get_translator(minetest.get_current_modname())

minetest.register_craftitem("vlf_fishing:fish_raw", {
	description = S("Raw Fish"),
	_doc_items_longdesc = S("Raw fish is obtained by fishing and is a food item which can be eaten safely. Cooking it improves its nutritional value."),
	inventory_image = "vlf_fishing_fish_raw.png",
	on_place = minetest.item_eat(2),
	on_secondary_use = minetest.item_eat(2),
	groups = { food=2, eatable = 2, smoker_cookable = 1, campfire_cookable = 1 },
	_vlf_saturation = 0.4,
	_vlf_cooking_output = "vlf_fishing:fish_cooked"
})

minetest.register_craftitem("vlf_fishing:fish_cooked", {
	description = S("Cooked Fish"),
	_doc_items_longdesc = S("Mmh, fish! This is a healthy food item."),
	inventory_image = "vlf_fishing_fish_cooked.png",
	on_place = minetest.item_eat(5),
	on_secondary_use = minetest.item_eat(5),
	groups = { food=2, eatable=5 },
	_vlf_saturation = 6,
})

minetest.register_craftitem("vlf_fishing:salmon_raw", {
	description = S("Raw Salmon"),
	_doc_items_longdesc = S("Raw salmon is obtained by fishing and is a food item which can be eaten safely. Cooking it improves its nutritional value."),
	inventory_image = "vlf_fishing_salmon_raw.png",
	on_place = minetest.item_eat(2),
	on_secondary_use = minetest.item_eat(2),
	groups = { food=2, eatable = 2, smoker_cookable = 1, campfire_cookable = 1 },
	_vlf_saturation = 0.4,
	_vlf_cooking_output = "vlf_fishing:salmon_cooked"
})

minetest.register_craftitem("vlf_fishing:salmon_cooked", {
	description = S("Cooked Salmon"),
	_doc_items_longdesc = S("This is a healthy food item which can be eaten."),
	inventory_image = "vlf_fishing_salmon_cooked.png",
	on_place = minetest.item_eat(6),
	on_secondary_use = minetest.item_eat(6),
	groups = { food=2, eatable=6 },
	_vlf_saturation = 9.6,
})

minetest.register_craftitem("vlf_fishing:clownfish_raw", {
	description = S("Clownfish"),
	_doc_items_longdesc = S("Clownfish may be obtained by fishing (and luck) and is a food item which can be eaten safely."),
	inventory_image = "vlf_fishing_clownfish_raw.png",
	on_place = minetest.item_eat(1),
	on_secondary_use = minetest.item_eat(1),
	groups = { food=2, eatable = 1 },
	_vlf_saturation = 0.2,
})

local function eat_pufferfish(itemstack, placer, pointed_thing)
    local rc = vlf_util.call_on_rightclick(itemstack, placer, pointed_thing)
	if rc then return rc end

    vlf_potions.give_effect_by_level("poison", placer, 3, 60)
    vlf_potions.give_effect_by_level("nausea", placer, 2, 60)
    return minetest.item_eat(1)(itemstack, placer, pointed_thing)
end
minetest.register_craftitem("vlf_fishing:pufferfish_raw", {
	description = S("Pufferfish"),
	_tt_help = minetest.colorize(vlf_colors.YELLOW, S("Very poisonous")),
	_doc_items_longdesc = S("Pufferfish are a common species of fish and can be obtained by fishing. They can technically be eaten, but they are very bad for humans. Eating a pufferfish only restores 1 hunger point and will poison you very badly (which drains your health non-fatally) and causes serious food poisoning (which increases your hunger)."),
	inventory_image = "vlf_fishing_pufferfish_raw.png",
	on_place = eat_pufferfish,
	on_secondary_use = eat_pufferfish,
	groups = { food=2, eatable=1, brewitem = 1 },
	_vlf_saturation = 0.2,
})

minetest.register_craft({
	output = "vlf_fishing:fishing_rod",
	recipe = {
		{"","","vlf_core:stick"},
		{"","vlf_core:stick","vlf_mobitems:string"},
		{"vlf_core:stick","","vlf_mobitems:string"},
	}
})
minetest.register_craft({
	output = "vlf_fishing:fishing_rod",
	recipe = {
		{"vlf_core:stick", "", ""},
		{"vlf_mobitems:string", "vlf_core:stick", ""},
		{"vlf_mobitems:string","","vlf_core:stick"},
	}
})

