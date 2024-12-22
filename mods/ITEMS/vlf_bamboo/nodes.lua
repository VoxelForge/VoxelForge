local S = minetest.get_translator("vlf_bamboo")
local SCAFFOLD_HEIGHT_LIMIT = 320

vlf_bamboo.bamboo_itemstrings = {
	"vlf_bamboo:bamboo",
	"vlf_bamboo:bamboo_1",
	"vlf_bamboo:bamboo_2",
	"vlf_bamboo:bamboo_3",
}

local boxes = {
	{-0.175, -0.5, -0.195, 0.05, 0.5, 0.030},
	{-0.05, -0.5, 0.285, -0.275, 0.5, 0.06},
	{0.25, -0.5, 0.325, 0.025, 0.5, 0.100},
	{-0.125, -0.5, 0.125, -0.3125, 0.5, 0.3125},
}

function vlf_bamboo.grow(pos)
	local pr = PseudoRandom(minetest.hash_node_position(pos))
	local max_height = pr:next(12,16)
	local bottom = vlf_util.traverse_tower(pos,-1)
	local top,h = vlf_util.traverse_tower(bottom,1)
	if h < max_height then
		local n = minetest.get_node(pos)
		if minetest.get_node(vector.offset(top,0,1,0)).name ~= "air" then return end
		minetest.set_node(vector.offset(top,0,1,0),n)
	end
end

local bamboo_def = {
	description = S("Bamboo"),
	tiles = {"vlf_bamboo_bamboo_bottom.png", "vlf_bamboo_bamboo_bottom.png", "vlf_bamboo_bamboo.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "4dir",
	use_texture_alpha = "clip",
	groups = {handy = 1, axey = 1, choppy = 1, dig_by_piston = 1, plant = 1, non_mycelium_plant = 1, flammable = 3, bamboo = 1, bamboo_tree = 1, vinelike_node = 1, unsticky = 1, _vlf_partial = 2,},
	sounds = vlf_sounds.node_sound_wood_defaults(),
	drop = "vlf_bamboo:bamboo",
	inventory_image = "vlf_bamboo_bamboo_shoot.png",
	wield_image = "vlf_bamboo_bamboo_shoot.png",
	_vlf_burntime = 2.5,
	_vlf_blast_resistance = 1,
	_vlf_hardness = 1.5,
	node_placement_prediction = "",
	on_place = vlf_util.generate_on_place_plant_function(function(pos)
		local node_below = minetest.get_node(vector.offset(pos,0,-1,0))
		local bamboo_below = minetest.get_item_group(node_below.name, "bamboo_tree") > 0
		return (minetest.get_item_group(node_below.name, "soil_bamboo") > 0 or bamboo_below),(bamboo_below and node_below.param2 or math.random(0,3))
	end),
	after_place_node  = function(pos)
		local node = minetest.get_node(pos)
		local node_below = minetest.get_node(vector.offset(pos,0,-1,0))
		if minetest.get_item_group(node_below.name, "bamboo_tree") > 0 then
			node = node_below
		else
			node.name = vlf_bamboo.bamboo_itemstrings[math.random(#vlf_bamboo.bamboo_itemstrings)]
		end
		minetest.swap_node(pos,node)
	end,
	_on_bone_meal = function(_, _, _, pos)
		return vlf_bamboo.grow(pos)
	end,
}

for i,it in pairs(vlf_bamboo.bamboo_itemstrings) do
	local d = table.copy(bamboo_def)
	if it ~= "vlf_bamboo:bamboo" then
		table.update(d, {groups = table.merge(bamboo_def.groups, {not_in_creative_inventory = 1})})
	end
	table.update(d,{
		node_box = {
			type = "fixed",
			fixed = {
				boxes[i],
			}
		},
		collision_box = {
			type = "fixed",
			fixed = {
				boxes[i],
			}
		},
		selection_box = {
			type = "fixed",
			fixed = {
				boxes[i],
			}
		},
	})
	minetest.register_node(it,d)
end

vlf_flowerpots.register_potted_flower("vlf_bamboo:bamboo", {
	name = "bamboo",
	desc = S("Bamboo Plant"),
	image = "vlf_bamboo_flower_pot.png",
})

local bamboo_top = table.copy(bamboo_def)
table.update(bamboo_top,{
	groups = {not_in_creative_inventory = 1, handy = 1, axey = 1, choppy = 1, flammable = 3, vinelike_node = 1, unsticky = 1},
	nodebox = nil,
	selection_box = nil,
	collision_box = nil,
	drawtype = "plantlike",
	tiles = {"vlf_bamboo_endcap.png"},
	on_place = nil,
	_on_bone_meal = nil,
})

minetest.register_node("vlf_bamboo:bamboo_endcap", bamboo_top)


minetest.register_node("vlf_bamboo:bamboo_mosaic",  {
	description = S("Bamboo Mosaic Plank"),
	_doc_items_longdesc = S("Bamboo Mosaic Plank"),
	_doc_items_hidden = false,
	tiles = {"vlf_bamboo_bamboo_plank_mosaic.png"},
	is_ground_content = false,
	groups = {handy = 1, axey = 1, building_block = 1, flammable = 3, fire_encouragement = 5, fire_flammability = 20},
	sounds = vlf_sounds.node_sound_wood_defaults(),
	_vlf_blast_resistance = 3,
	_vlf_hardness = 2,
	_vlf_burntime = 15
})

local adjacents = {
	vector.new(0,0,1),
	vector.new(0,0,-1),
	vector.new(1,0,0),
	vector.new(-1,0,0),
}

local allowed_base_groups = { "solid", "slab_top" }

local function can_place_on(node)
	local def = minetest.registered_nodes[node.name]

	if not def then
		return false
	end

	for _, j in pairs(allowed_base_groups) do
		if minetest.get_item_group(node.name, j) > 0 then
			return true
		end
	end

	return false
end

minetest.register_node("vlf_bamboo:scaffolding", {
	description = S("Scaffolding"),
	doc_items_longdesc = S("Scaffolding is a temporary structure to easily climb up while building that is easily removed"),
	doc_items_hidden = false,
	tiles = {"vlf_bamboo_scaffolding_top.png","vlf_bamboo_scaffolding_side.png","vlf_bamboo_scaffolding_bottom.png"},
	drawtype = "nodebox",
	paramtype = "light",
	use_texture_alpha = "clip",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, 0.375, -0.5, 0.5, 0.5, 0.5},
			{-0.5, -0.5, -0.5, -0.375, 0.5, -0.375},
			{0.375, -0.5, -0.5, 0.5, 0.5, -0.375},
			{0.375, -0.5, 0.375, 0.5, 0.5, 0.5},
			{-0.5, -0.5, 0.375, -0.375, 0.5, 0.5},
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
		},
	},
	is_ground_content = false,
	walkable = false,
	climbable = true,
	physical = true,
	node_placement_prediction = "",
	groups = { handy=1, axey=1, flammable=3, deco_block=1, material_wood=1, fire_encouragement=5, fire_flammability=60, falling_node = 1, stack_falling = 1, scaffolding = 1, dig_by_piston = 1, unsticky = 1},
	sounds = vlf_sounds.node_sound_wood_defaults(),
	_vlf_blast_resistance = 0,
	_vlf_hardness = 0,
	_vlf_burntime = 2.5,
	on_place = function(itemstack, placer, ptd)
		if not placer or not placer:is_player() then
			return itemstack
		end

		local ctrl = placer:get_player_control()
		local rc = vlf_util.call_on_rightclick(itemstack, placer, ptd)
		if rc then return rc end
		if not ptd then return end
		local node = minetest.get_node(ptd.under)

		if minetest.get_item_group(node.name,"scaffolding") > 0 and ctrl and ctrl.sneak then -- count param2 up when placing to the sides. Fall when > 6
			local pp2 = node.param2
			local np2 = pp2 + 1
			if minetest.get_node(vector.offset(ptd.above,0,-1,0)).name == "air" and minetest.get_node(ptd.above).name == "air" then
				itemstack = vlf_util.safe_place(ptd.above,{name = "vlf_bamboo:scaffolding_horizontal",param2 = np2}, placer, itemstack) or itemstack
			end
			if np2 > 6 then
				minetest.check_single_for_falling(ptd.above)
			end
		elseif node.name == "vlf_bamboo:scaffolding" then --tower up
			local bottom = vlf_util.traverse_tower(ptd.under,-1)
			local top,h = vlf_util.traverse_tower(bottom,1)
			local ppos = vector.offset(top,0,1,0)
			if h <= SCAFFOLD_HEIGHT_LIMIT and can_place_on(minetest.get_node(vector.offset(bottom,0,-1,0))) and minetest.get_node(ppos).name == "air" then
				itemstack = vlf_util.safe_place(ppos, node, placer, itemstack) or itemstack
			end

		elseif can_place_on(node) and minetest.get_node(ptd.above).name == "air" then
			itemstack = vlf_util.safe_place(ptd.above, {name = "vlf_bamboo:scaffolding"}, placer, itemstack) or itemstack
			minetest.check_single_for_falling(ptd.above)
		end
		return itemstack
	end,
	after_dig_node = function(pos, _, _, digger)
		vlf_util.traverse_tower(vector.offset(pos,0,1,0),1,function(pos, _, node)
			if node.name ~= "vlf_bamboo:scaffolding" then return true end
			if vlf_util.safe_place(pos, {name = "air"}, digger) then
				if not minetest.is_creative_enabled(digger:get_player_name()) then
					minetest.add_item(pos,"vlf_bamboo:scaffolding")
				end
				for _,v in pairs(adjacents) do
					minetest.check_for_falling(vector.add(pos,v))
				end
			end
		end)
	end,
	_vlf_after_falling = function(pos, _)
		if minetest.get_node(pos).name == "vlf_bamboo:scaffolding" then
			vlf_util.safe_place(pos,{name = "vlf_bamboo:scaffolding"})
		end
	end,
})

minetest.register_node("vlf_bamboo:scaffolding_horizontal", {
	description = S("Scaffolding horizontal"),
	doc_items_longdesc = S("Scaffolding block..."),
	doc_items_hidden = false,
	tiles = {"vlf_bamboo_scaffolding_side.png","vlf_bamboo_scaffolding_top.png","vlf_bamboo_scaffolding_bottom.png"},
	drawtype = "nodebox",
	paramtype = "light",
	use_texture_alpha = "clip",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, 0.375, -0.5, 0.5, 0.5, 0.5},
			{-0.5, -0.5, -0.5, -0.375, 0.5, -0.375},
			{0.375, -0.5, -0.5, 0.5, 0.5, -0.375},
			{0.375, -0.5, 0.375, 0.5, 0.5, 0.5},
			{-0.5, -0.5, 0.375, -0.375, 0.5, 0.5},
			{-0.5, -0.5, -0.5, 0.5, -0.375, 0.5},
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
		},
	},
	groups = { handy=1, axey=1, flammable=3, building_block=1, material_wood=1, fire_encouragement=5, fire_flammability=60, not_in_creative_inventory = 1, falling_node = 1, scaffolding = 1 },
	_vlf_after_falling = function(pos)
		if minetest.get_node(pos).name == "vlf_bamboo:scaffolding_horizontal" then
			local above = vector.offset(pos,0,1,0)
			if minetest.get_node(pos).name ~= "vlf_bamboo:scaffolding" then
				vlf_util.safe_place(pos, {name = "air"})
				minetest.add_item(pos,"vlf_bamboo:scaffolding")
			elseif minetest.get_node(above).name == "air" then
				vlf_util.safe_place(above, {name = "vlf_bamboo:scaffolding"})
			end
		end
	end
})
