

local liquid = {
	registered_liquids = {},
	-- A list of registered liquids

	running = true,
	-- This is the initial state of the liquid transformation mod.
	-- If set to false, liquids do not flow until they activated.

	MAIN_TICK = 0.025,
	-- The main tick speed. Changing that tick affects all liquids
	-- proportionally.

  -- Store the original core functions that need to be overridden.
  set_node = core.set_node,
  add_node = core.add_node,
  bulk_set_node = core.bulk_set_node,
  remove_node = core.remove_node,
}

-- This counter is used generate unique names
local resume_counter = 1


function liquid.register_liquid(def)
	-- This function generates a new liquid transformation.

	local def_flowing = def.ndef_flowing
	local def_source = def.ndef_source

	local wait_count = 0

	local modname = minetest.get_current_modname()

	local NAME_SOURCE  = def.name_source
	assert(NAME_SOURCE, '"name_source" was nil')

	local NAME_FLOWING = def.name_flowing
	assert(NAME_FLOWING, '"name_flowing" was nil ')

	local FLOW_DISTANCE = def.liquid_range or 7
	assert(FLOW_DISTANCE >= 0 and FLOW_DISTANCE < 8,
		'The liquid_range must be in range [0 <= x < 8]')

	local RENEWABLE = def.liquid_renewable or false
	local TICKS = def.liquid_tick or 0.5


	-- This table is a function that calculates then next lower liquid level.
	local level_tb = {}
	for i = 0, 9 do
		level_tb[i+1] = math.round(math.floor(i * (FLOW_DISTANCE+1) /  8) * 8 / (FLOW_DISTANCE+1))
	end



	----------------------------------------------------------------------
	-- Variables for processing a burst of iterations
	----------------------------------------------------------------------
	
	-- Swappable list of positions to be processed in the next iteration
	local update_next_set_A = {}
	local update_next_set_B = {}
	local update_next_set = update_next_set_A

	-- A list of nodes that have been changed during a burst.
	local changed_nodes = {}
	-- A list of nodes that have been red during the burst (caching)
	local read_nodes = {}



	----------------------------------------------------------------------
	-- Variables for path finding to the nearest slope
	----------------------------------------------------------------------

	-- The list of nodes to be updated next.
	-- Two of them for GC-free swapping
	local pf_search_list_A = { }
	local pf_search_list_B = { }
	local pf_search_list

	-- The map of potential liquid levels.
	local pf_pmap = {}

	-- An array of node positions that hit a slope.
	-- Two of them for GC-free swapping
	local pf_found_A = { }
	local pf_found_B = { }
	local pf_found

	-- If false the path finding was not successful the whole iteration will be
	-- void.
	local pf_ok = true



	----------------------------------------------------------------------
	-- Variables for one liquid transformation iteration
	----------------------------------------------------------------------

	-- variables for the positions
	local p111 -- center
	local p011 -- left
	local p211 -- right
	local p101 -- below
	local p121 -- above
	local p110 -- in front
	local p112 -- behind

	-- variables for the nodes
	local n111
	local n011
	local n211
	local n110
	local n112
	local n101
	local n121

	-- variables for the liquid level
	local l111
	local l011
	local l211
	local l110
	local l112
	local l101
	local l121

	-- The map that show where the current liquid shall spread to.
	local lt_map
	-- The level of the new node when spreading
	local lt_new_level
	-- The node for the new liquid when spreading
	local lt_new_liquid


	local function vector_add_to(v, x, y, z)
		v.x = v.x + x
		v.y = v.y + y
		v.z = v.z + z
	end

	local function get_position_from_hash(v, hash)
		v.x = (hash % 65536) - 32768
		hash  = math.floor(hash / 65536)
		v.y = (hash % 65536) - 32768
		hash  = math.floor(hash / 65536)
		v.z = (hash % 65536) - 32768
	end



	local function update_next(item)
		-- This function puts an item into the list that is processed in the next
		-- iteration.
		local h = core.hash_node_position(item.pos)
		if update_next_set[h] == nil then
			update_next_set[h] = item
		end
	end


	local function get_liquid_level(node)
		-- This function returns the level of a liquid node or nil if it isn't a
		-- liquid node

		if node.name == NAME_SOURCE then
			return 8
		elseif node.name == NAME_FLOWING then
			if bit.band(node.param2, 0x08) ~= 0 then
				return 8
			else 
				return bit.band(node.param2, 0x07)
			end
		else
			return nil
		end 
	end


	local function set_node(pos, node)
		-- This function puts the new node into a map.
		-- If there is already a node in that map at the same location, the one
		-- with the larger level wins. This is important do ensure symmetric flow
		-- if the underlying structure is symmetric as well. It also prevents weird
		-- things from happening like half level liquids lingering around.


		local h = core.hash_node_position(pos)
		local other = changed_nodes[h]

		if not other then
			changed_nodes[h] = node
		else
			local ln = get_liquid_level(node)  or 0
			local lo = get_liquid_level(other) or 0

			if ln > lo then
				changed_nodes[h] = node
			end
		end
	end

	local function get_node(pos)
		-- This function is the just the cached version of the `core.get_node()`

		local h = core.hash_node_position(pos)
		local node = read_nodes[h]

		if node then
			return node
		else
			node = core.get_node_or_nil(pos)
			read_nodes[h] = node
			return node
		end
	end

	local function hmap_clear(tb)
		for k, _ in pairs(tb) do
			tb[k] = nil
		end
	end

	local function arr_clear(tb)
		for k, _ in ipairs(tb) do
			tb[k] = nil
		end
	end


	local function is_liquid(node)
		return node.name == NAME_SOURCE or node.name == NAME_FLOWING
	end


	local function make_liquid(level)
		-- This function creates a new liquid node

		if level == 8 or level == 'down' then
			return {
				name = NAME_FLOWING,
				param2 = 8,
			}

		elseif level == 'source' then
			return {
				name = NAME_SOURCE,
			}

		elseif level <= 0 then
			return {
				name = 'air'
			}

		else
			return {
				name = NAME_FLOWING,
				param2 = bit.band(level, 0x07),
			}

		end
	end


	local function is_floodable(n)
		-- This function tests if the node is floodable in theory. For the final
		-- decisions, other factors are in play as well.

		if n.name == 'air' or n.name == NAME_SOURCE or n.name == NAME_FLOWING then
			return true
		else
			local ndef = core.registered_nodes[n.name]
			if ndef and ndef.floodable then
				return true
			end
		end
		return false
	end



	local pf_step_pos = vector.zero()
	local function pf_step(hpos, x, y, z, level)
		-- This function checks if the current position has an obstacle or a
		-- slope.
		--
		-- `hpos`  A hash of the position
		-- `x`     The shift in the x direction
		-- `y`     The shift in the y direction
		-- `z`     The shift in the z direction
		-- `level` The level at the new position

		get_position_from_hash(pf_step_pos, hpos)
		-- move one horizontal
		vector_add_to(pf_step_pos, x, y, z)
		local hpos_next = core.hash_node_position(pf_step_pos)

		if pf_pmap[hpos_next] == nil then
			local n1 = get_node(pf_step_pos)

			-- move one down
			vector_add_to(pf_step_pos, 0, -1, 0)
			local n2 = get_node(pf_step_pos)

			if not (n1 and n2) then
				pf_ok = false
				return
			end

			local l1 = get_liquid_level(n1)

			local f1 = is_floodable(n1)
			local f2 = is_floodable(n2)

			if f1 and f2 then 
				pf_found[#pf_found+1] = hpos_next
				pf_pmap[hpos_next] = level
			elseif f1 and (l1 or 0) <= level then
				pf_search_list[#pf_search_list+1] = hpos_next
				pf_pmap[hpos_next] = level
			end
		end
	end

	local pf_back_trace_pos = vector.zero()
	local function pf_back_trace(hpos, x, y, z, level)

		get_position_from_hash(pf_back_trace_pos, hpos)
		vector_add_to(pf_back_trace_pos, x, y, z)
		local hpos_next = core.hash_node_position(pf_back_trace_pos)

		local m = pf_pmap[hpos_next]
		if m and m > level then
			pf_found[#pf_found+1] = hpos_next
		end
	end

	local function rmap_read(map, pos)
		if map == 'DUMMY' then
			return nil
		end

		local hpos = core.hash_node_position(pos)
		return map[hpos]
	end

	local function path_find(pos, slope_dist)
		-- This function searches the nearest slopes within a maximum path distance
		-- of 5 nodes.
		-- If any node was 'ignore' then this function returns nil.


		local orig_level = get_liquid_level(get_node(pos))
		if orig_level <= 1 then
			-- If level of the origin is too small we return a dummy map. 
			return 'DUMMY'
		end

		-- initialize the variables.
		pf_ok = true

		arr_clear(pf_search_list_A)
		arr_clear(pf_search_list_B)
		pf_search_list = pf_search_list_A

		local h = core.hash_node_position(pos)
		pf_search_list[1] = h

		hmap_clear(pf_pmap)

		-- An array of node positions that hit a slope.
		arr_clear(pf_found_A)
		arr_clear(pf_found_B)
		pf_found = pf_found_A

		-- The map containing the real paths (decreasing liquid levels from origin
		-- to slope) (the result)
		-- rmap is intentionally GC collectable, this reference will run wild!
		local rmap = {}


		pf_pmap[h] = orig_level

		local level = orig_level

		for i = 1, 5 do
			-- Decrease the liquid level.
			level = level_tb[level]

			if level == 0 then
				break
			end

			local l = pf_search_list

			-- Swap the search lists
			if pf_search_list == pf_search_list_A then
				arr_clear(pf_search_list_B)
				pf_search_list = pf_search_list_B
			else
				arr_clear(pf_search_list_A)
				pf_search_list = pf_search_list_A
			end

			for i, hpos in ipairs(l) do
				-- Step into all 4 directions
				pf_step(hpos, -1, 0, 0, level)
				pf_step(hpos,  1, 0, 0, level)
				pf_step(hpos,  0, 0,-1, level)
				pf_step(hpos,  0, 0, 1, level)

				if not pf_ok then
					break
				end
			end

			if not pf_ok or #pf_found > 0 then
				break
			end
		end 

		if pf_ok then
			if #pf_found == 0 then
				-- If we hit the minimum level without finding a slope. The liquid
				-- shall flow in all directions where there is no obstacle. The
				-- potential map becomes the real map.
				rmap = pf_pmap
				-- Let the reference run wild
				pf_pmap = {}
			else 
				-- If a slope within range was found we need to remove all levels that
				-- are not part of the shortest path to those slopes.


				while #pf_found > 0 do

					local l = pf_found

					if pf_found == pf_found_A then
						arr_clear(pf_found_B)
						pf_found = pf_found_B
					else
						arr_clear(pf_found_A)
						pf_found = pf_found_A
					end

					for i, hpos in ipairs(l) do
						local level = pf_pmap[hpos]
						rmap[hpos] = level


						-- Search the origin.
						pf_back_trace(hpos, -1, 0, 0, level)
						pf_back_trace(hpos,  1, 0, 0, level)
						pf_back_trace(hpos,  0, 0,-1, level)
						pf_back_trace(hpos,  0, 0, 1, level)
					end
				end
			end

			--core.log('--------------------------')
			--for x = -8,8 do
			--	line = '| '
			--	for z = -8,8 do
			--		local h = core.hash_node_position(pos + vector.new(x, 0, z))
			--		local level = rmap[h]
			--		if level then
			--			line = line..level..' '
			--		elseif pmap[h] then
			--			line = line..'. '
			--		else
			--			line = line..'	'
			--		end
			--	end
			--	line = line..' |'
			--	core.log(line)
			--end

			return rmap

		else
			return nil
		end
	end



	local function lt_flood(p, n, l)
		local cnt_flood = 0
		local m = rmap_read(lt_map, p)
		if m and m == lt_new_level then
			if is_floodable(n) then
				cnt_flood = 1

				if lt_new_level > (l or 0) then
					update_next({pos=p, map=lt_map})
					set_node(p, lt_new_liquid)

				elseif n111.name == NAME_SOURCE and l and l == 7 then
					-- Give it a chance to renew
					update_next({pos=p, map=lt_map})
				end
			end
		end
		return cnt_flood
	end


	local function lt_push_horizontal()
		-- This function pushes the liquid in all four directions if the
		-- map wants that and the real node there is actually floodable.
		-- The number of *potential* floods are counted. If the count
		-- remains 0, the map is no longer suitable.
		local cnt_flood = 0
		cnt_flood = cnt_flood + lt_flood(p011, n011, l011)
		cnt_flood = cnt_flood + lt_flood(p211, n211, l211)
		cnt_flood = cnt_flood + lt_flood(p110, n110, l110)
		cnt_flood = cnt_flood + lt_flood(p112, n112, l112)
		return cnt_flood

	end




	local function flow_iteration(item)

		-- This is the position of the node to be updated
		p111 = item.pos
		-- This is the map that shows to where the liquid should spread.
		lt_map = item.map
		-- This tells us if the liquid should just sink without spread.
		local is_sinking = item.is_sinking

		n111 = get_node(p111)
		if not n111 then
			return
		end

		p011 = vector.offset(p111, -1,  0,  0)
		p211 = vector.offset(p111,  1,  0,  0)
		p101 = vector.offset(p111,  0, -1,  0)
		p121 = vector.offset(p111,  0,  1,  0)
		p110 = vector.offset(p111,  0,  0, -1)
		p112 = vector.offset(p111,  0,  0,  1)

		n011 = get_node(p011)
		n211 = get_node(p211)
		n110 = get_node(p110)
		n112 = get_node(p112)
		n101 = get_node(p101)
		n121 = get_node(p121)

		if not ( n011 and n211 and n110 and n112 and n101 and n121 ) then 
			return
		end


		if RENEWABLE then
			local count_sources = 0
			if n011.name == NAME_SOURCE then count_sources = count_sources + 1 end
			if n211.name == NAME_SOURCE then count_sources = count_sources + 1 end
			if n110.name == NAME_SOURCE then count_sources = count_sources + 1 end
			if n112.name == NAME_SOURCE then count_sources = count_sources + 1 end

			if (n111.name == NAME_FLOWING or n111.name == 'air') and count_sources >= 2 then 
				-- Renew liquid
				update_next({pos=p111})
				set_node(p111, { name=NAME_SOURCE })
				if n011.name ~= NAME_SOURCE then update_next({pos=p011}) end
				if n211.name ~= NAME_SOURCE then update_next({pos=p211}) end
				if n110.name ~= NAME_SOURCE then update_next({pos=p110}) end
				if n112.name ~= NAME_SOURCE then update_next({pos=p112}) end
				return
			end
		end

		-- These variables store the level or nil if the node isn't a liquid.
		l111 = get_liquid_level(n111)
		l011 = get_liquid_level(n011)
		l211 = get_liquid_level(n211)
		l110 = get_liquid_level(n110)
		l112 = get_liquid_level(n112)
		l101 = get_liquid_level(n101)
		l121 = get_liquid_level(n121)

		-- calculate the liquid level that is supported here.
		local support_level = 1

		if l121 ~= nil then 
			-- node above is a liquid
			support_level = 9
		elseif n111.name == NAME_SOURCE then
			-- the current node is a source
			support_level = 9
		else
			-- the neighboring node on the same Y-plan with the highest level counts
			if l011 ~= nil and support_level < l011 then
				support_level = l011
			end
			if l211 ~= nil and support_level < l211 then
				support_level = l211
			end
			if l110 ~= nil and support_level < l110 then
				support_level = l110
			end
			if l112 ~= nil and support_level < l112 then
				support_level = l112
			end
		end


		-- subtract 1 so that the level reaches from 0 to 8
		-- This variable tells us what level the current node should have.
		-- If it is higher we will reduce it and if it is lower we increase it.
		support_level = level_tb[support_level]


		if l111 ~= nil then
			-- The current node is already a liquid

			if l111 == support_level and not is_sinking then
				-- The current node is on its terminal level
				-- This means it is ready to spread.

				-- Get the next level from a table
				lt_new_level = level_tb[support_level]

				local d101 = core.registered_nodes[n101.name]

				if n101.name == NAME_SOURCE and n111.name ~= NAME_SOURCE then
					-- the current node is on top of a source node. No more flowing here.
					-- With the exception that when the current node is a source node as
					-- well.
				elseif
						n101.name == 'air'        or
						n101.name == NAME_FLOWING or
						(d101 and d101.floodable) then

					if not l101 or l101 < 8 then
						-- turn the liquid below into down-flowing
						update_next({pos=p101})
						set_node(p101, make_liquid('down'))
					else
						-- The liquid already flows down
					end
				elseif lt_new_level and lt_new_level > 0 then

					local is_new_map = false
					if not lt_map then
						-- Make a new map if there is none.
						lt_map = path_find(p111)
						if not lt_map then
							return
						end
						is_new_map = true
					end

					lt_new_liquid = make_liquid(lt_new_level)

					if lt_push_horizontal() == 0 and not is_new_map then
						-- The map might be outdated, try once more with a new map
						lt_map = path_find(p111)
						if not lt_map then
							return
						end
						lt_push_horizontal()
					end
				end

			elseif l111 > support_level then
				-- The liquid level is too high here we need to reduce it.

				if support_level > 0 then
					update_next({pos=p111, is_sinking=true})
				end
				set_node(p111, make_liquid(support_level))

				-- Neighboring nodes might need to be reduced as well
				if l011 ~= nil then update_next({pos=p011, is_sinking=true}) end
				if l211 ~= nil then update_next({pos=p211, is_sinking=true}) end
				if l110 ~= nil then update_next({pos=p110, is_sinking=true}) end
				if l112 ~= nil then update_next({pos=p112, is_sinking=true}) end

				-- the node below might need an update as well, but only if the liquid
				-- has completely gone
				if support_level == 0 and l101 ~= nil then
					update_next({pos=p101, is_sinking=true})
				end
			end
		else
			-- It seams that the current node is not a liquid at all.
			-- We update the neighbors because it might have been a liquid
			-- previously.
			if l011 ~= nil then update_next({pos=p011}) end
			if l211 ~= nil then update_next({pos=p211}) end
			if l110 ~= nil then update_next({pos=p110}) end
			if l112 ~= nil then update_next({pos=p112}) end
			if l101 ~= nil then update_next({pos=p101}) end
			if l121 ~= nil then update_next({pos=p121}) end
		end
	end

	local function liquid_update(pos)
		-- pos might not be a vector
		local p = vector.copy(pos)
		update_next({pos = p})
	end

	core.register_on_placenode(liquid_update)
	core.register_on_dignode(liquid_update)


	local function set_common_defs(ndef)

		if ndef.on_construct ~= nil then
			local on_construct = ndef.on_construct
			ndef.on_construct = function(pos)
				liquid_update(pos)
				on_construct(pos)
			end
		else
			ndef.on_construct = liquid_update
		end

		if ndef.after_destruct ~= nil then
			local after_destruct = ndef.after_destruct
			ndef.after_destruct = function(pos)
				liquid_update(pos)
				after_destruct(pos)
			end
		else
			ndef.after_destruct = liquid_update
		end


		-- remove attributes that might interfere.
		ndef.liquidtype = nil


		ndef.liquid_alternative_source	= NAME_SOURCE
		ndef.liquid_alternative_flowing = NAME_FLOWING
		ndef.paramtype					 = "light"
		ndef.paramtype2					 = "flowingliquid"

		if ndef.liquid_move_physics == nil then
			ndef.liquid_move_physics = true
		end


		if not ndef.groups then
			ndef.groups = { }
		end

	end


	set_common_defs(def_source)
	def_source.drawtype								= "liquid"
	def_source.groups.liquid_source		= 1
	core.register_node(NAME_SOURCE, def_source)


	set_common_defs(def_flowing)
	def_flowing.drawtype							= "flowingliquid"
	def_flowing.groups.liquid_flowing = 1
	core.register_node(NAME_FLOWING, def_flowing)


	core.register_on_mods_loaded(function()

		-- Luanti activates the builtin liquid transformation based on the
		-- `liquidtype`. Therefor we need to set it's value to 'none'.
		-- BUT many mods also read that value to check if this node is a liquid.
		-- This hack sets the value to the respective liquid type after Luanti red
		-- its value.
		-- This way mods see what they need, at least their callbacks do.

		local function set_liquidtype(name, liquidtype)
			local mt = getmetatable(core.registered_nodes[name])
			local oldidx = mt.__index
			mt.__index = function(tbl, k)
				if k == "liquidtype" then
					return liquidtype
				end
				if type(oldidx) == "function" then return oldidx(tbl, k) end
				if type(oldidx) == "table" and not rawget(tbl, k) then return oldidx[k] end
				return tbl[k]
			end
			setmetatable(core.registered_nodes[name], mt)
		end

		set_liquidtype(NAME_SOURCE, 'source')
		set_liquidtype(NAME_FLOWING, 'flowing')

		assert(core.registered_nodes[NAME_SOURCE].liquidtype == 'source',
		'This hack does no longer work')
		assert(core.registered_nodes[NAME_FLOWING].liquidtype == 'flowing',
		'This hack does no longer work')


	end)


	core.register_lbm({
		label = "Continue the liquids",

		name = modname..":resume_liquid_"..resume_counter,

		nodenames = {NAME_SOURCE, NAME_FLOWING},

		run_at_every_load = true,

		action = function(pos, node, dtime_s)
			local n111 =	node
			local n011 =	core.get_node(vector.offset(pos, -1, 0, 0))
			local n211 =	core.get_node(vector.offset(pos,  1, 0, 0))
			local n110 =	core.get_node(vector.offset(pos,  0, 0,-1))
			local n112 =	core.get_node(vector.offset(pos,  0, 0, 1))
			local n101 =	core.get_node(vector.offset(pos,  0,-1, 0))

			if n101.name ~= NAME_SOURCE or 
				n111.name ~= NAME_SOURCE or 
				n011.name ~= NAME_SOURCE or 
				n211.name ~= NAME_SOURCE or 
				n110.name ~= NAME_SOURCE or 
				n112.name ~= NAME_SOURCE then 

				core.after(5, function()
					liquid_update(pos)
				end)
			end
		 end,
	})

	resume_counter = resume_counter + 1


	local tick_dtime = 0.0

	local function tick()
		tick_dtime = tick_dtime + liquid.MAIN_TICK


		-- If the TICKS is smaller than Luanti default tick we do multiple steps per
		-- tick.
		while tick_dtime >= TICKS do
			tick_dtime = tick_dtime - TICKS

			if next(update_next_set) ~= nil then
				local q = update_next_set

				-- Reset the containers for reuse
				if update_next_set == update_next_set_A then
					hmap_clear(update_next_set_B)
					update_next_set = update_next_set_B
				else
					hmap_clear(update_next_set_A)
					update_next_set = update_next_set_A
				end

				hmap_clear(read_nodes)
				hmap_clear(changed_nodes)

				for _, item in pairs(q) do
					-- Do the flow magic
					flow_iteration(item)
				end

				for h, node in pairs(changed_nodes) do
					local pos = core.get_position_from_hash(h)

					local old = read_nodes[h]
					local old_ndef = core.registered_nodes[old.name]
					if old_ndef.on_flood then
						if not old_ndef.on_flood(pos, old, node) then
							liquid.set_node(pos, node)
						end
					else
						liquid.set_node(pos, node)
					end
				end
			end
		end
	end

	liquid.registered_liquids[#liquid.registered_liquids+1] = {
		tick = tick,
		update = liquid_update,
	}
end

function liquid.tick()
	for i, o in ipairs(liquid.registered_liquids) do
		o.tick()
	end
end

function liquid.update(pos)
	for i, o in ipairs(liquid.registered_liquids) do
		o.update(pos)
	end
end

core.register_globalstep(function(dtime)
	if liquid.running then
		liquid.tick()
	end
end)

core.register_chatcommand('liquid', {
	func = function(name, param)
		if param == 'step' then
			liquid.running = false
			liquid.tick()
		elseif param == 'run' then
			liquid.running = true
		elseif param == 'stop' then
			liquid.running = false
		end
	end
})


core.register_on_mods_loaded(function()

  -- `liquids_pointable` does not work anymore. This should solve many
  -- issues.
  for name, ndef in pairs(core.registered_items) do
    if ndef.liquids_pointable then
      local p = table.copy(ndef.pointabilities or {})

      if not p.nodes then
        p.nodes = {}
      end

      if not p.nodes["group:liquid"] and
        not p.nodes["group:liquid_source"] and
        not p.nodes["group:liquid_flowing"] then

        core.log("warning", 'Node "'..name..'" uses deprecated "liquids_pointable" attribute')
        p.nodes["group:liquid"] = true
        core.override_item(name, {
          pointabilities = p
        })
      end
    end
  end
end)



-- Override the set_node function so that it calls liquid.update() on every
-- node change.
core.set_node = function(pos, node)
  liquid.set_node(pos, node);
  liquid.update(pos);
end

-- Override the add_node function so that it calls liquid.update() on every
-- node change.
core.add_node = function(pos, node)
  liquid.add_node(pos, node)
  liquid.update(pos)
end

-- Override the bulk_set_node function so that it calls liquid.update() on every
-- node change.
core.bulk_set_node = function(positions, node)
  liquid.bulk_set_node(positions, node)
  for _, p in ipairs(positions) do
    liquid.update(p)
  end
end

-- Override the remove_node function so that it calls liquid.update() on every
-- node change.
core.remove_node = function(pos)
  liquid.remove_node(pos)
  liquid.update(pos)
end



return liquid

