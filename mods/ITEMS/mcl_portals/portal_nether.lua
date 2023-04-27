local S = minetest.get_translator("mcl_portals")

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local portal_search_groups = { "group:building_block", "group:deco_block", "group:liquid" }

local TELEPORT_DELAY = 3
local TELEPORT_COOLOFF = 4

local MIN_PORTAL_NODES = 6
local MAX_PORTAL_NODES = 256

local NETHER_SCALE = 8
local MAP_EDGE = math.floor(mcl_vars.mapgen_limit / (16 * 5)) * 16 * 5 - 16 * 3
local MAP_SIZE = MAP_EDGE * 2

local mod_storage = minetest.get_mod_storage()

-- List of positions of portals in the nether and overworld.
local portals = {
	overworld = {},
	nether = {},
}
for _, portal in pairs(minetest.deserialize(mod_storage:get_string("overworld_portals")) or {}) do
	table.insert(portals["overworld"], vector.copy(portal))
end
for _, portal in pairs(minetest.deserialize(mod_storage:get_string("nether_portals")) or {}) do
	table.insert(portals["nether"], vector.copy(portal))
end

-- The distance portals can be apart and still link.
local link_distance = {
	overworld = 16 * NETHER_SCALE,
	nether = 16,
}

-- The min and max y levels when searching for a place to generate a new nether
-- portal.
local search_y_min = {
	overworld = mcl_vars.mg_bedrock_overworld_min + 1,
	nether = mcl_vars.mg_bedrock_nether_bottom_min + 1,
}
local search_y_max = {
	overworld = mcl_vars.mg_overworld_max_official,
	nether = mcl_vars.mg_bedrock_nether_top_max - 1,
}

-- Table of objects (including players) which were recently teleported by a
-- nether portal. They have a brief cooloff period before they can teleport
-- again. This prevents annoying back-and-forth teleportation.
local portal_cooloff = {}
function mcl_portals.nether_portal_cooloff(object)
	return portal_cooloff[object]
end

local function register_portal(pos)
	y, dim = mcl_worlds.y_to_layer(pos.y)
	table.insert(portals[dim], pos)
	if dim == "overworld" then
		mod_storage:set_string("overworld_portals", minetest.serialize(portals.overworld))
	else
		mod_storage:set_string("nether_portals", minetest.serialize(portals.nether))
	end
end

local function queue()
	return {
		front = 1,
		back = 1,
		queue = {},
		enqueue = function(self, value)
			self.queue[self.back] = value
			self.back = self.back + 1
		end,
		dequeue = function(self) local value = self.queue[self.front]
			if not value then
				return
			end
			self.queue[self.front] = nil
			self.front = self.front + 1
			return value
		end,
		size = function(self)
			return self.back - self.front
		end,
	}
end

-- Rotate vector 90 degrees if 'param2 % 2 == 1'.
local function orient(pos, param2)
	if (param2 % 2) == 1 then
		return vector.new(pos.z, pos.y, pos.x)
	end
	return pos
end

local function check_and_light_shape(pos, param2)
	local portals = {}
	local queue = queue()
	local checked = {}

	queue:enqueue(pos)
	while queue:size() > 0 do
		local pos = queue:dequeue()
		local hash = minetest.hash_node_position(pos)

		if not checked[hash] then
			local name = minetest.get_node(pos).name
			if name == "air" or minetest.get_item_group(name, "fire") ~= 0 then
				queue:enqueue(pos + orient(vector.new(0, -1, 0), param2))
				queue:enqueue(pos + orient(vector.new(0, 1, 0), param2))
				queue:enqueue(pos + orient(vector.new(-1, 0, 0), param2))
				queue:enqueue(pos + orient(vector.new(1, 0, 0), param2))

				if #portals > MAX_PORTAL_NODES then
					return false
				end
				table.insert(portals, pos)
			elseif name ~= "mcl_core:obsidian" then
				return false
			end

			checked[hash] = true
		end
	end

	local center = vector.zero()
	for _, portal in pairs(portals) do
		center = center + portal
	end
	center = center:divide(#portals):round()

	while minetest.get_node(center:offset(0, -1, 0)).name ~= "mcl_core:obsidian" do
		center = center:offset(0, -1, 0)
	end

	if #portals >= MIN_PORTAL_NODES then
		minetest.bulk_set_node(portals, {
			name = "mcl_portals:portal",
			param2 = param2,
		})
		for _, portal in pairs(portals) do
			minetest.get_meta(pos):set_string("portal", minetest.serialize(center))
		end

		register_portal(center)
		return true
	end
	return false
end

-- Attempts to light a nether portal at the specified position. The position
-- must be one of the nodes inside the frame which must be filled only with air
-- and fire. Returns true if portal was created, false otherwise.
function mcl_portals.light_nether_portal(pos)
	local dim = mcl_worlds.pos_to_dimension(pos)
	if dim ~= "overworld" and dim ~= "nether" then
		return
	end

	for orientation = 0, 1 do
		local pos = check_and_light_shape(pos, orientation)
		if pos then
			return pos
		end
	end
	return
end

-- Destroy a nether portal. Connected portal nodes are searched and removed
-- using 'bulk_set_node'. This function is called from 'after_destruct' of
-- portal and obsidian nodes.
--
-- The flag 'destroying_portal' is used to avoid this function being called
-- recursively through callbacks in 'bulk_set_node'.
local destroying_portal = false
local function destroy_portal(pos, node)
	if destroying_portal then
		return
	end
	destroying_portal = true

	local param2 = node.param2
	local checked_tab = { [minetest.hash_node_position(pos)] = true }
	local nodes = { pos }

	local function check_remove(pos)
		local hash = minetest.hash_node_position(pos)
		if checked_tab[hash] then
			return
		end

		local node = minetest.get_node(pos)
		if node and node.name == "mcl_portals:portal" and (param2 == nil or node.param2 == param2) then
			table.insert(nodes, pos)
			checked_tab[hash] = true
		end
	end

	local i = 1
	while i <= #nodes do
		pos = nodes[i]
		if param2 % 2 == 0 then
			check_remove({x = pos.x - 1, y = pos.y, z = pos.z})
			check_remove({x = pos.x + 1, y = pos.y, z = pos.z})
		else
			check_remove({x = pos.x, y = pos.y, z = pos.z - 1})
			check_remove({x = pos.x, y = pos.y, z = pos.z + 1})
		end
		check_remove({x = pos.x, y = pos.y - 1, z = pos.z})
		check_remove({x = pos.x, y = pos.y + 1, z = pos.z})
		i = i + 1
	end

	minetest.bulk_set_node(nodes, { name = "air" })
	destroying_portal = false
end

local longdesc = minetest.registered_nodes["mcl_core:obsidian"]._doc_items_longdesc .. "\n" .. S("Obsidian is also used as the frame of Nether portals.")
local usagehelp = S("To open a Nether portal, place an upright frame of obsidian with a width of at least 4 blocks and a height of 5 blocks, leaving only air in the center. After placing this frame, light a fire in the obsidian frame. Nether portals only work in the Overworld and the Nether.")

minetest.override_item("mcl_core:obsidian", {
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usagehelp,
	after_destruct = function(pos, node)
		local function check_remove(pos, param2)
			if minetest.get_node(pos).name == "mcl_portals:portal" then
				minetest.remove_node(pos)
			end
		end

		check_remove({x = pos.x - 1, y = pos.y, z = pos.z})
		check_remove({x = pos.x + 1, y = pos.y, z = pos.z})
		check_remove({x = pos.x, y = pos.y, z = pos.z - 1})
		check_remove({x = pos.x, y = pos.y, z = pos.z + 1})
		check_remove({x = pos.x, y = pos.y - 1, z = pos.z})
		check_remove({x = pos.x, y = pos.y + 1, z = pos.z})
	end,
	_on_ignite = function(user, pointed_thing)
		local pos = pointed_thing.above
		local portal_placed = mcl_portals.light_nether_portal(pos)
		if portal_placed then
			if minetest.get_modpath("doc") then
				doc.mark_entry_as_revealed(user:get_player_name(), "nodes", "mcl_portals:portal")

				local dim = mcl_worlds.pos_to_dimension(pos)
				if minetest.get_modpath("awards") and dim ~= "nether" and user:is_player() then
					awards.unlock(user:get_player_name(), "mcl:buildNetherPortal")
				end
			end
			return true
		else
			return false
		end
	end,
})

local on_rotate
if minetest.get_modpath("screwdriver") then
	on_rotate = screwdriver.disallow
end

minetest.register_node("mcl_portals:portal", {
	description = S("Nether Portal"),
	_doc_items_longdesc = S("A Nether portal teleports creatures and objects to the hot and dangerous Nether dimension (and back!). Enter at your own risk!"),
	_doc_items_usagehelp = S("Stand in the portal for a moment to activate the teleportation. Entering a Nether portal for the first time will also create a new portal in the other dimension. If a Nether portal has been built in the Nether, it will lead to the Overworld. A Nether portal is destroyed if the any of the obsidian which surrounds it is destroyed, or if it was caught in an explosion."),

	tiles = {
		"blank.png",
		"blank.png",
		"blank.png",
		"blank.png",
		{
			name = "mcl_portals_portal.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1.25,
			},
		},
		{
			name = "mcl_portals_portal.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1.25,
			},
		},
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "blend" or true,
	walkable = false,
	buildable_to = false,
	is_ground_content = false,
	drop = "",
	light_source = 11,
	post_effect_color = {a = 180, r = 51, g = 7, b = 89},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.1,  0.5, 0.5, 0.1},
		},
	},
	groups = { creative_breakable = 1, portal = 1, not_in_creative_inventory = 1 },
	sounds = mcl_sounds.node_sound_glass_defaults(),
	after_destruct = destroy_portal,
	on_rotate = on_rotate,

	_mcl_hardness = -1,
	_mcl_blast_resistance = 0,
})

local function nether_to_overworld(x)
	local x = x * NETHER_SCALE + MAP_EDGE
	return MAP_EDGE - math.abs(x % (2 * MAP_SIZE) - MAP_SIZE)
end

local function overworld_to_nether(x)
	return x / NETHER_SCALE
end

-- Build portal at position facing the direction specified in param2. If
-- bad_spot is true, then it will make a small platform and clear air space
-- above it.
local function build_portal(pos, param2, bad_spot)
	register_portal(pos)

	-- For some reason writing this using minetest.set_node does not work,
	-- since that sometimes triggers on_destruct on the frame obsidian nodes
	-- which removes portal nodes. The solution for now is to use a voxel
	-- manipulator (which does not call on_destruct) to avoid this problem.
        local vm = minetest.get_voxel_manip()
	local emin, emax = vm:read_from_map(pos - vector.new(5, 5, 5), pos + vector.new(5, 5, 5))
	local data = vm:get_data()
	local param2_data = vm:get_param2_data()
	local a = VoxelArea:new{
		MinEdge = emin,
		MaxEdge = emax
	}

	local c_air = minetest.get_content_id("air")
	local c_portal = minetest.get_content_id("mcl_portals:portal")
	local c_obsidian = minetest.get_content_id("mcl_core:obsidian")

	local function index(pos)
		return a:index(pos.x, pos.y, pos.z)
	end

	for i = -2, 1 do
		data[index(pos + orient(vector.new(i, -1, 0), param2))] = c_obsidian
		data[index(pos + orient(vector.new(i, 3, 0), param2))] = c_obsidian
	end

	for i = 0, 2 do
		data[index(pos + orient(vector.new(-2, i, 0), param2))] = c_obsidian
		data[index(pos + orient(vector.new(-1, i, 0), param2))] = c_portal
		param2_data[index(pos + orient(vector.new(-1, i, 0), param2))] = param2
		data[index(pos + orient(vector.new(0, i, 0), param2))] = c_portal
		param2_data[index(pos + orient(vector.new(0, i, 0), param2))] = param2
		data[index(pos + orient(vector.new(1, i, 0), param2))] = c_obsidian
	end

	if bad_spot then
		for i = -1, 2 do
			local content = i == -1 and c_obsidian or c_air
			data[index(pos + orient(vector.new(-1, i, -1), param2))] = content
			data[index(pos + orient(vector.new(0, i, -1), param2))] = content
			data[index(pos + orient(vector.new(-1, i, 1), param2))] = content
			data[index(pos + orient(vector.new(0, i, 1), param2))] = content
		end
	end

	vm:set_data(data)
	vm:set_param2_data(param2_data)
	vm:write_to_map(true)
end

local function finalize_teleport(obj, pos)
	minetest.sound_play("mcl_portals_teleport", { pos = pos, gain = 0.5, max_hear_distance = 16 }, true)
	obj:set_pos(pos)
	if obj:is_player() then
		mcl_worlds.dimension_change(obj)
	end

	minetest.after(TELEPORT_COOLOFF, function(obj)
		portal_cooloff[obj] = false
	end, obj)
end

local function build_portal_and_teleport(obj, src_pos, dst_pos, param2, bad_spot)
	build_portal(dst_pos, param2, bad_spot)
	finalize_teleport(obj, dst_pos)
end

local function can_place_portal(pos, param2)
	local pos1 = pos + orient(vector.new(-2, 0, -1), param2)
	local pos2 = pos + orient(vector.new(1, 0, 1), param2)
	local ground_nodes = minetest.find_nodes_in_area(pos1, pos2, portal_search_groups)
	if #ground_nodes ~= 12 then
		return false
	end

	local air_pos1 = pos + orient(vector.new(-2, 1, -1), param2)
	local air_pos2 = pos + orient(vector.new(1, 4, 1), param2)
	local air_nodes = minetest.find_nodes_in_area(air_pos1, air_pos2, { "air" })
	return #air_nodes == 48 and not minetest.is_area_protected(air_pos1, air_pos2, "")
end

-- Check if object is in portal, returns the (position, node) of the portal if
-- it is, otherwise nil.
local function in_portal(obj)
	local pos = obj:get_pos()
	if not pos then
		return
	end
	pos.y = math.ceil(pos.y)
	pos = vector.round(pos)
	local node = minetest.get_node(pos)
	if node.name == "mcl_portals:portal" then
		return pos, node
	end
end

-- Scan emerged area and build a portal at a suitable spot. If no suitable spot
-- is found, then it will build the portal at a random location.
local function portal_emerge_area(blockpos, action, calls_remaining, param)
	if param.done_flag or calls_remaining ~= 0 then
		return
	end
	local src_pos = param.src_pos
	local minpos = param.minpos
	local maxpos = param.maxpos
	local param2 = param.param2
	local obj = param.obj

	-- Since there is a significant delay until the callback is run, we do
	-- another check if the player is still standing in the portal.
	if not in_portal(obj) then
		portal_cooloff[obj] = false
	end

	local function finalize(obj, src_pos, pos, param2, bad_pos)
		-- Move portal down one node if on snow cover or grass.
		if minetest.get_item_group(minetest.get_node(pos).name, "deco_block") > 0 then
			pos.y = pos.y - 1
		end

		pos = vector.new(pos.x, pos.y + 1, pos.z)
		build_portal_and_teleport(obj, src_pos, pos, param2, bad_pos)
		param.done_flag = true
	end

	local liquid_pos
	local nodes = minetest.find_nodes_in_area_under_air(minpos, maxpos, portal_search_groups)
	for _, pos in pairs(nodes) do
		if can_place_portal(pos, param2) then
			if not (minetest.get_item_group(minetest.get_node(pos).name, "liquid") > 0) then
				finalize(obj, src_pos, pos, param2, false)
				return
			end
			liquid_pos = pos
		end
	end

	if liquid_pos then
		finalize(obj, src_pos, liquid_pos, param2, true)
		return
	end

	local dst_pos = vector.new(
		math.random(minpos.x, maxpos.x),
		math.random(minpos.y, maxpos.y),
		math.random(minpos.z, maxpos.z)
	)
	finalize(obj, src_pos, dst_pos, param2, true)
end

local function get_teleport_target(pos)
	local y, dim = mcl_worlds.y_to_layer(pos.y)
	if not y then
		return
	end

	local scale = {
		nether = nether_to_overworld,
		overworld = overworld_to_nether,
	}
	if dim == "overworld" then
		return "nether", vector.new(overworld_to_nether(pos.x), 0, overworld_to_nether(pos.z))
	end
	return "overworld", vector.new(nether_to_overworld(pos.x), 0, nether_to_overworld(pos.z))
end

local function portal_distance(a, b)
	return math.max(math.abs(a.x - b.x), math.abs(math.abs(a.z - b.z)))
end

local function get_linked_portal(dim, pos)
	closest = nil
	for _, portal in pairs(portals[dim]) do
		if not closest or portal_distance(portal, pos) < portal_distance(closest, pos) then
			closest = portal
		end
	end

	if closest and portal_distance(closest, pos) < link_distance[dim] then
		return closest
	end
end

local function teleport(obj)
	local pos, portal_node = in_portal(obj)
	if not pos or portal_cooloff[obj] then
		return
	end
	portal_cooloff[obj] = true

	local dim, target = get_teleport_target(pos)
	local dst_pos = get_linked_portal(dim, target)
	if dst_pos then
		finalize_teleport(obj, dst_pos)
	elseif obj:is_player() then
		local param2 = portal_node.param2
		local y_min = search_y_min[dim]
		local y_max = search_y_max[dim]
		local minpos = vector.new(target.x - 16, y_min, target.z - 16)
		local maxpos = vector.new(target.x + 16, y_max, target.z + 16)
		minetest.emerge_area(minpos, maxpos, portal_emerge_area, {
			src_pos = pos,
			obj = obj,
			param2 = param2,
			minpos = minpos,
			maxpos = maxpos,
			done_flag = false,
		})
	end
end

local function initiate_teleport(obj)
	minetest.after(TELEPORT_DELAY, function()
		teleport(obj)
	end)
end

local function teleport_objs_in_portal(pos)
	for _, obj in pairs(minetest.get_objects_inside_radius(pos, 1)) do
		local lua_entity = obj:get_luaentity()
		if obj:is_player() or lua_entity then
			initiate_teleport(obj)
		end
	end
end

local function emit_portal_particles(pos, node)
	local param2 = node.param2
	local direction = math.random(0, 1)
	local time = math.random() * 1.9 + 0.5

	local velocity = vector.new(math.random() - 0.5, math.random() - 0.5, math.random() * 0.7 + 0.3)
	local acceleration = vector.new(math.random() - 0.5, math.random() - 0.5, math.random() * 1.1 + 0.3)
	if param2 % 2 == 1 then
		velocity.x, velocity.z = velocity.z, velocity.x
		acceleration.x, acceleration.z = acceleration.z, acceleration.x
	end
	local distance = vector.add(vector.multiply(velocity, time), vector.multiply(acceleration, time * time / 2))
	if direction == 1 then
		if param2 % 2 == 1 then
			distance.x = -distance.x
			velocity.x = -velocity.x
			acceleration.x = -acceleration.x
		else
			distance.z = -distance.z
			velocity.z = -velocity.z
			acceleration.z = -acceleration.z
		end
	end
	distance = vector.subtract(pos, distance)
	for _, obj in pairs(minetest.get_objects_inside_radius(pos, 15)) do
		if obj:is_player() then
			minetest.add_particle({
				amount = 1,
				pos = distance,
				velocity = velocity,
				acceleration = acceleration,
				expiration_time = time,
				size = 0.3 + math.random() * (1.8 - 0.3),
				collisiondetection = false,
				texture = "mcl_particles_nether_portal.png",
				playername = obj:get_player_name(),
			})
		end
	end
end


minetest.register_abm({
	label = "Nether portal teleportation and particles",
	nodenames = { "mcl_portals:portal" },
	interval = 1,
	chance = 2,
	action = function(pos, node)
		emit_portal_particles(pos, node)
		teleport_objs_in_portal(pos)
	end,
})

mcl_structures.register_structure("nether_portal",{
	nospawn = true,
	filenames = {
		modpath.."/schematics/mcl_portals_nether_portal.mts"
	},
})

mcl_structures.register_structure("nether_portal_open",{
	nospawn = true,
	filenames = {
		modpath.."/schematics/mcl_portals_nether_portal_open.mts"
	},
})
