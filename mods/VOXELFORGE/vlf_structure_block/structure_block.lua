local binser = dofile(minetest.get_modpath("vlf_lib") .. "/binser.lua")

local function convert_vlfschem_file_to_binary(file_path)

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
            if node.name ~= "voxelforge:temp_glass" and node.name ~= "voxelforge:structure_block" and meta:get_int("rb_value") == 0 then
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

    -- Calculate the actual size of the schematic excluding temp_glass and structure_block nodes
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
            if luaentity and luaentity.name ~= "vlf_structure_block:border" then
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

minetest.register_entity("vlf_structure_block:border", {
	initial_properties = {
		physical = false,
		pointable = false,
		visual = "upright_sprite",
		textures = {"vlf_structure_block_sbb.png"}, -- Default texture; will be overridden
		static_save = false,
		glow = minetest.LIGHT_MAX,
	},

	on_punch = function(self, hitter)
		if self and self.object then
			self.object:remove()
		end
	end,
	on_step = function(self)
		if self._origin_pos and minetest.get_node(self._origin_pos).name ~= "voxelforge:structure_block" then
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
	"vlf_structure_block_sbb.png", -- Y+
	"vlf_structure_block_sbbb.png", -- Y-
	"vlf_structure_block_sbb.png", -- X+
	"vlf_structure_block_sbe.png", -- X-
	"vlf_structure_block_sbb.png", -- Z+
	"vlf_structure_block_sbn.png", -- Z-
}


function vlf_structure_block.mark_borders(pos, size, offset)
	local start_pos = vector.add(pos, offset)
	local end_pos = vector.add(start_pos, {x = size.x - 1, y = size.y - 1, z = size.z - 1})
	local center = vector.multiply(vector.add(start_pos, end_pos), 0.5)
	local c1, c2 = vector.subtract(start_pos, 0.5 + 0.01), vector.add(end_pos, 0.5 + 0.01)
	
	-- Remove existing border entities in the area
	for _, obj in ipairs(minetest.get_objects_inside_radius(center, math.max(size.x, size.y, size.z) + 1)) do
		if obj:get_luaentity() and obj:get_luaentity().name == "vlf_structure_block:border" then
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
		local entity = minetest.add_entity(sideCenters[i], "vlf_structure_block:border")
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

function vlf_structure_block.unmark_borders(pos, size, offset)
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
				if lua_entity and lua_entity.name == "vlf_structure_block:border" then
					obj:remove() -- Remove the entity
				end
			end
		end
	end
end

local mark_borders = vlf_structure_block.mark_borders
local unmark_borders = vlf_structure_block.unmark_borders

local function create_sb_model(pos, size, offset, path, name)
    local start_pos = vector.add(pos, offset)
    local end_pos = vector.add(start_pos, {x = size.x - 1, y = size.y - 1, z = size.z - 1})
    meshport.create_mesh(start_pos, end_pos, path, name)
end

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
    "dropdown[1.4,3.3;10.2,2.2;mode;Save,Load,Corner,3D_Export;1]" ..
    "image[1.55,6.3;9.9,1.5;sbfs_field.png;]" ..
    "field[1.55,6.3;9.9,1.5;filename;;" .. filename .. "]" ..

	-- Size Field
    "label[2.8,8.4;Size:]" ..
    -- X
    "image[1.3,8.9;1.5,1.5;sbfs_X.png;]" ..
    "image[2.7,8.9;2.8,1.5;sbfs_field.png;]" ..
    "field[2.7,8.9;2.8,1.5;sx; ;" .. sx .. "]" ..
    -- Y
    "image[1.3,10.4;1.5,1.5;sbfs_Y.png;]" ..
    "image[2.7,10.4;2.8,1.5;sbfs_field.png;]" ..
    "field[2.7,10.4;2.8,1.5;sy; ;" .. sy .. "]" ..
    -- Z
    "image[1.3,12;1.5,1.5;sbfs_Z.png;]" ..
    "image[2.7,12;2.8,1.5;sbfs_field.png;]" ..
    "field[2.7,12;2.8,1.5;sz; ;" .. sz .. "]" ..
	-- Offset Field
    "label[7.8,8.4;Offset:]" ..
    -- X
    "image[6.5,8.9;1.5,1.5;sbfs_X.png;]" ..
    "image[7.8,8.9;2.8,1.5;sbfs_field.png;]" ..
    "field[7.8,8.9;2.8,1.5;ox; ;" .. ox .. "]" ..
    -- Y
    "image[6.5,10.4;1.5,1.5;sbfs_Y.png;]" ..
    "image[7.8,10.4;2.8,1.5;sbfs_field.png;]" ..
    "field[7.8,10.4;2.8,1.5;oy; ;" .. oy .. "]" ..
    -- Z
    "image[6.5,12;1.5,1.5;sbfs_Z.png;]" ..
    "image[7.8,12;2.8,1.5;sbfs_field.png;]" ..
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


    "background[-0.2,-0.3;48.5,27.8;sbfs.png]" ..
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
    "image[1.55,6.3;9.9,1.5;sbfs_field.png;]" ..
    "field[1.55,6.3;9.9,1.5;filename;;" .. filename .. "]" ..

	-- Size Field
    "label[2.8,8.4;Size:]" ..
    -- X
    "image[1.3,8.9;1.5,1.5;sbfs_X.png;]" ..
    "image[2.7,8.9;2.8,1.5;sbfs_field.png;]" ..
    "field[2.7,8.9;2.8,1.5;sx; ;" .. sx .. "]" ..
    -- Y
    "image[1.3,10.4;1.5,1.5;sbfs_Y.png;]" ..
    "image[2.7,10.4;2.8,1.5;sbfs_field.png;]" ..
    "field[2.7,10.4;2.8,1.5;sy; ;" .. sy .. "]" ..
    -- Z
    "image[1.3,12;1.5,1.5;sbfs_Z.png;]" ..
    "image[2.7,12;2.8,1.5;sbfs_field.png;]" ..
    "field[2.7,12;2.8,1.5;sz; ;" .. sz .. "]" ..
	-- Offset Field
    "label[7.8,8.4;Offset:]" ..
    -- X
    "image[6.5,8.9;1.5,1.5;sbfs_X.png;]" ..
    "image[7.8,8.9;2.8,1.5;sbfs_field.png;]" ..
    "field[7.8,8.9;2.8,1.5;ox; ;" .. ox .. "]" ..
    -- Y
    "image[6.5,10.4;1.5,1.5;sbfs_Y.png;]" ..
    "image[7.8,10.4;2.8,1.5;sbfs_field.png;]" ..
    "field[7.8,10.4;2.8,1.5;oy; ;" .. oy .. "]" ..
    -- Z
    "image[6.5,12;1.5,1.5;sbfs_Z.png;]" ..
    "image[7.8,12;2.8,1.5;sbfs_field.png;]" ..
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

                if node and node.name == "voxelforge:structure_block" then
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
        mark_borders(pos, size, offset)
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
        mark_borders(pos, size, offset)
        meta1:set_int("sx", size.x)
	meta1:set_int("sy", size.y)
	meta1:set_int("sz", size.z)
	meta1:set_int("ox", offset.x)
	meta1:set_int("oy", offset.y)
	meta1:set_int("oz", offset.z)
    end
end





minetest.register_node(":voxelforge:structure_block", {
    description = "Structure Block",
    tiles = {"structure_block.png"},
    groups = {cracky = 3, oddly_breakable_by_hand = 3},
    on_construct = function(pos, node)
    	local meta = minetest.get_meta(pos)
        mark_borders(pos, {
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
        	show_sb_formspec(pos, player:get_player_name(), player, "voxelforge:structure_block", nil)
        elseif meta:get_string("mode") == "Load" then
        	show_sb_load_formspec(pos, player:get_player_name(), player, "voxelforge:structure_block", "scroll_container_end[]")
        elseif meta:get_string("mode") == "Corner" then
        	show_sb_corner_formspec(pos, player:get_player_name(), player, "voxelforge:structure_block", nil)
        elseif meta:get_string("mode") == "Export" then
        	show_sb_export_formspec(pos, player:get_player_name(), player, "voxelforge:structure_block", nil)
	else
        	show_sb_formspec(pos, player:get_player_name(), player, "voxelforge:structure_block", nil)
        end
    end,
})

-- Updated Handle formspec input
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname == "voxelforge:structure_block" then
        local name = player:get_player_name()

        -- Get position of the node from player's view
        local node_pos = minetest.get_player_by_name(name):get_pos()
        node_pos = vector.floor(node_pos)

        -- Find all nodes of structure block in the area
        local nodes = minetest.find_nodes_in_area(vector.subtract(node_pos, 3), vector.add(node_pos, 3), "voxelforge:structure_block")
        local pos = nodes[1]  -- Assume we only handle one node

        if not pos then
            minetest.chat_send_player(name, "No Structure Block node found.")
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
            mark_borders(pos, {x = sx, y = sy, z = sz}, {x = ox, y = oy, z = oz})  -- Place temp glass
            meta:set_int("bbox_value", "1")
            show_sb_formspec(pos, name, player, "voxelforge:structure_block", nil)
            return
        end
        if fields.toggle_bbox and meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 1 then
            local fsbbox = "image[2.31,24.55;2,2;sbfs_scrollbar_off.png]"
            unmark_borders(pos, {x = sx, y = sy, z = sz}, {x = ox, y = oy, z = oz})  -- Place temp glass
            meta:set_int("bbox_value", "0")
            show_sb_formspec(pos, name, player, "voxelforge:structure_block", fsbbox)
            return
            -- bbox Value off-on, ie_value Off, rb_value Off
	    end
	if fields.toggle_bbox and meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 0 then
            local fsbboxio = "image[2.31,16;2,2;sbfs_scrollbar_off.png]"
            mark_borders(pos, {x = sx, y = sy, z = sz}, {x = ox, y = oy, z = oz})  -- Place temp glass
            meta:set_int("bbox_value", "1")
            show_sb_formspec(pos, name, player, "voxelforge:structure_block", fsbboxio)
            return
        end
        if fields.toggle_bbox and meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 1 then
            local fsbboxoio = "image[2.31,16;2,2;sbfs_scrollbar_off.png]" .. "image[2.31,24.55;2,2;sbfs_scrollbar_off.png]"
            unmark_borders(pos, {x = sx, y = sy, z = sz}, {x = ox, y = oy, z = oz})  -- Place temp glass
            meta:set_int("bbox_value", "0")
            show_sb_formspec(pos, name, player, "voxelforge:structure_block", fsbboxoio)
            return
        -- bbox Value off-on, ie_value Off, rb_value On
        end
        if fields.toggle_bbox and meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 0 then
            local fsbboxro = "image[2.31,16;2,2;sbfs_scrollbar_off.png]" .. "image[2.2,18.15;2,2;sbfs_scrollbar_on.png]"
            mark_borders(pos, {x = sx, y = sy, z = sz}, {x = ox, y = oy, z = oz})  -- Place temp glass
            meta:set_int("bbox_value", "1")
            show_sb_formspec(pos, name, player, "voxelforge:structure_block", fsbboxro)
            return
        end
        if fields.toggle_bbox and meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 1 then
            local fsbboxoro = "image[2.31,16;2,2;sbfs_scrollbar_off.png]" .. "image[2.31,24.55;2,2;sbfs_scrollbar_off.png]" .. "image[2.2,18.15;2,2;sbfs_scrollbar_on.png]"
            unmark_borders(pos, {x = sx, y = sy, z = sz}, {x = ox, y = oy, z = oz})  -- Place temp glass
            meta:set_int("bbox_value", "0")
            show_sb_formspec(pos, name, player, "voxelforge:structure_block", fsbboxoro)
            return
        -- bbox Value off-on, ie_value On, rb_value On
        end
        if fields.toggle_bbox and meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 0 then
            local fsbboxioro = "image[2.2,18.15;2,2;sbfs_scrollbar_on.png]"
            mark_borders(pos, {x = sx, y = sy, z = sz}, {x = ox, y = oy, z = oz})  -- Place temp glass
            meta:set_int("bbox_value", "1")
            show_sb_formspec(pos, name, player, "voxelforge:structure_block", fsbboxioro)
            return
        end
        if fields.toggle_bbox and meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 1 then
            local fsbboxoiro = "image[2.31,24.55;2,2;sbfs_scrollbar_off.png]" .. "image[2.2,18.15;2,2;sbfs_scrollbar_on.png]"
            unmark_borders(pos, {x = sx, y = sy, z = sz}, {x = ox, y = oy, z = oz})  -- Place temp glass
            meta:set_int("bbox_value", "0")
            show_sb_formspec(pos, name, player, "voxelforge:structure_block", fsbboxoiro)
            return
        -- ie Value off-on, rb_value Off, bbox_value On
        end
        if fields.toggle_ie and meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 1 then
            meta:set_int("ie_value", "1")
            show_sb_formspec(pos, name, player, "voxelforge:structure_block", nil)
            return
        end
        if fields.toggle_ie and meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 1 then
            local fsieone = "image[2.31,16;2,2;sbfs_scrollbar_off.png]"
            meta:set_int("ie_value", "0")
            show_sb_formspec(pos, name, player, "voxelforge:structure_block", fsieone.."scroll_container_end[]")
            return
        -- ie Value off-on, rb_value Off, bbox_value Off
        end
        if fields.toggle_ie and meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 0 then
            local fsietwo = "image[2.31,24.55;2,2;sbfs_scrollbar_off.png]"
            meta:set_int("ie_value", "1")
            show_sb_formspec(pos, name, player, "voxelforge:structure_block", fsietwo)
            return
        end
        if fields.toggle_ie and meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 0 then
            local fsiethree = "image[2.31,16;2,2;sbfs_scrollbar_off.png]" .. "image[2.31,24.55;2,2;sbfs_scrollbar_off.png]"
            meta:set_int("ie_value", "0")
            show_sb_formspec(pos, name, player, "voxelforge:structure_block", fsiethree)
            return
        -- ie Value off-on, rb_value On, bbox_value Off
        end
        if fields.toggle_ie and meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 0 then
            local fsiefour = "image[2.31,24.55;2,2;sbfs_scrollbar_off.png]" .. "image[2.2,18.15;2,2;sbfs_scrollbar_on.png]"
            meta:set_int("ie_value", "1")
            show_sb_formspec(pos, name, player, "voxelforge:structure_block", fsiefour)
            return
        end
        if fields.toggle_ie and meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 0 then
            local fsiefive = "image[2.31,16;2,2;sbfs_scrollbar_off.png]" .. "image[2.31,24.55;2,2;sbfs_scrollbar_off.png]" .. "image[2.2,18.15;2,2;sbfs_scrollbar_on.png]"
            meta:set_int("ie_value", "0")
            show_sb_formspec(pos, name, player, "voxelforge:structure_block", fsiefive)
            return
        -- ie Value off-on, rb_value On, bbox_value On
        end
        if fields.toggle_ie and meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 1 then
            local fsiesix = "image[2.2,18.15;2,2;sbfs_scrollbar_on.png]"
            meta:set_int("ie_value", "1")
            show_sb_formspec(pos, name, player, "voxelforge:structure_block", fsiesix)
            return
        end
        if fields.toggle_ie and meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 1 then
            local fsieseven = "image[2.31,16;2,2;sbfs_scrollbar_off.png]" .. "image[2.2,18.15;2,2;sbfs_scrollbar_on.png]"
            meta:set_int("ie_value", "0")
            show_sb_formspec(pos, name, player, "voxelforge:structure_block", fsieseven)
            return
        -- rb Value off-on, ie_value Off, bbox_value On
        end
        if fields.toggle_rb and meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 1 then
	    local fsrb = "image[2.31,16;2,2;sbfs_scrollbar_off.png]" .. "image[2.2,18.15;2,2;sbfs_scrollbar_on.png]"
            meta:set_int("rb_value", "1")
            show_sb_formspec(pos, name, player, "voxelforge:structure_block", fsrb)
            return
        end
        if fields.toggle_rb and meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 1 then
            local fsrbone = "image[2.31,16;2,2;sbfs_scrollbar_off.png]"
            meta:set_int("rb_value", "0")
            show_sb_formspec(pos, name, player, "voxelforge:structure_block", fsrbone)
            return
        -- rb Value off-on, ie_value Off, bbox_value Off
        end
        if fields.toggle_rb and meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 0 then
	    local fsrbtwo = "image[2.31,16;2,2;sbfs_scrollbar_off.png]" .. "image[2.2,18.15;2,2;sbfs_scrollbar_on.png]" .. "image[2.31,24.55;2,2;sbfs_scrollbar_off.png]"
            meta:set_int("rb_value", "1")
            show_sb_formspec(pos, name, player, "voxelforge:structure_block", fsrbtwo)
            return
        end
        if fields.toggle_rb and meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 0 then
            local fsrbthree = "image[2.31,16;2,2;sbfs_scrollbar_off.png]" .. "image[2.31,24.55;2,2;sbfs_scrollbar_off.png]"
            meta:set_int("rb_value", "0")
            show_sb_formspec(pos, name, player, "voxelforge:structure_block", fsrbthree)
            return
        -- rb Value off-on, ie_value On, bbox_value Off
        end
        if fields.toggle_rb and meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 0 then
	    local fsrbfour = "image[2.2,18.15;2,2;sbfs_scrollbar_on.png]" .. "image[2.31,24.55;2,2;sbfs_scrollbar_off.png]"
            meta:set_int("rb_value", "1")
            show_sb_formspec(pos, name, player, "voxelforge:structure_block", fsrbfour)
            return
        end
        if fields.toggle_rb and meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 0 then
            local fsrbfive = "image[2.31,24.55;2,2;sbfs_scrollbar_off.png]"
            meta:set_int("rb_value", "0")
            show_sb_formspec(pos, name, player, "voxelforge:structure_block", fsrbfive)
            return
        -- rb Value off-on, ie_value On, bbox_value On
        end
        if fields.toggle_rb and meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 1 then
	    local fsrbsix = "image[2.2,18.15;2,2;sbfs_scrollbar_on.png]"
            meta:set_int("rb_value", "1")
            show_sb_formspec(pos, name, player, "voxelforge:structure_block", fsrbsix)
            return
        end
        if fields.toggle_rb and meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 1 then
            meta:set_int("rb_value", "0")
            show_sb_formspec(pos, name, player, "voxelforge:structure_block", nil)
            return
        end
        end



        if meta:get_string("mode") == "Load" then
        -- bbox Value off-on, ie_value On, rb_value Off
        if fields.toggle_bbox and meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 0 then
            mark_borders(pos, {x = sx, y = sy, z = sz}, {x = ox, y = oy, z = oz})  -- Place temp glass
            meta:set_int("bbox_value", "1")
            show_sb_load_formspec(pos, name, player, "voxelforge:structure_block", "scroll_container_end[]")
            return
        end
        if fields.toggle_bbox and meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 1 then
            local fsbbox = "image[0.81,32.35;2,2;sbfs_scrollbar_off.png]"
            unmark_borders(pos, {x = sx, y = sy, z = sz}, {x = ox, y = oy, z = oz})  -- Place temp glass
            meta:set_int("bbox_value", "0")
            show_sb_load_formspec(pos, name, player, "voxelforge:structure_block", fsbbox.."scroll_container_end[]")
            return
            -- bbox Value off-on, ie_value Off, rb_value Off
	end
	if fields.toggle_bbox and meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 0 then
            local fsbboxio = "image[1.31,11.9;2,2;sbfs_scrollbar_off.png]"
            mark_borders(pos, {x = sx, y = sy, z = sz}, {x = ox, y = oy, z = oz})  -- Place temp glass
            meta:set_int("bbox_value", "1")
            show_sb_load_formspec(pos, name, player, "voxelforge:structure_block", fsbboxio.."scroll_container_end[]")
            return
        end
        if fields.toggle_bbox and meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 1 then
            local fsbboxoio = "image[1.31,11.9;2,2;sbfs_scrollbar_off.png]" .. "image[0.81,32.35;2,2;sbfs_scrollbar_off.png]"
            unmark_borders(pos, {x = sx, y = sy, z = sz}, {x = ox, y = oy, z = oz})  -- Place temp glass
            meta:set_int("bbox_value", "0")
            show_sb_load_formspec(pos, name, player, "voxelforge:structure_block", fsbboxoio.."scroll_container_end[]")
            return
        -- bbox Value off-on, ie_value Off, rb_value On
        end
        if fields.toggle_bbox and meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 0 then
            local fsbboxro = "image[1.31,11.9;2,2;sbfs_scrollbar_off.png]" .. "image[1.2,14.35;2,2;sbfs_scrollbar_on.png]"
            mark_borders(pos, {x = sx, y = sy, z = sz}, {x = ox, y = oy, z = oz})  -- Place temp glass
            meta:set_int("bbox_value", "1")
            show_sb_load_formspec(pos, name, player, "voxelforge:structure_block", fsbboxro.."scroll_container_end[]")
            return
        end
        if fields.toggle_bbox and meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 1 then
            local fsbboxoro = "image[1.31,11.9;2,2;sbfs_scrollbar_off.png]" .. "image[0.81,32.35;2,2;sbfs_scrollbar_off.png]" .. "image[1.2,14.35;2,2;sbfs_scrollbar_on.png]"
            unmark_borders(pos, {x = sx, y = sy, z = sz}, {x = ox, y = oy, z = oz})  -- Place temp glass
            meta:set_int("bbox_value", "0")
            show_sb_load_formspec(pos, name, player, "voxelforge:structure_block", fsbboxoro.."scroll_container_end[]")
            return
        -- bbox Value off-on, ie_value On, rb_value On
        end
        if fields.toggle_bbox and meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 0 then
            local fsbboxioro = "image[1.2,14.35;2,2;sbfs_scrollbar_on.png]"
            mark_borders(pos, {x = sx, y = sy, z = sz}, {x = ox, y = oy, z = oz})  -- Place temp glass
            meta:set_int("bbox_value", "1")
            show_sb_load_formspec(pos, name, player, "voxelforge:structure_block", fsbboxioro.."scroll_container_end[]")
            return
        end
        if fields.toggle_bbox and meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 1 then
            local fsbboxoiro = "image[0.81,32.35;2,2;sbfs_scrollbar_off.png]" .. "image[1.2,14.35;2,2;sbfs_scrollbar_on.png]"
            unmark_borders(pos, {x = sx, y = sy, z = sz}, {x = ox, y = oy, z = oz})  -- Place temp glass
            meta:set_int("bbox_value", "0")
            show_sb_load_formspec(pos, name, player, "voxelforge:structure_block", fsbboxoiro.."scroll_container_end[]")
            return
        -- ie Value off-on, rb_value Off, bbox_value On
        end
        if fields.toggle_ie and meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 1 then
            meta:set_int("ie_value", "1")
            show_sb_load_formspec(pos, name, player, "voxelforge:structure_block", "scroll_container_end[]")
            return
        end
        if fields.toggle_ie and meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 1 then
            local fsieone = "image[1.31,11.9;2,2;sbfs_scrollbar_off.png]"
            meta:set_int("ie_value", "0")
            show_sb_load_formspec(pos, name, player, "voxelforge:structure_block", fsieone.."scroll_container_end[]")
            return
        -- ie Value off-on, rb_value Off, bbox_value Off
        end
        if fields.toggle_ie and meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 0 then
            local fsietwo = "image[0.81,32.35;2,2;sbfs_scrollbar_off.png]"
            meta:set_int("ie_value", "1")
            show_sb_load_formspec(pos, name, player, "voxelforge:structure_block", fsietwo.."scroll_container_end[]")
            return
        end
        if fields.toggle_ie and meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 0 then
            local fsiethree = "image[1.31,11.9;2,2;sbfs_scrollbar_off.png]" .. "image[0.81,32.35;2,2;sbfs_scrollbar_off.png]"
            meta:set_int("ie_value", "0")
            show_sb_load_formspec(pos, name, player, "voxelforge:structure_block", fsiethree.."scroll_container_end[]")
            return
        -- ie Value off-on, rb_value On, bbox_value Off
        end
        if fields.toggle_ie and meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 0 then
            local fsiefour = "image[0.81,32.35;2,2;sbfs_scrollbar_off.png]" .. "image[1.2,14.35;2,2;sbfs_scrollbar_on.png]"
            meta:set_int("ie_value", "1")
            show_sb_load_formspec(pos, name, player, "voxelforge:structure_block", fsiefour.."scroll_container_end[]")
            return
        end
        if fields.toggle_ie and meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 0 then
            local fsiefive = "image[1.31,11.9;2,2;sbfs_scrollbar_off.png]" .. "image[0.81,32.35;2,2;sbfs_scrollbar_off.png]" .. "image[1.2,14.35;2,2;sbfs_scrollbar_on.png]"
            meta:set_int("ie_value", "0")
            show_sb_load_formspec(pos, name, player, "voxelforge:structure_block", fsiefive.."scroll_container_end[]")
            return
        -- ie Value off-on, rb_value On, bbox_value On
        end
        if fields.toggle_ie and meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 1 then
            local fsiesix = "image[1.2,14.35;2,2;sbfs_scrollbar_on.png]"
            meta:set_int("ie_value", "1")
            show_sb_load_formspec(pos, name, player, "voxelforge:structure_block", fsiesix.."scroll_container_end[]")
            return
        end
        if fields.toggle_ie and meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 1 then
            local fsieseven = "image[1.31,11.9;2,2;sbfs_scrollbar_off.png]" .. "image[1.2,14.35;2,2;sbfs_scrollbar_on.png]"
            meta:set_int("ie_value", "0")
            show_sb_load_formspec(pos, name, player, "voxelforge:structure_block", fsieseven.."scroll_container_end[]")
            return
        -- rb Value off-on, ie_value Off, bbox_value On
        end
        if fields.toggle_rb and meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 1 then
	    local fsrb = "image[1.31,11.9;2,2;sbfs_scrollbar_off.png]" .. "image[1.2,14.35;2,2;sbfs_scrollbar_on.png]"
            meta:set_int("rb_value", "1")
            show_sb_load_formspec(pos, name, player, "voxelforge:structure_block", fsrb.."scroll_container_end[]")
            return
        end
        if fields.toggle_rb and meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 1 then
            local fsrbone = "image[1.31,11.9;2,2;sbfs_scrollbar_off.png]"
            meta:set_int("rb_value", "0")
            show_sb_load_formspec(pos, name, player, "voxelforge:structure_block", fsrbone.."scroll_container_end[]")
            return
        -- rb Value off-on, ie_value Off, bbox_value Off
        end
        if fields.toggle_rb and meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 0 then
	    local fsrbtwo = "image[1.31,11.9;2,2;sbfs_scrollbar_off.png]" .. "image[1.2,14.35;2,2;sbfs_scrollbar_on.png]" .. "image[0.81,32.35;2,2;sbfs_scrollbar_off.png]"
            meta:set_int("rb_value", "1")
            show_sb_load_formspec(pos, name, player, "voxelforge:structure_block", fsrbtwo.."scroll_container_end[]")
            return
        end
        if fields.toggle_rb and meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 0 then
            local fsrbthree = "image[1.31,11.9;2,2;sbfs_scrollbar_off.png]" .. "image[0.81,32.35;2,2;sbfs_scrollbar_off.png]"
            meta:set_int("rb_value", "0")
            show_sb_load_formspec(pos, name, player, "voxelforge:structure_block", fsrbthree.."scroll_container_end[]")
            return
        -- rb Value off-on, ie_value On, bbox_value Off
        end
        if fields.toggle_rb and meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 0 then
	    local fsrbfour = "image[1.2,14.35;2,2;sbfs_scrollbar_on.png]" .. "image[0.81,32.35;2,2;sbfs_scrollbar_off.png]"
            meta:set_int("rb_value", "1")
            show_sb_load_formspec(pos, name, player, "voxelforge:structure_block", fsrbfour.."scroll_container_end[]")
            return
        end
        if fields.toggle_rb and meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 0 then
            local fsrbfive = "image[0.81,32.35;2,2;sbfs_scrollbar_off.png]"
            meta:set_int("rb_value", "0")
            show_sb_load_formspec(pos, name, player, "voxelforge:structure_block", fsrbfive.."scroll_container_end[]")
            return
        -- rb Value off-on, ie_value On, bbox_value On
        end
        if fields.toggle_rb and meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 1 then
	    local fsrbsix = "image[1.2,14.35;2,2;sbfs_scrollbar_on.png]"
            meta:set_int("rb_value", "1")
            show_sb_load_formspec(pos, name, player, "voxelforge:structure_block", fsrbsix.."scroll_container_end[]")
            return
        end
        if fields.toggle_rb and meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 1 then
            meta:set_int("rb_value", "0")
            show_sb_load_formspec(pos, name, player, "voxelforge:structure_block", "scroll_container_end[]")
            return
        end
        end









        -- Handle save button
        local lpos = {x=(pos.x + ox) or pos.x, y=(pos.y + oy) or pos.y, z=(pos.z + oz) or pos.z}
        if meta:get_string("mode") == "Load" and fields.load and meta:get_int("ie_value") == 1 then
        	vlf_structure_block.place_schematic(lpos, filename, rotation or 0, rotation_origin or pos, "true", true, true)
        elseif meta:get_string("mode") == "Load" and fields.load and meta:get_int("ie_value") == 0 then
        	vlf_structure_block.place_schematic(lpos, filename, rotation or 0, rotation_origin or pos, "true", true, false)
        end
        if fields.save then
            minetest.chat_send_player(name, "Configurations saved!")
        elseif fields.detect then
        	find_and_execute_with_sb_model(pos, {x=48,y=48,z=48}, meta:get_string("filename"))
        elseif fields.export then
            minetest.chat_send_player(name, "Exporting schematic...")
            export_schematic(player, pos, {x = sx, y = sy, z = sz}, {x = ox, y = oy, z = oz}, filename, true)
        elseif fields.unmark_borders then
            minetest.chat_send_player(name, "Removing temporary glass...")
            unmark_borders(pos, {x = sx, y = sy, z = sz}, {x = ox, y = oy, z = oz})
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
            show_sb_load_formspec(pos, name, player, "voxelforge:structure_block", one.."scroll_container_end[]")
            return
        end
        if meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 1 then
            local two = "image[1.31,11.9;2,2;sbfs_scrollbar_off.png]" .. "image[1.2,14.35;2,2;sbfs_scrollbar_on.png]"
            show_sb_load_formspec(pos, name, player, "voxelforge:structure_block", two.."scroll_container_end[]")
            return
        -- rb Value off-on, ie_value Off, bbox_value Off
        end
        if meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 0 then
	    local three = "image[1.31,11.9;2,2;sbfs_scrollbar_off.png]" .. "image[0.81,32.35;2,2;sbfs_scrollbar_off.png]"
            show_sb_load_formspec(pos, name, player, "voxelforge:structure_block", three.."scroll_container_end[]")
            return
        end
        if meta:get_int("ie_value") == 0 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 0 then
            local four = "image[1.31,11.9;2,2;sbfs_scrollbar_off.png]" .. "image[1.2,14.35;2,2;sbfs_scrollbar_on.png]" .. "image[0.81,32.35;2,2;sbfs_scrollbar_off.png]"
            show_sb_load_formspec(pos, name, player, "voxelforge:structure_block", four.."scroll_container_end[]")
            return
        -- rb Value off-on, ie_value On, bbox_value Off
        end
        if meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 0 then
	    local five = "image[0.81,32.35;2,2;sbfs_scrollbar_off.png]"
            meta:set_int("rb_value", "1")
            show_sb_load_formspec(pos, name, player, "voxelforge:structure_block", five.."scroll_container_end[]")
            return
        end
        if meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 0 then
            local six = "image[0.81,32.35;2,2;sbfs_scrollbar_off.png]" .. "image[1.2,14.35;2,2;sbfs_scrollbar_on.png]"
            show_sb_load_formspec(pos, name, player, "voxelforge:structure_block", six.."scroll_container_end[]")
            return
        -- rb Value off-on, ie_value On, bbox_value On
        end
        if meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 1 and meta:get_int("bbox_value") == 1 then
	    local seven = "image[1.2,14.35;2,2;sbfs_scrollbar_on.png]"
            show_sb_load_formspec(pos, name, player, "voxelforge:structure_block", seven.."scroll_container_end[]")
            return
        end
        if meta:get_int("ie_value") == 1 and meta:get_int("rb_value") == 0 and meta:get_int("bbox_value") == 1 then
            show_sb_load_formspec(pos, name, player, "voxelforge:structure_block", "scroll_container_end[]")
            return
        end
	elseif fields.mode and fields.mode == "Save" then
		show_sb_formspec(pos, name, player, "voxelforge:structure_block", nil)
		meta:set_string("mode", "Save")
	elseif fields.mode and fields.mode == "Corner" then
		show_sb_corner_formspec(pos, name, player, "voxelforge:structure_block", nil)
		meta:set_string("mode", "Corner")
	elseif fields.mode and fields.mode == "3D_Export" then
		show_sb_export_formspec(pos, name, player, "voxelforge:structure_block", nil)
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
            mark_borders(pos, {
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
				show_sb_formspec(pos, name, player, "voxelforge:structure_block", nil)
			end
		end)
        end
    end
end)
