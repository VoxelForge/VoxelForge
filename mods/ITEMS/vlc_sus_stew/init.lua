vlc_sus_stew = {}
vlc_sus_stew.registered_stews = {}
local item_effect = {}
local S = minetest.get_translator(minetest.get_current_modname())

local function get_random_effect()
	local keys = {}
	for k in pairs(vlc_sus_stew.registered_stews) do
		table.insert(keys, k)
	end
	local e = keys[math.random(#keys)]
	return vlc_sus_stew.registered_stews[e],e
end

local function eat_stew(itemstack, placer, pointed_thing)
	local rc = vlc_util.call_on_rightclick(itemstack, placer, pointed_thing)
	if rc then return rc end
	local e = itemstack:get_meta():get_string("effect")
	local f = vlc_sus_stew.registered_stews[e]
	if not f then
		f, e = get_random_effect()
	end
	if f(itemstack,placer,pointed_thing,e) then
		return "vlc_core:bowl"
	end
end

minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
	if itemstack:get_name() ~= "vlc_sus_stew:stew" then return end
	for f,e in pairs(item_effect) do
		for _,it in pairs(old_craft_grid) do
			if it:get_name() == f then
				itemstack:get_meta():set_string("effect",e)
				return itemstack
			end
		end
	end
end)

function vlc_sus_stew.register_stew(name,recipe_item,effect_func)
	vlc_sus_stew.registered_stews[name] = effect_func
	item_effect[recipe_item] = name
	minetest.register_craft({
		type = "shapeless",
		output = "vlc_sus_stew:stew",
		recipe = {"vlc_mushrooms:mushroom_red", "vlc_mushrooms:mushroom_brown", "vlc_core:bowl", recipe_item },
	})
end

local eat = minetest.item_eat(6, "vlc_core:bowl")

local function hunger_effect(itemstack, placer, pointed_thing)
	vlc_hunger.item_eat(6, "vlc_core:bowl", 3.5, 0, 100)
	return eat(itemstack, placer, pointed_thing)
end

local function potion_effect(itemstack, placer, pointed_thing,effect)
	if vlc_potions[effect.."_func"] then
		vlc_potions[effect.."_func"](placer, 1, 6)
	end
	return eat(itemstack, placer, pointed_thing)
end

vlc_sus_stew.register_stew("fire_resistance","vlc_flowers:allium",potion_effect)
--vlc_sus_stew.register_stew("blindness","vlc_flowers:azure_bluet",potion_effect) -- effect not implemented
vlc_sus_stew.register_stew("hunger","vlc_flowers:blue_orchid",hunger_effect)
vlc_sus_stew.register_stew("leaping","vlc_flowers:cornflower",potion_effect)
vlc_sus_stew.register_stew("hunger","vlc_flowers:dandelion",hunger_effect)
vlc_sus_stew.register_stew("poison","vlc_flowers:lily_of_the_valley",potion_effect)
vlc_sus_stew.register_stew("regeneration","vlc_flowers:oxeye_daisy",potion_effect)
vlc_sus_stew.register_stew("night_vision","vlc_flowers:poppy",potion_effect)
--vlc_sus_stew.register_stew("weakness","vlc_flowers:tulip_orange",potion_effect) -- effect not implemented
--vlc_sus_stew.register_stew("weakness","vlc_flowers:tulip_pink",potion_effect) -- effect not implemented
--vlc_sus_stew.register_stew("weakness","vlc_flowers:tulip_red",potion_effect) -- effect not implemented
--vlc_sus_stew.register_stew("weakness","vlc_flowers:tulip_white",potion_effect) -- effect not implemented
vlc_sus_stew.register_stew("harming","vlc_flowers:wither_rose",potion_effect) -- in place of real wither effect

minetest.register_craftitem("vlc_sus_stew:stew",{
	description = S("Suspicious Stew"),
	inventory_image = "sus_stew.png",
	stack_max = 1,
	on_place = eat_stew,
	on_secondary_use = eat_stew,
	groups = { food = 2, eatable = 4, can_eat_when_full = 1, not_in_creative_inventory=1,},
	_vlc_saturation = 7.2,
})

vlc_hunger.register_food("vlc_sus_stew:stew",6, "vlc_core:bowl")

--compat with old (vlc5) sus_stew
minetest.register_alias("vlc_sus_stew:poison_stew", "vlc_sus_stew:stew")
minetest.register_alias("vlc_sus_stew:hunger_stew", "vlc_sus_stew:stew")
minetest.register_alias("vlc_sus_stew:jump_boost_stew", "vlc_sus_stew:stew")
minetest.register_alias("vlc_sus_stew:regneration_stew", "vlc_sus_stew:stew")
minetest.register_alias("vlc_sus_stew:night_vision_stew", "vlc_sus_stew:stew")
