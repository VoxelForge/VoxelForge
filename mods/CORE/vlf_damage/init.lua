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
		freeze = {bypasses_armor = true},
		starve = {bypasses_armor = true, bypasses_magic = true},
		cactus = {},
		sweet_berry = {},
		fall = {bypasses_armor = true},
		fly_into_wall = {bypasses_armor = true}, -- unused
		out_of_world = {bypasses_armor = true, bypasses_magic = true, bypasses_invulnerability = true, bypasses_totem = true},
		generic = {bypasses_armor = true},
		magic = {is_magic = true, bypasses_armor = true, bypasses_guardian = true,},
		dragon_breath = {is_magic = true, bypasses_armor = true},	-- this is only used for dragon fireball; dragon fireball does not actually deal impact damage tho, so this is unreachable
		wither = {bypasses_armor = true},
		wither_skull = {is_magic = true, is_explosion = true},
		anvil = {},
		falling_node = {},	-- this is falling_block in MC
		spit = {is_projectile = true},
		mob = {},
		player = {},
		arrow = {is_projectile = true},
		fireball = {is_projectile = true, is_fire = true},
		thorns = {is_magic = true, bypasses_guardian = true,},
		explosion = {is_explosion = true, scales = true, always_affects_dragons = true},
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

	if vlf_reason.source then
		if not vlf_reason.source:is_player () then
			local entity = vlf_reason.source:get_luaentity ()
			if entity and entity.is_mob then
				vlf_reason.mob_name = entity.name
			end
		end
	end
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

--- Player damage.

local function emulate_damage_tick (player)
	minetest.sound_play ("player_damage",
			{ to_player = player:get_player_name (), gain = 0.5, },
			true)
end

--- An independent floating point health statistic is associated with
--- players which is synchronized with the engine HP whenever damage
--- is sustained or healing takes place.  If the engine HP changes
--- independently of this statistic, the change is adjusted by the
--- statistic.

function vlf_damage.damage_player (player, amount, vlf_reason)
	if not vlf_reason.flags then
	  vlf_damage.finish_reason (vlf_reason)
	end
	if amount < 0 then
	  vlf_damage.heal_player (player, -amount)
	end

	local meta = player:get_meta ()
	local vlf_health = meta:get_float ("vlf_health")
	local engine_hp = player:get_hp ()

	-- It's probably wise to be cautious and verify that the engine and
	-- internal HPs match.

	if math.ceil (vlf_health) ~= engine_hp then
	  minetest.log ("warning", ("Engine health of player "
				.. player:get_player_name ()
				.. " disagrees with MCL health "
				.. vlf_health ..""))
	  -- Reset internal health to the engine value.
	  vlf_health = engine_hp
	end
	amount = vlf_damage.run_modifiers (player, amount, vlf_reason)
	vlf_health = math.max (0, vlf_health - amount)
	meta:set_float ("vlf_health", vlf_health)

	vlf_health = math.ceil (vlf_health)
	if vlf_health < engine_hp then
	  player:set_hp (vlf_health, { type = "set_hp", vlf_damage = true,
					_vlf_reason = vlf_reason, })
	elseif amount > 0 then
	  -- Play a damage sound to the player.  Minetest affords games no
	  -- control over the tilt animation, unfortunately.
	  emulate_damage_tick (player)
	end
end

function vlf_damage.heal_player (player, amount)
	if amount < 0 then
	  return
	end

	local meta = player:get_meta ()
	local vlf_health = meta:get_float ("vlf_health")
	local engine_hp = player:get_hp ()
	if math.ceil (vlf_health) ~= engine_hp then
	  minetest.log ("warning", ("Engine health of player "
				.. player:get_player_name ()
				.. " disagrees with MCL health "
				.. vlf_health ..""))
	  -- Reset internal health to the engine value.
	  vlf_health = engine_hp
	end
	vlf_health = math.min (player:get_properties ().hp_max,
			  vlf_health + amount)
	meta:set_float ("vlf_health", vlf_health)

	vlf_health = math.ceil (vlf_health)
	if vlf_health > engine_hp then
	  player:set_hp (vlf_health, { type = "set_hp", vlf_damage = true, })
	end
end

function vlf_damage.get_hp (player)
	local meta = player:get_meta ()
	local vlf_health = meta:get_float ("vlf_health")
	local engine_hp = player:get_hp ()
	if math.ceil (vlf_health) ~= engine_hp then
	  minetest.log ("warning", ("Engine health of player "
				.. player:get_player_name ()
				.. " disagrees with MCL health "
				.. vlf_health ..""))
	  -- Reset internal health to the engine value.
	  vlf_health = engine_hp
	end
	return vlf_health
end

minetest.register_on_player_hpchange(function(player, hp_change, mt_reason)
	if not damage_enabled then return 0 end
	-- Take engine damage modifications from vlf_damage at face value.
	if mt_reason.vlf_damage then
		return hp_change
	end

	-- Detect damage from hazardous nodes and deduct the full
	-- amount of the damage, rather than hp_change, which is
	-- restricted to the player's remaining health and may be
	-- attenuated by armor or other protection.

	if mt_reason.type == "node_damage" and mt_reason.node then
		local nodedef = minetest.registered_nodes[mt_reason.node]

		if nodedef.damage_per_second then
		  hp_change = -nodedef.damage_per_second
		end
	end

	if hp_change < 0 then
		if player:get_hp() <= 0 then
		  return 0
		end
		hp_change = -vlf_damage.run_modifiers (player, -hp_change,
						  vlf_damage.from_mt (mt_reason))
	end

	-- Apply this as internal damage.
	local meta = player:get_meta ()
	local vlf_health = meta:get_float ("vlf_health")
	local engine_hp = player:get_hp ()

	-- It's probably wise to be cautious and verify that the
	-- engine and internal HPs match.

	if math.ceil (vlf_health) ~= engine_hp then
		minetest.log ("warning", ("Engine health of player "
					 .. player:get_player_name ()
					 .. " disagrees with MCL health "
					 .. vlf_health ..""))
		-- Reset internal health to the engine value.
		vlf_health = engine_hp
	end

	-- Deduct engine damage.
	vlf_health = math.max (0, vlf_health + hp_change)
	meta:set_float ("vlf_health", vlf_health)

	-- Return the difference in engine damage.
	local difference = math.ceil (vlf_health) - engine_hp
	if mt_reason.type ~= "fall" and difference == 0 and hp_change < 0 then
		emulate_damage_tick (player)
	end
	return difference
end, true)

minetest.register_on_punchplayer (function (player, hitter, _, _, _, damage)
	  -- Inflict the Minetest-computed damage by means of
	  -- vlf_damage.damage_player.
	  if damage > 0 then
	 local vlf_reason = { type = "generic", }
	 vlf_damage.from_punch (vlf_reason, hitter)
	 vlf_damage.damage_player (player, damage, vlf_reason)
	 return true
	  end
end)

minetest.register_on_joinplayer (function (player, _)
	  -- Convert the player's engine HP into a floating point internal
	  -- value if none already exists.
	  local meta = player:get_meta ()
	  if meta:get_float ("vlf_health") == 0 then
	 meta:set_float ("vlf_health", player:get_hp ())
	  end
end)

minetest.register_on_dieplayer(function(player, mt_reason)
	  -- Clear the internal HP of players who die.
	  local meta = player:get_meta ()
	  meta:set_float ("vlf_health", 0)
	  vlf_damage.run_death_callbacks(player, vlf_damage.from_mt(mt_reason))
end)

-- Register a modifier that adjusts damage by difficulty.

local function is_mob (source)
	if not source then
		return false
	end
	local entity = source:get_luaentity ()
	return entity and entity.is_mob
end

vlf_damage.register_modifier (function (obj, damage, reason)
	if not obj:is_player () then
		return damage
	end
	if (reason.flags.scales == true) or is_mob (reason.source) then
		if vlf_vars.difficulty == 0 then
			return 0
		elseif vlf_vars.difficulty == 1 then
			return math.min (damage / 2.0 + 1.0, damage)
		elseif vlf_vars.difficulty == 3 then
			return damage * 1.5
		end
	end
	return damage
end, -1000)

minetest.register_on_mods_loaded(function()
	table.sort(vlf_damage.modifiers, function(a, b) return a.priority < b.priority end)
end)
