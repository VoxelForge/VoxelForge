local modpath = minetest.get_modpath("vlf_data")
local binser = dofile(modpath .. "/binser.lua")
local Randomizer = dofile(minetest.get_modpath("vlf_lib").."/init.lua")

vlf_data = {}

minetest.register_alias("vlf_trial_chambers:temp_glass", "voxelforge:temp_glass")
minetest.register_alias("vlf_trial_chambers:jigsaw_block", "voxelforge:jigsaw")
minetest.register_alias("vlf_copper:waxed_oxidized_cut_copper_stairs", "vlf_stairs:stair_waxed_copper_oxidized_cut")
minetest.register_alias("minecraft:air", "air")
minetest.register_alias("minecraft:tuff_bricks", "vlf_deepslate:tuff_bricks")
minetest.register_alias("minecraft:waxed_oxidized_copper", "vlf_copper:waxed_oxidized_copper")
minetest.register_alias("minecraft:waxed_oxidized_cut_copper", "vlf_copper:waxed_oxidized_cut_copper")
minetest.register_alias("minecraft:waxed_copper_block", "vlf_copper:waxed_copper")
minetest.register_alias("minecraft:chiseled_tuff", "vlf_deepslate:tuff_chiseled")
minetest.register_alias("minecraft:waxed_copper_bulb", "vlf_copper:waxed_copper_bulb_lit")
minetest.register_alias("minecraft:chiseled_tuff_bricks", "vlf_deepslate:tuff_bricks_chiseled")
minetest.register_alias("minecraft:polished_tuff", "vlf_deepslate:tuff_polished")
minetest.register_alias("minecraft:trial_spawner", "vlf_mobspawners:spawner")
minetest.register_alias("minecraft:pointed_dripstone", "air")
minetest.register_alias("minecraft:tripwire", "voxelforge:tripwire")
minetest.register_alias("minecraft:tripwire_hook_active", "voxelforge:tripwire_hook_active")
minetest.register_alias("minecraft:waxed_copper_grate", "vlf_copper:waxed_copper_grate")


--[[local function convert_vlfschem_to_binary(directory)
	local function process_directory(dir)
		-- Get the list of files and subdirectories in the current directory
        	local files = minetest.get_dir_list(dir, false)
        	local subdirs = minetest.get_dir_list(dir, true)
        	-- Process files in the current directory
        	for _, file in ipairs(files) do
			local filepath = dir .. "/" .. file
			if filepath:sub(-18) == ".vlfschem.vlfschem" then
				--if filepath:sub(-9) == ".vlfschem" then
				--local output_file_path = filepath .. ""
				local output_file_path = filepath:gsub(".vlfschem.vlfschem", ".vlfschem") .. ""
				--minetest.log("action", "Converting file to binary: " .. filepath .. " -> " .. output_file_path)
				-- Attempt to open the input file in text mode
				local input_file = io.open(filepath, "r")
				if not input_file then
					--minetest.log("error", "Cannot open input file: " .. filepath)
					return false
				end
				-- Read the input file content
				local content = input_file:read("*a")
				input_file:close()
				-- Attempt to deserialize the content into a Lua table
				local func, err = loadstring(content)
				if not func then
					--minetest.log("error", "Error loading input file: " .. err)
					return false
				end
				local success, data = pcall(func)
				if not success then
					--minetest.log("error", "Error executing input file: " .. data)
					return false
				end
				-- Serialize the Lua table into binary format
				local binary_data = binser.serialize(data)
				-- Attempt to open the output file in binary mode
				local output_file = io.open(output_file_path, "wb")
				if not output_file then
					--minetest.log("error", "Cannot open output file: " .. output_file_path)
					return false
				end
				-- Write the binary data to the output file
				output_file:write(binary_data)
				output_file:close()
				--minetest.log("action", "File successfully converted to binary: " .. output_file_path)
			end
		end
		-- Recursively process subdirectories
		for _, subdir in ipairs(subdirs) do
			process_directory(dir .. "/" .. subdir)
		end
	end
	-- Start processing from the specified directory
	process_directory(directory)
end]]

local function convert_vlfschem_to_binary(directory)
    local function process_directory(dir)
        -- Get the list of files and subdirectories in the current directory
        local files = minetest.get_dir_list(dir, false)
        local subdirs = minetest.get_dir_list(dir, true)
        
        -- Process files in the current directory
        for _, file in ipairs(files) do
            local filepath = dir .. "/" .. file
            if filepath:sub(-18) == ".vlfschem.vlfschem" then
                local output_file_path = filepath:gsub(".vlfschem.vlfschem", ".vlfschem")
                
                -- Attempt to open the input file in text mode
                local input_file = io.open(filepath, "r")
                if not input_file then
                    return false
                end
                
                -- Read the input file content
                local content = input_file:read("*a")
                input_file:close()
                
                -- Attempt to deserialize the content into a Lua table
                local func, err = loadstring(content)
                if not func then
                    return false
                end
                
                local success, data = pcall(func)
                if not success then
                    return false
                end
                
                -- Serialize the Lua table into binary format
                local binary_data = binser.serialize(data)
                
                -- Compress the binary data
                local compressed_data = minetest.compress(binary_data)
                
                -- Attempt to open the output file in binary mode
                local output_file = io.open(output_file_path, "wb")
                if not output_file then
                    return false
                end
                
                -- Write the compressed binary data to the output file
                output_file:write(compressed_data)
                output_file:close()
            end
        end
        
        -- Recursively process subdirectories
        for _, subdir in ipairs(subdirs) do
            process_directory(dir .. "/" .. subdir)
        end
    end
    
    -- Start processing from the specified directory
    process_directory(directory)
end


convert_vlfschem_to_binary(modpath.."/data/voxelforge/structure/pillager_outpost")

--[[ Register the glass-like node
minetest.register_node(":voxelforge:temp_glass", {
	description = "Temporary Glass",
	drawtype = "glasslike",
	tiles = {"default_glass.png"},
	groups = {cracky = 3, oddly_breakable_by_hand = 3, not_in_creative_inventory = 1},
	drop = "",
	sunlight_propagates = true,
	paramtype = "light",
})

-- Helper function to place temporary glass-like nodes
local function place_temp_glass(pos, size, offset)
	local start_pos = vector.add(pos, offset)
	local end_pos = vector.add(start_pos, {x = size.x - 1, y = size.y - 1, z = size.z - 1})

	for x = start_pos.x, end_pos.x do
		for y = start_pos.y, end_pos.y do
			for z = start_pos.z, end_pos.z do
				if x == start_pos.x or x == end_pos.x or y == start_pos.y or y == end_pos.y or z == start_pos.z or z == end_pos.z then
					local node_pos = {x = x, y = y, z = z}
					if minetest.get_node(node_pos).name == "air" then
						minetest.set_node(node_pos, {name = "voxelforge:temp_glass"})
					end
				end
			end
		end
	end
end

-- Add a function to remove temporary glass-like nodes
local function remove_temp_glass(pos, size, offset)
	local start_pos = vector.add(pos, offset)
	local end_pos = vector.add(start_pos, {x = size.x - 1, y = size.y - 1, z = size.z - 1})

	for x = start_pos.x, end_pos.x do
		for y = start_pos.y, end_pos.y do
			for z = start_pos.z, end_pos.z do
				local node_pos = {x = x, y = y, z = z}
				if minetest.get_node(node_pos).name == "voxelforge:temp_glass" then
					minetest.set_node(node_pos, {name = "air"})
				end
			end
		end
	end
end

-- Register the schematic editor node
minetest.register_node(":voxelforge:schematic_editor", {
	description = "Schematic Editor",
	tiles = {"schematic_editor.png"},
	groups = {cracky = 3, oddly_breakable_by_hand = 3},

	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos)
		meta:set_string("owner", player:get_player_name()) -- Store the player name who opened the node
		local sx = meta:get_int("sx")
		local sy = meta:get_int("sy")
		local sz = meta:get_int("sz")
		local ox = meta:get_int("ox")
		local oy = meta:get_int("oy")
		local oz = meta:get_int("oz")
		local filename = meta:get_string("filename") or "schematic"
		local save_entities = meta:get_string("save_entities") == "true"
		local formspec = "size[8,8]" ..
			"field[0.5,1;2,1;sx;Size X;" .. sx .. "]" ..
			"field[2.5,1;2,1;sy;Size Y;" .. sy .. "]" ..
			"field[4.5,1;2,1;sz;Size Z;" .. sz .. "]" ..
			"field[0.5,3;2,1;ox;Offset X;" .. ox .. "]" ..
			"field[2.5,3;2,1;oy;Offset Y;" .. oy .. "]" ..
			"field[4.5,3;2,1;oz;Offset Z;" .. oz .. "]" ..
			"field[0.5,5;4,1;filename;Filename (without extension);" .. filename .. "]" ..
			"checkbox[6,3;save_entities;Save Entities;" .. (save_entities and "true" or "false") .. "]" ..
			"button[6,5;2,1;save_config;Save Configurations]" ..
			"button[6,6;2,1;export;Export Schematic]" ..
			"button[6,7;2,1;detect_size;Auto Detect Size/Offset]" ..
			"button[6,8;2,1;remove_temp_glass;Remove Temporary Glass]"
			minetest.show_formspec(player:get_player_name(), "voxelforge:schematic_editor", formspec)
	end,
})]]

-- Export schematic function
local function export_schematic(player, pos, size, offset, filename, save_entities)
    local start_pos = vector.add(pos, offset)
    local end_pos = vector.add(start_pos, {x = size.x - 1, y = size.y - 1, z = size.z - 1})
    local min_x, min_y, min_z = end_pos.x, end_pos.y, end_pos.z
    local max_x, max_y, max_z = start_pos.x, start_pos.y, start_pos.z

    local worldpath = minetest.get_worldpath()
    local file_path = worldpath .. "/" .. filename .. ".vlfschem"
    local file = io.open(file_path, "w")
    if not file then
        minetest.chat_send_player(player:get_player_name(), "Failed to export schematic.")
        return
    end

    file:write("return {\n")
    file:write("    size = {x = " .. size.x .. ", y = " .. size.y .. ", z = " .. size.z .. "},\n")

    -- Serialize and write nodes in batches with metadata first
    file:write("    nodes = {\n")
    for x = start_pos.x, end_pos.x do
        for y = start_pos.y, end_pos.y do
            for z = start_pos.z, end_pos.z do
                local node_pos = {x = x, y = y, z = z}
                local node = minetest.get_node(node_pos)
                if node.name ~= "voxelforge:temp_glass" and node.name ~= "voxelforge:schematic_editor" then
                    local meta = minetest.get_meta(node_pos):to_table().fields
                    local meta_str = minetest.serialize(meta):gsub("^return ", "")
                    local node_data = string.format(
                        "        {metadata = %s, name = %q, pos = {x = %d, y = %d, z = %d}, param2 = %d},\n",
                        meta_str, node.name, x - start_pos.x, y - start_pos.y, z - start_pos.z,
                        node.param2
                    )
                    file:write(node_data)

                    -- Update the bounds of the schematic
                    min_x = math.min(min_x, x)
                    min_y = math.min(min_y, y)
                    min_z = math.min(min_z, z)
                    max_x = math.max(max_x, x)
                    max_y = math.max(max_y, y)
                    max_z = math.max(max_z, z)
                end
            end
        end
    end
    file:write("    },\n")

    -- Calculate the actual size of the schematic excluding temp_glass and schematic_editor nodes
    local actual_size = {
        x = max_x - min_x + 1,
        y = max_y - min_y + 1,
        z = max_z - min_z + 1
    }

    -- Serialize and write entities if required
    if save_entities then
        file:write("    entities = {\n")
        local objects = minetest.get_objects_inside_radius(vector.add(start_pos, vector.divide(actual_size, 2)), math.max(actual_size.x, actual_size.y, actual_size.z) / 2)
        for _, obj in ipairs(objects) do
            if not obj:is_player() then
                local luaentity = obj:get_luaentity()
                if luaentity then
                    local entity_data = string.format(
                        "        {name = %q, pos = {x = %d, y = %d, z = %d}, properties = %s},\n",
                        luaentity.name, obj:get_pos().x - start_pos.x, obj:get_pos().y - start_pos.y, obj:get_pos().z - start_pos.z,
                        minetest.serialize(luaentity)
                    )
                    file:write(entity_data)
                end
            end
        end
        file:write("    },\n")
    else
        file:write("    entities = {},\n")
    end

    file:write("    probability = 1\n")
    file:write("}\n")
    file:close()

    minetest.chat_send_player(player:get_player_name(), "Schematic exported to " .. file_path)
end
--[[ Handle formspec input
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname == "voxelforge:schematic_editor" then
        -- Get position of the node from player's view
        local node_pos = minetest.get_player_by_name(player:get_player_name()):get_pos()
        node_pos = vector.floor(node_pos)

        -- Find all nodes of schematic editor in the area
        local nodes = minetest.find_nodes_in_area(vector.subtract(node_pos, 3), vector.add(node_pos, 3), "voxelforge:schematic_editor")
        local pos = nodes[1]  -- Assume we only handle one node

        if not pos then
            minetest.chat_send_player(player:get_player_name(), "No schematic editor node found.")
            return
        end

        -- Retrieve node meta
        local meta = minetest.get_meta(pos)

        -- Extract and save fields
        local sx = tonumber(fields.sx) or meta:get_int("sx")
        local sy = tonumber(fields.sy) or meta:get_int("sy")
        local sz = tonumber(fields.sz) or meta:get_int("sz")
        local ox = tonumber(fields.ox) or meta:get_int("ox")
        local oy = tonumber(fields.oy) or meta:get_int("oy")
        local oz = tonumber(fields.oz) or meta:get_int("oz")
        local filename = fields.filename or meta:get_string("filename") or "schematic"
        local save_entities = fields.save_entities == "true"

        -- Save settings to node meta
        meta:set_int("sx", sx)
        meta:set_int("sy", sy)
        meta:set_int("sz", sz)
        meta:set_int("ox", ox)
        meta:set_int("oy", oy)
        meta:set_int("oz", oz)
        meta:set_string("filename", filename)
        meta:set_string("save_entities", tostring(save_entities))

        if fields.save_config then
            minetest.chat_send_player(player:get_player_name(), "Configurations saved!")

            -- Place temporary glass-like nodes
            place_temp_glass(pos, {x = sx, y = sy, z = sz}, {x = ox, y = oy, z = oz})
        elseif fields.export then
            minetest.chat_send_player(player:get_player_name(), "Exporting schematic...")

            -- Export the schematic
            export_schematic(player, pos, {x = sx, y = sy, z = sz}, {x = ox, y = oy, z = oz}, filename, save_entities)
        elseif fields.remove_temp_glass then
            minetest.chat_send_player(player:get_player_name(), "Removing temporary glass...")

            -- Remove temporary glass-like nodes
            remove_temp_glass(pos, {x = sx, y = sy, z = sz}, {x = ox, y = oy, z = oz})
        end
    end
end)]]

-- Refined Formspec Layout for Schematic Editor

-- Register the glass-like node
minetest.register_node(":voxelforge:temp_glass", {
    description = "Temporary Glass",
    drawtype = "glasslike",
    tiles = {"default_glass.png"},
    groups = {cracky = 3, oddly_breakable_by_hand = 3, not_in_creative_inventory = 1},
    drop = "",
    sunlight_propagates = true,
    paramtype = "light",
})

-- Helper function to place temporary glass-like nodes
local function place_temp_glass(pos, size, offset)
    local start_pos = vector.add(pos, offset)
    local end_pos = vector.add(start_pos, {x = size.x - 1, y = size.y - 1, z = size.z - 1})

    for x = start_pos.x, end_pos.x do
        for y = start_pos.y, end_pos.y do
            for z = start_pos.z, end_pos.z do
                if x == start_pos.x or x == end_pos.x or y == start_pos.y or y == end_pos.y or z == start_pos.z or z == end_pos.z then
                    local node_pos = {x = x, y = y, z = z}
                    if minetest.get_node(node_pos).name == "air" then
                        minetest.set_node(node_pos, {name = "voxelforge:temp_glass"})
                    end
                end
            end
        end
    end
end

-- Add a function to remove temporary glass-like nodes
local function remove_temp_glass(pos, size, offset)
    local start_pos = vector.add(pos, offset)
    local end_pos = vector.add(start_pos, {x = size.x - 1, y = size.y - 1, z = size.z - 1})

    for x = start_pos.x, end_pos.x do
        for y = start_pos.y, end_pos.y do
            for z = start_pos.z, end_pos.z do
                local node_pos = {x = x, y = y, z = z}
                if minetest.get_node(node_pos).name == "voxelforge:temp_glass" then
                    minetest.set_node(node_pos, {name = "air"})
                end
            end
        end
    end
end

local function get_node_texture(node_name)
    local def = minetest.registered_nodes[node_name]
    if def and def.tiles and type(def.tiles[1]) == "string" then
        return def.tiles[1]
    end
    --return "default_dirt.png"  -- Fallback texture if no texture is found
    return "blank.png"
end

local function create_composite_texture_string(pos, size, offset)
    local start_pos = vector.add(pos, offset)
    local end_pos = vector.add(start_pos, {x = size.x - 1, y = size.y - 1, z = size.z - 1})

    local combine_string = "^[combine:" .. (size.x * 16) .. "x" .. (size.z * 16)

    for z = 0, size.z - 1 do
        for x = 0, size.x - 1 do
            local node_pos = vector.add(start_pos, {x = x, y = 0, z = z})  -- Only use Y = 0 slice
            local node = minetest.get_node(node_pos)
            local texture = get_node_texture(node.name)

            if texture then
                -- Calculate the position in the combined image
                local x_pos = x * 16
                local z_pos = z * 16
                combine_string = combine_string .. ":" .. x_pos .. "," .. z_pos .. "=" .. texture
            end
        end
    end

    return combine_string
end


minetest.register_node(":voxelforge:schematic_editor", {
    description = "Schematic Editor",
    tiles = {"default_stone.png"},
    groups = {cracky = 3, oddly_breakable_by_hand = 3},

    on_rightclick = function(pos, node, player, itemstack, pointed_thing)
        local meta = minetest.get_meta(pos)
        meta:set_string("owner", player:get_player_name())
        local sx = meta:get_int("sx")
        local sy = meta:get_int("sy")
        local sz = meta:get_int("sz")
        local ox = meta:get_int("ox")
        local oy = meta:get_int("oy")
        local oz = meta:get_int("oz")
        local filename = meta:get_string("filename") or "schematic"
        local save_entities = meta:get_string("save_entities") == "true"
        local remove_blocks = meta:get_string("remove_blocks") == "true"

        -- Generate composite texture string
        local preview_texture = create_composite_texture_string(pos, {x = sx, y = sy, z = sz}, {x = ox, y = oy, z = oz})

        local formspec = "size[12,10]" ..
            "label[0.5,0.5;Mode:]" ..
            "dropdown[1.5,0.35;2;mode;Save,Load;1]" ..
            "label[0.5,1.25;Structure Name:]" ..
            "field[2.5,1.1;5,1;filename;;" .. filename .. "]" ..
            "label[0.5,2.25;Size:]" ..
            "field[1.5,2;1,1;sx;X;" .. sx .. "]" ..
            "field[2.5,2;1,1;sy;Y;" .. sy .. "]" ..
            "field[3.5,2;1,1;sz;Z;" .. sz .. "]" ..
            "label[0.5,3.25;Offset:]" ..
            "field[1.5,3;1,1;ox;X;" .. ox .. "]" ..
            "field[2.5,3;1,1;oy;Y;" .. oy .. "]" ..
            "field[3.5,3;1,1;oz;Z;" .. oz .. "]" ..
            "checkbox[0.5,4;save_entities;Include Entities;" .. (save_entities and "true" or "false") .. "]" ..
            "checkbox[2.5,4;remove_blocks;Remove Blocks;" .. (remove_blocks and "true" or "false") .. "]" ..
            "button[0.5,5.5;4,1;save;Save]" ..
            "button[5,5.5;4,1;export;Export]" ..
            "checkbox[0.5,7;show_bounding;Show Bounding Box;false]" ..
            "button[0.5,8;4,1;reset;Reset]" ..
            "button[5,8;4,1;remove_temp_glass;Remove Temporary Glass]" ..
            --"image[7,0.5;4,4;" .. preview_texture .. "]"  -- Use [combine texture for preview
            "model[7,0.5;4,4;obj;watchtower_overgrown.obj;default_mossycobble.png,vlf_core_planks_birch.png,vlf_core_log_big_oak.png,blank.png,vlf_core_planks_big_oak.png,default_torch_on_floor_animated.png,vlf_fences_fence_big_oak.png;30,30;false;true]"

        minetest.show_formspec(player:get_player_name(), "voxelforge:schematic_editor", formspec)
    end,
})

-- Handle formspec input
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname == "voxelforge:schematic_editor" then
        local name = player:get_player_name()

        -- Get position of the node from player's view
        local node_pos = minetest.get_player_by_name(name):get_pos()
        node_pos = vector.floor(node_pos)

        -- Find all nodes of schematic editor in the area
        local nodes = minetest.find_nodes_in_area(vector.subtract(node_pos, 3), vector.add(node_pos, 3), "voxelforge:schematic_editor")
        local pos = nodes[1]  -- Assume we only handle one node

        if not pos then
            minetest.chat_send_player(name, "No schematic editor node found.")
            return
        end

        -- Retrieve node meta
        local meta = minetest.get_meta(pos)

        -- Extract and save fields
        local sx = tonumber(fields.sx) or meta:get_int("sx")
        local sy = tonumber(fields.sy) or meta:get_int("sy")
        local sz = tonumber(fields.sz) or meta:get_int("sz")
        local ox = tonumber(fields.ox) or meta:get_int("ox")
        local oy = tonumber(fields.oy) or meta:get_int("oy")
        local oz = tonumber(fields.oz) or meta:get_int("oz")
        local filename = fields.filename or meta:get_string("filename") or "schematic"
        local save_entities = fields.save_entities == "true"
        local remove_blocks = fields.remove_blocks == "true"

        -- Save settings to node meta
        meta:set_int("sx", sx)
        meta:set_int("sy", sy)
        meta:set_int("sz", sz)
        meta:set_int("ox", ox)
        meta:set_int("oy", oy)
        meta:set_int("oz", oz)
        meta:set_string("filename", filename)
        meta:set_string("save_entities", tostring(save_entities))
        meta:set_string("remove_blocks", tostring(remove_blocks))

        if fields.save then
            minetest.chat_send_player(name, "Configurations saved!")
            -- Place temporary glass-like nodes
            place_temp_glass(pos, {x = sx, y = sy, z = sz}, {x = ox, y = oy, z = oz})
        elseif fields.export then
            minetest.chat_send_player(name, "Exporting schematic...")
            -- Export schematic functionality
            export_schematic(player, pos, {x = sx, y = sy, z = sz}, {x = ox, y = oy, z = oz}, filename, save_entities)
        elseif fields.remove_temp_glass then
            minetest.chat_send_player(name, "Removing temporary glass...")
            -- Remove temporary glass-like nodes
            remove_temp_glass(pos, {x = sx, y = sy, z = sz}, {x = ox, y = oy, z = oz})
        end
    end
end)

local function process_copper_bulb(pos, node)
    local pos_hash = minetest.hash_node_position({x = pos.x * 7, y = pos.y * 12, z = pos.z * 18})--minetest.hash_node_position(pos)
    local blockseed = minetest.get_mapgen_setting("seed")
    local rand

    -- Modify seed calculation for better randomness
    local seed = pos_hash + blockseed + minetest.hash_node_position({x = pos.x * 7, y = pos.y * 12, z = pos.z * 18})
    --local rand = PcgRandom(seed)
    rand = Randomizer.new(pos_hash, blockseed)

    -- Generate a random float between 0.0 and 1.0
    --local rand_value = rand:next(0, 2^31 - 1) / (2^31 - 1)
    local rand_value = rand:random(0, 2^31 - 1) / (2^31 - 1)
    
    local result_node = nil
    if node.name == "vlf_copper:waxed_copper_bulb_lit" then
        if rand_value <= 0.1 then
            result_node = {
                name = "vlf_copper:waxed_oxidized_copper_bulb_lit",
            }
        elseif rand_value <= 0.33333334 then
            result_node = {
                name = "vlf_copper:waxed_weathered_copper_bulb_lit",
            }
        elseif rand_value <= 0.5 then
            result_node = {
                name = "vlf_copper:waxed_exposed_copper_bulb_lit",
            }
        end
    end

    return result_node
end

-- Non Binary File
local function load_vlfschem_nb(file_name)
    if not file_name then
        minetest.log("error", "File name is nil.")
        return nil
    end

    local file_path = file_name
    minetest.log("action", "Loading schematic from file: " .. file_path)

    -- Attempt to load the Lua file
    local chunk, load_err = loadfile(file_path)
    if not chunk then
        minetest.log("error", "Cannot load file: " .. file_path .. " - " .. load_err)
        return nil
    end

    -- Execute the Lua file and capture the returned data
    local success, schematic_data = pcall(chunk)
    if not success then
        minetest.log("error", "Error executing Lua file: " .. schematic_data)
        return nil
    end

    -- Ensure the returned data is a table
    if type(schematic_data) ~= "table" then
        minetest.log("error", "Schematic data is not a table in file: " .. file_name)
        return nil
    end

    -- Check if the 'nodes' field is present and is a table
    if type(schematic_data.nodes) ~= "table" then
        minetest.log("error", "Invalid schematic data: 'nodes' field is missing or not a table")
        return nil
    end

    -- Optionally log the type and content of the schematic data
    minetest.log("action", "Schematic data type: " .. type(schematic_data))

    return schematic_data -- Return the entire schematic table
end

--[[local function load_vlfschem(file_name)
    if not file_name then
        --minetest.log("error", "File name is nil.")
        return nil
    end
    local file_path = modpath .. "/" .. file_name
    --minetest.log("action", "Loading schematic from file: " .. file_path)

    -- Attempt to open the file in binary mode
    local file = io.open(file_path, "rb")
    if not file then
        --minetest.log("error", "Cannot open file: " .. file_path)
        return nil
    end

    -- Read the binary file content
    local content = file:read("*a")
    file:close()

    -- Attempt to deserialize the binary content using binser
    local success, schematic_data = pcall(function() return binser.deserialize(content) end)
    if not success then
        --minetest.log("error", "Error deserializing .vlfschem file: " .. schematic_data)
        return nil
    end

    -- Ensure the schematic data is a table
    if type(schematic_data) ~= "table" then
        --minetest.log("error", "Schematic data is not a table in file: " .. file_name)
        return nil
    end

    -- Log the type and content of the schematic data
    --minetest.log("action", "Schematic data type: " .. type(schematic_data[1])) -- schematic_data[1] is the first element if multiple items returned

    -- Check the structure of the schematic data
    if type(schematic_data[1].nodes) ~= "table" then
        --minetest.log("error", "Invalid schematic data format in file: " .. file_name)
        return nil
    end

    return schematic_data[1] -- return the first item in case of multiple items
end]]

--[[local function load_vlfschem(file_name)
    if not file_name then
        --minetest.log("error", "File name is nil.")
        return nil
    end
    local file_path = modpath .. "/" .. file_name
    --minetest.log("action", "Loading schematic from file: " .. file_path)

    -- Attempt to open the file in binary mode
    local file = io.open(file_path, "rb")
    if not file then
        --minetest.log("error", "Cannot open file: " .. file_path)
        return nil
    end

    -- Read the binary file content
    local compressed_content = file:read("*a")
    file:close()

    -- Decompress the content
    local content = minetest.decompress(compressed_content)

    -- Attempt to deserialize the decompressed content
    local success, schematic_data = pcall(function() return binser.deserialize(content) end)
    if not success then
        --minetest.log("error", "Error deserializing .vlfschem file: " .. schematic_data)
        return nil
    end

    -- Ensure the schematic data is a table
    if type(schematic_data) ~= "table" then
        --minetest.log("error", "Schematic data is not a table in file: " .. file_name)
        return nil
    end

    -- Log the type and content of the schematic data
    --minetest.log("action", "Schematic data type: " .. type(schematic_data[1]))

    -- Check the structure of the schematic data
    if type(schematic_data[1].nodes) ~= "table" then
        --minetest.log("error", "Invalid schematic data format in file: " .. file_name)
        return nil
    end

    return schematic_data[1] -- return the first item in case of multiple items
end]]






local function load_vlfschem(file_name)
    if not file_name then
        --minetest.log("error", "File name is nil.")
        return nil
    end
    local file_path = modpath .. "/" .. file_name
    --minetest.log("action", "Loading schematic from file: " .. file_path)

    -- Attempt to open the file in binary mode
    local file = io.open(file_path, "rb")
    if not file then
        --minetest.log("error", "Cannot open file: " .. file_path)
        return nil
    end

    -- Read the binary file content
    local compressed_content = file:read("*a")
    file:close()

    -- Decompress the content
    local content = minetest.decompress(compressed_content)

    -- Attempt to deserialize the decompressed content
    local success, schematic_data = pcall(function() return binser.deserialize(content) end)
    if not success then
        --minetest.log("error", "Error deserializing .vlfschem file: " .. schematic_data)
        return nil
    end

    -- Ensure the schematic data is a table
    if type(schematic_data) ~= "table" then
        --minetest.log("error", "Schematic data is not a table in file: " .. file_name)
        return nil
    end

    -- Log the type and content of the schematic data
    --minetest.log("action", "Schematic data type: " .. type(schematic_data[1]))

    -- Check the structure of the schematic data
    if type(schematic_data[1].nodes) ~= "table" then
        --minetest.log("error", "Invalid schematic data format in file: " .. file_name)
        return nil
    end

    return schematic_data[1] -- return the first item in case of multiple items
end

-- Function to check if a table contains a value
local function table_contains(tbl, value)
    for _, v in ipairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

local function set_metadata(metadata)
    if not metadata then
        return
    end

    local start_time = minetest.get_us_time()  -- Start timing

    -- Ensure the metadata is in the correct format
    local formatted_metadata = {}
    for pos, meta in pairs(metadata) do
        local meta_node_pos = vector.new(pos)
        formatted_metadata[meta_node_pos] = meta
    end

    -- Set metadata for each node position
    for pos, meta in pairs(formatted_metadata) do
        local node_meta = minetest.get_meta(pos)
        for key, value in pairs(meta) do
            node_meta:set_string(key, value)
        end
    end

    local end_time = minetest.get_us_time()  -- End timing
    local elapsed_time = (end_time - start_time) / 1000000  -- Convert microseconds to seconds
    --minetest.log("action", string.format("Metadata setting finished in %.4f seconds.", elapsed_time))
end

-- Rotation function for positions, considering the rotation origin
local function rotate_position(pos, rotation, origin)
    local relative_pos = vector.subtract(pos, origin)
    local x, z = relative_pos.x, relative_pos.z

    local rotated_pos
    if rotation == 270 then
        rotated_pos = {x = -z, y = relative_pos.y, z = x}
    elseif rotation == 180 then
        rotated_pos = {x = -x, y = relative_pos.y, z = -z}
    elseif rotation == 90 then
        rotated_pos = {x = z, y = relative_pos.y, z = -x}
    else
        rotated_pos = relative_pos
    end

    return vector.add(rotated_pos, origin)
end

-- Tables for directions, up, and down orientations
local direction_table = {0, 1, 2, 3}        -- North, East, South, West
local up_orientation_table = {6, 15, 8, 17} -- Up North, Up East, Up South, Up West
local down_orientation_table = {4, 13, 10, 19} -- Down North, Down East, Down South, Down West

-- Function to rotate param2 based on its table and rotation angle
local function rotate_param2(param2, rotation)
    local table_to_use

    if param2 == 6 or param2 == 15 or param2 == 8 or param2 == 17 then
        table_to_use = up_orientation_table
    elseif param2 == 4 or param2 == 13 or param2 == 10 or param2 == 19 then
        table_to_use = down_orientation_table
    else
        table_to_use = direction_table
    end

    -- Normalize the rotation to one of the defined values (0, 90, 180, 270)
    local normalized_rotation = (rotation % 360)
    if normalized_rotation < 0 then
        normalized_rotation = normalized_rotation + 360
    end
    
    -- Determine the current index in the table
    local index = nil
    for i, val in ipairs(table_to_use) do
        if param2 == val then
            index = i
            break
        end
    end

    if not index then
        return param2 -- Return the original param2 if no match found
    end

    -- Calculate the new index based on rotation
    local new_index = (index - 1 + (normalized_rotation / 90)) % 4 + 1
    return table_to_use[new_index]
end

-- Function to load the area around the position
local function load_area(minp, maxp)
    if not minetest.get_voxel_manip then
        return true  -- No voxel manipulator support, assume area is loaded
    end

    local manip = minetest.get_voxel_manip()
    local e1, e2 = manip:read_from_map(minp, maxp)
    if e1 and e2 then
        manip:calc_lighting()
        manip:update_map()
        return true
    else
        return false  -- Area couldn't be loaded
    end
end

local BoundingBox = dofile(modpath.."/bounding_box.lua")

local function place_schematic(pos, file_name, rotation, rotation_origin)
    local start_time = minetest.get_us_time()  -- Start timing

    rotation = rotation or 0
    rotation_origin = rotation_origin or pos

    local pos_hash = minetest.hash_node_position(pos)
    local blockseed = minetest.get_mapgen_setting("seed")
    local seed = pos_hash + blockseed
    local rng = PcgRandom(seed)
    local schematic = load_vlfschem(file_name)
    if not schematic then
        --minetest.log("error", "Failed to load schematic data.")
        return
    end

    -- Determine the area to be loaded based on schematic size
    local schematic_size = schematic.size
    local minp, maxp

    local schem_size
    if rotation == 0 then
    minp = vector.subtract(pos, vector.multiply(schematic_size, 0.0))
    maxp = vector.add(pos, vector.multiply(schematic_size, 1.0))
    elseif rotation == 90 then
    schem_size = {x=schematic_size.z, y=schematic_size.y, z=schematic_size.x}
    minp = vector.add(pos, vector.multiply(schem_size, 1.0))
    maxp = vector.subtract(pos, vector.multiply(schem_size, 0.0))
    elseif rotation == 180 then
    minp = vector.subtract(pos, vector.multiply(schematic_size, 1.0))
    maxp = vector.add(pos, vector.multiply(schematic_size, 0.0))
    elseif rotation == 270 then
    schem_size = {x=schematic_size.z, y=schematic_size.y, z=schematic_size.x}
    minp = vector.add(pos, vector.multiply(schem_size, 0.0))
    maxp = vector.subtract(pos, vector.multiply(schem_size, 1.0))
    else
    minp = vector.subtract(pos, vector.multiply(schematic_size, 0.0))
    maxp = vector.add(pos, vector.multiply(schematic_size, 1.0))
    end


    minetest.log("action", "Schematic " .. file_name .. " bounds: minp=" .. minetest.pos_to_string(minp) .. ", maxp=" .. minetest.pos_to_string(maxp) .. "Schematic rotation: " .. tostring(rotation))

    -- Load the area
    if not load_area(minp, maxp) then
        --minetest.log("error", "Failed to load area for schematic placement.")
        return
    end

    local nodes_by_type = {}
    local metadata = {}

    -- Process nodes
    for _, node in ipairs(schematic.nodes) do
        -- Rotate node position and param2
        local rotated_pos = rotate_position(node.pos, rotation, rotation_origin)
        local node_pos = vector.add(pos, rotated_pos)

        -- Rotate param2 based on the node's orientation
        local rotated_param2 = rotate_param2(node.param2 or 0, rotation)

        -- Process copper bulbs separately
        if node.name == "vlf_copper:waxed_copper_bulb_lit" then
            local processed_node = process_copper_bulb(node_pos, node)
            local node_name = processed_node and processed_node.name or node.name
            local node_param2 = processed_node and (rotated_param2 or 0) or rotated_param2

            -- Set copper bulb nodes individually
            minetest.set_node(node_pos, {name = node_name, param2 = node_param2})
        else
            -- Collect other nodes for bulk processing
            local node_key = node.name .. "_" .. rotated_param2

            if not nodes_by_type[node_key] then
                nodes_by_type[node_key] = {positions = {}, name = node.name, param2 = rotated_param2}
            end

            table.insert(nodes_by_type[node_key].positions, node_pos)

            -- Collect metadata if it exists
            if node.metadata and next(node.metadata) then
                metadata[node_pos] = node.metadata
            end
        end
    end

    -- Place other nodes in batches
    for _, node_group in pairs(nodes_by_type) do
        local positions = node_group.positions
        local total_positions = #positions
        local max_nodes_per_batch = 10000

        for i = 1, total_positions, max_nodes_per_batch do
            local end_index = math.min(i + max_nodes_per_batch - 1, total_positions)
            local batch_positions = {}
            for j = i, end_index do
                table.insert(batch_positions, positions[j])
            end

            minetest.bulk_set_node(batch_positions, {name = node_group.name, param2 = node_group.param2})
        end
    end

    -- Set metadata
    if next(metadata) then
        set_metadata(metadata)
    end

    -- Determine bounding box for the schematic
    local bbox_minp = vector.subtract(minp, pos)
    local bbox_maxp = vector.subtract(maxp, pos)
    local bounding_box = BoundingBox.new(bbox_minp.x, bbox_minp.y, bbox_minp.z, bbox_maxp.x, bbox_maxp.y, bbox_maxp.z)

    -- (Optional) Debug or visualize bounding box here
    -- e.g., minetest.debug("Bounding box: " .. tostring(bounding_box))

    local end_time = minetest.get_us_time()  -- End timing
    local elapsed_time = (end_time - start_time) / 1000000  -- Convert microseconds to seconds
    --minetest.log("action", string.format("Schematic placed in %.4f seconds.", elapsed_time))
end

local json = minetest.parse_json

local existing_bounding_boxes = {}

--[[local function get_bounding_box(schematic_pos, schematic_size, rotation)
    local minp, maxp

    if rotation == 0 then
        -- Rotation 0: Correct as is.
        minp = vector.new(schematic_pos)
        maxp = vector.add(schematic_pos, vector.subtract(schematic_size, {x = 1, y = 1, z = 1}))
    elseif rotation == 90 then
        -- Rotate 90 degrees (x and z dimensions swapped)
        local rotated_size = {x = schematic_size.z, y = schematic_size.y, z = schematic_size.x}
        local schempos = {x = schematic_pos.x - schematic_size.z + 1, y = schematic_pos.y, z = schematic_pos.z + schematic_size.x}
        minp = vector.new(schempos)
        maxp = vector.add(schempos, vector.subtract(rotated_size, {x = 1, y = 1, z = 1}))
    elseif rotation == 180 then
        -- Rotate 180 degrees: Correct as is.
        local schempos = {x = schematic_pos.x + schematic_size.x - 1, y = schematic_pos.y, z = schematic_pos.z}
        minp = vector.new(schempos)
        maxp = vector.add(schempos, vector.subtract(schematic_size, {x = 1, y = 1, z = 1}))
    elseif rotation == 270 then
        -- Rotate 270 degrees: Correct as is.
        local rotated_size = {x = schematic_size.z, y = schematic_size.y, z = schematic_size.x}
        local schempos = {x = schematic_pos.x + schematic_size.z - 1, y = schematic_pos.y, z = schematic_pos.z}
        minp = vector.new(schempos)
        maxp = vector.add(schempos, vector.subtract(rotated_size, {x = 1, y = 1, z = 1}))
    else
        -- Fallback case (shouldn't be needed)
        minp = vector.new(schematic_pos)
        maxp = vector.add(schematic_pos, vector.subtract(schematic_size, {x = 1, y = 1, z = 1}))
    end

    return minp, maxp
end]]


--[[local function is_intersecting(minp1, maxp1, minp2, maxp2)
    -- Check if two bounding boxes intersect
    return not (maxp1.x > minp2.x or minp1.x < maxp2.x or maxp1.y > minp2.y or minp1.y < maxp2.y or maxp1.z > minp2.z or minp1.z < maxp2.z)
end]]

local function is_intersecting(minp1, maxp1, minp2, maxp2)
    -- Check if two bounding boxes intersect beyond their boundaries
    return not (maxp1.x <= minp2.x or  -- Changed from '>' to '<='
                minp1.x >= maxp2.x or  -- Changed from '<' to '>='
                maxp1.y <= minp2.y or  -- Changed from '>' to '<='
                minp1.y >= maxp2.y or  -- Changed from '<' to '>='
                maxp1.z <= minp2.z or  -- Changed from '>' to '<='
                minp1.z >= maxp2.z)    -- Changed from '<' to '>='
end

local function spawn_struct(pos)
    local pos_hash_1 = minetest.hash_node_position(pos)
    local blockseed_1 = minetest.get_mapgen_setting("seed")
    local seed_1 = pos_hash_1 + blockseed_1
    local rng = PcgRandom(seed_1)
    local modpath = minetest.get_modpath("vlf_data")
    local pos_hash = minetest.hash_node_position({x = pos.x * 256 * 8, y = pos.y * 12, z = pos.z * 18})
    local blockseed = minetest.get_mapgen_setting("seed")
    local seed = pos_hash + blockseed + minetest.hash_node_position({x = pos.x * rng:next(1, 47), y = pos.y * rng:next(1, 49), z = pos.z * rng:next(1, 45)}) -- For better randomization
    local rng = Randomizer.new(pos_hash, blockseed)
    local meta = minetest.get_meta(pos)
    local pool = meta:get_string("pool")
    local name = meta:get_string("name")
    local target = meta:get_string("target")
    local final_state = meta:get_string("final_state")
    local levels = tonumber(meta:get_string("levels")) or 0
    local joint_type = meta:get_string("joint_type")
    local param2 = minetest.get_node(pos).param2

    local offsets = {
        [0] = vector.new(0, 0, 1),    -- North-facing
        [1] = vector.new(1, 0, 0),    -- East-facing
        [2] = vector.new(0, 0, -1),   -- South-facing
        [3] = vector.new(-1, 0, 0),   -- West-facing
        [6] = vector.new(0, 1, 0),    -- Upward-facing
        [8] = vector.new(0, 1, 0),    -- Upward-facing
        [15] = vector.new(0, 1, 0),   -- Upward-facing
        [17] = vector.new(0, 1, 0),   -- Upward-facing
        [4] = vector.new(0, -1, 0),   -- Downward-facing
        [10] = vector.new(0, -1, 0),  -- Downward-facing
        [13] = vector.new(0, -1, 0),  -- Downward-facing
        [19] = vector.new(0, -1, 0),  -- Downward-facing
    }

    local rotations = {
        -- Normal
        [0] = { [2] = 0 },
        [1] = { [3] = 90 },
        [2] = { [0] = 180 },
        [3] = { [1] = 0 },
        -- Up
        [6] = { [4] = 0, [19] = 90 },
        [8] = { [10] = 180, [19] = 270 },
        [15] = { [4] = 90, [19] = 180 },
        [17] = { [19] = 0, [4] = 270},
        -- Down 
        -- Hybrid
        [0] = { [3] = 270, [1] = 90, [0] = 180 },
        [1] = { [2] = 90, [0] = 270, [1] = 180 },
        [2] = { [1] = 270, [3] = 90, [2] = 180 },
        [3] = { [2] = 270, [3] = 180, [0] = 90 },
    }

    local real_pool = pool:gsub("minecraft:", "")
    local json_path = modpath .. "/data/voxelforge/worldgen/template_pool/" .. real_pool .. ".json"
    local file = io.open(json_path, "r")
    if not file then
        return
    end

    local json_content = file:read("*a")
    file:close()

    local pool_data = json(json_content)
    if not pool_data then
        return
    end

    local elements = pool_data.elements
    if not elements or #elements == 0 then
        return
    end

    local fallback_pool = pool_data.fallback
    if fallback_pool then
        fallback_pool = fallback_pool:gsub("minecraft:", "")
    end

    local valid_schematics = {}
    local total_weight = 0

    local function process_elements(elements)
        for _, element_entry in ipairs(elements) do
            local element = element_entry.element
            local weight = element_entry.weight or 1
            if not element.location then
                table.insert(valid_schematics, {schematic = nil, weight = weight})
                total_weight = total_weight + weight
            else
                local location = element.location:gsub("minecraft:", "")
                local base_name = location:gsub("%.vlfschem.compressed$", "")
                local selecting_schematic = "/data/voxelforge/structure/" .. base_name .. ".vlfschem.compressed"

                local schematic_data = load_vlfschem(selecting_schematic)
                if not schematic_data then
                    return
                end

                local found_matching_node = false
                for _, node in ipairs(schematic_data.nodes) do
                    if node.metadata and node.metadata.name == target then
                        found_matching_node = true
                        break
                    end
                end

                if found_matching_node then
                    table.insert(valid_schematics, {schematic = selecting_schematic, weight = weight})
                    total_weight = total_weight + weight
                end
            end
        end
    end

    process_elements(elements)

    if #valid_schematics == 0 then
        if fallback_pool then
            local fallback_json_path = modpath .. "/data/voxelforge/worldgen/template_pool/" .. fallback_pool .. ".json"
            local fallback_file = io.open(fallback_json_path, "r")
            if not fallback_file then
                return
            end

            local fallback_json_content = fallback_file:read("*a")
            fallback_file:close()

            local fallback_pool_data = json(fallback_json_content)
            if not fallback_pool_data then
                return
            end

            elements = fallback_pool_data.elements
            if not elements or #elements == 0 then
                return
            end

            valid_schematics = {}
            total_weight = 0
            process_elements(elements)

            if #valid_schematics == 0 then
                return
            end
        else
            return
        end
    end

local function rotate_pos(pos, size, rotation)
    -- Rotates a position within a schematic bounding box based on the given rotation
    local new_pos = {x = pos.x, y = pos.y, z = pos.z}

    if rotation == 90 then
        new_pos.x = -pos.z
        new_pos.z = -pos.x
        new_pos.y = -pos.y
    elseif rotation == 0 then
        new_pos.x = -pos.x
        new_pos.z = -pos.z
        new_pos.y = -pos.y
    elseif rotation == 180 then
        new_pos.x = pos.x
        new_pos.z = pos.z
        new_pos.y = pos.y
    elseif rotation == 270 then
        new_pos.x = pos.z
        new_pos.z = pos.x
        new_pos.y = -pos.y
    end

    return new_pos
end

    while #valid_schematics > 0 do
        local selected_weight = rng:random(1, total_weight)
        local cumulative_weight = 0
        local selected_schematic = nil

        for i, schematic_data in ipairs(valid_schematics) do
            cumulative_weight = cumulative_weight + schematic_data.weight
            if selected_weight <= cumulative_weight then
                selected_schematic = schematic_data.schematic
                table.remove(valid_schematics, i)  -- Remove the selected schematic to avoid re-selection
                total_weight = total_weight - schematic_data.weight
                break
            end
        end

        if not selected_schematic then
            minetest.set_node(pos, {name = final_state})
            return
        end

        local offset = offsets[param2] or vector.new(0, 0, 0)
        local target_param2 = 0
        local target_pos

        local schematic_data = load_vlfschem(selected_schematic)
        if not schematic_data then
            return
        end

        for _, node in ipairs(schematic_data.nodes) do
            if node.metadata and node.metadata.name == target then
                target_pos = node.pos
                target_param2 = node.param2
                break
            end
        end

        if not target_pos then
            return
        end
        
        local rot = rotations[param2] and rotations[param2][target_param2] or 0
        local placement_pos = vector.add(pos, vector.subtract(offset, target_pos))

	local function check_overlap(placement_pos, schematic_data, rot)
        -- Checks for overlap with consideration of rotation
        local check_pos
        local schematic_size = schematic_data.size  -- Ensure you have the schematic size available
        for _, node in ipairs(schematic_data.nodes) do
            -- Transform node position based on rotation
            local node_pos = {x=0, y=0, z=0}
            local rotated_pos = rotate_pos(node.pos, schematic_size, rot)
            if rot == 0 or rot == 90 or rot == 270 then
            	check_pos = vector.subtract(placement_pos, rotated_pos)
            elseif rot == 180 then
            	check_pos = vector.add(placement_pos, rotated_pos)
            else
            	check_pos = vector.subtract(placement_pos, rotated_pos)
            end
            local node_name = minetest.get_node(check_pos).name
            minetest.log("action", "Check Position: " .. tostring(check_pos) .. " Selected Schematic "  .. selected_schematic .. "")
            if node_name == "vlf_deepslate:tuff_bricks" then
                return true  -- Overlap detected
            end
        end
        return false
    end


        --if not check_overlap(placement_pos, schematic_data, rot) then
        if not check_overlap(placement_pos, schematic_data, rot) then
            place_schematic(placement_pos, selected_schematic, rot, target_pos)
            minetest.set_node(pos, {name = final_state})
            local place_pos = pos + offset
            local target_node_meta = minetest.get_meta(place_pos)
            local target_final_state = target_node_meta:get_string("final_state")
            if target_final_state and target_final_state ~= "" then
                minetest.set_node(place_pos, {name = target_final_state})
            end
            return
        end
    end
end


-- Function to get the formspec
local function get_jigsaw_formspec(pos)
    local meta = minetest.get_meta(pos)
    local pool = meta:get_string("pool")
    local name = meta:get_string("name")
    local final_state = meta:get_string("final_state")
    local target = meta:get_string("target")
    local levels = meta:get_string("levels")
    local joint_type = meta:get_string("joint_type")
    
    return "size[12,10]" ..
           "field[0.5,0.5;7.5,1;pool;Target Pool:;" .. pool .. "]" ..
           "field[0.5,1.5;7.5,1;name;Name:;" .. name .. "]" ..
           "field[0.5,2.5;7.5,1;target;Target Name:;" .. target .. "]" ..
           "field[0.5,3.5;7.5,1;final_state;Turns into:;" .. final_state .. "]" ..
           "field[0.5,4.5;3.5,1;levels;Levels:;" .. levels .. "]" ..
           "field[4,4.5;3.5,1;joint_type;Joint Type:;" .. joint_type .. "]" ..
           "button[0.5,6.5;3,1;generate;Generate]" ..
           "button_exit[4.5,6.5;3,1;cancel;Cancel]"
end

-- Register the jigsaw block
minetest.register_node(":voxelforge:jigsaw", {
    description = "Jigsaw Block",
    tiles = {
    "jigsaw_lock.png",
    "jigsaw_side_0.png",
    "jigsaw_side_90.png",
    "jigsaw_side.png",
    "jigsaw_top.png",
    "jigsaw_bottom.png"
    },
    paramtype2 = "facedir",
    groups = {choppy = 2, oddly_breakable_by_hand = 2},
    on_rightclick = function(pos, node, player, itemstack, pointed_thing)
        if player:get_player_name() ~= "" and player:is_player() then
            minetest.show_formspec(player:get_player_name(), "voxelforge:jigsaw", get_jigsaw_formspec(pos))
        end
    end,
    on_construct = function(pos, node)
        local node = minetest.get_node(pos)
        local meta = minetest.get_meta(pos)
        
        -- Check if the node name matches the one you're interested in
        minetest.after(0.01, function()
        if node.name == "voxelforge:jigsaw" then
            meta:set_string("generate", "true")
            local generate = meta:get_string("generate")
            if generate == "true" then 
            	spawn_struct(pos)
            end
        end
        end)
end,
})

-- Handle form submissions
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "voxelforge:jigsaw" then
        return
    end
    
        local node_pos = minetest.get_player_by_name(player:get_player_name()):get_pos()
        node_pos = vector.floor(node_pos)

        -- Find all nodes of schematic editor in the area
        local nodes = minetest.find_nodes_in_area(vector.subtract(node_pos, 2), vector.add(node_pos, 2), "voxelforge:jigsaw")
        local pos = nodes[1]  -- Assume we only handle one node

        if not pos then
            minetest.chat_send_player(player:get_player_name(), "No jigsaw block node found.")
            return
        end

        -- Retrieve node meta
        local meta = minetest.get_meta(pos)

       	local pool = tostring(fields.pool) or meta:get_string("pool")
        local name = tostring(fields.name) or meta:get_string("name")
        local final_state = tostring(fields.final_state) or meta:get_string("final_state")
        local target = tostring(fields.target) or meta:get_string("target")
        local levels = tonumber(fields.levels) or meta:get_string("levels")
        local joint_type = tostring(fields.joint_type) or meta:get_string("joint_type")
    -- Update metadata fields
        meta:set_string("pool", pool)
        meta:set_string("name", name)
        meta:set_string("target", target)
        meta:set_string("final_state", final_state)
        meta:set_string("levels", levels)
        meta:set_string("joint_type", joint_type)
    if fields.generate then
	--meta:set_string("generate", "true")
	spawn_struct(pos)
    end
end)

minetest.register_chatcommand("place_test", {
	params = "",
	description = "Test for Procedural Structures.",
	func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then
            return false, "Player not found."
        end

        local pos = player:get_pos()
		--place_schematic(pos, "/data/voxelforge/structure/trial_chambers/corridor/end_1.vlfschem.compressed", 0)
		place_schematic(pos, "/data/voxelforge/structure/pillager_outpost/watchtower_overgrown.vlfschem", 0)
	end
})

local placed_schematics = {}  -- Table to store placed schematic data for each player

local function is_directory(path)
    local success, _, code = os.rename(path, path)
    if not success and code == 13 then
        return true
    end
    return success, code
end

local function is_file(path)
    local f = io.open(path, "r")
    if f then
        f:close()
        return true
    else
        return false
    end
end

local function place_all_schematics_in_directory(directory, pos_start, player_name)

    local function place_schematics_in_dir(dir, pos)
        local items = minetest.get_dir_list(dir, false) -- Get all items (files and directories)

        -- Sort items alphabetically
        table.sort(items)

        minetest.log("action", "Scanning directory: " .. dir)
        for _, item in ipairs(items) do
            local filepath = dir .. DIR_DELIM .. item
		if is_file(filepath) and item:match("%.lua$") and not item:match("%.vlfschem%.vlfschem$") then
                minetest.log("action", "Found schematic file: " .. filepath)

                local schematic = load_vlfschem_nb(filepath)
                if not schematic then
                    minetest.log("error", "Failed to load schematic data: " .. filepath)
                else
                    -- Calculate the size of the schematic for positioning
                    local schematic_size = {
                        x = schematic.size.x,
                        y = schematic.size.y,
                        z = schematic.size.z
                    }

                    -- Place the schematic
                    place_schematic(pos, filepath, 0)
                    minetest.log("action", "Placed schematic at position: " .. minetest.pos_to_string(pos))

                    -- Determine the position for the voxelforge:schematic_editor block
                    local editor_pos = {
                        x = pos.x,
                        y = pos.y - 1,                    -- One node below
                        z = pos.z
                    }

                    -- Place the voxelforge:schematic_editor block
                    minetest.set_node(editor_pos, {name = "voxelforge:schematic_editor"})

                    -- Set metadata for the schematic_editor block
                    local meta = minetest.get_meta(editor_pos)
                    meta:set_string("filename", item)
                    meta:set_string("sx", schematic.size.x)
                    meta:set_string("sy", schematic.size.y)
                    meta:set_string("sz", schematic.size.z)
                    meta:set_string("ox", 0)
                    meta:set_string("oy", 1)
                    meta:set_string("oz", 0)

                    -- Save the schematic's placement data for the player
                    table.insert(placed_schematics, {
                        name = item,
                        position = table.copy(pos),
                        size = schematic_size,
                        editor_pos = editor_pos
                    })

                    -- Update position for the next schematic placement
                    pos.z = pos.z + schematic_size.z + 4 -- Move position to the right by schematic width + 4 blocks
                end
            else
                minetest.log("action", "Skipped non-schematic file: " .. filepath)
            end
        end

        return pos
    end

    local final_pos = place_schematics_in_dir(directory, pos_start)
    return final_pos
end

-- Usage example:
-- place_all_schematics_in_directory("/path/to/schematics", {x = 0, y = 10, z = 0}, "player_name")

--place_all_schematics_in_directory(modpath .. "/data/voxelforge/structure/trial_chambers", {x = 0, y = 100, z = 0})

--[[minetest.register_on_joinplayer(function(pos)
	local pos = {x=0, y=100, z=0}
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/trial_chambers/chamber", pos)
end)

minetest.register_on_joinplayer(function(pos)
	local pos = {x=40, y=100, z=0}
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/trial_chambers/chamber/addon", pos)
end)

minetest.register_on_joinplayer(function(pos)
	local pos = {x=60, y=100, z=0}
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/trial_chambers/assembly", pos)
end)

minetest.register_on_joinplayer(function(pos)
	local pos = {x=100, y=100, z=0}
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/trial_chambers/chamber/eruption", pos)
end)

minetest.register_on_joinplayer(function(pos)
	local pos = {x=160, y=100, z=0}
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/trial_chambers/chamber/pedestal", pos)

end)

minetest.register_on_joinplayer(function(pos)
	local pos = {x=200, y=100, z=0}
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/trial_chambers/chamber/slanted", pos)
end)

minetest.register_on_joinplayer(function(pos)
	local pos = {x=-10, y=100, z=0}
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/trial_chambers/chests", pos)
end)

minetest.register_on_joinplayer(function(pos)
	local pos = {x=-10, y=100, z=10}
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/trial_chambers/chests/connectors", pos)
end)
minetest.register_on_joinplayer(function(pos)
	local pos = {x=-40, y=100, z=0}
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/trial_chambers/corridor", pos)
end)

minetest.register_on_joinplayer(function(pos)
	local pos = {x=-70, y=100, z=0}
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/trial_chambers/corridor/atrium", pos)
end)

minetest.register_on_joinplayer(function(pos)
	local pos = {x=-100, y=100, z=0}
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/trial_chambers/corridor/addon", pos)
end)
minetest.register_on_joinplayer(function(pos)
	local pos = {x=-120, y=100, z=0}
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/trial_chambers/decor", pos)
end)

minetest.register_on_joinplayer(function(pos)
	local pos = {x=-140, y=100, z=0}
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/trial_chambers/dispensers", pos)
end)

minetest.register_on_joinplayer(function(pos)
	local pos = {x=-170, y=100, z=0}
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/trial_chambers/hallway", pos)
end)

minetest.register_on_joinplayer(function(pos)
	local pos = {x=-200, y=100, z=0}
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/trial_chambers/intersection", pos)
end)

minetest.register_on_joinplayer(function(pos)
	local pos = {x=-220, y=100, z=0}
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/trial_chambers/reward", pos)
end)

minetest.register_on_joinplayer(function(pos)
	local pos = {x=-230, y=100, z=0}
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/trial_chambers/spawner/breeze", pos)
end)

minetest.register_on_joinplayer(function(pos)
	local pos = {x=-240, y=100, z=0}
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/trial_chambers/spawner/connectors", pos)
end)

minetest.register_on_joinplayer(function(pos)
	local pos = {x=-250, y=100, z=0}
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/trial_chambers/spawner/melee", pos)
end)

minetest.register_on_joinplayer(function(pos)
	local pos = {x=-260, y=100, z=0}
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/trial_chambers/spawner/ranged", pos)
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/trial_chambers/spawner/slow_ranged", {x=-270, y=100, z=0})
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/trial_chambers/spawner/small_melee", {x=-280, y=100, z=0})
	----minetest.log("error", "schematic placed at" .. pos .. "")
end)

minetest.register_on_joinplayer(function(pos)
	local pos = {x=-270, y=100, z=0}
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/trial_chambers/spawner/slow_ranged", pos)
end)

minetest.register_on_joinplayer(function(pos)
	local pos = {x=-280, y=100, z=0}
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/trial_chambers/spawner/small_melee", pos)
end)]]

--[[minetest.register_on_joinplayer(function(pos)
	local pos = {x=0, y=100, z=0}
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/pillager_outpost", pos)
end)]]
