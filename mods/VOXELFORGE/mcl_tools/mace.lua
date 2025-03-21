local S = minetest.get_translator("mcl_tools")
mcl_tools.mace_cooldown = {}

--Mace Cooldown
local cooldown_time = 1.6
local heavy_core_longdesc = S("Solid Blocks of Steel. These are only forged if those that are brave enough can defeat the trials that await them.")
local mace_longdesc = S("The mace is a slow melee weapon that deals incredible damage. “dig” key to use it. This weapon has a cooldown of 1.6 seconds, but if you fall the mace will deal more damage than if you are on the ground. The further you fall the more damage done. If you hit a mob or player then you will receive no fall damage, but beware. If you miss you will die. ")

minetest.register_node("mcl_tools:heavy_core", {
    description = S("Heavy Core"),
	paramtype = "light",
    _doc_long_desc = heavy_core_longdesc,
    tiles = {"mcl_tools_heavy_core_top.png", "mcl_tools_heavy_core_bottom.png", "mcl_tools_heavy_core_side.png"},
    is_ground_content = false,
    groups = {pickaxey = 1, deco_block = 1, rarity = 3},
    sounds = mcl_sounds.node_sound_stone_defaults(),
    paramtype2 = "facedir",
    drawtype = "nodebox",
    use_texture_alpha = "clip",
    node_box = {
        type = "fixed",
            fixed = {
              {-0.25, -0.5, -0.25, 0.25, 0.0, 0.25},
        },
    },
    _mcl_hardness = 10,
    _mcl_blast_resistance = 30,
})

--Mace
minetest.register_tool("mcl_tools:mace", {
	description = S("Mace"),
	_doc_items_longdesc = mace_longdesc,
	inventory_image = "mcl_tools_mace.png",
	groups = { weapon=1, mace=1, dig_speed_class=1, enchantability=10, sword=1, rarity = 3 },
	tool_capabilities = {
		full_punch_interval = 1.6,
		max_drop_level = 1,
		groupcaps = {
			snappy = {times = {1.5, 0.9, 0.4}, uses = 50, maxlevel = 3},
		},
		damage_groups = {fleshy = 5},
	},
	_repair_material = "mcl_mobitems:breeze_rod",
	_mcl_toollike_wield = true,

	on_use = function(itemstack, user, pointed_thing)
		local fall_distance = user:get_velocity().y
		local obj = pointed_thing.ref
		if pointed_thing.type == "object" then
			if mcl_tools.mace_cooldown[user] == nil then
				mcl_tools.mace_cooldown[user] = mcl_tools.mace_cooldown[user] or 0
			end
			local current_time = minetest.get_gametime()
			if current_time - mcl_tools.mace_cooldown[user] >= cooldown_time then
				local wind_burst = mcl_enchanting.get_enchantment(itemstack, "wind_burst")
				local density_add = (mcl_enchanting.get_enchantment(itemstack, "density") or 0) * 0.5 * fall_distance
				local damage = -6 * fall_distance / 5.5 + density_add
				mcl_tools.mace_cooldown[user] = current_time
				if fall_distance < 0 then
					if user:is_player() then
						if damage > 50 then
							awards.unlock(user:get_player_name(), "mcl:overoverkill")
						end
					end
					if obj:is_player() or obj:get_luaentity() then
						obj:punch(user, 1.6, {
						full_punch_interval = 1.6,
						damage_groups = {fleshy = -6 * fall_distance / 5.5 + density_add},
						}, nil)
					end
					if wind_burst >= 1 then
						local v = user:get_velocity()
						user:set_velocity(vector.new(v.x, 0, v.z))
						local pos = user:get_pos()
						-- set vertical V to 0  first otherwise this is highly dependent on falling speed
						user:add_velocity(vector.new(0, 10 + (wind_burst * 5), 0))
						local pr = PseudoRandom(math.ceil(os.time() / 60 / 10))
						local vr = vector.new(pr:next(-2, 2)/10, 0, pr:next(-2, 2)/10)
						local amount = 20
						vr.y = pr:next(-9, -4) / 10
						minetest.add_particlespawner(table.merge(mcl_charges.wind_burst_spawner, {
							amount = amount,
							minacc = vr,
							maxacc = vr,
							minpos = vector.offset(pos, -2, 3, -2),
							maxpos = vector.offset(pos, 2, 0.3, 2),
						}))
					end
				else
					if obj:is_player() or obj:get_luaentity() then
						obj:punch(user, 1.6, {
						full_punch_interval = 1.6,
						damage_groups = {fleshy = 6},
						}, nil)
					end
				end
			end
			if not minetest.is_creative_enabled(user:get_player_name()) then
				itemstack:add_wear(65535 / 500)
				return itemstack
			end
		end
	end,
})

minetest.register_on_leaveplayer(function(player)
	mcl_tools.mace_cooldown[player] = nil
end)

-- By Cora
mcl_damage.register_modifier(function(obj, damage, reason)
	if reason.type == "fall" and mcl_tools.mace_cooldown[obj] and minetest.get_gametime() - mcl_tools.mace_cooldown[obj] < 2 then
			return 0
	end
end)

--Crafting recipe for mace
minetest.register_craft({
	output = "mcl_tools:mace",
	recipe = {
		{ "", "mcl_tools:heavy_core" },
		{ "", "mcl_mobitems:breeze_rod" },
	}
})

