local mod_storage = minetest.get_mod_storage()
local modpath = minetest.get_modpath("vlf_init")

-- Some global variables (don't overwrite them!)
vlf_vars = {}

vlf_vars.redstone_tick = 0.1
vlf_vars.mg_overworld_min_old = -62

--- GUI / inventory menu settings
vlf_vars.gui_slots = "listcolors[#9990;#FFF7;#FFF0;#000;#FFF]"
-- nonbg is added as formspec prepend in vlf_formspec_prepend
vlf_vars.gui_nonbg = vlf_vars.gui_slots ..
	"style_type[image_button;border=false;bgimg=vlf_inventory_button9.png;bgimg_pressed=vlf_inventory_button9_pressed.png;bgimg_middle=2,2]"..
	"style_type[button;border=false;bgimg=vlf_inventory_button9.png;bgimg_pressed=vlf_inventory_button9_pressed.png;bgimg_middle=2,2]"..
	"style_type[field;textcolor=#323232]"..
	"style_type[label;textcolor=#323232]"..
	"style_type[textarea;textcolor=#323232]"..
	"style_type[checkbox;textcolor=#323232]"

-- Background stuff must be manually added by mods (no formspec prepend)
vlf_vars.gui_bg_color = "bgcolor[#00000000]"
vlf_vars.gui_bg_img = "background9[1,1;1,1;vlf_base_textures_background9.png;true;7]"

-- Legacy
vlf_vars.inventory_header = ""

-- Tool wield size
vlf_vars.tool_wield_scale = { x = 1.8, y = 1.8, z = 1 }

minetest.register_on_mods_loaded(function()
	local font_size = minetest.settings:get("vlf_font_size") or 30
	local font_shadow_size = minetest.settings:get("vlf_font_shadow_size") or 3
	local chat_font_size = minetest.settings:get("vlf_chat_font_size") or 24
	minetest.settings:set("font_path", modpath.."/fonts/voxelforge.ttf")
	minetest.settings:set("font_shadow", font_shadow_size)
	minetest.settings:set("font_size", font_size)
	minetest.settings:set("chat_font_size", chat_font_size)
	minetest.settings:set("font_shadow_alpha", "225")
end)

minetest.register_on_shutdown(function()
	minetest.settings:set("font_path", "") -- One day hopefully this will be replaced by a setting that players can set so it's  their default font.
	minetest.settings:set("font_shadow", "1")
	minetest.settings:set("font_size", "16")
	minetest.settings:set("chat_font_size", "")
	minetest.settings:set("font_shadow_alpha", "172")
end)

-- Table to store player chat HUD IDs and chat history
local player_chat_huds = {}
local chat_history = {}

-- Maximum number of chat lines to display
local max_chat_lines = 10

-- Time after which chat messages start disappearing (in seconds)
local message_lifetime = 10  -- Adjust as needed

-- Maximum width for the chat HUD text before wrapping (in characters)
local max_hud_width_chars = 40  -- Adjust as needed

-- Function to hide the default chat
local function hide_default_chat(player)
	player:hud_set_flags({
		chat = false,
	})
end

-- Function to create the chat HUD element
local function create_chat_hud(player)
	local player_name = player:get_player_name()

	-- Add a HUD element for the chat
	player_chat_huds[player_name] = player:hud_add({
		hud_elem_type = "text",
		position = {x = 0.2, y = 0.7}, -- Top center (adjusted for upward movement)
		offset = {x = 0, y = 10}, -- Adjust y offset as needed
		text = "",
		alignment = {x = 0.1, y = -0.2},  -- Right and bottom alignment
		scale = {x = 100, y = 100},
		number = 0xFFFFFF, -- White color
	})
end

-- Function to update the chat HUD element with the chat history
local function update_chat_hud(player)
	local player_name = player:get_player_name()
	local hud_id = player_chat_huds[player_name]

	if hud_id then
		local chat_text = ""
		local current_time = os.time()
		local line_count = 0
		for i = #chat_history, 1, -1 do
		local message = chat_history[i]
		local message_time = message.time or current_time
		if current_time - message_time <= message_lifetime then
			local formatted_message
			formatted_message = message.message
			local words = {}
			for word in formatted_message:gmatch("%S+") do
				table.insert(words, word)
			end
			local wrapped_lines = {}
			local line = ""
			local line_length = 0
			for _, word in ipairs(words) do
				local word_length = word:len()
				if line_length > 0 and line_length + word_length > max_hud_width_chars then
					table.insert(wrapped_lines, line)
					line = ""
					line_length = 0
				end
				if line ~= "" then
					line = line .. " "
					line_length = line_length + 1
				end
				line = line .. word
				line_length = line_length + word_length
			end
			if line ~= "" then
				table.insert(wrapped_lines, line)
			end
			for j = 1, #wrapped_lines do
				if chat_text ~= "" then
					chat_text = chat_text .. "\n"
				end
				chat_text = chat_text .. string.rep(" ", max_hud_width_chars - wrapped_lines[j]:len()) .. wrapped_lines[j]
				line_count = line_count + 1
				if line_count >= max_chat_lines then
					break
				end
			end
		end
	end
		player:hud_change(hud_id, "text", chat_text)
	end
end

-- Function to add a message to the chat history
local function add_chat_message(name, message)
	local current_time = os.time()
	if name ~= "" then
		message = "<" .. name .. "> " .. message
	end
	table.insert(chat_history, {name = name, message = message, time = current_time})
	while #chat_history > max_chat_lines do
		table.remove(chat_history, 1)
	end
	for _, player in pairs(minetest.get_connected_players()) do
		update_chat_hud(player)
	end
end
minetest.register_on_joinplayer(function(player)
	local player_name = player:get_player_name()
	hide_default_chat(player)
	create_chat_hud(player)
	add_chat_message("", player_name .. " has joined the game.")
end)
minetest.register_on_leaveplayer(function(player)
	local player_name = player:get_player_name()
	add_chat_message("", player_name .. " has left the game.")
	for _, player in pairs(minetest.get_connected_players()) do
		update_chat_hud(player)
	end
end)
minetest.register_on_chat_message(function(name, message)
	add_chat_message(name, message)
	return true
end)
minetest.register_globalstep(function(dtime)
	local current_time = os.time()
	local updated = false
	for i = #chat_history, 1, -1 do
		if current_time - chat_history[i].time >= message_lifetime then
			table.remove(chat_history, i)
			updated = true
			end
		end
		if updated then
			for _, player in pairs(minetest.get_connected_players()) do
				update_chat_hud(player)
			end
		end
end)

-- Mapgen variables
local mg_name = minetest.get_mapgen_setting("mg_name")
local minecraft_height_limit = 320

local singlenode = mg_name == "singlenode"

-- The classic superflat setting is stored in mod storage so it remains
-- constant after the world has been created.
if not mod_storage:get("vlf_superflat_classic") then
	local superflat = mg_name == "flat" and minetest.get_mapgen_setting("vlf_superflat_classic") == "true"
	mod_storage:set_string("vlf_superflat_classic", superflat and "true" or "false")
end
vlf_vars.superflat = mod_storage:get_string("vlf_superflat_classic") == "true"

-- Calculate mapgen_edge_min/mapgen_edge_max
vlf_vars.chunksize = math.max(1, tonumber(minetest.get_mapgen_setting("chunksize")) or 5)
vlf_vars.MAP_BLOCKSIZE = math.max(1, minetest.MAP_BLOCKSIZE or 16)
vlf_vars.mapgen_limit = math.max(1, tonumber(minetest.get_mapgen_setting("mapgen_limit")) or 31000)
vlf_vars.MAX_MAP_GENERATION_LIMIT = math.max(1, minetest.MAX_MAP_GENERATION_LIMIT or 31000)
local central_chunk_offset = -math.floor(vlf_vars.chunksize / 2)
vlf_vars.central_chunk_offset_in_nodes = central_chunk_offset * vlf_vars.MAP_BLOCKSIZE
vlf_vars.chunk_size_in_nodes = vlf_vars.chunksize * vlf_vars.MAP_BLOCKSIZE
local central_chunk_min_pos = central_chunk_offset * vlf_vars.MAP_BLOCKSIZE
local central_chunk_max_pos = central_chunk_min_pos + vlf_vars.chunk_size_in_nodes - 1
local ccfmin = central_chunk_min_pos - vlf_vars.MAP_BLOCKSIZE -- Fullminp/fullmaxp of central chunk, in nodes
local ccfmax = central_chunk_max_pos + vlf_vars.MAP_BLOCKSIZE
local mapgen_limit_b = math.floor(math.min(vlf_vars.mapgen_limit, vlf_vars.MAX_MAP_GENERATION_LIMIT) / vlf_vars.MAP_BLOCKSIZE)
local mapgen_limit_min = -mapgen_limit_b * vlf_vars.MAP_BLOCKSIZE
local mapgen_limit_max = (mapgen_limit_b + 1) * vlf_vars.MAP_BLOCKSIZE - 1
local numcmin = math.max(math.floor((ccfmin - mapgen_limit_min) / vlf_vars.chunk_size_in_nodes), 0) -- Number of complete chunks from central chunk
local numcmax = math.max(math.floor((mapgen_limit_max - ccfmax) / vlf_vars.chunk_size_in_nodes), 0) -- fullminp/fullmaxp to effective mapgen limits.
vlf_vars.mapgen_edge_min = central_chunk_min_pos - numcmin * vlf_vars.chunk_size_in_nodes
vlf_vars.mapgen_edge_max = central_chunk_max_pos + numcmax * vlf_vars.chunk_size_in_nodes

local function coordinate_to_block(x)
	return math.floor(x / vlf_vars.MAP_BLOCKSIZE)
end

local function coordinate_to_chunk(x)
	return math.floor((coordinate_to_block(x) - central_chunk_offset) / vlf_vars.chunksize)
end

function vlf_vars.pos_to_block(pos)
	return {
		x = coordinate_to_block(pos.x),
		y = coordinate_to_block(pos.y),
		z = coordinate_to_block(pos.z)
	}
end

function vlf_vars.pos_to_chunk(pos)
	return {
		x = coordinate_to_chunk(pos.x),
		y = coordinate_to_chunk(pos.y),
		z = coordinate_to_chunk(pos.z)
	}
end

local k_positive = math.ceil(vlf_vars.MAX_MAP_GENERATION_LIMIT / vlf_vars.chunk_size_in_nodes)
local k_positive_z = k_positive * 2
local k_positive_y = k_positive_z * k_positive_z

function vlf_vars.get_chunk_number(pos) -- unsigned int
	local c = vlf_vars.pos_to_chunk(pos)
	return
		(c.y + k_positive) * k_positive_y +
		(c.z + k_positive) * k_positive_z +
		 c.x + k_positive
end

if not vlf_vars.superflat and not singlenode then
	-- Normal mode
	--[[ Realm stacking (h is for height)
	- Overworld (h>=256)
	- Void (h>=1000)
	- Realm Barrier (h=11), to allow escaping the End
	- End (h>=256)
	- Void (h>=1000)
	- Nether (h=128)
	- Void (h>=1000)
	]]

	-- Overworld
	vlf_vars.mg_overworld_min = -128
	vlf_vars.mg_overworld_max_official = vlf_vars.mg_overworld_min + minecraft_height_limit
	vlf_vars.mg_bedrock_overworld_min = vlf_vars.mg_overworld_min
	vlf_vars.mg_bedrock_overworld_max = vlf_vars.mg_bedrock_overworld_min + 4
	vlf_vars.mg_lava_overworld_max = vlf_vars.mg_overworld_min + 10
	vlf_vars.mg_lava = true
	vlf_vars.mg_bedrock_is_rough = true

elseif singlenode then
	vlf_vars.mg_overworld_min = -130
	vlf_vars.mg_overworld_min_old = -64
	vlf_vars.mg_overworld_max_official = vlf_vars.mg_overworld_min + minecraft_height_limit
	vlf_vars.mg_bedrock_overworld_min = vlf_vars.mg_overworld_min
	vlf_vars.mg_bedrock_overworld_max = vlf_vars.mg_bedrock_overworld_min
	vlf_vars.mg_lava = false
	vlf_vars.mg_lava_overworld_max = vlf_vars.mg_overworld_min
	vlf_vars.mg_bedrock_is_rough = false
else
	-- Classic superflat
	local ground = minetest.get_mapgen_setting("mgflat_ground_level")
	ground = tonumber(ground)
	if not ground then
		ground = 8
	end
	vlf_vars.mg_overworld_min = ground - 3
	vlf_vars.mg_overworld_min_old = vlf_vars.overworld_min
	vlf_vars.mg_overworld_max_official = vlf_vars.mg_overworld_min + minecraft_height_limit
	vlf_vars.mg_bedrock_overworld_min = vlf_vars.mg_overworld_min
	vlf_vars.mg_bedrock_overworld_max = vlf_vars.mg_bedrock_overworld_min
	vlf_vars.mg_lava = false
	vlf_vars.mg_lava_overworld_max = vlf_vars.mg_overworld_min
	vlf_vars.mg_bedrock_is_rough = false
end

-- mg_overworld_min_old is the overworld min value from before map generation
-- depth was increased. It is used for handling map layers in vlf_worlds. Some
-- mapgens do not set it, so for those we use the mg_overworld_min value.
if not vlf_vars.mg_overworld_min_old then
	vlf_vars.mg_overworld_min_old = vlf_vars.mg_overworld_min
end

vlf_vars.mg_overworld_max = vlf_vars.mapgen_edge_max

-- The Nether (around Y = -29000)
vlf_vars.mg_nether_min = -29067 -- Carefully chosen to be at a mapchunk border
vlf_vars.mg_nether_max = vlf_vars.mg_nether_min + 128
vlf_vars.mg_bedrock_nether_bottom_min = vlf_vars.mg_nether_min
vlf_vars.mg_bedrock_nether_top_max = vlf_vars.mg_nether_max
vlf_vars.mg_nether_deco_max = vlf_vars.mg_nether_max -11 -- this is so ceiling decorations don't spill into other biomes as bedrock generation calls minetest.generate_decorations to put netherrack under the bedrock
if not vlf_vars.superflat then
	vlf_vars.mg_bedrock_nether_bottom_max = vlf_vars.mg_bedrock_nether_bottom_min + 4
	vlf_vars.mg_bedrock_nether_top_min = vlf_vars.mg_bedrock_nether_top_max - 4
	vlf_vars.mg_lava_nether_max = vlf_vars.mg_nether_min + 31
else
	-- Thin bedrock in classic superflat mapgen
	vlf_vars.mg_bedrock_nether_bottom_max = vlf_vars.mg_bedrock_nether_bottom_min
	vlf_vars.mg_bedrock_nether_top_min = vlf_vars.mg_bedrock_nether_top_max
	vlf_vars.mg_lava_nether_max = vlf_vars.mg_nether_min + 2
end
if mg_name == "flat" then
	if vlf_vars.superflat then
		vlf_vars.mg_flat_nether_floor = vlf_vars.mg_bedrock_nether_bottom_max + 4
		vlf_vars.mg_flat_nether_ceiling = vlf_vars.mg_bedrock_nether_bottom_max + 52
	else
		vlf_vars.mg_flat_nether_floor = vlf_vars.mg_lava_nether_max + 4
		vlf_vars.mg_flat_nether_ceiling = vlf_vars.mg_lava_nether_max + 52
	end
end

-- The End (surface at ca. Y = -27000)
vlf_vars.mg_end_min = -27073 -- Carefully chosen to be at a mapchunk border
vlf_vars.mg_end_max_official = vlf_vars.mg_end_min + minecraft_height_limit
vlf_vars.mg_end_max = vlf_vars.mg_overworld_min - 2000
vlf_vars.mg_end_platform_pos = { x = 100, y = vlf_vars.mg_end_min + 64, z = 0 }
vlf_vars.mg_end_exit_portal_pos = vector.new(0, vlf_vars.mg_end_min + 71, 0)

-- Realm barrier used to safely separate the End from the void below the Overworld
vlf_vars.mg_realm_barrier_overworld_end_max = vlf_vars.mg_end_max
vlf_vars.mg_realm_barrier_overworld_end_min = vlf_vars.mg_end_max - 11

-- Use MineClone 2-style dungeons
vlf_vars.mg_dungeons = true

-- Set default stack sizes
minetest.nodedef_default.stack_max = 64
minetest.craftitemdef_default.stack_max = 64

-- Set random seed for all other mods (Remember to make sure no other mod calls this function)
math.randomseed(os.time())

local chunks = {} -- intervals of chunks generated
function vlf_vars.add_chunk(pos)
	local n = vlf_vars.get_chunk_number(pos) -- unsigned int
	local prev
	for i, d in pairs(chunks) do
		if n <= d[2] then -- we've found it
			if (n == d[2]) or (n >= d[1]) then return end -- already here
			if n == d[1]-1 then -- right before:
				if prev and (prev[2] == n-1) then
					prev[2] = d[2]
					table.remove(chunks, i)
					return
				end
				d[1] = n
				return
			end
			if prev and (prev[2] == n-1) then --join to previous
				prev[2] = n
				return
			end
			table.insert(chunks, i, {n, n}) -- insert new interval before i
			return
		end
		prev = d
	end
	chunks[#chunks+1] = {n, n}
end
function vlf_vars.is_generated(pos)
	local n = vlf_vars.get_chunk_number(pos) -- unsigned int
	for i, d in pairs(chunks) do
		if n <= d[2] then
			return (n >= d[1])
		end
	end
	return false
end

-- Do minetest.get_node and if it returns "ignore", then try again after loading
-- its area using a voxel manipulator.
function vlf_vars.get_node(pos)
	local node = minetest.get_node(pos)
	if node.name ~= "ignore" then
		return node
	end

	minetest.get_voxel_manip():read_from_map(pos, pos)
	return minetest.get_node(pos)
end

-- Register ABMs to update from old mapgen depth to new. The ABMs are limited in
-- the Y space meaning they will completely stop once all bedrock and void in
-- the relevant areas is gone.
if vlf_vars.mg_overworld_min_old ~= vlf_vars.mg_overworld_min then
	local function get_mapchunk_area(pos)
		local pos1 = pos:divide(5 * 16):floor():multiply(5 * 16)
		local pos2 = pos1:add(5 * 16 - 1)
		return pos1, pos2
	end

	local void_regen_min_y = vlf_vars.mg_overworld_min
	local void_regen_max_y = math.floor(vlf_vars.mg_overworld_min_old / (5 * 16)) * (5 * 16) - 1
	local bedrock_regen_min_y = void_regen_max_y + 1
	local bedrock_regen_max_y = vlf_vars.mg_overworld_min_old + 4

	local void_replaced = {}
	minetest.register_abm({
		label = "Replace old world depth void",
		name = ":vlf_mapgen_core:replace_old_void",
		nodenames = { "vlf_core:void" },
		chance = 1,
		interval = 10,
		min_y = void_regen_min_y,
		max_y = void_regen_max_y,
		action = function(pos, node)
			local pos1, pos2 = get_mapchunk_area(pos)
			local h = minetest.hash_node_position(pos1)
			if void_replaced[h] then
				return
			end
			void_replaced[h] = true

			pos2.y = math.min(pos2.y, void_regen_max_y)
			minetest.after(0, function()
				minetest.delete_area(pos1, pos2)
			end)
		end
	})

	local bedrock_replaced = {}
	minetest.register_abm({
		label = "Replace old world depth bedrock",
		name = ":vlf_mapgen_core:replace_old_bedrock",
		nodenames = { "vlf_core:void", "vlf_core:bedrock" },
		chance = 1,
		interval = 10,
		min_y = bedrock_regen_min_y,
		max_y = bedrock_regen_max_y,
		action = function(pos, node)
			local pos1, pos2 = get_mapchunk_area(pos)
			local h = minetest.hash_node_position(pos1)
			if bedrock_replaced[h] then
				if node.name == "vlf_core:bedrock" then
					node.name = "vlf_deepslate:deepslate"
					minetest.set_node(pos, node)
				end
				return
			end
			bedrock_replaced[h] = true

			pos1.y = math.max(pos1.y, bedrock_regen_min_y)
			pos2.y = math.min(pos2.y, bedrock_regen_max_y)

			minetest.after(0, function()
				local vm = minetest.get_voxel_manip()
				local emin, emax = vm:read_from_map(pos1, pos2)
				local data = vm:get_data()
				local a = VoxelArea:new{
					MinEdge = emin,
					MaxEdge = emax,
				}

				local c_void = minetest.get_content_id("vlf_core:void")
				local c_bedrock = minetest.get_content_id("vlf_core:bedrock")
				local c_deepslate = minetest.get_content_id("vlf_deepslate:deepslate")

				local n = 0
				for z = pos1.z, pos2.z do
					for y = pos1.y, pos2.y do
						for x = pos1.x, pos2.x do
							local vi = a:index(x, y, z)
							if data[vi] == c_void or data[vi] == c_bedrock then
								n = n + 1
								data[vi] = c_deepslate
							end
						end
					end
				end

				vm:set_data(data)
				vm:write_to_map(true)
			end)
		end
	})
end


minetest.register_globalstep(function(dtime)
	for _, player in ipairs(minetest.get_connected_players()) do
        local pos = player:get_pos()
        	for _, entity in ipairs(minetest.get_objects_inside_radius(pos, 10)) do
			local controls = player:get_player_control()
			--local pos = player:get_pos()
			local node = minetest.get_node(pos)
			local is_in_climable

			if minetest.get_item_group(node.name, "climbable") > 0 then
				if not controls.up and not controls.down and not controls.jump then
					is_in_climable = true
				else
					is_in_climable = true
					minetest.after(1, function()
						is_in_climable = false
					end)
				end
			end
			if is_in_climable == true then
				local vel = player:get_velocity()
				if vel.y > -0.2 then
					player:add_velocity({x = 0, y = -0.2, z = 0})
				end
			end
		end
	end
end)

minetest.register_chatcommand("get_biome_at_pos", {
	params = "",
	description = "Returns the biome name at the users position. Same effect as typing /debug 4 though returns a chat message rather than a hud",
	func = function(name, param)
	local player = minetest.get_player_by_name(name)
	local pos = player:get_pos()
	local biome_data = minetest.get_biome_data(pos)
        if biome_data then
            local biome_name = minetest.get_biome_name(biome_data.biome)
            return true, "Biome at Your pos is: " .. biome_name .. ""
        end
end
})

minetest.register_on_mods_loaded(function()
    local worldpath = minetest.get_worldpath()
    local file_path = worldpath .. "/current_version.lua"
    
    -- Try to open the file for reading
    local file = io.open(file_path, "r")
    
    -- If the file doesn't exist, create it with the default version
    if not file then
        local new_file = io.open(file_path, "w")
        new_file:write("return {\n")
        new_file:write("current_version = { version = '24w39a' }\n")
        new_file:write("}\n")
        new_file:close()
        file = io.open(file_path, "r") -- Reopen the file for reading after creation
    end

    -- Load the table from the Lua file
    local version_data = dofile(file_path)
    file:close() -- Close the file after reading

    -- Check if the file contains valid version data
    if version_data and version_data.current_version and version_data.current_version.version then
        local current_version = version_data.current_version.version
        
        -- If the version isn't 24w41a, handle it as a potential issue
        if current_version ~= "24w39a" then
             local wfile = io.open(file_path, "w")
             wfile:write("return {\n")
             wfile:write("current_version = { version = '24w39a' }\n")
             wfile:write("}\n")
             wfile:close()
            error("This World was last played in version "..tostring(current_version).."; you are on version 24w39a. Please make a backup in case you experience world corruptions. If you would like to proceed anyway, you can click out of this error and reload.")
        --else
            -- If the version is correct, no action needed, but you can update the version if required
            -- Uncomment the lines below to update the version to "24w41a"
        end
    else
        error("Version information is missing or incorrect in current_version.lua")
    end
end)

