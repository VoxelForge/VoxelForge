vlf_lush_caves = {}
local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)
local schempath = minetest.get_modpath("vlf_schematics")

local PARTICLE_DISTANCE = 25

local adjacents = {
	vector.new(1,0,0),
	vector.new(-1,0,0),
	vector.new(0,0,1),
	vector.new(0,0,-1),
	vector.new(0,-1,0)
}

local function vector_distance_xz(a, b)
	return vector.distance(
		{ x=a.x, y=0, z=a.z },
		{ x=b.x, y=0, z=b.z }
	)
end

dofile(modpath.."/nodes.lua")
dofile(modpath.."/dripleaf.lua")

minetest.register_abm({
	label = "Spore Blossom Particles",
	nodenames = {"vlf_lush_caves:spore_blossom"},
	interval = 25,
	chance = 10,
	action = function(pos, node)
		if minetest.get_node(vector.offset(pos, 0, -1, 0)).name ~= "air" then return end
		for _,pl in pairs(minetest.get_connected_players()) do
			if vector.distance(pos,pl:get_pos()) < PARTICLE_DISTANCE then
				minetest.add_particlespawner({
					texture = "vlf_lush_caves_spore_blossom_particle.png",
					amount = 32,
					time = 25,
					minvel = vector.zero(),
					maxvel = vector.zero(),
					minacc = vector.new(-0.2, -0.1, -0.2),
					maxacc = vector.new(0.2, -0.3, 0.2),
					minexptime = 1.5,
					maxexptime = 8.5,
					minsize = 0.1,
					maxsize= 0.4,
					glow = 4,
					collisiondetection = true,
					collision_removal = true,
					minpos = vector.offset(pos, -0.25, -0.5, -0.25),
					maxpos = vector.offset(pos, 0.25, -0.5, 0.25),
					playername = pl:get_player_name(),
				})
			end
		end
	end
})

function vlf_lush_caves.makelake(pos,def,pr)
	local p1 = vector.offset(pos,-8,-4,-8)
	local p2 = vector.offset(pos,8,4,8)
	local nn = minetest.find_nodes_in_area_under_air(p1,p2,{"group:solid"})
	table.sort(nn,function(a, b)
		   return vector_distance_xz(pos, a) < vector_distance_xz(pos, b)
	end)
	if not nn[1] then return end
	--local dripleaves = {}
	for i=1,pr:next(1,#nn) do
		minetest.set_node(nn[i],{name="vlf_core:water_source"})
		--[[
		if pr:next(1,20) == 1 then
			table.insert(dripleaves,nn[i])
		end
		--]]
	end
	local nnn = minetest.find_nodes_in_area(p1,p2,{"vlf_core:water_source"})
	for k,v in pairs(nnn) do
		for kk,vv in pairs(adjacents) do
			local pp = vector.add(v,vv)
			local an = minetest.get_node(pp)
			if an.name ~= "vlf_core:water_source" then
				minetest.set_node(pp,{name="vlf_core:clay"})
				if pr:next(1,20) == 1 then
					minetest.set_node(vector.offset(pp,0,1,0),{name="vlf_lush_caves:moss_carpet"})
				end
			end
		end
	end
	--[[
	for _,d in pairs(dripleaves) do
		if minetest.get_item_group(minetest.get_node(d).name,"water") > 0 then
			minetest.set_node(vector.offset(d,0,-1,0),{name="vlf_lush_caves:dripleaf_big_waterroot"})
			minetest.registered_nodes["vlf_lush_caves:dripleaf_big_stem"].on_construct(d)
			for ii = 1, pr:next(1,4) do
				vlf_lush_caves.dripleaf_grow(d,{name = "vlf_lush_caves:dripleaf_big_stem"})
			end
		end
	end
	--]]
	return true
end

local function set_of_content_ids_by_group(group)
	local result = {}
	for name, def in pairs(minetest.registered_nodes) do
		if def.groups[group] then
			result[minetest.get_content_id(name)] = true
		end
	end
	return result
end

local CONVERTS_TO_ROOTED_DIRT = set_of_content_ids_by_group("material_stone")
CONVERTS_TO_ROOTED_DIRT[minetest.get_content_id("vlf_core:dirt")] = true
CONVERTS_TO_ROOTED_DIRT[minetest.get_content_id("vlf_core:coarse_dirt")] = true
local CONTENT_HANGING_ROOTS = minetest.get_content_id("vlf_lush_caves:hanging_roots")
local CONTENT_ROOTED_DIRT = minetest.get_content_id("vlf_lush_caves:rooted_dirt")

local function squared_average(a, b)
	local s = a + b
	return s*s/4
end

-- Azalea tree voxel manipulator buffer
local data = {}

function vlf_lush_caves.makeazalea(pos, def, pr)
	local distance = {x = 4, y = 40, z = 4}
	local airup = minetest.find_nodes_in_area_under_air(vector.offset(pos, 0, distance.y, 0), pos, {"vlf_core:dirt_with_grass"})
	if #airup == 0 then return end
	local surface_pos = airup[1]

	local function squared_distance(x, z)
		local dx = x - pos.x
		local dz = z - pos.z
		return dx*dx + dz*dz
	end

	local maximum_random_value = squared_average(distance.x, distance.z) + 1

	local min = vector.offset(pos, -distance.x, -1, -distance.z)
	local max = vector.offset(pos, distance.x, distance.y, distance.z)

	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	vm:get_data(data)

	local a = VoxelArea:new({MinEdge = emin, MaxEdge = emax})

	local vi, below
	for z = min.z, max.z do
		for y = min.y + 1, surface_pos.y - 1 do
			for x = min.x, max.x do
				vi = a:index(x, y, z)
				local probability_value = maximum_random_value - squared_distance(x, z)
				if CONVERTS_TO_ROOTED_DIRT[data[vi]] and pr:next(1, maximum_random_value) <= probability_value then
					data[vi] = CONTENT_ROOTED_DIRT
					below = a:index(x, y - 1, z)
					if data[below] == minetest.CONTENT_AIR then
						data[below] = CONTENT_HANGING_ROOTS
					end
				end
			end
		end
	end
	data[a:index(surface_pos.x, surface_pos.y, surface_pos.z)] = CONTENT_ROOTED_DIRT
	vm:set_data(data)
	minetest.place_schematic_on_vmanip(vm,
		vector.offset(surface_pos, -3, 1, -3),
		schempath.."/schems/azalea1.mts",
		"random",nil,nil,
		"place_center_x place_center_z"
	)
	vm:calc_lighting()
	vm:write_to_map()
	minetest.log("info","[vlf_lush_caves] Azalea generated at "..minetest.pos_to_string(surface_pos))
	return true
end

minetest.register_abm({
	label = "Cave vines grow",
	nodenames = {"vlf_lush_caves:cave_vines_lit","vlf_lush_caves:cave_vines"},
	interval = 180,
	chance = 5,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local pd1 = vector.offset(pos,0,-1,0)
		local pd2 = vector.offset(pos,0,-2,0)
		node.name = "vlf_lush_caves:cave_vines"
		if  math.random(5) == 1 then
			node.name="vlf_lush_caves:cave_vines_lit"
		end
		if minetest.get_node(pd1).name == "air" and minetest.get_node(pd2).name == "air" then
			minetest.swap_node(pd1,node)
		else
			minetest.swap_node(pos,{name="vlf_lush_caves:cave_vines_lit"})
		end
	end
})

local lushcaves = { "LushCaves", "LushCaves_underground", "LushCaves_ocean", "LushCaves_deep_ocean"}

vlf_structures.register_structure("clay_pool",{
	place_on = {"group:material_stone","vlf_core:gravel","vlf_lush_caves:moss","vlf_core:clay"},
	spawn_by = {"air"},
	num_spawn_by = 1,
	fill_ratio = 0.01,
	terrain_feature = true,
	flags = "all_floors",
	y_max = -10,
	biomes = lushcaves,
	place_func = vlf_lush_caves.makelake,
})

local azaleas = {}
local az_limit = 500
vlf_structures.register_structure("azalea_tree",{
	place_on = {"group:material_stone","vlf_core:gravel","vlf_lush_caves:moss","vlf_core:clay"},
	spawn_by = {"air"},
	num_spawn_by = 1,
	fill_ratio = 0.15,
	flags = "all_ceilings",
	terrain_feature = true,
	y_max =0,
	y_min = vlf_vars.mg_overworld_min + 15,
	biomes = lushcaves,
	place_func = function(pos,def,pr)
		for _,a in pairs(azaleas) do
			if vector.distance(pos,a) < az_limit then
				return true
			end
		end
		if vlf_lush_caves.makeazalea(pos,def,pr) then
			table.insert(azaleas,pos)
			return true
		end
	end
})
--[[
minetest.set_gen_notify({cave_begin = true})
minetest.set_gen_notify({large_cave_begin = true})

vlf_mapgen_core.register_generator("lush_caves",nil, function(minp, maxp, blockseed)
	local gennotify = minetest.get_mapgen_object("gennotify")
	for _, pos in pairs(gennotify["large_cave_begin"] or {}) do
		--minetest.log("large cave at "..minetest.pos_to_string(pos))
	end
	for _, pos in pairs(gennotify["cave_begin"] or {}) do
		minetest.log("cave at "..minetest.pos_to_string(pos))
	end
end, 99999, true)
--]]

minetest.register_craft({
		type = "fuel",
		recipe = "vlf_lush_caves:azalea",
		burntime = 5,
})

minetest.register_craft({
		type = "fuel",
		recipe = "vlf_lush_caves:azalea_flowering",
		burntime = 5,
})

vlf_flowerpots.register_potted_flower("vlf_lush_caves:azalea", {
	name = "azalea",
	desc = S("Azalea Plant"),
	image = "vlf_lush_caves_azalea_side.png",
})

vlf_flowerpots.register_potted_flower("vlf_lush_caves:azalea_flowering", {
	name = "azalea_flowering",
	desc = S("Flowering Azalea Plant"),
	image = "vlf_lush_caves_azalea_flowering_side.png",
})
