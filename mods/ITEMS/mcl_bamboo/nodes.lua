local S = minetest.get_translator("mcl_bamboo")
local itemstrings = {
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

local bamboo_def = {
	description = "Bamboo",
	tiles = {"mcl_bamboo_bamboo_bottom.png", "mcl_bamboo_bamboo_bottom.png", "mcl_bamboo_bamboo.png"},
	drawtype = "nodebox",
	paramtype = "light",
	groups = {handy = 1, axey = 1, choppy = 1, dig_by_piston = 1, plant = 1, non_mycelium_plant = 1, flammable = 3, bamboo = 1},
	sounds = node_sound,

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
	on_place = function(itemstack, placer, pointed_thing)
		-- Use pointed node's on_rightclick function first, if present
		local node = minetest.get_node(pointed_thing.under)
		if placer and not placer:get_player_control().sneak then
			if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
				return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, placer, itemstack) or itemstack
			end
		end

		if minetest.is_protected(pointed_thing.above, placer:get_player_name()) then
			minetest.record_protection_violation(pointed_thing.above, pname)
			return
		end

		if minetest.dir_to_wallmounted(vector.subtract(pointed_thing.under,  pointed_thing.above)) == 1 then
			local nu = minetest.get_node(pointed_thing.under)
			local fs = ItemStack(itemstack)
			if minetest.get_item_group(nu.name,"bamboo") > 0 then
				fs:set_name(nu.name)
			else
				fs:set_name(itemstrings[math.random(#itemstrings)])
			end
			local _, success = minetest.item_place_node(fs, placer, pointed_thing, minetest.dir_to_facedir(vector.direction(placer:get_pos(),pointed_thing.above)))
			if not success then
				return
			end
			minetest.sound_play(mcl_sounds.node_sound_wood_defaults().place, {pos=above, gain=1}, true)
			if not minetest.is_creative_enabled(placer:get_player_name()) then
				itemstack:take_item()
			end
		end
		return itemstack
	end,
}

for i,it in pairs(itemstrings) do
	local d = table.copy(bamboo_def)
	if it ~= "mcl_bamboo:bamboo" then
		table.update(d,{
			groups = {handy = 1, axey = 1, choppy = 1, dig_by_piston = 1, plant = 1, non_mycelium_plant = 1, flammable = 3, bamboo = 1, not_in_creative_inventory = 1},
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
})

minetest.register_node("mcl_bamboo:bamboo_endcap", bamboo_top)

local bamboo_block_def = {
	description = "Bamboo Block",
	tiles = {"mcl_bamboo_bamboo_bottom.png", "mcl_bamboo_bamboo_bottom.png", "mcl_bamboo_bamboo_block.png"},
	groups = {handy = 1, building_block = 1, axey = 1, flammable = 2, material_wood = 1, bamboo_block = 1, fire_encouragement = 5, fire_flammability = 5},
	sounds = node_sound,
	paramtype2 = "facedir",
	drops = "mcl_bamboo:bamboo_block",
	_on_axe_place = mcl_core.strip_tree,
	_mcl_blast_resistance = 3,
	_mcl_hardness = 2,
	_mcl_stripped_variant = "mcl_bamboo:bamboo_block_stripped", -- this allows us to use the built in Axe's strip block.
}

minetest.register_node("mcl_bamboo:bamboo_block", bamboo_block_def)

local bamboo_stripped_block = table.copy(bamboo_block_def)
table.update(bamboo_stripped_block,{
	_on_axe_place = nil,
	description = S("Stripped Bamboo Block"),
	tiles = {"mcl_bamboo_bamboo_bottom_stripped.png", "mcl_bamboo_bamboo_bottom_stripped.png", "mcl_bamboo_bamboo_block_stripped.png"},
})
minetest.register_node("mcl_bamboo:bamboo_block_stripped", bamboo_stripped_block)

local bamboo_plank = {
	description = S("Bamboo Plank"),
	_doc_items_longdesc = S("Bamboo Plank"),
	_doc_items_hidden = false,
	tiles = {"mcl_bamboo_bamboo_plank.png"},
	stack_max = 64,
	is_ground_content = false,
	groups = {handy = 1, axey = 1, flammable = 3, wood = 1, building_block = 1, material_wood = 1, fire_encouragement = 5, fire_flammability = 20},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_blast_resistance = 3,
	_mcl_hardness = 2,
}
minetest.register_node("mcl_bamboo:bamboo_plank", bamboo_plank)


local bamboo_mosaic = table.copy(bamboo_plank)
table.update(bamboo_mosaic,{
	tiles = {"mcl_bamboo_bamboo_plank_mosaic.png"},
	groups = {handy = 1, axey = 1, flammable = 3, fire_encouragement = 5, fire_flammability = 20},
	description = S("Bamboo Mosaic Plank"),
	_doc_items_longdesc = S("Bamboo Mosaic Plank"),
})

minetest.register_node("mcl_bamboo:bamboo_mosaic", bamboo_mosaic)

minetest.register_node("mcl_bamboo:scaffolding", {
	description = S("Scaffolding"),
	doc_items_longdesc = S("Scaffolding block used to climb up or out across areas."),
	doc_items_hidden = false,
	tiles = { "mcl_bamboo_scaffolding_top.png", "mcl_bamboo_scaffolding_top.png", "mcl_bamboo_scaffolding_bottom.png" },
	drawtype = "nodebox",
	paramtype = "light",
	use_texture_alpha = "clip",
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.5, 0.375, -0.5, 0.5, 0.5, 0.5 },
			{ -0.5, -0.5, -0.5, -0.375, 0.5, -0.375 },
			{ 0.375, -0.5, -0.5, 0.5, 0.5, -0.375 },
			{ 0.375, -0.5, 0.375, 0.5, 0.5, 0.5 },
			{ -0.5, -0.5, 0.375, -0.375, 0.5, 0.5 },
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{ -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
		},
	},
	buildable_to = false,
	is_ground_content = false,
	walkable = false,
	climbable = true,
	physical = true,
	node_placement_prediction = "",
	groups = { handy = 1, axey = 1, flammable = 3, building_block = 1, material_wood = 1, fire_encouragement = 5, fire_flammability = 20, dig_by_piston = 1, falling_node = 1, stack_falling = 1 },
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_blast_resistance = 0,
	_mcl_hardness = 0,

	on_rotate = disallow_on_rotate,

	on_place = function(itemstack, placer, pointed)
		local node = minetest.get_node(pointed.under)
		local pos = pointed.under
		local h = 0
		local current_base_node = node -- Current Base Node.
		local below_node = minetest.get_node(vector.offset(pos, 0, -1, 0)) -- current node below the current_base_node.

		if minetest.is_protected(pos, placer:get_player_name()) then
			return
		end
		if node.name ~= "mcl_bamboo:scaffolding" then
			if placer and not placer:get_player_control().sneak then
				if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
					return minetest.registered_nodes[node.name].on_rightclick(pointed.under, node, placer, itemstack) or itemstack
				end
			end

			local dir = vector.subtract(pointed.under, pointed.above)
			local wdir = minetest.dir_to_wallmounted(dir)
			if wdir == 1 then
				minetest.set_node(pointed.above, { name = "mcl_bamboo:scaffolding", param2 = 0 })
				if not minetest.is_creative_enabled(placer:get_player_name()) then
					itemstack:take_item(1)
				end
				return itemstack
			else
				return
			end
		end

		--build up when placing on existing scaffold
		--[[
			Quick explanation. scaffolding should be placed at the ground level ONLY. To do this, we look at a few
			different nodes. Current node (current_node) is the top node being placed - make sure that it is air / unoccupied.
			below_node (below node) is the node below the bottom node; Used to check to see if we are up in the air putting
			more scaffolds on the top.. current_base_node (Current Base Node) is the targeted node for placement; we can only place
			scaffolding on this one, to stack them up in the air.
		--]]
		repeat
			pos = vector.offset(pos, 0, 1, 0)
			local current_node = minetest.get_node(pos)
			if current_node.name == "air" then
				if current_base_node.name == "mcl_bamboo:scaffolding" and below_node == "mcl_bamboo:scaffolding" and SIDE_SCAFFOLDING == false then
					return itemstack
				end

				if minetest.is_protected(pos, placer:get_player_name()) then
					return itemstack
				end
				minetest.set_node(pos, node)
				if not minetest.is_creative_enabled(placer:get_player_name()) then
					itemstack:take_item(1)
				end
				return itemstack
			end
			h = h + 1
		until current_node.name ~= node.name or itemstack:get_count() == 0 or h >= 128 -- loop check.
	end,
	on_destruct = function(pos)
		local new_pos = vector.offset(pos, 0, 1, 0)
		local node_above = minetest.get_node(new_pos)
		if node_above and node_above.name == "mcl_bamboo:scaffolding" then
			local sound_params = {
				pos = new_pos,
				max_hear_distance = 10,
			}

			minetest.remove_node(new_pos)
			minetest.sound_play(mcl_sounds.node_sound_wood_defaults().dug, sound_params, true)
			local istack = ItemStack("mcl_bamboo:scaffolding")
			minetest.add_item(new_pos, istack)
		end
	end,
})
