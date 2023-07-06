local S = minetest.get_translator("mcl_bamboo")

mcl_bamboo.bamboo_itemstrings = {
	"mcl_bamboo:bamboo",
	"mcl_bamboo:bamboo_1",
	"mcl_bamboo:bamboo_2",
	"mcl_bamboo:bamboo_3",
}

local boxes = {
	{-0.175, -0.5, -0.195, 0.05, 0.5, 0.030},
	{-0.05, -0.5, 0.285, -0.275, 0.5, 0.06},
	{0.25, -0.5, 0.325, 0.025, 0.5, 0.100},
	{-0.125, -0.5, 0.125, -0.3125, 0.5, 0.3125},
}

function mcl_bamboo.grow(pos)
	local bottom = mcl_util.traverse_tower(pos,-1)
	local top,h = mcl_util.traverse_tower(bottom,1)
	if h < 12 then
		local n = minetest.get_node(pos)
		minetest.set_node(vector.offset(top,0,1,0),n)
		minetest.set_node(vector.offset(top,0,2,0),{name="mcl_bamboo:bamboo_endcap"})
	end
end

local bamboo_def = {
	description = "Bamboo",
	tiles = {"mcl_bamboo_bamboo_bottom.png", "mcl_bamboo_bamboo_bottom.png", "mcl_bamboo_bamboo.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "4dir",
	groups = {handy = 1, axey = 1, choppy = 1, dig_by_piston = 1, plant = 1, non_mycelium_plant = 1, flammable = 3, bamboo = 1, bamboo_tree = 1},
	sounds = mcl_sounds.node_sound_wood_defaults(),

	drop = {
		max_items = 1,
		items = {
			{
				rarity = 8,
				items = {"mcl_bamboo:bamboo 2"},
			},
			{
				rarity = 1,
				items = {"mcl_bamboo:bamboo"},
			},
		},
	},

	inventory_image = "mcl_bamboo_bamboo_shoot.png",
	wield_image = "mcl_bamboo_bamboo_shoot.png",
	_mcl_blast_resistance = 1,
	_mcl_hardness = 1.5,
	node_placement_prediction = "",
	on_place = mcl_util.generate_on_place_plant_function(function(pos, node)
		local node_below = minetest.get_node_or_nil(vector.offset(pos,0,-1,0))
		if not node_below then return false end
		return minetest.get_item_group(node_below.name, "soil_bamboo") > 0
	end),
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		minetest.set_node(pos,{name=mcl_bamboo.bamboo_itemstrings[math.random(#mcl_bamboo.bamboo_itemstrings)], param2 = math.random(0,3)})
	end,
	on_dig = function(pos,node,digger)
		mcl_util.traverse_tower(pos,1,function(p)
			minetest.remove_node(p)
			if not minetest.is_creative_enabled(digger and digger:get_player_name() or "") then
				minetest.add_item(p,node.name)
			end
		end)
	end,
	_on_bone_meal = function(itemstack,placer,pointed_thing,pos,node)
		return mcl_bamboo.grow(pos)
	end,
}

for i,it in pairs(mcl_bamboo.bamboo_itemstrings) do
	local d = table.copy(bamboo_def)
	if it ~= "mcl_bamboo:bamboo" then
		table.update(d,{
			groups = {handy = 1, axey = 1, choppy = 1, dig_by_piston = 1, plant = 1, non_mycelium_plant = 1, flammable = 3, bamboo = 1, not_in_creative_inventory = 1, bamboo_tree = 1},
		})
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


local bamboo_top = table.copy(bamboo_def)
table.update(bamboo_top,{
	groups = {not_in_creative_inventory = 1, handy = 1, axey = 1, choppy = 1, flammable = 3},
	nodebox = nil,
	selection_box = nil,
	collision_box = nil,
	drawtype = "plantlike",
	tiles = {"mcl_bamboo_endcap.png"},
	on_place = nil,
	_on_bone_meal = nil,
})

minetest.register_node("mcl_bamboo:bamboo_endcap", bamboo_top)


minetest.register_node("mcl_bamboo:bamboo_mosaic",  {
	description = S("Bamboo Mosaic Plank"),
	_doc_items_longdesc = S("Bamboo Mosaic Plank"),
	_doc_items_hidden = false,
	tiles = {"mcl_bamboo_bamboo_plank_mosaic.png"},
	is_ground_content = false,
	groups = {handy = 1, axey = 1, flammable = 3, fire_encouragement = 5, fire_flammability = 20},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_blast_resistance = 3,
	_mcl_hardness = 2,
})
