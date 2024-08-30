-- TODO: when < minetest 5.9 isn't supported anymore, remove this variable check and replace all occurences of [hud_elem_type_field] with type
local hud_elem_type_field = "type"
if not minetest.features.hud_def_type_field then
	hud_elem_type_field = "hud_elem_type"
end

local hud_totem = {}

minetest.register_on_leaveplayer(function(player)
	hud_totem[player] = nil
end)

local particle_colors = {"ACD520", "A39F2C", "C3C62F", "ACBB2D", "C2AD25", "3AAA11", "2EAF01", "398723", "338631", "36901B", "206F2C", "226B2F", "3F7724", "466C01"} -- These probably aren't all of the colors, but they are a few of them

-- Save the player from death when holding totem of undying in hand
vlf_damage.register_modifier(function(obj, damage, reason)
	if obj:is_player() and not reason.flags.bypasses_totem then
		local hp = obj:get_hp()
		if hp - damage <= 0 then
			local wield = obj:get_wielded_item()
			local in_offhand = false
			if wield:get_name() ~= "vlf_totems:totem_of_undying" then
				local inv = obj:get_inventory()
				if inv then
					wield = obj:get_inventory():get_stack("offhand", 1)
					in_offhand = true
				end
			end
			if wield:get_name() == "vlf_totems:totem" then
				local ppos = obj:get_pos()

				if obj:get_breath() < 11 then
					obj:set_breath(10)
				end

				if not minetest.is_creative_enabled(obj:get_player_name()) then
					wield:take_item()
					if in_offhand then
						obj:get_inventory():set_stack("offhand", 1, wield)
						vlf_inventory.update_inventory_formspec(obj)
					else
						obj:set_wielded_item(wield)
					end
				end
				awards.unlock(obj:get_player_name(), "vlf:postMortal")

				-- Effects
				minetest.sound_play({name = "vlf_totems_totem", gain = 1}, {pos=ppos, max_hear_distance = 16}, true)

				for i = 1, 4 do
					for c = 1, #particle_colors do
						minetest.add_particlespawner({
								amount = math.floor(100 / (4 * #particle_colors)),
								time = 1,
								minpos = vector.offset(ppos, 0, -1, 0),
								maxpos = vector.offset(ppos, 0, 1, 0),
								minvel = vector.new(-1.5, 0, -1.5),
								maxvel = vector.new(1.5, 1.5, 1.5),
								minacc = vector.new(0, -0.1, 0),
								maxacc = vector.new(0, -1, 0),
								minexptime = 1,
								maxexptime = 3,
								minsize = 1,
								maxsize = 2,
								collisiondetection = true,
								collision_removal = true,
								object_collision = false,
								vertical = false,
								texture = "vlf_particles_totem" .. i .. ".png^[colorize:#" .. particle_colors[c],
								glow = 10,
							})
					end
				end
				
				-- Status entity_effects; see
				-- https://minecraft.wiki/w/Totem_of_Undying
				--
				-- Totems also clear all entity_effects
				-- before applying theirs.
				vlf_entity_effects._reset_entity_effects (obj, true)
				vlf_entity_effects.give_entity_effect_by_level ("regeneration", obj, 2, 45);
				vlf_entity_effects.give_entity_effect ("fire_resistance", obj, 1, 40);
				vlf_entity_effects.give_entity_effect_by_level ("absorption", obj, 2, 5);

				-- Big totem overlay
				if not hud_totem[obj] then
					hud_totem[obj] = obj:hud_add({
						[hud_elem_type_field] = "image",
						text = "vlf_totems_totem.png",
						position = {x = 0.5, y = 1},
						scale = {x = 17, y = 17},
						offset = {x = 0, y = -178},
						z_index = 100,
					})
					minetest.after(3, function()
						if obj:is_player() then
							obj:hud_remove(hud_totem[obj])
							hud_totem[obj] = nil
						end
					end)
				end

				-- Set HP to exactly 1
				return hp - 1
			end
		end
	end
end, 1000)
