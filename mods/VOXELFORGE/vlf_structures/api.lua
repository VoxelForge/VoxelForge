vlf_structures.registered_structures = {}
local disabled_structures = minetest.settings:get("mcl_disabled_structures")
if disabled_structures then	disabled_structures = disabled_structures:split(",")
else disabled_structures = {} end

local peaceful = minetest.settings:get_bool("only_peaceful_mobs", false)
local mob_cap_player = tonumber(minetest.settings:get("mcl_mob_cap_player")) or 75
local mob_cap_animal = tonumber(minetest.settings:get("mcl_mob_cap_animal")) or 10
local mobs_spawn = minetest.settings:get_bool("mobs_spawn", true) ~= false

local logging = minetest.settings:get_bool("mcl_logging_structures",true)
vlf_structures.DBG = false

local rotations = {
	"0",
	"90",
	"180",
	"270"
}

local EMPTY_SCHEMATIC = { size = {x = 0, y = 0, z = 0}, data = { } }

function vlf_structures.is_disabled(structname)
	return table.indexof(disabled_structures,structname) ~= -1
end

function vlf_structures.place_schematic(pos, schematic, rotation, replacements, def, force_placement, flags, after_placement_callback, pr, callback_param)
	--if type(schematic) ~= "table" and not mcl_util.file_exists(schematic) then
		--minetest.log("warning","[mcl_structures] schematic file "..tostring(schematic).." does not exist.")
		--return end
	local s = vlf_structure_block.load_vlfschem(schematic, false)
	if s and s.size then
		local x, z = s.size.x, s.size.z
		if rotation then
			if rotation == "random" and pr then
				rotation = rotations[pr:next(1,#rotations)]
			end
			if rotation == "random" then
				x = math.max(x, z)
				z = x
			elseif rotation == "90" or rotation == "270" then
				x, z = z, x
			end
		end
		local p1 = {x=pos.x    , y=pos.y           , z=pos.z    }
		local p2 = {x=pos.x+x-1, y=pos.y+s.size.y-1, z=pos.z+z-1}
		minetest.log("verbose", "[mcl_structures] size=" ..minetest.pos_to_string(s.size) .. ", rotation=" .. tostring(rotation) .. ", emerge from "..minetest.pos_to_string(p1) .. " to " .. minetest.pos_to_string(p2))
		vlf_structure_block.place_schematic(pos, schematic, 0, pos, "true", def.wom or "false", def.include_entities or true, def.terrain_setting or "rigid", def.processor or nil)
		return true
	end
end

function vlf_structures.find_lowest_y(pp)
	local y = 31000
	for _,p in pairs(pp) do
		if p.y < y then y = p.y end
	end
	return y
end

function vlf_structures.find_highest_y(pp)
	local y = -31000
	for _,p in pairs(pp) do
		if p.y > y then y = p.y end
	end
	return y
end

function vlf_structures.spawn_mobs(mob, spawnon, p1 ,p2 ,_ ,n , water)
	n = n or 1
	local sp = {}
	if water then
		local nn = minetest.find_nodes_in_area(p1,p2,spawnon)
		for _, v in pairs(nn) do
			if minetest.get_item_group(minetest.get_node(vector.offset(v,0,1,0)).name,"water") > 0 then
				table.insert(sp,v)
			end
		end
	else
		sp = minetest.find_nodes_in_area_under_air(p1,p2,spawnon)
	end
	table.shuffle(sp)
	for i,node in pairs(sp) do
		if not peaceful and i <= n then
			local pos = vector.offset(node,0,1,0)
			if pos then
				minetest.add_entity(vector.offset(pos,0,-0.5,0),mob)
			end
		end
		minetest.get_meta(node):set_string("spawnblock","yes")
	end
end

function vlf_structures.place_structure(pos, def, pr, blockseed, _)
	if not def then	return end
	local log_enabled = logging and not def.terrain_feature
	local y_offset = 0
	if type(def.y_offset) == "function" then
		y_offset = def.y_offset(pr)
	elseif def.y_offset then
		y_offset = def.y_offset
	end
	local pp = vector.offset(pos,0,y_offset,0)
	if def.solid_ground and def.sidelen then
		local ground_p1 = vector.offset(pos,-def.sidelen/2,-1,-def.sidelen/2)
		local ground_p2 = vector.offset(pos,def.sidelen/2,-1,def.sidelen/2)

		local solid = minetest.find_nodes_in_area(ground_p1,ground_p2,{"group:solid"})
		if #solid < ( def.sidelen * def.sidelen ) then
			if def.make_foundation then
				mcl_util.create_ground_turnip(vector.offset(pos, 0, -1, 0), def.sidelen, def.sidelen)
			else
				if log_enabled then
					minetest.log("warning","[mcl_structures] "..def.name.." at "..minetest.pos_to_string(pp).." not placed. No solid ground.")
				end
				return false
			end
		end
	end
	if def.on_place and not def.on_place(pos,def,pr,blockseed) then
		if log_enabled then
			minetest.log("warning","[mcl_structures] "..def.name.." at "..minetest.pos_to_string(pp).." not placed. Conditions not satisfied.")
		end
		return false
	end
	if def.filenames then
		if #def.filenames <= 0 then return false end
		local r = pr:next(1,#def.filenames)
		local file = def.filenames[r]
		if file then
			local rot = rotations[pr:next(1,#rotations)]

			if def.daughters then
				for _,d in pairs(def.daughters) do
					local p = vector.add(pos,d.pos)
					local rot = d.rot or 0
					vlf_structures.place_schematic(p, d.files[pr:next(1,#d.files)], rot, nil, true, "place_center_x,place_center_z",function()
						if def.after_place then
							def.after_place(pos,def,pr)
						end
					end,pr)
				end
			end
			vlf_structures.place_schematic(pp, file, rot,  def.replacements, def, true, "place_center_x,place_center_z", ---@diagnostic disable-line: unused-local
			pr)
			if log_enabled then
				minetest.log("error","[mcl_structures] "..def.name.." placed at "..minetest.pos_to_string(pp))
			end
			return true
		end
	elseif def.place_func and def.place_func(pp,def,pr,blockseed) then
		if not def.after_place or ( def.after_place  and def.after_place(pp,def,pr,blockseed) ) then
			if log_enabled then
				minetest.log("error","[mcl_structures] "..def.name.." placed at "..minetest.pos_to_string(pp))
			end
			return true
		end
	end
	if log_enabled then
		minetest.log("warning","[mcl_structures] placing "..def.name.." failed at "..minetest.pos_to_string(pos))
	end
end

function vlf_structures.register_structure(name,def,nospawn) --nospawn means it will be placed by another (non-nospawn) structure that contains it's structblock i.e. it will not be placed by mapgen directly
	if vlf_structures.is_disabled(name) then return end
	local flags = "place_center_x, place_center_z, force_placement"
	if def.flags then flags = def.flags end
	def.name = name
	if not def.noise_params and def.chunk_probability then
		def.fill_ratio = def.fill_ratio or 1.1/80/80 -- aim for 1 per chunk, control via chunk probability
	end
	if not nospawn and def.place_on then
		minetest.register_on_mods_loaded(function() --make sure all previous decorations and biomes have been registered
			def.deco = minetest.register_decoration({
				name = "vlf_structures:"..name,
				deco_type = "schematic",
				schematic = EMPTY_SCHEMATIC,
				place_on = def.place_on,
				spawn_by = def.spawn_by,
				num_spawn_by = def.num_spawn_by,
				sidelen = 80,
				fill_ratio = def.fill_ratio,
				noise_params = def.noise_params,
				flags = flags,
				biomes = def.biomes,
				y_max = def.y_max,
				y_min = def.y_min
			})
			def.deco_id = minetest.get_decoration_id("vlf_structures:"..name)
			minetest.set_gen_notify({decoration=true}, { def.deco_id })
			--catching of gennotify happens in mcl_mapgen_core
		end)
	end
	vlf_structures.registered_structures[name] = def
end

function vlf_structures.register_structure_spawn(def)
	--name,y_min,y_max,spawnon,biomes,chance,interval,limit,underwater
	minetest.register_abm({
		label = "Spawn "..def.name,
		nodenames = def.spawnon,
		min_y = def.y_min or -31000,
		max_y = def.y_max or 31000,
		interval = def.interval or 60,
		chance = def.chance or 5,
		action = function(pos, _, _, active_object_count_wider)
			local limit = def.limit or 7
			if active_object_count_wider > limit + mob_cap_animal then return end
			if active_object_count_wider > mob_cap_player then return end
			if not mobs_spawn then
				return
			end
			local p = vector.offset(pos,0,1,0)
			if not def.underwater and minetest.get_node(p).name ~= "air" then return end
			if minetest.get_meta(pos):get_string("spawnblock") == "" then return end
			if def.biomes then
				if table.indexof(def.biomes,minetest.get_biome_name(minetest.get_biome_data(p).biome)) == -1 then
					return
				end
			end
			local mobdef = minetest.registered_entities[def.name]
			if mobdef.can_spawn and not mobdef.can_spawn(p) then return end
			local staticdata = minetest.serialize ({
				_structure_spawn = 1,
			})
			minetest.add_entity (vector.offset(p,0,-0.5,0), def.name, staticdata)
		end,
	})
end
