local S = minetest.get_translator("mcl_potions")
mcl_potions.register_effect({
	name = "infested",
	description = S("Infested"),
	res_condition = function(obj)
		-- apply to players and non-silverfish mobs
		if obj:is_player() then return false end
		local entity = obj:get_luaentity()
		if entity and entity.is_mob and entity.name ~= "mobs_mc:silverfish" then return false end
		return true
	end,
	get_tt = function(factor)
		return S("Causes 1-2 silverfish to spawn with a 10% chance when damaged")
	end,
	-- TODO: Better particles (or change colour)
	particle_color = "#472331",
	uses_factor = false,
})



-- Called for mobs in their physics.lua
function mcl_potions.check_infested_on_damage(obj)
	-- check for infested status effect
	-- TODO: silverfish should fling out in direction entity faces
	if mcl_potions.get_effect(obj, "infested") and math.random(1, 10) == 1 then
		-- 50-50 for 1 or 2 silverfish
		minetest.add_entity(obj:get_pos(), "mobs_mc:silverfish")
		if math.random(1, 2) == 1 then
			minetest.add_entity(obj:get_pos(), "mobs_mc:silverfish")
		end
	end
end

mcl_damage.register_on_damage(function (obj, damage, reason)
	mcl_potions.check_infested_on_damage(obj)
end)


mcl_potions.register_effect({
	name = "oozing",
	description = S("Oozing"),
	res_condition = function(obj)
		-- apply to players and non-slime mobs
		if obj:is_player() then return false end
		local entity = obj:get_luaentity()
		if entity and entity.is_mob and not string.find(entity.name, "mobs_mc:slime") then return false end
		return true
	end,
	get_tt = function(factor)
		return S("Causes 2 medium slimes to spawn on death")
	end,
	-- TODO: Better particles (or change colour)
	particle_color = "#60AA30",
	uses_factor = false,
})

-- Called for mobs in their physics.lua
function mcl_potions.check_oozing_on_death(obj)
	-- check for oozing status effect
	-- TODO: maybe slimes shouldn't spawn through walls (is this practical without line of sight check?)
	if mcl_potions.get_effect(obj, "oozing") then
		local pos = vector.round(obj:get_pos())
		-- Use distance of 2 for 5x5x5 area as find_nodes_in_area is quite zealous with valid nodes
		local nodes_under_air = minetest.find_nodes_in_area_under_air(vector.offset(pos, -2, -2, -2), vector.offset(pos, 2, 2, 2), "group:solid")
		-- always 2 medium ('small') slimes
		for i=1,2 do
			local spawn_pos
			if #nodes_under_air == 0 then
				spawn_pos = pos
			else
				-- Spawn in air above node
				spawn_pos = vector.offset(nodes_under_air[math.random(#nodes_under_air)], 0, 1, 0)
			end
			minetest.add_entity(spawn_pos, "mobs_mc:slime_small")
		end
	end
end

mcl_damage.register_on_death(function (obj, damage, reason)
	mcl_potions.check_oozing_on_death(obj)
end)

-- TODO: Reduce cobweb movement resistance when
mcl_potions.register_effect({
	name = "weaving",
	description = S("Weaving"),
	res_condition = function(obj)
		-- apply to players and mobs
		if obj:is_player() then return false end
		local entity = obj:get_luaentity()
		if entity and entity.is_mob then return false end
		return true
	end,
	get_tt = function(factor)
		return S("Causes 2-3 cobwebs to appear on death")
	end,
	-- TODO: Better particles (or change colour)
	particle_color = "#ACCCFF",
	uses_factor = false,
})

-- Called for mobs in their physics.lua
function mcl_potions.check_weaving_on_death(obj)
	-- check for weaving status effect
	if mcl_potions.get_effect(obj, "weaving") then
		local pos = vector.round(obj:get_pos())
		-- Use distance of 1 for 3x3x3 area as find_nodes_in_area is quite zealous with valid nodes
		-- TODO: Cobwebs should probably be able to replace replaceable nodes (e.g. grass)
		local nodes_under_air = minetest.find_nodes_in_area_under_air(vector.offset(pos, -1, -1, -1), vector.offset(pos, 1, 1, 1), "group:solid")
		--minetest.debug(#nodes_under_air, dump(pos), dump(nodes))
		-- spawn 2-3 cobwebs
		local num_cobwebs = math.random(2, 3)
		for i=1,num_cobwebs do
			if #nodes_under_air == 0 then
				return
			end
			local pos_index = math.random(1, #nodes_under_air)
			-- Put cobweb in the air above node
			minetest.set_node(vector.offset(nodes_under_air[pos_index], 0, 1, 0), {name="mcl_core:cobweb"})
			table.remove(nodes_under_air, pos_index)
		end
	end
end

mcl_damage.register_on_death(function (obj, damage, reason)
	mcl_potions.check_weaving_on_death(obj)
end)

mcl_potions.register_effect({
	name = "wind_charged",
	description = S("Wind Charged"),
	res_condition = function(obj)
		-- apply to players and mobs
		if obj:is_player() then return false end
		local entity = obj:get_luaentity()
		if entity and entity.is_mob then return false end
		return true
	end,
	get_tt = function(factor)
		return S("Causes A wind burst on death")
	end,
	particle_color = "#CEE1FE",
	uses_factor = false,
})

-- Called for mobs in their physics.lua
function mcl_potions.check_wind_charged_on_death(obj)
	-- check for weaving status effect
	if mcl_potions.get_effect(obj, "wind_charged") then
		local pos = vector.round(obj:get_pos())
		local posy = {x=pos.x, y=pos.y-1, z=pos.z}
		local RADIUS = 8
		local damage_radius = (RADIUS / math.max(1, RADIUS)) * RADIUS
		mcl_charges.wind_burst(posy, damage_radius)
	end
end

mcl_damage.register_on_death(function (obj, damage, reason)
	mcl_potions.check_wind_charged_on_death(obj)
end)
