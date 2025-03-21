--[[local AIR = {name = "air"}
local abs = math.abs
local max = math.max
local floor = math.floor
local vector_new = vector.new
local is_solid_not_tree = vl_terraforming._is_solid_not_tree
local is_tree_not_leaves = vl_terraforming._is_tree_not_leaves

--- Clear an area for a structure
--
-- Rounding: we model an ellipse. At zero rounding, we want the line go through the corner, at sx/2, sz/2.
-- For this, we need to make ellipse sized 2a=sqrt(2)*sx, 2b=sqrt(2)*sz,
-- Which yields a = sx/sqrt(2), b=sz/sqrt(2) and a^2=sx^2*0.5, b^2=sz^2*0.5
-- To get corners, we decrease a and b by approx. corners each
-- The ellipse condition dx^2/a^2+dz^2/b^2 <= 1 then yields dx^2/(sx^2*0.5) + dz^2/(sz^2*0.5) <= 1
-- We use wx2=sx^-2*2, wz2=sz^-2*2 and then dx^2*wx2+dz^2*wz2 <= 1
--
-- @param vm VoxelManip: Lua voxel manipulator
-- @param px number: lowest x
-- @param py number: lowest y
-- @param pz number: lowest z
-- @param sx number: x width
-- @param sy number: y height
-- @param sz number: z depth
-- @param corners number: corner rounding
-- @param surface_mat Node: surface node material
-- @param dust_mat Node: surface dust material
-- @param pr PcgRandom: random generator
function vl_terraforming.clearance_vm(vm, px, py, pz, sx, sy, sz, corners, surface_mat, dust_mat, pr)
	if sx <= 0 or sy <= 0 or sz <= 0 then return end
	local get_node_at = vm.get_node_at
	local set_node_at = vm.set_node_at
	corners = corners or 0
	local wx2, wz2 = max(sx - corners, 1)^-2 * 2, max(sz - corners, 1)^-2 * 2
	local cx, cz = px + sx * 0.5 - 0.5, pz + sz * 0.5 - 0.5
	local min_clear, max_clear = py+sy, py+floor(sy*1.5+2) -- todo: make more parameterizable, but adds another parameter
	-- excavate the needed volume and some headroom
	local vec = vector_new(0, 0, 0) -- single vector, to avoid allocations -- performance!
	for xi = px-1,px+sx do
		local dx = abs(cx-xi)
		local dx2 =  max(dx+0.51,0)^2*wx2
		local dx21 = max(dx-0.49,0)^2*wx2
		vec.x = xi
		for zi = pz-1,pz+sz do
			local dz = abs(cz-zi)
			local dz2 =  max(dz+0.51,0)^2*wz2
			local dz21 = max(dz-0.49,0)^2*wz2
			vec.z = zi
			if xi >= px and xi < px+sx and zi >= pz and zi < pz+sz and dx2+dz2 <= 1 then
				vec.y = py
				if vm:get_node_at(vec).name ~= "mcl_core:bedrock" then set_node_at(vm, vec, AIR) end
				vec.y = py - 1
				local n = get_node_at(vm, vec)
				if n and n.name ~= surface_mat.name and is_solid_not_tree(n) then
					set_node_at(vm, vec, surface_mat)
				end
				for yi = py+1,min_clear do -- full height for inner area
					vec.y = yi
					if vm:get_node_at(vec).name ~= "mcl_core:bedrock" then set_node_at(vm, vec, AIR) end
				end
			elseif dx21+dz21 <= 1 then
				-- widen the cave above by 1, to make easier to enter for mobs
				-- todo: make configurable?
				vec.y = py + 1
				local name = vm:get_node_at(vec).name
				if name ~= "mcl_core:bedrock" then
					local mat = AIR
					if dust_mat then
						vec.y = py
						if vm:get_node_at(vec).name == surface_mat.name then mat = dust_mat end
						vec.y = py + 1
					end
					set_node_at(vm, vec, mat)
				end
				for yi = py+2,min_clear-1 do
					vec.y = yi
					if vm:get_node_at(vec).name ~= "mcl_core:bedrock" then set_node_at(vm, vec, AIR) end
					if yi > py+4 then
						local p = (yi-py) / (max_clear-py)
						--minetest.log(tostring(p).."^2 "..tostring(p*p).." rand: "..pr:next(0,1e9)/1e9)
						if (pr:next(0,1e9)/1e9) < p then break end
					end
				end
				-- remove some tree parts and fix surfaces down
				for yi = py,py-1,-1 do
					vec.y = yi
					local n = get_node_at(vm, vec)
					if is_tree_not_leaves(n) then
						set_node_at(vm, vec, surface_mat)
						if dust_mat and yi == py then
							vec.y = yi + 1
							if vm:get_node_at(vec).name == "air" then set_node_at(vm, vec, dust_mat) end
						end
					else
						if n and n.name ~= surface_mat.name and is_solid_not_tree(n) then
							set_node_at(vm, vec, surface_mat)
							if dust_mat then
								vec.y = yi + 1
								if vm:get_node_at(vec).name == "air" then set_node_at(vm, vec, dust_mat) end
							end
						end
						break
					end
				end
			end
		end
	end
	-- some extra gaps for entry
	-- todo: make optional instead of hard-coded 25%
	-- todo: only really useful if there is space at px-3,py+3 to px-3,py+5
	--[[
	for xi = px-2,px+sx+1 do
		local dx21 = max(abs(cx-xi)-0.49,0)^2*wx2
		local dx22 = max(abs(cx-xi)-1.49,0)^2*wx2
		for zi = pz-2,pz+sz+1 do
			local dz21 = max(abs(cz-zi)-0.49,0)^2*wz2
			local dz22 = max(abs(cz-zi)-1.49,0)^2*wz2
			if dx21+dz21 > 1 and dx22+dz22 <= 1 and pr:next(1,4) == 1 then
				if py+4 < sy then
					for yi = py+2,py+4 do
						vec = vector_new(xi, yi, zi)
						if vm:get_node_at(vec).name ~= "mcl_core:bedrock" then set_node_at(vm, vec, v) end
					end
				end
				for yi = py+1,py-1,-1 do
					local n = get_node_at(vm, vector_new(xi, yi, zi))
					if is_tree_bot_leaves(n) and n.name ~= "mcl_core:bedrock" then
						set_node_at(vm, vector_new(xi, yi, zi), AIR)
					else
						if n and n.name ~= surface_mat.name and is_solid_not_tree(n) then
							set_node_at(vm, vector_new(xi, yi, zi), surface_mat)
						end
						break
					end
				end
			end
		end
	end
	]]--
	-- cave some additional area overhead, try to make it interesting though
	--[[for yi = min_clear+1,max_clear do
		local dy2 = max(yi-min_clear-1,0)^2*0.05
		local active = false
		for xi = px-2,px+sx+1 do
			local dx22 = max(abs(cx-xi)-1.49,0)^2*wx2
			for zi = pz-2,pz+sz+1 do
				local dz22 = max(abs(cz-zi)-1.49,0)^2*wz2
				local keep_trees = (xi<px or xi>=px+sx) or (zi<pz or zi>=pz+sz) -- TODO make parameter?
				if dx22+dy2+dz22 <= 1 then
					vec.x, vec.y, vec.z = xi, yi, zi
					local name = get_node_at(vm, vec).name
					-- don't break bedrock or air
					if name == "air" or name == "ignore" or name == "mcl_core:bedrock" or name == "mcl_villages:no_paths" then goto continue end
					local meta = minetest.registered_items[name]
					local groups = meta and meta.groups
					local is_tree = groups.leaves or groups.tree or (groups.compostability or 0 > 50)
					if keep_trees and is_tree then goto continue end
					vec.y = yi-1
					-- do not clear above solid
					local name_below = get_node_at(vm, vec).name
					if name_below ~= "air" and name_below ~= "ignore" and name_below ~= "mcl_core:bedrock" then goto continue end
					-- try to completely remove trees overhead
					-- stop randomly depending on fill, to narrow down the caves
					if not keep_trees and not is_tree and (pr:next(0,1e9)/1e9)^0.5 > 1-(dx22+dy2+dz22-0.1) then goto continue end
					vec.x, vec.y, vec.z = xi, yi, zi
					set_node_at(vm, vec, AIR)
					active = true
					::continue::
				end
			end
		end
		if not active then break end
	end
end]]

--[[local AIR = {name = "air"}
local abs = math.abs
local max = math.max
local floor = math.floor
local is_solid_not_tree = vl_terraforming._is_solid_not_tree
local is_tree_not_leaves = vl_terraforming._is_tree_not_leaves

--- Clear an area for a structure
function vl_terraforming.clearance_vm(px, py, pz, sx, sy, sz, corners, surface_mat, dust_mat, pr)
	if sx <= 0 or sy <= 0 or sz <= 0 then return end
	corners = corners or 0
	local wx2, wz2 = max(sx - corners, 1)^-2 * 2, max(sz - corners, 1)^-2 * 2
	local cx, cz = px + sx * 0.5 - 0.5, pz + sz * 0.5 - 0.5
	local min_clear, max_clear = py+sy, py+floor(sy*1.5+2)
	local nodes_by_type = {}
	local metadata = {}

	for xi = px-1, px+sx do
		local dx = abs(cx-xi)
		local dx2 = max(dx+0.51,0)^2*wx2
		local dx21 = max(dx-0.49,0)^2*wx2
		for zi = pz-1, pz+sz do
			local dz = abs(cz-zi)
			local dz2 = max(dz+0.51,0)^2*wz2
			local dz21 = max(dz-0.49,0)^2*wz2
			if xi >= px and xi < px+sx and zi >= pz and zi < pz+sz and dx2+dz2 <= 1 then
				local pos = {x = xi, y = py, z = zi}
				if minetest.get_node(pos).name ~= "mcl_core:bedrock" then minetest.remove_node(pos) end
				pos.y = py - 1
				local n = minetest.get_node(pos)
				if n and n.name ~= surface_mat.name and is_solid_not_tree(n) then
					table.insert(nodes_by_type, {positions = {{x = pos.x, y = pos.y, z = pos.z}}, name = surface_mat.name})
				end
				for yi = py+1, min_clear do
					pos.y = yi
					if minetest.get_node(pos).name ~= "mcl_core:bedrock" then minetest.remove_node(pos) end
				end
			elseif dx21+dz21 <= 1 then
				local pos = {x = xi, y = py + 1, z = zi}
				local name = minetest.get_node(pos).name
				if name ~= "mcl_core:bedrock" then
					local mat = AIR
					if dust_mat then
						pos.y = py
						if minetest.get_node(pos).name == surface_mat.name then mat = dust_mat end
						pos.y = py + 1
					end
					table.insert(nodes_by_type, {positions = {{x = pos.x, y = pos.y, z = pos.z}}, name = mat.name})
				end
			end
		end
	end

	for _, node_group in pairs(nodes_by_type) do
		local positions = node_group.positions
		local total_positions = #positions
		local max_nodes_per_batch = 20000

		for i = 1, total_positions, max_nodes_per_batch do
			local end_index = math.min(i + max_nodes_per_batch - 1, total_positions)
			local batch_positions = {}
			for j = i, end_index do
				table.insert(batch_positions, positions[j])
			end
			minetest.bulk_set_node(batch_positions, {name = node_group.name})
		end
	end
end]]






local AIR = {name = "air"}
local abs = math.abs
local max = math.max
local floor = math.floor
local is_solid_not_tree = vl_terraforming._is_solid_not_tree
local is_tree_not_leaves = vl_terraforming._is_tree_not_leaves

--- Clear an area for a structure
function vl_terraforming.clearance_vm(px, py, pz, sx, sy, sz, corners, surface_mat, dust_mat, pr)
	if sx <= 0 or sy <= 0 or sz <= 0 then return end
	corners = corners or 0
	local wx2, wz2 = max(sx - corners, 1)^-2 * 2, max(sz - corners, 1)^-2 * 2
	local cx, cz = px + sx * 0.5 - 0.5, pz + sz * 0.5 - 0.5
	local min_clear, max_clear = py+sy, py+floor(sy*1.5+2)
	local nodes_by_type = {}
	local metadata = {}

	for xi = px-1, px+sx do
		local dx = abs(cx-xi)
		local dx2 = max(dx+0.51,0)^2*wx2
		local dx21 = max(dx-0.49,0)^2*wx2
		for zi = pz-1, pz+sz do
			local dz = abs(cz-zi)
			local dz2 = max(dz+0.51,0)^2*wz2
			local dz21 = max(dz-0.49,0)^2*wz2
			if xi >= px and xi < px+sx and zi >= pz and zi < pz+sz and dx2+dz2 <= 1 then
				local pos = {x = xi, y = py, z = zi}
				if minetest.get_node(pos).name ~= "mcl_core:bedrock" then minetest.remove_node(pos) end
				pos.y = py - 1
				local n = minetest.get_node(pos)
				if n and n.name ~= surface_mat.name and is_solid_not_tree(n) then
					table.insert(nodes_by_type, {positions = {{x = pos.x, y = pos.y, z = pos.z}}, name = surface_mat.name})
				end
				for yi = py+1, min_clear do
					pos.y = yi
					if minetest.get_node(pos).name ~= "mcl_core:bedrock" then minetest.remove_node(pos) end
				end
			elseif dx21+dz21 <= 1 then
				local pos = {x = xi, y = py + 1, z = zi}
				local name = minetest.get_node(pos).name
				if name ~= "mcl_core:bedrock" then
					local mat = AIR
					if dust_mat then
						pos.y = py
						if minetest.get_node(pos).name == surface_mat.name then mat = dust_mat end
						pos.y = py + 1
					end
					table.insert(nodes_by_type, {positions = {{x = pos.x, y = pos.y, z = pos.z}}, name = mat.name})
				end
			end
		end
	end

	for yi = min_clear+1, max_clear do
		local dy2 = max(yi-min_clear-1,0)^2*0.05
		local active = false
		for xi = px-2, px+sx+1 do
			local dx22 = max(abs(cx-xi)-1.49,0)^2*wx2
			for zi = pz-2, pz+sz+1 do
				local dz22 = max(abs(cz-zi)-1.49,0)^2*wz2
				local keep_trees = (xi<px or xi>=px+sx) or (zi<pz or zi>=pz+sz)
				if dx22+dy2+dz22 <= 1 then
					local pos = {x = xi, y = yi, z = zi}
					local name = minetest.get_node(pos).name
					if name == "air" or name == "ignore" or name == "mcl_core:bedrock" or name == "mcl_villages:no_paths" then goto continue end
					local meta = minetest.registered_items[name]
					local groups = meta and meta.groups
					local is_tree = groups.leaves or groups.tree or (groups.compostability or 0 > 50)
					if keep_trees and is_tree then goto continue end
					pos.y = yi-1
					local name_below = minetest.get_node(pos).name
					if name_below ~= "air" and name_below ~= "ignore" and name_below ~= "mcl_core:bedrock" then goto continue end
					if not keep_trees and not is_tree and (pr:next(0,1e9)/1e9)^0.5 > 1-(dx22+dy2+dz22-0.1) then goto continue end
					pos.y = yi
					minetest.remove_node(pos)
					active = true
					::continue::
				end
			end
		end
		if not active then break end
	end

	for _, node_group in pairs(nodes_by_type) do
		local positions = node_group.positions
		local total_positions = #positions
		local max_nodes_per_batch = 20000

		for i = 1, total_positions, max_nodes_per_batch do
			local end_index = math.min(i + max_nodes_per_batch - 1, total_positions)
			local batch_positions = {}
			for j = i, end_index do
				table.insert(batch_positions, positions[j])
			end
			minetest.bulk_set_node(batch_positions, {name = node_group.name})
		end
	end
end

