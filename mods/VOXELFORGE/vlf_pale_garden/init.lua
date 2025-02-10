local S = minetest.get_translator("vlf_pale_garden")
local schempath = minetest.get_modpath("vlf_pale_garden")
dofile(schempath.."/biome.lua")
dofile(schempath.."/mob.lua")
dofile(schempath.."/resin.lua")

local function random_moss_vegetation()
	local x = math.random()
	if x < 0.5208 then
		return "mcl_flowers:tallgrass"
	elseif x < 0.7812 then
		return "vlf_pale_garden:pale_moss_carpet"
	else
		return "mcl_flowers:double_grass"
	end
end

local function set_moss_with_chance_vegetation(pos)
	minetest.set_node(pos, { name = "vlf_pale_garden:pale_moss" })
	if math.random() < 0.6 then
		local vegetation = random_moss_vegetation()
		local pos_up = vector.offset(pos, 0, 1, 0)
		if vegetation == "mcl_flowers:double_grass" then
			local pos_up2 = vector.offset(pos, 0, 2, 0)
			if minetest.registered_nodes[minetest.get_node(pos_up2).name].buildable_to then
				minetest.set_node(pos_up, { name = "mcl_flowers:double_grass" })
				minetest.set_node(pos_up2, { name = "mcl_flowers:double_grass_top" })
			else
				minetest.set_node(pos_up, { name = "mcl_flowers:tallgrass" })
			end
		else
			minetest.set_node(pos_up, { name = vegetation })
		end
	end
end

vlf_pale_garden = {}

function vlf_pale_garden.bone_meal_moss(itemstack, placer, pointed_thing, pos)
	if minetest.get_node(vector.offset(pos, 0, 1, 0)).name ~= "air" then
		return false
	end

	local x_max = math.random(2, 3)
	local z_max = math.random(2, 3)
	local area_positions = minetest.find_nodes_in_area_under_air(
		vector.offset(pos, -x_max, -6, -z_max),
		vector.offset(pos, x_max, 4, z_max),
		{ "group:converts_to_moss" }
	)

	for _, conversion_pos in pairs(area_positions) do
		local x_distance = math.abs(pos.x - conversion_pos.x)
		local z_distance = math.abs(pos.z - conversion_pos.z)

		if not ( x_distance == x_max and z_distance == z_max ) then
			if x_distance == x_max or z_distance == z_max then
				if math.random() < 0.75 then
					set_moss_with_chance_vegetation(conversion_pos)
				end
			else
				set_moss_with_chance_vegetation(conversion_pos)
			end
		end
	end
	return true
end

local PARTICLE_DISTANCE = 20

local spawn_particlespawner = {
	texture = "",
	texpool = {},
	time = 2,
	glow = 1,
	minvel = vector.zero(),
	maxvel = vector.zero(),
	minacc = vector.new(-0.1, -0.1, -0.1),
	maxacc = vector.new(0.2, 0.2, 0.2),
	minexptime = 1.25,
	maxexptime = 2,
	minsize = 5.5,
	maxsize= 7.5,
	collisiondetection = true,
	collision_removal = true,
}

mcl_trees.register_wood("pale_oak",{
	readable_name=S("Pale"),
	sign_color="#E3D6CF",
	--sapling=true,
	tree_schems_2x2 = {
		{file = schempath.."/schems/pale_oak_tree_1.mts", offset = vector.new(1,0,1)},
		{file = schempath.."/schems/pale_oak_tree_2.mts",},
	},
	tree = {
		sunlight_propagates = true,
		tiles = {"pale_oak_log_top.png", "pale_oak_log_top.png","pale_oak_log.png" }
	},
	bark = { tiles = {"pale_oak_log.png"}},
	leaves = {
		tiles = { "pale_oak_leaves.png" },
		--color = "#6a7039",
		paramtype2 = "normal",
	},
	sapling = {
		tiles = {"pale_oak_sapling.png"},
		inventory_image = "pale_oak_sapling.png",
		wield_image = "pale_oak_sapling.png",
	},
	wood = { tiles = {"pale_oak_planks.png"}},
	stripped = {
		tiles = {"stripped_pale_oak_log_top.png", "stripped_pale_oak_log_top.png","stripped_pale_oak_log.png"}
	},
	stripped_bark = {
		tiles = {"stripped_pale_oak_log.png"}
	},
	fence = {
		tiles = { "pale_oak_fence.png" },
	},
	fence_gate = {
		tiles = { "pale_oak_fence_gate.png" },
	},
	door = {
		inventory_image = "pale_oak_door.png",
		tiles_bottom = {"pale_oak_door_bottom.png", "pale_oak_door_bottom.png"},
		tiles_top = {"pale_oak_door_top.png", "pale_oak_door_top.png"}
	},
	trapdoor = {
		tile_front = "pale_oak_trapdoor.png",
		tile_side = "pale_oak_trapdoor_side.png",
		wield_image = "pale_oak_trapdoor.png",
	},
})

minetest.register_node("vlf_pale_garden:pale_moss", {
	description = S("Pale Moss"),
	_doc_items_longdesc = S("Pale Moss is a pale block found in pale gardens"),
	_doc_items_entry_name = "pale_moss",
	_doc_items_hidden = false,
	tiles = {"pale_moss_block.png"},
	groups = {handy=1, hoey=2, dirt=1, soil=1, soil_bamboo=1, soil_sapling=2, soil_sugarcane=1, soil_fungus=1, enderman_takable=1, building_block=1, grass_block_no_snow=1, compostability=65, dig_by_piston=1},
	sounds = mcl_sounds.node_sound_dirt_defaults(),
	_mcl_blast_resistance = 0.1,
	_mcl_hardness = 0.1,
	_on_bone_meal = vlf_pale_garden.bone_meal_moss,
})

-- Define a local for the node and collision box
local pale_moss_box = {
	type = "fixed",
	fixed = {
		{-8/16, -8/16, -8/16, 8/16, -7/16, 8/16},
	},
}

local function register_pale_moss_node(name, description, longdesc, image, mesh, not_in_creative)
	local groups = {handy = 1, carpet = 1, supported_node = 1, deco_block = 1, compostability = 30, dig_by_water = 1, dig_by_piston = 1, moss = 1}
	if not_in_creative then
		groups.not_in_creative_inventory = 1
	end

	minetest.register_node(name, {
		description = S(description),
		_doc_items_longdesc = S(longdesc),
		_doc_items_entry_name = name,
		is_ground_content = false,
		paramtype2 = "4dir",
		tiles = {image},
		wield_image = image,
		wield_scale = {x = 1, y = 1, z = 0.5},
		groups = groups,
		sounds = mcl_sounds.node_sound_wool_defaults(),
		paramtype = "light",
		sunlight_propagates = true,
		drawtype = mesh and "mesh" or "nodebox",
		node_box = not mesh and pale_moss_box or nil,
		mesh = mesh or nil,
		selection_box = pale_moss_box,
		collision_box = pale_moss_box,
		use_texture_alpha = "clip",
		_mcl_hardness = 0.1,
		_mcl_blast_resistance = 0.1,
	})
end

register_pale_moss_node(
	"vlf_pale_garden:pale_moss_carpet_side",
	"Pale Moss Carpet (Side)",
	"Pale Moss carpet growing on the side of a block",
	"pale_vine_side_1.png",
	"pale_vine_side_1.obj",
	true -- Adds "not_in_creative_inventory"
)

register_pale_moss_node(
	"vlf_pale_garden:pale_moss_carpet_side_up",
	"Pale Moss Carpet (Side and Up)",
	"Pale Moss carpet growing on the side of a block and extending upwards",
	"pale_vine_side_2.png",
	"pale_vine_side_2.obj",
	true -- Adds "not_in_creative_inventory"
)

register_pale_moss_node(
	"vlf_pale_garden:pale_moss_carpet_side_tall",
	"Pale Moss Carpet (Side and Tall)",
	"Pale Moss carpet growing on the side of a block and extending upwards over two blocks",
	"pale_vine_d_side_2.png",
	"pale_vine_d_side_2.obj",
	true -- Adds "not_in_creative_inventory"
)

register_pale_moss_node(
	"vlf_pale_garden:pale_moss_carpet_2_side_medium",
	"Pale Moss Carpet (Side and Medium)",
	"Pale Moss carpet growing on the side of a block and extending upwards over two blocks",
	"pale_vine_d_side_1.png",
	"pale_vine_d_side_1.obj",
	true -- Adds "not_in_creative_inventory"
)

minetest.register_node("vlf_pale_garden:pale_moss_carpet", {
	description = S("Pale Moss Carpet"),
	_doc_items_longdesc = S("Pale Moss carpet"),
	_doc_items_entry_name = "pale_moss_carpet",

	is_ground_content = false,
	tiles = {"pale_moss_carpet.png"},
	wield_image = "pale_moss_carpet.png",
	wield_scale = {x = 1, y = 1, z = 0.5},
	groups = {handy = 1, carpet = 1, supported_node = 1, deco_block = 1, compostability = 30, dig_by_water = 1, dig_by_piston = 1, moss = 1},
	sounds = mcl_sounds.node_sound_wool_defaults(),
	paramtype = "light",
	sunlight_propagates = true,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16, -8/16, -8/16, 8/16, -7/16, 8/16},
		},
	},
	use_texture_alpha = "clip",
	_mcl_hardness = 0.1,
	_mcl_blast_resistance = 0.1,

	on_construct = function(pos)
		-- Check the block to the right (+X), left (-X), forward (+Z), and backward (-Z)
		local right_pos = {x = pos.x + 1, y = pos.y, z = pos.z}
		local left_pos = {x = pos.x - 1, y = pos.y, z = pos.z}
		local forward_pos = {x = pos.x, y = pos.y, z = pos.z + 1}
		local backward_pos = {x = pos.x, y = pos.y, z = pos.z - 1}

		local right_node = minetest.get_node(right_pos)
		local left_node = minetest.get_node(left_pos)
		local forward_node = minetest.get_node(forward_pos)
		local backward_node = minetest.get_node(backward_pos)

		local facing_direction = nil
		local air_above = false
		local is_corner = false

		-- Check for blocks on both X and Z coordinates
		local x_block = (right_node.name ~= "air" or left_node.name ~= "air")
		local z_block = (forward_node.name ~= "air" or backward_node.name ~= "air")

		-- Determine the facing direction and check for air above if needed
		if right_node.name ~= "air" and minetest.get_item_group(right_node.name, "moss") == 0 and minetest.get_item_group(right_node.name, "solid") > 0 then
			-- Facing left if there's a block to the right
			facing_direction = {x = -1, z = 0}
			local above_right = {x = right_pos.x, y = right_pos.y + 1, z = right_pos.z}
			if minetest.get_node(above_right).name == "air" then
				air_above = true
			end
		elseif left_node.name ~= "air" and minetest.get_item_group(left_node.name, "moss") == 0 and minetest.get_item_group(left_node.name, "solid") > 0 then
			-- Facing right if there's a block to the left
			facing_direction = {x = 1, z = 0}
			local above_left = {x = left_pos.x, y = left_pos.y + 1, z = left_pos.z}
			if minetest.get_node(above_left).name == "air" then
				air_above = true
			end
		elseif forward_node.name ~= "air" and minetest.get_item_group(forward_node.name, "moss") == 0 and minetest.get_item_group(forward_node.name, "solid") > 0 then
			-- Facing backward if there's a block forward
			facing_direction = {x = 0, z = -1}
			local above_forward = {x = forward_pos.x, y = forward_pos.y + 1, z = forward_pos.z}
			if minetest.get_node(above_forward).name == "air" then
				air_above = true
			end
		elseif backward_node.name ~= "air" and minetest.get_item_group(backward_node.name, "moss") == 0 and minetest.get_item_group(forward_node.name, "solid") > 0 then
			-- Facing forward if there's a block backward
			facing_direction = {x = 0, z = 1}
			local above_backward = {x = backward_pos.x, y = backward_pos.y + 1, z = backward_pos.z}
			if minetest.get_node(above_backward).name == "air" then
				air_above = true
			end
		end

		-- Randomly pick medium or tall variant based on air above and facing direction
		if facing_direction and not is_corner then
			local random_variant
			if air_above then
				-- Only medium if air above
				random_variant = "vlf_pale_garden:pale_moss_carpet_side"
			else
				-- Random between medium and tall if no air
				random_variant = math.random(2) == 1 and "vlf_pale_garden:pale_moss_carpet_side" or "vlf_pale_garden:pale_moss_carpet_side_up"
			end

			-- Set the new variant and ensure the node faces the opposite direction
			minetest.set_node(pos, {
				name = random_variant,
				param2 = minetest.dir_to_facedir(facing_direction)
			})
		end

		-- Set facing direction for corner variants
		if x_block and z_block then
			local corner_facing
			local random_variant
			if right_node.name ~= "air" and forward_node.name ~= "air" and minetest.get_item_group(right_node.name, "moss") == 0 and
			minetest.get_item_group(forward_node.name, "moss") == 0 then
				-- Block is in the bottom-right corner
				corner_facing = minetest.dir_to_facedir({x = 1, z = -1})
			elseif right_node.name ~= "air" and backward_node.name ~= "air" and minetest.get_item_group(right_node.name, "moss") == 0 and
			minetest.get_item_group(backward_node.name, "moss") == 0 then
				-- Block is in the top-right corner
				corner_facing = minetest.dir_to_facedir({x = 1, z = 1})
			elseif left_node.name ~= "air" and forward_node.name ~= "air" and minetest.get_item_group(left_node.name, "moss") == 0 and
			minetest.get_item_group(forward_node.name, "moss") == 0 then
				-- Block is in the bottom-left corner
				corner_facing = minetest.dir_to_facedir({x = -1, z = -1})
			elseif left_node.name ~= "air" and backward_node.name ~= "air" and minetest.get_item_group(left_node.name, "moss") == 0 and
			minetest.get_item_group(backward_node.name, "moss") == 0 then
				-- Block is in the top-left corner
				corner_facing = minetest.dir_to_facedir({x = -1, z = 1})
			end

			if corner_facing then
				random_variant = math.random(2) == 1 and "vlf_pale_garden:pale_moss_carpet_side_tall" or "vlf_pale_garden:pale_moss_carpet_2_side_medium"
				minetest.set_node(pos, {
					name = random_variant,
					param2 = corner_facing
				})
			end
		end
	end
})
minetest.register_alias("mcl_pale_garden:pale_hanging_moss", "vlf_pale_garden:pale_hanging_moss")
minetest.register_alias("mcl_pale_garden:pale_hanging_moss_tip", "vlf_pale_garden:pale_hanging_moss_tip")
minetest.register_alias("mcl_pale_garden:active_creaking_heart", "vlf_pale_garden:active_creaking_heart")
minetest.register_node("vlf_pale_garden:pale_hanging_moss", {
	description = S("Hanging Pale Moss"),
	_doc_items_create_entry = S("Hanging Pale Moss"),
	_doc_items_entry_name = S("Hanging Pale Moss"),
	_doc_items_longdesc = S("Hanging Pale Moss"),
	sunlight_propagates = true,
	light_propagates = true,
	walkable = false,
	_mcl_shears_drop = true,
	_mcl_silk_touch_drop = true,
	drawtype = "plantlike",
	tiles = {"pale_hanging_moss.png"},
	inventory_image = "pale_hanging_moss.png",
	wield_image = "pale_hanging_moss.png",
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}
		},
	},
	groups = {handy=1, plant=1, vinelike_node=2, dig_by_water=1, destroy_by_lava_flow=1, dig_by_piston=1},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_blast_resistance = 0,
	_mcl_blast_hardness = 0,
	drop = "",
})

minetest.register_node("vlf_pale_garden:pale_hanging_moss_tip", {
	description = S("Hanging Pale Moss"),
	_doc_items_create_entry = S("Hanging Pale Moss"),
	_doc_items_entry_name = S("Hanging Pale Moss"),
	_doc_items_longdesc = S("Hanging Pale Moss"),
	sunlight_propagates = true,
	light_propagates = true,
	walkable = false,
	_mcl_shears_drop = true,
	_mcl_silk_touch_drop = true,
	drawtype = "plantlike",
	tiles = {"pale_hanging_moss_tip.png"},
	inventory_image = "pale_hanging_moss_tip.png",
	wield_image = "pale_hanging_moss_tip.png",
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}
	},
	groups = {handy = 1, plant = 1, vinelike_node = 2, dig_by_water = 1, destroy_by_lava_flow = 1, dig_by_piston = 1},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_blast_resistance = 0,
	_mcl_blast_hardness = 0,
	drop = "",
	on_construct = function(pos)
		-- Get the position of the node above
		local above_pos = {x = pos.x, y = pos.y + 1, z = pos.z}
		local above_node = minetest.get_node(above_pos)

		-- Check if the node above has the same base name but without "tip"
		if above_node and above_node.name:find("vlf_pale_garden:pale_hanging_moss_tip") then
			-- Set the node above to the same name as the current one, but without "tip"
			minetest.swap_node(above_pos, {name = "vlf_pale_garden:pale_hanging_moss"})
		end
	end,

	on_destruct = function(pos)
		-- Get the position of the node above
		local above_pos = {x = pos.x, y = pos.y + 1, z = pos.z}
		local above_node = minetest.get_node(above_pos)

		-- Check if the node above is a "non-tip" moss block and change it back to "tip"
		if above_node and above_node.name == "vlf_pale_garden:pale_hanging_moss" then
			minetest.swap_node(above_pos, {name = "vlf_pale_garden:pale_hanging_moss_tip"})
		end
	end,
	_on_bone_meal = function(itemstack, placer, pointed_thing, pos)
		minetest.swap_node(pos,{name="vlf_pale_garden:pale_hanging_moss"})
		local pos_below = {x=pos.x, y=pos.y-1, z=pos.z}
		minetest.set_node(pos_below,{name="vlf_pale_garden:pale_hanging_moss_tip"})
		return true
	end,
})

minetest.register_abm({
    label = "Convert non-tip vine to tip",
    nodenames = {"vlf_pale_garden:pale_hanging_moss"},
    interval = 2,
    chance = 1,

    action = function(pos, node)
        local below_pos = {x = pos.x, y = pos.y - 1, z = pos.z}
        local below_node = minetest.get_node(below_pos)

	if below_node.name == "air" or
           (below_node.name ~= "vlf_pale_garden:pale_hanging_moss" and
            below_node.name ~= "vlf_pale_garden:pale_hanging_moss_tip") then
		minetest.set_node(pos, {name = "vlf_pale_garden:pale_hanging_moss_tip"})
        end
    end
})

minetest.register_abm({
    label = "Convert tip vine to non-tip",
    nodenames = {"vlf_pale_garden:pale_hanging_moss_tip"},
    interval = 2,
    chance = 1,

    action = function(pos, node)
        local below_pos = {x = pos.x, y = pos.y - 1, z = pos.z}
        local below_node = minetest.get_node(below_pos)

        if below_node.name == "vlf_pale_garden:pale_hanging_moss" or below_node.name == "vlf_pale_garden:pale_hanging_moss_tip" then
		minetest.set_node(pos, {name = "vlf_pale_garden:pale_hanging_moss"})
        end
    end
})

minetest.register_node("vlf_pale_garden:inactive_creaking_heart", {
	description = S("Creaking Heart"),
	_doc_items_hidden = false,
	paramtype2 = "facedir",
	tiles = {"creaking_heart_top.png", "creaking_heart_top.png","creaking_heart.png"},
	groups = {
		handy = 1, axey = 1,
		building_block = 1,
		tree = 1, material_wood=1,
		flammable = 3, fire_encouragement=5, fire_flammability=20,
	},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	on_place = mcl_util.rotate_axis,
	on_rotate = screwdriver.rotate_3way,
	_mcl_blast_resistance = 2,
	_mcl_hardness = 2,
})

local function check_creaking_heart_activation(pos)
    local node = minetest.get_node(pos)
    local facedir = node.param2

    local left_pos = {x = pos.x - 1, y = pos.y, z = pos.z}
    local right_pos = {x = pos.x + 1, y = pos.y, z = pos.z}
    local above_pos = {x = pos.x, y = pos.y + 1, z = pos.z}
    local below_pos = {x = pos.x, y = pos.y - 1, z = pos.z}
    local front_pos = {x = pos.x, y = pos.y, z = pos.z + 1}
    local back_pos = {x = pos.x, y = pos.y, z = pos.z - 1}

    local left_node = minetest.get_node(left_pos)
    local right_node = minetest.get_node(right_pos)
    local above_node = minetest.get_node(above_pos)
    local below_node = minetest.get_node(below_pos)
    local front_node = minetest.get_node(front_pos)
    local back_node = minetest.get_node(back_pos)

    -- Table of valid block names for comparison
    local valid_blocks = {
        ["mcl_trees:tree_pale_oak"] = true,
        ["mcl_trees:stripped_pale_oak"] = true,
        ["mcl_trees:bark_stripped_pale_oak"] = true,
        ["mcl_trees:bark_pale_oak"] = true
    }

    -- Check left and right nodes
    if valid_blocks[left_node.name] and valid_blocks[right_node.name] then
        if left_node.param2 == facedir and right_node.param2 == facedir then
            return true
        end
    end

    -- Check above and below nodes
    if valid_blocks[above_node.name] and valid_blocks[below_node.name] then
        if above_node.param2 == facedir and below_node.param2 == facedir then
            return true
        end
    end

    -- Check above and below nodes
    if valid_blocks[front_node.name] and valid_blocks[back_node.name] then
        if front_node.param2 == facedir and back_node.param2 == facedir then
            return true
        end
    end

    return false
end

minetest.register_abm({
    label = "Check Creaking Heart Activation",
    nodenames = {"vlf_pale_garden:inactive_creaking_heart"},
    interval = 2,
    chance = 1,
    action = function(pos, node)
        if check_creaking_heart_activation(pos) then
            minetest.set_node(pos, {name = "vlf_pale_garden:active_creaking_heart", param2 = node.param2})
        end
    end
})

minetest.register_node("vlf_pale_garden:active_creaking_heart", {
	description = S("Creaking Heart"),
	_doc_items_hidden = false,
	paramtype2 = "facedir",
	tiles = {"creaking_heart_top_active.png", "creaking_heart_top_active.png","creaking_heart_active.png"},
	groups = {
		handy = 1, axey = 1,
		building_block = 1,
		tree = 1, material_wood=1,
		flammable = 3, fire_encouragement=5, fire_flammability=20,
	},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	on_place = mcl_util.rotate_axis,
	on_rotate = screwdriver.rotate_3way,
	_mcl_blast_resistance = 2,
	_mcl_hardness = 2,
	on_dig = function(pos, node, digger)
	-- Remove the creaking mob whose heart position matches the block
	for _, object in pairs(minetest.get_objects_inside_radius(pos, 32)) do
		local lua_entity = object:get_luaentity()
		if lua_entity and lua_entity.name == "vlf_pale_garden:creaking_transient" and lua_entity._heart_pos and vector.equals(lua_entity._heart_pos, pos) then
			minetest.add_particlespawner({
				amount = 20, -- Number of particles
				time = 1.5, -- Duration of the spawner
				minpos = vector.subtract(lua_entity.object:get_pos(), {x = 0.5, y = 1.5, z = 0.5}),
				maxpos = vector.add(lua_entity.object:get_pos(), {x = 0.5, y = 2.5, z = 0.5}),
				minvel = {x = -0.5, y = -2, z = -0.5}, -- Particles only fall downwards
				maxvel = {x = 0.5, y = -4, z = 0.5},  -- Downward velocity range
				minacc = {x = 0, y = -7.81, z = 0}, -- Gravity effect pulling particles down
				maxacc = {x = 0, y = -7.81, z = 0},
				minexptime = 0.5, -- Minimum lifetime of particles
				maxexptime = 1, -- Maximum lifetime of particles
				minsize = 1, -- Minimum size of particles
				maxsize = 3, -- Maximum size of particles
				texture = "tree_creak_particle.png", -- Particle texture
				glow = 0, -- Glow effect (optional)
			})
			object:remove()
			-- Particle spawner to simulate tree-like creaking falling apart
		end
	end
	minetest.node_dig(pos, node, digger)
end,

})

minetest.register_abm({
	label = "Creaking Heart Mob Spawner",
	nodenames = {"vlf_pale_garden:active_creaking_heart"},
	interval = 2,
	chance = 1,
	action = function(pos, node)
		-- Get current time of day
		local time_of_day = minetest.get_timeofday()
		local meta = minetest.get_meta(pos)
		local has_spawned = meta:get_int("creaking_spawned") == 1

		-- Only attempt to spawn if it's night and a mob hasn't already spawned
		if (time_of_day >= 0.8 or time_of_day <= 0.2) and not has_spawned then
			local spawn_pos = nil

			for dy = 0, -10, -1 do
				for dx = -5, 5 do
					for dz = -5, 5 do
						if math.abs(dx) + math.abs(dz) <= 5 then
							local check_pos = {x = pos.x + dx, y = pos.y + dy, z = pos.z + dz}
							local node_below = minetest.get_node(check_pos)
							local node_above_pos = {x = check_pos.x, y = check_pos.y + 1, z = check_pos.z}
							local node_above = minetest.get_node(node_above_pos)
							local node_below_def = minetest.registered_nodes[node_below.name]
							if node_below_def and node_below_def.walkable and minetest.get_item_group(node_below.name, "solid") > 0
							and node_above.name == "air" then
								spawn_pos = node_above_pos
								break
							end
						end
					end
				end
			end

			-- If a valid spawn position was found, spawn the mob and mark it as spawned
			if spawn_pos and not minetest.is_protected(spawn_pos, "") then
				local mob = mcl_mobs.spawn(spawn_pos, "vlf_pale_garden:creaking_transient")
				if mob then
					local lua_entity = mob:get_luaentity()
					if lua_entity then
						lua_entity._heart_pos = pos
						lua_entity.spawn_from_heart = true

						-- Particle effect
						local amount = 6
						local name = "mcl_particles_generic.png^[colorize:#A0A0A0:255"
						for _, pl in pairs(minetest.get_connected_players()) do
							if vector.distance(pos, pl:get_pos()) < PARTICLE_DISTANCE then
								table.insert(spawn_particlespawner.texpool, {
									name = name,
									animation = {type = "vertical_frames", aspect_w = 8, aspect_h = 8, length = 1.9},
								})
								minetest.add_particlespawner(table.merge(spawn_particlespawner, {
									amount = amount,
									minpos = vector.subtract(lua_entity.object:get_pos(), {x = 0.5, y = 0.5, z = 0.5}),
									maxpos = vector.add(lua_entity.object:get_pos(), {x = 0.5, y = 1.5, z = 0.5}),
									playername = pl:get_player_name(),
								}))
							end
						end
					end
					-- Mark that a mob has been spawned this night
					meta:set_int("creaking_spawned", 1)
				end
			end
		elseif time_of_day > 0.2 and time_of_day < 0.8 and has_spawned then
			-- Remove existing "creaking" mobs that match the heart position if day
			meta:set_int("creaking_spawned", 0)
			for _, object in pairs(minetest.get_objects_inside_radius(pos, 32)) do
				local lua_entity = object:get_luaentity()
				if lua_entity and lua_entity.name == "vlf_pale_garden:creaking_transient" and lua_entity._heart_pos and vector.equals(lua_entity._heart_pos, pos) then
					local amount = 6
					local name = "mcl_particles_generic.png^[colorize:#A0A0A0:255"
					for _, pl in pairs(minetest.get_connected_players()) do
						if vector.distance(pos, pl:get_pos()) < PARTICLE_DISTANCE then
							table.insert(spawn_particlespawner.texpool, {
								name = name,
								animation = {type = "vertical_frames", aspect_w = 8, aspect_h = 8, length = 1.9},
							})
							minetest.add_particlespawner(table.merge(spawn_particlespawner, {
								amount = amount,
								minpos = vector.subtract(lua_entity.object:get_pos(), {x = 0.5, y = 0.5, z = 0.5}),
								maxpos = vector.add(lua_entity.object:get_pos(), {x = 0.5, y = 1.5, z = 0.5}),
								playername = pl:get_player_name(),
							}))
						end
					end
					object:remove()
				end
			end
		end
	end,
})

minetest.register_node("vlf_pale_garden:closed_eyeblossom", {
	description = S("Closed Eyeblossom"),
	drawtype = "plantlike",
	waving = 1,
	tiles = { "eyeblossom_stem.png^closed_eyeblossom.png" },
	inventory_image = "eyeblossom_stem.png^closed_eyeblossom.png",
	wield_image = "eyeblossom_stem.png^closed_eyeblossom.png",
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
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	node_placement_prediction = "",
	on_place = mcl_flowers.on_place_flower,
	selection_box = {
		type = "fixed",
		fixed = { -5/16, -0.5, -5/16, 5/16, 5/16, 5/16 },
	},
	--_mcl_silk_touch_drop = ,
	_on_bone_meal = mcl_flowers.on_bone_meal_simple,
})
mcl_flowerpots.register_potted_flower("vlf_pale_garden:closed_eyeblossom", {
	name = "closed_eyeblossom",
	desc = S("Closed Eyeblossom"),
	image = "(eyeblossom_stem.png^closed_eyeblossom.png)",
})

minetest.register_node("vlf_pale_garden:open_eyeblossom", {
	description = S("Open Eyeblossom"),
	drawtype = "plantlike",
	waving = 1,
	tiles = { "eyeblossom_stem.png^open_eyeblossom.png" },
	inventory_image = "eyeblossom_stem.png^open_eyeblossom.png^open_eyeblossom_emissive.png",
	wield_image = "eyeblossom_stem.png^open_eyeblossom.png^open_eyeblossom_emissive.png",
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
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	node_placement_prediction = "",
	on_place = mcl_flowers.on_place_flower,
	selection_box = {
		type = "fixed",
		fixed = { -5/16, -0.5, -5/16, 5/16, 5/16, 5/16 },
	},
	--_mcl_silk_touch_drop = ,
	_on_bone_meal = mcl_flowers.on_bone_meal_simple,
	on_construct = function(pos)
		minetest.add_entity(pos, "vlf_pale_garden:eyeblossom_emissive")
        end,
})
mcl_flowerpots.register_potted_flower("vlf_pale_garden:open_eyeblossom", {
	name = "open_eyeblossom",
	desc = S("Open Eyeblossom"),
	image = "(eyeblossom_stem.png^open_eyeblossom.png)",
	on_construct = function(pos)
		minetest.add_entity(pos, "vlf_pale_garden:eyeblossom_pot_emissive")
        end,
})

-- Register an ABM to check for eyeblossom entities
minetest.register_abm({
    label = "Add missing eyeblossom entities to flowerpots",
    nodenames = {"mcl_flowerpots:flower_pot_open_eyeblossom"},
    interval = 2, -- Frequency of the check (in seconds)
    chance = 1, -- Apply the ABM to all matching nodes

    action = function(pos, node)
        -- Check for existing eyeblossom entities at this position
        local objects = minetest.get_objects_inside_radius(pos, 0.5)
        local entity_present = false

        for _, obj in ipairs(objects) do
            if obj:get_luaentity() and obj:get_luaentity().name == "vlf_pale_garden:eyeblossom_pot_emissive" then
                entity_present = true
                break
            end
        end
	local f_pos = {x=pos.x, y=pos.y+0.23, z=pos.z}
        -- If the entity is not present, add it
        if not entity_present then
            minetest.add_entity(f_pos, "vlf_pale_garden:eyeblossom_pot_emissive")
        end
    end,
})

-- Register the glowing add-on entity
    minetest.register_entity("vlf_pale_garden:eyeblossom_emissive", {
    initial_properties = {
		pointable = false,
		visual = "mesh",
		mesh = "plantlike.obj",
		visual_size = {x = 10, y = 10},
		textures = {"open_eyeblossom_emissive.png"},
		glow = 15,
	},
        on_step = function(self, dtime)
            local pos = self.object:get_pos()
            local node = minetest.get_node(pos)
            if node.name ~= "vlf_pale_garden:open_eyeblossom" then
                self.object:remove()
                return
            end
        end,
    })
minetest.register_entity("vlf_pale_garden:eyeblossom_pot_emissive", {
	initial_properties = {
		pointable = false,
		visual = "mesh",
		mesh = "plantlike.obj",
		visual_size = {x = 10, y = 10},
		textures = { "open_eyeblossom_emissive.png" },
		glow = 15,
	},
        on_step = function(self, dtime)
            local pos = self.object:get_pos()
            local node = minetest.get_node(pos)
            if node.name ~= "mcl_flowerpots:flower_pot_open_eyeblossom" then
                self.object:remove()
                return
            end
        end,
})

minetest.register_abm({
    label = "Bloom closed eyeblossoms",
    nodenames = {"vlf_pale_garden:closed_eyeblossom"},
    interval = 5, -- Frequency of the check (in seconds)
    chance = 1, -- Apply the ABM to all matching nodes

    action = function(pos, node)
        -- Check the game time
        local time_of_day = minetest.get_timeofday()
        if time_of_day <= 0.8 and time_of_day >= 0.2 then
            return
        end

        -- Find all closed eyeblossoms within a 10-block radius
        local positions = minetest.find_nodes_in_area(
            vector.subtract(pos, 10),
            vector.add(pos, 10),
            {"vlf_pale_garden:closed_eyeblossom"}
        )

        if #positions > 0 then
            -- Pick a random closed eyeblossom to bloom
            local random_pos = positions[math.random(1, #positions)]
            minetest.set_node(random_pos, {name = "vlf_pale_garden:open_eyeblossom"})

            -- Trigger surrounding closed eyeblossoms to slowly bloom
            minetest.after(5, function()
                local neighbors = minetest.find_nodes_in_area(
                    vector.subtract(random_pos, 3),
                    vector.add(random_pos, 3),
                    {"vlf_pale_garden:closed_eyeblossom"}
                )

                for _, neighbor_pos in ipairs(neighbors) do
                    minetest.after(math.random(1, 2), function()
                        minetest.set_node(neighbor_pos, {name = "vlf_pale_garden:open_eyeblossom"})
                    end)
                end
            end)
        end
    end,
})

minetest.register_abm({
    label = "Bloom closed eyeblossoms",
    nodenames = {"vlf_pale_garden:open_eyeblossom"},
    interval = 5, -- Frequency of the check (in seconds)
    chance = 1, -- Apply the ABM to all matching nodes

    action = function(pos, node)
        -- Check the game time
        local time_of_day = minetest.get_timeofday()
        if time_of_day > 0.2 and time_of_day < 0.8 then
            --return
        --end

        -- Find all closed eyeblossoms within a 10-block radius
        local positions = minetest.find_nodes_in_area(
            vector.subtract(pos, 10),
            vector.add(pos, 10),
            {"vlf_pale_garden:open_eyeblossom"}
        )

        if #positions > 0 then
            -- Pick a random closed eyeblossom to bloom
            local random_pos = positions[math.random(1, #positions)]
            minetest.set_node(random_pos, {name = "vlf_pale_garden:closed_eyeblossom"})

            -- Trigger surrounding closed eyeblossoms to slowly bloom
            minetest.after(5, function()
                local neighbors = minetest.find_nodes_in_area(
                    vector.subtract(random_pos, 3),
                    vector.add(random_pos, 3),
                    {"vlf_pale_garden:open_eyeblossom"}
                )

                for _, neighbor_pos in ipairs(neighbors) do
                    minetest.after(math.random(1, 2), function()
                        minetest.set_node(neighbor_pos, {name = "vlf_pale_garden:closed_eyeblossom"})
                    end)
                end
            end)
        end
        end
    end,
})
