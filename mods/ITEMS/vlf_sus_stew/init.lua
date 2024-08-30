local S = minetest.get_translator(minetest.get_current_modname())

--                                          ____________________________
--_________________________________________/    Variables & Functions    \_________

local eat = minetest.item_eat(6, "vlf_core:bowl") --6 hunger points, player receives vlf_core:bowl after eating

local flower_entity_effect = {
	[ "vlf_flowers:allium" ] = "fire_resistance",
	[ "vlf_flowers:azure_bluet" ] = "blindness",
	[ "vlf_flowers:lily_of_the_valley" ] = "poison",
	[ "vlf_flowers:blue_orchid" ] = "saturation",
	[ "vlf_flowers:dandelion" ] = "saturation",
	[ "vlf_flowers:cornflower" ] = "jump",
	[ "vlf_flowers:oxeye_daisy" ] = "regeneration",
	[ "vlf_flowers:poppy" ] = "night_vision",
	[ "vlf_flowers:wither_rose" ] = "withering",
	[ "vlf_flowers:tulip_orange" ] = "weakness",
	[ "vlf_flowers:tulip_pink" ] = "weakness",
	[ "vlf_flowers:tulip_red" ] = "weakness",
	[ "vlf_flowers:tulip_white" ] = "weakness",
}

local entity_effects = {
	[ "fire_resistance" ] = function(itemstack, placer, pointed_thing)
		vlf_entity_effects.give_entity_effect("fire_resistance", placer, 1, 4)
		return eat(itemstack, placer, pointed_thing)
	end,

	[ "blindness" ] = function(itemstack, placer, pointed_thing)
		vlf_entity_effects.give_entity_effect("blindness", placer, 1, 8)
		return eat(itemstack, placer, pointed_thing)
	end,

	[ "poison" ] = function(itemstack, placer, pointed_thing)
		vlf_entity_effects.give_entity_effect_by_level("poison", placer, 1, 12)
		return eat(itemstack, placer, pointed_thing)
	end,

	[ "saturation" ] = function(itemstack, placer, pointed_thing, player)
		vlf_entity_effects.give_entity_effect_by_level("saturation", placer, 1, 0.5)
		return eat(itemstack, placer, pointed_thing)
	end,

	["jump"] = function(itemstack, placer, pointed_thing)
		vlf_entity_effects.give_entity_effect_by_level("leaping", placer, 1, 6)
		return eat(itemstack, placer, pointed_thing)
	end,

	["regeneration"] = function(itemstack, placer, pointed_thing)
		vlf_entity_effects.give_entity_effect_by_level("regeneration", placer, 1, 8)
		return eat(itemstack, placer, pointed_thing)
	end,

	["withering"] = function(itemstack, placer, pointed_thing)
		vlf_entity_effects.give_entity_effect_by_level("withering", placer, 1, 8)
		return eat(itemstack, placer, pointed_thing)
	end,

	["weakness"] = function(itemstack, placer, pointed_thing)
		vlf_entity_effects.give_entity_effect_by_level("weakness", placer, 1, 9)
		return eat(itemstack, placer, pointed_thing)
	end,

	["night_vision"] = function(itemstack, placer, pointed_thing)
		vlf_entity_effects.give_entity_effect("night_vision", placer, 1, 5)
		return eat(itemstack, placer, pointed_thing)
	end,
}

local function get_random_entity_effect()
	local keys = {}
	for k in pairs(entity_effects) do
		table.insert(keys, k)
	end
	return entity_effects[keys[math.random(#keys)]]
end

local function eat_stew(itemstack, placer, pointed_thing)
	local rc = vlf_util.call_on_rightclick(itemstack, placer, pointed_thing)
	if rc then return rc end
	local e = itemstack:get_meta():get_string("entity_effect")
	local f = entity_effects[e]
	if not f then
	    f = get_random_entity_effect()
	end
	if f(itemstack, placer, pointed_thing) then
	    return "vlf_core:bowl"
	end
end

minetest.register_on_craft(function(itemstack, _, old_craft_grid, _)
	if itemstack:get_name() ~= "vlf_sus_stew:stew" then return end
	for f,e in pairs(flower_entity_effect) do
		for _,it in pairs(old_craft_grid) do
			if it:get_name() == f then
				itemstack:get_meta():set_string("entity_effect",e)
				return itemstack
			end
		end
	end
end)

minetest.register_craftitem("vlf_sus_stew:stew",{
	description = S("Suspicious Stew"),
	inventory_image = "sus_stew.png",
	stack_max = 1,
	on_place = eat_stew,
	on_secondary_use = eat_stew,
	groups = { food = 2, eatable = 4, can_eat_when_full = 1, not_in_creative_inventory=1,},
	_vlf_saturation = 7.2,
})

vlf_hunger.register_food("vlf_sus_stew:stew",6, "vlf_core:bowl")

--compat with old (vlf5) sus_stew
minetest.register_alias("vlf_sus_stew:poison_stew", "vlf_sus_stew:stew")
minetest.register_alias("vlf_sus_stew:hunger_stew", "vlf_sus_stew:stew")
minetest.register_alias("vlf_sus_stew:jump_boost_stew", "vlf_sus_stew:stew")
minetest.register_alias("vlf_sus_stew:regneration_stew", "vlf_sus_stew:stew")
minetest.register_alias("vlf_sus_stew:night_vision_stew", "vlf_sus_stew:stew")

--										 ______________
--_________________________________________/	Crafts	\________________________________

minetest.register_craft({
	type = "shapeless",
	output = "vlf_sus_stew:stew",
	recipe = {"vlf_mushrooms:mushroom_red", "vlf_mushrooms:mushroom_brown", "vlf_core:bowl", "vlf_flowers:allium"},
})

minetest.register_craft({
	type = "shapeless",
	output = "vlf_sus_stew:stew",
	recipe = {"vlf_mushrooms:mushroom_red", "vlf_mushrooms:mushroom_brown", "vlf_core:bowl", "vlf_flowers:lily_of_the_valley"},
})

minetest.register_craft({
	type = "shapeless",
	output = "vlf_sus_stew:stew",
	recipe = {"vlf_mushrooms:mushroom_red", "vlf_mushrooms:mushroom_brown", "vlf_core:bowl", "vlf_flowers:blue_orchid"},
})

minetest.register_craft({
	type = "shapeless",
	output = "vlf_sus_stew:stew",
	recipe = {"vlf_mushrooms:mushroom_red", "vlf_mushrooms:mushroom_brown", "vlf_core:bowl", "vlf_flowers:dandelion"} ,
})

minetest.register_craft({
	type = "shapeless",
	output = "vlf_sus_stew:stew",
	recipe = {"vlf_mushrooms:mushroom_red", "vlf_mushrooms:mushroom_brown", "vlf_core:bowl", "vlf_flowers:cornflower"},
})

minetest.register_craft({
	type = "shapeless",
	output = "vlf_sus_stew:stew",
	recipe = {"vlf_mushrooms:mushroom_red", "vlf_mushrooms:mushroom_brown", "vlf_core:bowl", "vlf_flowers:oxeye_daisy"},
})

minetest.register_craft({
	type = "shapeless",
	output = "vlf_sus_stew:stew",
	recipe = {"vlf_mushrooms:mushroom_red", "vlf_mushrooms:mushroom_brown", "vlf_core:bowl", "vlf_flowers:poppy"},
})
