--lua locals
local mob_class = vlf_mobs.mob_class

local modern_lighting = minetest.settings:get_bool("vlf_mobs_modern_lighting", true)
local peaceful_mode = minetest.settings:get_bool("only_peaceful_mobs", false)

local nether_threshold = 11
local end_threshold = 15
local overworld_threshold = 0
local overworld_sky_threshold = 7
local overworld_passive_threshold = 7

local PASSIVE_INTERVAL = 20
local dbg_spawn_attempts = 0
local dbg_spawn_succ = 0
local dbg_spawn_counts = {}
-- range for mob count
local aoc_range = 136
local remove_far = true

local timer_light = 30
local timer_dark = 10
local timer_light_level = 3
local instant_despawn_range = 128
local random_despawn_range = 32

local mob_cap = {
	monster = tonumber(minetest.settings:get("vlf_mob_cap_monster")) or 70,
	animal = tonumber(minetest.settings:get("vlf_mob_cap_animal")) or 10,
	ambient = tonumber(minetest.settings:get("vlf_mob_cap_ambient")) or 15,
	water = tonumber(minetest.settings:get("vlf_mob_cap_water")) or 5,
	water_ambient = tonumber(minetest.settings:get("vlf_mob_cap_water_ambient")) or 20,
	player = tonumber(minetest.settings:get("vlf_mob_cap_player")) or 75,
	total = tonumber(minetest.settings:get("vlf_mob_cap_total")) or 500,
}

--do mobs spawn?
local mobs_spawn = minetest.settings:get_bool("mobs_spawn", true) ~= false
local spawn_protected = minetest.settings:get_bool("mobs_spawn_protected") ~= false
local logging = minetest.settings:get_bool("vlf_logging_mobs_spawn", false)
local mgname = minetest.get_mapgen_setting("mgname")

-- count how many mobs are in an area
local function count_mobs(pos,r,mob_type)
	local num = 0
	for _,l in pairs(minetest.luaentities) do
		if l and l.is_mob and (mob_type == nil or l.type == mob_type) then
			local p = l.object:get_pos()
			if p and vector.distance(p,pos) < r then
				num = num + 1
			end
		end
	end
	return num
end

local function count_mobs_total(mob_type)
	local num = 0
	for _,l in pairs(minetest.luaentities) do
		if l.is_mob then
			if mob_type == nil or l.type == mob_type then
				num = num + 1
			end
		end
	end
	return num
end

local function count_mobs_all()
	local mobs_found = {}
	local num = 0
	for _,entity in pairs(minetest.luaentities) do
		if entity.is_mob then
			local mob_name = entity.name
			if mobs_found[mob_name] then
				mobs_found[mob_name] = mobs_found[mob_name] + 1
			else
				mobs_found[mob_name] = 1
			end
			num = num + 1
		end
	end
	return mobs_found, num
end

local function count_mobs_total_cap(mob_type)
	local num = 0
	for _,l in pairs(minetest.luaentities) do
		if l.is_mob then
			if ( mob_type == nil or l.type == mob_type ) and l.can_despawn and not l.nametag then
				num = num + 1
			end
		end
	end
	return num
end

--this is where all of the spawning information is kept
local spawn_dictionary = {}

local spawn_defaults = {
	dimension = "overworld",
	type_of_spawning = "ground",
	min_light = 7,
	max_light = minetest.LIGHT_MAX + 1,
	chance = 1000,
	aoc = aoc_range,
	min_height = -31000,
	max_height = 31000,
}

local spawn_defaults_meta = { __INDEX = spawn_defaults }

function vlf_mobs.spawn_setup(def)
	if not mobs_spawn then return end

	assert(def, "Empty spawn setup definition from mod: "..tostring(minetest.get_current_modname()))
	assert(def.name, "Missing mob name from from mod: "..tostring(minetest.get_current_modname()))

	local mob_def = minetest.registered_entities[def.name]
	assert(mob_def, "spawn definition with invalid entity: "..tostring(def.name))
	if peaceful_mode and not mob_def.persist_in_peaceful then return end
	assert(def.chance > 0, "Chance shouldn't be less than 1 (mob name: " .. def.name ..")")

	setmetatable(def, spawn_defaults_meta)
	def.min_light        = def.min_light or mob_def.min_light or (mob_def.spawn_class == "hostile" and 0)
	def.max_light        = def.max_light or mob_def.max_light or (mob_def.spawn_class == "hostile" and 7)
	def.min_height       = def.min_height or vlf_vars["mg_"..def.dimension.."_min"]
	def.max_height       = def.max_height or vlf_vars["mg_"..def.dimension.."_max"]

	table.insert(spawn_dictionary, def)
end

function vlf_mobs.get_mob_light_level(mob,dim)
	for _,v in pairs(spawn_dictionary) do
		if v.name == mob and v.dimension == dim then
			return v.min_light,v.max_light
		end
	end
	local def = minetest.registered_entities[mob]
	return def.min_light,def.max_light
end

local function biome_check(biome_list, biome_goal)
	if mgname == "singlenode" then return true end
	return table.indexof(biome_list,biome_goal) ~= -1
end

local function is_farm_animal(n)
	return n == "mobs_mc:pig" or n == "mobs_mc:cow" or n == "mobs_mc:sheep" or n == "mobs_mc:chicken" or n == "mobs_mc:horse" or n == "mobs_mc:donkey"
end

local function get_water_spawn(p)
		local nn = minetest.find_nodes_in_area(vector.offset(p,-2,-1,-2),vector.offset(p,2,-15,2),{"group:water"})
		if nn and #nn > 0 then
			return nn[math.random(#nn)]
		end
end

local function has_room(self,pos)
	local cb = self.initial_properties.collisionbox
	local nodes = {}
	if self.fly_in then
		local t = type(self.fly_in)
		if t == "table" then
			nodes = table.copy(self.fly_in)
		elseif t == "string" then
			table.insert(nodes,self.fly_in)
		end
	end
	if self.swims_in then
		local t = type(self.swims_in)
		if t == "table" then
			nodes = table.copy(self.swims_in)
		elseif t == "string" then
			table.insert(nodes,self.swims_in)
		end
	end
	table.insert(nodes,"air")
	local x = cb[4] - cb[1]
	local y = cb[5] - cb[2]
	local z = cb[6] - cb[3]
	local r = math.ceil(x * y * z)
	local p1 = vector.offset(pos,cb[1],cb[2],cb[3])
	local p2 = vector.offset(pos,cb[4],cb[5],cb[6])
	local n = #minetest.find_nodes_in_area(p1,p2,nodes) or 0
	if r > n then
		minetest.log("info","[vlf_mobs] No room for mob "..self.name.." at "..minetest.pos_to_string(vector.round(pos)))
		return false
	end
	return true
end

local function spawn_check(pos,spawn_def,ignore_caps)
	if not spawn_def or not pos then return end
	dbg_spawn_attempts = dbg_spawn_attempts + 1
	local dimension = vlf_worlds.pos_to_dimension(pos)
	local mob_def = minetest.registered_entities[spawn_def.name]
	local mob_type = mob_def.type
	local gotten_node = minetest.get_node(pos).name
	local gotten_biome = minetest.get_biome_data(pos)
	if not gotten_node or not gotten_biome then return end
	gotten_biome = minetest.get_biome_name(gotten_biome.biome) --makes it easier to work with

	local is_ground = minetest.get_item_group(gotten_node,"solid") ~= 0
	if not is_ground then
		pos.y = pos.y - 1
		gotten_node = minetest.get_node(pos).name
		is_ground = minetest.get_item_group(gotten_node,"solid") ~= 0
	end
	pos.y = pos.y + 1
	local is_water = minetest.get_item_group(gotten_node, "water") ~= 0
	local is_lava  = minetest.get_item_group(gotten_node, "lava") ~= 0
	local is_leaf  = minetest.get_item_group(gotten_node, "leaves") ~= 0
	local is_bedrock  = gotten_node == "vlf_core:bedrock"
	local is_grass = minetest.get_item_group(gotten_node,"grass_block") ~= 0

	local mob_count_wide = 0
	local mob_count = 0
	if not ignore_caps then
		mob_count = count_mobs(pos,32,mob_type)
		mob_count_wide = count_mobs(pos,aoc_range,mob_type)
	end

	if not pos then return false,"no pos" end
	if not spawn_def then return false,"no spawn_def" end
	if ( mob_count_wide >= (mob_cap[mob_type] or 15) ) then return false,"mob cap wide full" end
	if ( mob_count >= 5 ) then return false, "local mob cap full" end
	if not ( spawn_def.min_height and pos.y >= spawn_def.min_height ) then return false, "too low" end
	if not ( spawn_def.max_height and pos.y <= spawn_def.max_height ) then return false, "too high" end
	if spawn_def.dimension ~= dimension then return false, "wrong dimension" end
	if not ( not spawn_def.biomes_except or (spawn_def.biomes_except and not biome_check(spawn_def.biomes_except, gotten_biome))) then return false, "biomes_except failed" end
	if not ( not spawn_def.biomes or (spawn_def.biomes and biome_check(spawn_def.biomes, gotten_biome))) then return false, "biome check failed" end
	if not (is_ground or spawn_def.type_of_spawning ~= "ground") then return false, "not on ground" end
	if not (spawn_def.type_of_spawning ~= "ground" or not is_leaf) then return false, "leaf" end
	if not has_room(mob_def,pos) then return false, "no room" end
	if not (spawn_def.check_position and spawn_def.check_position(pos) or true) then return false, "check_position failed" end
	if not (not is_farm_animal(spawn_def.name) or is_grass) then return false, "farm animals only on grass" end
	if not (spawn_def.type_of_spawning ~= "water" or is_water) then return false, "water mob only on water" end
	if not (spawn_def.type_of_spawning ~= "lava" or is_lava) then return false, "lava mobs only on lava" end
	if not ( not spawn_protected or not minetest.is_protected(pos, "") ) then return false, "spawn protected" end
	if is_bedrock then return false, "no spawn on bedrock" end

	local gotten_light = minetest.get_node_light(pos)
	local my_node = minetest.get_node(pos)
	local sky_light = minetest.get_natural_light(pos)
	local art_light = minetest.get_artificial_light(my_node.param1)
	if modern_lighting then

		if mob_def.check_light then
			return mob_def.check_light(pos, gotten_light, art_light, sky_light)
		elseif mob_type == "monster" then
			if dimension == "nether" then
				if art_light > nether_threshold then
					return false, "too bright"
				end
			elseif dimension == "end" then
				if art_light > end_threshold then
					return false, "too bright"
				end
			elseif dimension == "overworld" then
				if art_light > overworld_threshold or sky_light > overworld_sky_threshold then
					return false, "too bright"
				end
			end
		else
			-- passive threshold is apparently the same in all dimensions ...
			if gotten_light <= overworld_passive_threshold then
				return false, "too dark"
			end
		end
	else
		if gotten_light < spawn_def.min_light then return false,"too dark" end
		if gotten_light > spawn_def.max_light then return false,"too bright" end
	end

	return true, ""
end

function vlf_mobs.spawn(pos,id, staticdata)
	local def = minetest.registered_entities[id] or minetest.registered_entities["mobs_mc:"..id] or minetest.registered_entities["extra_mobs:"..id]
	if not def or (def.can_spawn and not def.can_spawn(pos)) or not def.is_mob then
		return false
	end
	if not dbg_spawn_counts[def.name] then
		dbg_spawn_counts[def.name] = 1
	else
		dbg_spawn_counts[def.name] = dbg_spawn_counts[def.name] + 1
	end
	return minetest.add_entity(pos, def.name, staticdata)
end


local function spawn_group(p,mob,spawn_on,group_max,group_min)
	if not group_min then group_min = 1 end
	local nn= minetest.find_nodes_in_area_under_air(vector.offset(p,-5,-3,-5),vector.offset(p,5,3,5),spawn_on)
	local o
	table.shuffle(nn)
	if not nn or #nn < 1 then
		nn = {}
		table.insert(nn,p)
	end
	for _ = 1, math.random(group_min,group_max) do
		local sp = vector.offset(nn[math.random(#nn)],0,1,0)
		if spawn_check(nn[math.random(#nn)],mob,true) then
			if mob.type_of_spawning == "water" then
				sp = get_water_spawn(sp)
			end
			o =  vlf_mobs.spawn(sp,mob.name)
			if o then dbg_spawn_succ = dbg_spawn_succ + 1 end
		end
	end
	return o
end

function mob_class:despawn_allowed()
	local nametag = self.nametag and self.nametag ~= ""
	local not_busy = self.state ~= "attack" and self.following == nil
	if self.can_despawn == true then
		if not nametag and not_busy and not self.tamed and not self.persistent then
			return true
		end
	end
	return false
end

vlf_mobs.spawn_group = spawn_group

local S = minetest.get_translator("vlf_mobs")

--extra checks for mob spawning
local function can_spawn(spawn_def,spawning_position)
	if spawn_def.type_of_spawning == "water" then
		spawning_position = get_water_spawn(spawning_position)
		if not spawning_position then
			minetest.log("warning","[vlf_mobs] no water spawn for mob "..spawn_def.name.." found at "..minetest.pos_to_string(vector.round(spawning_position)))
			return
		end
	end
	if minetest.registered_entities[spawn_def.name].can_spawn and not minetest.registered_entities[spawn_def.name].can_spawn(spawning_position) then
		minetest.log("warning","[vlf_mobs] mob "..spawn_def.name.." refused to spawn at "..minetest.pos_to_string(vector.round(spawning_position)))
		return false
	end
	return true
end

local passive_timer = PASSIVE_INTERVAL

--timer function to check if passive mobs should spawn (only every 20 secs unlike other mob spawn classes)
local function check_timer(spawn_def)
	local mob_def = minetest.registered_entities[spawn_def.name]
	if mob_def and mob_def.spawn_class == "passive" then
		if passive_timer > 0 then
			return false
		else
			passive_timer = PASSIVE_INTERVAL
		end
	end
	return true
end

local MOB_SPAWN_ZONE_INNER = 24
local MOB_SPAWN_ZONE_OUTER = 128


local SPAWN_MAPGEN_LIMIT  = 30911
local SPAWN_DISTANCE_CDF_PWL = {
	{0.000,0.00},
	{0.083,0.40},
	{0.416,0.75},
	{1.000,1.00},
}
-- Calculate the inverse of a piecewise linear function f(x). Line segments are represented as two
-- adjacent points specified as { x, f(x) }. At least 2 points are required. If there are most solutions,
-- the one with a lower x value will be chosen.
local function inverse_pwl(fx, f)
	if fx < f[1][2] then
		return f[1][1]
	end
	for i=2,#f do
		local x0,fx0 = unpack(f[i-1])
		local x1,fx1 = unpack(f[i  ])
		if fx < fx1 then
			return (fx - fx0) * (x1 - x0) / (fx1 - fx0) + x0
		end
	end
	return f[#f][1]
end


local two_pi = 2 * math.pi
local function math_round(x) return (x > 0) and math.floor(x + 0.5) or math.ceil(x - 0.5) end

local function get_next_mob_spawn_pos(pos)
	-- Select a distance such that distances closer to the player are selected much more often than
	-- those further away from the player.
	local fx = (math.random(1,10000)-1) / 10000
	local x = inverse_pwl(fx, SPAWN_DISTANCE_CDF_PWL)
	local distance = x * (MOB_SPAWN_ZONE_OUTER - MOB_SPAWN_ZONE_INNER) + MOB_SPAWN_ZONE_INNER
	--print("Using spawn distance of "..tostring(distance).."  fx="..tostring(fx)..",x="..tostring(x))

	-- TODO Floor xoff and zoff and add 0.5 so it tries to spawn in the middle of the square. Less failed attempts.
	-- Use spherical coordinates https://en.wikipedia.org/wiki/Spherical_coordinate_system#Cartesian_coordinates
	local theta = math.random() * two_pi
	local phi = math.random() * two_pi
	local xoff = math_round(distance * math.sin(theta) * math.cos(phi))
	local yoff = math_round(distance * math.cos(theta))
	local zoff = math_round(distance * math.sin(theta) * math.sin(phi))
	local goal_pos = vector.offset(pos, xoff, yoff, zoff)

	if not ( math.abs(goal_pos.x) <= SPAWN_MAPGEN_LIMIT and math.abs(pos.y) <= SPAWN_MAPGEN_LIMIT and math.abs(goal_pos.z) <= SPAWN_MAPGEN_LIMIT ) then
		return nil
	end

	-- Calculate upper/lower y limits
	local R1 = MOB_SPAWN_ZONE_OUTER
	local d = vector.distance( pos, vector.new( goal_pos.x, pos.y, goal_pos.z ) ) -- distance from player to projected point on horizontal plane
	local y1 = math.sqrt( R1*R1 - d*d ) -- absolue value of distance to outer sphere

	local y_min
	local y_max
	if d >= MOB_SPAWN_ZONE_INNER then
		-- Outer region, y range has both ends on the outer sphere
		y_min = pos.y - y1
		y_max = pos.y + y1
	else
		-- Inner region, y range spans between inner and outer spheres
		local R2 = MOB_SPAWN_ZONE_INNER
		local y2 = math.sqrt( R2*R2 - d*d )
		if goal_pos.y > pos. y then
			-- Upper hemisphere
			y_min = pos.y + y2
			y_max = pos.y + y1
		else
			-- Lower hemisphere
			y_min = pos.y - y1
			y_max = pos.y - y2
		end
	end
	y_min = math_round(y_min)
	y_max = math_round(y_max)

	local spawning_position_list = minetest.find_nodes_in_area_under_air(
			{x = goal_pos.x, y = y_min, z = goal_pos.z},
			{x = goal_pos.x, y = y_max, z = goal_pos.z},
			{"group:solid", "group:water", "group:lava"}
	) or {}

	-- Select only the locations at a valid distance
	local valid_positions = {}
	for _,check_pos in ipairs(spawning_position_list) do
		local dist = vector.distance(pos, check_pos)
		if dist >= MOB_SPAWN_ZONE_INNER and dist <= MOB_SPAWN_ZONE_OUTER then
			table.insert(valid_positions, check_pos)
		end
	end

	if #valid_positions == 0 then return end
	return valid_positions[math.random(#valid_positions)]

end


if mobs_spawn then
	local cumulative_chance
	local mob_library_worker_table
	local function initialize_spawn_data()
		if not mob_library_worker_table then
			mob_library_worker_table = table.copy(spawn_dictionary)
		end
		if not cumulative_chance then
			cumulative_chance = 0
			for _, v in pairs(mob_library_worker_table) do
				cumulative_chance = cumulative_chance + v.chance
			end
		end
	end

	local function spawn_a_mob(pos, _, _)
		--create a disconnected clone of the spawn dictionary
		--prevents memory leak

		local mob_library_worker_table = table.copy(spawn_dictionary)
		local spawning_position = get_next_mob_spawn_pos(pos)

		local spawn_loop_counter = #mob_library_worker_table
		--use random weighted choice with replacement to grab a mob, don't exclude any possibilities
		--shuffle table once every loop to provide equal inclusion probability to all mobs
		--repeat grabbing a mob to maintain existing spawn rates
		while spawn_loop_counter > 0 do
			table.shuffle(mob_library_worker_table)
			local mob_chance_offset = math.random(1, cumulative_chance)
			local mob_index = 1
			local mob_chance = mob_library_worker_table[mob_index].chance
			local step_chance = mob_chance
			while step_chance < mob_chance_offset do
				mob_index = mob_index + 1
				if mob_index <= #mob_library_worker_table then
					mob_chance = mob_library_worker_table[mob_index].chance
					step_chance = step_chance + mob_chance
				else
					break
				end
				mob_chance = mob_library_worker_table[mob_index].chance
				step_chance = step_chance + mob_chance
			end
			local spawn_def = mob_library_worker_table[mob_index]
			--minetest.log(spawn_def.name.." "..step_chance.. " "..mob_chance)
			if spawn_def and spawn_def.name and minetest.registered_entities[spawn_def.name] then
				local spawn_in_group = minetest.registered_entities[spawn_def.name].spawn_in_group or 4
				local spawn_in_group_min = minetest.registered_entities[spawn_def.name].spawn_in_group_min or 1
				local mob_type = minetest.registered_entities[spawn_def.name].type
				if spawn_check(spawning_position,spawn_def) then

					if can_spawn(spawn_def,spawning_position) and check_timer(spawn_def) then
						--everything is correct, spawn mob
						if spawn_in_group and ( mob_type ~= "monster" or math.random(5) == 1 ) then
							if logging then
								minetest.log("action", "[vlf_mobs] A group of mob " .. spawn_def.name .. " spawns on " ..minetest.get_node(vector.offset(spawning_position,0,-1,0)).name .." at " .. minetest.pos_to_string(spawning_position, 1))
							end
							spawn_group(spawning_position,spawn_def,{minetest.get_node(vector.offset(spawning_position,0,-1,0)).name},spawn_in_group,spawn_in_group_min)

						else
							if logging then
								minetest.log("action", "[vlf_mobs] Mob " .. spawn_def.name .. " spawns on " ..minetest.get_node(vector.offset(spawning_position,0,-1,0)).name .." at ".. minetest.pos_to_string(spawning_position, 1))
							end
							vlf_mobs.spawn(spawning_position, spawn_def.name)
						end
					end
				end
			end
			spawn_loop_counter = spawn_loop_counter - 1
		end
	end


	--MAIN LOOP

	local timer = 0
	minetest.register_globalstep(function(dtime)
		passive_timer = passive_timer - dtime
		timer = timer + dtime
		if timer < 10 then return end
		timer = 0
		local players = minetest.get_connected_players()
		local total_mobs = count_mobs_total_cap()
		if total_mobs > mob_cap.total or total_mobs > #players * mob_cap.player then
			minetest.log("action","[vlf_mobs] global mob cap reached. no cycle spawning.")
			return
		end --mob cap per player

		initialize_spawn_data()
		for _, player in pairs(players) do
			local pos = player:get_pos()
			local dimension = vlf_worlds.pos_to_dimension(pos)
			-- ignore void and unloaded area
			if dimension ~= "void" and dimension ~= "default" then
				spawn_a_mob(pos, dimension, dtime)
			end
		end
	end)
end

function mob_class:check_despawn(pos, dtime)
	if remove_far and self:despawn_allowed() then
		local min_dist = 10000

		for _, player in pairs(minetest.get_connected_players()) do
			local dist = vector.distance(player:get_pos(), pos)
			min_dist = math.min(min_dist, dist)
		end

		if min_dist > instant_despawn_range then
			self:kill_me("no players within " .. instant_despawn_range)
			return true
		elseif min_dist > random_despawn_range then
			if self.lifetimer then
				self.lifetimer = self.lifetimer - dtime
			else
				if minetest.get_node_light(pos) < timer_light_level then
					self.lifetimer = timer_dark
				else
					self.lifetimer = timer_light
				end
			end

			if self.lifetimer <= 0 and math.random(1, 100) < 4 then
				self:kill_me("player distance timeout and random chance")
				return true
			end
		else
			self.lifetimer = nil
		end
	end
end

function mob_class:kill_me(msg)
	if logging then
		minetest.log("action", "[vlf_mobs] Mob " .. self.name .. " despawns because " .. msg)
	end

	self:safe_remove()
end

minetest.register_chatcommand("spawn_mob",{
	privs = { debug = true },
	description=S("spawn_mob is a chatcommand that allows you to type in the name of a mob without 'typing mobs_mc:' all the time like so; 'spawn_mob spider'. however, there is more you can do with this special command, currently you can edit any number, boolean, and string variable you choose with this format: spawn_mob 'any_mob:var<mobs_variable=variable_value>:'. any_mob being your mob of choice, mobs_variable being the variable, and variable value being the value of the chosen variable. and example of this format: \n spawn_mob skeleton:var<passive=true>:\n this would spawn a skeleton that wouldn't attack you. REMEMBER-THIS> when changing a number value always prefix it with 'NUM', example: \n spawn_mob skeleton:var<jump_height=NUM10>:\n this setting the skelly's jump height to 10. if you want to make multiple changes to a mob, you can, example: \n spawn_mob skeleton:var<passive=true>::var<jump_height=NUM10>::var<fly_in=air>::var<fly=true>:\n etc."),
	func = function(n,param)
		local pos = minetest.get_player_by_name(n):get_pos()

		local modifiers = {}
		for capture in string.gmatch(param, "%:(.-)%:") do
			table.insert(modifiers, ":"..capture)
		end

		local mod1 = string.find(param, ":")



		local mobname = param
		if mod1 then
			mobname = string.sub(param, 1, mod1-1)
		end

		local mob = vlf_mobs.spawn(pos, mobname, minetest.serialize({ persist_in_peaceful = true }))

		if mob then
			for c=1, #modifiers do
				local modifs = modifiers[c]

				local mod1 = string.find(modifs, ":")
				local mod_start = string.find(modifs, "<")
				local mod_vals = string.find(modifs, "=")
				local mod_end = string.find(modifs, ">")
				local mob_entity = mob:get_luaentity()
				if string.sub(modifs, mod1+1, mod1+3) == "var" then
					if mod1 and mod_start and mod_vals and mod_end then
						local variable = string.sub(modifs, mod_start+1, mod_vals-1)
						local value = string.sub(modifs, mod_vals+1, mod_end-1)

						local number_tag = string.find(value, "NUM")
						if number_tag then
							value = tonumber(string.sub(value, 4, -1)) ---@diagnostic disable-line: cast-local-type
						end

						if value == "true" then
							value = true ---@diagnostic disable-line: cast-local-type
						elseif value == "false" then
							value = false ---@diagnostic disable-line: cast-local-type
						end

						if not mob_entity[variable] then
							minetest.log("warning", n.." mob variable "..variable.." previously unset")
						end

						mob_entity[variable] = value

					else
						minetest.log("warning", n.." couldn't modify "..mobname.." at "..minetest.pos_to_string(pos).. ", missing paramaters")
					end
				else
					minetest.log("warning", n.." couldn't modify "..mobname.." at "..minetest.pos_to_string(pos).. ", missing modification type")
				end
			end

			minetest.log("action", n.." spawned "..mobname.." at "..minetest.pos_to_string(pos))
			return true, mobname.." spawned at "..minetest.pos_to_string(pos)
		else
			return false, "Couldn't spawn "..mobname
		end
	end
})
minetest.register_chatcommand("spawncheck",{
	privs = { debug = true },
	func = function(n,param)
		local pl = minetest.get_player_by_name(n)
		local pos = vector.offset(pl:get_pos(),0,-1,0)
		local dim = vlf_worlds.pos_to_dimension(pos)
		local sp
		for _,v in pairs(spawn_dictionary) do
			if v.name == param and v.dimension == dim then sp = v end
		end
		if sp then
			minetest.log(dump(sp))
			local r,t = spawn_check(pos,sp)
			if r then
				return true, "spawn check for "..sp.name.." at "..minetest.pos_to_string(pos).." successful"
			else
				return r,tostring(t) or ""
			end
		else
			return false,"no spawndef found for "..param
		end
	end
})

minetest.register_chatcommand("mobstats",{
	privs = { debug = true },
	func = function(n, _)
		minetest.chat_send_player(n,dump(dbg_spawn_counts))
		local pos = minetest.get_player_by_name(n):get_pos()
		minetest.chat_send_player(n,"mobs within 32 radius of player:"..count_mobs(pos,32))
		minetest.chat_send_player(n,"total mobs:"..count_mobs_total())
		minetest.chat_send_player(n,"spawning attempts since server start:"..dbg_spawn_attempts)
		minetest.chat_send_player(n,"successful spawns since server start:"..dbg_spawn_succ)


		local mob_counts, total_mobs = count_mobs_all()
		if (total_mobs) then
			minetest.log("action", "Total mobs found: " .. total_mobs)
		end
		if mob_counts then
			for k, v1 in pairs(mob_counts) do
				minetest.log("action", "k: " .. tostring(k))
				minetest.log("action", "v1: " .. tostring(v1))
			end
		end

	end
})
