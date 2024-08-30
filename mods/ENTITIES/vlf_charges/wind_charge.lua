-- Damage radius refined here and in the init.lua
local RADIUS = 4
local damage_radius = (RADIUS / math.max(1, RADIUS)) * RADIUS
local radius = 2

-- Wind Charge Registry
register_charge("wind_charge", "Wind Charge", {
	hit_player = vlf_mobs.get_arrow_damage_func(0, "fireball"),
	hit_mob = vlf_mobs.get_arrow_damage_func(6, "fireball"),
	hit_node = function(self, pos, node)
		vlf_charges.wind_burst(pos, damage_radius)
		local pr = PseudoRandom(math.ceil(os.time() / 60 / 10)) -- make particles change direction every 10 minutes
		local v = vector.new(pr:next(-2, 2)/10, 0, pr:next(-2, 2)/10)
		local amount = 6
			v.y = pr:next(-9, -4) / 10
					minetest.add_particlespawner(table.merge(wind_burst_spawner, {
						amount = amount,
						minacc = v,
						maxacc = v,
						minpos = vector.offset(pos, -0.8, 0.6, -0.8),
						maxpos = vector.offset(pos, 0.8, 0.8, 0.8),
					}))
		minetest.sound_play("tnt_explode", { pos = pos, gain = 0.4, max_hear_distance = 30, pitch = 2.5 }, true)
		local pos = self.object:get_pos()
		local node = minetest.get_node(pos)

-- Bell, Chorus flower, and Decorated Pot:
				if node.name == "vlf_bells:bell" then
					vlf_bells.ring_once(pos)
				end
				if node.name == "vlf_end:chorus_flower" then
					minetest.dig_node(pos)
					vlf_charges.chorus_flower_entity_effects(pos, radius)
				end
				if node.name == "vlf_end:chorus_flower_dead" then
					minetest.swap_node(pos, {name = "air"})
					minetest.add_item(pos, {name = "vlf_end:chorus_flower"})
					vlf_charges.chorus_flower_entity_effects(pos, radius)
				end
				if node.name == "vlf_pottery_sherds:pot" then
					minetest.swap_node(pos, {name = "air"})
					minetest.add_item(pos, {name = "vlf_core:brick"})
					minetest.add_item(pos, {name = "vlf_core:brick"})
					minetest.add_item(pos, {name = "vlf_core:brick"})
					minetest.add_item(pos, {name = "vlf_core:brick"})
					vlf_charges.pot_entity_effects(pos, radius)
				end
	end,
	hit_player_alt = function(self, pos)
		vlf_charges.wind_burst(pos, damage_radius)
		local pr = PseudoRandom(math.ceil(os.time() / 60 / 10))
		local v = vector.new(pr:next(-2, 2)/10, 0, pr:next(-2, 2)/10)
			v.y = pr:next(-9, -4) / 10
				minetest.add_particlespawner(table.merge(wind_burst_spawner, {
					minacc = v,
					maxacc = v,
					minpos = vector.offset(pos, -0.8, 0.6, -0.8),
					maxpos = vector.offset(pos, 0.8, 0.8, 0.8),
				}))
		minetest.sound_play("tnt_explode", { pos = pos, gain = 0.5, max_hear_distance = 30, pitch = 2.5 }, true)
	end,
	hit_mob_alt = function(self, pos)
		vlf_charges.wind_burst(pos, damage_radius)
		local pr = PseudoRandom(math.ceil(os.time() / 60 / 10))
		local v = vector.new(pr:next(-2, 2)/10, 0, pr:next(-2, 2)/10)
			v.y = pr:next(-9, -4) / 10
				minetest.add_particlespawner(table.merge(wind_burst_spawner, {
					minacc = v,
					maxacc = v,
					minpos = vector.offset(pos, -0.8, 0.6, -0.8),
					maxpos = vector.offset(pos, 0.8, 0.8, 0.8),
				}))
		minetest.sound_play("tnt_explode", { pos = pos, gain = 0.5, max_hear_distance = 30, pitch = 2.5 }, true)
	end,
	on_activate = function(self, staticdata)
		self.object:set_armor_groups({immortal = 1})
		minetest.after(3, function()
			if self.object:get_luaentity() then
				self.object:remove()
			end
		end)
	end,
})
