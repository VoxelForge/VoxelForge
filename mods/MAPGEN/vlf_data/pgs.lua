local modpath = minetest.get_modpath("vlf_data")
local binser = dofile(modpath .. "/binser.lua")
local Randomizer = dofile(minetest.get_modpath("vlf_lib").."/init.lua")

minetest.register_on_mods_loaded(function()
    local worldpath = minetest.get_worldpath()
    local dir_name = "voxelforge/structure_block/export"
    local target_path = worldpath .. DIR_DELIM .. dir_name
    
    local dir_name2 = "voxelforge/structure_block/3d_models"
    local target_path2 = worldpath .. DIR_DELIM .. dir_name2
    
    local dir_name3 = "generated/voxelforge/structures"
    local target_path3 = worldpath .. DIR_DELIM .. dir_name3

    -- Attempt to create the directory
    local success = minetest.mkdir(target_path)
    if success then
        minetest.log("action", "[CustomDir] Directory ensured at: " .. target_path)
    else
        minetest.log("error", "[CustomDir] Failed to ensure directory at: " .. target_path)
    end
    local success2 = minetest.mkdir(target_path2)
    if success2 then
        minetest.log("action", "[CustomDir] Directory ensured at: " .. target_path2)
    else
        minetest.log("error", "[CustomDir] Failed to ensure directory at: " .. target_path2)
    end
    local success3 = minetest.mkdir(target_path3)
    if success3 then
        minetest.log("action", "[CustomDir] Directory ensured at: " .. target_path3)
    else
        minetest.log("error", "[CustomDir] Failed to ensure directory at: " .. target_path3)
    end
end)


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
minetest.register_alias("voxelforge:air", "air")
minetest.register_alias("vlf_core:powdered_snow", "vlf_powder_snow:powder_snow")


local function convert_vlfschem_to_binary(directory)
    local function process_directory(dir)
        -- Get the list of files and subdirectories in the current directory
        local files = minetest.get_dir_list(dir, false)
        local subdirs = minetest.get_dir_list(dir, true)
        
        -- Process files in the current directory
        for _, file in ipairs(files) do
            local filepath = dir .. "/" .. file
            if filepath:sub(-18) == ".gamedata.gamedata" then
                local output_file_path = filepath:gsub(".gamedata.gamedata", ".gamedata")
                
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

local function convert_vlfschem_file_to_binary(file_path)
   --[[ if file_path:sub(-18) ~= ".gamedata.gamedata" then
        return false, "Invalid file extension"
    end]]

    local output_file_path = file_path
    
    -- Attempt to open the input file in text mode
    local input_file = io.open(file_path, "r")
    if not input_file then
        return false, "Failed to open input file"
    end
    
    -- Read the input file content
    local content = input_file:read("*a")
    input_file:close()
    
    -- Attempt to deserialize the content into a Lua table
    local func, err = loadstring(content)
    if not func then
        return false, "Failed to load content: " .. (err or "Unknown error")
    end
    
    local success, data = pcall(func)
    if not success then
        return false, "Failed to execute content: " .. (data or "Unknown error")
    end
    
    -- Serialize the Lua table into binary format
    local binary_data = binser.serialize(data)
    
    -- Compress the binary data
    local compressed_data = minetest.compress(binary_data)
    
    -- Attempt to open the output file in binary mode
    local output_file = io.open(output_file_path, "wb")
    if not output_file then
        return false, "Failed to open output file"
    end
    
    -- Write the compressed binary data to the output file
    output_file:write(compressed_data)
    output_file:close()
    
    return true, "File successfully converted"
end


--convert_vlfschem_to_binary(modpath.."/data/voxelforge/structure/pillager_outpost")

 -- Custom serialization function
local function custom_serialize(value)
    if type(value) == "string" then
        return string.format("%q", value)  -- Format strings properly
    elseif type(value) == "number" then
        return tostring(value)  -- Directly convert numbers to string
    elseif type(value) == "table" then
        local table_str = "{"
        for k, v in pairs(value) do
            -- Serialize the key and value
            local key_str = custom_serialize(k)
            local value_str = custom_serialize(v)
            table_str = table_str .. string.format("[%s] = %s,", key_str, value_str)
        end
        -- Remove the trailing comma
        if table_str:sub(-1) == "," then
            table_str = table_str:sub(1, -2)
        end
        table_str = table_str .. "}"
        return table_str
    else
        return "nil"  -- Handle unexpected types
    end
end

-- Export schematic function
local function export_schematic(player, pos, size, offset, filename, save_entities)
    local start_pos = vector.add(pos, offset)
    local end_pos = vector.add(start_pos, {x = size.x - 1, y = size.y - 1, z = size.z - 1})
    local min_x, min_y, min_z = end_pos.x, end_pos.y, end_pos.z
    local max_x, max_y, max_z = start_pos.x, start_pos.y, start_pos.z
    local meta = minetest.get_meta(pos)

    local worldpath = minetest.get_worldpath()
    local file_path = worldpath .. "/generated/voxelforge/structures/" .. filename .. ".gamedata"
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
            if node.name ~= "voxelforge:temp_glass" and node.name ~= "voxelforge:schematic_editor" and meta:get_int("rb_value") == 0 then
                local meta = minetest.get_meta(node_pos):to_table().fields

                -- Manually format the metadata with type checks to ensure proper value formatting
                local formatted_metadata = "{"
                for key, value in pairs(meta) do
                    -- Check if the value is a string, and format accordingly
                    if type(value) == "string" then
                        formatted_metadata = formatted_metadata .. string.format("%s = %q,", key, value)
                    else
                        formatted_metadata = formatted_metadata .. string.format("%s = %s,", key, tostring(value))
                    end
                end
                -- Remove the trailing comma if it exists
                if formatted_metadata:sub(-1) == "," then
                    formatted_metadata = formatted_metadata:sub(1, -2)
                end
                formatted_metadata = formatted_metadata .. "}"

                -- Format the final node data
                local node_data = string.format(
                    "        {metadata = %s, name = %q, pos = {x = %d, y = %d, z = %d}, param2 = %d},\n",
                    formatted_metadata, node.name, x - start_pos.x, y - start_pos.y, z - start_pos.z,
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
if meta:get_int("ie_value") == 1 then
    file:write("    entities = {\n")
    local objects = minetest.get_objects_inside_radius(
        vector.add(start_pos, vector.divide(actual_size, 2)),
        math.max(actual_size.x, actual_size.y, actual_size.z) / 2
    )
    for _, obj in ipairs(objects) do
        if not obj:is_player() then
            local luaentity = obj:get_luaentity()
            if luaentity and luaentity.name ~= "vlf_data:border" then
                -- Manually serialize properties for each entity
                local properties_str = "{"
                for key, value in pairs(luaentity) do
                    -- Check if the value is a string, number, or table
                    local serialized_value = custom_serialize(value)
                    properties_str = properties_str .. string.format("%s = %s,", key, serialized_value)
                end

                -- Remove the trailing comma if it exists
                if properties_str:sub(-1) == "," then
                    properties_str = properties_str:sub(1, -2)
                end
                properties_str = properties_str .. "}"

                -- Write the entity data to file without any local variables or returns
                local entity_data = string.format(
                    "        {name = %q, pos = {x = %.2f, y = %.2f, z = %.2f}, properties = %s},\n",
                    luaentity.name, 
                    obj:get_pos().x - start_pos.x, 
                    obj:get_pos().y - start_pos.y, 
                    obj:get_pos().z - start_pos.z,
                    properties_str
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
    
    convert_vlfschem_file_to_binary(worldpath .. "/generated/voxelforge/structures/" .. filename .. ".gamedata")
end

minetest.register_entity(":vlf_data:border", {
	initial_properties = {
		physical = false,
		pointable = false,
		visual = "upright_sprite",
		textures = {"vlf_data_sbb.png"}, -- Default texture; will be overridden
		static_save = false,
		glow = minetest.LIGHT_MAX,
	},

	on_punch = function(self, hitter)
		if self and self.object then
			self.object:remove()
		end
	end,
	on_step = function(self)
		if self._origin_pos and minetest.get_node(self._origin_pos).name ~= "voxelforge:schematic_editor" then
			self.object:remove()
		elseif not self._origin_pos then
			self.object:remove()
		end
	end
})
local vec = vector.new


local SIDE_ROTATIONS = {
	vec(0.5 * math.pi, 0, math.pi),    -- Y+ (flip vertically)
	vec(1.5 * math.pi, 0, 0),          -- Y-
	vec(0, 1.5 * math.pi, math.pi),    -- X+ (flip horizontally)
	vec(0, 0.5 * math.pi, 0),          -- X-
	vec(0, 0, math.pi),                -- Z+ (flip horizontally)
	vec(0, math.pi, 0),                -- Z-
}

local SIDE_TEXTURES = {
	"vlf_data_sbb.png", -- Y+
	"vlf_data_sbbb.png", -- Y-
	"vlf_data_sbb.png", -- X+
	"vlf_data_sbe.png", -- X-
	"vlf_data_sbb.png", -- Z+
	"vlf_data_sbn.png", -- Z-
}


local function mark_borders(pos, size, offset)
	local start_pos = vector.add(pos, offset)
	local end_pos = vector.add(start_pos, {x = size.x - 1, y = size.y - 1, z = size.z - 1})
	local center = vector.multiply(vector.add(start_pos, end_pos), 0.5)
	local c1, c2 = vector.subtract(start_pos, 0.5 + 0.01), vector.add(end_pos, 0.5 + 0.01)
	
	-- Remove existing border entities in the area
	for _, obj in ipairs(minetest.get_objects_inside_radius(center, math.max(size.x, size.y, size.z) + 1)) do
		if obj:get_luaentity() and obj:get_luaentity().name == "vlf_data:border" then
			obj:remove()
		end
	end

	local sideCenters = {
		vec(center.x, c2.y, center.z), -- Y+
		vec(center.x, c1.y, center.z), -- Y-
		vec(c2.x, center.y, center.z), -- X+
		vec(c1.x, center.y, center.z), -- X-
		vec(center.x, center.y, c2.z), -- Z+
		vec(center.x, center.y, c1.z), -- Z-
	}

	local size_diff = vector.subtract(c2, c1)
	local sideSizes = {
		{x = size_diff.x, y = size_diff.z}, -- Y+
		{x = size_diff.x, y = size_diff.z}, -- Y-
		{x = size_diff.z, y = size_diff.y}, -- X+
		{x = size_diff.z, y = size_diff.y}, -- X-
		{x = size_diff.x, y = size_diff.y}, -- Z+
		{x = size_diff.x, y = size_diff.y}, -- Z-
	}

	local half = vector.multiply(size_diff, 0.5)
	local selectionBoxes = {
		{-half.x, -0.02, -half.z, half.x, 0, half.z}, -- Y+
		{-half.x, 0, -half.z, half.x, 0.02, half.z}, -- Y-
		{-0.02, -half.y, -half.z, 0, half.y, half.z}, -- X+
		{0, -half.y, -half.z, 0.02, half.y, half.z}, -- X-
		{-half.x, -half.y, -0.02, half.x, half.y, 0}, -- Z+
		{-half.x, -half.y, 0, half.x, half.y, 0.02}, -- Z-
	}

	local borders = {}
	for i = 1, 6 do
		local entity = minetest.add_entity(sideCenters[i], "vlf_data:border")
		entity:set_properties({
			visual_size = sideSizes[i],
			selectionbox = selectionBoxes[i],
			textures = {SIDE_TEXTURES[i]}, -- Assign specific texture for each side
		})
		local lua_entity = entity:get_luaentity()
		lua_entity._origin_pos = pos
		entity:set_rotation(SIDE_ROTATIONS[i])
		borders[i] = entity
	end

	return borders
end

local function unmark_borders(pos, size, offset)
	local start_pos = vector.add(pos, offset)
	local end_pos = vector.add(start_pos, {x = size.x - 1, y = size.y - 1, z = size.z - 1})
	local center = vector.multiply(vector.add(start_pos, end_pos), 0.5)
	local c1, c2 = vector.subtract(start_pos, 0.5 + 0.01), vector.add(end_pos, 0.5 + 0.01)

	local sideCenters = {
		vec(center.x, c2.y, center.z), -- Y+
		vec(center.x, c1.y, center.z), -- Y-
		vec(c2.x, center.y, center.z), -- X+
		vec(c1.x, center.y, center.z), -- X-
		vec(center.x, center.y, c2.z), -- Z+
		vec(center.x, center.y, c1.z), -- Z-
	}

	-- Loop over all side centers and remove entities at each position
	for i = 1, 6 do
		local center_pos = sideCenters[i]

		-- Find entities in a radius of 1 around the position
		local objects = minetest.get_objects_inside_radius(center_pos, 1)
		for _, obj in pairs(objects) do
			if obj and not obj:is_player() then
				local lua_entity = obj:get_luaentity()
				if lua_entity and lua_entity.name == "vlf_data:border" then
					obj:remove() -- Remove the entity
				end
			end
		end
	end
end

local function create_sb_model(pos, size, offset, path, name)
    local start_pos = vector.add(pos, offset)
    local end_pos = vector.add(start_pos, {x = size.x - 1, y = size.y - 1, z = size.z - 1})
    meshport.create_mesh(start_pos, end_pos, path, name)
end

-- Example usage:
local function place_temp_glass(pos, size, offset)
	mark_borders(pos, size, offset)
end


-- Add a function to remove temporary glass-like nodes
local function remove_temp_glass(pos, size, offset)
    unmark_borders(pos, size, offset)
end

--[[local function get_node_texture(node_name)
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
end]]

local function pos_to_string(pos)
    -- Convert the position to a string using minetest.pos_to_string
    local str = minetest.pos_to_string(pos)
    -- Replace commas with underscores
    str = str:gsub(",", "_")
    -- Remove parentheses
    str = str:gsub("[%(%)]", "")
    return str
end

local function reload_model_in_formspec(player_name, player, fname)
	local pmeta = player:get_meta()
	local sbm = pmeta:get_int("sbm")
    minetest.dynamic_add_media({
        filename = fname..".obj",
        filepath = minetest.get_worldpath() .. "/voxelforge/structure_block/3d_models/"..fname..".obj",
        ephemeral = true,
    }, function(name)
    end)
end
    
local function extract_textures_from_file(file_path)
    local textures = {}

    -- Open the file for reading
    local file = io.open(file_path, "r")
    if not file then
        minetest.log("error", "Failed to open file: " .. file_path)
        return nil
    end

    -- Read file line by line
    for line in file:lines() do
        -- Find all .png paths in each line
        for full_path in line:gmatch("[^%s]+%.png") do
            -- Extract the part of the path after the last "/"
            local _, _, relevant_path = full_path:find(".*%/(.-%.png)")
            if relevant_path then
                table.insert(textures, relevant_path)
            end
        end
    end

    -- Close the file
    file:close()

    -- Return the textures as a comma-separated string
    return table.concat(textures, ",")
end

local function show_sb_formspec(pos, playername, player, formspec_name, eformspec)
	local meta = minetest.get_meta(pos)
	local sx = meta:get_int("sx")
        local sy = meta:get_int("sy")
        local sz = meta:get_int("sz")
        local ox = meta:get_int("ox")
        local oy = meta:get_int("oy")
        local oz = meta:get_int("oz")
        local textures = extract_textures_from_file(minetest.get_worldpath() .. "/voxelforge/structure_block/3d_models/"..pos_to_string(pos).."_structure_block_model.mtl") or "blank.png"
        local owner = meta:get_string("owner")
        local filename = meta:get_string("filename") or "schematic"
        --[[if oz == nil then
        	meta:set_int("oz", "0")
        elseif oy == nil then
        	meta:set_int("oy", "-1")
        elseif ox == nil then
        	meta:set_int("ox", "0")
        elseif sz == nil then
        	meta:set_int("sz", "5")
        elseif sy == nil then
        	meta:set_int("sy", "5")
        elseif sx == nil then
        	meta:set_int("sx", "5")
        end]]
        local formspec = "formspec_version[4]" ..
	"size[48,27]" ..
	-- Initial Values.
	"background9[1,1;1,1;blank.png;true;7]" ..
	"style_type[image_button;border=false;bgimg=blank.png;bgimg_pressed=blank.png;bgimg_middle=2,2]"..
	"style_type[button;border=false;bgimg=blank.png;bgimg_pressed=blank.png;bgimg_middle=2,2]"..
	"style_type[field;border=false;bgimg=blank.png]"..
	"style_type[field;textcolor=#ffffff]"..
	"style_type[label;textcolor=#ffffff]"..
	"style_type[textarea;textcolor=#323232]"..
	"style_type[checkbox;textcolor=#323232]" ..
	
	-- Top
	"button_exit[0,0;0.9,0.9;back_button;<]" ..
	"label[2.8,0.4;Structure Block]" ..

    -- Left Panel
    --"background[-0.2,-0.3;28.5,20.8;sbfs.png]" ..
    "background[-0.2,-0.3;48.5,27.8;sbfs.png]" ..
    "label[1.3,2.7;Mode:]" ..
    "dropdown[1.4,3.3;10.2,2.3;mode;Save,Load,Corner,3D_Export;1]" ..
    "field[1.55,6.3;9.9,1.5;filename;;" .. filename .. "]" ..

	-- Size Field
    "label[2.8,8.4;Size:]" ..
    -- X
    "image[1.3,8.9;1.5,1.5;sbfs_X.png;]" ..
    "field[2.7,8.9;2.8,1.5;sx; ;" .. sx .. "]" ..
    -- Y
    "image[1.3,10.4;1.5,1.5;sbfs_Y.png;]" ..
    "field[2.7,10.4;2.8,1.5;sy; ;" .. sy .. "]" ..
    -- Z
    "image[1.3,12;1.5,1.5;sbfs_Z.png;]" ..
    "field[2.7,12;2.8,1.5;sz; ;" .. sz .. "]" ..
	-- Offset Field
    "label[7.8,8.4;Offset:]" ..
    -- X
    "image[6.5,8.9;1.5,1.5;sbfs_X.png;]" ..
    "field[7.8,8.9;2.8,1.5;ox; ;" .. ox .. "]" ..
    -- Y
    "image[6.5,10.4;1.5,1.5;sbfs_Y.png;]" ..
    "field[7.8,10.4;2.8,1.5;oy; ;" .. oy .. "]" ..
    -- Z
    "image[6.5,12;1.5,1.5;sbfs_Z.png;]" ..
    "field[7.8,12;2.8,1.5;oz; ;" .. oz .. "]" ..
    
    "style[detect;border=false;bgimg=sbfs_bp.png;bgimg_pressed=sbsb.png]" ..
    "button[1.4,14;9.9,1.5;detect;Detect]" ..
    
    
    "label[1.5,16;Include Entities:]" ..
    "button[2.31,16.5;2,1;toggle_ie; ]" ..
    "image[2.31,16;2,2;sbfs_scrollbar_on.png]" ..
    
   
    "label[1.5,18.15;Remove Blocks:]" ..
    "button[2.2,18.5;2,1;toggle_rb; ]" ..
    "image[2.2,18.15;2,2;sbfs_scrollbar_off.png]" ..


    "label[1.5,19.9;Redstone Save Mode]" ..
    "label[1.5,20.5;(Aesthetic Only)]" ..
    "dropdown[1.4,21.1;10.2,2.3;redstone_mode;Save In Memory,Save To Disk;1]" ..

    "label[1.5,24.2;Show Bounding Box:]" ..
    "button[2.31,24.9;2,1;toggle_bbox; ]" ..
    "image[2.31,24.55;2,2;sbfs_scrollbar_on.png]" ..

    -- Right Panel (3D Model Preview and Buttons)
"model[13.3,2.25;34,20.3;obj;"..pos_to_string(pos).."_structure_block_model.obj;"..textures..";0,0;false;true]" ..
    
    -- Bottom Buttons
    "style[save;border=false;bgimg=sbfs_bp.png;bgimg_pressed=sbsb.png]" ..
    "button[13.35,24.15;10.25,2.2;save;Save]" ..
    
    "style[export;border=false;bgimg=sbfs_bp.png;bgimg_pressed=sbsb.png]" ..
    "button[23.8,24.15;10.55,2.2;export;Export]" ..
    
    "style[reset;border=false;bgimg=sbfs_bp.png;bgimg_pressed=sbsb.png]" ..
    "button[34.6,24.15;10.25,2.2;reset;Reset]"
        if eformspec ~= nil then formspec = formspec .. eformspec else formspec = formspec end
    
    minetest.show_formspec(playername, formspec_name, formspec)
end

local function show_sb_load_formspec(pos, playername, player, formspec_name, eformspec)
	local meta = minetest.get_meta(pos)
        local ox = meta:get_int("ox")
        local oy = meta:get_int("oy")
        local oz = meta:get_int("oz")
        local textures = extract_textures_from_file(minetest.get_worldpath() .. "/voxelforge/structure_block/3d_models/"..pos_to_string(pos).."_structure_block_model.mtl") or "blank.png"
        local filename = meta:get_string("filename") or "schematic"
        local si = meta:get_int("si") or 100
        local seed = meta:get_string("seed")
        local at = meta:get_int("at")
        local formspec = "formspec_version[4]" ..
	"size[48,27]" ..
	-- Initial Values.
	"background9[1,1;1,1;blank.png;true;7]" ..
	"style_type[image_button;border=false;bgimg=blank.png;bgimg_pressed=blank.png;bgimg_middle=2,2]"..
	"style_type[button;border=false;bgimg=blank.png;bgimg_pressed=blank.png;bgimg_middle=2,2]"..
	"style_type[field;border=false;bgimg=blank.png]"..
	"style_type[field;textcolor=#ffffff]"..
	"style_type[label;textcolor=#ffffff]"..
	"style_type[textarea;textcolor=#323232]"..
	"style_type[checkbox;textcolor=#323232]" ..
	
	-- Top
	"button_exit[0,0;0.9,0.9;back_button;<]" ..
	"label[2.8,0.4;Structure Block]" ..

    -- Left Panel
    "scrollbaroptions[min=0;max=" .. 8 .. ";smallstep=1;arrows=hide]" ..
    "scrollbar[11.75,0.48;6,0.75;horizontal;Load_Bar;0]" ..
    "image[11.75,0.48;6,0.75;sbfs_overlay.png]" ..

    -- Right Panel (3D Model Preview and Buttons)
"model[13.3,2.25;34,20.3;obj;"..pos_to_string(pos).."_structure_block_model.obj;"..textures..";0,0;false;true]" ..
    
    -- Bottom Buttons
    "style[load;border=false;bgimg=sbfs_bp.png;bgimg_pressed=sbsb.png]" ..
    "button[13.35,24.15;10.25,2.2;load;Load]" ..
    
    "style[export;border=false;bgimg=sbfs_bp.png;bgimg_pressed=sbsb.png]" ..
    "button[23.8,24.15;10.55,2.2;export;Export]" ..
    
    "style[reset;border=false;bgimg=sbfs_bp.png;bgimg_pressed=sbsb.png]" ..
    "button[34.6,24.15;10.25,2.2;reset;Reset]" ..
    
    
    "background[-0.2,-0.3;48.5,27.8;sbfs_load.png]" ..
    "scroll_container[1,2.3;11,24.2;Load_Bar;vertical;1.25]" ..
    "label[0.3,0.4;Mode:]" ..
    "dropdown[0.4,1;9.5,2.3;mode;Save,Load,Corner,3D_Export;2]" ..
    "image[0.55,4;9.2,1.5;sbfs_field.png;]" ..
    "field[0.55,4;9.2,1.5;filename;;" .. filename .. "]" ..

	-- Offset Field
    "label[4,6.1;Offset:]" ..
    -- X
    
    "image[0.3,6.6;1.5,1.5;sbfs_X.png;]" ..
    "image[0.3,8.1;1.5,1.5;sbfs_Y.png;]" ..
    "image[0.3,9.7;1.5,1.5;sbfs_Z.png;]" ..
    -- X
    "image[1.7,6.66;7.9,1.4;sbfs_field.png;]" ..
    "field[1.7,6.66;7.9,1.4;ox; ;" .. ox .. "]" ..
    "image[1.7,8.1;7.9,1.5;sbfs_field.png;]" ..
    "field[1.7,8.1;7.9,1.5;oy; ;" .. oy .. "]" ..
    "image[1.7,9.7;7.9,1.5;sbfs_field.png;]" ..
    "field[1.7,9.7;7.9,1.5;oz; ;" .. oz .. "]" ..
    
    
    "label[0.4,11.9;Include Entities:]" ..
    "button[1.31,11.9;2,1;toggle_ie; ]" ..
    "image[1.31,11.9;2,2;sbfs_scrollbar_on.png]" ..
    
   
    "label[0.5,14.35;Remove Blocks:]" ..
    "button[1.2,14.35.15;2,1;toggle_rb; ]" ..
    "image[1.2,14.35;2,2;sbfs_scrollbar_off.png]" ..
    
    "label[0.3,16.8;Integrity:]" ..
    "image[0.45,17.2;9.2,1.5;sbfs_field.png;]" ..
    "field[0.45,17.2;9.2,1.5;si;;" .. si .. "]" ..

    "label[0.3,19.5;Seed:]" ..
    "image[0.45,19.9;9.2,1.5;sbfs_field.png;]" ..
    "field[0.45,19.9;9.2,1.5;si;;" .. seed .. "]" ..
    
    "label[0.3,22;Rotation:]" ..
    "image[0.4,22.4;9.3,1.5;sbfs_scrollbar_long.png]" ..
    "image[0.4,22.4;1.5,1.5;sbfs_scrollbar_indicator.png]" ..
    
    "label[0.3,24.5;Mirror:]" ..
    "image[0.8,24.6;1.225,1.225;sbfs_X.png;]" ..
    "checkbox[1.8,25.2;mirror_x; ;0]" ..
    "image[2.25,24.6;1.225,1.225;sbfs_Z.png;]" ..
    "checkbox[3.25,25.2;mirror_x; ;0]" ..
    
    "label[0.3,26;Animation Mode:]" ..
    "dropdown[0.4,26.6;9.5,2.3;animation_mode;None,Layer By Layer,Block By Block;1]" ..
    
    "label[0.3,29.5;Animation Time:]" ..
    "image[0.45,29.9;9.2,1.5;sbfs_field.png;]" ..
    "field[0.45,29.9;9.2,1.5;at;;" .. at .. "]" ..


    "label[0.3,31.9;Show Bounding Box:]" ..
    "button[0.81,32.8;2,1;toggle_bbox; ]" ..
    "image[0.81,32.35;2,2;sbfs_scrollbar_on.png]"
    --"scroll_container_end[]"
    
        if eformspec ~= nil then formspec = formspec .. eformspec else formspec = formspec end
    
    minetest.show_formspec(playername, formspec_name, formspec)
end

local function show_sb_corner_formspec(pos, playername, player, formspec_name, eformspec)
	local meta = minetest.get_meta(pos)
        local ox = meta:get_int("ox")
        local oy = meta:get_int("oy")
        local oz = meta:get_int("oz")
        local textures = extract_textures_from_file(minetest.get_worldpath() .. "/voxelforge/structure_block/3d_models/"..pos_to_string(pos).."_structure_block_model.mtl") or "blank.png"
        local filename = meta:get_string("filename") or "schematic"
        local si = meta:get_int("si") or 100
        local seed = meta:get_string("seed")
        local at = meta:get_int("at")
        local formspec = "formspec_version[4]" ..
	"size[15,7.5]" ..
	-- Initial Values.
	"background9[1,1;1,1;blank.png;true;7]" ..
	"style_type[image_button;border=false;bgimg=blank.png;bgimg_pressed=blank.png;bgimg_middle=2,2]"..
	"style_type[button;border=false;bgimg=blank.png;bgimg_pressed=blank.png;bgimg_middle=2,2]"..
	"style_type[field;border=false;bgimg=blank.png]"..
	"style_type[field;textcolor=#ffffff]"..
	"style_type[label;textcolor=#ffffff]"..
	"style_type[textarea;textcolor=#323232]"..
	"style_type[checkbox;textcolor=#323232]" ..
	
	-- Top
	"button_exit[-0.2,-0.4;0.9,0.9;back_button;<]" ..
	"label[1.2,0.1;Structure Block]" ..
	
	"background[-0.2,-0.3;15.5,8.3;sbfs_corner.png]" ..
	"label[0.5,1.2;Mode:]" ..
	"dropdown[0.5,1.49;4.9,1.1;mode;Save,Load,Corner,3D_Export;3]" ..
	"field[0.6,3;4.8,0.8;filename;;" .. filename .. "]" ..
	"label[6.4,1.2;Corner Mode:]" ..
	"label[6.4,1.7;Corner Mode is used with the Detect]" ..
	"label[6.4,2.1;button in Save Mode to define the area]" ..
	"label[6.4,2.5;to save. It will only detect Corner]" ..
	"label[6.4,2.9;Blocks with the same name as the struc-]" ..
	"label[6.4,3.3;ture being saved.]"

        if eformspec ~= nil then formspec = formspec .. eformspec else formspec = formspec end
    
    minetest.show_formspec(playername, formspec_name, formspec)
end

local function show_sb_export_formspec(pos, playername, player, formspec_name, eformspec)
	local meta = minetest.get_meta(pos)
	local sx = meta:get_int("sx")
        local sy = meta:get_int("sy")
        local sz = meta:get_int("sz")
        local ox = meta:get_int("ox")
        local oy = meta:get_int("oy")
        local oz = meta:get_int("oz")
        local textures = extract_textures_from_file(minetest.get_worldpath() .. "/voxelforge/structure_block/3d_models/"..pos_to_string(pos).."_structure_block_model.mtl") or "blank.png"
        local owner = meta:get_string("owner")
        local filename = meta:get_string("filename") or "schematic"
        local formspec = "formspec_version[4]" ..
	"size[48,27]" ..
	-- Initial Values.
	"background9[1,1;1,1;blank.png;true;7]" ..
	"style_type[image_button;border=false;bgimg=blank.png;bgimg_pressed=blank.png;bgimg_middle=2,2]"..
	"style_type[button;border=false;bgimg=blank.png;bgimg_pressed=blank.png;bgimg_middle=2,2]"..
	"style_type[field;border=false;bgimg=blank.png]"..
	"style_type[field;textcolor=#ffffff]"..
	"style_type[label;textcolor=#ffffff]"..
	"style_type[textarea;textcolor=#323232]"..
	"style_type[checkbox;textcolor=#323232]" ..
	
	-- Top
	"button_exit[0,0;0.9,0.9;back_button;<]" ..
	"label[2.8,0.4;Structure Block]" ..

    -- Left Panel
    "background[-0.2,-0.3;48.5,27.8;sbfs_export.png]" ..
    "label[1.3,2.7;Mode:]" ..
    "dropdown[1.4,3.3;10.2,2.3;mode;Save,Load,Corner,3D_Export;4]" ..
    "field[1.55,6.3;9.9,1.5;filename;;" .. filename .. "]" ..

	-- Size Field
    "label[2.8,8.4;Size:]" ..
    -- X
    "image[1.3,8.9;1.5,1.5;sbfs_X.png;]" ..
    "field[2.7,8.9;2.8,1.5;sx; ;" .. sx .. "]" ..
    -- Y
    "image[1.3,10.4;1.5,1.5;sbfs_Y.png;]" ..
    "field[2.7,10.4;2.8,1.5;sy; ;" .. sy .. "]" ..
    -- Z
    "image[1.3,12;1.5,1.5;sbfs_Z.png;]" ..
    "field[2.7,12;2.8,1.5;sz; ;" .. sz .. "]" ..
	-- Offset Field
    "label[7.8,8.4;Offset:]" ..
    -- X
    "image[6.5,8.9;1.5,1.5;sbfs_X.png;]" ..
    "field[7.8,8.9;2.8,1.5;ox; ;" .. ox .. "]" ..
    -- Y
    "image[6.5,10.4;1.5,1.5;sbfs_Y.png;]" ..
    "field[7.8,10.4;2.8,1.5;oy; ;" .. oy .. "]" ..
    -- Z
    "image[6.5,12;1.5,1.5;sbfs_Z.png;]" ..
    "field[7.8,12;2.8,1.5;oz; ;" .. oz .. "]" ..
    
   
    "label[1.5,14.3;Remove Blocks:]" ..
    "button[2.2,14.8;2,1;toggle_rb; ]" ..
    "image[2.2,14.5;2,2;sbfs_scrollbar_off.png]" ..


    "label[1.5,16.85;Show Bounding Box:]" ..
    "button[2.31,17.15;2,1;toggle_bbox; ]" ..
    "image[2.31,16.85;2,2;sbfs_scrollbar_on.png]" ..

    -- Right Panel (3D Model Preview and Buttons)
"model[13.3,2.25;34,20.3;obj;"..pos_to_string(pos).."_structure_block_model.obj;"..textures..";0,0;false;true]" ..
    
    
    "style[export;border=false;bgimg=sbfs_bp.png;bgimg_pressed=sbsb.png]" ..
    "button[13.3,24.15;15.65,2.2;threedexport;Export]" ..
    
    "style[reset;border=false;bgimg=sbfs_bp.png;bgimg_pressed=sbsb.png]" ..
    "button[29.2,24.15;15.65,2.2;reset;Reset]"
        if eformspec ~= nil then formspec = formspec .. eformspec else formspec = formspec end
    
    minetest.show_formspec(playername, formspec_name, formspec)
end

local function find_and_execute_with_sb_model(pos, search_size, name)
    -- Calculate the max search boundary
    local maxp = vector.add(pos, search_size)
    local valid_positions = {}
    local meta1 = minetest.get_meta(pos)

    -- Loop through the defined region to collect valid positions
    for x = pos.x, maxp.x - 1 do
        for y = pos.y, maxp.y - 1 do
            for z = pos.z, maxp.z - 1 do
                local current_pos = {x = x, y = y, z = z}
                local node = minetest.get_node_or_nil(current_pos)

                if node and node.name == "voxelforge:schematic_editor" then
                    local meta = minetest.get_meta(current_pos)
                    if meta:get_string("filename") == name and meta:get_string("mode") == "Corner" then
                        table.insert(valid_positions, current_pos)
                    end
                end
            end
        end
    end

    -- Abort if more than 2 blocks are found
    if #valid_positions > 2 then
    	minetest.log("error", "Structure block at: " .. tostring(pos) .. " . Attempted to detect the size from more than two possible blocks. This action is not supported.")
        return
    end

    -- If only one valid block is found, calculate size from pos to that block with offset = 0
    if #valid_positions == 1 then
        local end_pos = valid_positions[1]
        local size = {
            x = math.abs(end_pos.x - pos.x) + 1,
            y = math.abs(end_pos.y - pos.y) + 1,
            z = math.abs(end_pos.z - pos.z) + 1
        }
        local offset = {x = 0, y = 0, z = 0} -- Offset is zero

        -- Execute the create_sb_model command
        create_sb_model(
            pos,
            size,
            offset,
            minetest.get_worldpath() .. "/voxelforge/structure_block/3d_models",
            minetest.pos_to_string(pos) .. "_structure_block_model"
        )
        place_temp_glass(pos, size, offset)
        meta1:set_int("sx", size.x)
    meta1:set_int("sy", size.y)
    meta1:set_int("sz", size.z)
    meta1:set_int("ox", offset.x)
    meta1:set_int("oy", offset.y)
    meta1:set_int("oz", offset.z)
        return
    end

    -- If exactly two valid blocks are found, find the closest and farthest blocks
    if #valid_positions == 2 then
        -- Sort blocks by distance from pos
        table.sort(valid_positions, function(a, b)
            return vector.distance(pos, a) < vector.distance(pos, b)
        end)

        local start_pos = valid_positions[1]  -- Closest block
        local end_pos = valid_positions[#valid_positions]  -- Farthest block

        -- Abort if start_pos is above end_pos in Y-axis
        if start_pos.y > end_pos.y then
            return
        end

        -- Calculate size and offset
        local size = {
            x = math.abs(end_pos.x - start_pos.x) + 1,
            y = math.abs(end_pos.y - start_pos.y) + 1,
            z = math.abs(end_pos.z - start_pos.z) + 1
        }
        local offset = {
            x = start_pos.x - pos.x,
            y = start_pos.y - pos.y,
            z = start_pos.z - pos.z
        }

        -- Execute the create_sb_model command
        create_sb_model(
            start_pos,
            size,
            offset,
            minetest.get_worldpath() .. "/voxelforge/structure_block/3d_models",
            minetest.pos_to_string(start_pos) .. "_structure_block_model"
        )
        place_temp_glass(pos, size, offset)
        meta1:set_int("sx", size.x)
	meta1:set_int("sy", size.y)
	meta1:set_int("sz", size.z)
	meta1:set_int("ox", offset.x)
	meta1:set_int("oy", offset.y)
	meta1:set_int("oz", offset.z)
    end
end





minetest.register_node(":voxelforge:schematic_editor", {
    description = "Schematic Editor",
    tiles = {"default_stone.png"},
    groups = {cracky = 3, oddly_breakable_by_hand = 3},
    on_construct = function(pos, node)
    	local meta = minetest.get_meta(pos)
        place_temp_glass(pos, {
			x = 5, y = 5, z = 5
		}, {
			x = 0, y = -1, z = 0
		})
	create_sb_model(pos, {
			x = 5, y = 5, z = 5
		}, {
			x = 0, y = -1, z = 0
		}, minetest.get_worldpath() .. "/voxelforge/structure_block/3d_models", pos_to_string(pos) .. "_structure_block_model")
	end,
	on_destruct = function(pos)
		create_sb_model(pos, {
			x = 0, y = 0, z = 0
		}, {
			x = 0, y = 0, z = 0
		}, minetest.get_worldpath() .. "/voxelforge/structure_block/3d_models", pos_to_string(pos) .. "_structure_block_model")
	end,
    on_rightclick = function(pos, node, player, itemstack, pointed_thing)
        local meta = minetest.get_meta(pos)
        local pmeta = player:get_meta()
        meta:set_string("owner", player:get_player_name())
        local owner = meta:get_string("owner")
        local filename = meta:get_string("filename") or "schematic"
	reload_model_in_formspec(player:get_player_name(), player, pos_to_string(pos) .. "_structure_block_model")
	if meta:get_string("mode") == "Save" then
        	show_sb_formspec(pos, player:get_player_name(), player, "voxelforge:schematic_editor", nil)
        elseif meta:get_string("mode") == "Load" then
        	show_sb_load_formspec(pos, player:get_player_name(), player, "voxelforge:schematic_editor", "scroll_container_end[]")
        elseif meta:get_string("mode") == "Corner" then
        	show_sb_corner_formspec(pos, player:get_player_name(), player, "voxelforge:schematic_editor", nil)
        elseif meta:get_string("mode") == "Export" then
        	show_sb_export_formspec(pos, player:get_player_name(), player, "voxelforge:schematic_editor", nil)
	else
        	show_sb_formspec(pos, player:get_player_name(), player, "voxelforge:schematic_editor", nil)
        end
    end,
})

-- Updated Handle formspec input
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
        --local ie_value = 
        local rb_value = tonumber(fields.rb) or meta:get_int("rb_value")

        -- Save settings to node meta
        meta:set_int("sx", sx)
        meta:set_int("sy", sy)
        meta:set_int("sz", sz)
        meta:set_int("ox", ox)
        meta:set_int("oy", oy)
        meta:set_int("oz", oz)
        --meta:set_int("ie_value", ie_value)
        --meta:set_int("rb_value", rb_value)
        meta:set_string("filename", filename)
        
        
        if meta:get_string("mode") == "Save" then
        -- bbox Value off-on, ie_value On, rb_value Off
        if fields.toggle_bbox and meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 0 then
            place_temp_glass(pos, {x = sx, y = sy, z = sz}, {x = ox, y = oy, z = oz})  -- Place temp glass
            meta:set_int("bbox_value", "1")
            show_sb_formspec(pos, name, player, "voxelforge:schematic_editor", nil)
            return
        end
        if fields.toggle_bbox and meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 1 then
            local fsbbox = "image[2.31,24.55;2,2;sbfs_scrollbar_off.png]"
            remove_temp_glass(pos, {x = sx, y = sy, z = sz}, {x = ox, y = oy, z = oz})  -- Place temp glass
            meta:set_int("bbox_value", "0")
            show_sb_formspec(pos, name, player, "voxelforge:schematic_editor", fsbbox)
            return
            -- bbox Value off-on, ie_value Off, rb_value Off
	end
	if fields.toggle_bbox and meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 0 then
            local fsbboxio = "image[2.31,16;2,2;sbfs_scrollbar_off.png]"
            place_temp_glass(pos, {x = sx, y = sy, z = sz}, {x = ox, y = oy, z = oz})  -- Place temp glass
            meta:set_int("bbox_value", "1")
            show_sb_formspec(pos, name, player, "voxelforge:schematic_editor", fsbboxio)
            return
        end
        if fields.toggle_bbox and meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 1 then
            local fsbboxoio = "image[2.31,16;2,2;sbfs_scrollbar_off.png]" .. "image[2.31,24.55;2,2;sbfs_scrollbar_off.png]"
            unmark_borders(pos, {x = sx, y = sy, z = sz}, {x = ox, y = oy, z = oz})  -- Place temp glass
            meta:set_int("bbox_value", "0")
            show_sb_formspec(pos, name, player, "voxelforge:schematic_editor", fsbboxoio)
            return
        -- bbox Value off-on, ie_value Off, rb_value On
        end
        if fields.toggle_bbox and meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 0 then
            local fsbboxro = "image[2.31,16;2,2;sbfs_scrollbar_off.png]" .. "image[2.2,18.15;2,2;sbfs_scrollbar_on.png]"
            place_temp_glass(pos, {x = sx, y = sy, z = sz}, {x = ox, y = oy, z = oz})  -- Place temp glass
            meta:set_int("bbox_value", "1")
            show_sb_formspec(pos, name, player, "voxelforge:schematic_editor", fsbboxro)
            return
        end
        if fields.toggle_bbox and meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 1 then
            local fsbboxoro = "image[2.31,16;2,2;sbfs_scrollbar_off.png]" .. "image[2.31,24.55;2,2;sbfs_scrollbar_off.png]" .. "image[2.2,18.15;2,2;sbfs_scrollbar_on.png]"
            remove_temp_glass(pos, {x = sx, y = sy, z = sz}, {x = ox, y = oy, z = oz})  -- Place temp glass
            meta:set_int("bbox_value", "0")
            show_sb_formspec(pos, name, player, "voxelforge:schematic_editor", fsbboxoro)
            return
        -- bbox Value off-on, ie_value On, rb_value On
        end
        if fields.toggle_bbox and meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 0 then
            local fsbboxioro = "image[2.2,18.15;2,2;sbfs_scrollbar_on.png]"
            place_temp_glass(pos, {x = sx, y = sy, z = sz}, {x = ox, y = oy, z = oz})  -- Place temp glass
            meta:set_int("bbox_value", "1")
            show_sb_formspec(pos, name, player, "voxelforge:schematic_editor", fsbboxioro)
            return
        end
        if fields.toggle_bbox and meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 1 then
            local fsbboxoiro = "image[2.31,24.55;2,2;sbfs_scrollbar_off.png]" .. "image[2.2,18.15;2,2;sbfs_scrollbar_on.png]"
            remove_temp_glass(pos, {x = sx, y = sy, z = sz}, {x = ox, y = oy, z = oz})  -- Place temp glass
            meta:set_int("bbox_value", "0")
            show_sb_formspec(pos, name, player, "voxelforge:schematic_editor", fsbboxoiro)
            return
        -- ie Value off-on, rb_value Off, bbox_value On
        end
        if fields.toggle_ie and meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 1 then
            meta:set_int("ie_value", "1")
            show_sb_formspec(pos, name, player, "voxelforge:schematic_editor", nil)
            return
        end
        if fields.toggle_ie and meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 1 then
            local fsieone = "image[2.31,16;2,2;sbfs_scrollbar_off.png]"
            meta:set_int("ie_value", "0")
            show_sb_formspec(pos, name, player, "voxelforge:schematic_editor", fsieone.."scroll_container_end[]")
            return
        -- ie Value off-on, rb_value Off, bbox_value Off
        end
        if fields.toggle_ie and meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 0 then
            local fsietwo = "image[2.31,24.55;2,2;sbfs_scrollbar_off.png]"
            meta:set_int("ie_value", "1")
            show_sb_formspec(pos, name, player, "voxelforge:schematic_editor", fsietwo)
            return
        end
        if fields.toggle_ie and meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 0 then
            local fsiethree = "image[2.31,16;2,2;sbfs_scrollbar_off.png]" .. "image[2.31,24.55;2,2;sbfs_scrollbar_off.png]"
            meta:set_int("ie_value", "0")
            show_sb_formspec(pos, name, player, "voxelforge:schematic_editor", fsiethree)
            return
        -- ie Value off-on, rb_value On, bbox_value Off
        end
        if fields.toggle_ie and meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 0 then
            local fsiefour = "image[2.31,24.55;2,2;sbfs_scrollbar_off.png]" .. "image[2.2,18.15;2,2;sbfs_scrollbar_on.png]"
            meta:set_int("ie_value", "1")
            show_sb_formspec(pos, name, player, "voxelforge:schematic_editor", fsiefour)
            return
        end
        if fields.toggle_ie and meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 0 then
            local fsiefive = "image[2.31,16;2,2;sbfs_scrollbar_off.png]" .. "image[2.31,24.55;2,2;sbfs_scrollbar_off.png]" .. "image[2.2,18.15;2,2;sbfs_scrollbar_on.png]"
            meta:set_int("ie_value", "0")
            show_sb_formspec(pos, name, player, "voxelforge:schematic_editor", fsiefive)
            return
        -- ie Value off-on, rb_value On, bbox_value On
        end
        if fields.toggle_ie and meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 1 then
            local fsiesix = "image[2.2,18.15;2,2;sbfs_scrollbar_on.png]"
            meta:set_int("ie_value", "1")
            show_sb_formspec(pos, name, player, "voxelforge:schematic_editor", fsiesix)
            return
        end
        if fields.toggle_ie and meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 1 then
            local fsieseven = "image[2.31,16;2,2;sbfs_scrollbar_off.png]" .. "image[2.2,18.15;2,2;sbfs_scrollbar_on.png]"
            meta:set_int("ie_value", "0")
            show_sb_formspec(pos, name, player, "voxelforge:schematic_editor", fsieseven)
            return
        -- rb Value off-on, ie_value Off, bbox_value On
        end
        if fields.toggle_rb and meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 1 then
	    local fsrb = "image[2.31,16;2,2;sbfs_scrollbar_off.png]" .. "image[2.2,18.15;2,2;sbfs_scrollbar_on.png]"
            meta:set_int("rb_value", "1")
            show_sb_formspec(pos, name, player, "voxelforge:schematic_editor", fsrb)
            return
        end
        if fields.toggle_rb and meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 1 then
            local fsrbone = "image[2.31,16;2,2;sbfs_scrollbar_off.png]"
            meta:set_int("rb_value", "0")
            show_sb_formspec(pos, name, player, "voxelforge:schematic_editor", fsrbone)
            return
        -- rb Value off-on, ie_value Off, bbox_value Off
        end
        if fields.toggle_rb and meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 0 then
	    local fsrbtwo = "image[2.31,16;2,2;sbfs_scrollbar_off.png]" .. "image[2.2,18.15;2,2;sbfs_scrollbar_on.png]" .. "image[2.31,24.55;2,2;sbfs_scrollbar_off.png]"
            meta:set_int("rb_value", "1")
            show_sb_formspec(pos, name, player, "voxelforge:schematic_editor", fsrbtwo)
            return
        end
        if fields.toggle_rb and meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 0 then
            local fsrbthree = "image[2.31,16;2,2;sbfs_scrollbar_off.png]" .. "image[2.31,24.55;2,2;sbfs_scrollbar_off.png]"
            meta:set_int("rb_value", "0")
            show_sb_formspec(pos, name, player, "voxelforge:schematic_editor", fsrbthree)
            return
        -- rb Value off-on, ie_value On, bbox_value Off
        end
        if fields.toggle_rb and meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 0 then
	    local fsrbfour = "image[2.2,18.15;2,2;sbfs_scrollbar_on.png]" .. "image[2.31,24.55;2,2;sbfs_scrollbar_off.png]"
            meta:set_int("rb_value", "1")
            show_sb_formspec(pos, name, player, "voxelforge:schematic_editor", fsrbfour)
            return
        end
        if fields.toggle_rb and meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 0 then
            local fsrbfive = "image[2.31,24.55;2,2;sbfs_scrollbar_off.png]"
            meta:set_int("rb_value", "0")
            show_sb_formspec(pos, name, player, "voxelforge:schematic_editor", fsrbfive)
            return
        -- rb Value off-on, ie_value On, bbox_value On
        end
        if fields.toggle_rb and meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 1 then
	    local fsrbsix = "image[2.2,18.15;2,2;sbfs_scrollbar_on.png]"
            meta:set_int("rb_value", "1")
            show_sb_formspec(pos, name, player, "voxelforge:schematic_editor", fsrbsix)
            return
        end
        if fields.toggle_rb and meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 1 then
            meta:set_int("rb_value", "0")
            show_sb_formspec(pos, name, player, "voxelforge:schematic_editor", nil)
            return
        end
        end
        
        
        
        
        if meta:get_string("mode") == "Load" then
        -- bbox Value off-on, ie_value On, rb_value Off
        if fields.toggle_bbox and meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 0 then
            place_temp_glass(pos, {x = sx, y = sy, z = sz}, {x = ox, y = oy, z = oz})  -- Place temp glass
            meta:set_int("bbox_value", "1")
            show_sb_load_formspec(pos, name, player, "voxelforge:schematic_editor", "scroll_container_end[]")
            return
        end
        if fields.toggle_bbox and meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 1 then
            local fsbbox = "image[0.81,32.35;2,2;sbfs_scrollbar_off.png]"
            remove_temp_glass(pos, {x = sx, y = sy, z = sz}, {x = ox, y = oy, z = oz})  -- Place temp glass
            meta:set_int("bbox_value", "0")
            show_sb_load_formspec(pos, name, player, "voxelforge:schematic_editor", fsbbox.."scroll_container_end[]")
            return
            -- bbox Value off-on, ie_value Off, rb_value Off
	end
	if fields.toggle_bbox and meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 0 then
            local fsbboxio = "image[1.31,11.9;2,2;sbfs_scrollbar_off.png]"
            place_temp_glass(pos, {x = sx, y = sy, z = sz}, {x = ox, y = oy, z = oz})  -- Place temp glass
            meta:set_int("bbox_value", "1")
            show_sb_load_formspec(pos, name, player, "voxelforge:schematic_editor", fsbboxio.."scroll_container_end[]")
            return
        end
        if fields.toggle_bbox and meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 1 then
            local fsbboxoio = "image[1.31,11.9;2,2;sbfs_scrollbar_off.png]" .. "image[0.81,32.35;2,2;sbfs_scrollbar_off.png]"
            unmark_borders(pos, {x = sx, y = sy, z = sz}, {x = ox, y = oy, z = oz})  -- Place temp glass
            meta:set_int("bbox_value", "0")
            show_sb_load_formspec(pos, name, player, "voxelforge:schematic_editor", fsbboxoio.."scroll_container_end[]")
            return
        -- bbox Value off-on, ie_value Off, rb_value On
        end
        if fields.toggle_bbox and meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 0 then
            local fsbboxro = "image[1.31,11.9;2,2;sbfs_scrollbar_off.png]" .. "image[1.2,14.35;2,2;sbfs_scrollbar_on.png]"
            place_temp_glass(pos, {x = sx, y = sy, z = sz}, {x = ox, y = oy, z = oz})  -- Place temp glass
            meta:set_int("bbox_value", "1")
            show_sb_load_formspec(pos, name, player, "voxelforge:schematic_editor", fsbboxro.."scroll_container_end[]")
            return
        end
        if fields.toggle_bbox and meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 1 then
            local fsbboxoro = "image[1.31,11.9;2,2;sbfs_scrollbar_off.png]" .. "image[0.81,32.35;2,2;sbfs_scrollbar_off.png]" .. "image[1.2,14.35;2,2;sbfs_scrollbar_on.png]"
            remove_temp_glass(pos, {x = sx, y = sy, z = sz}, {x = ox, y = oy, z = oz})  -- Place temp glass
            meta:set_int("bbox_value", "0")
            show_sb_load_formspec(pos, name, player, "voxelforge:schematic_editor", fsbboxoro.."scroll_container_end[]")
            return
        -- bbox Value off-on, ie_value On, rb_value On
        end
        if fields.toggle_bbox and meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 0 then
            local fsbboxioro = "image[1.2,14.35;2,2;sbfs_scrollbar_on.png]"
            place_temp_glass(pos, {x = sx, y = sy, z = sz}, {x = ox, y = oy, z = oz})  -- Place temp glass
            meta:set_int("bbox_value", "1")
            show_sb_load_formspec(pos, name, player, "voxelforge:schematic_editor", fsbboxioro.."scroll_container_end[]")
            return
        end
        if fields.toggle_bbox and meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 1 then
            local fsbboxoiro = "image[0.81,32.35;2,2;sbfs_scrollbar_off.png]" .. "image[1.2,14.35;2,2;sbfs_scrollbar_on.png]"
            remove_temp_glass(pos, {x = sx, y = sy, z = sz}, {x = ox, y = oy, z = oz})  -- Place temp glass
            meta:set_int("bbox_value", "0")
            show_sb_load_formspec(pos, name, player, "voxelforge:schematic_editor", fsbboxoiro.."scroll_container_end[]")
            return
        -- ie Value off-on, rb_value Off, bbox_value On
        end
        if fields.toggle_ie and meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 1 then
            meta:set_int("ie_value", "1")
            show_sb_load_formspec(pos, name, player, "voxelforge:schematic_editor", "scroll_container_end[]")
            return
        end
        if fields.toggle_ie and meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 1 then
            local fsieone = "image[1.31,11.9;2,2;sbfs_scrollbar_off.png]"
            meta:set_int("ie_value", "0")
            show_sb_load_formspec(pos, name, player, "voxelforge:schematic_editor", fsieone.."scroll_container_end[]")
            return
        -- ie Value off-on, rb_value Off, bbox_value Off
        end
        if fields.toggle_ie and meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 0 then
            local fsietwo = "image[0.81,32.35;2,2;sbfs_scrollbar_off.png]"
            meta:set_int("ie_value", "1")
            show_sb_load_formspec(pos, name, player, "voxelforge:schematic_editor", fsietwo.."scroll_container_end[]")
            return
        end
        if fields.toggle_ie and meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 0 then
            local fsiethree = "image[1.31,11.9;2,2;sbfs_scrollbar_off.png]" .. "image[0.81,32.35;2,2;sbfs_scrollbar_off.png]"
            meta:set_int("ie_value", "0")
            show_sb_load_formspec(pos, name, player, "voxelforge:schematic_editor", fsiethree.."scroll_container_end[]")
            return
        -- ie Value off-on, rb_value On, bbox_value Off
        end
        if fields.toggle_ie and meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 0 then
            local fsiefour = "image[0.81,32.35;2,2;sbfs_scrollbar_off.png]" .. "image[1.2,14.35;2,2;sbfs_scrollbar_on.png]"
            meta:set_int("ie_value", "1")
            show_sb_load_formspec(pos, name, player, "voxelforge:schematic_editor", fsiefour.."scroll_container_end[]")
            return
        end
        if fields.toggle_ie and meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 0 then
            local fsiefive = "image[1.31,11.9;2,2;sbfs_scrollbar_off.png]" .. "image[0.81,32.35;2,2;sbfs_scrollbar_off.png]" .. "image[1.2,14.35;2,2;sbfs_scrollbar_on.png]"
            meta:set_int("ie_value", "0")
            show_sb_load_formspec(pos, name, player, "voxelforge:schematic_editor", fsiefive.."scroll_container_end[]")
            return
        -- ie Value off-on, rb_value On, bbox_value On
        end
        if fields.toggle_ie and meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 1 then
            local fsiesix = "image[1.2,14.35;2,2;sbfs_scrollbar_on.png]"
            meta:set_int("ie_value", "1")
            show_sb_load_formspec(pos, name, player, "voxelforge:schematic_editor", fsiesix.."scroll_container_end[]")
            return
        end
        if fields.toggle_ie and meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 1 then
            local fsieseven = "image[1.31,11.9;2,2;sbfs_scrollbar_off.png]" .. "image[1.2,14.35;2,2;sbfs_scrollbar_on.png]"
            meta:set_int("ie_value", "0")
            show_sb_load_formspec(pos, name, player, "voxelforge:schematic_editor", fsieseven.."scroll_container_end[]")
            return
        -- rb Value off-on, ie_value Off, bbox_value On
        end
        if fields.toggle_rb and meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 1 then
	    local fsrb = "image[1.31,11.9;2,2;sbfs_scrollbar_off.png]" .. "image[1.2,14.35;2,2;sbfs_scrollbar_on.png]"
            meta:set_int("rb_value", "1")
            show_sb_load_formspec(pos, name, player, "voxelforge:schematic_editor", fsrb.."scroll_container_end[]")
            return
        end
        if fields.toggle_rb and meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 1 then
            local fsrbone = "image[1.31,11.9;2,2;sbfs_scrollbar_off.png]"
            meta:set_int("rb_value", "0")
            show_sb_load_formspec(pos, name, player, "voxelforge:schematic_editor", fsrbone.."scroll_container_end[]")
            return
        -- rb Value off-on, ie_value Off, bbox_value Off
        end
        if fields.toggle_rb and meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 0 then
	    local fsrbtwo = "image[1.31,11.9;2,2;sbfs_scrollbar_off.png]" .. "image[1.2,14.35;2,2;sbfs_scrollbar_on.png]" .. "image[0.81,32.35;2,2;sbfs_scrollbar_off.png]"
            meta:set_int("rb_value", "1")
            show_sb_load_formspec(pos, name, player, "voxelforge:schematic_editor", fsrbtwo.."scroll_container_end[]")
            return
        end
        if fields.toggle_rb and meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 0 then
            local fsrbthree = "image[1.31,11.9;2,2;sbfs_scrollbar_off.png]" .. "image[0.81,32.35;2,2;sbfs_scrollbar_off.png]"
            meta:set_int("rb_value", "0")
            show_sb_load_formspec(pos, name, player, "voxelforge:schematic_editor", fsrbthree.."scroll_container_end[]")
            return
        -- rb Value off-on, ie_value On, bbox_value Off
        end
        if fields.toggle_rb and meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 0 then
	    local fsrbfour = "image[1.2,14.35;2,2;sbfs_scrollbar_on.png]" .. "image[0.81,32.35;2,2;sbfs_scrollbar_off.png]"
            meta:set_int("rb_value", "1")
            show_sb_load_formspec(pos, name, player, "voxelforge:schematic_editor", fsrbfour.."scroll_container_end[]")
            return
        end
        if fields.toggle_rb and meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 0 then
            local fsrbfive = "image[0.81,32.35;2,2;sbfs_scrollbar_off.png]"
            meta:set_int("rb_value", "0")
            show_sb_load_formspec(pos, name, player, "voxelforge:schematic_editor", fsrbfive.."scroll_container_end[]")
            return
        -- rb Value off-on, ie_value On, bbox_value On
        end
        if fields.toggle_rb and meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 1 then
	    local fsrbsix = "image[1.2,14.35;2,2;sbfs_scrollbar_on.png]"
            meta:set_int("rb_value", "1")
            show_sb_load_formspec(pos, name, player, "voxelforge:schematic_editor", fsrbsix.."scroll_container_end[]")
            return
        end
        if fields.toggle_rb and meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 1 then
            meta:set_int("rb_value", "0")
            show_sb_load_formspec(pos, name, player, "voxelforge:schematic_editor", "scroll_container_end[]")
            return
        end
        end
        
        
        
        
        
        
        
        

        -- Handle save button
        if fields.save then
            minetest.chat_send_player(name, "Configurations saved!")
        elseif fields.detect then
        	find_and_execute_with_sb_model(pos, {x=48,y=48,z=48}, meta:get_string("filename"))
        elseif fields.export then
            minetest.chat_send_player(name, "Exporting schematic...")
            export_schematic(player, pos, {x = sx, y = sy, z = sz}, {x = ox, y = oy, z = oz}, filename, true)
        elseif fields.remove_temp_glass then
            minetest.chat_send_player(name, "Removing temporary glass...")
            remove_temp_glass(pos, {x = sx, y = sy, z = sz}, {x = ox, y = oy, z = oz})
	elseif fields.threedexport then
		create_sb_model(pos, {
			x = sx, y = sy, z = sz
		}, {
			x = ox, y = oy, z = oz
		}, minetest.get_worldpath() .. "/voxelforge/structure_block/export", meta:get_string("filename"))
		
        end
        if fields.mode and fields.mode == "Load" then
		meta:set_string("mode", "Load")
		if meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 1 then
	    local one = "image[1.31,11.9;2,2;sbfs_scrollbar_off.png]"
            show_sb_load_formspec(pos, name, player, "voxelforge:schematic_editor", one.."scroll_container_end[]")
            return
        end
        if meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 1 then
            local two = "image[1.31,11.9;2,2;sbfs_scrollbar_off.png]" .. "image[1.2,14.35;2,2;sbfs_scrollbar_on.png]"
            show_sb_load_formspec(pos, name, player, "voxelforge:schematic_editor", two.."scroll_container_end[]")
            return
        -- rb Value off-on, ie_value Off, bbox_value Off
        end
        if meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 0 then
	    local three = "image[1.31,11.9;2,2;sbfs_scrollbar_off.png]" .. "image[0.81,32.35;2,2;sbfs_scrollbar_off.png]"
            show_sb_load_formspec(pos, name, player, "voxelforge:schematic_editor", three.."scroll_container_end[]")
            return
        end
        if meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 0 then
            local four = "image[1.31,11.9;2,2;sbfs_scrollbar_off.png]" .. "image[1.2,14.35;2,2;sbfs_scrollbar_on.png]" .. "image[0.81,32.35;2,2;sbfs_scrollbar_off.png]"
            show_sb_load_formspec(pos, name, player, "voxelforge:schematic_editor", four.."scroll_container_end[]")
            return
        -- rb Value off-on, ie_value On, bbox_value Off
        end
        if meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 0 then
	    local five = "image[0.81,32.35;2,2;sbfs_scrollbar_off.png]"
            meta:set_int("rb_value", "1")
            show_sb_load_formspec(pos, name, player, "voxelforge:schematic_editor", five.."scroll_container_end[]")
            return
        end
        if meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 0 then
            local six = "image[0.81,32.35;2,2;sbfs_scrollbar_off.png]" .. "image[1.2,14.35;2,2;sbfs_scrollbar_on.png]"
            show_sb_load_formspec(pos, name, player, "voxelforge:schematic_editor", six.."scroll_container_end[]")
            return
        -- rb Value off-on, ie_value On, bbox_value On
        end
        if meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 1 then
	    local seven = "image[1.2,14.35;2,2;sbfs_scrollbar_on.png]"
            show_sb_load_formspec(pos, name, player, "voxelforge:schematic_editor", seven.."scroll_container_end[]")
            return
        end
        if meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 1 then
            show_sb_load_formspec(pos, name, player, "voxelforge:schematic_editor", "scroll_container_end[]")
            return
        end
	elseif fields.mode and fields.mode == "Save" then
		show_sb_formspec(pos, name, player, "voxelforge:schematic_editor", nil)
		meta:set_string("mode", "Save")
	elseif fields.mode and fields.mode == "Corner" then
		show_sb_corner_formspec(pos, name, player, "voxelforge:schematic_editor", nil)
		meta:set_string("mode", "Corner")
	elseif fields.mode and fields.mode == "3D_Export" then
		show_sb_export_formspec(pos, name, player, "voxelforge:schematic_editor", nil)
		meta:set_string("mode", "Export")
	end
	
	local updated = false
        if fields.sx then meta:set_int("sx", tonumber(fields.sx) or 0); updated = true end
        if fields.sy then meta:set_int("sy", tonumber(fields.sy) or 0); updated = true end
        if fields.sz then meta:set_int("sz", tonumber(fields.sz) or 0); updated = true end
        if fields.ox then meta:set_int("ox", tonumber(fields.ox) or 0); updated = true end
        if fields.oy then meta:set_int("oy", tonumber(fields.oy) or 0); updated = true end
        if fields.oz then meta:set_int("oz", tonumber(fields.oz) or 0); updated = true end

        -- Rebuild bounding box if any field changed
        if updated and meta:get_int("bbox_value") == 1 --[[and meta:get_string("mode") == "Save" ]]then
            place_temp_glass(pos, {
                x = sx, y = sy, z = sz
            }, {
                x = ox, y = oy, z = oz
            })
           -- reload_model_in_formspec(player:get_player_name(), player, meta:get_string("owner") .. "_structure_block_model")
            create_sb_model(pos, {
			x = sx, y = sy, z = sz
		}, {
			x = ox, y = oy, z = oz
		}, minetest.get_worldpath() .. "/voxelforge/structure_block/3d_models", pos_to_string(pos) .. "_structure_block_model")
		reload_model_in_formspec(player:get_player_name(), player, pos_to_string(pos) .. "_structure_block_model")
		minetest.after(4, function()
			if meta:get_string("mode") == "Save" then
				show_sb_formspec(pos, name, player, "voxelforge:schematic_editor", nil)
			end
		end)
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
        --minetest.log("error", "Error deserializing .gamedata file: " .. schematic_data)
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
    local schematic = load_vlfschem_nb(file_name)
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
        --if node.name == "vlf_copper:waxed_copper_bulb_lit" then
            --local processed_node = process_copper_bulb(node_pos, node)
            --local node_name = processed_node and processed_node.name or node.name
            --local node_param2 = processed_node and (rotated_param2 or 0) or rotated_param2

            -- Set copper bulb nodes individually
            --minetest.set_node(node_pos, {name = node_name, param2 = node_param2})
        --else
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
        --end
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
    
    -- Handle loading entities
    if schematic.entities then
        for _, entity_data in ipairs(schematic.entities) do
            -- Rotate entity position
            local rotated_pos = rotate_position(entity_data.pos, rotation, rotation_origin)
            local entity_pos = vector.add(pos, rotated_pos)

            -- Spawn entity if it's not excluded
            if entity_data.name ~= "vlf_data:border" then
                local obj = minetest.add_entity(entity_pos, entity_data.name)
                if obj and entity_data.properties then
                    local luaentity = obj:get_luaentity()
                    if luaentity then
                        for key, value in pairs(entity_data.properties) do
                            luaentity[key] = value
                        end
                    end
                end
            end
        end
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

    local real_pool = pool:gsub("voxelforge:", "")
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
        fallback_pool = fallback_pool:gsub("voxelforge:", "")
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
                local base_name = location:gsub("%.gamedata$", "")
                local selecting_schematic = "data/voxelforge/structure/" .. base_name .. ".gamedata"
                minetest.log("error", "selected schematic:" .. selecting_schematic.."")

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
            --[[if node_name == "vlf_deepslate:tuff_bricks" then
                return true  -- Overlap detected
            end]]
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

minetest.register_chatcommand("get_meta", {
    description = "Get metadata of the node at your position",
    privs = {interact = true},  -- Only allow players with the interact privilege to use this command
    func = function(name)
        -- Get the player object
        local player = minetest.get_player_by_name(name)
        if not player then
            return false, "Player not found."
        end

        -- Get the player's position
        local pos = player:get_pos()
        pos = vector.round(pos)  -- Round the position to the nearest node

        -- Get the metadata at the player's position
        local meta = minetest.get_meta(pos)
        if not meta then
            return false, "No metadata found at your position."
        end

        -- Retrieve all metadata fields
        local meta_table = meta:to_table()
        local meta_string = minetest.serialize(meta_table.fields)

        -- Return the metadata to the player
        return true, "Metadata at your position: " .. meta_string
    end,
})

minetest.register_chatcommand("place_test", {
	params = "",
	description = "Test for Procedural Structures.",
	func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then
            return false, "Player not found."
        end

        local pos = player:get_pos()
		--place_schematic(pos, "data/voxelforge/structure/pillager_outpost/base_plate.gamedata", 0)
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
		if is_file(filepath) and item:match("%.lua$") and not item:match("%.gamedata%.gamedata$") then
                minetest.log("error", "Found schematic file: " .. filepath)

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
                    minetest.log("error", "Placed schematic at position: " .. minetest.pos_to_string(pos))

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
                    
		place_temp_glass(editor_pos, {
			x = schematic.size.x, y = schematic.size.y, z = schematic.size.z
		}, {
			x = 0, y = 1, z = 0
		})

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
                minetest.log("error", "Skipped non-schematic file: " .. filepath)
            end
        end

        return pos
    end

    local final_pos = place_schematics_in_dir(directory, pos_start)
    return final_pos
end

--[[minetest.register_on_joinplayer(function(pos)
	local pos = {x=100, y=100, z=0}
	place_all_schematics_in_directory(modpath.."/data/voxelforge/structure/pillager_outpost", pos)
end)]]


minetest.register_chatcommand("place_schematics", {
    description = "Places all schematics in the trial chambers directory at the specified position",
    privs = {server = true}, -- Optional: Only players with server privileges can use this command
    func = function(name)
        local player = minetest.get_player_by_name(name)
        if not player then
            return false, "Player not found!"
        end

        local pos = {x = -40, y = 100, z = 0}
        place_all_schematics_in_directory(modpath .. "/data/voxelforge/structure/trial_chambers/corridor", pos)

        return true, "Schematics placed at " .. minetest.pos_to_string(pos)
    end,
})



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
