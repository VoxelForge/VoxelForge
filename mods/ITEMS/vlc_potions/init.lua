local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)

vlc_potions = {}

-- duration effects of redstone are a factor of 8/3
-- duration effects of glowstone are a time factor of 1/2
-- splash potion duration effects are reduced by a factor of 3/4

vlc_potions.II_FACTOR = 2
vlc_potions.PLUS_FACTOR = 8/3

vlc_potions.DURATION = 180
vlc_potions.DURATION_PLUS = vlc_potions.DURATION * vlc_potions.PLUS_FACTOR
vlc_potions.DURATION_2 = vlc_potions.DURATION / vlc_potions.II_FACTOR

vlc_potions.INV_FACTOR = 0.50
vlc_potions.SPLASH_FACTOR = 0.75
vlc_potions.LINGERING_FACTOR = 0.25

dofile(modpath .. "/functions.lua")
dofile(modpath .. "/commands.lua")
dofile(modpath .. "/splash.lua")
dofile(modpath .. "/lingering.lua")
dofile(modpath .. "/tipped_arrow.lua")
dofile(modpath .. "/potions.lua")

minetest.register_craftitem("vlc_potions:fermented_spider_eye", {
	description = S("Fermented Spider Eye"),
	_doc_items_longdesc = S("Try different combinations to create potions."),
	wield_image = "vlc_potions_spider_eye_fermented.png",
	inventory_image = "vlc_potions_spider_eye_fermented.png",
	groups = { brewitem = 1, },
})

minetest.register_craft({
	type = "shapeless",
	output = "vlc_potions:fermented_spider_eye",
	recipe = { "vlc_mushrooms:mushroom_brown", "vlc_core:sugar", "vlc_mobitems:spider_eye" },
})

minetest.register_craftitem("vlc_potions:glass_bottle", {
	description = S("Glass Bottle"),
	_tt_help = S("Liquid container"),
	_doc_items_longdesc = S("A glass bottle is used as a container for liquids and can be used to collect water directly."),
	_doc_items_usagehelp = S("To collect water, use it on a cauldron with water (which removes a level of water) or any water source (which removes no water)."),
	inventory_image = "vlc_potions_potion_bottle.png",
	wield_image = "vlc_potions_potion_bottle.png",
	groups = {brewitem=1, empty_bottle = 1},
	liquids_pointable = true,
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type == "node" then
			local node = minetest.get_node(pointed_thing.under)
			local def = minetest.registered_nodes[node.name]

			local rc = vlc_util.call_on_rightclick(itemstack, placer, pointed_thing)
			if rc then return rc end

			-- Try to fill glass bottle with water
			local get_water = false
			--local from_liquid_source = false
			local river_water = false
			if def and def.groups and def.groups.water and def.liquidtype == "source" then
				-- Water source
				get_water = true
				--from_liquid_source = true
				river_water = node.name == "vlcx_core:river_water_source"
			-- Or reduce water level of cauldron by 1
			elseif string.sub(node.name, 1, 14) == "vlc_cauldrons:" then
				local pname = placer:get_player_name()
				if minetest.is_protected(pointed_thing.under, pname) then
					minetest.record_protection_violation(pointed_thing.under, pname)
					return itemstack
				end
				if node.name == "vlc_cauldrons:cauldron_3" then
					get_water = true
					minetest.swap_node(pointed_thing.under, {name="vlc_cauldrons:cauldron_2"})
				elseif node.name == "vlc_cauldrons:cauldron_2" then
					get_water = true
					minetest.swap_node(pointed_thing.under, {name="vlc_cauldrons:cauldron_1"})
				elseif node.name == "vlc_cauldrons:cauldron_1" then
					get_water = true
					minetest.swap_node(pointed_thing.under, {name="vlc_cauldrons:cauldron"})
				elseif node.name == "vlc_cauldrons:cauldron_3r" then
					get_water = true
					river_water = true
					minetest.swap_node(pointed_thing.under, {name="vlc_cauldrons:cauldron_2r"})
				elseif node.name == "vlc_cauldrons:cauldron_2r" then
					get_water = true
					river_water = true
					minetest.swap_node(pointed_thing.under, {name="vlc_cauldrons:cauldron_1r"})
				elseif node.name == "vlc_cauldrons:cauldron_1r" then
					get_water = true
					river_water = true
					minetest.swap_node(pointed_thing.under, {name="vlc_cauldrons:cauldron"})
				end
			end
			if get_water then
				local water_bottle
				if river_water then
					water_bottle = ItemStack("vlc_potions:river_water")
				else
					water_bottle = ItemStack("vlc_potions:water")
				end
				-- Replace with water bottle, if possible, otherwise
				-- place the water potion at a place where's space
				local inv = placer:get_inventory()
				minetest.sound_play("vlc_potions_bottle_fill", {pos=pointed_thing.under, gain=0.5, max_hear_range=16}, true)
				if minetest.is_creative_enabled(placer:get_player_name()) then
					-- Don't replace empty bottle in creative for convenience reasons
					if not inv:contains_item("main", water_bottle) then
						inv:add_item("main", water_bottle)
					end
				elseif itemstack:get_count() == 1 then
					return water_bottle
				else
					if inv:room_for_item("main", water_bottle) then
						inv:add_item("main", water_bottle)
					else
						minetest.add_item(placer:get_pos(), water_bottle)
					end
					itemstack:take_item()
				end
			end
		end
		return itemstack
	end,
})

minetest.register_craft( {
	output = "vlc_potions:glass_bottle 3",
	recipe = {
		{ "vlc_core:glass", "", "vlc_core:glass" },
		{ "", "vlc_core:glass", "" }
	}
})

-- Template function for creating images of filled potions
-- - colorstring must be a ColorString of form “#RRGGBB”, e.g. “#0000FF” for blue.
-- - opacity is optional opacity from 0-255 (default: 127)
local function potion_image(colorstring, opacity)
	if not opacity then
		opacity = 127
	end
	return "vlc_potions_potion_overlay.png^[colorize:"..colorstring..":"..tostring(opacity).."^vlc_potions_potion_bottle.png"
end



-- Cauldron fill up rules:
-- Adding any water increases the water level by 1, preserving the current water type
local cauldron_levels = {
	-- start = { add water, add river water }
	{ "",    "_1",  "_1r" },
	{ "_1",  "_2",  "_2" },
	{ "_2",  "_3",  "_3" },
	{ "_1r", "_2r",  "_2r" },
	{ "_2r", "_3r", "_3r" },
}
local fill_cauldron = function(cauldron, water_type)
	local base = "vlc_cauldrons:cauldron"
	for i=1, #cauldron_levels do
		if cauldron == base .. cauldron_levels[i][1] then
			if water_type == "vlcx_core:river_water_source" then
				return base .. cauldron_levels[i][3]
			else
				return base .. cauldron_levels[i][2]
			end
		end
	end
end

-- function to set node and empty water bottle (used for cauldrons and mud)
local function set_node_empty_bottle(itemstack, placer, pointed_thing, newitemstring)
	local pname = placer:get_player_name()
	if minetest.is_protected(pointed_thing.under, pname) then
		minetest.record_protection_violation(pointed_thing.under, pname)
		return itemstack
	end

	-- set the node to `itemstring`
	minetest.set_node(pointed_thing.under, {name=newitemstring})

	-- play sound
	minetest.sound_play("vlc_potions_bottle_pour", {pos=pointed_thing.under, gain=0.5, max_hear_range=16}, true)

	if minetest.is_creative_enabled(placer:get_player_name()) then
		return itemstack
	else
		return "vlc_potions:glass_bottle"
	end
end

-- used for water bottles and river water bottles
local function dispense_water_bottle(stack, pos, droppos)
	local node = minetest.get_node(droppos)
	if node.name == "vlc_core:dirt" or node.name == "vlc_core:coarse_dirt" then
		-- convert dirt/coarse dirt to mud
		minetest.set_node(droppos, {name = "vlc_mud:mud"})
		minetest.sound_play("vlc_potions_bottle_pour", {pos=droppos, gain=0.5, max_hear_range=16}, true)
		return ItemStack("vlc_potions:glass_bottle")

	elseif node.name == "vlc_mud:mud" then
		-- dont dispense into mud
		return stack
	end
end

-- on_place function for `vlc_potions:water` and `vlc_potions:river_water`

local function water_bottle_on_place(itemstack, placer, pointed_thing)
	if pointed_thing.type == "node" then
		local node = minetest.get_node(pointed_thing.under)

		local rc = vlc_util.call_on_rightclick(itemstack, placer, pointed_thing)
		if rc then return rc end

		local cauldron = nil
		if itemstack:get_name() == "vlc_potions:water" then -- regular water
			cauldron = fill_cauldron(node.name, "vlc_core:water_source")
		elseif itemstack:get_name() == "vlc_potions:river_water" then -- river water
			cauldron = fill_cauldron(node.name, "vlcx_core:river_water_source")
		end


		if cauldron then
			set_node_empty_bottle(itemstack, placer, pointed_thing, cauldron)
		elseif node.name == "vlc_core:dirt" or node.name == "vlc_core:coarse_dirt" then
			set_node_empty_bottle(itemstack, placer, pointed_thing, "vlc_mud:mud")
		end
	end

	-- Drink the water by default
	return minetest.do_item_eat(0, "vlc_potions:glass_bottle", itemstack, placer, pointed_thing)
end

-- Itemstring of potions is “vlc_potions:<NBT Potion Tag>”

minetest.register_craftitem("vlc_potions:water", {
	description = S("Water Bottle"),
	_tt_help = S("No effect"),
	_doc_items_longdesc = S("Water bottles can be used to fill cauldrons. Drinking water has no effect."),
	_doc_items_usagehelp = S("Use the “Place” key to drink. Place this item on a cauldron to pour the water into the cauldron."),
	stack_max = 1,
	inventory_image = potion_image("#0022FF"),
	wield_image = potion_image("#0022FF"),
	groups = {brewitem=1, food=3, can_eat_when_full=1, water_bottle=1},
	on_place = water_bottle_on_place,
	_on_dispense = dispense_water_bottle,
	_dispense_into_walkable = true,
	on_secondary_use = minetest.item_eat(0, "vlc_potions:glass_bottle"),
})


minetest.register_craftitem("vlc_potions:river_water", {
	description = S("River Water Bottle"),
	_tt_help = S("No effect"),
	_doc_items_longdesc = S("River water bottles can be used to fill cauldrons. Drinking it has no effect."),
	_doc_items_usagehelp = S("Use the “Place” key to drink. Place this item on a cauldron to pour the river water into the cauldron."),

	stack_max = 1,
	inventory_image = potion_image("#0044FF"),
	wield_image = potion_image("#0044FF"),
	groups = {brewitem=1, food=3, can_eat_when_full=1, water_bottle=1},
	on_place = water_bottle_on_place,
	_on_dispense = dispense_water_bottle,
	_dispense_into_walkable = true,
	on_secondary_use = minetest.item_eat(0, "vlc_potions:glass_bottle"),

})

-- Hurt mobs
local function water_splash(obj, damage)
	if not obj then
		return
	end
	if not damage or (damage > 0 and damage < 1) then
		damage = 1
	end
	-- Damage mobs that are vulnerable to water
	local lua = obj:get_luaentity()
	if lua and lua.is_mob then
		obj:punch(obj, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {water_vulnerable=damage},
		}, nil)
	end
end

vlc_potions.register_splash("water", S("Splash Water Bottle"), "#0022FF", {
	tt=S("Extinguishes fire and hurts some mobs"),
	longdesc=S("A throwable water bottle that will shatter on impact, where it extinguishes nearby fire and hurts mobs that are vulnerable to water."),
	no_effect=true,
	potion_fun=water_splash,
	effect=1
})
vlc_potions.register_lingering("water", S("Lingering Water Bottle"), "#0022FF", {
	tt=S("Extinguishes fire and hurts some mobs"),
	longdesc=S("A throwable water bottle that will shatter on impact, where it creates a cloud of water vapor that lingers on the ground for a while. This cloud extinguishes fire and hurts mobs that are vulnerable to water."),
	no_effect=true,
	potion_fun=water_splash,
	effect=1
})

minetest.register_craftitem("vlc_potions:speckled_melon", {
	description = S("Glistering Melon"),
	_doc_items_longdesc = S("This shiny melon is full of tiny gold nuggets and would be nice in an item frame. It isn't edible and not useful for anything else."),
	groups = { brewitem = 1, },
	inventory_image = "vlc_potions_melon_speckled.png",
})

minetest.register_craft({
	output = "vlc_potions:speckled_melon",
	recipe = {
		{"vlc_core:gold_nugget", "vlc_core:gold_nugget", "vlc_core:gold_nugget"},
		{"vlc_core:gold_nugget", "vlc_farming:melon_item", "vlc_core:gold_nugget"},
		{"vlc_core:gold_nugget", "vlc_core:gold_nugget", "vlc_core:gold_nugget"},
	}
})


local water_table = {
	["vlc_nether:nether_wart_item"] = "vlc_potions:awkward",
	-- ["vlc_potions:fermented_spider_eye"] = "vlc_potions:weakness",
	["vlc_potions:speckled_melon"] = "vlc_potions:mundane",
	["vlc_core:sugar"] = "vlc_potions:mundane",
	["vlc_mobitems:magma_cream"] = "vlc_potions:mundane",
	["vlc_mobitems:blaze_powder"] = "vlc_potions:mundane",
	["mesecons:wire_00000000_off"] = "vlc_potions:mundane",
	["vlc_mobitems:ghast_tear"] = "vlc_potions:mundane",
	["vlc_mobitems:spider_eye"] = "vlc_potions:mundane",
	["vlc_mobitems:rabbit_foot"] = "vlc_potions:mundane",
	["vlc_nether:glowstone_dust"] = "vlc_potions:thick",
	["vlc_mobitems:gunpowder"] = "vlc_potions:water_splash"
}

local awkward_table = {
	["vlc_potions:speckled_melon"] = "vlc_potions:healing",
	["vlc_farming:carrot_item_gold"] = "vlc_potions:night_vision",
	["vlc_core:sugar"] = "vlc_potions:swiftness",
	["vlc_mobitems:magma_cream"] = "vlc_potions:fire_resistance",
	-- ["vlc_mobitems:blaze_powder"] = "vlc_potions:strength",
	["vlc_fishing:pufferfish_raw"] = "vlc_potions:water_breathing",
	["vlc_mobitems:ghast_tear"] = "vlc_potions:regeneration",
	["vlc_mobitems:spider_eye"] = "vlc_potions:poison",
	["vlc_mobitems:rabbit_foot"] = "vlc_potions:leaping",
}

local output_table = {
	["vlc_potions:river_water"] = water_table,
	["vlc_potions:water"] = water_table,
	["vlc_potions:awkward"] = awkward_table,
}

minetest.register_on_mods_loaded(function()
	for k, _ in pairs(table.merge(awkward_table, water_table)) do
		local def = minetest.registered_items[k]
		if def then
			minetest.override_item(k, {
				groups = table.merge(def.groups, {brewing_ingredient = 1})
			})
		end
	end
end)


local enhancement_table = {}
local extension_table = {}
local potions = {}

for i, potion in ipairs({"healing","harming","swiftness","slowness",
	 "leaping","poison","regeneration","invisibility","fire_resistance",
	 -- "weakness","strength",
	 "water_breathing","night_vision", "withering"}) do

	table.insert(potions, potion)

	if potion ~= "invisibility" and potion ~= "night_vision" and potion ~= "weakness" and potion ~= "water_breathing" and potion ~= "fire_resistance" then
		enhancement_table["vlc_potions:"..potion] = "vlc_potions:"..potion.."_2"
		enhancement_table["vlc_potions:"..potion.."_splash"] = "vlc_potions:"..potion.."_2_splash"
		table.insert(potions, potion.."_2")
	end

	if potion ~= "healing" and potion ~= "harming" then
		extension_table["vlc_potions:"..potion.."_splash"] = "vlc_potions:"..potion.."_plus_splash"
		extension_table["vlc_potions:"..potion] = "vlc_potions:"..potion.."_plus"
		table.insert(potions, potion.."_plus")
	end

end

for i, potion in ipairs({"awkward", "mundane", "thick", "water"}) do
	table.insert(potions, potion)
end


local inversion_table = {
	["vlc_potions:healing"] = "vlc_potions:harming",
	["vlc_potions:healing_2"] = "vlc_potions:harming_2",
	["vlc_potions:swiftness"] = "vlc_potions:slowness",
	["vlc_potions:swiftness_plus"] = "vlc_potions:slowness_plus",
	["vlc_potions:leaping"] = "vlc_potions:slowness",
	["vlc_potions:leaping_plus"] = "vlc_potions:slowness_plus",
	["vlc_potions:night_vision"] = "vlc_potions:invisibility",
	["vlc_potions:night_vision_plus"] = "vlc_potions:invisibility_plus",
	["vlc_potions:poison"] = "vlc_potions:harming",
	["vlc_potions:poison_2"] = "vlc_potions:harming_2",
	["vlc_potions:healing_splash"] = "vlc_potions:harming_splash",
	["vlc_potions:healing_2_splash"] = "vlc_potions:harming_2_splash",
	["vlc_potions:swiftness_splash"] = "vlc_potions:slowness_splash",
	["vlc_potions:swiftness_plus_splash"] = "vlc_potions:slowness_plus_splash",
	["vlc_potions:leaping_splash"] = "vlc_potions:slowness_splash",
	["vlc_potions:leaping_plus_splash"] = "vlc_potions:slowness_plus_splash",
	["vlc_potions:night_vision_splash"] = "vlc_potions:invisibility_splash",
	["vlc_potions:night_vision_plus_splash"] = "vlc_potions:invisibility_plus_splash",
	["vlc_potions:poison_splash"] = "vlc_potions:harming_splash",
	["vlc_potions:poison_2_splash"] = "vlc_potions:harming_2_splash",
}


local splash_table = {}
local lingering_table = {}

for i, potion in ipairs(potions) do
	splash_table["vlc_potions:"..potion] = "vlc_potions:"..potion.."_splash"
	lingering_table["vlc_potions:"..potion.."_splash"] = "vlc_potions:"..potion.."_lingering"
end


local mod_table = {
	["mesecons:wire_00000000_off"] = extension_table,
	["vlc_potions:fermented_spider_eye"] = inversion_table,
	["vlc_nether:glowstone_dust"] = enhancement_table,
	["vlc_mobitems:gunpowder"] = splash_table,
	["vlc_potions:dragon_breath"] = lingering_table,
}

-- Compare two ingredients for compatable alchemy
function vlc_potions.get_alchemy(ingr, pot)
	if output_table[pot] then

		local brew_table = output_table[pot]

		if brew_table[ingr] then
			return brew_table[ingr]
		end
	end

	if mod_table[ingr] then

		local brew_table = mod_table[ingr]

		if brew_table[pot] then
			return brew_table[pot]
		end

	end

	return false
end

vlc_mobs.effect_functions["poison"] = vlc_potions.poison_func
vlc_mobs.effect_functions["regeneration"] = vlc_potions.regeneration_func
vlc_mobs.effect_functions["invisibility"] = vlc_potions.invisiblility_func
vlc_mobs.effect_functions["fire_resistance"] = vlc_potions.fire_resistance_func
vlc_mobs.effect_functions["night_vision"] = vlc_potions.night_vision_func
vlc_mobs.effect_functions["water_breathing"] = vlc_potions.water_breathing_func
vlc_mobs.effect_functions["leaping"] = vlc_potions.leaping_func
vlc_mobs.effect_functions["swiftness"] = vlc_potions.swiftness_func
vlc_mobs.effect_functions["heal"] = vlc_potions.healing_func
vlc_mobs.effect_functions["bad_omen"] = vlc_potions.bad_omen_func
vlc_mobs.effect_functions["withering"] = vlc_potions.withering_func

-- give withering to players in a wither rose
local etime = 0
minetest.register_globalstep(function(dtime)
	etime = dtime + etime
	if etime < 0.5 then return end
	etime = 0
	for _,pl in pairs(minetest.get_connected_players()) do
		local npos = vector.offset(pl:get_pos(), 0, 0.2, 0)
		local n = minetest.get_node(npos)
		if n.name == "vlc_flowers:wither_rose" then vlc_potions.withering_func(pl, 1, 2) end
	end
end)

vlc_wip.register_wip_item("vlc_potions:night_vision")
vlc_wip.register_wip_item("vlc_potions:night_vision_plus")
vlc_wip.register_wip_item("vlc_potions:night_vision_splash")
vlc_wip.register_wip_item("vlc_potions:night_vision_plus_splash")
vlc_wip.register_wip_item("vlc_potions:night_vision_lingering")
vlc_wip.register_wip_item("vlc_potions:night_vision_plus_lingering")
vlc_wip.register_wip_item("vlc_potions:night_vision_arrow")
vlc_wip.register_wip_item("vlc_potions:night_vision_plus_arrow")
