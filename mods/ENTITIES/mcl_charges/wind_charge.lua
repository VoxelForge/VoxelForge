local S = core.get_translator("mcl_charges")
local RADIUS = 4
local damage_radius = (RADIUS / math.max(1, RADIUS)) * RADIUS
local radius = 2

local function windcharge_hit(pos, node)
    -- Define the search radius
    local radius = 3

    -- Loop through all nodes within the radius
    for x = -radius, radius do
        for y = -radius, radius do
            for z = -radius, radius do
                -- Calculate the current position to check
                local check_pos = {x = pos.x + x, y = pos.y + y, z = pos.z + z}

                -- Get the node at the current position
                local check_node = minetest.get_node(check_pos)

                -- Check if the node name contains "lit"
                if check_node.name:find("lit_candle") then
                    -- Replace "lit" with "unl" in the node name
                    local new_node_name = check_node.name:gsub("lit_candle", "unl_candle")

                    -- Set the new node at the position
                    minetest.set_node(check_pos, {name = new_node_name})
                end
            end
        end
    end
end

mcl_charges.register_charge("wind_charge", S("Wind Charge"), {
	hit_player = mcl_mobs.get_arrow_damage_func(0, "fireball"),
	hit_mob = mcl_mobs.get_arrow_damage_func(6, "fireball"),
	hit_node = function(self, pos, node)
		mcl_charges.wind_burst(pos, damage_radius, self.origin_pos, self.owner)
		local pr = PseudoRandom(math.ceil(os.time() / 60 / 10)) -- make particles change direction every 10 minutes
		local v = vector.new(pr:next(-2, 2)/10, 0, pr:next(-2, 2)/10)
		v.y = pr:next(-9, -4) / 10
		minetest.add_particlespawner(table.merge(mcl_charges.wind_burst_spawner, {
			minacc = v,
			maxacc = v,
			minpos = vector.offset(pos, -0.8, 0.6, -0.8),
			maxpos = vector.offset(pos, 0.8, 0.8, 0.8),
		}))
		minetest.sound_play("tnt_explode", { pos = pos, gain = 0.4, max_hear_distance = 30, pitch = 2.5 }, true)

		if node.name == "mcl_bells:bell" then
			mcl_bells.ring_once(pos)
		end
		if node.name == "mcl_end:chorus_flower" then
			minetest.dig_node(pos)
			mcl_charges.chorus_flower_effects(pos, radius)
		end
		if node.name == "mcl_end:chorus_flower_dead" then
			minetest.swap_node(pos, {name = "air"})
			minetest.add_item(pos, {name = "mcl_end:chorus_flower"})
			mcl_charges.chorus_flower_effects(pos, radius)
		end
		if node.name == "mcl_pottery_sherds:pot" then
			minetest.swap_node(pos, {name = "air"})
			minetest.add_item(pos, {name = "mcl_core:brick"})
			minetest.add_item(pos, {name = "mcl_core:brick"})
			minetest.add_item(pos, {name = "mcl_core:brick"})
			minetest.add_item(pos, {name = "mcl_core:brick"})
			mcl_charges.pot_effects(pos, radius)
		end
        windcharge_hit(pos, node)
	end,
	hit_player_alt = function(_, pos)
		mcl_charges.wind_burst(pos, damage_radius, self.origin_pos, self.owner)
		local pr = PseudoRandom(math.ceil(os.time() / 60 / 10))
		local v = vector.new(pr:next(-2, 2)/10, 0, pr:next(-2, 2)/10)
		v.y = pr:next(-9, -4) / 10
		minetest.add_particlespawner(table.merge(mcl_charges.wind_burst_spawner, {
			minacc = v,
			maxacc = v,
			minpos = vector.offset(pos, -0.8, 0.6, -0.8),
			maxpos = vector.offset(pos, 0.8, 0.8, 0.8),
		}))
		minetest.sound_play("tnt_explode", { pos = pos, gain = 0.5, max_hear_distance = 30, pitch = 2.5 }, true)
        windcharge_hit(pos, node)
	end,
	hit_mob_alt = function(_, pos)
		mcl_charges.wind_burst(pos, damage_radius, self.origin_pos, self.owner)
		local pr = PseudoRandom(math.ceil(os.time() / 60 / 10))
		local v = vector.new(pr:next(-2, 2)/10, 0, pr:next(-2, 2)/10)
		v.y = pr:next(-9, -4) / 10
		minetest.add_particlespawner(table.merge(mcl_charges.wind_burst_spawner, {
			minacc = v,
			maxacc = v,
			minpos = vector.offset(pos, -0.8, 0.6, -0.8),
			maxpos = vector.offset(pos, 0.8, 0.8, 0.8),
		}))
		minetest.sound_play("tnt_explode", { pos = pos, gain = 0.5, max_hear_distance = 30, pitch = 2.5 }, true)
        windcharge_hit(pos, node)
	end,
	on_activate = function(self, _)
		self.object:set_armor_groups({immortal = 1})
		minetest.after(3, function()
			if self.object:get_luaentity() then
				self.object:remove()
			end
		end)
	end,
})
