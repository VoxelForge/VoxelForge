-- potato plants
-- This includes potato flowers, potato plant stem nodes and potato fruit

local S = minetest.get_translator(minetest.get_current_modname())

--- Plant parts ---

-- Helper function
local function round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

-- This is a list of nodes that SHOULD NOT call their detach function
local no_detach = {}

-- This detaches all potato plants that are/were attached
-- at start_pos.
function voxelforge.detach_potato_plant(start_pos, digger)
	-- This node should not call a detach function, do NOTHING
	local hash = minetest.hash_node_position(start_pos)
	if no_detach[hash] then
		return
	end

	-- This node SHOULD be detached, make sure no others are
	no_detach = {}

	local neighbors = {
		{ x=0, y=1, z=0 },
		{ x=0, y=0, z=1 },
		{ x=-1, y=0, z=0 },
		{ x=0, y=0, z=-1 },
		{ x=1, y=0, z=0 },
		{ x=0, y=-1, z=0 },
	}
	table.insert(neighbors, { x=0, y=-1, z=0 })
	local tree_start_posses = {}
	for i=1, #neighbors do
		table.insert(tree_start_posses, vector.add(start_pos, neighbors[i]))
	end

	-- From the start_pos, we look at the 6 possible directions. Each of these can
	-- have a full independent potato plant ("tree") that might be detached.
	for t=1, #tree_start_posses do
		-- For each "tree", we do a depth-first search to traverse all
		-- potato plant nodes.
		local touched_nodes_hashes = { minetest.hash_node_position(start_pos) }
		local check_posses = { tree_start_posses[t] }
		local potato_nodes = {}
		local break_tree = true
		while #check_posses > 0 do
			local pos = check_posses[1]

			-- Don't just count neighbors as being touched, count THIS NODE as well
			-- This will prevent it from getting stuck in an endless loop
			if not touched_nodes_hashes[minetest.hash_node_position(pos)] then
				local node = minetest.get_node(pos)
				touched_nodes_hashes[minetest.hash_node_position(pos)] = true
				if node.name == "voxelforge:end_stone" then
					-- End stone found, the algorithm ends here (haha!)
					-- without destroying any nodes, because potato plants
					-- attach to end stone.
					break_tree = false
					break
				elseif minetest.get_item_group(node.name, "potato_plant") == 1 then
					table.insert(potato_nodes, pos)
					for i=1, #neighbors do
						local newpos = vector.add(pos, neighbors[i])
						if not touched_nodes_hashes[minetest.hash_node_position(newpos)] then
							table.insert(check_posses, vector.add(pos, neighbors[i]))
						end
					end
				end
			end

			table.remove(check_posses, 1)
		end
		if break_tree then
			-- If we traversed the entire potato plant and it was not attached to end stone:
			-- Drop ALL the potato nodes we found.
			for c=1, #potato_nodes do
				no_detach[ minetest.hash_node_position(potato_nodes[c]) ] = true
				if digger then
					minetest.node_dig(potato_nodes[c], { name = "voxelforge:strong_roots" }, digger)
				else
					minetest.remove_node(potato_nodes[c])
				end
			end
		end
	end

	no_detach = {}
end

function voxelforge.check_detach_potato_plant(pos, _, _, digger)
	voxelforge.detach_potato_plant(pos, digger)
end

function voxelforge.check_blast_potato_plant(pos)
	minetest.remove_node(pos)
	voxelforge.detach_potato_plant(pos)
end

minetest.register_node(":voxelforge:powerful_potato", {
	description = S("Powerful Potato"),
	tiles = {
		"powerful_potato.png",
	},
	paramtype = "light",
	sunlight_propagates = true,
	sounds = vlf_sounds.node_sound_wood_defaults(),
	groups = {handy=1,axey=1, deco_block = 1, dig_by_piston = 1, destroy_by_lava_flow = 1,potato_plant = 1, unsticky = 1},

	--node_placement_prediction = "",
	after_dig_node = voxelforge.check_detach_potato_plant,
	on_blast = voxelforge.check_blast_potato_plant,
	_vlf_blast_resistance = 0.4,
	_vlf_hardness = 0.4,
})

minetest.register_node(":voxelforge:strong_roots", {
	description = S("Strong Roots"),
	tiles = {
		"strong_roots.png",
		"strong_roots.png",
		"strong_roots.png",
		"strong_roots.png",
		"strong_roots.png",
		"strong_roots.png",
	},
	drawtype = "nodebox",
	paramtype = "light",
	sunlight_propagates = true,
	node_box = {
		type = "connected",
		fixed = { -0.25, -0.25, -0.25, 0.25, 0.25, 0.25 }, -- Core
		connect_top = { -0.1875, 0.25, -0.1875, 0.1875, 0.5, 0.1875 },
		connect_left = { -0.5, -0.1875, -0.1875, -0.25, 0.1875, 0.1875 },
		connect_right = { 0.25, -0.1875, -0.1875, 0.5, 0.1875, 0.1875 },
		connect_bottom = { -0.1875, -0.5, -0.25, 0.1875, -0.25, 0.25 },
		connect_front = { -0.1875, -0.1875, -0.5, 0.1875, 0.1875, -0.25 },
		connect_back = { -0.1875, -0.1875, 0.25, 0.1875, 0.1875, 0.5 },
	},
	connect_sides = { "top", "bottom", "front", "back", "left", "right" },
	connects_to = {"group:potato_plant", "voxelforge:end_stone"},
	sounds = vlf_sounds.node_sound_wood_defaults(),
	drop = {
		items = {
			{ items = { "voxelforge:potato_fruit"}, rarity = 2 },
		}
	},
	groups = {handy=1,axey=1, deco_block = 1, dig_by_piston = 1, destroy_by_lava_flow = 1, potato_plant = 1, unsticky = 1},

	node_placement_prediction = "",
	--after_dig_node = voxelforge.check_detach_potato_plant,
	--on_blast = voxelforge.check_blast_potato_plant,
	_vlf_blast_resistance = 2,
	_vlf_hardness = 0.4,
})

minetest.register_node(":voxelforge:weak_roots", {
	description = S("Weak Roots"),
	tiles = {
		"weak_roots.png",
		"weak_roots.png",
		"weak_roots.png",
		"weak_roots.png",
		"weak_roots.png",
		"weak_roots.png",
	},
	drawtype = "nodebox",
	paramtype = "light",
	sunlight_propagates = true,
	node_box = {
		type = "connected",
		fixed = { -0.25, -0.25, -0.25, 0.25, 0.25, 0.25 }, -- Core
		connect_top = { -0.1875, 0.25, -0.1875, 0.1875, 0.5, 0.1875 },
		connect_left = { -0.5, -0.1875, -0.1875, -0.25, 0.1875, 0.1875 },
		connect_right = { 0.25, -0.1875, -0.1875, 0.5, 0.1875, 0.1875 },
		connect_bottom = { -0.1875, -0.5, -0.25, 0.1875, -0.25, 0.25 },
		connect_front = { -0.1875, -0.1875, -0.5, 0.1875, 0.1875, -0.25 },
		connect_back = { -0.1875, -0.1875, 0.25, 0.1875, 0.1875, 0.5 },
	},
	connect_sides = { "top", "bottom", "front", "back", "left", "right" },
	connects_to = {"group:potato_plant", "voxelforge:end_stone"},
	sounds = vlf_sounds.node_sound_wood_defaults(),
	drop = {
		items = {
			{ items = { "voxelforge:potato_fruit"}, rarity = 2 },
		}
	},
	groups = {handy=1,axey=1, deco_block = 1, dig_by_piston = 1, destroy_by_lava_flow = 1, potato_plant = 1, unsticky = 1},

	node_placement_prediction = "",
	--after_dig_node = voxelforge.check_detach_potato_plant,
	--on_blast = voxelforge.check_blast_potato_plant,
	_vlf_blast_resistance = 2,
	_vlf_hardness = 0.4,
})

-- Grow a complete potato plant at pos
function voxelforge.grow_potato_plant(pos, node, pr)
    local flowers = { pos }
    -- Plant initial flower (if it isn't there already)
    if not node then
        node = minetest.get_node(pos)
    end
    if node.name ~= "voxelforge:powerful_potato" then
        minetest.set_node(pos, { name = "voxelforge:powerful_potato" })
    end
    while true do
        local new_flowers_list = {}
        for f = 1, #flowers do
            local new_flowers = voxelforge.grow_potato_plant_step(flowers[f], minetest.get_node(flowers[f]), pr)
            if #new_flowers > 0 then
                table.insert(new_flowers_list, new_flowers)
            end
        end
        if #new_flowers_list == 0 then
            return
        end
        flowers = {}
        for l = 1, #new_flowers_list do
            for f = 1, #new_flowers_list[l] do
                table.insert(flowers, new_flowers_list[l][f])
            end
        end
    end
end

-- Check if a root is touching four or more strong roots
local function is_touching_four_or_more_roots(pos)
    local around = {
        { x = -1, y = 0, z = 0 },
        { x = 1, y = 0, z = 0 },
        { x = 0, y = 0, z = -1 },
        { x = 0, y = 0, z = 1 },
    }
    local count = 0
    for _, offset in ipairs(around) do
        local neighbor = vector.add(pos, offset)
        if minetest.get_node(neighbor).name == "voxelforge:strong_roots" then
            count = count + 1
            if count >= 4 then
                return true
            end
        end
    end
    return false
end

-- Grow a single step of a potato plant at pos.
-- Pos must be a potato flower or a strong root.
function voxelforge.grow_potato_plant_step(pos, node, pr)
    local new_flower_buds = {}

    if node.name == "voxelforge:powerful_potato" then
        local age = node.param2 or 0
        local below = { x = pos.x, y = pos.y - 1, z = pos.z }
        local node_below = minetest.get_node(below)

        if age < 3--[[ and node_below.name == "air" ]]and pr:next(1, 100) <= 78 then -- 50% chance to grow downward
            minetest.set_node(below, { name = "voxelforge:strong_roots", param2 = age })
            table.insert(new_flower_buds, below)
        elseif age >= 3 then
            for _, offset in ipairs({
                { x = -1, y = 0, z = 0 },
                { x = 1, y = 0, z = 0 },
                { x = 0, y = 0, z = -1 },
                { x = 0, y = 0, z = 1 },
            }) do
                local neighbor = vector.add(pos, offset)
                if --[[minetest.get_node(neighbor).name == "air" and ]]pr:next(1, 100) <= 7 then -- 25% chance to grow horizontally
                if node.name ~= "voxelforge:powerful_potato" then
                    minetest.set_node(neighbor, { name = "voxelforge:strong_roots" })
                    table.insert(new_flower_buds, neighbor)
                end
                end
            end
        end

        minetest.set_node(pos, { name = "voxelforge:powerful_potato", param2 = age + 1 })

    elseif node.name == "voxelforge:strong_roots" then
        if not is_touching_four_or_more_roots(pos) then
            local below = { x = pos.x, y = pos.y - 1, z = pos.z }
            local node_below = minetest.get_node(below)

            if --[[node_below.name == "air" and ]]pr:next(1, 100) <= 78 then -- 50% chance to grow downward
                minetest.set_node(below, { name = "voxelforge:strong_roots" })
                table.insert(new_flower_buds, below)
            end

            for _, offset in ipairs({
                { x = -1, y = 0, z = 0 },
                { x = 1, y = 0, z = 0 },
                { x = 0, y = 0, z = -1 },
                { x = 0, y = 0, z = 1 },
            }) do
                local neighbor = vector.add(pos, offset)
                if --[[minetest.get_node(neighbor).name == "air" and ]]pr:next(1, 100) <= 7 then -- 25% chance to grow horizontally
                	if node.name ~= "voxelforge:powerful_potato" then
                   	 minetest.set_node(neighbor, { name = "voxelforge:strong_roots" })
                    	table.insert(new_flower_buds, neighbor)
                    	end
                end
            end
        end
    end

    return new_flower_buds
end

--- ABM ---
local seed = minetest.get_mapgen_setting("seed")
local pr = PseudoRandom(seed)
minetest.register_abm({
	label = "potato plant growth",
	nodenames = { "voxelforge:powerful_potato", "voxelforge:strong_roots" },
	interval = 15,
	chance = 2.0,
	action = function(pos, node)
		voxelforge.grow_potato_plant_step(pos, node, pr)
	end,
})
