local S = minetest.get_translator("vlf_candles")

local candleboxes = {
	{-1/16, -8/16, -1/16, 1/16, -2/16, 1/16},
	{-2/16, -8/16, -3/16, 2/16, -2/16, 2/16},
	{-3/16, -8/16, -3/16, 2/16, -2/16, 2/16},
	{-3/16, -8/16, -3/16, 3/16, -2/16, 3/16}
}

local tpl_candle = {
	description = S("Candle"),
	drawtype = "mesh",
	groups = { axey = 1, dig_by_piston = 1, handy = 1, candles = 1, unlit_candles = 1, not_solid = 1, pickaxey = 1, shearsy = 1, shovely = 1, swordy = 1 },
	is_ground_content = false,
	paramtype = "light",
	paramtype2 = "color",
	palette = "vlf_dyes_palette.png",
	inventory_image = "vlf_candles_item.png",
	wield_image = "vlf_candles_item.png",
	tiles = { "vlf_candles_candle.png" },
	node_placement_prediction = "",
	sounds = vlf_sounds.node_sound_defaults(),
	sunlight_propagates = true,
	use_texture_alpha = "clip",
	_on_dye_place = function(pos,color)
		local node = minetest.get_node(pos)
		node.param2 = vlf_dyes.colors[color].palette_index
		minetest.swap_node(pos, node)
	end,
	_on_ignite = function(player, pointed_thing)
		local n = minetest.get_node(pointed_thing.under)
		local g = minetest.get_item_group(n.name, "candles")
		if g > 0 then
			n.name = "vlf_candles:candle_lit_"..tostring(g)
			minetest.swap_node(pointed_thing.under, n)
			return true
		end
	end,
	_vlf_blast_resistance = 0.1,
	_vlf_hardness = 0.1,
}

local tpl_lit_candle = {
	description = S("Lit Candle"),
	groups = { axey = 1, dig_by_piston = 1, handy = 1, candles = 1, lit_candles = 1, not_in_creative_inventory = 1, not_solid = 1, pickaxey = 1, shearsy = 1, shovely = 1, swordy = 1 },
}

function tpl_candle.on_place(itemstack, placer, pointed_thing)
	if not placer then return end
	if vlf_util.check_position_protection(pointed_thing.under, placer) then return end
	local rc = vlf_util.call_on_rightclick(itemstack, placer, pointed_thing)
	if rc ~= nil then return rc end

	local unode = minetest.get_node(pointed_thing.under)

	local g = minetest.get_item_group(unode.name, "candles")
	if g > 0 then
		if g < #candleboxes then
			unode.name = "vlf_candles:candle_"..tostring(math.min(4, g + 1))
			unode.param2 = itemstack:get_meta():get("palette_index")
			minetest.swap_node(pointed_thing.under, unode)
			if not minetest.is_creative_enabled(placer:get_player_name()) then
				itemstack:take_item()
			end
		end
	else
		return minetest.item_place_node(itemstack, placer, pointed_thing)
	end

	return itemstack
end

function extinguish(pos, node, clicker, itemstack, pointed_thing)
	if not clicker then
		return
	end

	if vlf_util.check_position_protection(pos, clicker) then
		return
	end

	local g = minetest.get_item_group(node.name, "lit_candles")
	if g > 0 then
		node.name = "vlf_candles:candle_"..tostring(g)
		minetest.swap_node(pos, node)
	end
end

for i=1,4 do
	local candle_n = {
		mesh = "vlf_candles_candle_"..tostring(i)..".obj",
		drop = "vlf_candles:candle_1".." "..tostring(i),
		selection_box = {type = "fixed", fixed = candleboxes[i]},
		collision_box = {type = "fixed", fixed = candleboxes[i]},
	}
	local creative_group
	if i ~= 1 then creative_group = { not_in_creative_inventory = 1 } end
	--[[minetest.register_node("vlf_candles:candle_"..i,table.merge(tpl_candle, candle_n,{
		groups = table.merge(tpl_candle.groups, { candles = i, unlit_candles = i }, creative_group),
	}))
	minetest.register_node("vlf_candles:candle_lit_"..i,table.merge(tpl_candle, tpl_lit_candle, candle_n,{
		light_source = 3 * i,
		groups = table.merge(tpl_lit_candle.groups, { candles = i, lit_candles = i }),
		_on_ignite = nil,
		on_rightclick = extinguish,
	}))]]
end

local function candle_craft(itemstack, player, old_craft_grid, craft_inv)
	local i = 0
	local dye, candle
	for _, stack in pairs(old_craft_grid) do
		if minetest.get_item_group(stack:get_name(), "candles") > 0 then
			candle = stack
			i = i + 1
		elseif minetest.get_item_group(stack:get_name(), "dye") > 0 then
			dye = stack
			i = i + 1
		end
	end
	if dye and candle and i == 2 then
		local cdef = vlf_dyes.colors[dye:get_definition()._color]
		local r = ItemStack(minetest.itemstring_with_palette(candle, cdef.palette_index))
		r:get_meta():set_string("description", S("@1 Candle", cdef.readable_name))
		return r
	end
end

minetest.register_craft_predict(candle_craft)
minetest.register_on_craft(candle_craft)

minetest.register_craft({
	output = "vlf_candles:candle_1",
	recipe = {
		{"vlf_mobitems:string"},
		{"vlf_honey:honeycomb"}
	}
})

minetest.register_craft({
	type = "shapeless",
	output = "vlf_candles:candle_1",
	recipe = {
		"group:candles",
		"group:dye",
	}
})
