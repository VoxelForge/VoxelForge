local S = minetest.get_translator(minetest.get_current_modname())

local PRESSURE_PLATE_INTERVAL = 0.25

local pp_box_off = {
	type = "fixed",
	fixed = { -7/16, -8/16, -7/16, 7/16, -7/16, 7/16 },
}
local pp_box_on = {
	type = "fixed",
	fixed = { -7/16, -8/16, -7/16, 7/16, -7.5/16, 7/16 },
}

mcl_pressureplates = {}

local function update_pp(pos)
	local node = minetest.get_node(pos)
	local basename = minetest.registered_nodes[node.name]._mcl_pressureplate_basename
	local activated_by = minetest.registered_nodes[node.name]._mcl_pressureplate_activated_by
	local weighted = minetest.registered_nodes[node.name]._mcl_pressureplate_weighted

	-- This is a workaround for a strange bug that occurs when the server is started
	-- For some reason the first time on_timer is called, the pos is wrong
	if not basename then return end

	local obj_does_activate = function(obj, activated_by)
		if activated_by.any then
			return true
		elseif activated_by.mob and obj:get_luaentity() and obj:get_luaentity().is_mob == true then
			return true
		elseif activated_by.player and obj:is_player() then
			return true
		else
			return false
		end
	end

	local function obj_touching_plate_pos(obj_ref, plate_pos)
		local obj_pos = obj_ref:get_pos()
		local props = obj_ref:get_properties()
		local parent = obj_ref:get_attach()
		if props and obj_pos and not parent then
			local collisionbox = props.collisionbox
			local physical = props.physical
			local is_player = obj_ref:is_player()
			local luaentity = obj_ref:get_luaentity()
			local is_item = luaentity and luaentity.name == "__builtin:item"
			if collisionbox and physical or is_player or is_item then
				local plate_x_min = plate_pos.x - 7 / 16
				local plate_x_max = plate_pos.x + 7 / 16
				local plate_z_min = plate_pos.z - 7 / 16
				local plate_z_max = plate_pos.z + 7 / 16
				local plate_y_max = plate_pos.y - 7 / 16
				local obj_x_min = obj_pos.x + collisionbox[1]
				local obj_x_max = obj_pos.x + collisionbox[4]
				local obj_z_min = obj_pos.z + collisionbox[3]
				local obj_z_max = obj_pos.z + collisionbox[6]
				local obj_y_min = obj_pos.y + collisionbox[2]

				if
					obj_y_min <= plate_y_max and
					(obj_x_min < plate_x_max) and
					(obj_x_max > plate_x_min) and
					(obj_z_min < plate_z_max) and
					(obj_z_max > plate_z_min)
				then
					return true
				end
			end
		end
		return false
	end

	local function count_obj_touching_plate_pos(pos)
		local n = 0
		for obj in minetest.objects_inside_radius(pos, 1) do
			if
				obj_does_activate(obj, activated_by) and
				obj_touching_plate_pos(obj, pos)
			then
				n = n + 1
				minetest.get_meta(pos):set_string("deact_time", "")
			end
		end
		return n
	end

	local n_entities = count_obj_touching_plate_pos(pos)
	if node.name == basename .. "_on" then
		if n_entities == 0 then
			local meta = minetest.get_meta(pos)
			local deact_time = meta:get_float("deact_time")
			local current_time = minetest.get_us_time()
			if deact_time == 0 then
				deact_time = current_time + 1 * 1000 * 1000
				meta:set_float("deact_time", deact_time)
			end
			if deact_time <= current_time then
				minetest.set_node(pos, { name = basename .. "_off" })
				meta:set_string("deact_time", "")
			end
		end
	end
	if n_entities > 0 then
		local power = math.min(weighted and (n_entities / weighted) or 15, 15)
		minetest.set_node(pos, { name = basename .. "_on", param2 = power })
	end

	return true
end

function mcl_pressureplates.register_pressure_plate(basename, def)
	local groups_off = table.copy(def.groups)
	groups_off.attached_node = 1
	groups_off.dig_by_piston = 1
	groups_off.unsticky = 1
	groups_off.pressure_plate = 1
	local groups_on = table.copy(groups_off)
	groups_on.not_in_creative_inventory = 1
	groups_on.dig_by_piston = 1
	groups_on.unsticky = 1
	groups_on.pressure_plate = 2

	local tt = S("Provides redstone power when pushed")
	if not def.activated_by then
		tt = tt .. "\n" .. S("Pushable by players, mobs and objects")
	elseif def.activated_by.mob and def.activated_by.player then
		tt = tt .. "\n" .. S("Pushable by players and mobs")
	elseif def.activated_by.mob then
		tt = tt .. "\n" .. S("Pushable by mobs")
	elseif def.activated_by.player then
		tt = tt .. "\n" .. S("Pushable by players")
	end

	local basename = "mcl_pressureplates:pressure_plate_"..basename
	local commdef = {
		drawtype = "nodebox",
		wield_image = def.texture,
		paramtype = "light",
		walkable = false,
		description = def.description,
		tiles = { def.texture },
		drop = basename.."_off",
		on_timer = update_pp,
		_on_walk_through = function(pos)
			update_pp(vector.round(pos))
		end,
		on_construct = function(pos)
			minetest.get_node_timer(pos):start(PRESSURE_PLATE_INTERVAL)
		end,
		sounds = def.sounds,
		is_ground_content = false,
		_mcl_pressureplate_basename = basename,
		_mcl_pressureplate_activated_by = def.activated_by or { any = true },
		_mcl_pressureplate_weighted = def.weighted,
		_mcl_burntime = def.burntime,
		_mcl_blast_resistance = 0.5,
		_mcl_hardness = 0.5,
		_mcl_redstone = {
			connects_to = function(node)
				return true
			end,
		},
	}

	minetest.register_node(":"..basename.."_off", table.merge(commdef, {
		node_box = pp_box_off,
		selection_box = pp_box_off,
		groups = groups_off,
		_doc_items_longdesc = def.longdesc,
		_tt_help = tt,
	}))
	minetest.register_node(":"..basename.."_on", table.merge(commdef, {
		node_box = pp_box_on,
		selection_box = pp_box_on,
		groups = groups_on,
		description = "",
		_doc_items_create_entry = false,
		_mcl_redstone = table.merge(commdef._mcl_redstone, {
			get_power = function(node, dir)
				return dir.y ~= 1 and node.param2 or 0, dir.y < 0
			end,
		}),
	}))
	minetest.register_craft({
		output = basename.."_off",
		recipe = {{def.recipeitem, def.recipeitem}},
	})

	if minetest.get_modpath("doc") then
		doc.add_entry_alias("nodes", basename .. "_off", "nodes", basename .. "_on")
	end
end

mcl_pressureplates.register_pressure_plate("stone", {
	description = S("Stone Pressure Plate"),
	texture = "default_stone.png",
	recipeitem = "mcl_core:stone",
	sounds = mcl_sounds.node_sound_stone_defaults(),
	groups = {pickaxey=1, material_stone=1},
	activated_by = { player = true, mob = true },
	longdesc = S("A stone pressure plate is a redstone component which supplies its surrounding blocks with redstone power while a player or mob stands on top of it. It is not triggered by anything else."),
})

mcl_pressureplates.register_pressure_plate("polished_blackstone", {
	description = S("Polished Blackstone Pressure Plate"),
	texture = "mcl_blackstone_polished.png",
	recipeitem = "mcl_blackstone:blackstone_polished",
	sounds = mcl_sounds.node_sound_stone_defaults(),
	groups = {pickaxey=1, material_stone=1},
	activated_by = { player = true, mob = true },
	longdesc = S("A polished blackstone pressure plate is a redstone component which supplies its surrounding blocks with redstone power while a player or mob stands on top of it. It is not triggered by anything else."),
})

mcl_pressureplates.register_pressure_plate("light", {
	description = S("Light Weighted Pressure Plate"),
	texture = "default_gold_block.png",
	recipeitem = "mcl_core:gold_ingot",
	sounds = mcl_sounds.node_sound_stone_defaults(),
	groups = {pickaxey=1},
	weighted = 1,
	longdesc = S("A heavy weighted pressure plate is a redstone component which supplies its surrounding blocks with one redstone power for every movable object (including dropped items, players and mobs) that rests on top of it."),
})

mcl_pressureplates.register_pressure_plate("heavy", {
	description = S("Heavy Weighted Pressure Plate"),
	texture = "default_steel_block.png",
	recipeitem = "mcl_core:iron_ingot",
	sounds = mcl_sounds.node_sound_stone_defaults(),
	groups = {pickaxey=1},
	weighted = 10,
	longdesc = S("A heavy weighted pressure plate is a redstone component which supplies its surrounding blocks with one redstone power for every 10 movable objects (including dropped items, players and mobs) that rest on top of it."),
})
