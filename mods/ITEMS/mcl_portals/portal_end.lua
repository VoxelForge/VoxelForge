local S = minetest.get_translator(minetest.get_current_modname())

local has_doc = minetest.get_modpath("doc")
mcl_portals.registered_on_beat_game = {}
function mcl_portals.register_on_beat_game(func)
	table.insert(mcl_portals.registered_on_beat_game, func)
end
-- Parameters
--local SPAWN_MIN = mcl_vars.mg_end_min+70
--local SPAWN_MAX = mcl_vars.mg_end_min+98

--local mg_name = minetest.get_mapgen_setting("mg_name")

local function destroy_portal(pos)
	local neighbors = {
		{ x=1, y=0, z=0 },
		{ x=-1, y=0, z=0 },
		{ x=0, y=0, z=1 },
		{ x=0, y=0, z=-1 },
	}
	for n=1, #neighbors do
		local npos = vector.add(pos, neighbors[n])
		if minetest.get_node(npos).name == "mcl_portals:portal_end" then
			minetest.remove_node(npos)
		end
	end
end

local function check_spawn_space(pos, size, y_offset)
    y_offset = y_offset or 1
    local half = math.floor(size / 2)
    local pos1 = {
        x = pos.x - half,
        y = pos.y + y_offset,
        z = pos.z - half
    }
    local pos2 = {
        x = pos.x + half - (size % 2 == 0 and 1 or 0),
        y = pos.y + y_offset + size - 1,
        z = pos.z + half - (size % 2 == 0 and 1 or 0)
    }
    local air_nodes = minetest.find_nodes_in_area(pos1, pos2, {"air"})
    local required_air = size * size * size
    return #air_nodes == required_air
end

local function find_valid_spawn(target, attempts)
	local minp, maxp = vector.subtract(target,8), vector.add(target,8)
	core.load_area(minp, maxp)
	attempts = attempts or 1
	if attempts > 10 then
		return mcl_spawn.get_world_spawn_pos()
	end
	local nn = minetest.find_nodes_in_area_under_air(minp,maxp,{"group:solid"})
	if #nn > 0 then
		for _, n in pairs(nn) do
			if check_spawn_space(n, 2) then
				return vector.offset(n,-0.5,1,-0.5)
			end
		end
		return find_valid_spawn(vector.add(target,attempts), attempts + 1)
	else
		return find_valid_spawn(vector.add(target,attempts), attempts + 1)
	end
end

local ep_scheme = {
	{ o={x=0, y=0, z=1}, p=1 },
	{ o={x=0, y=0, z=2}, p=1 },
	{ o={x=0, y=0, z=3}, p=1 },
	{ o={x=1, y=0, z=4}, p=2 },
	{ o={x=2, y=0, z=4}, p=2 },
	{ o={x=3, y=0, z=4}, p=2 },
	{ o={x=4, y=0, z=3}, p=3 },
	{ o={x=4, y=0, z=2}, p=3 },
	{ o={x=4, y=0, z=1}, p=3 },
	{ o={x=3, y=0, z=0}, p=0 },
	{ o={x=2, y=0, z=0}, p=0 },
	{ o={x=1, y=0, z=0}, p=0 },
}

-- End portal
minetest.register_node("mcl_portals:portal_end", {
	description = S("End Portal"),
	_tt_help = S("Used to construct end portals"),
	_doc_items_longdesc = S("An End portal teleports creatures and objects to the mysterious End dimension (and back!)."),
	_doc_items_usagehelp = S("Hop into the portal to teleport. Entering an End portal in the Overworld teleports you to a fixed position in the End dimension and creates a 5×5 obsidian platform at your destination. End portals in the End will lead back to your spawn point in the Overworld."),
	tiles = {
		{
			name = "mcl_portals_end_portal.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1.0,
			},
		},
		{
			name = "mcl_portals_end_portal.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 6.0,
			},
		},
		"blank.png",
	},
	drawtype = "nodebox",
	paramtype = "light",
	sunlight_propagates = true,
	use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "blend" or true,
	walkable = false,
	diggable = false,
	buildable_to = false,
	is_ground_content = false,
	drop = "",
	light_source = minetest.LIGHT_MAX,
	post_effect_color = {a = 192, r = 0, g = 0, b = 0},
	after_destruct = destroy_portal,
	-- This prevents “falling through”
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -7/16, 0.5},
		},
	},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 4/16, 0.5},
		},
	},
	groups = {portal=1, not_in_creative_inventory = 1, disable_jump = 1, unmovable_by_piston = 1},

	_mcl_hardness = -1,
	_mcl_blast_resistance = 3600000,
})

-- Check if pos is part of a valid end portal frame, filled with eyes of ender.
local function check_end_portal_frame(pos)
	for i = 1, 12 do
		local pos0 = vector.subtract(pos, ep_scheme[i].o)
		local portal = true
		for j = 1, 12 do
			local p = vector.add(pos0, ep_scheme[j].o)
			local node = minetest.get_node(p)
			if not node or node.name ~= "mcl_portals:end_portal_frame_eye" or node.param2 ~= ep_scheme[j].p then
				portal = false
				break
			end
		end
		if portal then
			return true, {x=pos0.x+1, y=pos0.y, z=pos0.z+1}
		end
	end
	return false
end

-- Generate or destroy a 3×3 end portal beginning at pos. To be used to fill an end portal framea.
-- If destroy == true, the 3×3 area is removed instead.
local function end_portal_area(pos, destroy)
	local SIZE = 3
	local name
	if destroy then
		name = "air"
	else
		name = "mcl_portals:portal_end"
	end
	local posses = {}
	for x=pos.x, pos.x+SIZE-1 do
		for z=pos.z, pos.z+SIZE-1 do
			table.insert(posses, {x=x,y=pos.y,z=z})
		end
	end
	minetest.bulk_set_node(posses, {name=name})
end

local function show_credits(player)
	local meta = player:get_meta()
	local completed_end = meta:get_int("completed_end")

	if completed_end == 0 and minetest.is_singleplayer() then
		meta:set_int("completed_end", 1)
		for _, func in ipairs(mcl_portals.registered_on_beat_game) do
			func(player)
		end
		mcl_credits.show(player)
	end
end

local function teleport_object(obj, target, original_dim)
	obj:set_pos(target)
	minetest.sound_play("mcl_portals_teleport", {pos=target, gain=0.05, max_hear_distance = 16}, true)

	if obj:is_player() then
		-- Look towards the main End island
		if original_dim ~= "end" then
			obj:set_look_horizontal(math.pi/2)
		-- Show credits
		else
			show_credits(obj)
		end
		mcl_worlds.dimension_change(obj, mcl_worlds.pos_to_dimension(target))
	else
		local l = obj:get_luaentity()
		if l and l.is_mob then
			l._just_portaled = 5
		end
	end
end

function mcl_portals.end_teleport(obj, pos)
	if not obj then return end
	local pos = pos or obj:get_pos()
	if not pos then return end
	local dim = mcl_worlds.pos_to_dimension(pos)

	local target, player_spawn
	if dim == "end" then
		-- End portal in the End:
		-- Teleport back to the player's spawn or world spawn in the Overworld.
		if obj:is_player() then
			target, player_spawn = mcl_spawn.get_player_spawn_pos(obj)
		end

		if not target or not player_spawn then
			target = find_valid_spawn(mcl_spawn.get_world_spawn_pos())
		end
		teleport_object(obj, target, dim)
	else
		-- End portal in any other dimension:
		-- Teleport to the End at a fixed position.
		-- The destination is built by mcl_structures.

		core.load_area(vector.subtract(mcl_vars.mg_end_platform_pos, 8), vector.add(mcl_vars.mg_end_platform_pos, 8))
		mcl_structures.place_structure(mcl_vars.mg_end_platform_pos, mcl_structures.registered_structures["end_spawn_obsidian_platform"], PseudoRandom(minetest.get_mapgen_setting("seed")),-1)
		teleport_object(obj, vector.offset(mcl_vars.mg_end_platform_pos, 0, 1, 0), dim)
	end
end

function mcl_portals.end_portal_teleport(pos)
	for obj in minetest.objects_inside_radius(pos, 1) do
		local lua_entity = obj:get_luaentity()
		if obj:is_player() or lua_entity then
			local objpos = obj:get_pos()
			if objpos == nil then
				return
			end

			-- Check if object is actually in portal.
			objpos.y = math.ceil(objpos.y)
			if minetest.get_node(objpos).name ~= "mcl_portals:portal_end" then
				return
			end

			if obj:is_player() and mcl_player.players[obj].attached == true then --luacheck: ignore 542 (empty if branch)
				-- do nothing if player is attached to something in portal
			else
				mcl_portals.end_teleport(obj, objpos)
				awards.unlock(obj:get_player_name(), "mcl:enterEndPortal")
			end
		end
	end
end

minetest.register_abm({
	label = "End portal teleportation",
	nodenames = {"mcl_portals:portal_end"},
	interval = 0.1,
	chance = 1,
	action = mcl_portals.end_portal_teleport,
})

local rotate_frame, rotate_frame_eye

if minetest.get_modpath("screwdriver") then
	-- Intentionally not rotatable
	rotate_frame = false
	rotate_frame_eye = false
end

local function after_place_node(pos, placer, itemstack, pointed_thing) ---@diagnostic disable-line: unused-local
	local node = minetest.get_node(pos)
	if node then
		node.param2 = (node.param2+2) % 4
		minetest.swap_node(pos, node)

		local ok, ppos = check_end_portal_frame(pos)
		if ok then
			-- Epic 'portal open' sound effect that can be heard everywhere
			minetest.sound_play("mcl_portals_open_end_portal", {gain=0.8}, true)
			end_portal_area(ppos)
		end
	end
end

minetest.register_node("mcl_portals:end_portal_frame", {
	description = S("End Portal Frame"),
	_tt_help = S("Used to construct end portals"),
	_doc_items_longdesc = S("End portal frames are used in the construction of End portals. Each block has a socket for an eye of ender.") .. "\n" .. S("NOTE: The End dimension is currently incomplete and might change in future versions."),
	_doc_items_usagehelp = S("To create an End portal, you need 12 end portal frames and 12 eyes of ender. The end portal frames have to be arranged around a horizontal 3×3 area with each block facing inward. Any other arrangement will fail.") .. "\n" .. S("Place an eye of ender into each block. The end portal appears in the middle after placing the final eye.") .. "\n" .. S("Once placed, an eye of ender can not be taken back."),
	groups = { creative_breakable = 1, deco_block = 1, end_portal_frame = 1, unmovable_by_piston = 1, pathfinder_partial = 2},
	tiles = { "mcl_portals_endframe_top.png", "mcl_portals_endframe_bottom.png", "mcl_portals_endframe_side.png" },
	use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "opaque" or false,
	paramtype2 = "facedir",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = { -0.5, -0.5, -0.5, 0.5, 5/16, 0.5 },
	},
	is_ground_content = false,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	paramtype = "light",
	light_source = 1,

	on_rotate = rotate_frame,

	after_place_node = after_place_node,

	_mcl_blast_resistance = 36000000,
	_mcl_hardness = -1,
})

minetest.register_node("mcl_portals:end_portal_frame_eye", {
	description = S("End Portal Frame with Eye of Ender"),
	_tt_help = S("Used to construct end portals"),
	_doc_items_create_entry = false,
	groups = { creative_breakable = 1, deco_block = 1, comparator_signal = 15, end_portal_frame = 2, not_in_creative_inventory = 1, unmovable_by_piston = 1, pathfinder_partial = 2},
	tiles = { "mcl_portals_endframe_top.png^[lowpart:75:mcl_portals_endframe_eye.png", "mcl_portals_endframe_bottom.png", "mcl_portals_endframe_eye.png^mcl_portals_endframe_side.png" },
	use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "opaque" or false,
	paramtype2 = "facedir",
	drawtype = "nodebox",
	_mcl_baseitem = "mcl_portals:end_portal_frame",
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.5, -0.5, -0.5, 0.5, 5/16, 0.5 }, -- Frame
			{ -4/16, 5/16, -4/16, 4/16, 0.5, 4/16 }, -- Eye
		},
	},
	is_ground_content = false,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	paramtype = "light",
	light_source = 1,
	on_destruct = function(pos)
		local ok, ppos = check_end_portal_frame(pos)
		if ok then
			end_portal_area(ppos, true)
		end
	end,

	on_rotate = rotate_frame_eye,

	after_place_node = after_place_node,

	_mcl_blast_resistance = 36000000,
	_mcl_hardness = -1,
})

if has_doc then
	doc.add_entry_alias("nodes", "mcl_portals:end_portal_frame", "nodes", "mcl_portals:end_portal_frame_eye")
end


--[[ ITEM OVERRIDES ]]

-- Portal opener
local old_on_place = minetest.registered_items["mcl_end:ender_eye"].on_place
minetest.override_item("mcl_end:ender_eye", {
	on_place = function(itemstack, user, pointed_thing)

		local rc = mcl_util.call_on_rightclick(itemstack, user, pointed_thing)
		if rc then return rc end

		local node = minetest.get_node(pointed_thing.under)
		-- Place eye of ender into end portal frame
		if pointed_thing.under and node.name == "mcl_portals:end_portal_frame" then
			local protname = user:get_player_name()
			if minetest.is_protected(pointed_thing.under, protname) then
				minetest.record_protection_violation(pointed_thing.under, protname)
				return itemstack
			end
			minetest.set_node(pointed_thing.under, { name = "mcl_portals:end_portal_frame_eye", param2 = node.param2 })

			if has_doc then
				doc.mark_entry_as_revealed(user:get_player_name(), "nodes", "mcl_portals:end_portal_frame")
			end
			core.sound_play(
				"mcl_portals_place_frame_eye_"..math.random(1,3),
				{pos = pointed_thing.under, gain = 0.5, max_hear_distance = 16}, true)
			if not minetest.is_creative_enabled(user:get_player_name()) then
				itemstack:take_item() -- 1 use
			end

			local ok, ppos = check_end_portal_frame(pointed_thing.under)
			if ok then
				-- Epic 'portal open' sound effect that can be heard everywhere
				minetest.sound_play("mcl_portals_open_end_portal", {gain=0.8}, true)
				end_portal_area(ppos)
				if has_doc then
					doc.mark_entry_as_revealed(user:get_player_name(), "nodes", "mcl_portals:portal_end")
				end
			end
		elseif old_on_place then
			return old_on_place(itemstack, user, pointed_thing)
		end
		return itemstack
	end,
})
