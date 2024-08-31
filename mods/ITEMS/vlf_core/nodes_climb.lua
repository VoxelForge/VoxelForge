-- Climbable nodes
local S = minetest.get_translator(minetest.get_current_modname())

local function rotate_climbable(pos, node, user, mode)
	if mode == screwdriver.ROTATE_FACE then
		local r = screwdriver.rotate.wallmounted(pos, node, mode)
		node.param2 = r
		minetest.swap_node(pos, node)
		return true
	end
	return false
end

minetest.register_node("vlf_core:ladder", {
	description = S("Ladder"),
	_doc_items_longdesc = S("A piece of ladder which allows you to climb vertically. Ladders can only be placed on the side of solid blocks and not on glass, leaves, ice, slabs, glowstone, nor sea lanterns."),
	drawtype = "signlike",
	is_ground_content = false,
	tiles = {"default_ladder.png"},
	inventory_image = "default_ladder.png",
	wield_image = "default_ladder.png",
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "wallmounted",
	climbable = true,
	node_box = {
		type = "wallmounted",
		wall_side = { -0.5, -0.5, -0.5, -7/16, 0.5, 0.5 },
	},
	selection_box = {
		type = "wallmounted",
		wall_side = { -0.5, -0.5, -0.5, -7/16, 0.5, 0.5 },
	},
	groups = {handy=1,axey=1, attached_node=1, deco_block=1, dig_by_piston=1, climbable=1},
	sounds = vlf_sounds.node_sound_wood_defaults(),
	node_placement_prediction = "",
	-- Restrict placement of ladders
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			-- no interaction possible with entities
			return itemstack
		end

		local under = pointed_thing.under
		local node = minetest.get_node(under)
		local def = minetest.registered_nodes[node.name]
		if not def then
			return itemstack
		end
		local groups = def.groups

		-- Don't allow to place the ladder at particular nodes
		if (groups and (groups.glass or groups.leaves or groups.slab)) or
				node.name == "vlf_core:ladder" or node.name == "vlf_core:ice" or node.name == "vlf_nether:glowstone" or node.name == "vlf_ocean:sea_lantern" then
			return itemstack
		end

		local rc = vlf_util.call_on_rightclick(itemstack, placer, pointed_thing)
		if rc then return rc end
		local above = pointed_thing.above

		-- Ladders may not be placed on ceiling or floor
		if under.y ~= above.y then
			return itemstack
		end
		local idef = itemstack:get_definition()
		local success = minetest.item_place_node(itemstack, placer, pointed_thing)

		if success then
			if idef.sounds and idef.sounds.place then
				minetest.sound_play(idef.sounds.place, {pos=above, gain=1}, true)
			end
		end
		return itemstack
	end,

	_vlf_blast_resistance = 0.4,
	_vlf_hardness = 0.4,
	on_rotate = rotate_climbable,
})

minetest.register_node("vlf_core:vine", {
	description = S("Vines"),
	_doc_items_longdesc = S("Vines are climbable blocks which can be placed on the sides of solid full-cube blocks. Vines slowly grow and spread."),
	drawtype = "signlike",
	tiles = {"vlf_core_vine.png"},
	inventory_image = "vlf_core_vine.png",
	wield_image = "vlf_core_vine.png",
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "wallmounted",
	walkable = false,
	climbable = true,
	buildable_to = true,
	selection_box = {
		type = "wallmounted",
	},
	groups = {
		handy = 1, axey = 1, shearsy = 1, swordy = 1, deco_block = 1, vinelike_node = 4,
		dig_by_piston = 1, destroy_by_lava_flow = 1, compostability = 50,
		flammable = 2, fire_encouragement = 15, fire_flammability = 100, climbable=1
	},
	sounds = vlf_sounds.node_sound_leaves_defaults(),
	drop = "",
	_vlf_shears_drop = true,
	node_placement_prediction = "",
	-- Restrict placement of vines
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			-- no interaction possible with entities
			return itemstack
		end

		local under = pointed_thing.under
		local node = minetest.get_node(under)
		local def = minetest.registered_nodes[node.name]
		if not def then return itemstack end

		local rc = vlf_util.call_on_rightclick(itemstack, placer, pointed_thing)
		if rc then return rc end

		-- Only place on full cubes
		if not vlf_core.supports_vines(node.name) then
			return itemstack
		end

		local above = pointed_thing.above

		-- Vines may not be placed on top or below another block
		if under.y ~= above.y then
			return itemstack
		end
		local idef = itemstack:get_definition()
		local itemstack, success = minetest.item_place_node(itemstack, placer, pointed_thing)

		if success then
			if idef.sounds and idef.sounds.place then
				minetest.sound_play(idef.sounds.place, {pos=above, gain=1}, true)
			end
		end
		return itemstack
	end,

	-- If dug, also dig a “dependant” vine below it.
	-- A vine is dependant if it hangs from this node and has no supporting block.
	_vlf_blast_resistance = 0.2,
	_vlf_hardness = 0.2,
	on_rotate = false,
})
