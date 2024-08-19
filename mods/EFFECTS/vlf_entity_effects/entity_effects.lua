local S = minetest.get_translator(minetest.get_current_modname())

vlf_entity_effects.registered_entity_effects = {}
-- shorthand
local registered_entity_effects = vlf_entity_effects.registered_entity_effects

local function entity_effect_image(colorstring, opacity)
	if not opacity then
		opacity = 127
	end
	return "vlf_entity_effects_entity_effect_overlay.png^[colorize:"..colorstring..":"..tostring(opacity).."^vlf_entity_effects_entity_effect_bottle.png"
end

local how_to_drink = S("Use the “Place” key to drink it.")
local entity_effect_intro = S("Drinking a entity_effect gives you a particular effect or set of effects.")

-- ██████╗░███████╗░██████╗░██╗░██████╗████████╗███████╗██████╗░
-- ██╔══██╗██╔════╝██╔════╝░██║██╔════╝╚══██╔══╝██╔════╝██╔══██╗
-- ██████╔╝█████╗░░██║░░██╗░██║╚█████╗░░░░██║░░░█████╗░░██████╔╝
-- ██╔══██╗██╔══╝░░██║░░╚██╗██║░╚═══██╗░░░██║░░░██╔══╝░░██╔══██╗
-- ██║░░██║███████╗╚██████╔╝██║██████╔╝░░░██║░░░███████╗██║░░██║
-- ╚═╝░░╚═╝╚══════╝░╚═════╝░╚═╝╚═════╝░░░░╚═╝░░░╚══════╝╚═╝░░╚═╝
--
-- ██████╗░░█████╗░████████╗██╗░█████╗░███╗░░██╗░██████╗
-- ██╔══██╗██╔══██╗╚══██╔══╝██║██╔══██╗████╗░██║██╔════╝
-- ██████╔╝██║░░██║░░░██║░░░██║██║░░██║██╔██╗██║╚█████╗░
-- ██╔═══╝░██║░░██║░░░██║░░░██║██║░░██║██║╚████║░╚═══██╗
-- ██║░░░░░╚█████╔╝░░░██║░░░██║╚█████╔╝██║░╚███║██████╔╝
-- ╚═╝░░░░░░╚════╝░░░░╚═╝░░░╚═╝░╚════╝░╚═╝░░╚══╝╚═════╝░

local function generate_on_use(effects, color, on_use, custom_effect)
	return function(itemstack, user, pointed_thing)
		if pointed_thing.type == "node" then
			if user and not user:get_player_control().sneak then
				local node = minetest.get_node(pointed_thing.under)
				if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
					return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, user, itemstack) or itemstack
				end
			end
		elseif pointed_thing.type == "object" then
			return itemstack
		end

		local potency = itemstack:get_meta():get_int("vlf_entity_effects:entity_effect_potent")
		local plus = itemstack:get_meta():get_int("vlf_entity_effects:entity_effect_plus")
		local ef_level
		local dur
		for name, details in pairs(effects) do
			if details.uses_level then
				ef_level = details.level + details.level_scaling * (potency)
			else
				ef_level = details.level
			end
			if details.dur_variable then
				dur = details.dur * math.pow(vlf_entity_effects.PLUS_FACTOR, plus)
				if potency>0 and details.uses_level then
					dur = dur / math.pow(vlf_entity_effects.POTENT_FACTOR, potency)
				end
			else
				dur = details.dur
			end
			if details.effect_stacks then
				ef_level = ef_level + vlf_entity_effects.get_effect_level(user, name)
			end
			vlf_entity_effects.give_effect_by_level(name, user, ef_level, dur)
		end

		if on_use then on_use(user, potency+1) end
		if custom_effect then custom_effect(user, potency+1, plus) end

		itemstack = minetest.do_item_eat(0, "vlf_entity_effects:glass_bottle", itemstack, user, pointed_thing)
		if itemstack then vlf_entity_effects._use_entity_effect(user, color) end

		return itemstack
	end
end

-- API - registers a entity_effect
-- required parameters in def:
-- name - string - entity_effect name in code
-- optional parameters in def:
-- desc_prefix - translated string - part of visible entity_effect name, comes before the word "Potion"
-- desc_suffix - translated string - part of visible entity_effect name, comes after the word "Potion"
-- _tt - translated string - custom tooltip text
-- _dynamic_tt - function(level) - returns custom tooltip text dependent on entity_effect level
-- _longdesc - translated string - text for in-game documentation
-- stack_max - int - max stack size - defaults to 1
-- image - string - name of a custom texture of the entity_effect icon
-- color - string - colorstring for entity_effect icon when image is not defined - defaults to #0000FF
-- groups - table - item groups definition -
--   - must contain _vlf_entity_effects=1 for tooltip to include dynamic_tt and effects
--   - defaults to {brewitem=1, food=3, can_eat_when_full=1, _vlf_entity_effects=1}
-- nocreative - bool - adds a not_in_creative_inventory=1 group - defaults to false
-- _effect_list - table - all the effects dealt by the entity_effect in the format of tables
-- -- the name of each sub-table should be a name of a registered effect, and fields can be the following:
-- -- -- uses_level - bool - whether the level of the entity_effect affects the level of the effect -
-- -- --   - defaults to the uses_factor field of the effect definition
-- -- -- level - int - used as the effect level if uses_level is false and for lvl1 entity_effects - defaults to 1
-- -- -- level_scaling - int - used as the number of effect levels added per entity_effect level - defaults to 1 -
-- -- --   - this has no effect if uses_level is false
-- -- -- dur - float - duration of the effect in seconds - defaults to vlf_entity_effects.DURATION
-- -- -- dur_variable - bool - whether variants of the entity_effect should have the length of this effect changed -
-- -- --   - defaults to true
-- -- --   - if at least one effect has this set to true, the entity_effect has a "plus" variant
-- -- -- effect_stacks - bool - whether the effect stacks - defaults to false
-- uses_level - bool - whether the entity_effect should come at different levels -
--   - defaults to true if uses_level is true for at least one effect, else false
-- drinkable - bool - defaults to true
-- has_splash - bool - defaults to true
-- has_lingering - bool - defaults to true
-- has_arrow - bool - defaults to false
-- has_potent - bool - whether there is a potent (e.g. II) variant - defaults to the value of uses_level
-- default_potent_level - int - entity_effect level used for the default potent variant - defaults to 2
-- default_extend_level - int - extention level (amount of +) used for the default extended variant - defaults to 1
-- custom_on_use - function(user, level) - called when the entity_effect is drunk, returns true on success
-- custom_effect - function(object, level, plus) - called when the entity_effect effects are applied, returns true on success
-- custom_splash_effect - function(pos, level) - called when the splash entity_effect explodes, returns true on success
-- custom_linger_effect - function(pos, radius, level) - called on the lingering entity_effect step, returns true on success

function vlf_entity_effects.register_entity_effect(def)
	local modname = minetest.get_current_modname()
	local name = def.name
	if name == nil then
		error("Unable to register entity_effect: name is nil")
	end
	if type(name) ~= "string" then
		error("Unable to register entity_effect: name is not a string")
	end
	local pdef = {}
	if def.desc_prefix and def.desc_suffix then
		pdef.description = S("@1 Potion @2", def.desc_prefix, def.desc_suffix)
	elseif def.desc_prefix then
		pdef.description = S("@1 Potion", def.desc_prefix)
	elseif def.desc_suffix then
		pdef.description = S("Potion @1", def.desc_suffix)
	else
		pdef.description = S("Strange Potion")
	end
	pdef._tt_help = def._tt
	pdef._dynamic_tt = def._dynamic_tt
	local entity_effect_longdesc = def._longdesc
	if def._effect_list then
		entity_effect_longdesc = entity_effect_intro .. "\n" .. def._longdesc
	end
	pdef._doc_items_longdesc = entity_effect_longdesc
	if def.drinkable ~= false then pdef._doc_items_usagehelp = how_to_drink end
	pdef.stack_max = def.stack_max or 1
	local color = def.color or "#0000FF"
	pdef.inventory_image = def.image or entity_effect_image(color)
	pdef.wield_image = pdef.inventory_image
	pdef.groups = def.groups or {brewitem=1, food=3, can_eat_when_full=1, _vlf_entity_effects=1}
	if def.nocreative then pdef.groups.not_in_creative_inventory = 1 end

	pdef._effect_list = {}
	local effect
	local uses_level = false
	local has_plus = false
	if def._effect_list then
		for name, details in pairs(def._effect_list) do
			effect = vlf_entity_effects.registered_effects[name]
			if effect then
				local ulvl
				if details.uses_level ~= nil then ulvl = details.uses_level
				else ulvl = effect.uses_factor end
				if ulvl then uses_level = true end
				local durvar = true
				if details.dur_variable ~= nil then durvar = details.dur_variable end
				if durvar then has_plus = true end
				pdef._effect_list[name] = {
					uses_level = ulvl,
					level = details.level or 1,
					level_scaling = details.level_scaling or 1,
					dur = details.dur or vlf_entity_effects.DURATION,
					dur_variable = durvar,
					effect_stacks = details.effect_stacks and true or false
				}
			else
				error("Unable to register entity_effect: effect not registered")
			end
		end
	end
	if def.uses_level ~= nil then uses_level = def.uses_level end
	pdef.uses_level = uses_level
	if def.has_potent ~= nil then pdef.has_potent = def.has_potent
	else pdef.has_potent = uses_level end
	pdef._default_potent_level = def.default_potent_level or 2
	pdef._default_extend_level = def.default_extend_level or 1
	pdef.has_plus = has_plus
	local on_use
	if def.drinkable ~= false then
		on_use = generate_on_use(pdef._effect_list, color, def.custom_on_use, def.custom_effect)
	end
	pdef.on_place = on_use
	pdef.on_secondary_use = on_use

	local internal_def = table.copy(pdef)
	minetest.register_craftitem(modname..":"..name, pdef)

	if def.has_splash or def.has_splash == nil then
		local splash_desc = S("Splash @1", pdef.description)
		local sdef = {}
		sdef._tt = def._tt
		sdef._dynamic_tt = def._dynamic_tt
		sdef._longdesc = def._longdesc
		sdef.nocreative = def.nocreative
		sdef.stack_max = pdef.stack_max
		sdef._effect_list = pdef._effect_list
		sdef.uses_level = uses_level
		sdef.has_potent = pdef.has_potent
		sdef.has_plus = has_plus
		sdef._default_potent_level = pdef._default_potent_level
		sdef._default_extend_level = pdef._default_extend_level
		sdef.custom_effect = def.custom_effect
		sdef.on_splash = def.custom_splash_effect
		if not def._effect_list then sdef.instant = true end
		vlf_entity_effects.register_splash(name, splash_desc, color, sdef)
		internal_def.has_splash = true
	end

	if def.has_lingering or def.has_lingering == nil then
		local ling_desc = S("Lingering @1", pdef.description)
		local ldef = {}
		ldef._tt = def._tt
		ldef._dynamic_tt = def._dynamic_tt
		ldef._longdesc = def._longdesc
		ldef.nocreative = def.nocreative
		ldef.stack_max = pdef.stack_max
		ldef._effect_list = pdef._effect_list
		ldef.uses_level = uses_level
		ldef.has_potent = pdef.has_potent
		ldef.has_plus = has_plus
		ldef._default_potent_level = pdef._default_potent_level
		ldef._default_extend_level = pdef._default_extend_level
		ldef.custom_effect = def.custom_effect
		ldef.on_splash = def.custom_splash_effect
		ldef.while_lingering = def.custom_linger_effect
		if not def._effect_list then ldef.instant = true end
		vlf_entity_effects.register_lingering(name, ling_desc, color, ldef)
		internal_def.has_lingering = true
	end

	if def.has_arrow then
		local arr_desc
		if def.desc_prefix and def.desc_suffix then
			arr_desc = S("@1 Arrow @2", def.desc_prefix, def.desc_suffix)
		elseif def.desc_prefix then
			arr_desc = S("@1 Arrow", def.desc_prefix)
		elseif def.desc_suffix then
			arr_desc = S("Arrow @1", def.desc_suffix)
		else
			arr_desc = S("Strange Tipped Arrow")
		end
		local adef = {}
		adef._tt = def._tt
		adef._dynamic_tt = def._dynamic_tt
		adef._longdesc = def._longdesc
		adef.nocreative = def.nocreative
		adef._effect_list = pdef._effect_list
		adef.uses_level = uses_level
		adef.has_potent = pdef.has_potent
		adef.has_plus = has_plus
		adef._default_potent_level = pdef._default_potent_level
		adef._default_extend_level = pdef._default_extend_level
		adef.custom_effect = def.custom_effect
		if not def._effect_list then adef.instant = true end
		vlf_entity_effects.register_arrow(name, arr_desc, color, adef)
		internal_def.has_arrow = true
	end

	vlf_entity_effects.registered_entity_effects[modname..":"..name] = internal_def
end

vlf_entity_effects.register_entity_effect({
	name = "trolling",
	desc_prefix = S("Mighty"),
	desc_suffix = S("of Trolling"),
	_tt = "trololo",
	_dynamic_tt = function(level)
		return "trolololoooololo"
	end,
	_longdesc = "Trolololololo",
	stack_max = 2,
	color = "#00AA00",
	nocreative = true,
	_effect_list = {
		night_vision = {},
		strength = {},
		swiftness = {
			uses_level = false,
			level = 2,
		},
		poison = {
			dur = 10,
		},
	},
	default_potent_level = 5,
	default_extend_level = 3,
})

-- ██████╗░░█████╗░████████╗██╗░█████╗░███╗░░██╗
-- ██╔══██╗██╔══██╗╚══██╔══╝██║██╔══██╗████╗░██║
-- ██████╔╝██║░░██║░░░██║░░░██║██║░░██║██╔██╗██║
-- ██╔═══╝░██║░░██║░░░██║░░░██║██║░░██║██║╚████║
-- ██║░░░░░╚█████╔╝░░░██║░░░██║╚█████╔╝██║░╚███║
-- ╚═╝░░░░░░╚════╝░░░░╚═╝░░░╚═╝░╚════╝░╚═╝░░╚══╝
--
-- ██████╗░███████╗███████╗██╗███╗░░██╗██╗████████╗██╗░█████╗░███╗░░██╗░██████╗
-- ██╔══██╗██╔════╝██╔════╝██║████╗░██║██║╚══██╔══╝██║██╔══██╗████╗░██║██╔════╝
-- ██║░░██║█████╗░░█████╗░░██║██╔██╗██║██║░░░██║░░░██║██║░░██║██╔██╗██║╚█████╗░
-- ██║░░██║██╔══╝░░██╔══╝░░██║██║╚████║██║░░░██║░░░██║██║░░██║██║╚████║░╚═══██╗
-- ██████╔╝███████╗██║░░░░░██║██║░╚███║██║░░░██║░░░██║╚█████╔╝██║░╚███║██████╔╝
-- ╚═════╝░╚══════╝╚═╝░░░░░╚═╝╚═╝░░╚══╝╚═╝░░░╚═╝░░░╚═╝░╚════╝░╚═╝░░╚══╝╚═════╝░


minetest.register_craftitem("vlf_entity_effects:dragon_breath", {
	description = S("Dragon's Breath"),
	_longdesc = S("This item is used in brewing and can be combined with splash entity_effects to create lingering entity_effects."),
	image = "vlf_entity_effects_dragon_breath.png",
	groups = { brewitem = 1, bottle = 1 },
	stack_max = 64,
})

vlf_entity_effects.register_entity_effect({
	name = "awkward",
	desc_prefix = S("Awkward"),
	_tt = S("No effect"),
	_longdesc = S("Has an awkward taste and is used for brewing entity_effects."),
	color = "#0000FF",
})

vlf_entity_effects.register_entity_effect({
	name = "mundane",
	desc_prefix = S("Mundane"),
	_tt = S("No effect"),
	_longdesc = S("Has a terrible taste and is not really useful for brewing entity_effects."),
	color = "#0000FF",
})

vlf_entity_effects.register_entity_effect({
	name = "healing",
	desc_suffix = S("of Healing"),
	_dynamic_tt = function(level)
		return S("+@1 HP", 4 * level)
	end,
	_longdesc = S("Instantly heals."),
	color = "#F82423",
	uses_level = true,
	has_arrow = true,
	custom_effect = function(object, level)
		return vlf_entity_effects.healing_func(object, 4 * level)
	end,
})

vlf_entity_effects.register_entity_effect({
	name = "harming",
	desc_suffix = S("of Harming"),
	_dynamic_tt = function(level)
		return S("-@1 HP", 6 * level)
	end,
	_longdesc = S("Instantly deals damage."),
	color = "#430A09",
	uses_level = true,
	has_arrow = true,
	custom_effect = function(object, level)
		return vlf_entity_effects.healing_func(object, -6 * level)
	end,
})

vlf_entity_effects.register_entity_effect({
	name = "night_vision",
	desc_suffix = S("of Night Vision"),
	_tt = nil,
	_longdesc = S("Increases the perceived brightness of light under a dark sky."),
	color = "#1F1FA1",
	_effect_list = {
		night_vision = {},
	},
	has_arrow = true,
})

vlf_entity_effects.register_entity_effect({
	name = "swiftness",
	desc_suffix = S("of Swiftness"),
	_tt = nil,
	_longdesc = S("Increases walking speed."),
	color = "#7CAFC6",
	_effect_list = {
		swiftness = {},
	},
	has_arrow = true,
})

vlf_entity_effects.register_entity_effect({
	name = "slowness",
	desc_suffix = S("of Slowness"),
	_tt = nil,
	_longdesc = S("Decreases walking speed."),
	color = "#5A6C81",
	_effect_list = {
		slowness = {dur=vlf_entity_effects.DURATION_INV},
	},
	default_potent_level = 4,
	has_arrow = true,
})

vlf_entity_effects.register_entity_effect({
	name = "leaping",
	desc_suffix = S("of Leaping"),
	_tt = nil,
	_longdesc = S("Increases jump strength."),
	color = "#22FF4C",
	_effect_list = {
		leaping = {},
	},
	has_arrow = true,
})

vlf_entity_effects.register_entity_effect({
	name = "withering",
	desc_suffix = S("of Withering"),
	_tt = nil,
	_longdesc = S("Applies the withering effect which deals damage at a regular interval and can kill."),
	color = "#292929",
	_effect_list = {
		withering = {dur=vlf_entity_effects.DURATION_POISON},
	},
	has_arrow = true,
})

vlf_entity_effects.register_entity_effect({
	name = "poison",
	desc_suffix = S("of Poison"),
	_tt = nil,
	_longdesc = S("Applies the poison effect which deals damage at a regular interval."),
	color = "#4E9331",
	_effect_list = {
		poison = {dur=vlf_entity_effects.DURATION_POISON},
	},
	has_arrow = true,
})

vlf_entity_effects.register_entity_effect({
	name = "regeneration",
	desc_suffix = S("of Regeneration"),
	_tt = nil,
	_longdesc = S("Regenerates health over time."),
	color = "#CD5CAB",
	_effect_list = {
		regeneration = {dur=vlf_entity_effects.DURATION_POISON},
	},
	has_arrow = true,
})

vlf_entity_effects.register_entity_effect({
	name = "invisibility",
	desc_suffix = S("of Invisibility"),
	_tt = nil,
	_longdesc = S("Grants invisibility."),
	color = "#7F8392",
	_effect_list = {
		invisibility = {},
	},
	has_arrow = true,
})

vlf_entity_effects.register_entity_effect({
	name = "water_breathing",
	desc_suffix = S("of Water Breathing"),
	_tt = nil,
	_longdesc = S("Grants limitless breath underwater."),
	color = "#2E5299",
	_effect_list = {
		water_breathing = {},
	},
	has_arrow = true,
})

vlf_entity_effects.register_entity_effect({
	name = "fire_resistance",
	desc_suffix = S("of Fire Resistance"),
	_tt = nil,
	_longdesc = S("Grants immunity to damage from heat sources like fire."),
	color = "#E49A3A",
	_effect_list = {
		fire_resistance = {},
	},
	has_arrow = true,
})

vlf_entity_effects.register_entity_effect({
	name = "strength",
	desc_suffix = S("of Strength"),
	_tt = nil,
	_longdesc = S("Increases attack power."),
	color = "#932423",
	_effect_list = {
		strength = {},
	},
	has_arrow = true,
})

vlf_entity_effects.register_entity_effect({
	name = "weakness",
	desc_suffix = S("of Weakness"),
	_tt = nil,
	_longdesc = S("Decreases attack power."),
	color = "#484D48",
	_effect_list = {
		weakness = {},
	},
	has_arrow = true,
})

vlf_entity_effects.register_entity_effect({
	name = "slow_falling",
	desc_suffix = S("of Slow Falling"),
	_tt = nil,
	_longdesc = S("Instead of falling, you descend gracefully."),
	color = "#ACCCFF",
	_effect_list = {
		slow_falling = {},
	},
	has_arrow = true,
})

vlf_entity_effects.register_entity_effect({
	name = "darkness",
	desc_suffix = S("of Darkness"),
	_tt = nil,
	_longdesc = S("Surrounds with darkness."),
	color = "#000000",
	_effect_list = {
		darkness = {},
	},
	has_arrow = true,
})

vlf_entity_effects.register_entity_effect({
	name = "health_boost",
	desc_suffix = S("of Health Boost"),
	_tt = nil,
	_longdesc = S("Increases health."),
	color = "#BE1919",
	_effect_list = {
		health_boost = {},
	},
	has_arrow = true,
})

vlf_entity_effects.register_entity_effect({
	name = "resistance",
	desc_suffix = S("of Resistance"),
	_tt = nil,
	_longdesc = S("Decreases damage taken."),
	color = "#2552A5",
	_effect_list = {
		resistance = {},
	},
	has_arrow = true,
})

vlf_entity_effects.register_entity_effect({
	name = "luck",
	desc_suffix = S("of Luck"),
	_tt = nil,
	_longdesc = S("Increases luck."),
	color = "#7BFF42",
	_effect_list = {
		luck = {},
	},
	has_arrow = true,
})

vlf_entity_effects.register_entity_effect({
	name = "food_poisoning",
	desc_suffix = S("of Food Poisoning"),
	_tt = nil,
	_longdesc = S("Moves bowels too fast."),
	color = "#83A061",
	_effect_list = {
		food_poisoning = {
			dur = vlf_entity_effects.DURATION_POISON,
			effect_stacks = true,
		},
	},
	has_arrow = true,
})

vlf_entity_effects.register_entity_effect({
	name = "ominous",
	desc_prefix = S("Ominous"),
	_tt = nil,
	_longdesc = S("Attracts danger."),
	image = table.concat({
		"(vlf_entity_effects_entity_effect_overlay.png^[colorize:red:100)",
		"^vlf_entity_effects_splash_overlay.png^[colorize:black:100",
		"^vlf_entity_effects_entity_effect_bottle.png",
	}),
	_effect_list = {
		bad_omen = {dur = 6000},
	},
	has_splash = false,
	has_lingering = false,
})

vlf_entity_effects.register_entity_effect({
	name = "infestation",
	desc_suffix = S("of Infestation"),
	_tt = nil,
	_longdesc = S("Causes 1-2 silverfish to spawn with a 10% chance when damaged"),
	color = "#472331",
	_effect_list = {
		infested = {},
	},
	has_arrow = true,
})

vlf_entity_effects.register_entity_effect({
	name = "oozing",
	desc_suffix = S("of Oozing"),
	_tt = nil,
	_longdesc = S("Causes 2 medium slimes to spawn on death"),
	color = "#60AA30",
	_effect_list = {
		oozing = {},
	},
	has_arrow = true,
})

vlf_entity_effects.register_entity_effect({
	name = "weaving",
	desc_suffix = S("of Weaving"),
	_tt = nil,
	_longdesc = S("Causes 2-3 cobwebs to appear on death"),
	color = "#ACCCFF",
	_effect_list = {
		weaving = {},
	},
	has_arrow = true,
})

-- COMPAT CODE
local function replace_legacy_entity_effect(itemstack)
	local name = itemstack:get_name()
	local suffix = ""
	local bare_name = name:match("^(.+)_splash$")
	if bare_name then
		suffix = "_splash"
	else
		bare_name = name:match("^(.+)_lingering$")
		if bare_name then
			suffix = "_lingering"
		else
			bare_name = name:match("^(.+)_arrow$")
			if bare_name then
				suffix = "_arrow"
			else
				bare_name = name
			end
		end
	end
	local new_name = bare_name:match("^(.+)_plus$")
	local new_stack
	if new_name then
		new_stack = ItemStack(new_name..suffix)
		new_stack:get_meta():set_int("vlf_entity_effects:entity_effect_plus",
			registered_entity_effects[new_name]._default_extend_level)
		new_stack:set_count(itemstack:get_count())
		tt.reload_itemstack_description(new_stack)
	end
	new_name = bare_name:match("^(.+)_2$")
	if new_name then
		new_stack = ItemStack(new_name..suffix)
		new_stack:get_meta():set_int("vlf_entity_effects:entity_effect_potent",
			registered_entity_effects[new_name]._default_potent_level-1)
		new_stack:set_count(itemstack:get_count())
		tt.reload_itemstack_description(new_stack)
	end
	return new_stack
end
local compat = "vlf_entity_effects:compat_entity_effect"
local compat_arrow = "vlf_entity_effects:compat_arrow"
minetest.register_craftitem(compat, {
	description = S("Unknown Potion"),
	_tt_help = S("Right-click to identify"),
	image = "vlf_entity_effects_entity_effect_overlay.png^[colorize:#00F:127^vlf_entity_effects_entity_effect_bottle.png^vl_unknown.png",
	on_secondary_use = replace_legacy_entity_effect,
	on_place = replace_legacy_entity_effect,
})
minetest.register_craftitem(compat_arrow, {
	description = S("Unknown Tipped Arrow"),
	_tt_help = S("Right-click to identify"),
	image = "vlf_bows_arrow_inv.png^(vlf_entity_effects_arrow_inv.png^[colorize:#FFF:100)^vl_unknown.png",
	on_secondary_use = replace_legacy_entity_effect,
	on_place = replace_legacy_entity_effect,
})

local old_entity_effects_plus = {
	"fire_resistance", "water_breathing", "invisibility", "regeneration", "poison",
	"withering", "leaping", "slowness", "swiftness", "night_vision"
}
local old_entity_effects_2 = {
	"healing", "harming", "swiftness", "slowness", "leaping",
	"withering", "poison", "regeneration"
}

for _, name in pairs(old_entity_effects_2) do
	minetest.register_alias("vlf_entity_effects:" .. name .. "_2", compat)
	minetest.register_alias("vlf_entity_effects:" .. name .. "_2_splash", compat)
	minetest.register_alias("vlf_entity_effects:" .. name .. "_2_lingering", compat)
	minetest.register_alias("vlf_entity_effects:" .. name .. "_2_arrow", compat_arrow)
end
for _, name in pairs(old_entity_effects_plus) do
	minetest.register_alias("vlf_entity_effects:" .. name .. "_plus", compat)
	minetest.register_alias("vlf_entity_effects:" .. name .. "_plus_splash", compat)
	minetest.register_alias("vlf_entity_effects:" .. name .. "_plus_lingering", compat)
	minetest.register_alias("vlf_entity_effects:" .. name .. "_plus_arrow", compat_arrow)
end
