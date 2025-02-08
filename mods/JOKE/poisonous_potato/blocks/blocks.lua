minetest.register_node(":voxelforge:pedestal", {
	description = ("Pedestal"),
	tiles = {
		"pedestal.png",
	},
	drawtype = "mesh",
	is_ground_content = false,
	paramtype = "light",
	mesh = "pedestal.obj",
	groups = {handy = 1, deco_block = 1, dig_by_piston = 1, unsticky = 1, potato = 1},
	sounds = vlf_sounds.node_sound_stone_defaults(),
	_vlf_blast_resistance = 1200,
	_vlf_hardness = 55,
	use_texture_alpha = "clip",
})

minetest.register_node(":voxelforge:potato_portal", {
	description = ("Potato Portal"),
	tiles = {
		{
			name = "potato_portal.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 4.0,
			},
		},
	},
	drawtype = "mesh",
	is_ground_content = false,
	paramtype = "light",
	light_source = 15,
	mesh = "potato_portal.obj",
	walkable = false,
	groups = {handy = 1, deco_block = 1, dig_by_piston = 1, unsticky = 1, potato = 1},
	sounds = vlf_sounds.node_sound_stone_defaults(),
	_vlf_blast_resistance = -1,
	_vlf_hardness = -1,
	use_texture_alpha = "blend",
})

minetest.register_node(":voxelforge:big_brain", {
	description = ("Big Brain"),
	tiles = {
		"tater.png",
		"big_brain_front_back.png",
		"big_brain_left_right.png",
		"big_brain_front_back.png",
		"big_brain_left_right.png",
		"big_brain_top_bottom.png",
	},
	drawtype = "mesh",
	is_ground_content = false,
	paramtype = "light",
	drop = {"voxelforge:big_brain", "potato_of_knowledge"},
	mesh = "big_brain.obj",
	groups = {handy = 1, deco_block = 1, dig_by_piston = 1, unsticky = 1, potato = 1},
	sounds = vlf_sounds.node_sound_stone_defaults(),
	_vlf_blast_resistance = 1200,
	_vlf_hardness = 55,
	use_texture_alpha = "clip",
})

local boxes = { -8/16, -8/16, -8/16,  8/16, -2/16, 8/16 }
local toggle_inverted = {
	["voxelforge:potato_battery"] = "voxelforge:potato_battery_inverted",
	["voxelforge:potato_battery_inverted"] = "voxelforge:potato_battery",
}
local commdef = {
	drawtype = "nodebox",
	wield_scale = { x=1, y=1, z=3 },
	paramtype = "light",
	is_ground_content = false,
	selection_box = {
		type = "fixed",
		fixed = boxes
	},
	node_box = {
		type = "fixed",
		fixed = boxes
	},
	groups = {handy=1,axey=1, material_wood=1, flammable=-1, daylight_detector=1, unmovable_by_piston = 1, potato = 1},
	sounds = vlf_sounds.node_sound_glass_defaults(),
	on_rightclick = function(pos, node, clicker, pointed_thing)
		local protname = clicker:get_player_name()
		if minetest.is_protected(pos, protname) then
			minetest.record_protection_violation(pos, protname)
			return
		end
		vlf_redstone.swap_node(pos, {name = toggle_inverted[node.name], param2 = node.param2})
	end,
	_vlf_blast_resistance = 3,
	_vlf_hardness = 3,
}

minetest.register_node(":voxelforge:potato_battery", table.merge(commdef, {
	tiles = { "potato_battery_top.png","potato_battery_top.png","potato_battery_side.png",
		"potato_battery_side.png","potato_battery_side.png","potato_battery_side.png", },
	wield_image = "potato_battery_top.png",
	description=("Potato Battery"),
	_vlf_redstone = {
		get_power = function(node, dir)
			return 0, false
		end,
		connects_to = function(node, dir)
			return true
		end,
	},
}))


minetest.register_node(":voxelforge:potato_battery_inverted", table.merge(commdef, {
	tiles = { "potato_battery_inverted_top.png","potato_battery_inverted_top.png","potato_battery_side.png",
	"potato_battery_side.png","potato_battery_side.png","potato_battery_side.png", },
	wield_image = "potato_battery_inverted_top.png",
	drop = "voxelforge:potato_battery",
	groups = table.merge(commdef.groups, {not_in_creative_inventory=1}),
	description=("Inverted Potato Battery"),
	_doc_items_create_entry = false,
	_vlf_redstone = {
		get_power = function(node, dir)
			return 15
		end,
		connects_to = function(node, dir)
			return true
		end,
	},
}))

vlf_player.register_globalstep_slow(function(player, dtime)
	-- Get the player's position
	local pos = player:get_pos()
	if not pos then return end

	-- Find all entities within a 30-block radius of the player's position
	local objects = minetest.get_objects_inside_radius(pos, 30)

	for _, obj in ipairs(objects) do
		if obj and obj:get_pos() then
			-- Am I near a cactus?
			local obj_pos = obj:get_pos()
			local near = minetest.find_node_near(obj_pos, 1, "voxelforge:potato_battery_inverted", true)
			if near then
				-- Am I touching the cactus? If so, it hurts
				local dist = vector.distance(obj_pos, near)
				if dist < 0.9 then
					-- Add a particle spawner at the block's position
					minetest.add_particlespawner({
						amount = 10,
						time = 1, -- Spawner lasts for 1 second
						minpos = vector.subtract(near, 0.5),
						maxpos = vector.add(near, 0.5),
						minvel = {x = -1, y = 0.5, z = -1},
						maxvel = {x = 1, y = 1, z = 1},
						minacc = {x = 0, y = -0.1, z = 0},
						maxacc = {x = 0, y = 0.1, z = 0},
						minexptime = 0.5,
						maxexptime = 1,
						minsize = 1,
						maxsize = 2,
						texture = "vlf_copper_anti_oxidation_particle.png", -- Replace with your particle texture
					})

					-- Deal damage to players and damageable entities
					if obj:is_player() or (obj:get_luaentity() and obj:get_luaentity().health) then
						local hp = obj:is_player() and obj:get_hp() or obj:get_luaentity().health
						if hp > 0 then
							vlf_util.deal_damage(obj, 1, {type = "a_bad_tempered_potato"})
						end
					end
				end
			end
		end
	end
end)

minetest.register_node(":voxelforge:floatato", {
	description = ("Floatato"),
	tiles = {
		"floatato.png",
	},
	is_ground_content = false,
	paramtype = "light",
	groups = {hoey = 1, deco_block = 1, dig_by_piston = 1, unsticky = 1, potato = 1},
	sounds = vlf_sounds.node_sound_stone_defaults(),
	_vlf_blast_resistance = 0.3,
	_vlf_hardness = 0.3,
	use_texture_alpha = "clip",
})

-- Floatater (Currently due to the use of entities this would be very laggy)

minetest.register_node(":voxelforge:powerful_potato", {
	description = ("Powerful Potato"),
	tiles = {
		"powerful_potato.png",
	},
	is_ground_content = false,
	paramtype = "light",
	groups = {handy = 1, deco_block = 1, dig_by_piston = 1, unsticky = 1, potato = 1},
	sounds = vlf_sounds.node_sound_stone_defaults(),
	_vlf_blast_resistance = 0.4,
	_vlf_hardness = 0.4,
	use_texture_alpha = "clip",
})

minetest.register_node(":voxelforge:amber_block", {
	description = ("Block of Amber"),
	tiles = {
		"amber_block.png",
	},
	is_ground_content = false,
	paramtype = "light",
	groups = {pickaxey = 1, deco_block = 1, dig_by_piston = 1, unsticky = 1, potato = 1},
	sounds = vlf_sounds.node_sound_stone_defaults(),
	_vlf_blast_resistance = 6,
	_vlf_hardness = 5,
	use_texture_alpha = "clip",
})

minetest.register_node(":voxelforge:potato_flower", {
	description = ("Potato Flower"),
	drawtype = "plantlike",
	waving = 1,
	tiles = { "potato_flower.png" },
	inventory_image = "potato_flower.png",
	wield_image = "potato_flower.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	groups = {
		attached_node = 1, deco_block = 1, dig_by_piston = 1, dig_immediate = 3,
		dig_by_water = 1, destroy_by_lava_flow = 1, enderman_takable = 1,
		plant = 1, flower = 1, place_flowerlike = 1, non_mycelium_plant = 1,
		flammable = 2, fire_encouragement = 60, fire_flammability = 100,
		compostability = 65, unsticky = 1
	},
	sounds = vlf_sounds.node_sound_leaves_defaults(),
	node_placement_prediction = "",
	on_place = vlf_flowers.on_place_flower,
	selection_box = {
		type = "fixed",
		fixed = { -5/16, -0.5, -5/16, 5/16, 5/16, 5/16 },
	},
	--_vlf_silk_touch_drop = ,
	_on_bone_meal = vlf_flowers.on_bone_meal_simple,
})

local nether_wood_groups = { handy = 1, axey = 1, material_wood = 1, building_block = 1}
vlf_trees.register_wood("potato",{
	readable_name="Potato",
	sign = {_vlf_burntime = 0 },
	sign_color="#30b459",
	boat=false,
	chest_boat=false,
	sapling=false,
	stripped=false,
	stripped_bark=false,
	bark=false,
	tree = {
		tiles = {"potato_stem_top.png", "potato_stem_top.png",{name="potato_stem.png",animation = {type = "vertical_frames",aspect_w = 16,aspect_h = 16,length = 1.0}}},
		groups = table.merge(nether_wood_groups,{tree = 1}),
		_vlf_burntime = 0,
		_vlf_cooking_output = ""
	},
	leaves = {
		tiles = {"potato_leaves.png"},
		_vlf_burntime = 0,
		_vlf_cooking_output = ""
	},
	wood = {
		tiles = {"potato_planks.png"},
		groups = table.merge(nether_wood_groups,{wood = 1}),
		_vlf_burntime = 0
	},
	fence = {
		tiles = { "potato_fence.png" },
		_vlf_burntime = 0
	},
	fence_gate = {
		tiles = { "potato_fence.png" },
		_vlf_burntime = 0
	},
	door = {
		inventory_image = "potato_door.png",
		tiles_bottom = {"potato_door_bottom.png","potato_door_side.png"},
		tiles_top = {"potato_door_top.png","potato_door_side.png"},
		_vlf_burntime = 0
	},
	trapdoor = {
		tile_front = "potato_trapdoor.png",
		tile_side = "potato_trapdoor.png",
		wield_image = "potato_trapdoor.png",
		_vlf_burntime = 0
	},
	button = { _vlf_burntime = 0 },
	pressure_plate = { _vlf_burntime = 0 },
	stairs = { overrides = { _vlf_burntime = 0 }},
	slab = { overrides = { _vlf_burntime = 0 }},
})
