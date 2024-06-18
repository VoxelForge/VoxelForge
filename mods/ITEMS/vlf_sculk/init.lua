--[[local S = minetest.get_translator(minetest.get_current_modname())
vlf_sculk = {}

local mt_sound_play = minetest.sound_play

local spread_to = {"vlf_core:stone","vlf_core:dirt","vlf_core:sand","vlf_core:dirt_with_grass","group:grass_block","vlf_core:andesite","vlf_core:diorite","vlf_core:granite","vlf_core:mycelium","group:dirt","vlf_end:end_stone","vlf_nether:netherrack","vlf_blackstone:basalt","vlf_nether:soul_sand","vlf_blackstone:soul_soil","vlf_crimson:warped_nylium","vlf_crimson:crimson_nylium","vlf_core:gravel","vlf_deepslate:deepslate","vlf_deepslate:tuff"}

local sounds = {
	footstep = {name = "vlf_sculk_block", gain = 0.2},
	dug      = {name = "vlf_sculk_block", gain = 0.2},
}

local SPREAD_RANGE = 8
local SENSOR_RANGE = 8
local SENSOR_DELAY = 0.5
local SHRIEKER_COOLDOWN = 10

local adjacents = {
	vector.new(1,0,0),
	vector.new(-1,0,0),
	vector.new(0,1,0),
	vector.new(0,-1,0),
	vector.new(0,0,1),
	vector.new(0,0,-1),
}


local function sensor_action(p,tp)
	local s = minetest.find_node_near(p,SPREAD_RANGE,{"vlf_sculk:shrieker"})
	local n = minetest.get_node(s)
	if s and n.param2 ~= 1 then
		minetest.sound_play("vlf_sculk_shrieker", {pos=s, gain=1.5, max_hear_distance = 16}, true)
		n.param2 = 1
		minetest.set_node(s,n)
		minetest.after(SHRIEKER_COOLDOWN,function(s)
			minetest.set_node(s,{name = "vlf_sculk:shrieker",param2=0})
		end,s)
	end
	local p1 = vector.offset(p,-SENSOR_RANGE,-SENSOR_RANGE,-SENSOR_RANGE)
	local p2 = vector.offset(p,SENSOR_RANGE,SENSOR_RANGE,SENSOR_RANGE)
	--darken_area(p1,p2)
end

--[[function minetest.sound_play(spec, parameters, ephemeral)
	--local rt = old_sound_play(spec, parameters, ephemeral)
	if parameters.pos then
		pos = parameters.pos
	elseif parameters.to_player then
		pos = minetest.get_player_by_name(parameters.to_player):get_pos()
	end
	if not pos then return rt end
	local s = minetest.find_node_near(pos,SPREAD_RANGE,{"vlf_sculk:sensor"})
	if s then
		minetest.after(SENSOR_DELAY,sensor_action,s,pos)
	end
	return rt
end]]  

--[[walkover.register_global(function(pos, node, player)
	local s = minetest.find_node_near(pos,SPREAD_RANGE,{"vlf_sculk:sensor"})
	if not s then return end
	local v = player:get_velocity()
	if v.x == 0 and v.y == 0 and v.z == 0 then return end
	if player:get_player_control().sneak then return end
	local def = minetest.registered_nodes[node.name]
	if def and def.sounds then
		minetest.log("walkover "..node.name)
		minetest.after(SENSOR_DELAY,sensor_action,s,pos)
	end
end)
--

local function get_node_xp(pos)
	local meta = minetest.get_meta(pos)
	return meta:get_int("xp")
end
local function set_node_xp(pos,xp)
	local meta = minetest.get_meta(pos)
	return meta:set_int("xp",xp)
end

local function sculk_after_dig_node(pos, oldnode, oldmetadata, digger)
	-- Check if node will yield its useful drop by the digger's tool
	if digger and digger:is_player() then
		local tool = digger:get_wielded_item()

		if vlf_autogroup.can_harvest(oldnode.name, tool:get_name(), digger) then
			if tool and vlf_enchanting.get_enchantments(tool, "silk_touch").silk_touch then
				-- Don't drop experience when mined with silk touch
				return
			end
		end
	end

	local xp = get_node_xp(pos)
	if oldnode.param2 == 1 then
		xp = 1
	end
	local obs = vlf_experience.throw_xp(pos,xp)
	for _,v in pairs(obs) do
		local l = v:get_luaentity()
		l._sculkdrop = true
	end
end

local function has_air(pos)
	for _,v in pairs(adjacents) do
		if minetest.get_item_group(minetest.get_node(vector.add(pos,v)).name,"solid") <= 0 then return true end
	end
end

local function has_nonsculk(pos)
	for _,v in pairs(adjacents) do
		local p = vector.add(pos,v)
		if minetest.get_item_group(minetest.get_node(p).name,"sculk") <= 0 and minetest.get_item_group(minetest.get_node(p).name,"solid") > 0 then return p end
	end
end
local function retrieve_close_spreadable_nodes (p)
	local nnn = minetest.find_nodes_in_area(vector.offset(p,-SPREAD_RANGE,-SPREAD_RANGE,-SPREAD_RANGE),vector.offset(p,SPREAD_RANGE,SPREAD_RANGE,SPREAD_RANGE),spread_to)
	local nn={}
	for _,v in pairs(nnn) do
		if has_air(v) then
			table.insert(nn,v)
		end
	end
	table.sort(nn,function(a, b)
		return vector.distance(p, a) < vector.distance(p, b)
	end)
	return nn
end

local function spread_sculk (p, xp_amount)
	local c = minetest.find_node_near(p,SPREAD_RANGE,{"vlf_sculk:catalyst"})
	if c then
		local nn = retrieve_close_spreadable_nodes (p)
		if nn and #nn > 0 then
			if xp_amount > 0 then
				local d = math.random(100)
				--enable to generate shriekers and sensors
				if d <= 1 then
					minetest.set_node(nn[1],{name = "vlf_sculk:shrieker"})
					set_node_xp(nn[1],math.min(1,self._xp - 10))
					self.object:remove()
					return ret
				elseif d <= 9 then
					minetest.set_node(nn[1],{name = "vlf_sculk:sensor"})
					set_node_xp(nn[1],math.min(1,self._xp - 5))
					self.object:remove()
					return ret
				else --


				local r = math.min(math.random(#nn), xp_amount)

				for i=1,r do
					minetest.set_node(nn[i],{name = "vlf_sculk:sculk" })
					set_node_xp(nn[i],math.floor(xp_amount / r))
				end
				for i=1,r do
					local p = has_nonsculk(nn[i])
					if p and has_air(p) then
						minetest.set_node(vector.offset(p,0,1,0),{name = "vlf_sculk:vein", param2 = 1})
					end
				end
				set_node_xp(nn[1],get_node_xp(nn[1]) + xp_amount % r)
				return true
			end
		end
	end
end
end

function vlf_sculk.handle_death(pos, xp_amount)
	if not pos or not xp_amount then return end
	return spread_sculk (pos, xp_amount)
end

minetest.register_on_dieplayer(function(player)
	vlf_sculk.handle_death(player:get_pos(), 5)
end)

minetest.register_node("vlf_sculk:shrieker", {
	description = S("Sculk Shrieker"),
	tiles = {
		"vlf_sculk_shrieker_top.png",
		"vlf_sculk_shrieker_bottom.png",
		"vlf_sculk_shrieker_side.png"
	},
	drop = "",
	sounds = sounds,
	groups = {handy = 1, hoey = 1, building_block=1, sculk = 1,},
	place_param2 = 0,
	is_ground_content = false,
	after_dig_node = sculk_after_dig_node,
	_vlf_blast_resistance = 3,
	light_source  = 6,
	_vlf_hardness = 3,
	_vlf_silk_touch_drop = true,
})

minetest.register_node("vlf_sculk:sculk", {
	description = S("Sculk"),
	tiles = {
		{ name = "vlf_sculk_sculk.png",
		animation = {
			type = "vertical_frames",
			aspect_w = 16,
			aspect_h = 16,
			length = 3.0,
		}, },
	},
	drop = "",
	groups = {handy = 1, hoey = 1, building_block=1, sculk = 1,},
	place_param2 = 1,
	sounds = sounds,
	is_ground_content = false,
	after_dig_node = sculk_after_dig_node,
	_vlf_blast_resistance = 0.2,
	_vlf_hardness = 0.6,
	_vlf_silk_touch_drop = true,
})

minetest.register_node("vlf_sculk:vein", {
	description = S("Sculk Vein"),
	_doc_items_longdesc = S("Sculk vein."),
	drawtype = "signlike",
	tiles = {"vlf_sculk_vein.png"},
	inventory_image = "vlf_sculk_vein.png",
	wield_image = "vlf_sculk_vein.png",
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
		handy = 1, axey = 1, shearsy = 1, swordy = 1, deco_block = 1,
		dig_by_piston = 1, destroy_by_lava_flow = 1, sculk = 1, dig_by_water = 1,
	},
	sounds = sounds,
	drop = "",
	_vlf_shears_drop = true,
	node_placement_prediction = "",
	_vlf_blast_resistance = 0.2,
	_vlf_hardness = 0.2,
	on_rotate = false,
})

minetest.register_node("vlf_sculk:catalyst", {
	description = S("Sculk Catalyst"),
	tiles = {
		"vlf_sculk_catalyst_top.png",
		"vlf_sculk_catalyst_bottom.png",
		"vlf_sculk_catalyst_side.png"
	},
	drop = "",
	sounds = sounds,
	groups = {handy = 1, hoey = 1, building_block=1, sculk = 1,},
	place_param2 = 1,
	is_ground_content = false,
	after_dig_node = sculk_after_dig_node,
	_vlf_blast_resistance = 3,
	light_source  = 6,
	_vlf_hardness = 3,
	_vlf_silk_touch_drop = true,
})


minetest.register_node("vlf_sculk:sensor", {
	description = S("Sculk Sensor"),
	tiles = {
		"vlf_sculk_sensor_top.png",
		"vlf_sculk_sensor_bottom.png",
		"vlf_sculk_sensor_side.png"
	},
	drop = "",
	tiles = {"vlf_sculk_sensor.png"},
	overlay_tiles = {{
	name = "vlf_sculk_sensor_tendril_inactive_alt.png",
	animation = {
		type = "vertical_frames",
		aspect_w = 32,
		aspect_h = 16,
		length = 2.0,
	}},
},
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.0, 0.5},
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.0, 0.5},
		},
	},
	sounds = sounds,
	drawtype = 'mesh',
	mesh = 'vlf_sculk_sensor.obj',
	groups = {handy = 1, hoey = 1, building_block=1, sculk = 1,},
	place_param2 = 1,
	is_ground_content = false,
	after_dig_node = sculk_after_dig_node,
	_vlf_blast_resistance = 3,
	light_source  = 6,
	_vlf_hardness = 3,
	_vlf_silk_touch_drop = true,
})]]

--sculk stuff--

--1)sculk block--
--2)sculk catalyst--
--3)sculk sensors--
--4)sculk shrieker--
--5)sculk vein--

--------------------------------------------------------------------

local S = minetest.get_translator(minetest.get_current_modname())

vlf_sculk = {}

local mt_sound_play = minetest.sound_play

local spread_to = {"vlf_core:stone","vlf_core:dirt","vlf_core:sand","vlf_core:dirt_with_grass","group:grass_block","vlf_core:andesite","vlf_core:diorite","vlf_core:granite","vlf_core:mycelium","group:dirt","vlf_end:end_stone","vlf_nether:netherrack","vlf_blackstone:basalt","vlf_nether:soul_sand","vlf_blackstone:soul_soil","vlf_crimson:warped_nylium","vlf_crimson:crimson_nylium","vlf_core:gravel"}

local sounds = {
	footstep = {name = "vlf_sculk_block", },
	dug      = {name = "vlf_sculk_block", },
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
local function set_node_xp(pos,xp)
	local meta = minetest.get_meta(pos)
	return meta:set_int("xp",xp)
end

local function sculk_on_destruct(pos)
	local xp = get_node_xp(pos)
	local n = minetest.get_node(pos)
	if n.param2 == 1 then
		xp = 1
	end
	local obs = vlf_experience.throw_xp(pos,xp)
	for _,v in pairs(obs) do
		local l = v:get_luaentity()
		l._sculkdrop = true
	end
end

local function has_air(pos)
	for _,v in pairs(adjacents) do
		if minetest.get_item_group(minetest.get_node(vector.add(pos,v)).name,"solid") <= 0 then return true end
	end
end

local function has_nonsculk(pos)
	for _,v in pairs(adjacents) do
		local p = vector.add(pos,v)
		if minetest.get_item_group(minetest.get_node(p).name,"sculk") <= 0 and minetest.get_item_group(minetest.get_node(p).name,"solid") > 0 then return p end
	end
end
local function retrieve_close_spreadable_nodes (p)
	local nnn = minetest.find_nodes_in_area(vector.offset(p,-SPREAD_RANGE,-SPREAD_RANGE,-SPREAD_RANGE),vector.offset(p,SPREAD_RANGE,SPREAD_RANGE,SPREAD_RANGE),spread_to)
	local nn={}
	for _,v in pairs(nnn) do
		if has_air(v) then
			table.insert(nn,v)
		end
	end
	table.sort(nn,function(a, b)
		return vector.distance(p, a) < vector.distance(p, b)
	end)
	return nn
end

local function spread_sculk (p, xp_amount)
	local c = minetest.find_node_near(p,SPREAD_RANGE,{"vlf_sculk:catalyst"})
	if c then
		local nn = retrieve_close_spreadable_nodes (p)
		if nn and #nn > 0 then
			if xp_amount > 0 then
				local d = math.random(100)
				--enable to generate shriekers and sensors
				if d <= 1 then
					minetest.set_node(nn[1],{name = "vlf_sculk:shrieker"})
					set_node_xp(nn[1],math.min(1,self._xp - 10))
					self.object:remove()
					return ret
				elseif d <= 9 then
					minetest.set_node(nn[1],{name = "vlf_sculk:sensor"})
					set_node_xp(nn[1],math.min(1,self._xp - 5))
					self.object:remove()
					return ret
				else


				local r = math.min(math.random(#nn), xp_amount)
				--minetest.log("r: ".. r)

				for i=1,r do
					minetest.set_node(nn[i],{name = "vlf_sculk:sculk" })
					set_node_xp(nn[i],math.floor(xp_amount / r))
				end
				for i=1,r do
					local p = has_nonsculk(nn[i])
					if p and has_air(p) then
						minetest.set_node(vector.offset(p,0,1,0),{name = "vlf_sculk:vein", param2 = 1})
					end
				end
				set_node_xp(nn[1],get_node_xp(nn[1]) + xp_amount % r)
				return true
				--self.object:remove()
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
			length = 3.0,
		}, },
	},
	drop = "",
	groups = {handy = 1, hoey = 1, building_block=1, sculk = 1,},
	place_param2 = 1,
	sounds = sounds,
	is_ground_content = false,
	on_destruct = sculk_on_destruct,
	_vlf_blast_resistance = 0.2,
	_vlf_hardness = 0.6,
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
	sounds = sounds,
	groups = {handy = 1, hoey = 1, building_block=1, sculk = 1,},
	place_param2 = 1,
	is_ground_content = false,
	on_destruct = sculk_on_destruct,
	_vlf_blast_resistance = 3,
	light_source  = 6,
	_vlf_hardness = 3,
	_vlf_silk_touch_drop = true,
})

minetest.register_node("vlf_sculk:vein", {
	description = S("Sculk Vein"),
	_doc_items_longdesc = S("Sculk vein."),
	drawtype = "signlike",
	tiles = {"vlf_sculk_vein.png"},
	inventory_image = "vlf_sculk_vein.png",
	wield_image = "vlf_sculk_vein.png",
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
		handy = 1, axey = 1, shearsy = 1, swordy = 1, deco_block = 1,
		dig_by_piston = 1, destroy_by_lava_flow = 1, sculk = 1, dig_by_water = 1,
	},
	sounds = sounds,
	drop = "",
	_vlf_shears_drop = true,
	node_placement_prediction = "",
	_vlf_blast_resistance = 0.2,
	_vlf_hardness = 0.2,
	on_rotate = false,
})

local wool = { "vlf_wool:white", "vlf_wool:grey",  "vlf_wool:dark_grey", "vlf_wool:silver", "vlf_wool:black", "vlf_wool:red", "vlf_wool:yellow", "vlf_wool:dark_green", "vlf_wool:cyan", "vlf_wool:blue", "vlf_wool:magenta", "vlf_wool:orange", "vlf_wool:violet", "vlf_wool:brown", "vlf_wool:pink", "vlf_wool:lime", "vlf_wool:light_blue",}

-- List of nodes that entities can move on without triggering the sculk sensor
local allowed_node_types = {"group:carpet", wool}

-- ID of the entity to ignore (set to -1 to detect all entities)
local ignored_entity_id = 123

-- Function to check if an entity should be ignored
local function is_entity_ignored(entity)
    if ignored_entity_id == -1 then
        return false
    end
    return entity:get_id() == ignored_entity_id
end

-- Function to check if a node type is allowed
local function is_node_type_allowed(node_pos)
    local node_name = minetest.get_node(node_pos).name
    for _, allowed_node_type in ipairs(allowed_node_types) do
        if minetest.get_item_group(node_name, allowed_node_type) ~= 0 then
            return true
        end
    end
    return false
end

-- Function to check if an entity should trigger the sculk sensor
local function should_entity_trigger_sculk_sensor(entity)
    if is_entity_ignored(entity) then
        return false
    end
    local entity_pos = entity:get_pos()
    local node_pos = vector.round(entity_pos)
    return not is_node_type_allowed(node_pos)
end

-------------------------------------
-- Register mesecon output on sculk sensor
minetest.register_node("vlf_sculk:sculk_sensor", {
description = "Sculk Sensor",
tiles = {"vlf_sculk_sensor.png",
},
	overlay_tiles = {{
	name = "vlf_sculk_sensor_tendril_inactive_alt.png",
	animation = {
		type = "vertical_frames",
		aspect_w = 32,
		aspect_h = 16,
		length = 2.0,
	}},
},
	drop = "",
	sounds = sounds,
	use_texture_alpha = "clip",
	drawtype = 'mesh',
	mesh = 'vlf_sculk_sensor.obj',
	selection_box = {
			type = 'fixed',
			fixed = {-.5, -.5, -.5, .5, 0.0, .5},
		},
   	collision_box = {
  	  type = "fixed",
   	 fixed = {-0.5, -0.5, -0.5, 0.5, 0.0, 0.5},
   	},
	groups = {handy = 1, hoey = 1, building_block=1, sculk = 1,},
	place_param2 = 1,
	is_ground_content = false,
	on_destruct = sculk_on_destruct,
	_vlf_blast_resistance = 3,
	light_source  = 6,
	_vlf_hardness = 3,
	_vlf_silk_touch_drop = true,
    --sounds = default.node_sound_stone_defaults(),
    mesecons = {
        effector = {
            rules = sculk_sensor_effector_rules,
            action_on = function(pos, node)
                -- Emit vibration particles
                minetest.add_particlespawner({
                    amount = 16,
                    time = 0.5,
                    minpos = {x = pos.x - 0.5, y = pos.y - 0.5, z = pos.z - 0.5},
                    maxpos = {x = pos.x + 0.5, y = pos.y + 0.5, z = pos.z + 0.5},
                    minvel = {x = -1, y = -1, z = -1},
                    maxvel = {x = 1, y = 1, z = 1},
                    minacc = {x = 0, y = 0, z = 0},
                    maxacc = {x = 0, y = 0, z = 0},
                    minexptime = 0.5,
                    maxexptime = 1,
                    minsize = 3,
                    maxsize = 5,
                    collisiondetection = true,
                    collision_removal = true,
                    object_collision = true,
                    vertical = false,
                    texture = "vlf_sculk_catalyst_top_bloom.png",
                    glow = 14,
                })
                
                -- Play sound effect
                --minetest.sound_play("modname_sculk_sound", {pos = pos, gain = 1.0})
                
                -- Emit mesecon signal
                mesecon.receptor_on(pos, sculk_sensor_effector_rules)
                
                -- Schedule mesecon signal turn off after 0.1 seconds
                minetest.after(0.1, function()
                    mesecon.receptor_off(pos, sculk_sensor_effector_rules)
                end)
            end
        }
    },
})


--------------------------------------------------------------------

