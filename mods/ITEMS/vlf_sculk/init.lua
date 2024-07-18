--sculk stuff--

--1)sculk block--
--2)sculk catalyst--
--3)sculk sensors--
--4)sculk shrieker--
--5)sculk vein--

local modpath = minetest.get_modpath("vlf_sculk")

-- Load files
dofile(modpath .. "/sculk_sensor.lua")
dofile(modpath .. "/sculk_shrieker.lua")

--------------------------------------------------------------------

local S = minetest.get_translator(minetest.get_current_modname())

vlf_sculk = {}

local mt_sound_play = minetest.sound_play

local spread_to = {"vlf_core:stone","vlf_core:dirt","vlf_core:sand","vlf_core:dirt_with_grass","group:grass_block","vlf_core:andesite","vlf_core:diorite","vlf_core:granite","vlf_core:mycelium","group:dirt","vlf_end:end_stone","vlf_nether:netherrack","vlf_blackstone:basalt","vlf_nether:soul_sand","vlf_blackstone:soul_soil","vlf_crimson:warped_nylium","vlf_crimson:crimson_nylium","vlf_core:gravel"}

local sounds = {
	footstep = {name = "vlf_sculk_block_2", },
	place = {name = "vlf_sculk_block_2", },
	dug = {name = "vlf_sculk_block", "vlf_sculk_2", },
}

local SPREAD_RANGE = 8

local adjacents = {
	vector.new(1,0,0),
	vector.new(-1,0,0),
	vector.new(0,1,0),
	vector.new(0,-1,0),
	vector.new(0,0,1),
	vector.new(0,0,-1),
}

-----------------------------------------
local function get_node_xp(pos)
	local meta = minetest.get_meta(pos)
	return meta:get_int("xp")
end

local function set_node_xp(pos, xp)
	local meta = minetest.get_meta(pos)
	return meta:set_int("xp", xp)
end

local function sculk_on_destruct(pos)
	local xp = get_node_xp(pos)
	local n = minetest.get_node(pos)
	if n.param2 == 1 then
		xp = 1
	end
	local obs = vlf_experience.throw_xp(pos, xp)
	for _,v in pairs(obs) do
		local l = v:get_luaentity()
		l._sculkdrop = true
	end
end

local function has_air(pos)
	for _,v in pairs(adjacents) do
		if minetest.get_item_group(minetest.get_node(vector.add(pos,v)).name, "solid") <= 0 then
			return true
		end
	end
end

local function has_nonsculk(pos)
	for _,v in pairs(adjacents) do
		local p = vector.add(pos,v)
		if minetest.get_item_group(minetest.get_node(p).name, "sculk") <= 0 and minetest.get_item_group(minetest.get_node(p).name, "solid") > 0 then
			return p
		end
	end
end

local function retrieve_close_spreadable_nodes(p)
	local nnn = minetest.find_nodes_in_area(vector.offset(p, -SPREAD_RANGE, -SPREAD_RANGE, -SPREAD_RANGE), vector.offset(p, SPREAD_RANGE, SPREAD_RANGE, SPREAD_RANGE), spread_to)
	local nn = {}
	for _,v in pairs(nnn) do
		if has_air(v) then
			table.insert(nn, v)
		end
	end
	table.sort(nn, function(a, b)
		return vector.distance(p, a) < vector.distance(p, b)
	end)
	return nn
end

local function spread_sculk(p, xp_amount)
	local c = minetest.find_node_near(p, SPREAD_RANGE, {"vlf_sculk:catalyst"} or {"vlf_sculk:catalyst_bloom"})
	if c then
	local nn = retrieve_close_spreadable_nodes(p)
		if nn and #nn > 0 then
			if xp_amount > 0 then
				local d = math.random(100)
				if d <= 0 then
					minetest.set_node(nn[1],{name = "vlf_sculk:shrieker"})
					set_node_xp(nn[1],math.min(1,self._xp - 10))
					return ret
				elseif d <= 0 then
					minetest.set_node(nn[1],{name = "vlf_sculk:sculk_sensor_inactive"})
					set_node_xp(nn[1],math.min(1,self._xp - 5))
					return ret
				else
					local r = math.min(math.random(#nn), xp_amount)
					for i=1,r do
						minetest.set_node(nn[i], {name = "vlf_sculk:sculk"})
						set_node_xp(nn[i], math.floor(xp_amount / r))
					end
					for i=1,r do
						if minetest.get_node(c).name == "vlf_sculk:catalyst" then
							minetest.set_node(c, {name = "vlf_sculk:catalyst_bloom"})
						end
						for i=1,r do
							local p = has_nonsculk(nn[i])
							if p and has_air(p) then
								minetest.set_node(vector.offset(p, 0, 1, 0), {name = "vlf_sculk:vein", param2 = 1})
							end
						end
						set_node_xp(nn[1], get_node_xp(nn[1]) + xp_amount % r)
						return true
					end
				end
			end
		end
	end
end

function vlf_sculk.handle_death(pos, xp_amount)
	if not pos or not xp_amount then return end
	--local nu = minetest.get_node(vector.offset(p,0,-1,0))
		return spread_sculk (pos, xp_amount)
end

minetest.register_on_dieplayer(function(player)
	if vlf_sculk.handle_death(player:get_pos(), 5) then
		--minetest.log("Player is dead. Sculk")
	else
		--minetest.log("Player is dead. not Sculk")
	end
end)

minetest.register_node("vlf_sculk:sculk", {
	description = S("Sculk"),
	tiles = {
		{ name = "vlf_sculk_sculk.png",
		animation = {
			type = "vertical_frames",
			aspect_w = 16,
			aspect_h = 16,
			length = 2.5,
		}, },
	},
	drop = "",
	groups = {handy = 1, hoey = 1, building_block=1, sculk = 1, xp=1},
	place_param2 = 1,
	sounds = sounds,
	is_ground_content = false,
	--on_destruct = sculk_on_destruct,
	_vlf_blast_resistance = 0.2,
	_vlf_hardness = 0.2,
	_vlf_silk_touch_drop = true,
})

minetest.register_node("vlf_sculk:catalyst", {
	description = S("Sculk Catalyst"),
	tiles = {
		"vlf_sculk_catalyst_top.png",
		"vlf_sculk_catalyst_bottom.png",
		"vlf_sculk_catalyst_side.png"
	},
	drop = "",
	sounds = {
	footstep = {name = "vlf_sculk_block_2", },
	place = {name = "vlf_sculk_block_2", },
	dug = {name = "vlf_sculk_catalyst_breaking",},
	},
	groups = {handy = 1, hoey = 1, building_block=1, sculk = 1, xp=5},
	place_param2 = 1,
	is_ground_content = false,
	--on_destruct = sculk_on_destruct,
	_vlf_blast_resistance = 3,
	light_source  = 6,
	_vlf_hardness = 3,
	_vlf_silk_touch_drop = true,
})

minetest.register_node("vlf_sculk:catalyst_bloom", {
	description = S("Sculk Catalyst"),
	tiles = {
	{ name="vlf_sculk_catalyst_top_bloom.png",
				animation={
				type="vertical_frames",
				aspect_w=16,
				aspect_h=16,
				length=1.0
			},
		},
	"vlf_sculk_catalyst_bottom.png",
	{ name="vlf_sculk_catalyst_side_bloom.png",
				animation={
				type="vertical_frames",
				aspect_w=16,
				aspect_h=16,
				length=1.0
			},
		},
	},
	drop = "",
	sounds = sounds,
	groups = {handy = 1, hoey = 1, building_block=1, sculk = 1, not_in_creative_inventory=1, xp=5},
	place_param2 = 1,
	is_ground_content = false,
	--on_destruct = sculk_on_destruct,
	_vlf_blast_resistance = 3,
	light_source  = 6,
	_vlf_hardness = 3,
	_vlf_silk_touch_drop = true and {"vlf_sculk:catalyst"},
		on_construct = function(pos)
		minetest.add_particle({
		pos = {x=pos.x, y=pos.y+0.2, z=pos.z},
		velocity = {x = 0, y = 0.6, z = 0},
		expirationtime = 1.2,
		size = 5,
		--texture = "vlf_soul_particle.png",
		texture = "vlf_soul_particle.png",
		animation = {
			type = "vertical_frames",
			frames_w = 16,
			frames_h = 16,
			frame_length = 1.0,
		},
	})
			minetest.after(0.7, function() -- Delay of seconds
			minetest.swap_node(pos, {name = "vlf_sculk:catalyst"})
		end)
	end,
})

minetest.register_node("vlf_sculk:vein", {
	description = S("Sculk Vein"),
	_doc_items_longdesc = S("Sculk vein."),
	drawtype = "signlike",
	tiles = {
		{ name = "vlf_sculk_vein.png",
		animation = {
			type = "vertical_frames",
			aspect_w = 16,
			aspect_h = 16,
			length = 2.5,
		}, },
	},
	inventory_image = "vlf_sculk_vein.png^[verticalframe:3:0",
	wield_image = "vlf_sculk_vein.png^[verticalframe:3:0",
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "wallmounted",
	walkable = false,
	climbable = false,
	buildable_to = true,
	selection_box = {
		type = "wallmounted",
	},
	groups = {
		handy = 1, hoey = 1, shearsy = 1, swordy = 1, deco_block = 1,
		dig_by_piston = 1, sculk = 1,
	},
	sounds = sounds,
	drop = "",
	_vlf_shears_drop = true,
	node_placement_prediction = "",
	_vlf_blast_resistance = 0.2,
	_vlf_hardness = 0.2,
	on_rotate = false,
})

minetest.register_abm({
	label = "vlf_sculk_revert_vlf_sculk:catalyst_bloom",
	nodenames = {"vlf_sculk:catalyst_bloom"},
	interval = 2.5,
	chance = 1,
	action = function(pos)
	local node = minetest.get_node(pos)
	if node.name == "vlf_sculk:catalyst_bloom" then
		local meta = minetest.get_meta(pos)
		local creation_time = meta:get_int("creation_time") or 0
		local current_time = minetest.get_gametime()

		-- Check if the node has existed for at least 5 seconds (100 ticks per second)
		local existence_time = current_time - creation_time
		local existence_seconds = existence_time / 100
		if existence_seconds >= 5 then
		-- Revert to inactive sculk sensor node after turning off mesecon signal
		minetest.set_node(pos, {name = "vlf_sculk:catalyst"})
		end
	end
	end,
})

--Add this in mesecons_mvps.lua----------------------
mesecon.register_mvps_stopper("vlf_sculk:shrieker")
mesecon.register_mvps_stopper("vlf_sculk:sculk_sensor_inactive")
mesecon.register_mvps_stopper("vlf_sculk:sculk_sensor_active")
mesecon.register_mvps_stopper("vlf_sculk:sculk_sensor_inactive_w_logged")
mesecon.register_mvps_stopper("vlf_sculk:sculk_sensor_active_w_logged")
mesecon.register_mvps_stopper("vlf_deepslate:reinforced_deepslate")

--------------------------------------------------------------------
