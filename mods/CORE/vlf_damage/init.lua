vlf_damage = {
	modifiers = {},
	damage_callbacks = {},
	death_callbacks = {},
	types = {
		in_fire = {is_fire = true},
		lightning_bolt = {is_lightning = true},
		on_fire = {is_fire = true, bypasses_armor = true},
		lava = {is_fire = true},
		hot_floor = {is_fire = true},
		in_wall = {bypasses_armor = true},
		drown = {bypasses_armor = true},
		starve = {bypasses_armor = true, bypasses_magic = true},
		cactus = {},
		sweet_berry = {},
		fall = {bypasses_armor = true},
		fly_into_wall = {bypasses_armor = true}, -- unused
		out_of_world = {bypasses_armor = true, bypasses_magic = true, bypasses_invulnerability = true, bypasses_totem = true},
		generic = {bypasses_armor = true},
		magic = {is_magic = true, bypasses_armor = true},
		dragon_breath = {is_magic = true, bypasses_armor = true},	-- this is only used for dragon fireball; dragon fireball does not actually deal impact damage tho, so this is unreachable
		wither = {bypasses_armor = true}, -- unused
		wither_skull = {is_magic = true, is_explosion = true}, -- this is non-MC but a workaround to get the proper death message
		anvil = {},
		falling_node = {},	-- this is falling_block in MC
		mob = {},
		player = {},
		arrow = {is_projectile = true},
		fireball = {is_projectile = true, is_fire = true},
		thorns = {is_magic = true},
		explosion = {is_explosion = true},
		cramming = {bypasses_armor = true}, -- unused
		fireworks = {is_explosion = true}, -- unused
		environment = {},
		light = {},
	}
}

local damage_enabled = minetest.settings:get_bool("enabled_damage",true)

function vlf_damage.register_modifier(func, priority)
	table.insert(vlf_damage.modifiers, {func = func, priority = priority or 0})
end

function vlf_damage.register_on_damage(func)
	table.insert(vlf_damage.damage_callbacks, func)
end

function vlf_damage.register_on_death(func)
	table.insert(vlf_damage.death_callbacks, func)
end

function vlf_damage.run_modifiers(obj, damage, reason)
	for _, modf in ipairs(vlf_damage.modifiers) do
		damage = modf.func(obj, damage, reason) or damage
		if damage == 0 then
			return 0
		end
	end

	return damage
end

local function run_callbacks(funcs, ...)
	for _, func in pairs(funcs) do
		func(...)
	end
end

function vlf_damage.run_damage_callbacks(obj, damage, reason)
	run_callbacks(vlf_damage.damage_callbacks, obj, damage, reason)
end

function vlf_damage.run_death_callbacks(obj, reason)
	run_callbacks(vlf_damage.death_callbacks, obj, reason)
end

function vlf_damage.from_punch(vlf_reason, object)
	vlf_reason.direct = object
	local luaentity = vlf_reason.direct:get_luaentity()
	if luaentity then
		if luaentity._is_arrow then
			vlf_reason.type = "arrow"
		elseif luaentity._is_fireball then
			vlf_reason.type = "fireball"
		elseif luaentity.is_mob then
			vlf_reason.type = "mob"
		end
		vlf_reason.source = vlf_reason.source or luaentity._source_object
	else
		vlf_reason.type = "player"
	end
end

function vlf_damage.finish_reason(vlf_reason)
	vlf_reason.source = vlf_reason.source or vlf_reason.direct
	vlf_reason.flags = vlf_damage.types[vlf_reason.type] or {}
end

function vlf_damage.from_mt(mt_reason)
	if mt_reason._vlf_cached_reason then
		return mt_reason._vlf_cached_reason
	end

	local vlf_reason

	if mt_reason._vlf_reason then
		vlf_reason = mt_reason._vlf_reason
	else
		vlf_reason = {type = "generic"}

		if mt_reason._vlf_type then
			vlf_reason.type = mt_reason._vlf_type
		elseif mt_reason.type == "fall" then
			vlf_reason.type = "fall"
		elseif mt_reason.type == "drown" then
			vlf_reason.type = "drown"
		elseif mt_reason.type == "punch" then
			vlf_damage.from_punch(vlf_reason, mt_reason.object)
		elseif mt_reason.type == "node_damage" and mt_reason.node then
			if minetest.get_item_group(mt_reason.node, "fire") > 0 then
				vlf_reason.type = "in_fire"
			end
			if minetest.get_item_group(mt_reason.node, "lava") > 0 then
				vlf_reason.type = "lava"
			end
		end

		for key, value in pairs(mt_reason) do
			if key:find("_vlf_") == 1 then
				vlf_reason[key:sub(6, #key)] = value
			end
		end
	end

	vlf_damage.finish_reason(vlf_reason)
	mt_reason._vlf_cached_reason = vlf_reason

	return vlf_reason
end

function vlf_damage.register_type(name, def)
	vlf_damage.types[name] = def
end

minetest.register_on_player_hpchange(function(player, hp_change, mt_reason)
	if not damage_enabled then return 0 end
	if hp_change < 0 then
		if player:get_hp() <= 0 then
			return 0
		end
		hp_change = -vlf_damage.run_modifiers(player, -hp_change, vlf_damage.from_mt(mt_reason))
	end
	return hp_change
end, true)

minetest.register_on_player_hpchange(function(player, hp_change, mt_reason)
	if not damage_enabled then return 0 end
	if player:get_hp() > 0 then
		mt_reason.approved = true
		if hp_change < 0 then
			vlf_damage.run_damage_callbacks(player, -hp_change, vlf_damage.from_mt(mt_reason))
		end
	end
end, false)

minetest.register_on_dieplayer(function(player, mt_reason)
	vlf_damage.run_death_callbacks(player, vlf_damage.from_mt(mt_reason))
end)

minetest.register_on_mods_loaded(function()
	table.sort(vlf_damage.modifiers, function(a, b) return a.priority < b.priority end)
end)
