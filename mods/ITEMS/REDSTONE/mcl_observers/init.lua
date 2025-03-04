local S = minetest.get_translator(minetest.get_current_modname())

mcl_observers = {}

function mcl_observers.observer_activate(pos)
	local oldnode = minetest.get_node(pos)
	mcl_redstone.after(1, function()
		local node = minetest.get_node(pos)
		if oldnode.name ~= node.name or oldnode.param2 ~= node.param2 then
			return
		end
		local ndef = minetest.registered_nodes[node.name]
		minetest.set_node(pos, {name = ndef._mcl_observer_on, param2 = node.param2})
	end)
end

-- Scan the node in front of the observer and update the observer state if
-- needed.
--
-- TODO: Also scan metadata changes.
-- TODO: Ignore some node changes.
local function observer_scan(pos, initialize)
	local node = minetest.get_node(pos)
	local front
	if node.name == "mcl_observers:observer_up_off" or node.name == "mcl_observers:observer_up_on" then
		front = vector.add(pos, {x=0, y=1, z=0})
	elseif node.name == "mcl_observers:observer_down_off" or node.name == "mcl_observers:observer_down_on" then
		front = vector.add(pos, {x=0, y=-1, z=0})
	else
		front = vector.add(pos, minetest.facedir_to_dir(node.param2))
	end
	local frontnode = minetest.get_node(front)
	local meta = minetest.get_meta(pos)
	local oldnode = meta:get_string("node_name")
	local oldparam2 = meta:get_string("node_param2")
	local meta_needs_updating = false
	if oldnode ~= "" and not initialize then
		if not (frontnode.name == oldnode and tostring(frontnode.param2) == oldparam2) then
			-- Node state changed! Activate observer
			local ndef = minetest.registered_nodes[node.name]
			minetest.set_node(pos, {name = ndef._mcl_observer_on, param2 = node.param2})
			meta_needs_updating = true
		end
	else
		meta_needs_updating = true
	end
	if meta_needs_updating then
		meta:set_string("node_name", frontnode.name)
		meta:set_string("node_param2", tostring(frontnode.param2))
	end
	return frontnode
end


-- Vertical orientation (CURRENTLY DISABLED)
local function observer_orientate(pos, placer)
	-- Not placed by player
	if not placer then return end

	-- Placer pitch in degrees
	local pitch = placer:get_look_vertical() * (180 / math.pi)

	--local node = minetest.get_node(pos)
	if pitch > 55 then -- player looking upwards
		-- Observer looking downwards
		minetest.set_node(pos, {name="mcl_observers:observer_down_off"})
	elseif pitch < -55 then -- player looking downwards
		-- Observer looking upwards
		minetest.set_node(pos, {name="mcl_observers:observer_up_off"})
	end
end

local commdef = {
	is_ground_content = false,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	on_rotate = false,
	groups = {pickaxey=1, material_stone=1, not_opaque=1, },
	_mcl_blast_resistance = 3.5,
	_mcl_hardness = 3.5,
	drop = "mcl_observers:observer_off",
	on_construct = function(pos)
		local timer = minetest.get_node_timer(pos)
		if not timer:is_started() then
			timer:start(mcl_redstone.tick_speed)
		end
	end,
	_mcl_redstone = {},
}
local commdef_off = table.merge(commdef, {
	groups = table.merge(commdef.groups, {observer=1}),
	on_timer = function(pos, elapsed)
		observer_scan(pos)
		return true
	end,
})
local commdef_on = table.merge(commdef, {
	_doc_items_create_entry = false,
	groups = table.merge(commdef.groups, {observer=2}),
	on_timer = function(pos, elapsed)
		local node = minetest.get_node(pos)
		local ndef = minetest.registered_nodes[node.name]
		minetest.set_node(pos, {
			name = ndef._mcl_observer_off,
			param2 = node.param2,
		})
	end,
})

minetest.register_node("mcl_observers:observer_off", table.merge(commdef_off, {
	paramtype2 = "facedir",
	description = S("Observer"),
	groups = table.merge(commdef_off.groups),
	_tt_help = S("Emits redstone pulse when block in front changes"),
	_doc_items_longdesc = S("An observer is a redstone component which observes the block in front of it and sends a very short redstone pulse whenever this block changes."),
	_doc_items_usagehelp = S("Place the observer directly in front of the block you want to observe with the “face” looking at the block. The arrow points to the side of the output, which is at the opposite side of the “face”. You can place your redstone dust or any other component here."),

	tiles = {
		"mcl_observers_observer_top.png^[transformR180", "default_furnace_bottom.png",
		"mcl_observers_observer_side.png", "mcl_observers_observer_side.png",
		"mcl_observers_observer_front.png", "mcl_observers_observer_back.png",
	},
	after_place_node = observer_orientate,
	_mcl_observer_on = "mcl_observers:observer_on",
	_mcl_observer_off = "mcl_observers:observer_off",
	_mcl_redstone = table.merge(commdef_off._mcl_redstone, {
		connects_to = function(node, dir)
			local dir2 = -minetest.facedir_to_dir(node.param2)
			return dir2 == dir
		end,
	}),
}))
minetest.register_node("mcl_observers:observer_on", table.merge(commdef_on, {
	paramtype2 = "facedir",
	groups = table.merge(commdef_on.groups, {not_in_creative_inventory=1}),
	tiles = {
		"mcl_observers_observer_top.png^[transformR180", "default_furnace_bottom.png",
		"mcl_observers_observer_side.png", "mcl_observers_observer_side.png",
		"mcl_observers_observer_front.png", "mcl_observers_observer_back_lit.png",
	},
	_mcl_observer_on = "mcl_observers:observer_on",
	_mcl_observer_off = "mcl_observers:observer_off",
	_mcl_redstone = table.merge(commdef_on._mcl_redstone, {
		connects_to = function(node, dir)
			local dir2 = -minetest.facedir_to_dir(node.param2)
			return dir2 == dir
		end,
		get_power = function(node, dir)
			local dir2 = -minetest.facedir_to_dir(node.param2)
			return dir2 == dir and 15 or 0, true
		end,
	})
}))

minetest.register_node("mcl_observers:observer_down_off", table.merge(commdef_off, {
	_doc_items_create_entry = false,
	groups = table.merge(commdef_off.groups, {not_in_creative_inventory=1}),
	tiles = {
		"mcl_observers_observer_back.png", "mcl_observers_observer_front.png",
		"mcl_observers_observer_side.png^[transformR90", "mcl_observers_observer_side.png^[transformR90",
		"mcl_observers_observer_top.png", "mcl_observers_observer_top.png",
	},
	_mcl_observer_on = "mcl_observers:observer_down_on",
	_mcl_observer_off = "mcl_observers:observer_down_off",
}))
minetest.register_node("mcl_observers:observer_down_on", table.merge(commdef_on, {
	groups = table.merge(commdef_on.groups, {not_in_creative_inventory=1}),
	tiles = {
		"mcl_observers_observer_back_lit.png", "mcl_observers_observer_front.png",
		"mcl_observers_observer_side.png^[transformR90", "mcl_observers_observer_side.png^[transformR90",
		"mcl_observers_observer_top.png", "mcl_observers_observer_top.png",
	},
	_mcl_observer_on = "mcl_observers:observer_down_on",
	_mcl_observer_off = "mcl_observers:observer_down_off",
	_mcl_redstone = table.merge(commdef_on._mcl_redstone, {
		get_power = function(node, dir)
			return dir.y > 0 and 15 or 0, true
		end,
	})
}))

minetest.register_node("mcl_observers:observer_up_off", table.merge(commdef_off, {
	_doc_items_create_entry = false,
	groups = table.merge(commdef_off.groups, {not_in_creative_inventory=1}),
	tiles = {
		"mcl_observers_observer_front.png", "mcl_observers_observer_back.png",
		"mcl_observers_observer_side.png^[transformR270", "mcl_observers_observer_side.png^[transformR270",
		"mcl_observers_observer_top.png^[transformR180", "mcl_observers_observer_top.png^[transformR180",
	},
	_mcl_observer_on = "mcl_observers:observer_up_on",
	_mcl_observer_off = "mcl_observers:observer_up_off",
}))
minetest.register_node("mcl_observers:observer_up_on", table.merge(commdef_on, {
	groups = table.merge(commdef_on.groups, {not_in_creative_inventory=1}),
	tiles = {
		"mcl_observers_observer_front.png", "mcl_observers_observer_back_lit.png",
		"mcl_observers_observer_side.png^[transformR270", "mcl_observers_observer_side.png^[transformR270",
		"mcl_observers_observer_top.png^[transformR180", "mcl_observers_observer_top.png^[transformR180",
	},
	_mcl_observer_on = "mcl_observers:observer_up_on",
	_mcl_observer_off = "mcl_observers:observer_up_off",
	_mcl_redstone = table.merge(commdef_on._mcl_redstone, {
		get_power = function(node, dir)
			return dir.y < 0 and 15 or 0, true
		end,
	})
}))

minetest.register_craft({
	output = "mcl_observers:observer_off",
	recipe = {
		{ "mcl_core:cobble", "mcl_core:cobble", "mcl_core:cobble" },
		{ "mcl_nether:quartz", "mcl_redstone:redstone", "mcl_redstone:redstone" },
		{ "mcl_core:cobble", "mcl_core:cobble", "mcl_core:cobble" },
	},
})
minetest.register_craft({
	output = "mcl_observers:observer_off",
	recipe = {
		{ "mcl_core:cobble", "mcl_core:cobble", "mcl_core:cobble" },
		{ "mcl_redstone:redstone", "mcl_redstone:redstone", "mcl_nether:quartz" },
		{ "mcl_core:cobble", "mcl_core:cobble", "mcl_core:cobble" },
	},
})

minetest.register_lbm({
	name = "mcl_observers:turn_off",
	nodenames = {
		"mcl_observers:observer_on",
		"mcl_observers:observer_down_on",
		"mcl_observers:observer_up_on",
		"mcl_observers:observer_off",
		"mcl_observers:observer_down_off",
		"mcl_observers:observer_up_off",
	},
	run_at_every_load = true,
	action = function(pos)
		local node = minetest.get_node(pos)
		local ndef = minetest.registered_nodes[node.name]
		minetest.set_node(pos, { name = ndef._mcl_observer_off, param2 = node.param2 })
	end,
})

doc.add_entry_alias("nodes", "mcl_observers:observer_off", "nodes", "mcl_observers:observer_on")
doc.add_entry_alias("nodes", "mcl_observers:observer_off", "nodes", "mcl_observers:observer_down_on")
doc.add_entry_alias("nodes", "mcl_observers:observer_off", "nodes", "mcl_observers:observer_up_on")
doc.add_entry_alias("nodes", "mcl_observers:observer_off", "nodes", "mcl_observers:observer_off")
doc.add_entry_alias("nodes", "mcl_observers:observer_off", "nodes", "mcl_observers:observer_down_off")
doc.add_entry_alias("nodes", "mcl_observers:observer_off", "nodes", "mcl_observers:observer_up_off")
