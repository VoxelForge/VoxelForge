local S = minetest.get_translator(minetest.get_current_modname())
local F = minetest.formspec_escape
local C = minetest.colorize

local get_double_container_neighbor_pos = vlf_util.get_double_container_neighbor_pos

local sf = string.format

-- Chest Entity
-- ============
-- This is necessary to show the chest as an animated mesh, as Minetest doesn't
-- support assigning animated meshes to nodes directly. We're bypassing this
-- limitation by giving each chest its own entity, and making the chest node
-- itself fully transparent.
local animated_chests = (minetest.settings:get_bool("animated_chests") ~= false)
local entity_animations = {
	shulker = {
		speed = 50,
		open = { x = 45, y = 95 },
		close = { x = 95, y = 145 },
	},
	chest = {
		speed = 25,
		open = { x = 0, y = 7 },
		close = { x = 13, y = 20 },
	},
}
local drop_items_chest = vlf_util.drop_items_from_meta_container("main")

minetest.register_entity("vlf_chests:chest", {
	initial_properties = {
		visual = "mesh",
		pointable = false,
		physical = false,
		static_save = false,
	},

	set_animation = function(self, animname)
		local anim_table = entity_animations[self.animation_type]
		local anim = anim_table[animname]
		if not anim then return end
		self.object:set_animation(anim, anim_table.speed, 0, false)
	end,

	open = function(self, playername)
		self.players[playername] = true
		if not self.is_open then
			self:set_animation("open")
			minetest.sound_play(self.sound_prefix .. "_open", { pos = self.node_pos, gain = 0.5, max_hear_distance = 16 },
				true)
			self.is_open = true
		end
	end,

	close = function(self, playername)
		local playerlist = self.players
		playerlist[playername] = nil
		if self.is_open then
			if next(playerlist) then
				return
			end
			self:set_animation("close")
			minetest.sound_play(self.sound_prefix .. "_close",
				{ pos = self.node_pos, gain = 0.3, max_hear_distance = 16 },
				true)
			self.is_open = false
		end
	end,

	initialize = function(self, node_pos, node_name, textures, dir, double, sound_prefix, mesh_prefix, animation_type)
		self.node_pos = node_pos
		self.node_name = node_name
		self.sound_prefix = sound_prefix
		self.animation_type = animation_type
		local obj = self.object
		obj:set_armor_groups({ immortal = 1 })
		obj:set_properties({
			textures = textures,
			mesh = mesh_prefix .. (double and "_double" or "") .. ".b3d",
		})
		self:set_yaw(dir)
		self.players = {}
	end,

	reinitialize = function(self, node_name)
		self.node_name = node_name
	end,

	set_yaw = function(self, dir)
		self.object:set_yaw(minetest.dir_to_yaw(dir))
	end,

	check = function(self)
		local node_pos, node_name = self.node_pos, self.node_name
		if not node_pos or not node_name then
			return false
		end
		local node = minetest.get_node(node_pos)
		if node.name ~= node_name then
			return false
		end
		return true
	end,

	on_activate = function(self, initialization_data)
		if initialization_data and initialization_data:find("\"###vlf_chests:chest###\"") then
			self:initialize(unpack(minetest.deserialize(initialization_data)))
		else
			minetest.log("warning",
				"[vlf_chests] on_activate called without proper initialization_data ... removing entity")
			self.object:remove()
		end
	end,

	on_step = function(self, dtime)
		if not self:check() then
			self.object:remove()
		end
	end
})

local function get_entity_pos(pos, dir, double)
	pos = vector.copy(pos)
	if double then
		local add, mul, vec, cross = vector.add, vector.multiply, vector.new, vector.cross
		pos = add(pos, mul(cross(dir, vec(0, 1, 0)), -0.5))
	end
	return pos
end

local function find_entity(pos)
	for _, obj in pairs(minetest.get_objects_inside_radius(pos, 0)) do
		local luaentity = obj:get_luaentity()
		if luaentity and luaentity.name == "vlf_chests:chest" then
			return luaentity
		end
	end
end

local function get_entity_info(pos, param2, double, dir, entity_pos)
	dir = dir or minetest.facedir_to_dir(param2)
	return dir, get_entity_pos(pos, dir, double)
end

local function create_entity(pos, node_name, textures, param2, double, sound_prefix, mesh_prefix, animation_type, dir,
							entity_pos)
	dir, entity_pos = get_entity_info(pos, param2, double, dir, entity_pos)
	local initialization_data = minetest.serialize({pos, node_name, textures, dir, double, sound_prefix,
		mesh_prefix, animation_type, "###vlf_chests:chest###"})
	local obj = minetest.add_entity(entity_pos, "vlf_chests:chest", initialization_data)
	if obj and obj:get_pos() then
		return obj:get_luaentity()
	else
		minetest.log("warning", "[vlf_chests] Failed to create entity at " .. (entity_pos and minetest.pos_to_string(entity_pos, 1) or "nil"))
	end
end
vlf_chests.create_entity = create_entity

local function find_or_create_entity(pos, node_name, textures, param2, double, sound_prefix, mesh_prefix,
							animation_type, dir, entity_pos)
	dir, entity_pos = get_entity_info(pos, param2, double, dir, entity_pos)
	return find_entity(entity_pos) or
		create_entity(pos, node_name, textures, param2, double, sound_prefix, mesh_prefix, animation_type, dir,
			entity_pos)
end
vlf_chests.find_or_create_entity = find_or_create_entity

local no_rotate, simple_rotate
if screwdriver then
	no_rotate = screwdriver.disallow
	simple_rotate = function(pos, node, user, mode, new_param2)
		if screwdriver.rotate_simple(pos, node, user, mode, new_param2) ~= false then
			local nodename = node.name
			local nodedef = minetest.registered_nodes[nodename]
			local dir = minetest.facedir_to_dir(new_param2)
			find_or_create_entity(pos, nodename, nodedef._chest_entity_textures, new_param2, false,
				nodedef._chest_entity_sound,
				nodedef._chest_entity_mesh, nodedef._chest_entity_animation_type, dir):set_yaw(dir)
		else
			return false
		end
	end
end
vlf_chests.no_rotate, vlf_chests.simple_rotate = no_rotate, simple_rotate

--[[ List of open chests.
Key: Player name
Value:
	If player is using a chest: { pos = <chest node position> }
	Otherwise: nil ]]
local open_chests = {}
vlf_chests.open_chests = open_chests

-- To be called if a player opened a chest
local function player_chest_open(player, pos, node_name, textures, param2, double, sound, mesh, shulker)
	local name = player:get_player_name()
	open_chests[name] = {
		pos = pos,
		node_name = node_name,
		textures = textures,
		param2 = param2,
		double = double,
		sound = sound,
		mesh = mesh,
		shulker = shulker
	}
	if animated_chests then
		local dir = minetest.facedir_to_dir(param2)
		find_or_create_entity(pos, node_name, textures, param2, double, sound, mesh, shulker and "shulker" or "chest",
				dir):
			open(name)
	end
end
vlf_chests.player_chest_open = player_chest_open

-- Simple protection checking functions
local function protection_check_move(pos, from_list, from_index, to_list, to_index, count, player)
	local name = player:get_player_name()
	if minetest.is_protected(pos, name) then
		minetest.record_protection_violation(pos, name)
		return 0
	else
		return count
	end
end
vlf_chests.protection_check_move = protection_check_move

local function protection_check_put_take(pos, listname, index, stack, player)
	local name = player:get_player_name()
	if minetest.is_protected(pos, name) then
		minetest.record_protection_violation(pos, name)
		return 0
	else
		return stack:get_count()
	end
end
vlf_chests.protection_check_put_take = protection_check_put_take

-- To be called when a chest is closed (only relevant for trapped chest atm)
local function chest_update_after_close(pos)
	local node = minetest.get_node(pos)

	if node.name == "vlf_chests:trapped_chest_on_small" then
		minetest.swap_node(pos, { name = "vlf_chests:trapped_chest_small", param2 = node.param2 })
		find_or_create_entity(pos, "vlf_chests:trapped_chest_small", { "vlf_chests_trapped.png" }, node.param2, false,
			"vlf_chests", "vlf_chests_chest", "chest"):reinitialize("vlf_chests:trapped_chest_small")
		mesecon.receptor_off(pos, mesecon.rules.pplate)
	elseif node.name == "vlf_chests:trapped_chest_on_left" then
		minetest.swap_node(pos, { name = "vlf_chests:trapped_chest_left", param2 = node.param2 })
		find_or_create_entity(pos, "vlf_chests:trapped_chest_left", vlf_chests.tiles.chest_trapped_double, node.param2, true,
			"vlf_chests", "vlf_chests_chest", "chest"):reinitialize("vlf_chests:trapped_chest_left")
		mesecon.receptor_off(pos, mesecon.rules.pplate)

		local pos_other = get_double_container_neighbor_pos(pos, node.param2, "left")
		minetest.swap_node(pos_other, { name = "vlf_chests:trapped_chest_right", param2 = node.param2 })
		mesecon.receptor_off(pos_other, mesecon.rules.pplate)
	elseif node.name == "vlf_chests:trapped_chest_on_right" then
		minetest.swap_node(pos, { name = "vlf_chests:trapped_chest_right", param2 = node.param2 })
		mesecon.receptor_off(pos, mesecon.rules.pplate)

		local pos_other = get_double_container_neighbor_pos(pos, node.param2, "right")
		minetest.swap_node(pos_other, { name = "vlf_chests:trapped_chest_left", param2 = node.param2 })
		find_or_create_entity(pos_other, "vlf_chests:trapped_chest_left", vlf_chests.tiles.chest_trapped_double,
			node.param2, true, "vlf_chests", "vlf_chests_chest", "chest")
			:reinitialize("vlf_chests:trapped_chest_left")
		mesecon.receptor_off(pos_other, mesecon.rules.pplate)
	end
end
vlf_chests.chest_update_after_close = chest_update_after_close

-- To be called if a player closed a chest
local function player_chest_close(player)
	local name = player:get_player_name()
	local open_chest = open_chests[name]
	if open_chest == nil then
		return
	end
	if animated_chests then
		find_or_create_entity(open_chest.pos, open_chest.node_name, open_chest.textures, open_chest.param2,
			open_chest.double, open_chest.sound, open_chest.mesh, open_chest.shulker and "shulker" or "chest")
			:close(name)
	end
	chest_update_after_close(open_chest.pos)

	open_chests[name] = nil
end
vlf_chests.player_chest_close = player_chest_close

local function double_chest_add_item(top_inv, bottom_inv, listname, stack)
	if not stack or stack:is_empty() then return end

	local name = stack:get_name()

	local function top_off(inv, stack)
		for c, chest_stack in ipairs(inv:get_list(listname)) do
			if stack:is_empty() then
				break
			end

			if chest_stack:get_name() == name and chest_stack:get_free_space() > 0 then
				stack = chest_stack:add_item(stack)
				inv:set_stack(listname, c, chest_stack)
			end
		end

		return stack
	end

	stack = top_off(top_inv, stack)
	stack = top_off(bottom_inv, stack)

	if not stack:is_empty() then
		stack = top_inv:add_item(listname, stack)
		if not stack:is_empty() then
			bottom_inv:add_item(listname, stack)
		end
	end
end

local function on_chest_blast(pos)
	local node = minetest.get_node(pos)
	drop_items_chest(pos, node)
	minetest.remove_node(pos)
end

local function limit_put_list(stack, list)
	for _, other in ipairs(list) do
		stack = other:add_item(stack)
		if stack:is_empty() then
			break
		end
	end
	return stack
end

local function limit_put(stack, inv1, inv2)
	local leftover = ItemStack(stack)
	leftover = limit_put_list(leftover, inv1:get_list("main"))
	leftover = limit_put_list(leftover, inv2:get_list("main"))
	return stack:get_count() - leftover:get_count()
end

local function close_forms(canonical_basename, pos)
	local players = minetest.get_connected_players()
	for p = 1, #players do
		if vector.distance(players[p]:get_pos(), pos) <= 30 then
			minetest.close_formspec(players[p]:get_player_name(),
				"vlf_chests:" .. canonical_basename .. "_" .. pos.x .. "_" .. pos.y .. "_" .. pos.z)
		end
	end
end

-- This is a helper function to register regular chests (both small and double variants).
-- Some parameters here are only utilized by trapped chests.
function vlf_chests.register_chest(basename, d)
	-- If this passes without crash, we know for a fact that d = {...}
	assert((d and type(d) == "table"), "Second argument to vlf_chests.register_chest must be a table")

	if not d.drop then
		d.drop = "vlf_chests:" .. basename
	else
		d.drop = "vlf_chests:" .. d.drop
	end
	-- The basename of the "canonical" version of the node, if set (e.g.: trapped_chest_on → trapped_chest).
	-- Used to get a shared formspec ID and to swap the node back to the canonical version in on_construct.
	if not d.canonical_basename then
		d.canonical_basename = basename
	end

	local small_name = "vlf_chests:" .. basename .. "_small"
	local small_textures = d.tiles.small
	local left_name = "vlf_chests:" .. basename .. "_left"
	local right_name = "vlf_chests:" .. basename .. "_right"
	local double_textures = d.tiles.double

	minetest.register_node("vlf_chests:" .. basename, {
		description = d.desc,
		_tt_help = d.tt_help,
		_doc_items_longdesc = d.longdesc,
		_doc_items_usagehelp = d.usagehelp,
		_doc_items_hidden = d.hidden,
		drawtype = "mesh",
		mesh = "vlf_chests_chest.b3d",
		tiles = small_textures,
		use_texture_alpha = "opaque",
		paramtype = "light",
		paramtype2 = "facedir",
		sounds = d.sounds,
		groups = { deco_block = 1 },
		on_construct = function(pos, node)
			local node = minetest.get_node(pos)
			node.name = small_name
			minetest.set_node(pos, node)
		end,
		after_place_node = function(pos, placer, itemstack, pointed_thing)
			minetest.get_meta(pos):set_string("name", itemstack:get_meta():get_string("name"))
		end,
	})

	minetest.register_node(small_name, {
		description = d.desc,
		_tt_help = d.tt_help,
		_doc_items_longdesc = d.longdesc,
		_doc_items_usagehelp = d.usagehelp,
		_doc_items_hidden = d.hidden,
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = { -0.4375, -0.5, -0.4375, 0.4375, 0.375, 0.4375 },
		},
		tiles = { "blank.png^[resize:16x16" },
		use_texture_alpha = "clip",
		_chest_entity_textures = small_textures,
		_chest_entity_sound = "vlf_chests",
		_chest_entity_mesh = "vlf_chests_chest",
		_chest_entity_animation_type = "chest",
		paramtype = "light",
		paramtype2 = "facedir",
		drop = d.drop,
		groups = {
			handy = 1,
			axey = 1,
			container = 2,
			deco_block = 1,
			material_wood = 1,
			flammable = -1,
			chest_entity = 1,
			not_in_creative_inventory = 1
		},
		is_ground_content = false,
		sounds = d.sounds,
		on_construct = function(pos)
			local param2 = minetest.get_node(pos).param2
			local meta = minetest.get_meta(pos)

			--[[ This is a workaround for Minetest issue 5894
			<https://github.com/minetest/minetest/issues/5894>.
			Apparently if we don't do this, large chests initially don't work when
			placed at chunk borders, and some chests randomly don't work after
			placing. ]]
			-- FIXME: Remove this workaround when the bug has been fixed.
			-- BEGIN OF WORKAROUND --
			meta:set_string("workaround", "ignore_me")
			meta:set_string("workaround", "") -- Done to keep metadata clean
			-- END OF WORKAROUND --

			local inv = meta:get_inventory()
			inv:set_size("main", 9 * 3)

			--[[ The "input" list is *another* workaround (hahahaha!) around the fact that Minetest
			does not support listrings to put items into an alternative list if the first one
			happens to be full. See <https://github.com/minetest/minetest/issues/5343>.
			This list is a hidden input-only list and immediately puts items into the appropriate chest.
			It is only used for listrings and hoppers. This workaround is not that bad because it only
			requires a simple “inventory allows” check for large chests.]]
			-- FIXME: Refactor the listrings as soon Minetest supports alternative listrings
			-- BEGIN OF LISTRING WORKAROUND
			inv:set_size("input", 1)
			-- END OF LISTRING WORKAROUND

			-- Combine into a double chest if neighbouring another small chest
			if minetest.get_node(get_double_container_neighbor_pos(pos, param2, "right")).name ==
					small_name then
				minetest.swap_node(pos, { name = right_name, param2 = param2 })
				local p = get_double_container_neighbor_pos(pos, param2, "right")
				minetest.swap_node(p, { name = left_name, param2 = param2 })
				create_entity(p, left_name, double_textures, param2, true, "vlf_chests",
					"vlf_chests_chest", "chest")
			elseif minetest.get_node(get_double_container_neighbor_pos(pos, param2, "left")).name ==
					small_name then
				minetest.swap_node(pos, { name = left_name, param2 = param2 })
				create_entity(pos, left_name, double_textures, param2, true, "vlf_chests",
					"vlf_chests_chest", "chest")
				local p = get_double_container_neighbor_pos(pos, param2, "left")
				minetest.swap_node(p, { name = right_name, param2 = param2 })
			else
				minetest.swap_node(pos, { name = small_name, param2 = param2 })
				create_entity(pos, small_name, small_textures, param2, false, "vlf_chests",
					"vlf_chests_chest", "chest")
			end
		end,
		after_place_node = function(pos, placer, itemstack, pointed_thing)
			minetest.get_meta(pos):set_string("name", itemstack:get_meta():get_string("name"))
		end,
		after_dig_node = drop_items_chest,
		on_blast = on_chest_blast,
		allow_metadata_inventory_move = protection_check_move,
		allow_metadata_inventory_take = protection_check_put_take,
		allow_metadata_inventory_put = protection_check_put_take,
		on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
			minetest.log("action", player:get_player_name() ..
				" moves stuff in chest at " .. minetest.pos_to_string(pos))
		end,
		on_metadata_inventory_put = function(pos, listname, index, stack, player)
			minetest.log("action", player:get_player_name() ..
				" moves stuff to chest at " .. minetest.pos_to_string(pos))
			-- BEGIN OF LISTRING WORKAROUND
			if listname == "input" then
				local inv = minetest.get_inventory({ type = "node", pos = pos })
				inv:add_item("main", stack)
			end
			-- END OF LISTRING WORKAROUND
		end,
		on_metadata_inventory_take = function(pos, listname, index, stack, player)
			minetest.log("action", player:get_player_name() ..
				" takes stuff from chest at " .. minetest.pos_to_string(pos))
		end,
		_vlf_blast_resistance = d.hardness,
		_vlf_hardness = d.hardness,

		on_rightclick = function(pos, node, clicker)
			local topnode = minetest.get_node({ x = pos.x, y = pos.y + 1, z = pos.z })
			if topnode and topnode.name and minetest.registered_nodes[topnode.name] then
				if minetest.registered_nodes[topnode.name].groups.opaque == 1 then
					-- won't open if there is no space from the top
					return false
				end
			end
			local name = minetest.get_meta(pos):get_string("name")
			if name == "" then
				name = S("Chest")
			end

			minetest.show_formspec(clicker:get_player_name(),
				sf("vlf_chests:%s_%s_%s_%s", d.canonical_basename, pos.x, pos.y, pos.z),
				table.concat({
					"formspec_version[4]",
					"size[11.75,10.425]",

					"label[0.375,0.375;" .. F(C(vlf_formspec.label_color, name)) .. "]",
					vlf_formspec.get_itemslot_bg_v4(0.375, 0.75, 9, 3),
					sf("list[nodemeta:%s,%s,%s;main;0.375,0.75;9,3;]", pos.x, pos.y, pos.z),
					"label[0.375,4.7;" .. F(C(vlf_formspec.label_color, S("Inventory"))) .. "]",
					vlf_formspec.get_itemslot_bg_v4(0.375, 5.1, 9, 3),
					"list[current_player;main;0.375,5.1;9,3;9]",

					vlf_formspec.get_itemslot_bg_v4(0.375, 9.05, 9, 1),
					"list[current_player;main;0.375,9.05;9,1;]",
					sf("listring[nodemeta:%s,%s,%s;main]", pos.x, pos.y, pos.z),
					"listring[current_player;main]",
				})
			)

			if d.on_rightclick then
				d.on_rightclick(pos, node, clicker)
			end

			player_chest_open(clicker, pos, small_name, small_textures, node.param2, false, "vlf_chests",
				"vlf_chests_chest")
		end,

		on_destruct = function(pos)
			close_forms(d.canonical_basename, pos)
		end,
		mesecons = d.mesecons,
		on_rotate = simple_rotate,
	})

	minetest.register_node(left_name, {
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = { -0.4375, -0.5, -0.4375, 0.5, 0.375, 0.4375 },
		},
		tiles = { "blank.png^[resize:16x16" },
		use_texture_alpha = "clip",
		_chest_entity_textures = double_textures,
		_chest_entity_sound = "vlf_chests",
		_chest_entity_mesh = "vlf_chests_chest",
		_chest_entity_animation_type = "chest",
		paramtype = "light",
		paramtype2 = "facedir",
		groups = {
			handy = 1,
			axey = 1,
			container = 2,
			not_in_creative_inventory = 1,
			material_wood = 1,
			flammable = -1,
			chest_entity = 1,
			double_chest = 1
		},
		drop = d.drop,
		is_ground_content = false,
		sounds = d.sounds,
		on_construct = function(pos)
			local n = minetest.get_node(pos)
			local param2 = n.param2
			local p = get_double_container_neighbor_pos(pos, param2, "left")
			if not p or minetest.get_node(p).name ~= "vlf_chests:" .. d.canonical_basename .. "_right" then
				n.name = "vlf_chests:" .. d.canonical_basename .. "_small"
				minetest.swap_node(pos, n)
			end
			create_entity(pos, left_name, double_textures, param2, true, "vlf_chests", "vlf_chests_chest", "chest")
		end,
		after_place_node = function(pos, placer, itemstack, pointed_thing)
			minetest.get_meta(pos):set_string("name", itemstack:get_meta():get_string("name"))
		end,
		on_destruct = function(pos)
			local n = minetest.get_node(pos)
			if n.name == small_name then
				return
			end

			close_forms(d.canonical_basename, pos)

			local param2 = n.param2
			local p = get_double_container_neighbor_pos(pos, param2, "left")
			if not p or minetest.get_node(p).name ~= "vlf_chests:" .. basename .. "_right" then
				return
			end
			close_forms(d.canonical_basename, p)

			minetest.swap_node(p, { name = small_name, param2 = param2 })
			create_entity(p, small_name, small_textures, param2, false, "vlf_chests", "vlf_chests_chest", "chest")
		end,
		after_dig_node = drop_items_chest,
		on_blast = on_chest_blast,
		allow_metadata_inventory_move = protection_check_move,
		allow_metadata_inventory_take = protection_check_put_take,
		allow_metadata_inventory_put = function(pos, listname, index, stack, player)
			local name = player:get_player_name()
			if minetest.is_protected(pos, name) then
				minetest.record_protection_violation(pos, name)
				return 0
			-- BEGIN OF LISTRING WORKAROUND
			elseif listname == "input" then
				local inv = minetest.get_inventory({ type = "node", pos = pos })
				local other_pos = get_double_container_neighbor_pos(pos, minetest.get_node(pos).param2, "left")
				local other_inv = minetest.get_inventory({ type = "node", pos = other_pos })
				return limit_put(stack, inv, other_inv)
			-- END OF LISTRING WORKAROUND
			else
				return stack:get_count()
			end
		end,
		on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
			minetest.log("action", player:get_player_name() ..
				" moves stuff in chest at " .. minetest.pos_to_string(pos))
		end,
		on_metadata_inventory_put = function(pos, listname, index, stack, player)
			minetest.log("action", player:get_player_name() ..
				" moves stuff to chest at " .. minetest.pos_to_string(pos))
			-- BEGIN OF LISTRING WORKAROUND
			if listname == "input" then
				local inv = minetest.get_inventory({ type = "node", pos = pos })
				local other_pos = get_double_container_neighbor_pos(pos, minetest.get_node(pos).param2, "left")
				local other_inv = minetest.get_inventory({ type = "node", pos = other_pos })

				inv:set_stack("input", 1, nil)

				double_chest_add_item(inv, other_inv, "main", stack)
			end
			-- END OF LISTRING WORKAROUND
		end,
		on_metadata_inventory_take = function(pos, listname, index, stack, player)
			minetest.log("action", player:get_player_name() ..
				" takes stuff from chest at " .. minetest.pos_to_string(pos))
		end,
		_vlf_blast_resistance = d.hardness,
		_vlf_hardness = d.hardness,

		on_rightclick = function(pos, node, clicker)
			local pos_other = get_double_container_neighbor_pos(pos, node.param2, "left")
			local above_def = minetest.registered_nodes[
				minetest.get_node({ x = pos.x, y = pos.y + 1, z = pos.z }).name
			]
			local above_def_other = minetest.registered_nodes[
				minetest.get_node({ x = pos_other.x, y = pos_other.y + 1, z = pos_other.z }).name
			]

			if (not above_def or above_def.groups.opaque == 1 or not above_def_other
					or above_def_other.groups.opaque == 1) then
				-- won't open if there is no space from the top
				return false
			end

			local name = minetest.get_meta(pos):get_string("name")
			if name == "" then -- if empty after that ^
				name = minetest.get_meta(pos_other):get_string("name")
			end if name == "" then -- if STILL empty after that ^
				name = S("Large Chest")
			end

			minetest.show_formspec(clicker:get_player_name(),
				sf("vlf_chests:%s_%s_%s_%s", d.canonical_basename, pos.x, pos.y, pos.z),
				table.concat({
					"formspec_version[4]",
					"size[11.75,14.15]",

					"label[0.375,0.375;" .. F(C(vlf_formspec.label_color, name)) .. "]",
					vlf_formspec.get_itemslot_bg_v4(0.375, 0.75, 9, 3),
					sf("list[nodemeta:%s,%s,%s;main;0.375,0.75;9,3;]", pos.x, pos.y, pos.z),
					vlf_formspec.get_itemslot_bg_v4(0.375, 4.5, 9, 3),
					sf("list[nodemeta:%s,%s,%s;main;0.375,4.5;9,3;]", pos_other.x, pos_other.y, pos_other.z),
					"label[0.375,8.45;" .. F(C(vlf_formspec.label_color, S("Inventory"))) .. "]",
					vlf_formspec.get_itemslot_bg_v4(0.375, 8.825, 9, 3),
					"list[current_player;main;0.375,8.825;9,3;9]",

					vlf_formspec.get_itemslot_bg_v4(0.375, 12.775, 9, 1),
					"list[current_player;main;0.375,12.775;9,1;]",

					--BEGIN OF LISTRING WORKAROUND
					"listring[current_player;main]",
					sf("listring[nodemeta:%s,%s,%s;input]", pos.x, pos.y, pos.z),
					--END OF LISTRING WORKAROUND

					"listring[current_player;main]" ..
					sf("listring[nodemeta:%s,%s,%s;main]", pos.x, pos.y, pos.z),
					"listring[current_player;main]",
					sf("listring[nodemeta:%s,%s,%s;main]", pos_other.x, pos_other.y, pos_other.z),
				})
			)

			if d.on_rightclick_left then
				d.on_rightclick_left(pos, node, clicker)
			end

			player_chest_open(clicker, pos, left_name, double_textures, node.param2, true, "vlf_chests",
				"vlf_chests_chest")
		end,
		mesecons = d.mesecons,
		on_rotate = no_rotate,
		_vlf_hoppers_on_try_pull = function(pos, hop_pos, hop_inv, hop_list)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()

			local stack_id = vlf_util.select_stack(inv, "main", hop_inv, hop_list)
			if stack_id ~= nil then
				return inv, "main", stack_id
			end

			local node = minetest.get_node(pos)
			local pos_other = get_double_container_neighbor_pos(pos, node.param2, "left")
			local meta_other = minetest.get_meta(pos_other)
			local inv_other = meta_other:get_inventory()
			stack_id = vlf_util.select_stack(inv_other, "main", hop_inv, hop_list)
			return inv_other, "main", stack_id
		end,
		_vlf_hoppers_on_try_push = function(pos, hop_pos, hop_inv, hop_list)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()

			local stack_id = vlf_util.select_stack(hop_inv, hop_list, inv, "main", nil, 1)
			if stack_id ~= nil then
				return inv, "main", stack_id
			end

			local node = minetest.get_node(pos)
			local pos_other = get_double_container_neighbor_pos(pos, node.param2, "left")
			local meta_other = minetest.get_meta(pos_other)
			local inv_other = meta_other:get_inventory()
			stack_id = vlf_util.select_stack(hop_inv, hop_list, inv_other, "main", nil, 1)
			return inv_other, "main", stack_id
		end,
	})

	minetest.register_node(right_name, {
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "facedir",
		node_box = {
			type = "fixed",
			fixed = { -0.5, -0.5, -0.4375, 0.4375, 0.375, 0.4375 },
		},
		tiles = { "blank.png^[resize:16x16" },
		use_texture_alpha = "clip",
		groups = {
			handy = 1,
			axey = 1,
			container = 2,
			not_in_creative_inventory = 1,
			material_wood = 1,
			flammable = -1,
			double_chest = 2
		},
		drop = d.drop,
		is_ground_content = false,
		sounds = d.sounds,
		on_construct = function(pos)
			local n = minetest.get_node(pos)
			local param2 = n.param2
			local p = get_double_container_neighbor_pos(pos, param2, "right")
			if not p or minetest.get_node(p).name ~= left_name then
				n.name = small_name
				minetest.swap_node(pos, n)
			end
		end,
		after_place_node = function(pos, placer, itemstack, pointed_thing)
			minetest.get_meta(pos):set_string("name", itemstack:get_meta():get_string("name"))
		end,
		on_destruct = function(pos)
			local n = minetest.get_node(pos)
			if n.name == small_name then
				return
			end

			close_forms(d.canonical_basename, pos)

			local param2 = n.param2
			local p = get_double_container_neighbor_pos(pos, param2, "right")
			if not p or minetest.get_node(p).name ~= left_name then
				return
			end
			close_forms(d.canonical_basename, p)

			minetest.swap_node(p, { name = small_name, param2 = param2 })
			create_entity(p, small_name, small_textures, param2, false, "vlf_chests", "vlf_chests_chest", "chest")
		end,
		after_dig_node = drop_items_chest,
		on_blast = on_chest_blast,
		allow_metadata_inventory_move = protection_check_move,
		allow_metadata_inventory_take = protection_check_put_take,
		allow_metadata_inventory_put = function(pos, listname, index, stack, player)
			local name = player:get_player_name()
			if minetest.is_protected(pos, name) then
				minetest.record_protection_violation(pos, name)
				return 0
			-- BEGIN OF LISTRING WORKAROUND
			elseif listname == "input" then
				local other_pos = get_double_container_neighbor_pos(pos, minetest.get_node(pos).param2, "right")
				local other_inv = minetest.get_inventory({ type = "node", pos = other_pos })
				local inv = minetest.get_inventory({ type = "node", pos = pos })
				return limit_put(stack, other_inv, inv)
			-- END OF LISTRING WORKAROUND
			else
				return stack:get_count()
			end
		end,
		on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
			minetest.log("action", player:get_player_name() ..
				" moves stuff in chest at " .. minetest.pos_to_string(pos))
		end,
		on_metadata_inventory_put = function(pos, listname, index, stack, player)
			minetest.log("action", player:get_player_name() ..
				" moves stuff to chest at " .. minetest.pos_to_string(pos))
			-- BEGIN OF LISTRING WORKAROUND
			if listname == "input" then
				local other_pos = get_double_container_neighbor_pos(pos, minetest.get_node(pos).param2, "right")
				local other_inv = minetest.get_inventory({ type = "node", pos = other_pos })
				local inv = minetest.get_inventory({ type = "node", pos = pos })

				inv:set_stack("input", 1, nil)

				double_chest_add_item(other_inv, inv, "main", stack)
			end
			-- END OF LISTRING WORKAROUND
		end,
		on_metadata_inventory_take = function(pos, listname, index, stack, player)
			minetest.log("action", player:get_player_name() ..
				" takes stuff from chest at " .. minetest.pos_to_string(pos))
		end,
		_vlf_blast_resistance = d.hardness,
		_vlf_hardness = d.hardness,

		on_rightclick = function(pos, node, clicker)
			local pos_other = get_double_container_neighbor_pos(pos, node.param2, "right")
			local above_def = minetest.registered_nodes[
				minetest.get_node({ x = pos.x, y = pos.y + 1, z = pos.z }).name
			]
			local above_def_other = minetest.registered_nodes[
				minetest.get_node({ x = pos_other.x, y = pos_other.y + 1, z = pos_other.z }).name
			]

			if (not above_def or above_def.groups.opaque == 1 or not above_def_other
					or above_def_other.groups.opaque == 1) then
				-- won't open if there is no space from the top
				return false
			end

			local name = minetest.get_meta(pos):get_string("name")
			if name == "" then -- if empty after that ^
				name = minetest.get_meta(pos_other):get_string("name")
			end if name == "" then -- if STILL empty after that ^
				name = S("Large Chest")
			end

			minetest.show_formspec(clicker:get_player_name(),
				sf("vlf_chests:%s_%s_%s_%s", d.canonical_basename, pos.x, pos.y, pos.z),
				table.concat({
					"formspec_version[4]",
					"size[11.75,14.15]",

					"label[0.375,0.375;" .. F(C(vlf_formspec.label_color, name)) .. "]",
					vlf_formspec.get_itemslot_bg_v4(0.375, 0.75, 9, 3),
					sf("list[nodemeta:%s,%s,%s;main;0.375,0.75;9,3;]", pos_other.x, pos_other.y, pos_other.z),
					vlf_formspec.get_itemslot_bg_v4(0.375, 4.5, 9, 3),
					sf("list[nodemeta:%s,%s,%s;main;0.375,4.5;9,3;]", pos.x, pos.y, pos.z),
					"label[0.375,8.45;" .. F(C(vlf_formspec.label_color, S("Inventory"))) .. "]",
					vlf_formspec.get_itemslot_bg_v4(0.375, 8.825, 9, 3),
					"list[current_player;main;0.375,8.825;9,3;9]",

					vlf_formspec.get_itemslot_bg_v4(0.375, 12.775, 9, 1),
					"list[current_player;main;0.375,12.775;9,1;]",

					--BEGIN OF LISTRING WORKAROUND
					"listring[current_player;main]",
					sf("listring[nodemeta:%s,%s,%s;input]", pos.x, pos.y, pos.z),
					--END OF LISTRING WORKAROUND

					"listring[current_player;main]" ..
					sf("listring[nodemeta:%s,%s,%s;main]", pos_other.x, pos_other.y, pos_other.z),
					"listring[current_player;main]",
					sf("listring[nodemeta:%s,%s,%s;main]", pos.x, pos.y, pos.z),
				})
			)

			if d.on_rightclick_right then
				d.on_rightclick_right(pos, node, clicker)
			end

			player_chest_open(clicker, pos_other, left_name, double_textures, node.param2, true, "vlf_chests",
				"vlf_chests_chest")
		end,
		mesecons = d.mesecons,
		on_rotate = no_rotate,
		_vlf_hoppers_on_try_pull = function(pos, hop_pos, hop_inv, hop_list)
			local node = minetest.get_node(pos)
			local pos_other = get_double_container_neighbor_pos(pos, node.param2, "right")
			local meta_other = minetest.get_meta(pos_other)
			local inv_other = meta_other:get_inventory()

			local stack_id = vlf_util.select_stack(inv_other, "main", hop_inv, hop_list)
			if stack_id ~= nil then
				return inv_other, "main", stack_id
			end

			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			stack_id = vlf_util.select_stack(inv, "main", hop_inv, hop_list)
			return inv, "main", stack_id
		end,
		_vlf_hoppers_on_try_push = function(pos, hop_pos, hop_inv, hop_list)
			local node = minetest.get_node(pos)
			local pos_other = get_double_container_neighbor_pos(pos, node.param2, "right")
			local meta_other = minetest.get_meta(pos_other)
			local inv_other = meta_other:get_inventory()

			local stack_id = vlf_util.select_stack(hop_inv, hop_list, inv_other, "main", nil, 1)
			if stack_id ~= nil then
				return inv_other, "main", stack_id
			end

			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			stack_id = vlf_util.select_stack(hop_inv, hop_list, inv, "main", nil, 1)
			return inv, "main", stack_id
		end,
	})

	if doc then
		doc.add_entry_alias("nodes", small_name, "nodes", left_name)
		doc.add_entry_alias("nodes", small_name, "nodes", right_name)
	end
end

-- Returns false if itemstack is a shulker box
function vlf_chests.is_not_shulker_box(stack)
	local g = minetest.get_item_group(stack:get_name(), "shulker_box")
	return g == 0 or g == nil
end
