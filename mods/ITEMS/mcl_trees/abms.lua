-- Leaf Decay
local function leafdecay_particles(pos, node)
	minetest.add_particlespawner({
		amount = math.random(10, 20),
		time = 0.1,
		minpos = vector.add(pos, {x=-0.4, y=-0.4, z=-0.4}),
		maxpos = vector.add(pos, {x=0.4, y=0.4, z=0.4}),
		minvel = {x=-0.2, y=-0.2, z=-0.2},
		maxvel = {x=0.2, y=0.1, z=0.2},
		minacc = {x=0, y=-9.81, z=0},
		maxacc = {x=0, y=-9.81, z=0},
		minexptime = 0.1,
		maxexptime = 0.5,
		minsize = 0.5,
		maxsize = 1.5,
		collisiondetection = true,
		vertical = false,
		node = node,
	})
end

-- Whenever a tree trunk node is removed, all `group:leaves` nodes in a radius
-- of 6 blocks are checked from the trunk node's `after_destruct` handler.
-- Any such nodes within that radius that has no trunk node present within a
-- distance of 6 blocks is replaced with a `group:orphan_leaves` node.
--
-- The `group:orphan_leaves` nodes are gradually decayed in this ABM.
minetest.register_abm({
	label = "Leaf decay",
	nodenames = {"group:orphan_leaves"},
	interval = 5,
	chance = 10,
		action = function(pos, node)
		-- Spawn item entities for any of the leaf's drops
		local itemstacks = minetest.get_node_drops(node.name)
		for _, itemname in pairs(itemstacks) do
			local p_drop = vector.offset(pos, math.random() - 0.5, math.random() - 0.5, math.random() - 0.5)
			minetest.add_item(p_drop, itemname)
		end
		-- Remove the decayed node
		minetest.remove_node(pos)
		leafdecay_particles(pos, node)
		minetest.check_for_falling(pos)

		-- Kill depending vines immediately to skip the vines decay delay
		local surround = {
			{ x = 0, y = 0, z = -1 },
			{ x = 0, y = 0, z = 1 },
			{ x = -1, y = 0, z = 0 },
			{ x = 1, y = 0, z = 0 },
			{ x = 0, y = -1, z = -1 },
		}
		for s=1, #surround do
			local spos = vector.add(pos, surround[s])
			local maybe_vine = minetest.get_node(spos)
			--local surround_inverse = vector.multiply(surround[s], -1)
			if maybe_vine.name == "mcl_core:vine" and (not mcl_core.check_vines_supported(spos, maybe_vine)) then
				local def = minetest.registered_nodes[maybe_vine.name]
				if def and def.on_dig then
					def.on_dig(spos,maybe_vine,nil)
				end
			end
		end
	end
})

-- Check if a node stops a tree from growing.  Torches, plants, wood, tree,
-- leaves and dirt does not affect tree growth.
local function node_stops_growth(node)
	if node.name == "air" then
		return false
	end

	local def = minetest.registered_nodes[node.name]
	if not def then
		return true
	end

	local groups = def.groups
	if not groups then
		return true
	end
	if groups.plant or groups.torch or groups.dirt or groups.tree
		or groups.bark or groups.leaves or groups.wood then
		return false
	end

	return true
end

-- Check if a tree can grow at position. The width is the width to check
-- around the tree. A width of 3 and height of 5 will check a 3x3 area, 5
-- nodes above the sapling. If any walkable node other than dirt, wood or
-- leaves occurs in those blocks the tree cannot grow.
function mcl_trees.check_growth(pos, width, height)
	-- Huge tree (with even width to check) will check one more node in
	-- positive x and y directions.
	local neg_space = math.min((width - 1) / 2)
	local pos_space = math.max((width - 1) / 2)
	for x = -neg_space, pos_space do
		for z = -neg_space, pos_space do
			for y = 1, height do
				local np = vector.new(
					pos.x + x,
					pos.y + y,
					pos.z + z)
				if node_stops_growth(minetest.get_node(np)) then
					return false
				end
			end
		end
	end
	return true
end

function mcl_trees.grow_tree(pos, node)
	local name = node.name:gsub("mcl_trees:sapling_","")
	local tbt,ne = mcl_trees.check_2by2_saps(pos, node)
	if node.name:find("propagule") then name = "mangrove" end
	if not mcl_trees.woods[name] or not mcl_trees.woods[name].tree_schems then return end
	local schem = mcl_trees.woods[name].tree_schems[1]
	table.shuffle(mcl_trees.woods[name].tree_schems)
	if tbt and ( name == "dark_oak" or name == "jungle" or name == "spruce" ) then
		for _,v in pairs(mcl_trees.woods[name].tree_schems) do
			if v.file:find("huge") or name == "dark_oak" then schem = v end
		end
	elseif name ~= "dark_oak" then --dark oak only grows "huge" trees
		for _,v in pairs(mcl_trees.woods[name].tree_schems) do
			if not v.file:find("huge") then schem = v end
		end
	end
	local w = schem.width or 5
	local h = schem.height or 10
	if mcl_trees.check_growth(pos, w, h) then
		minetest.remove_node(pos)
		if tbt then
			for _,v in pairs(tbt) do
				minetest.remove_node(v)
			end
			pos = ne
		end
		minetest.place_schematic(vector.subtract(pos, schem.offset or vector.new(math.ceil(w/2), 1, math.ceil(w/2))), schem.file, "random", nil, false)

		local nn = minetest.find_nodes_in_area(vector.offset(pos, -math.ceil(w/2), 0, -math.ceil(w/2)), vector.offset(pos, math.ceil(w/2), h, math.ceil(w/2)), {"group:leaves"})
		for _,v in pairs(nn) do
			local n = minetest.get_node(v)
			if minetest.get_item_group(n.name,"biomecolor") > 0 then
				-- preserve the log distance in the upper 3 bits
				n.param2 = math.floor(n.param2 / 32) * 32 + mcl_util.get_pos_p2(v)
				minetest.swap_node(v, n)
			end
		end
	end
end

minetest.register_abm({
	label = "Tree growth",
	nodenames = {"group:sapling"},
	neighbors = {"group:soil_sapling","group:soil_propagule"},
	interval = 35,
	chance = 5,
	action = mcl_trees.grow_tree,
})

minetest.register_lbm({
	label = "Set old leaves param2",
	name = "mcl_trees:leaves_param2_update",
	nodenames = {"group:leaves"},
	run_at_every_load = false,
	action = function(pos, n)
		if minetest.get_item_group(n.name,"biomecolor") == 0 then return end
		local p2 = mcl_util.get_pos_p2(pos)
		if n.param2 ~= p2 then
			n.param2 = p2
			minetest.swap_node(pos, n)
		end
	end,
})
