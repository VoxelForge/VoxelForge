local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)

vlf_effects = {}

-- duration effects of redstone are a factor of 8/3
-- duration effects of glowstone are a time factor of 1/2
-- splash potion duration effects are reduced by a factor of 3/4

vlf_effects.POTENT_FACTOR = 2
vlf_effects.PLUS_FACTOR = 8/3
vlf_effects.INV_FACTOR = 0.50

vlf_effects.DURATION = 180
vlf_effects.DURATION_INV = vlf_effects.DURATION * vlf_effects.INV_FACTOR
vlf_effects.DURATION_POISON = 45

vlf_effects.II_FACTOR = vlf_effects.POTENT_FACTOR -- TODO remove at some point
vlf_effects.DURATION_PLUS = vlf_effects.DURATION * vlf_effects.PLUS_FACTOR -- TODO remove at some point
vlf_effects.DURATION_2 = vlf_effects.DURATION / vlf_effects.II_FACTOR -- TODO remove at some point

vlf_effects.SPLASH_FACTOR = 0.75
vlf_effects.LINGERING_FACTOR = 0.25

dofile(modpath .. "/functions.lua")
dofile(modpath .. "/commands.lua")
dofile(modpath .. "/splash.lua")
dofile(modpath .. "/lingering.lua")
dofile(modpath .. "/tipped_arrow.lua")
dofile(modpath .. "/potions.lua")
local potions = vlf_effects.registered_potions

minetest.register_craftitem("vlf_effects:fermented_spider_eye", {
	description = S("Fermented Spider Eye"),
	_doc_items_longdesc = S("Try different combinations to create potions."),
	wield_image = "vlf_effects_spider_eye_fermented.png",
	inventory_image = "vlf_effects_spider_eye_fermented.png",
	groups = { brewitem = 1, },
})

minetest.register_craft({
	type = "shapeless",
	output = "vlf_effects:fermented_spider_eye",
	recipe = { "vlf_mushrooms:mushroom_brown", "vlf_core:sugar", "vlf_mobitems:spider_eye" },
})

minetest.register_craftitem("vlf_effects:glass_bottle", {
	description = S("Glass Bottle"),
	_tt_help = S("Liquid container"),
	_doc_items_longdesc = S("A glass bottle is used as a container for liquids and can be used to collect water directly."),
	_doc_items_usagehelp = S("To collect water, use it on a cauldron with water (which removes a level of water) or any water source (which removes no water)."),
	inventory_image = "vlf_effects_potion_bottle.png",
	wield_image = "vlf_effects_potion_bottle.png",
	groups = {brewitem=1, empty_bottle = 1},
	liquids_pointable = true,
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type == "node" then
			local node = minetest.get_node(pointed_thing.under)
			local def = minetest.registered_nodes[node.name]

			local rc = vlf_util.call_on_rightclick(itemstack, placer, pointed_thing)
			if rc then return rc end

			-- Try to fill glass bottle with water
			local get_water = false
			--local from_liquid_source = false
			local river_water = false
			if def and def.groups and def.groups.water and def.liquidtype == "source" then
				-- Water source
				get_water = true
				--from_liquid_source = true
				river_water = node.name == "vlfx_core:river_water_source"
			-- Or reduce water level of cauldron by 1
			elseif string.sub(node.name, 1, 14) == "vlf_cauldrons:" then
				local pname = placer:get_player_name()
				if minetest.is_protected(pointed_thing.under, pname) then
					minetest.record_protection_violation(pointed_thing.under, pname)
					return itemstack
				end
				if node.name == "vlf_cauldrons:cauldron_3" then
					get_water = true
					minetest.swap_node(pointed_thing.under, {name="vlf_cauldrons:cauldron_2"})
				elseif node.name == "vlf_cauldrons:cauldron_2" then
					get_water = true
					minetest.swap_node(pointed_thing.under, {name="vlf_cauldrons:cauldron_1"})
				elseif node.name == "vlf_cauldrons:cauldron_1" then
					get_water = true
					minetest.swap_node(pointed_thing.under, {name="vlf_cauldrons:cauldron"})
				elseif node.name == "vlf_cauldrons:cauldron_3r" then
					get_water = true
					river_water = true
					minetest.swap_node(pointed_thing.under, {name="vlf_cauldrons:cauldron_2r"})
				elseif node.name == "vlf_cauldrons:cauldron_2r" then
					get_water = true
					river_water = true
					minetest.swap_node(pointed_thing.under, {name="vlf_cauldrons:cauldron_1r"})
				elseif node.name == "vlf_cauldrons:cauldron_1r" then
					get_water = true
					river_water = true
					minetest.swap_node(pointed_thing.under, {name="vlf_cauldrons:cauldron"})
				end
			end
			if get_water then
				local water_bottle
				if river_water then
					water_bottle = ItemStack("vlf_effects:river_water")
				else
					water_bottle = ItemStack("vlf_effects:water")
				end
				-- Replace with water bottle, if possible, otherwise
				-- place the water potion at a place where's space
				local inv = placer:get_inventory()
				minetest.sound_play("vlf_effects_bottle_fill", {pos=pointed_thing.under, gain=0.5, max_hear_range=16}, true)
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
	output = "vlf_effects:glass_bottle 3",
	recipe = {
		{ "vlf_core:glass", "", "vlf_core:glass" },
		{ "", "vlf_core:glass", "" }
	}
})

-- Template function for creating images of filled potions
-- - colorstring must be a ColorString of form “#RRGGBB”, e.g. “#0000FF” for blue.
-- - opacity is optional opacity from 0-255 (default: 127)
local function potion_image(colorstring, opacity)
	if not opacity then
		opacity = 127
	end
	return "vlf_effects_potion_overlay.png^[colorize:"..colorstring..":"..tostring(opacity).."^vlf_effects_potion_bottle.png"
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
	local base = "vlf_cauldrons:cauldron"
	for i=1, #cauldron_levels do
		if cauldron == base .. cauldron_levels[i][1] then
			if water_type == "vlfx_core:river_water_source" then
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
	minetest.sound_play("vlf_effects_bottle_pour", {pos=pointed_thing.under, gain=0.5, max_hear_range=16}, true)

	if minetest.is_creative_enabled(placer:get_player_name()) then
		return itemstack
	else
		return "vlf_effects:glass_bottle"
	end
end

-- used for water bottles and river water bottles
local function dispense_water_bottle(stack, pos, droppos)
	local node = minetest.get_node(droppos)
	if node.name == "vlf_core:dirt" or node.name == "vlf_core:coarse_dirt" then
		-- convert dirt/coarse dirt to mud
		minetest.set_node(droppos, {name = "vlf_mud:mud"})
		minetest.sound_play("vlf_effects_bottle_pour", {pos=droppos, gain=0.5, max_hear_range=16}, true)
		return ItemStack("vlf_effects:glass_bottle")

	elseif node.name == "vlf_mud:mud" then
		-- dont dispense into mud
		return stack
	end
end

-- on_place function for `vlf_effects:water` and `vlf_effects:river_water`

local function water_bottle_on_place(itemstack, placer, pointed_thing)
	if pointed_thing.type == "node" then
		local node = minetest.get_node(pointed_thing.under)

		local rc = vlf_util.call_on_rightclick(itemstack, placer, pointed_thing)
		if rc then return rc end

		local cauldron = nil
		if itemstack:get_name() == "vlf_effects:water" then -- regular water
			cauldron = fill_cauldron(node.name, "vlf_core:water_source")
		elseif itemstack:get_name() == "vlf_effects:river_water" then -- river water
			cauldron = fill_cauldron(node.name, "vlfx_core:river_water_source")
		end


		if cauldron then
			set_node_empty_bottle(itemstack, placer, pointed_thing, cauldron)
		elseif node.name == "vlf_core:dirt" or node.name == "vlf_core:coarse_dirt" then
			set_node_empty_bottle(itemstack, placer, pointed_thing, "vlf_mud:mud")
		end
	end

	-- Drink the water by default
	return minetest.do_item_eat(0, "vlf_effects:glass_bottle", itemstack, placer, pointed_thing)
end

-- Itemstring of potions is “vlf_effects:<NBT Potion Tag>”

minetest.register_craftitem("vlf_effects:water", {
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
	on_secondary_use = minetest.item_eat(0, "vlf_effects:glass_bottle"),
})


minetest.register_craftitem("vlf_effects:river_water", {
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
	on_secondary_use = minetest.item_eat(0, "vlf_effects:glass_bottle"),

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

vlf_effects.register_splash("water", S("Splash Water Bottle"), "#0022FF", {
	tt=S("Extinguishes fire and hurts some mobs"),
	longdesc=S("A throwable water bottle that will shatter on impact, where it extinguishes nearby fire and hurts mobs that are vulnerable to water."),
	no_effect=true,
	potion_fun=water_splash,
	effect=1
})
vlf_effects.register_lingering("water", S("Lingering Water Bottle"), "#0022FF", {
	tt=S("Extinguishes fire and hurts some mobs"),
	longdesc=S("A throwable water bottle that will shatter on impact, where it creates a cloud of water vapor that lingers on the ground for a while. This cloud extinguishes fire and hurts mobs that are vulnerable to water."),
	no_effect=true,
	potion_fun=water_splash,
	effect=1
})

minetest.register_craftitem("vlf_effects:speckled_melon", {
	description = S("Glistering Melon"),
	_doc_items_longdesc = S("This shiny melon is full of tiny gold nuggets and would be nice in an item frame. It isn't edible and not useful for anything else."),
	groups = { brewitem = 1, },
	inventory_image = "vlf_effects_melon_speckled.png",
})

minetest.register_craft({
	output = "vlf_effects:speckled_melon",
	recipe = {
		{"vlf_core:gold_nugget", "vlf_core:gold_nugget", "vlf_core:gold_nugget"},
		{"vlf_core:gold_nugget", "vlf_farming:melon_item", "vlf_core:gold_nugget"},
		{"vlf_core:gold_nugget", "vlf_core:gold_nugget", "vlf_core:gold_nugget"},
	}
})



local output_table = { }

-- API
-- registers a potion that can be combined with multiple ingredients for different outcomes
-- out_table contains the recipes for those outcomes
function vlf_effects.register_ingredient_potion(input, out_table)
	if output_table[input] then
		error("Attempt to register the same ingredient twice!")
	end
	if type(input) ~= "string" then
		error("Invalid argument! input must be a string")
	end
	if type(out_table) ~= "table" then
		error("Invalid argument! out_table must be a table")
	end
	output_table[input] = out_table
end

local water_table = {
	["vlf_nether:nether_wart_item"] = "vlf_effects:awkward",
	["vlf_effects:fermented_spider_eye"] = "vlf_effects:weakness",
	["vlf_effects:speckled_melon"] = "vlf_effects:mundane",
	["vlf_core:sugar"] = "vlf_effects:mundane",
	["vlf_mobitems:magma_cream"] = "vlf_effects:mundane",
	["vlf_mobitems:blaze_powder"] = "vlf_effects:mundane",
	["mesecons:wire_00000000_off"] = "vlf_effects:mundane",
	["vlf_mobitems:ghast_tear"] = "vlf_effects:mundane",
	["vlf_mobitems:spider_eye"] = "vlf_effects:mundane",
	["vlf_mobitems:rabbit_foot"] = "vlf_effects:mundane",
	["vlf_mobitems:gunpowder"] = "vlf_effects:water_splash"
}
-- API
-- register a potion recipe brewed from water
function vlf_effects.register_water_brew(ingr, potion)
	if water_table[ingr] then
		error("Attempt to register the same ingredient twice!")
	end
	if type(ingr) ~= "string" then
		error("Invalid argument! ingr must be a string")
	end
	if type(potion) ~= "string" then
		error("Invalid argument! potion must be a string")
	end
	water_table[ingr] = potion
end
vlf_effects.register_ingredient_potion("vlf_effects:river_water", water_table)
vlf_effects.register_ingredient_potion("vlf_effects:water", water_table)

local awkward_table = {
	["vlf_effects:speckled_melon"] = "vlf_effects:healing",
	["vlf_farming:carrot_item_gold"] = "vlf_effects:night_vision",
	["vlf_core:sugar"] = "vlf_effects:swiftness",
	["vlf_mobitems:magma_cream"] = "vlf_effects:fire_resistance",
	["vlf_mobitems:blaze_powder"] = "vlf_effects:strength",
	["vlf_fishing:pufferfish_raw"] = "vlf_effects:water_breathing",
	["vlf_mobitems:ghast_tear"] = "vlf_effects:regeneration",
	["vlf_mobitems:spider_eye"] = "vlf_effects:poison",
	["vlf_mobitems:rabbit_foot"] = "vlf_effects:leaping",

	["vlf_flowers:fourleaf_clover"] = "vlf_effects:luck",
	["vlf_mobitems:phantom_membrane"] = "vlf_effects:slow_falling", -- TODO add phantom membranes
	["vlf_core:apple_gold"] = "vlf_effects:resistance",

	-- TODO darkness - sculk?
	-- TODO absorption - water element?
	-- TODO turtle master - earth element?
	-- TODO frost - frost element?
	-- TODO haste - air element?
}
-- API
-- register a potion recipe brewed from awkward potion
function vlf_effects.register_awkward_brew(ingr, potion)
	if awkward_table[ingr] then
		error("Attempt to register the same ingredient twice!")
	end
	if type(ingr) ~= "string" then
		error("Invalid argument! ingr must be a string")
	end
	if type(potion) ~= "string" then
		error("Invalid argument! potion must be a string")
	end
	awkward_table[ingr] = potion
end
vlf_effects.register_ingredient_potion("vlf_effects:awkward", awkward_table)

local mundane_table = {
	["vlf_effects:fermented_spider_eye"] = "vlf_effects:weakness",
}
-- API
-- register a potion recipe brewed from mundane potion
function vlf_effects.register_mundane_brew(ingr, potion)
	if mundane_table[ingr] then
		error("Attempt to register the same ingredient twice!")
	end
	if type(ingr) ~= "string" then
		error("Invalid argument! ingr must be a string")
	end
	if type(potion) ~= "string" then
		error("Invalid argument! potion must be a string")
	end
	mundane_table[ingr] = potion
end
vlf_effects.register_ingredient_potion("vlf_effects:mundane", mundane_table)

local thick_table = {
	["vlf_crimson:shroomlight"] = "vlf_effects:glowing",
	["vlf_mobitems:nether_star"] = "vlf_effects:ominous",
	["vlf_mobitems:ink_sac"] = "vlf_effects:blindness",
	["vlf_farming:carrot_item_gold"] = "vlf_effects:saturation",
}
-- API
-- register a potion recipe brewed from thick potion
function vlf_effects.register_thick_brew(ingr, potion)
	if thick_table[ingr] then
		error("Attempt to register the same ingredient twice!")
	end
	if type(ingr) ~= "string" then
		error("Invalid argument! ingr must be a string")
	end
	if type(potion) ~= "string" then
		error("Invalid argument! potion must be a string")
	end
	thick_table[ingr] = potion
end
vlf_effects.register_ingredient_potion("vlf_effects:thick", thick_table)


local mod_table = { }

-- API
-- registers a brewing recipe altering the potion using a table
-- this is supposed to substitute one item with another
function vlf_effects.register_table_modifier(ingr, modifier)
	if mod_table[ingr] then
		error("Attempt to register the same ingredient twice!")
	end
	if type(ingr) ~= "string" then
		error("Invalid argument! ingr must be a string")
	end
	if type(modifier) ~= "table" then
		error("Invalid argument! modifier must be a table")
	end
	mod_table[ingr] = modifier
end

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

local inversion_table = {
	-- Effect Bottle Table.
	["vlf_effects:healing"] = "vlf_effects:harming",
	["vlf_effects:swiftness"] = "vlf_effects:slowness",
	["vlf_effects:leaping"] = "vlf_effects:slowness",
	["vlf_effects:night_vision"] = "vlf_effects:invisibility",
	["vlf_effects:poison"] = "vlf_effects:harming",
}
-- API
function vlf_effects.register_inversion_recipe(input, output)
	if inversion_table[input] then
		error("Attempt to register the same input twice!")
	end
	if type(input) ~= "string" then
		error("Invalid argument! input must be a string")
	end
	if type(output) ~= "string" then
		error("Invalid argument! output must be a string")
	end
	inversion_table[input] = output
end
local function fill_inversion_table() -- autofills with splash and lingering inversion recipes
	local filling_table = { }
	for input, output in pairs(inversion_table) do
		if potions[input].has_splash and potions[output].has_splash then
			filling_table[input.."_splash"] = output .. "_splash"
			if potions[input].has_lingering and potions[output].has_lingering then
				filling_table[input.."_lingering"] = output .. "_lingering"
			end
		end
	end
	table.update(inversion_table, filling_table)
	vlf_effects.register_table_modifier("vlf_effects:fermented_spider_eye", inversion_table)
end
minetest.register_on_mods_loaded(fill_inversion_table)

local splash_table = {}
local lingering_table = {}
for potion, def in pairs(potions) do
	if def.has_splash then
		splash_table[potion] = potion.."_splash"
		if def.has_lingering then
			lingering_table[potion.."_splash"] = potion.."_lingering"
		end
	end
end
vlf_effects.register_table_modifier("vlf_mobitems:gunpowder", splash_table)
vlf_effects.register_table_modifier("vlf_effects:dragon_breath", lingering_table)


local meta_mod_table = { }

-- API
-- registers a brewing recipe altering the potion using a function
-- this is supposed to be a recipe that changes metadata only
function vlf_effects.register_meta_modifier(ingr, mod_func)
	if meta_mod_table[ingr] then
		error("Attempt to register the same ingredient twice!")
	end
	if type(ingr) ~= "string" then
		error("Invalid argument! ingr must be a string")
	end
	if type(mod_func) ~= "function" then
		error("Invalid argument! mod_func must be a function")
	end
	meta_mod_table[ingr] = mod_func
end

local function extend_dur(potionstack)
	local def = potions[potionstack:get_name()]
	if not def then return false end
	if not def.has_plus then return false end -- bail out if can't be extended
	local potionstack = ItemStack(potionstack)
	local meta = potionstack:get_meta()
	local potent = meta:get_int("vlf_effects:potion_potent")
	local plus = meta:get_int("vlf_effects:potion_plus")
	if plus == 0 then
		if potent ~= 0 then
			meta:set_int("vlf_effects:potion_potent", 0)
		end
		meta:set_int("vlf_effects:potion_plus", def._default_extend_level)
		tt.reload_itemstack_description(potionstack)
		return potionstack
	end
	return false
end
vlf_effects.register_meta_modifier("mesecons:wire_00000000_off", extend_dur)

local function enhance_pow(potionstack)
	local def = potions[potionstack:get_name()]
	if not def then return false end
	if not def.has_potent then return false end -- bail out if has no potent variant
	local potionstack = ItemStack(potionstack)
	local meta = potionstack:get_meta()
	local potent = meta:get_int("vlf_effects:potion_potent")
	local plus = meta:get_int("vlf_effects:potion_plus")
	if potent == 0 then
		if plus ~= 0 then
			meta:set_int("vlf_effects:potion_plus", 0)
		end
		meta:set_int("vlf_effects:potion_potent", def._default_potent_level-1)
		tt.reload_itemstack_description(potionstack)
		return potionstack
	end
	return false
end
vlf_effects.register_meta_modifier("vlf_nether:glowstone_dust", enhance_pow)


-- Find an alchemical recipe for given ingredient and potion
-- returns outcome
function vlf_effects.get_alchemy(ingr, pot)
	local brew_selector = output_table[pot:get_name()]
	if brew_selector and brew_selector[ingr] then
		local meta = pot:get_meta():to_table()
		local alchemy = ItemStack(brew_selector[ingr])
		local metaref = alchemy:get_meta()
		metaref:from_table(meta)
		tt.reload_itemstack_description(alchemy)
		return alchemy
	end

	brew_selector = mod_table[ingr]
	if brew_selector then
		local brew = brew_selector[pot:get_name()]
		if brew then
			local meta = pot:get_meta():to_table()
			local alchemy = ItemStack(brew)
			local metaref = alchemy:get_meta()
			metaref:from_table(meta)
			tt.reload_itemstack_description(alchemy)
			return alchemy
		end
	end

	if meta_mod_table[ingr] then
		local brew_func = meta_mod_table[ingr]
		if brew_func then return brew_func(pot) end
	end

	return false
end

-- give withering to players in a wither rose
local etime = 0
minetest.register_globalstep(function(dtime)
	etime = dtime + etime
	if etime < 0.5 then return end
	etime = 0
	for _,pl in pairs(minetest.get_connected_players()) do
		local npos = vector.offset(pl:get_pos(), 0, 0.2, 0)
		local n = minetest.get_node(npos)
		if n.name == "vlf_flowers:wither_rose" then vlf_effects.withering_func(pl, 1, 2) end
	end
end)

vlf_wip.register_wip_item("vlf_effects:night_vision")
vlf_wip.register_wip_item("vlf_effects:night_vision_splash")
vlf_wip.register_wip_item("vlf_effects:night_vision_lingering")
vlf_wip.register_wip_item("vlf_effects:night_vision_arrow")
