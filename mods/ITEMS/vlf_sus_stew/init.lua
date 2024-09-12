vlf_sus_stew = {}
vlf_sus_stew.registered_stews = {}
local item_effect = {}
local S = minetest.get_translator(minetest.get_current_modname())

local function get_random_effect()
	local keys = {}
	for k in pairs(vlf_sus_stew.registered_stews) do
		table.insert(keys, k)
	end
	local e = keys[math.random(#keys)]
	return vlf_sus_stew.registered_stews[e],e
end

local function eat_stew(itemstack, placer, pointed_thing)
	local rc = vlf_util.call_on_rightclick(itemstack, placer, pointed_thing)
	if rc then return rc end
	local e = itemstack:get_meta():get_string("effect")
	local f = vlf_sus_stew.registered_stews[e]
	if not f then
		f, e = get_random_effect()
	end
	if f(itemstack,placer,pointed_thing,e) then
		return "vlf_core:bowl"
	end
end

minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
	if itemstack:get_name() ~= "vlf_sus_stew:stew" then return end
	for f,e in pairs(item_effect) do
		for _,it in pairs(old_craft_grid) do
			if it:get_name() == f then
				itemstack:get_meta():set_string("effect",e)
				return itemstack
			end
		end
	end
end)

function vlf_sus_stew.register_stew(name,recipe_item,effect_func)
	vlf_sus_stew.registered_stews[name] = effect_func
	item_effect[recipe_item] = name
	minetest.register_craft({
		type = "shapeless",
		output = "vlf_sus_stew:stew",
		recipe = {"vlf_mushrooms:mushroom_red", "vlf_mushrooms:mushroom_brown", "vlf_core:bowl", recipe_item },
	})
end

local function hunger_effect(itemstack, placer, pointed_thing)
	vlf_hunger.item_eat(6, "vlf_core:bowl", 3.5, 0, 100)
	return itemstack
end

local function sus_effect(itemstack, placer, pointed_thing,effect)
	if vlf_entity_effects[effect.."_func"] then
		vlf_entity_effects[effect.."_func"](placer, 1, 6)
	end
	return itemstack
end

vlf_sus_stew.register_stew("fire_resistance","vlf_flowers:allium",sus_effect)
--vlf_sus_stew.register_stew("blindness","vlf_flowers:azure_bluet",sus_effect) -- effect not implemented
vlf_sus_stew.register_stew("hunger","vlf_flowers:blue_orchid",hunger_effect)
vlf_sus_stew.register_stew("leaping","vlf_flowers:cornflower",sus_effect)
vlf_sus_stew.register_stew("hunger","vlf_flowers:dandelion",hunger_effect)
vlf_sus_stew.register_stew("poison","vlf_flowers:lily_of_the_valley",sus_effect)
vlf_sus_stew.register_stew("regeneration","vlf_flowers:oxeye_daisy",sus_effect)
vlf_sus_stew.register_stew("night_vision","vlf_flowers:poppy",sus_effect)
--vlf_sus_stew.register_stew("weakness","vlf_flowers:tulip_orange",sus_effect) -- effect not implemented
--vlf_sus_stew.register_stew("weakness","vlf_flowers:tulip_pink",sus_effect) -- effect not implemented
--vlf_sus_stew.register_stew("weakness","vlf_flowers:tulip_red",sus_effect) -- effect not implemented
--vlf_sus_stew.register_stew("weakness","vlf_flowers:tulip_white",sus_effect) -- effect not implemented
vlf_sus_stew.register_stew("harming","vlf_flowers:wither_rose",sus_effect) -- in place of real wither effect

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
