local S = minetest.get_translator("vlc_bamboo")
local SCAFFOLD_HEIGHT_LIMIT = 320

vlc_bamboo.bamboo_itemstrings = {
	"vlc_bamboo:bamboo",
	"vlc_bamboo:bamboo_1",
	"vlc_bamboo:bamboo_2",
	"vlc_bamboo:bamboo_3",
}

local boxes = {
	{-0.175, -0.5, -0.195, 0.05, 0.5, 0.030},
	{-0.05, -0.5, 0.285, -0.275, 0.5, 0.06},
	{0.25, -0.5, 0.325, 0.025, 0.5, 0.100},
	{-0.125, -0.5, 0.125, -0.3125, 0.5, 0.3125},
}

function vlc_bamboo.grow(pos)
	local pr = PseudoRandom(minetest.hash_node_position(pos))
	local max_height = pr:next(12,16)
	local bottom = vlc_util.traverse_tower(pos,-1)
	local top,h = vlc_util.traverse_tower(bottom,1)
	if h < max_height then
		local n = minetest.get_node(pos)
		if minetest.get_node(vector.offset(top,0,1,0)).name ~= "air" then return end
		minetest.set_node(vector.offset(top,0,1,0),n)
	end
end

local bamboo_def = {
	description = S("Bamboo"),
	tiles = {"vlc_bamboo_bamboo_bottom.png", "vlc_bamboo_bamboo_bottom.png", "vlc_bamboo_bamboo.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "4dir",
	use_texture_alpha = "clip",
	groups = {handy = 1, axey = 1, choppy = 1, dig_by_piston = 1, plant = 1, non_mycelium_plant = 1, flammable = 3, bamboo = 1, bamboo_tree = 1, vinelike_node = 1},
	sounds = vlc_sounds.node_sound_wood_defaults(),
	drop = "vlc_bamboo:bamboo",
	inventory_image = "vlc_bamboo_bamboo_shoot.png",
	wield_image = "vlc_bamboo_bamboo_shoot.png",
	_vlc_blast_resistance = 1,
	_vlc_hardness = 1.5,
	node_placement_prediction = "",
	on_place = vlc_util.generate_on_place_plant_function(function(pos, node)
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
			node.name = vlc_bamboo.bamboo_itemstrings[math.random(#vlc_bamboo.bamboo_itemstrings)]
		end
		minetest.swap_node(pos,node)
	end,
	_on_bone_meal = function(itemstack,placer,pointed_thing,pos,node)
		return vlc_bamboo.grow(pos)
	end,
}

for i,it in pairs(vlc_bamboo.bamboo_itemstrings) do
	local d = table.copy(bamboo_def)
	if it ~= "vlc_bamboo:bamboo" then
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

vlc_flowerpots.register_potted_flower("vlc_bamboo:bamboo", {
	name = "bamboo",
	desc = S("Bamboo Plant"),
	image = "vlc_bamboo_flower_pot.png",
})

local bamboo_top = table.copy(bamboo_def)
table.update(bamboo_top,{
	groups = {not_in_creative_inventory = 1, handy = 1, axey = 1, choppy = 1, flammable = 3, vinelike_node = 1},
	nodebox = nil,
	selection_box = nil,
	collision_box = nil,
	drawtype = "plantlike",
	tiles = {"vlc_bamboo_endcap.png"},
	on_place = nil,
	_on_bone_meal = nil,
})

minetest.register_node("vlc_bamboo:bamboo_endcap", bamboo_top)


minetest.register_node("vlc_bamboo:bamboo_mosaic",  {
	description = S("Bamboo Mosaic Plank"),
	_doc_items_longdesc = S("Bamboo Mosaic Plank"),
	_doc_items_hidden = false,
	tiles = {"vlc_bamboo_bamboo_plank_mosaic.png"},
	is_ground_content = false,
	groups = {handy = 1, axey = 1, flammable = 3, fire_encouragement = 5, fire_flammability = 20},
	sounds = vlc_sounds.node_sound_wood_defaults(),
	_vlc_blast_resistance = 3,
	_vlc_hardness = 2,
})

local adjacents = {
	vector.new(0,0,1),
	vector.new(0,0,-1),
	vector.new(1,0,0),
	vector.new(-1,0,0),
}

minetest.register_node("vlc_bamboo:scaffolding", {
	description = S("Scaffolding"),
	doc_items_longdesc = S("Scaffolding is a temporary structure to easily climb up while building that is easily removed"),
	doc_items_hidden = false,
	tiles = {"vlc_bamboo_scaffolding_top.png","vlc_bamboo_scaffolding_side.png","vlc_bamboo_scaffolding_bottom.png"},
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
	groups = { handy=1, axey=1, flammable=3, building_block=1, material_wood=1, fire_encouragement=5, fire_flammability=60, falling_node = 1, stack_falling = 1, scaffolding = 1 },
	sounds = vlc_sounds.node_sound_wood_defaults(),
	_vlc_blast_resistance = 0,
	_vlc_hardness = 0,
	on_place = function(itemstack, placer, ptd)
		if not placer or not placer:is_player() then
			return itemstack
		end

		local ctrl = placer:get_player_control()
		local rc = vlc_util.call_on_rightclick(itemstack, placer, ptd)
		if rc then return rc end
		if not ptd then return end
		local node = minetest.get_node(ptd.under)

		if minetest.get_item_group(node.name,"scaffolding") > 0 and ctrl and ctrl.sneak then -- count param2 up when placing to the sides. Fall when > 6
			local pp2 = node.param2
			local np2 = pp2 + 1
			if minetest.get_node(vector.offset(ptd.above,0,-1,0)).name == "air" and minetest.get_node(ptd.above).name == "air" then
				itemstack = vlc_util.safe_place(ptd.above,{name = "vlc_bamboo:scaffolding_horizontal",param2 = np2}, placer, itemstack) or itemstack
			end
			if np2 > 6 then
				minetest.check_single_for_falling(ptd.above)
			end
		elseif node.name == "vlc_bamboo:scaffolding" then --tower up
			local bottom = vlc_util.traverse_tower(ptd.under,-1)
			local top,h = vlc_util.traverse_tower(bottom,1)
			local ppos = vector.offset(top,0,1,0)
			if h <= SCAFFOLD_HEIGHT_LIMIT and  minetest.get_item_group(minetest.get_node(vector.offset(bottom,0,-1,0)).name, "solid") > 0 and minetest.get_node(ppos).name == "air" then
				itemstack = vlc_util.safe_place(ppos, node, placer, itemstack) or itemstack
			end

		elseif minetest.get_item_group(node.name,"solid") > 0 and minetest.get_node(ptd.above).name == "air" then --place on solid
			itemstack = vlc_util.safe_place(ptd.above, {name = "vlc_bamboo:scaffolding"}, placer, itemstack) or itemstack
			minetest.check_single_for_falling(ptd.above)
		end
		return itemstack
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		vlc_util.traverse_tower(vector.offset(pos,0,1,0),1,function(pos,dir,node)
			if node.name ~= "vlc_bamboo:scaffolding" then return true end
			if vlc_util.safe_place(pos, {name = "air"}, digger) then
				if not minetest.is_creative_enabled(digger:get_player_name()) then
					minetest.add_item(pos,"vlc_bamboo:scaffolding")
				end
				for _,v in pairs(adjacents) do
					minetest.check_for_falling(vector.add(pos,v))
				end
			end
		end)
	end,
	_vlc_after_falling = function(pos, depth)
		if minetest.get_node(pos).name == "vlc_bamboo:scaffolding" then
			vlc_util.safe_place(pos,{name = "vlc_bamboo:scaffolding"})
		end
	end,
})

minetest.register_node("vlc_bamboo:scaffolding_horizontal", {
	description = S("Scaffolding horizontal"),
	doc_items_longdesc = S("Scaffolding block..."),
	doc_items_hidden = false,
	tiles = {"vlc_bamboo_scaffolding_side.png","vlc_bamboo_scaffolding_top.png","vlc_bamboo_scaffolding_bottom.png"},
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
	_vlc_after_falling = function(pos)
		if minetest.get_node(pos).name == "vlc_bamboo:scaffolding_horizontal" then
			local above = vector.offset(pos,0,1,0)
			if minetest.get_node(pos).name ~= "vlc_bamboo:scaffolding" then
				vlc_util.safe_place(pos, {name = "air"})
				minetest.add_item(pos,"vlc_bamboo:scaffolding")
			elseif minetest.get_node(above).name == "air" then
				vlc_util.safe_place(above, {name = "vlc_bamboo:scaffolding"})
			end
		end
	end
})
