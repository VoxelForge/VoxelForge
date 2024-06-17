vlc_damage = {
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

function vlc_damage.register_modifier(func, priority)
	table.insert(vlc_damage.modifiers, {func = func, priority = priority or 0})
end

function vlc_damage.register_on_damage(func)
	table.insert(vlc_damage.damage_callbacks, func)
end

function vlc_damage.register_on_death(func)
	table.insert(vlc_damage.death_callbacks, func)
end

function vlc_damage.run_modifiers(obj, damage, reason)
	for _, modf in ipairs(vlc_damage.modifiers) do
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

function vlc_damage.run_damage_callbacks(obj, damage, reason)
	run_callbacks(vlc_damage.damage_callbacks, obj, damage, reason)
end

function vlc_damage.run_death_callbacks(obj, reason)
	run_callbacks(vlc_damage.death_callbacks, obj, reason)
end

function vlc_damage.from_punch(vlc_reason, object)
	vlc_reason.direct = object
	local luaentity = vlc_reason.direct:get_luaentity()
	if luaentity then
		if luaentity._is_arrow then
			vlc_reason.type = "arrow"
		elseif luaentity._is_fireball then
			vlc_reason.type = "fireball"
		elseif luaentity.is_mob then
			vlc_reason.type = "mob"
		end
		vlc_reason.source = vlc_reason.source or luaentity._source_object
	else
		vlc_reason.type = "player"
	end
end

function vlc_damage.finish_reason(vlc_reason)
	vlc_reason.source = vlc_reason.source or vlc_reason.direct
	vlc_reason.flags = vlc_damage.types[vlc_reason.type] or {}
end

function vlc_damage.from_mt(mt_reason)
	if mt_reason._vlc_cached_reason then
		return mt_reason._vlc_cached_reason
	end

	local vlc_reason

	if mt_reason._vlc_reason then
		vlc_reason = mt_reason._vlc_reason
	else
		vlc_reason = {type = "generic"}

		if mt_reason._vlc_type then
			vlc_reason.type = mt_reason._vlc_type
		elseif mt_reason.type == "fall" then
			vlc_reason.type = "fall"
		elseif mt_reason.type == "drown" then
			vlc_reason.type = "drown"
		elseif mt_reason.type == "punch" then
			vlc_damage.from_punch(vlc_reason, mt_reason.object)
		elseif mt_reason.type == "node_damage" and mt_reason.node then
			if minetest.get_item_group(mt_reason.node, "fire") > 0 then
				vlc_reason.type = "in_fire"
			end
			if minetest.get_item_group(mt_reason.node, "lava") > 0 then
				vlc_reason.type = "lava"
			end
		end

		for key, value in pairs(mt_reason) do
			if key:find("_vlc_") == 1 then
				vlc_reason[key:sub(6, #key)] = value
			end
		end
	end

	vlc_damage.finish_reason(vlc_reason)
	mt_reason._vlc_cached_reason = vlc_reason

	return vlc_reason
end

function vlc_damage.register_type(name, def)
	vlc_damage.types[name] = def
end

minetest.register_on_player_hpchange(function(player, hp_change, mt_reason)
	if not damage_enabled then return 0 end
	if hp_change < 0 then
		if player:get_hp() <= 0 then
			return 0
		end
		hp_change = -vlc_damage.run_modifiers(player, -hp_change, vlc_damage.from_mt(mt_reason))
	end
	return hp_change
end, true)

minetest.register_on_player_hpchange(function(player, hp_change, mt_reason)
	if not damage_enabled then return 0 end
	if player:get_hp() > 0 then
		mt_reason.approved = true
		if hp_change < 0 then
			vlc_damage.run_damage_callbacks(player, -hp_change, vlc_damage.from_mt(mt_reason))
		end
	end
end, false)

minetest.register_on_dieplayer(function(player, mt_reason)
	vlc_damage.run_death_callbacks(player, vlc_damage.from_mt(mt_reason))
end)

minetest.register_on_mods_loaded(function()
	table.sort(vlc_damage.modifiers, function(a, b) return a.priority < b.priority end)
end)
