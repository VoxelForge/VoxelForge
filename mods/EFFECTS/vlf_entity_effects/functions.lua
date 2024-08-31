local S = minetest.get_translator(minetest.get_current_modname())

-- TODO: when < minetest 5.9 isn't supported anymore, remove this variable check and replace all occurences of [hud_elem_type_field] with type
local hud_elem_type_field = "type"
if not minetest.features.hud_def_type_field then
	hud_elem_type_field = "hud_elem_type"
end

local EF = {}
vlf_entity_effects.registered_effects = {}
local registered_effects = vlf_entity_effects.registered_effects -- shorthand ref

-- effects affecting item speed utilize numerous hacks, so they have to be counted separately
local item_speed_effects = {}

local EFFECT_TYPES = 0
minetest.register_on_mods_loaded(function()
	for _,_ in pairs(EF) do
		EFFECT_TYPES = EFFECT_TYPES + 1
	end
end)

-- ██████╗░███████╗░██████╗░██╗░██████╗████████╗███████╗██████╗
-- ██╔══██╗██╔════╝██╔════╝░██║██╔════╝╚══██╔══╝██╔════╝██╔══██╗
-- ██████╔╝█████╗░░██║░░██╗░██║╚█████╗░░░░██║░░░█████╗░░██████╔╝
-- ██╔══██╗██╔══╝░░██║░░╚██╗██║░╚═══██╗░░░██║░░░██╔══╝░░██╔══██╗
-- ██║░░██║███████╗╚██████╔╝██║██████╔╝░░░██║░░░███████╗██║░░██║
-- ╚═╝░░╚═╝╚══════╝░╚═════╝░╚═╝╚═════╝░░░░╚═╝░░░╚══════╝╚═╝░░╚═╝
--
-- ███████╗███████╗███████╗███████╗░█████╗░████████╗░██████╗
-- ██╔════╝██╔════╝██╔════╝██╔════╝██╔══██╗╚══██╔══╝██╔════╝
-- █████╗░░█████╗░░█████╗░░█████╗░░██║░░╚═╝░░░██║░░░╚█████╗░
-- ██╔══╝░░██╔══╝░░██╔══╝░░██╔══╝░░██║░░██╗░░░██║░░░░╚═══██╗
-- ███████╗██║░░░░░██║░░░░░███████╗╚█████╔╝░░░██║░░░██████╔╝
-- ╚══════╝╚═╝░░░░░╚═╝░░░░░╚══════╝░╚════╝░░░░╚═╝░░░╚═════╝░

local function generate_linear_lvl_to_fac(l1, l2)
	local a = l2 - l1
	local b = 2*l1 - l2
	return function(level)
		return (a*level + b)
	end
end

local function generate_linear_fac_to_lvl(l1, l2)
	local a = 1/(l2 - l1)
	local b = -(2*l1 - l2) * a
	return function(factor)
		return math.round(a*factor + b)
	end
end

local function generate_rational_lvl_to_fac(l1, l2)
	local a = (l1 - l2) * 2
	local b = 2*l2 - l1
	return function(level)
		if level == 0 then return 0 end
		return (a/level + b)
	end
end

local function generate_rational_fac_to_lvl(l1, l2)
	local a = (l1 - l2) * 2
	local b = 2*l2 - l1
	return function(factor)
		if (factor - b) == 0 then return math.huge end
		return math.round(a/(factor - b))
	end
end

local function generate_modifier_func(name, dmg_flag, mod_func, is_type)
	if dmg_flag == "" then return function(object, damage, reason)
		if EF[name][object] and not reason.flags.bypasses_magic then
			return mod_func and mod_func(damage, EF[name][object]) or 0
		end
	end
	elseif is_type then return function(object, damage, reason)
		if EF[name][object] and not reason.flags.bypasses_magic and reason.type == dmg_flag then
			return mod_func and mod_func(damage, EF[name][object]) or 0
		end
	end
	else return function(object, damage, reason)
		if EF[name][object] and not reason.flags.bypasses_magic and reason.flags[dmg_flag] then
			return mod_func and mod_func(damage, EF[name][object]) or 0
		end
	end end
end

-- API - registers an effect
-- required parameters in def:
-- name - string - effect name in code
-- description - translated string - actual effect name in game
-- optional parameters in def:
-- get_tt - function(factor) - returns tooltip description text for use with effects
-- icon - string - file name of the effect icon in HUD - defaults to one based on name
-- res_condition - function(object) - returning true if target is to be resistant to the effect
-- on_start - function(object, factor) - called when dealing the effect
-- on_load - function(object, factor) - called on_joinplayer and on_activate
-- on_step - function(dtime, object, factor, duration) - running every step for all objects with this effect
-- on_hit_timer - function(object, factor, duration) - if defined runs a hit_timer depending on timer_uses_factor value
-- on_end - function(object) - called when the effect wears off
-- after_end - function(object) - called when the effect wears off, after purging the data of the effect
-- on_save_effect - function(object - called when the effect is to be serialized for saving (supposed to do cleanup)
-- particle_color - string - colorstring for particles - defaults to #3000EE
-- uses_factor - bool - whether factor affects the effect
-- lvl1_factor - number - factor for lvl1 effect - defaults to 1 if uses_factor
-- lvl2_factor - number - factor for lvl2 effect - defaults to 2 if uses_factor
-- timer_uses_factor - bool - whether hit_timer uses factor (uses_factor must be true) or a constant value (hit_timer_step must be defined)
-- hit_timer_step - float - interval between hit_timer hits
-- damage_modifier - string - damage flag of which damage is changed as defined by modifier_func, pass empty string for all damage
-- dmg_mod_is_type - bool - damage_modifier string is used as type instead of flag of damage, defaults to false
-- modifier_func - function(damage, effect_vals) - see damage_modifier, if not defined damage_modifier defaults to 100% resistance
-- modifier_priority - integer - priority passed when registering damage_modifier - defaults to -50
-- affects_item_speed - table
-- -- if provided, effect gets added to the item_speed_effects table, this should be true if the effect affects item speeds,
-- -- otherwise it won't work properly with other such effects (like haste and fatigue)
-- -- -- factor_is_positive - bool - whether values of factor between 0 and 1 should be considered +factor% or speed multiplier
-- -- --   - obviously +factor% is positive and speed multiplier is negative interpretation
-- -- --   - values of factor higher than 1 will have a positive effect regardless
-- -- --   - values of factor lower than 0 will have a negative effect regardless
-- -- --   - open an issue on our tracker if you have a usage that isn't supported by this API
function vlf_entity_effects.register_effect(def)
	local modname = minetest.get_current_modname()
	local name = def.name
	assert(name ~= nil, "Unable to register effect: name is nil")
	assert(type(name) == "string", "Unable to register effect: name is not a string")
	assert(name ~= "list" and name ~= "heal" and name ~= "remove" and name ~= "clear", "Unable to register effect: " .. name .. " is a reserved word")
	assert(not registered_effects[name], "Effect named "..name.." already registered!")
	assert(def.description and type(def.description) == "string", "Unable to register effect: description is not a string")
	local pdef = {}
	pdef.description = def.description
	if not def.icon then
		pdef.icon = modname.."_effect_"..name..".png"
	else
		pdef.icon = def.icon
	end
	pdef.get_tt = def.get_tt
	pdef.res_condition = def.res_condition
	pdef.on_start = def.on_start
	pdef.on_reject = def.on_reject
	pdef.on_load = def.on_load
	pdef.on_step = def.on_step
	pdef.on_hit_timer = def.on_hit_timer
	pdef.on_end = def.on_end
	pdef.on_save_effect = def.on_save_effect
	if not def.particle_color then
		pdef.particle_color = "#3000EE"
	else
		pdef.particle_color = def.particle_color
	end
	if def.uses_factor then
		pdef.uses_factor = true
		local l1 = def.lvl1_factor or 1
		local l2 = def.lvl2_factor or 2*l1
		if l1 < l2 then
			pdef.level_to_factor = generate_linear_lvl_to_fac(l1, l2)
			pdef.factor_to_level = generate_linear_fac_to_lvl(l1, l2)
			pdef.inv_factor = false
		elseif l1 > l2 then
			pdef.level_to_factor = generate_rational_lvl_to_fac(l1, l2)
			pdef.factor_to_level = generate_rational_fac_to_lvl(l1, l2)
			pdef.inv_factor = true
		else
			error("Can't extrapolate levels from lvl1 and lvl2 bearing the same factor")
		end
	else
		pdef.uses_factor = false
	end
	if def.on_hit_timer then
		if def.timer_uses_factor then
			assert(def.uses_factor, "Uses factor but does not use factor?")
			pdef.timer_uses_factor = true
		else
			assert(def.hit_timer_step, "If hit_timer does not use factor, hit_timer_step must be defined")
			pdef.timer_uses_factor = false
			pdef.hit_timer_step = def.hit_timer_step
		end
	end
	if def.damage_modifier then
		vlf_damage.register_modifier(
			generate_modifier_func(name, def.damage_modifier, def.modifier_func, def.dmg_mod_is_type),
			def.modifier_priority or -50
		)
	end
	registered_effects[name] = pdef
	EF[name] = {}
	item_speed_effects[name] = def.affects_item_speed
end

vlf_entity_effects.register_effect({
	name = "invisibility",
	description = S("Invisiblity"),
	icon = "vlf_entity_effects_effect_invisible.png",
	get_tt = function(factor)
		return S("body is invisible")
	end,
	on_start = function(object, factor)
		vlf_entity_effects.make_invisible(object, true)
	end,
	on_load = function(object, factor)
		vlf_entity_effects.make_invisible(object, true)
	end,
	on_end = function(object)
		vlf_entity_effects.make_invisible(object, false)
	end,
	particle_color = "#7F8392",
	uses_factor = false,
})

vlf_entity_effects.register_effect({
	name = "poison",
	description = S("Poison"),
	icon = "vlf_entity_effects_effect_poisoned.png",
	get_tt = function(factor)
		return S("-1 HP / @1 s", factor)
	end,
	res_condition = function(object)
		local entity = object:get_luaentity()
		return (entity and (entity.harmed_by_heal or string.find(entity.name, "spider")))
	end,
	on_hit_timer = function(object, factor, duration)
		if vlf_util.get_hp(object) - 1 > 0 then
			vlf_util.deal_damage(object, 1, {type = "magic"})
		end
	end,
	particle_color = "#4E9331",
	uses_factor = true,
	lvl1_factor = 1.25,
	lvl2_factor = 0.6,
	timer_uses_factor = true,
})

vlf_entity_effects.register_effect({
	name = "regeneration",
	description = S("Regeneration"),
	icon = "vlf_entity_effects_effect_regenerating.png",
	get_tt = function(factor)
		return S("+1 HP / @1 s", factor)
	end,
	res_condition = function(object)
		local entity = object:get_luaentity()
		return (entity and entity.harmed_by_heal)
	end,
	on_hit_timer = function(object, factor, duration)
		local entity = object:get_luaentity()
		if object:is_player() then
			object:set_hp(math.min(object:get_properties().hp_max or 20, object:get_hp() + 1), { type = "set_hp", other = "regeneration" })
		elseif entity and entity.is_mob then
		    local hp_max = object:get_properties ().hp_max
		    entity.health = math.min(hp_max, entity.health + 1)
		end
	end,
	particle_color = "#CD5CAB",
	uses_factor = true,
	lvl1_factor = 2.5,
	lvl2_factor = 1.25,
	timer_uses_factor = true,
})

vlf_entity_effects.register_effect({
	name = "strength",
	description = S("Strength"),
	icon = "vlf_entity_effects_effect_strong.png",
	get_tt = function(factor)
		return S("+@1% melee damage", 100*(factor-1))
	end,
	particle_color = "#932423",
	uses_factor = true,
	lvl1_factor = 1.3,
	lvl2_factor = 1.6,
})

vlf_entity_effects.register_effect({
	name = "weakness",
	icon = "vlf_entity_effects_effect_weak.png",
	description = S("Weakness"),
	get_tt = function(factor)
		return S("-@1% melee damage", 100*(1-factor))
	end,
	particle_color = "#485D48",
	uses_factor = true,
	lvl1_factor = 0.8,
	lvl2_factor = 0.6,
})

-- implementation of strength and weakness effects
-- mobs have this implemented in vlf_mobs/combat.lua in mob_class:on_punch()
vlf_damage.register_modifier(function(object, damage, reason)
	if reason.direct and reason.direct == reason.source then
		local hitter = reason.direct
		local strength = EF.strength[hitter]
		local weakness = EF.weakness[hitter]
		if not strength and not weakness then return end
		local str_fac = strength and strength.factor or 1
		local weak_fac = weakness and weakness.factor or 1
		return damage * str_fac * weak_fac
	end
end, 0)

vlf_entity_effects.register_effect({
	name = "water_breathing",
	description = S("Water Breathing"),
	get_tt = function(factor)
		return S("limitless breathing under water")
	end,
	on_step = function(dtime, object, factor, duration)
		if object:get_breath() then
			hb.hide_hudbar(object, "breath")
			if object:get_breath() < 10 then object:set_breath(10) end
		else
		    local entity = object:get_luaentity ()
		    if entity and entity.is_mob then
			-- This should apply to waterborne creatures
			-- also:
			-- https://minecraft.wiki/w/Water_Breathing.
			entity:reset_breath ()
		    end
		end
	end,
	particle_color = "#2E5299",
	uses_factor = false,
})

local function add_physics_factor (object, player_name, mob_field,
				   id, factor, mob_field2, mob_field3)
    -- mob_field2 and 3 are for cases where two or more mob properties
    -- must be adjusted, such as walk_velocity and run_velocity and
    -- their ilk.
    if object:is_player () then
	playerphysics.add_physics_factor (object, player_name,
					  id, factor)
    else
	local entity = object:get_luaentity ()
	if entity and entity.is_mob then
	    entity:add_physics_factor (mob_field, id, factor)
	    if mob_field2 then
		entity:add_physics_factor (mob_field2, id, factor)
		if mob_field3 then
		    entity:add_physics_factor (mob_field3, id, factor)
		end
	    end
	end
    end
end

local function remove_physics_factor (object, player_name, mob_field,
				      id, mob_field2, mob_field3)
    if object:is_player () then
	playerphysics.remove_physics_factor (object, player_name, id)
    else
	local entity = object:get_luaentity ()
	if entity and entity.is_mob then
	    entity:remove_physics_factor (mob_field, id)
	    if mob_field2 then
		entity:remove_physics_factor (mob_field2, id)
		if mob_field3 then
		    entity:remove_physics_factor (mob_field3, id)
		end
	    end
	end
    end
end

vlf_entity_effects.register_effect({
	name = "dolphin_grace",
	description = S("Dolphin's Grace"),
	get_tt = function(factor)
		return S("swimming gracefully")
	end,
	on_hit_timer = function(object, factor, duration)
		local node = minetest.get_node_or_nil(object:get_pos())
		-- TODO: apply this only to swimming for mobs.
		if node and minetest.registered_nodes[node.name]
			and minetest.get_item_group(node.name, "liquid") ~= 0 then
		    add_physics_factor (object, "speed", "walk_velocity",
					"vlf_entity_effects:dolphin", 1.6)
		else
		    remove_physics_factor (object, "speed", "walk_velocity",
					   "vlf_entity_effects:dolphin")
		end
	end,
	particle_color = "#6AABFD",
	uses_factor = false,
	timer_uses_factor = false,
	hit_timer_step = 1,
})

vlf_entity_effects.register_effect({
	name = "leaping",
	description = S("Leaping"),
	get_tt = function(factor)
		if factor > 0 then return S("+@1% jumping power", math.floor(factor*100)) end
		return S("-@1% jumping power", math.floor(-factor*100))
	end,
	on_start = function(object, factor)
	    add_physics_factor (object, "jump", "jump_height",
				"vlf_entity_effects:leaping", 1 + factor)
	end,
	on_end = function(object)
	    remove_physics_factor (object, "jump", "jump_height",
				   "vlf_entity_effects:leaping")
	end,
	particle_color = "#22FF4C",
	uses_factor = true,
	lvl1_factor = 0.5,
	lvl2_factor = 1,
})

vlf_entity_effects.register_effect({
	name = "slow_falling",
	description = S("Slow Falling"),
	get_tt = function(factor)
		return S("decreases gravity effects")
	end,
	on_start = function(object, factor)
	    add_physics_factor (object, "gravity", "fall_speed",
				"vlf_entity_effects:slow_falling", 0.5)
	end,
	on_step = function(dtime, object, factor, duration)
	    local vel = object:get_velocity()

	    if vel then
		if vel.y < -3 then
		    object:add_velocity(vector.new(0,-3-vel.y,0))
		end
	    end
	end,
	on_end = function(object)
	    remove_physics_factor (object, "gravity", "fall_speed",
				   "vlf_entity_effects:slow_falling")
	end,
	particle_color = "#ACCCFF",
})

vlf_entity_effects.register_effect({
	name = "swiftness",
	description = S("Swiftness"),
	icon = "vlf_entity_effects_effect_swift.png",
	get_tt = function(factor)
		return S("+@1% running speed", math.floor(factor*100))
	end,
	on_start = function(object, factor)
	    add_physics_factor (object, "speed", "walk_velocity",
				"vlf_entity_effects:swiftness", 1 + factor,
				"run_velocity")
	end,
	on_end = function(object)
	    remove_physics_factor (object, "speed", "walk_velocity",
				   "vlf_entity_effects:swiftness", "run_velocity")
	end,
	particle_color = "#7CAFC6",
	uses_factor = true,
	lvl1_factor = 0.2,
	lvl2_factor = 0.4,
})

vlf_entity_effects.register_effect({
	name = "slowness",
	description = S("Slowness"),
	icon = "vlf_entity_effects_effect_slow.png",
	get_tt = function(factor)
		return S("-@1% running speed", math.floor(factor*100))
	end,
	on_start = function(object, factor)
	    add_physics_factor (object, "speed", "walk_velocity",
				"vlf_entity_effects:slowness", 1 - factor,
				"run_velocity")
	end,
	on_end = function(object)
	    remove_physics_factor (object, "speed", "walk_velocity",
				   "vlf_entity_effects:slowness", "run_velocity")
	end,
	particle_color = "#5A6C81",
	uses_factor = true,
	lvl1_factor = 0.15,
	lvl2_factor = 0.3,
})

vlf_entity_effects.register_effect({
	name = "levitation",
	description = S("Levitation"),
	get_tt = function(factor)
		return S("moves body upwards at @1 nodes/s", factor)
	end,
	on_step = function(dtime, object, factor, duration)
		local vel = object:get_velocity().y
		if vel<factor then object:add_velocity(vector.new(0,factor,0)) end
	end,
	particle_color = "#420E7E",
	uses_factor = true,
	lvl1_factor = 0.9,
	lvl2_factor = 1.8,
})

vlf_entity_effects.register_effect({
	name = "night_vision",
	description = S("Night Vision"),
	get_tt = function(factor)
		return S("improved vision during the night")
	end,
	on_start = function(object, factor)
	    if object:is_player () then
		object:get_meta():set_int("night_vision", 1)
		vlf_weather.skycolor.update_sky_color({object})
	    end
	end,
	on_load = function(object, factor)
	    if object:is_player () then
		object:get_meta():set_int("night_vision", 1)
		vlf_weather.skycolor.update_sky_color({object})
	    end
	end,
	on_step = function(dtime, object, factor, duration)
	    if object:is_player () then
		vlf_weather.skycolor.update_sky_color({object})
	    end
	end,
	on_end = function(object)
	    if object:is_player () then
		local meta = object:get_meta()
		meta:set_int("night_vision", 0)
		vlf_weather.skycolor.update_sky_color({object})
	    end
	end,
	particle_color = "#1F1FA1",
	uses_factor = false,
})

vlf_entity_effects.register_effect({
	name = "darkness",
	description = S("Darkness"),
	get_tt = function(factor)
		return S("surrounded by darkness").."\n"..S("not seeing anything beyond @1 nodes", factor)
	end,
	on_start = function(object, factor)
	    if object:is_player () then
		object:get_meta():set_int("darkness", 1)
		vlf_weather.skycolor.update_sky_color({object})
		object:set_sky({fog = {
			fog_distance = factor,
		}})
		EF.darkness[object].flash = 0.6
	    end
	end,
	on_step = function(dtime, object, factor, duration)
	    if object:is_player () then
		if object:get_meta():get_int("night_vision") ~= 1 then
			local flash = EF.darkness[object].flash
			if flash < 0.2 then EF.darkness[object].flashdir = true
			elseif flash > 0.6 then EF.darkness[object].flashdir = false end
			flash = EF.darkness[object].flashdir and (flash + dtime) or (flash - dtime)
			object:set_sky({fog = {
				fog_start = flash,
			}})
			EF.darkness[object].flash = flash
		else
			object:set_sky({fog = {
				fog_start = 0.9,
			}})
		end
		vlf_weather.skycolor.update_sky_color({object})
	    end
	end,
	on_end = function(object)
	    if object:is_player () then
		object:get_meta():set_int("darkness", 0)
		vlf_weather.skycolor.update_sky_color({object})
		object:set_sky({fog = {
			fog_distance = -1,
			fog_start = -1,
		}})
	    end
	end,
	particle_color = "#000000",
	uses_factor = true,
	lvl1_factor = 30,
	lvl2_factor = 20,
})

local GLOW_DISTANCE = 30
local CLOSE_GLOW_LIMIT = 3
local MIN_GLOW_SCALE = 1
local MAX_GLOW_SCALE = 4
local SCALE_DIFF = MAX_GLOW_SCALE - MIN_GLOW_SCALE
local SCALE_FACTOR = (GLOW_DISTANCE - CLOSE_GLOW_LIMIT) / SCALE_DIFF
local abs = math.abs
vlf_entity_effects.register_effect({
	name = "glowing",
	description = S("Glowing"),
	get_tt = function(factor)
		return S("more visible at all times")
	end,
	on_start = function(object, factor)
		EF.glowing[object].waypoints = {}
	end,
	on_step = function(dtime, object, factor, duration)
		local pos = object:get_pos()
		if not pos then return end
		local x, y, z = pos.x, pos.y, pos.z
		for _, player in pairs(minetest.get_connected_players()) do
			local pp = player:get_pos()
			if pp and player ~= object then
				local hud_id = EF.glowing[object].waypoints[player]
				if abs(pp.x-x) < GLOW_DISTANCE and abs(pp.y-y) < GLOW_DISTANCE
					and abs(pp.z-z) < GLOW_DISTANCE then
						local distance = vector.distance(pos, pp)
						local scale
						if distance <= CLOSE_GLOW_LIMIT then scale = MAX_GLOW_SCALE
						elseif distance >= GLOW_DISTANCE then scale = MIN_GLOW_SCALE
						else scale = (GLOW_DISTANCE - distance) / SCALE_FACTOR + MIN_GLOW_SCALE end
						if hud_id then
							player:hud_change(hud_id, "world_pos", pos)
							player:hud_change(hud_id, "scale", {x = scale, y = scale})
						else
							EF.glowing[object].waypoints[player] = player:hud_add({
								hud_elem_type = "image_waypoint",
								position = {x = 0.5, y = 0.5},
								scale = {x = scale, y = scale},
								text = "vlf_entity_effects_glow_waypoint.png",
								alignment = {x = 0, y = -1},
								world_pos = pos,
							})
						end
				elseif hud_id then
					player:hud_remove(hud_id)
					EF.glowing[object].waypoints[player] = nil
				end
			end
		end
	end,
	on_end = function(object)
		for player, hud_id in pairs(EF.glowing[object].waypoints) do
			if player:get_pos() then player:hud_remove(hud_id) end
		end
	end,
	on_save_effect = function(object)
		for player, hud_id in pairs(EF.glowing[object].waypoints) do
			if player:get_pos() then player:hud_remove(hud_id) end
		end
		EF.glowing[object].waypoints = {}
	end,
	particle_color = "#FFFF77",
	uses_factor = false,
})

vlf_entity_effects.register_effect({
	name = "health_boost",
	description = S("Health Boost"),
	get_tt = function(factor)
		return S("HP increased by @1", factor)
	end,
	on_start = function(object, factor)
	    if object:is_player () then
		-- TODO can mob "physics" overrides also affect hp?
		object:set_properties({hp_max = minetest.PLAYER_MAX_HP_DEFAULT+factor})
	    end
	end,
	on_end = function(object)
	    if object:is_player () then
		object:set_properties({hp_max = minetest.PLAYER_MAX_HP_DEFAULT})
	    end
	end,
	particle_color = "#FF2222",
	uses_factor = true,
	lvl1_factor = 4,
	lvl2_factor = 8,
})

vlf_entity_effects.register_effect({
	name = "absorption",
	description = S("Absorption"),
	get_tt = function(factor)
		return S("absorbs up to @1 incoming damage", factor)
	end,
	on_start = function(object, factor)
		hb.change_hudbar(object, "absorption", factor, (math.floor(factor/20-0.05)+1)*20)
		EF.absorption[object].absorb = factor
	end,
	on_reject = function (object, factor)
	    -- Remaining absorption health might fall short of what
	    -- this level provides, despite the currently active
	    -- effect being nominally superior.
	    if EF.absorption[object].absorb < factor then
		hb.change_hudbar(object, "absorption", factor, (math.floor(factor/20-0.05)+1)*20)
		EF.absorption[object].absorb = factor
		return true
	    end
	end,
	on_load = function(object, factor)
		minetest.after(0, function() hb.change_hudbar(object, "absorption", nil, (math.floor(factor/20-0.05)+1)*20) end)
	end,
	on_step = function(dtime, object, factor, duration)
		hb.change_hudbar(object, "absorption", EF.absorption[object].absorb)
	end,
	on_end = function(object)
		hb.change_hudbar(object, "absorption", 0)
	end,
	particle_color = "#B59500",
	uses_factor = true,
	lvl1_factor = 4,
	lvl2_factor = 8,
	damage_modifier = "",
	modifier_priority = 300,
	modifier_func = function(damage, effect_vals)
		local absorb = effect_vals.absorb
		local carryover = 0
		if absorb > damage then
			effect_vals.absorb = absorb - damage
		else
			carryover = damage - absorb
			effect_vals.absorb = 0
		end
		return carryover
	end,
})

vlf_entity_effects.register_effect({
	name = "fire_resistance",
	description = S("Fire Resistance"),
	icon = "vlf_entity_effects_effect_fire_proof.png",
	get_tt = function(factor)
		return S("resistance to fire damage")
	end,
	particle_color = "#E49A3A",
	uses_factor = false,
	damage_modifier = "is_fire",
})

vlf_entity_effects.register_effect({
	name = "resistance",
	description = S("Resistance"),
	get_tt = function(factor)
		return S("resist @1% of incoming damage", math.floor(factor*100))
	end,
	particle_color = "#2552A5",
	uses_factor = true,
	lvl1_factor = 0.2,
	lvl2_factor = 0.4,
	damage_modifier = "",
	modifier_func = function(damage, effect_vals)
		return damage - (effect_vals.factor)*damage
	end,
})

vlf_entity_effects.register_effect({
	name = "luck",
	description = S("Luck"),
	particle_color = "#7BFF42",
	on_start = function(object, factor)
		-- TODO: Luck that only influences loot tables as in
		-- Minecraft.
	end,
	uses_factor = true,
})

vlf_entity_effects.register_effect({
	name = "bad_luck",
	description = S("Bad Luck"),
	particle_color = "#887343",
	on_start = function(object, factor)
	    -- TODO: Bad Luck that only influences loot tables as in
	    -- Minecraft.
	end,
	uses_factor = true,
})

vlf_entity_effects.register_effect({
	name = "bad_omen",
	description = S("Bad Omen"),
	get_tt = function(factor)
		return S("danger is imminent")
	end,
	particle_color = "#472331",
	uses_factor = true,
})

vlf_entity_effects.register_effect({
	name = "hero_of_village",
	description = S("Hero of the Village"),
	particle_color = "#44FF44",
})

vlf_entity_effects.register_effect({
	name = "withering",
	description = S("Withering"),
	get_tt = function(factor)
		return S("-1 HP / @1 s, can kill", factor)
	end,
	res_condition = function(object)
		local entity = object:get_luaentity()
		return (entity and string.find(entity.name, "wither"))
	end,
	on_hit_timer = function(object, factor, duration)
		if object:is_player() or object:get_luaentity() then
			vlf_util.deal_damage(object, 1, {type = "magic"})
		end
	end,
	particle_color = "#292929",
	uses_factor = true,
	lvl1_factor = 2,
	lvl2_factor = 1,
	timer_uses_factor = true,
})

vlf_entity_effects.register_effect({
	name = "blindness",
	description = "Blindness",
	get_tt = function(factor)
		return S("impaired sight")
	end,
	on_start = function(object, factor)
	    if object:is_player () then
		EF.blindness[object].vignette = object:hud_add({
			hud_elem_type = "image",
			position = {x = 0.5, y = 0.5},
			scale = {x = -101, y = -101},
			text = "vlf_entity_effects_blindness_hud.png",
			z_index = -401
		})
	    end
	end,
	on_load = function(object, factor)
	    if object:is_player () then
		EF.blindness[object].vignette = object:hud_add({
			hud_elem_type = "image",
			position = {x = 0.5, y = 0.5},
			scale = {x = -101, y = -101},
			text = "vlf_entity_effects_blindness_hud.png",
			z_index = -401
		})
	    end
	end,
	on_end = function(object)
	    if object:is_player () then
		if not EF.blindness[object] then return end
		object:hud_remove(EF.blindness[object].vignette)
	    end
	end,
	particle_color = "#686868",
	uses_factor = false,
})

-- TODO: FOV changes for the foregoing two effects.

vlf_entity_effects.register_effect({
	name = "hunger",
	description = S("Hunger"),
	icon = "vlf_entity_effects_effect_food_poisoning.png",
	get_tt = function(factor)
		return S("exhausts by @1 per second", factor)
	end,
	on_start = function(object, factor)
	    if object:is_player () and vlf_hunger.active then
		hb.change_hudbar(object, "hunger", nil, nil, "vlf_hunger_icon_foodpoison.png", nil, "vlf_hunger_bar_foodpoison.png")
		if vlf_hunger.debug then
			hb.change_hudbar(object, "exhaustion", nil, nil, nil, nil, "vlf_hunger_bar_foodpoison.png")
		end
	    end
	end,
	on_load = function(object, factor) -- TODO refactor and add hunger bar modifier API
	    if object:is_player () and vlf_hunger.active then
		hb.change_hudbar(object, "hunger", nil, nil, "vlf_hunger_icon_foodpoison.png", nil, "vlf_hunger_bar_foodpoison.png")
		if vlf_hunger.debug then
			hb.change_hudbar(object, "exhaustion", nil, nil, nil, nil, "vlf_hunger_bar_foodpoison.png")
		end
	    end
	end,
	on_step = function(dtime, object, factor, duration)
	    if object:is_player () and vlf_hunger.active then
		vlf_hunger.exhaust(object:get_player_name(), dtime*factor)
	    end
	end,
	on_end = function(object)
	    if object:is_player () and vlf_hunger.active then
		vlf_hunger.reset_bars_poison_hunger(object)
	    end
	end,
	particle_color = "#83A061",
	uses_factor = true,
	lvl1_factor = 100,
	lvl2_factor = 200,
})

vlf_entity_effects.register_effect({
	name = "nausea",
	description = S("Nausea"),
	get_tt = function(factor)
		return S("not feeling very well...").."\n"..S("frequency: @1 / 1 s", factor)
	end,
	on_start = function(object, factor)
		object:set_lighting({
			saturation = -1.0,
		})
	end,
	on_hit_timer = function(object, factor, duration)
		if EF.nausea[object].nauseated then
			EF.nausea[object].nauseated = false
		else

			EF.nausea[object].nauseated = true
		end
	end,
	on_end = function(object)
		object:set_lighting({
			saturation = 1.0,
		})

	end,
	particle_color = "#60AA30",
	uses_factor = true,
	lvl1_factor = 2,
	lvl2_factor = 1,
	timer_uses_factor = true,
})

vlf_entity_effects.register_effect({
	name = "saturation",
	description = S("Saturation"),
	get_tt = function(factor)
		return S("saturates by @1 per second", factor)
	end,
	on_step = function(dtime, object, factor, duration)
	    if object:is_player () then
		vlf_hunger.set_hunger(object, math.min(vlf_hunger.get_hunger(object)+dtime*factor, 20))
		vlf_hunger.saturate(object:get_player_name(), dtime*factor)
	    end
	end,
	particle_color = "#CEAE29",
	uses_factor = true,
})

-- constants relevant for effects altering mining and attack speed
local LONGEST_MINING_TIME = 300
local LONGEST_PUNCH_INTERVAL = 10
vlf_entity_effects.LONGEST_MINING_TIME = LONGEST_MINING_TIME
vlf_entity_effects.LONGEST_PUNCH_INTERVAL = LONGEST_PUNCH_INTERVAL

function vlf_entity_effects.apply_haste_fatigue(toolcaps, h_fac, f_fac)
	local interval = toolcaps.full_punch_interval
	local h_level = registered_effects.haste.factor_to_level (h_fac)
	local f_level = registered_effects.fatigue.factor_to_level (f_fac)
	interval = interval * (1.0 + 0.1 * (-h_level + f_level))
	toolcaps.full_punch_interval = math.min (interval, LONGEST_PUNCH_INTERVAL)
	for name, group in pairs(toolcaps.groupcaps) do
		local t = group.times
		for i=1, #t do
			if f_fac == 0 then
				t[i] = t[i] > LONGEST_MINING_TIME and t[i] or LONGEST_MINING_TIME
			else
				local old_time = t[i]
				t[i] = t[i] / (1+h_fac) / f_fac
				if old_time < LONGEST_MINING_TIME and t[i] > LONGEST_MINING_TIME then
					t[i] = LONGEST_MINING_TIME
				end
			end
		end
	end
	return toolcaps
end

function vlf_entity_effects.hf_update_internal(hand, object)
	-- TODO add a check for creative mode?
	local meta = hand:get_meta()
	local h_fac = vlf_entity_effects.get_total_haste(object)
	local f_fac = vlf_entity_effects.get_total_fatigue(object)
	-- Reset the capabilities of the hand to its default.
	meta:set_tool_capabilities ()
	local toolcaps = hand:get_tool_capabilities()
	meta:set_tool_capabilities(vlf_entity_effects.apply_haste_fatigue(toolcaps, h_fac, f_fac))
	return hand
end

local function haste_fatigue_hand_update(object)
	local inventory = object:get_inventory()
	if not inventory or inventory:get_size("hand") < 1 then return end
	local hand = inventory:get_stack("hand", 1)
	inventory:set_stack("hand", 1, vlf_entity_effects.hf_update_internal(hand, object))
end

vlf_entity_effects.register_effect({
	name = "haste",
	description = S("Haste"),
	get_tt = function(factor)
		return S("+@1% mining and attack speed", math.floor(factor*100))
	end,
	on_start = function (object, factor)
	    if object:is_player () then
		vlf_entity_effects.update_haste_and_fatigue (object, factor)
	    end
	end,
	after_end = function(object)
	    if object:is_player () then
		haste_fatigue_hand_update(object)
		vlf_entity_effects._reset_haste_fatigue_item_meta(object)
	    end
	end,
	particle_color = "#FFFF00",
	uses_factor = true,
	lvl1_factor = 0.2,
	lvl2_factor = 0.4,
	affects_item_speed = {factor_is_positive = true},
})

vlf_entity_effects.register_effect({
	name = "fatigue",
	description = S("Fatigue"),
	get_tt = function(factor)
		return S("-@1% mining and attack speed", math.floor((1-factor)*100))
	end,
	on_start = function (object, factor)
	    if object:is_player () then
		vlf_entity_effects.update_haste_and_fatigue (object, factor)
	    end
	end,
	after_end = function(object)
	    if object:is_player () then
		haste_fatigue_hand_update(object)
		vlf_entity_effects._reset_haste_fatigue_item_meta(object)
	    end
	end,
	particle_color = "#64643D",
	uses_factor = true,
	lvl1_factor = 0.3,
	lvl2_factor = 0.09,
	affects_item_speed = {},
})

vlf_entity_effects.register_effect({
	name = "conduit_power",
	description = S("Conduit Power"),
	get_tt = function(factor)
		return S("+@1% mining and attack speed in water").."\n"..S("limitless breathing under water", math.floor(factor*100))
	end,
	on_start = function (object, factor)
	    if object:is_player () then
		vlf_entity_effects.update_haste_and_fatigue (object, factor)
	    end
	end,
	on_step = function(dtime, object, factor, duration)
		if not object:is_player() then return end
		local node = minetest.get_node_or_nil(object:get_pos())
		if node and minetest.registered_nodes[node.name]
			and minetest.get_item_group(node.name, "liquid") ~= 0
			and minetest.get_item_group(node.name, "water") ~= 0 then
				EF.conduit_power[object].blocked = nil
				if object:get_breath() then
					hb.hide_hudbar(object, "breath")
					if object:get_breath() < 10 then object:set_breath(10) end
				end
				-- TODO implement improved underwater vision with this effect
		else
			EF.conduit_power[object].blocked = true
		end
	end,
	after_end = function(object)
	    haste_fatigue_hand_update(object)
	    vlf_entity_effects._reset_haste_fatigue_item_meta(object)
	end,
	particle_color = "#1FB1BA",
	uses_factor = true,
	lvl1_factor = 0.2,
	lvl2_factor = 0.4,
	affects_item_speed = {factor_is_positive = true},
})

-- implementation of haste and fatigue effects
function vlf_entity_effects.update_haste_and_fatigue(player)
    local h_fac = vlf_entity_effects.get_total_haste(player)
    local f_fac = vlf_entity_effects.get_total_fatigue(player)
    if vlf_gamemode.get_gamemode(player) == "creative" then return end
    local item = player:get_wielded_item()
    local meta = item:get_meta()
    local item_haste = meta:get_float("vlf_entity_effects:haste")
    local item_fatig = 1 - meta:get_float("vlf_entity_effects:fatigue")
    if item_haste ~= h_fac or item_fatig ~= f_fac then
	if h_fac ~= 0 then meta:set_float("vlf_entity_effects:haste", h_fac)
	else meta:set_string("vlf_entity_effects:haste", "") end
	if f_fac ~= 1 then meta:set_float("vlf_entity_effects:fatigue", 1 - f_fac)
	else meta:set_string("vlf_entity_effects:fatigue", "") end
	meta:set_tool_capabilities()
	vlf_enchanting.update_groupcaps(item, true)
	if h_fac == 0 and f_fac == 1 then
	    player:set_wielded_item(item)
	    return
	end
	local toolcaps = item:get_tool_capabilities()
	meta:set_tool_capabilities(vlf_entity_effects.apply_haste_fatigue(toolcaps, h_fac, f_fac))
	player:set_wielded_item(item)
    end
    haste_fatigue_hand_update(player, h_fac, f_fac)
end
minetest.register_on_punchnode(function(pos, node, puncher, pointed_thing)
	vlf_entity_effects.update_haste_and_fatigue(puncher)
end)
minetest.register_on_punchplayer(function(player, hitter)
	if not hitter:is_player() then return end -- TODO implement haste and fatigue support for mobs?
	vlf_entity_effects.update_haste_and_fatigue(hitter)
end)
-- update when hitting mob implemented in vlf_mobs/combat.lua



-- ██╗░░░██╗██████╗░██████╗░░█████╗░████████╗███████╗
-- ██║░░░██║██╔══██╗██╔══██╗██╔══██╗╚══██╔══╝██╔════╝
-- ██║░░░██║██████╔╝██║░░██║███████║░░░██║░░░█████╗░░
-- ██║░░░██║██╔═══╝░██║░░██║██╔══██║░░░██║░░░██╔══╝░░
-- ╚██████╔╝██║░░░░░██████╦╝██║░░██║░░░██║░░░███████╗
-- ░╚═════╝░╚═╝░░░░░╚═════╝░╚═╝░░╚═╝░░░╚═╝░░░╚══════╝
--
-- ██╗░░██╗██╗░░░██╗██████╗░
-- ██║░░██║██║░░░██║██╔══██╗
-- ███████║██║░░░██║██║░░██║
-- ██╔══██║██║░░░██║██║░░██║
-- ██║░░██║╚██████╔╝██████╦╝
-- ╚═╝░░╚═╝░╚═════╝░╚═════╝░

hb.register_hudbar("absorption", 0xFFFFFF, S("Absorption"), {bar = "[fill:2x16:#B59500", icon = "vlf_entity_effects_icon_absorb.png"}, 0, 0, false)

local hp_hudbar_modifiers = {}

-- API - registers a HP hudbar modifier
-- required parameters in def:
-- predicate - function(player) - returns true if player fulfills the requirements (eg. has the effects) for the hudbar look
-- icon - string - name of the icon to which the modifier should change the HP hudbar heart
-- priority - signed int - lower gets checked first, and first fulfilled predicate applies its modifier
function vlf_entity_effects.register_hp_hudbar_modifier(def)
	assert(type(def.predicate) == "function", "Predicate must be a function")
	assert(def.icon, "No icon provided")
	assert(def.priority, "No priority provided")
	table.insert(hp_hudbar_modifiers, {
		predicate = def.predicate,
		icon = def.icon,
		priority = def.priority,
	})
	table.sort(hp_hudbar_modifiers, function(a, b) return a.priority <= b.priority end)
end

vlf_entity_effects.register_hp_hudbar_modifier({
	predicate = function(player)
		if EF.withering[player] and EF.regeneration[player] then return true end
	end,
	icon = "vlf_entity_effects_icon_regen_wither.png",
	priority = -30,
})

vlf_entity_effects.register_hp_hudbar_modifier({
	predicate = function(player)
		if EF.withering[player] then return true end
	end,
	icon = "vlf_entity_effects_icon_wither.png",
	priority = -20,
})

vlf_entity_effects.register_hp_hudbar_modifier({
	predicate = function(player)
		if EF.poison[player] and EF.regeneration[player] then return true end
	end,
	icon = "hbhunger_icon_regen_poison.png",
	priority = -10,
})

vlf_entity_effects.register_hp_hudbar_modifier({
	predicate = function(player)
		if EF.poison[player] then return true end
	end,
	icon = "hbhunger_icon_health_poison.png",
	priority = 0,
})

vlf_entity_effects.register_hp_hudbar_modifier({
	predicate = function(player)
		if EF.regeneration[player] then return true end
	end,
	icon = "hudbars_icon_regenerate.png",
	priority = 10,
})

local function effects_set_hudbar(player)
	for _, mod in pairs(hp_hudbar_modifiers) do
		if mod.predicate(player) then
			hb.change_hudbar(player, "health", nil, nil, mod.icon, nil, "hudbars_bar_health.png")
			return
		end
	end
	hb.change_hudbar(player, "health", nil, nil, "hudbars_icon_health.png", nil, "hudbars_bar_health.png")
end

local enable_damage = minetest.settings:get_bool("enable_damage")

local icon_ids = {}

local function effects_init_icons(player)
	local name = player:get_player_name()
	icon_ids[name] = {}
	for e=1, EFFECT_TYPES do
		local x = -52 * e - 2
		local id = {}
		id.img = player:hud_add({
			[hud_elem_type_field] = "image",
			text = "blank.png",
			position = { x = 1, y = 0 },
			offset = { x = x, y = 3 },
			scale = { x = 0.375, y = 0.375 },
			alignment = { x = 1, y = 1 },
			z_index = 100,
		})
		id.label = player:hud_add({
			[hud_elem_type_field] = "text",
			text = "",
			position = { x = 1, y = 0 },
			offset = { x = x+22, y = 50 },
			scale = { x = 50, y = 15 },
			alignment = { x = 0, y = 1 },
			z_index = 100,
			style = 1,
			number = 0xFFFFFF,
		})
		id.timestamp = player:hud_add({
			[hud_elem_type_field] = "text",
			text = "",
			position = { x = 1, y = 0 },
			offset = { x = x+22, y = 65 },
			scale = { x = 50, y = 15 },
			alignment = { x = 0, y = 1 },
			z_index = 100,
			style = 1,
			number = 0xFFFFFF,
		})
		table.insert(icon_ids[name], id)
	end
	-- Health HUD bars should be concealed when damage is
	-- disabled.
	if enable_damage then
	    hb.init_hudbar (player, "absorption")
	end
end

local function effects_set_icons(player)
	local name = player:get_player_name()
	if not icon_ids[name] then
		return
	end
	local active_effects = {}
	for effect_name, effect in pairs(EF) do
		if effect[player] then
			active_effects[effect_name] = effect[player]
		end
	end

	local i = 1
	for effect_name, def in pairs(registered_effects) do
		local icon = icon_ids[name][i].img
		local label = icon_ids[name][i].label
		local timestamp = icon_ids[name][i].timestamp
		local vals = active_effects[effect_name]
		if vals then
			player:hud_change(icon, "text", def.icon .. "^[resize:128x128")
			if def.uses_factor then
				local level = def.factor_to_level(vals.factor)
				if level > 3000 or level == math.huge then level = "∞"
				elseif level < 0  then level = "???"
				elseif level == 0 then level = "0"
				else level = vlf_util.to_roman(level) end
				player:hud_change(label, "text", level)
			else
				player:hud_change(label, "text", "")
			end
			if vals.dur == math.huge then
				player:hud_change(timestamp, "text", "∞")
			else
				local dur = math.round(vals.dur-vals.timer)
				player:hud_change(timestamp, "text", math.floor(dur/60)..string.format(":%02d",math.floor(dur % 60)))
			end
			EF[effect_name][player].hud_index = i
			i = i + 1
		end
	end
	while i < EFFECT_TYPES do
		player:hud_change(icon_ids[name][i].img, "text", "blank.png")
		player:hud_change(icon_ids[name][i].label, "text", "")
		player:hud_change(icon_ids[name][i].timestamp, "text", "")
		i = i + 1
	end
end

local function effects_set_hud(player)
	effects_set_hudbar(player)
	effects_set_icons(player)
end


-- ███╗░░░███╗░█████╗░██╗███╗░░██╗  ███████╗███████╗███████╗███████╗░█████╗░████████╗
-- ████╗░████║██╔══██╗██║████╗░██║  ██╔════╝██╔════╝██╔════╝██╔════╝██╔══██╗╚══██╔══╝
-- ██╔████╔██║███████║██║██╔██╗██║  █████╗░░█████╗░░█████╗░░█████╗░░██║░░╚═╝░░░██║░░░
-- ██║╚██╔╝██║██╔══██║██║██║╚████║  ██╔══╝░░██╔══╝░░██╔══╝░░██╔══╝░░██║░░██╗░░░██║░░░
-- ██║░╚═╝░██║██║░░██║██║██║░╚███║  ███████╗██║░░░░░██║░░░░░███████╗╚█████╔╝░░░██║░░░
-- ╚═╝░░░░░╚═╝╚═╝░░╚═╝╚═╝╚═╝░░╚══╝  ╚══════╝╚═╝░░░░░╚═╝░░░░░╚══════╝░╚════╝░░░░╚═╝░░░
--
-- ░█████╗░██╗░░██╗███████╗░█████╗░██╗░░██╗███████╗██████╗░
-- ██╔══██╗██║░░██║██╔════╝██╔══██╗██║░██╔╝██╔════╝██╔══██╗
-- ██║░░╚═╝███████║█████╗░░██║░░╚═╝█████═╝░█████╗░░██████╔╝
-- ██║░░██╗██╔══██║██╔══╝░░██║░░██╗██╔═██╗░██╔══╝░░██╔══██╗
-- ╚█████╔╝██║░░██║███████╗╚█████╔╝██║░╚██╗███████╗██║░░██║
-- ░╚════╝░╚═╝░░╚═╝╚══════╝░╚════╝░╚═╝░░╚═╝╚══════╝╚═╝░░╚═╝

local function add_spawner(obj, color)
    local d = 0.2
    return minetest.add_particlespawner({
	    amount = 10.0,
	    time = 0,
	    attached = obj,
	    minpos = {x = -d, y = 1, z = -d},
	    maxpos = {x = d, y = 2, z = d},
	    minvel = {x = -0.1, y = 0, z = -0.1},
	    maxvel = {x = 0.1, y = 0.1, z = 0.1},
	    minacc = {x = -0.1, y = 0, z = -0.1},
	    maxacc = {x = 0.1, y = .1, z = 0.1},
	    minexptime = 0.5,
	    maxexptime = 1,
	    minsize = 0.5,
	    maxsize = 1,
	    collisiondetection = false,
	    vertical = false,
	    texture = "vlf_particles_effect.png^[colorize:"..color..":127",
    })
end

minetest.register_globalstep(function(dtime)
	for name, effect in pairs(registered_effects) do
	    for object, vals in pairs(EF[name]) do
		if vals.dur ~= math.huge then EF[name][object].timer = vals.timer + dtime end

		if not vals.no_particles and not vals.spawner then
		    vals.spawner
			= add_spawner (object, effect.particle_color)
		end

		if effect.on_step then effect.on_step(dtime, object, vals.factor, vals.dur) end
		if effect.on_hit_timer then
		    EF[name][object].hit_timer = (vals.hit_timer or 0) + dtime
		    if EF[name][object].hit_timer >= vals.step then
			effect.on_hit_timer(object, vals.factor, vals.dur)
			if EF[name][object] then
			    EF[name][object].hit_timer
				= EF[name][object].hit_timer - vals.step
			end
		    end
		end

		if not object or not EF[name][object] or EF[name][object].timer >= vals.dur or not object:get_pos() then
		    if vals.spawner then
			minetest.delete_particlespawner (vals.spawner)
		    end
		    if effect.on_end then effect.on_end(object) end
		    EF[name][object] = nil
		    if item_speed_effects[effect] then
			item_speed_effects[effect][object] = nil
		    end
		    if effect.after_end then effect.after_end(object) end
		    if object:is_player() then
			local meta = object:get_meta()
			meta:set_string("vlf_entity_effects:_EF_"..name, "")
			effects_set_hud(object)
		    else
			local ent = object:get_luaentity()
			if ent then
			    if not ent._vlf_entity_effects then
				ent._vlf_entity_effects = {}
			    end
			    ent._vlf_entity_effects["_EF_"..name] = nil
			end
		    end
		elseif object:is_player() then
		    if vals.dur == math.huge then
			object:hud_change(icon_ids[object:get_player_name()][vals.hud_index].timestamp,
					  "text", "∞")
		    else
			local dur = math.round(vals.dur-vals.timer)
			object:hud_change(icon_ids[object:get_player_name()][vals.hud_index].timestamp,
					  "text", math.floor(dur/60)..string.format(":%02d",math.floor(dur % 60)))
		    end
		else
		    local ent = object:get_luaentity()
		    if not ent._vlf_entity_effects then
			ent._vlf_entity_effects = {}
		    end
		    if ent then
			ent._vlf_entity_effects["_EF_"..name] = EF[name][object]
		    end
		end
	    end
	end
end)


-- ███████╗███████╗███████╗███████╗░█████╗░████████╗
-- ██╔════╝██╔════╝██╔════╝██╔════╝██╔══██╗╚══██╔══╝
-- █████╗░░█████╗░░█████╗░░█████╗░░██║░░╚═╝░░░██║░░░
-- ██╔══╝░░██╔══╝░░██╔══╝░░██╔══╝░░██║░░██╗░░░██║░░░
-- ███████╗██║░░░░░██║░░░░░███████╗╚█████╔╝░░░██║░░░
-- ╚══════╝╚═╝░░░░░╚═╝░░░░░╚══════╝░╚════╝░░░░╚═╝░░░
--
-- ██╗░░░░░░█████╗░░█████╗░██████╗░░░░░██╗░██████╗░█████╗░██╗░░░██╗███████╗
-- ██║░░░░░██╔══██╗██╔══██╗██╔══██╗░░░██╔╝██╔════╝██╔══██╗██║░░░██║██╔════╝
-- ██║░░░░░██║░░██║███████║██║░░██║░░██╔╝░╚█████╗░███████║╚██╗░██╔╝█████╗░░
-- ██║░░░░░██║░░██║██╔══██║██║░░██║░██╔╝░░░╚═══██╗██╔══██║░╚████╔╝░██╔══╝░░
-- ███████╗╚█████╔╝██║░░██║██████╔╝██╔╝░░░██████╔╝██║░░██║░░╚██╔╝░░███████╗
-- ╚══════╝░╚════╝░╚═╝░░╚═╝╚═════╝░╚═╝░░░░╚═════╝░╚═╝░░╚═╝░░░╚═╝░░░╚══════╝

function vlf_entity_effects._reset_haste_fatigue_item_meta(player)
	local inv = player:get_inventory()
	if not inv then return end
	local lists = inv:get_lists()
	for _, list in pairs(lists) do
		for _, item in pairs(list) do
			local meta = item:get_meta()
			meta:set_string("vlf_entity_effects:haste", "")
			meta:set_string("vlf_entity_effects:fatigue", "")
			meta:set_tool_capabilities()
			vlf_enchanting.update_groupcaps(item, true)
		end
	end
	inv:set_lists(lists)
end
vlf_gamemode.register_on_gamemode_change(vlf_entity_effects._reset_haste_fatigue_item_meta)

function vlf_entity_effects._clear_cached_effect_data(object)
	for name, effect in pairs(EF) do
		effect[object] = nil
	end
	if not object:is_player() then return end
	local meta = object:get_meta()
	meta:set_int("night_vision", 0)
end

function vlf_entity_effects._reset_effects(object, set_hud)
	local set_hud = set_hud
	if not object:is_player() then
		set_hud = false
	end

	local removed_effects = {}
	for name, effect in pairs(registered_effects) do
	    local val = EF[name][object]
	    if val and effect.on_end then
		effect.on_end (object)
	    end
	    if val and val.spawner then
		minetest.delete_particlespawner (val.spawner)
	    end
	    if effect.after_end then table.insert(removed_effects, effect.after_end) end
	end
	for name, tbl in pairs (item_speed_effects) do
	    tbl[object] = nil
	end

	vlf_entity_effects._clear_cached_effect_data(object)

	for i=1, #removed_effects do
		removed_effects[i](object)
	end

	if set_hud ~= false then
		effects_set_hud(object)
	end
end

function vlf_entity_effects._save_player_effects(player)
	if not player:is_player() then
		return
	end
	local meta = player:get_meta()

	for name, effect in pairs(registered_effects) do
	    if EF[name][player] then
		EF[name][player].spawner = nil
		if effect.on_save_effect then
		    effect.on_save_effect(player)
		end
	    end
	    meta:set_string("vlf_entity_effects:_EF_"..name, minetest.serialize(EF[name][player]))
	end
end

function vlf_entity_effects._load_player_effects(player)
	if not player:is_player() then
		return
	end
	local meta = player:get_meta()

	-- handle legacy meta strings
	local legacy_invisible = minetest.deserialize(meta:get_string("_is_invisible"))
	local legacy_poisoned = minetest.deserialize(meta:get_string("_is_poisoned"))
	local legacy_regenerating = minetest.deserialize(meta:get_string("_is_regenerating"))
	local legacy_strong = minetest.deserialize(meta:get_string("_is_strong"))
	local legacy_weak = minetest.deserialize(meta:get_string("_is_weak"))
	local legacy_water_breathing = minetest.deserialize(meta:get_string("_is_water_breathing"))
	local legacy_leaping = minetest.deserialize(meta:get_string("_is_leaping"))
	local legacy_swift = minetest.deserialize(meta:get_string("_is_swift"))
	local legacy_night_vision = minetest.deserialize(meta:get_string("_is_cat"))
	local legacy_fireproof = minetest.deserialize(meta:get_string("_is_fire_proof"))
	local legacy_bad_omen = minetest.deserialize(meta:get_string("_has_bad_omen"))
	local legacy_withering = minetest.deserialize(meta:get_string("_is_withering"))
	if legacy_invisible then
		EF.invisibility[player] = legacy_invisible
		meta:set_string("_is_invisible", "")
	end
	if legacy_poisoned then
		EF.poison[player] = legacy_poisoned
		meta:set_string("_is_poisoned", "")
	end
	if legacy_regenerating then
		EF.regeneration[player] = legacy_regenerating
		meta:set_string("_is_regenerating", "")
	end
	if legacy_strong then
		EF.strength[player] = legacy_strong
		meta:set_string("_is_strong", "")
	end
	if legacy_weak then
		EF.weakness[player] = legacy_weak
		meta:set_string("_is_weak", "")
	end
	if legacy_water_breathing then
		EF.water_breathing[player] = legacy_water_breathing
		meta:set_string("_is_water_breating", "")
	end
	if legacy_leaping then
		EF.leaping[player] = legacy_leaping
		meta:set_string("_is_leaping", "")
	end
	if legacy_swift then
		EF.swiftness[player] = legacy_swift
		meta:set_string("_is_swift", "")
	end
	if legacy_night_vision then
		EF.night_vision[player] = legacy_night_vision
		meta:set_string("_is_cat", "")
	end
	if legacy_fireproof then
		EF.fire_resistance[player] = legacy_fireproof
		meta:set_string("_is_fire_proof", "")
	end
	if legacy_bad_omen then
		EF.bad_omen[player] = legacy_bad_omen
		meta:set_string("_has_bad_omen", "")
	end
	if legacy_withering then
		EF.withering[player] = legacy_withering
		meta:set_string("_is_withering", "")
	end

	-- new API effects + on_load for loaded legacy effects
	for name, effect in pairs(registered_effects) do
		local loaded = minetest.deserialize(meta:get_string("vlf_entity_effects:_EF_"..name))
		if loaded then
			EF[name][player] = loaded
		end
		if EF[name][player] then -- this is needed because of legacy effects loaded separately
			if effect.uses_factor and type(EF[name][player].factor) ~= "number" then
				EF[name][player].factor = effect.level_to_factor(1)
			end
			if effect.on_load then
				effect.on_load(player, EF[name][player].factor)
			end
		end
	end
end

function vlf_entity_effects._load_entity_effects(entity)
	if not entity or not entity._vlf_entity_effects or entity._vlf_entity_effects == {} then
		return
	end
	local object = entity.object
	if not object or not object:get_pos() then return end
	for name, effect in pairs(registered_effects) do
		local loaded = entity._vlf_entity_effects["_EF_"..name]
		if loaded then
			EF[name][object] = loaded
			if effect.uses_factor and not loaded.factor then
				EF[name][object].factor = effect.level_to_factor(1)
			end
			if effect.on_load then
				effect.on_load(object, EF[name][object].factor)
			end
		end
	end
end

-- Returns true if object has given effect
function vlf_entity_effects.has_effect(object, effect_name)
	if not EF[effect_name] then
		return false
	end
	return EF[effect_name][object] ~= nil
end

function vlf_entity_effects.get_effect(object, effect_name)
	if not EF[effect_name] or not EF[effect_name][object] then
		return false
	end
	return EF[effect_name][object]
end

function vlf_entity_effects.get_effect_level(object, effect_name)
	if not EF[effect_name] then return end
	local effect = EF[effect_name][object]
	if not effect then return 0 end
	if not registered_effects[effect_name].uses_factor then return 1 end
	return registered_effects[effect_name].factor_to_level(effect.factor)
end

function vlf_entity_effects.get_total_haste(object)
	local accum_factor = 1
	for name, def in pairs(item_speed_effects) do
		if EF[name][object] and not EF[name][object].blocked then
			local factor = EF[name][object].factor
			if def.factor_is_positive then factor = factor + 1 end
			if factor > 1 then accum_factor = accum_factor * factor end
		end
	end
	return accum_factor - 1
end

function vlf_entity_effects.get_total_fatigue(object)
	local accum_factor = 1
	for name, def in pairs(item_speed_effects) do
		if EF[name][object] and not EF[name][object].blocked then
			local factor = EF[name][object].factor
			if def.factor_is_positive then factor = factor + 1 end
			if factor <= 0 then return 0 end
			if factor < 1 then accum_factor = accum_factor * factor end
		end
	end
	return accum_factor
end

function vlf_entity_effects.clear_effect(object, effectname)
	if not EF[effectname] then
		minetest.log("warning", "[vlf_entity_effects] Tried to remove an effect that is not registered: " .. dump(effectname))
		return false
	end
	local def = registered_effects[effectname]
	local effect = EF[effectname][object]
	if effect then
		if def.on_end then def.on_end(object) end
		if effect.spawner then
		    minetest.delete_particlespawner (effect.spawner)
		end
		EF[effectname][object] = nil
		if def.after_end then def.after_end(object) end
	end
	if item_speed_effects[effectname] then
	    item_speed_effects[effectname][object] = nil
	end
	if not object:is_player() then return end
	effects_set_hud(object)
end

minetest.register_on_leaveplayer( function(player)
	vlf_entity_effects._save_player_effects(player)
	vlf_entity_effects._clear_cached_effect_data(player) -- clear the buffer to prevent looking for a player not there
	icon_ids[player:get_player_name()] = nil
end)

minetest.register_on_dieplayer( function(player)
	vlf_entity_effects._reset_effects(player)
	effects_set_hud(player)
end)

minetest.register_on_joinplayer( function(player)
	vlf_entity_effects._reset_effects(player, false) -- make sure there are no weird holdover effects
	vlf_entity_effects._load_player_effects(player)
	vlf_entity_effects._reset_haste_fatigue_item_meta(player)
	effects_init_icons(player)
	effects_set_hud(player)
end)

minetest.register_on_shutdown(function()
	-- save player effects on server shutdown
	for _,player in pairs(minetest.get_connected_players()) do
		vlf_entity_effects._save_player_effects(player)
	end
end)

-- ░██████╗██╗░░░██╗██████╗░██████╗░░█████╗░██████╗░████████╗██╗███╗░░██╗░██████╗░
-- ██╔════╝██║░░░██║██╔══██╗██╔══██╗██╔══██╗██╔══██╗╚══██╔══╝██║████╗░██║██╔════╝░
-- ╚█████╗░██║░░░██║██████╔╝██████╔╝██║░░██║██████╔╝░░░██║░░░██║██╔██╗██║██║░░██╗░
-- ░╚═══██╗██║░░░██║██╔═══╝░██╔═══╝░██║░░██║██╔══██╗░░░██║░░░██║██║╚████║██║░░╚██╗
-- ██████╔╝╚██████╔╝██║░░░░░██║░░░░░╚█████╔╝██║░░██║░░░██║░░░██║██║░╚███║╚██████╔╝
-- ╚═════╝░░╚═════╝░╚═╝░░░░░╚═╝░░░░░░╚════╝░╚═╝░░╚═╝░░░╚═╝░░░╚═╝╚═╝░░╚══╝░╚═════╝░
--
-- ███████╗██╗░░░██╗███╗░░██╗░█████╗░████████╗██╗░█████╗░███╗░░██╗░██████╗
-- ██╔════╝██║░░░██║████╗░██║██╔══██╗╚══██╔══╝██║██╔══██╗████╗░██║██╔════╝
-- █████╗░░██║░░░██║██╔██╗██║██║░░╚═╝░░░██║░░░██║██║░░██║██╔██╗██║╚█████╗░
-- ██╔══╝░░██║░░░██║██║╚████║██║░░██╗░░░██║░░░██║██║░░██║██║╚████║░╚═══██╗
-- ██║░░░░░╚██████╔╝██║░╚███║╚█████╔╝░░░██║░░░██║╚█████╔╝██║░╚███║██████╔╝
-- ╚═╝░░░░░░╚═════╝░╚═╝░░╚══╝░╚════╝░░░░╚═╝░░░╚═╝░╚════╝░╚═╝░░╚══╝╚═════╝░

function vlf_entity_effects.detect_hit (obj, pos, moveresult, velocity)
    local val
    local entity = obj:get_luaentity ()
    local in_thrower_body = entity and not entity._exited_thrower
    for _, item in ipairs (moveresult.collisions) do
	if item.type == "node" then
	    -- Detect targets.
	    local node = minetest.get_node (item.node_pos)
	    if node and node.name == "vlf_target:target_off" then
		val = { target = item.node_pos, }
	    elseif node then
		-- Next, detect walkable nodes.
		local def = minetest.registered_nodes[node.name]
		if def.walkable then
		    val = val or {}
		end
	    end
	end
    end
    -- Mobs and objects are currently non-colliding, so supplement the
    -- move results with a raycast as in vlf_bows.
    if not val or in_thrower_body then
	local raycast = minetest.raycast (pos, vector.add (pos, velocity * 0.1),
					  true, false)
	local still_inside = false
	local thrower = entity._thrower

	-- If the thrower should be a string, try to look up the
	-- player by that name.
	if type (thrower) == "string" then
	    thrower = minetest.get_player_by_name (thrower)
	end

	for hitpoint in raycast do
	    if hitpoint.type == "object" and hitpoint.ref ~= obj then
		if hitpoint.ref:is_player ()
		    or (hitpoint.ref:get_luaentity ()
			and hitpoint.ref:get_luaentity ().is_mob) then
		    -- Don't return the thrower if the effect was
		    -- launched from within it and has not yet
		    -- exited.
		    if in_thrower_body and hitpoint.ref == thrower then
			still_inside = true
		    else
			val = {}
		    end
		end
	    else
		break
	    end
	end

	if entity then
	    entity._exited_thrower = not still_inside
	end
    end
    return val
end


function vlf_entity_effects.make_invisible(obj_ref, hide)
	if obj_ref:is_player() then
		if hide then
			vlf_player.player_set_visibility(obj_ref, false)
			obj_ref:set_nametag_attributes({ color = { a = 0 } })
		else
			vlf_player.player_set_visibility(obj_ref, true)
			obj_ref:set_nametag_attributes({ color = { r = 255, g = 255, b = 255, a = 255 } })
		end
	else -- TODO make below section (and preferably other effects on mobs) rely on metadata
		if hide then
			local luaentity = obj_ref:get_luaentity()
			EF.invisibility[obj_ref].old_size = luaentity.visual_size
			obj_ref:set_properties({ visual_size = { x = 0, y = 0 } })
		else
			obj_ref:set_properties({ visual_size = EF.invisibility[obj_ref].old_size })
		end
	end
end


function vlf_entity_effects._use_effect(obj, color)
	local d = 0.1
	local pos = obj:get_pos()
	minetest.sound_play("vlf_entity_effects_drinking", {pos = pos, max_hear_distance = 6, gain = 1})
	minetest.add_particlespawner({
		amount = 25,
		time = 1,
		minpos = {x=pos.x-d, y=pos.y+1, z=pos.z-d},
		maxpos = {x=pos.x+d, y=pos.y+2, z=pos.z+d},
		minvel = {x=-0.1, y=0, z=-0.1},
		maxvel = {x=0.1, y=0.1, z=0.1},
		minacc = {x=-0.1, y=0, z=-0.1},
		maxacc = {x=0.1, y=.1, z=0.1},
		minexptime = 1,
		maxexptime = 5,
		minsize = 0.5,
		maxsize = 1,
		collisiondetection = true,
		vertical = false,
		texture = "vlf_particles_effect.png^[colorize:"..color..":127",
	})
end


-- ██████╗░░█████╗░░██████╗███████╗  ██████╗░░█████╗░████████╗██╗░█████╗░███╗░░██╗
-- ██╔══██╗██╔══██╗██╔════╝██╔════╝  ██╔══██╗██╔══██╗╚══██╔══╝██║██╔══██╗████╗░██║
-- ██████╦╝███████║╚█████╗░█████╗░░  ██████╔╝██║░░██║░░░██║░░░██║██║░░██║██╔██╗██║
-- ██╔══██╗██╔══██║░╚═══██╗██╔══╝░░  ██╔═══╝░██║░░██║░░░██║░░░██║██║░░██║██║╚████║
-- ██████╦╝██║░░██║██████╔╝███████╗  ██║░░░░░╚█████╔╝░░░██║░░░██║╚█████╔╝██║░╚███║
-- ╚═════╝░╚═╝░░╚═╝╚═════╝░╚══════╝  ╚═╝░░░░░░╚════╝░░░░╚═╝░░░╚═╝░╚════╝░╚═╝░░╚══╝
--
-- ███████╗███████╗███████╗███████╗░█████╗░████████╗
-- ██╔════╝██╔════╝██╔════╝██╔════╝██╔══██╗╚══██╔══╝
-- █████╗░░█████╗░░█████╗░░█████╗░░██║░░╚═╝░░░██║░░░
-- ██╔══╝░░██╔══╝░░██╔══╝░░██╔══╝░░██║░░██╗░░░██║░░░
-- ███████╗██║░░░░░██║░░░░░███████╗╚█████╔╝░░░██║░░░
-- ╚══════╝╚═╝░░░░░╚═╝░░░░░╚══════╝░╚════╝░░░░╚═╝░░░
--
-- ███████╗██╗░░░██╗███╗░░██╗░█████╗░████████╗██╗░█████╗░███╗░░██╗░██████╗
-- ██╔════╝██║░░░██║████╗░██║██╔══██╗╚══██╔══╝██║██╔══██╗████╗░██║██╔════╝
-- █████╗░░██║░░░██║██╔██╗██║██║░░╚═╝░░░██║░░░██║██║░░██║██╔██╗██║╚█████╗░
-- ██╔══╝░░██║░░░██║██║╚████║██║░░██╗░░░██║░░░██║██║░░██║██║╚████║░╚═══██╗
-- ██║░░░░░╚██████╔╝██║░╚███║╚█████╔╝░░░██║░░░██║╚█████╔╝██║░╚███║██████╔╝
-- ╚═╝░░░░░░╚═════╝░╚═╝░░╚══╝░╚════╝░░░░╚═╝░░░╚═╝░╚════╝░╚═╝░░╚══╝╚═════╝░

local registered_res_predicates = {}
-- API
-- This is supposed to add custom resistance functions independent of effects
-- E.g. some entity could be resistant to all (or some) effects under specific conditions
-- predicate - function(object, effect_name) - return true if resists effect
function vlf_entity_effects.register_generic_resistance_predicate(predicate)
	assert(type(predicate) == "function", "Attempted to register non-function as a predicate")
	table.insert(registered_res_predicates, predicate)
end

function vlf_entity_effects.level_from_details (details, potency)
    if details.uses_level then
	return details.level + details.level_scaling * potency
    end
    return details.level
end

function vlf_entity_effects.duration_from_details (details, potency, plus, attenuation)
    local dur

    if details.dur_variable then
	dur = (details.dur * math.pow (vlf_entity_effects.PLUS_FACTOR, plus)
	       / (potency > 0 and details.uses_level and
		  math.pow (details.potent_factor
			    or vlf_entity_effects.POTENT_FACTOR, potency)
		  or 1)
	       * attenuation)
    else
	dur = details.dur
    end
    return dur
end

local function target_valid(object, name)
	if not object or object:get_hp() <= 0 then return false end

	local entity = object:get_luaentity()
	if entity and entity.is_boss then return false end

	for i=1, #registered_res_predicates do
		if registered_res_predicates[i](object, name) then return false end
	end

	if not (registered_effects[name].res_condition
		and registered_effects[name].res_condition(object)) then return true end
end

function vlf_entity_effects.give_effect(name, object, factor, duration, no_particles)
	if not target_valid(object, name) then return false end
	local edef = registered_effects[name]
	if not edef then return false end
	if not EF[name][object] then
		local vals = {dur = duration, timer = 0, no_particles = no_particles}
		if edef.uses_factor then vals.factor = factor end
		if edef.on_hit_timer then
			if edef.timer_uses_factor then vals.step = factor
			else vals.step = edef.hit_timer_step end
		end
		if duration == "INF" then
			vals.dur = math.huge
		end
		EF[name][object] = vals
		if edef.on_start then edef.on_start(object, factor) end
	else
		local present = EF[name][object]
		present.no_particles = no_particles
		if not edef.uses_factor or (edef.uses_factor and
			(not edef.inv_factor and factor >= present.factor
			 or edef.inv_factor and factor <= present.factor)) then
				present.dur = math.max(duration, present.dur - present.timer)
				present.timer = 0
				if edef.uses_factor then
					present.factor = factor
					if edef.timer_uses_factor then present.step = factor end
					if edef.on_start then edef.on_start(object, factor) end
				end
				if duration == "INF" then
					present.dur = math.huge
				end
		else
		    -- on_reject must be called at all events if it
		    -- exists, as it will attempt to restore the
		    -- benefits afforded by `factor' if those afforded
		    -- by `object' have already been spent.  This is
		    -- solely applicable to Absorption AFAICT.
		    if edef.on_reject then
			return edef.on_reject (object, factor)
		    end
		    return false
		end
	end

	if object:is_player() then effects_set_hud(object) end
	return true
end

function vlf_entity_effects.give_effect_by_level(name, object, level, duration, no_particles)
	if level == 0 then return false end
	if not registered_effects[name].uses_factor then
		return vlf_entity_effects.give_effect(name, object, 0, duration, no_particles)
	end
	local factor = registered_effects[name].level_to_factor(level)
	return vlf_entity_effects.give_effect(name, object, factor, duration, no_particles)
end

function vlf_entity_effects.all_effects (object)
    local val = {}

    for name, _ in pairs (registered_effects) do
	if EF[name][object] then
	    val[name] = EF[name][object]
	end
    end

    return val
end

function vlf_entity_effects.healing_func(object, hp)
	if not object or object:get_hp() <= 0 then return false end
	local ent = object:get_luaentity()

	if ent and ent.harmed_by_heal then hp = -hp end

	if hp > 0 then
		-- at least 1 HP
		if hp < 1 then
			hp = 1
		end

		local hp_max = object:get_properties ().hp_max
		if ent and ent.is_mob then
		    ent.health = math.min (ent.health + hp, hp_max)
		elseif object:is_player() then
		    object:set_hp(math.min(object:get_hp() + hp, hp_max),
				  { type = "set_hp", other = "healing" })
		end

	elseif hp < 0 then
		if hp > -1 then
			hp = -1
		end

		vlf_util.deal_damage(object, -hp, {type = "magic"})
	end
end

function vlf_entity_effects.strength_func(object, factor, duration)
	return vlf_entity_effects.give_effect("strength", object, factor, duration)
end
function vlf_entity_effects.leaping_func(object, factor, duration)
	return vlf_entity_effects.give_effect("leaping", object, factor, duration)
end
function vlf_entity_effects.weakness_func(object, factor, duration)
	return vlf_entity_effects.give_effect("weakness", object, factor, duration)
end
function vlf_entity_effects.swiftness_func(object, factor, duration)
	return vlf_entity_effects.give_effect("swiftness", object, factor, duration)
end
function vlf_entity_effects.slowness_func(object, factor, duration)
	return vlf_entity_effects.give_effect("slowness", object, factor, duration)
end

function vlf_entity_effects.withering_func(object, factor, duration)
	return vlf_entity_effects.give_effect("withering", object, factor, duration)
end


function vlf_entity_effects.poison_func(object, factor, duration)
	return vlf_entity_effects.give_effect("poison", object, factor, duration)
end

function vlf_entity_effects.regeneration_func(object, factor, duration)
	return vlf_entity_effects.give_effect("regeneration", object, factor, duration)
end

function vlf_entity_effects.invisiblility_func(object, null, duration)
	return vlf_entity_effects.give_effect("invisibility", object, null, duration)
end

function vlf_entity_effects.water_breathing_func(object, null, duration)
	return vlf_entity_effects.give_effect("water_breathing", object, null, duration)
end

function vlf_entity_effects.fire_resistance_func(object, null, duration)
	return vlf_entity_effects.give_effect("fire_resistance", object, null, duration)
end

function vlf_entity_effects.night_vision_func(object, null, duration)
	return vlf_entity_effects.give_effect("night_vision", object, null, duration)
end

function vlf_entity_effects._water_effect(pos, radius)
	local epos = {x=pos.x, y=pos.y+0.5, z=pos.z}
	local dnode = minetest.get_node({x=pos.x,y=pos.y-0.5,z=pos.z})
	if minetest.get_item_group(dnode.name, "fire") ~= 0 or minetest.get_item_group(dnode.name, "lit_campfire") ~= 0 then
		epos.y = pos.y - 0.5
	end
	local exting = false
	-- No radius: Splash, extinguish epos and 4 nodes around
	if not radius then
		local dirs = {
			{x=0,y=0,z=0},
			{x=0,y=0,z=-1},
			{x=0,y=0,z=1},
			{x=-1,y=0,z=0},
			{x=1,y=0,z=0},
		}
		for d=1, #dirs do
			local tpos = vector.add(epos, dirs[d])
			local node = minetest.get_node(tpos)
			if minetest.get_item_group(node.name, "fire") ~= 0 then
				minetest.sound_play("fire_extinguish_flame", {pos = tpos, gain = 0.25, max_hear_distance = 16}, true)
				minetest.remove_node(tpos)
				exting = true
			elseif minetest.get_item_group(node.name, "lit_campfire") ~= 0 then
				minetest.sound_play("fire_extinguish_flame", {pos = tpos, gain = 0.25, max_hear_distance = 16}, true)
				local def = minetest.registered_nodes[node.name]
				minetest.set_node(tpos, {name = def._vlf_campfires_smothered_form, param2 = node.param2})
				exting = true
			end
		end
	-- Has radius: lingering, extinguish all nodes in area
	else
		local nodes = minetest.find_nodes_in_area(
			{x=epos.x-radius,y=epos.y,z=epos.z-radius},
			{x=epos.x+radius,y=epos.y,z=epos.z+radius},
			{"group:fire", "group:lit_campfire"})
		for n=1, #nodes do
			local node = minetest.get_node(nodes[n])
			minetest.sound_play("fire_extinguish_flame", {pos = nodes[n], gain = 0.25, max_hear_distance = 16}, true)
			if minetest.get_item_group(node.name, "fire") ~= 0 then
				minetest.remove_node(nodes[n])
			elseif minetest.get_item_group(node.name, "lit_campfire") ~= 0 then
				local def = minetest.registered_nodes[node.name]
				minetest.set_node(nodes[n], {name = def._vlf_campfires_smothered_form, param2 = node.param2})
			end
			exting = true
		end
	end
	-- Search for entities in the vicinity that are on fire and
	-- extinguish them.  Damage those entities which are
	-- vulnerable to water.  Clear suffocation counters of
	-- Axolotls.
	local aa = vector.subtract (pos, { x = radius / 2, y = 1, z = radius / 2, })
	local bb = vector.add (pos, { x = radius / 2, y = 1, z = radius / 2, })
	for obj in minetest.objects_in_area (aa, bb) do
	    local entity = obj:get_luaentity (obj)

	    if vlf_burning.is_burning (obj) then
		vlf_burning.extinguish (obj)
		exting = true
	    end

	    if entity and entity.is_mob then
		if entity.water_damage > 0 then
		    obj:punch (obj, 1.0, { full_punch_interval = 1.0,
					   damage_groups = {water_vulnerable=1}, },
			       nil)
		    exting = true
		elseif entity.name == "mobs_mc:axolotl" then
		    entity:reset_breath ()
		    exting = true
		end
	    end
	end
	return exting
end

function vlf_entity_effects.bad_omen_func(object, factor, duration)
	vlf_entity_effects.give_effect("bad_omen", object, factor, duration)
end
