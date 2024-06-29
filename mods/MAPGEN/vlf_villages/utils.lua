
local terrace_max_ext = 6

-------------------------------------------------------------------------------
-- function to copy tables
-------------------------------------------------------------------------------
function vlf_villages.shallowCopy(original)
	local copy = {}
	for key, value in pairs(original) do
		copy[key] = value
	end
	return copy
end
--
--
--
function vlf_villages.round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

-------------------------------------------------------------------------------
-- function to find surface block y coordinate
-- returns surface postion
-------------------------------------------------------------------------------
function vlf_villages.find_surface(pos, wait, quick)
	local p6 = vector.new(pos)
	local cnt = 0
	local itter = 1 -- look up
	local cnt_max = 200
	local wait_time = 10000000

	if quick then
		cnt_max = 20
		wait_time = 2000000
	end

	-- check, in which direction to look for surface
	local surface_node
	if wait then
		surface_node = vlf_vars.get_node(p6, true, wait_time)
	else
		surface_node = vlf_vars.get_node(p6)
	end

	if
		surface_node.name == "air"
		or surface_node.name == "ignore"
		or surface_node.name == "vlf_core:snow"
		or (minetest.get_item_group(surface_node.name, "deco_block") > 0)
		or (minetest.get_item_group(surface_node.name, "plant") > 0)
		or (minetest.get_item_group(surface_node.name, "tree") > 0)
	then
		itter = -1 -- look down
	end

	-- go through nodes an find surface
	while cnt < cnt_max do
		-- Check Surface_node and Node above
		--
		if vlf_villages.surface_mat[surface_node.name] then
			local surface_node_plus_1 = vlf_vars.get_node(vector.offset(p6, 0, 1, 0))
			if surface_node_plus_1 and surface_node and
				(string.find(surface_node_plus_1.name,"air") or
				string.find(surface_node_plus_1.name,"snow") or
				string.find(surface_node_plus_1.name,"fern") or
				string.find(surface_node_plus_1.name,"flower") or
				string.find(surface_node_plus_1.name,"bush") or
				string.find(surface_node_plus_1.name,"tree") or
				string.find(surface_node_plus_1.name,"grass"))
				then
					vlf_villages.debug("find_surface7: " ..surface_node.name.. " " .. surface_node_plus_1.name)
					return p6, surface_node.name
			else
				vlf_villages.debug("find_surface2: wrong layer above " .. surface_node_plus_1.name)
			end
		else
			vlf_villages.debug("find_surface3: wrong surface "..surface_node.name.." at pos "..minetest.pos_to_string(p6))
		end

		p6.y = p6.y + itter
		if p6.y < 0 then
			vlf_villages.debug("find_surface4: y<0")
			return nil
		end
		cnt = cnt+1
		surface_node = vlf_vars.get_node(p6)
	end
	vlf_villages.debug("find_surface5: cnt_max overflow")
	return nil
end
-------------------------------------------------------------------------------
-- check distance for new building
-------------------------------------------------------------------------------
function vlf_villages.check_distance(settlement_info, building_pos, building_size)
	local distance
	for i, built_house in ipairs(settlement_info) do
		distance = math.sqrt(
			((building_pos.x - built_house["pos"].x)*(building_pos.x - built_house["pos"].x))+
			((building_pos.z - built_house["pos"].z)*(building_pos.z - built_house["pos"].z)))
		if distance < building_size or distance < built_house["hsize"] then
			return false
		end
	end
	return true
end
-------------------------------------------------------------------------------
-- fill chests
-------------------------------------------------------------------------------
function vlf_villages.fill_chest(pos, pr)
	-- initialize chest (mts chests don't have meta)
	local meta = minetest.get_meta(pos)
	if meta:get_string("infotext") ~= "Chest" then
		-- For MineClone2 0.70 or before
		-- minetest.registered_nodes["vlf_chests:chest"].on_construct(pos)
		--
		-- For MineClone2 after commit 09ab1482b5 (the new entity chests)
		minetest.registered_nodes["vlf_chests:chest_small"].on_construct(pos)
	end
	-- fill chest
	local inv = minetest.get_inventory( {type="node", pos=pos} )

	local function get_treasures(prand)
		local loottable = {{
			stacks_min = 3,
			stacks_max = 8,
			items = {
				{ itemstring = "vlf_core:diamond", weight = 3, amount_min = 1, amount_max = 3 },
				{ itemstring = "vlf_core:iron_ingot", weight = 10, amount_min = 1, amount_max = 5 },
				{ itemstring = "vlf_core:gold_ingot", weight = 5, amount_min = 1, amount_max = 3 },
				{ itemstring = "vlf_farming:bread", weight = 15, amount_min = 1, amount_max = 3 },
				{ itemstring = "vlf_core:apple", weight = 15, amount_min = 1, amount_max = 3 },
				{ itemstring = "vlf_tools:pick_iron", weight = 5 },
				{ itemstring = "vlf_tools:sword_iron", weight = 5 },
				{ itemstring = "vlf_armor:chestplate_iron", weight = 5 },
				{ itemstring = "vlf_armor:helmet_iron", weight = 5 },
				{ itemstring = "vlf_armor:leggings_iron", weight = 5 },
				{ itemstring = "vlf_armor:boots_iron", weight = 5 },
				{ itemstring = "vlf_core:obsidian", weight = 5, amount_min = 3, amount_max = 7 },
				{ itemstring = "vlf_core:sapling", weight = 5, amount_min = 3, amount_max = 7 },
				{ itemstring = "vlf_mobitems:saddle", weight = 3 },
				{ itemstring = "vlf_mobitems:iron_horse_armor", weight = 1 },
				{ itemstring = "vlf_mobitems:gold_horse_armor", weight = 1 },
				{ itemstring = "vlf_mobitems:diamond_horse_armor", weight = 1 },
			}
		}}
		local items = vlf_loot.get_multi_loot(loottable, prand)
		return items
	end

	local items = get_treasures(pr)
	vlf_loot.fill_inventory(inv, "main", items, pr)
end

-------------------------------------------------------------------------------
-- initialize furnace
-------------------------------------------------------------------------------
function vlf_villages.initialize_furnace(pos)
	-- find chests within radius
	local furnacepos = minetest.find_node_near(pos,
		7, --radius
		{"vlf_furnaces:furnace"})
	-- initialize furnacepos (mts furnacepos don't have meta)
	if furnacepos
	then
		local meta = minetest.get_meta(furnacepos)
		if meta:get_string("infotext") ~= "furnace"
		then
			minetest.registered_nodes["vlf_furnaces:furnace"].on_construct(furnacepos)
		end
	end
end
-------------------------------------------------------------------------------
-- initialize anvil
-------------------------------------------------------------------------------
function vlf_villages.initialize_anvil(pos)
	-- find chests within radius
	local anvilpos = minetest.find_node_near(pos,
		7, --radius
		{"vlf_anvils:anvil"})
	-- initialize anvilpos (mts anvilpos don't have meta)
	if anvilpos
	then
		local meta = minetest.get_meta(anvilpos)
		if meta:get_string("infotext") ~= "anvil"
		then
			minetest.registered_nodes["vlf_anvils:anvil"].on_construct(anvilpos)
		end
	end
end
-------------------------------------------------------------------------------
-- randomize table
-------------------------------------------------------------------------------
function vlf_villages.shuffle(tbl, pr)
	local table = vlf_villages.shallowCopy(tbl)
	local size = #table
	for i = size, 1, -1 do
		local rand = pr:next(1, size)
		table[i], table[rand] = table[rand], table[i]
	end
	return table
end

-------------------------------------------------------------------------------
-- Set array to list
-- https://stackoverflow.com/questions/656199/search-for-an-item-in-a-lua-list
-------------------------------------------------------------------------------
function vlf_villages.Set (list)
	local set = {}
	for _, l in ipairs(list) do set[l] = true end
	return set
end

-- Function to check if placing a schema at a position would overlap already placed
-- buildings. Basically it checks if two circles overlap.
-- Returns if it is OK and the minimal distance required to stop them overlapping if false.
function vlf_villages.check_radius_distance(settlement_info, building_pos, schem)

	-- terrace_max_ext is to try an avoid the terracing of the overground from
	-- removing the ground under another building.

	local r1 = ((math.max(schem["size"]["x"], schem["size"]["z"])) / 2) + terrace_max_ext

	for i, built_house in ipairs(settlement_info) do
		local r2 = ((math.max(built_house["size"]["x"], built_house["size"]["z"])) / 2) + terrace_max_ext
		local distance = vector.distance(building_pos, built_house["pos"])

		if distance < r1 + r2 then
			return false, r1 + r2 - distance + 1
		end
	end
	return true, 0
end

function plant_fields(pos, biome_name, schem_lua, pr)
	local modified_schem_lua = schem_lua

	local map_name = vlf_villages.biome_map[biome_name] or "plains"

	for _, crop in ipairs(vlf_villages.get_crop_types()) do
		if string.find(modified_schem_lua, "vlf_villages:crop_" .. crop) then
			for count = 1, 8 do
				local name = "vlf_villages:crop_" .. crop .. "_" .. count
				local replacement = vlf_villages.get_weighted_crop(map_name, crop, pr)
				if replacement == nil or replacement == "" then
					replacement = vlf_villages.default_crop()
				end
				modified_schem_lua = modified_schem_lua:gsub(name, replacement)
			end
		end
	end

	return modified_schem_lua
end

-- Load a schema and replace nodes in it based on biome
function vlf_villages.substitue_materials(pos, schem_lua, pr)
	local modified_schem_lua = schem_lua
	local biome_data = minetest.get_biome_data(pos)
	local biome_name = minetest.get_biome_name(biome_data.biome)

	if vlf_villages.biome_map[biome_name] and vlf_villages.material_substitions[vlf_villages.biome_map[biome_name]] then
		for _, sub in pairs(vlf_villages.material_substitions[vlf_villages.biome_map[biome_name]]) do
			modified_schem_lua = modified_schem_lua:gsub(sub[1], sub[2])
		end
	end

	if string.find(modified_schem_lua, "vlf_villages:crop_") then
		modified_schem_lua = plant_fields(pos, biome_name, modified_schem_lua, pr)
	end

	return modified_schem_lua
end

local villages = {}
local mod_storage = minetest.get_mod_storage()

local function lazy_load_village(name)
	if not villages[name] then
		local data = mod_storage:get("vlf_villages." .. name)
		if data then
			villages[name] = minetest.deserialize(data)
		end
	end
end

function vlf_villages.get_village(name)
	lazy_load_village(name)

	if villages[name] then
		return table.copy(villages[name])
	end
end

function vlf_villages.village_exists(name)
	lazy_load_village(name)

	if villages[name] then
		return true
	end

	return false
end

function vlf_villages.add_village(name, data)
	lazy_load_village(name)

	if villages[name] then
		minetest.log("info","Village already exists: " .. name )
		return false
	end

	local new_village = {name = name, data = data}
	mod_storage:set_string("vlf_villages." .. name, minetest.serialize(new_village))

	return true
end
