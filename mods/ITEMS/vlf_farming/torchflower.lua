--[[local S = minetest.get_translator(minetest.get_current_modname())

local planton = {"vlf_core:dirt_with_grass", "vlf_core:dirt", "vlf_core:podzol", "vlf_core:coarse_dirt", "vlf_lush_caves:moss", "vlf_mangrove:mangrove_mud_roots", "vlf_mud:mud", "vlf_lush_caves:rooted_dirt"}

for i=0, 1 do
	local texture = "vlf_farming_torchflower_" .. i .. ".png"
	local node_name = "vlf_farming:torchflower_bush_" .. i
	local groups = {sweet_berry=1, dig_immediate=3, not_in_creative_inventory=1,plant=1,attached_node=1,dig_by_water=1,destroy_by_lava_flow=1,dig_by_piston=1, flammable=3, fire_encouragement=60, fire_flammability=20, compostability=30}
	local orc
	if i >= 2 then
		orc = function(pos, node, clicker, itemstack, pointed_thing)
			if clicker and clicker:is_player() then
				local pn = clicker:get_player_name()
				if minetest.is_protected(pos, pn) then
					minetest.record_protection_violation(pos, pn)
					return false
				end
				if clicker:get_wielded_item():get_name() == "vlf_bone_meal:bone_meal" then
					return false
				end
			end
			minetest.swap_node(pos, {name = "vlf_farming:torchflower_1"})
			return itemstack
		end
	end

	minetest.register_node(node_name, {
		drawtype = "plantlike",
		tiles = {texture},
		description = S("Sweet Berry Bush (Stage @1)", i),
		paramtype = "light",
		sunlight_propagates = true,
		paramtype2 = "meshoptions",
		place_param2 = 3,
		move_resistance = 7,
		walkable = false,
		-- Dont even create a table if no berries are dropped.
		drop = not drop_berries and "" or {
			max_items = 1,
			items = {
				{ items = {"vlf_farming:sweet_berry " .. berries_to_drop[1] }, rarity = 2 },
				{ items = {"vlf_farming:sweet_berry " .. berries_to_drop[2] } }
			}
		},
		selection_box = {
			type = "fixed",
			fixed = {-6 / 16, -0.5, -6 / 16, 6 / 16, (-0.30 + (i*0.25)), 6 / 16},
		},
		inventory_image = texture,
		wield_image = texture,
		groups = groups,
		sounds = vlf_sounds.node_sound_leaves_defaults(),
		_vlf_blast_resistance = 0,
		_vlf_hardness = 0,
		on_rightclick = orc,
		_on_bone_meal = function(itemstack,placer,pointed_thing,pos,node)
			vlf_farming.on_bone_meal(itemstack,placer,pointed_thing,pos,node,"plant_sweet_berry_bush",1)
		end,
	})
end

-- TODO: Find proper interval and chance values for sweet berry bushes. Current interval and chance values are copied from vlf_farming:beetroot which has similar growth stages.
vlf_farming:add_plant("plant_torchflower", "vlf_flowers:torchflower", {"vlf_farming:torchflower_0", "vlf_farming:torchflower_1"}, 68, 2)]]

-- COMING SOON
