--===============--
--=== Globals ===--
--===============--
particles = {}
voxelforge = {}
--==============--
--=== Locals ===--
--==============--
local modpath = minetest.get_modpath("voxelforge")
--==============--
--=== Dofile ===--
--==============--
dofile(modpath.."/advancements.lua")
dofile(modpath.."/biomes.lua")
dofile(modpath.."/effects.lua")
dofile(modpath.."/potions.lua")
dofile(modpath.."/torchflower.lua")
dofile(modpath.."/vlf_compat.lua")

--=================--
--=== Functions ===--
--=================--
function particles.trail(start_pos, target_pos, color, a_type, attraction, speed)
	local attract
	if a_type == "in" then
		attract = attraction
	elseif a_type == "out" then
		attract = -attraction
	else
		attract = 0
	end
	local speed = 0.2
    -- Add a particle spawner with custom start position, target position, and color
    return minetest.add_particlespawner({
        amount = math.random(20, 40),
        time = 4,
        minpos = vector.subtract(start_pos, {x = speed.x, y = speed.y, z = speed.z}),
        maxpos = vector.add(start_pos, {x = speed.x, y = speed.y, z = speed.z}),
        minvel = vector.multiply(vector.direction(start_pos, target_pos), 3.0),
        maxvel = vector.multiply(vector.direction(start_pos, target_pos), 5.0),
        glow = 8,
        minacc = {x = 0, y = 0, z = 0},
        maxacc = {x = 0, y = 0, z = 0},
        minexptime = 5, -- Particles stay until they hit target
        maxexptime = 5,
        minsize = 0.5,
        maxsize = 1,
        attract = {kind = "point", strength = attract, origin = start_pos},
        texture = "blank.png^[noalpha^[colorize:" .. color .. ":255", -- Dynamic colorization
    })
end

function voxelforge.play_sound(sound_name, pos, max_distance, gain)
    for _, player in ipairs(minetest.get_connected_players()) do
        local player_pos = player:get_pos()
        local distance = vector.distance(pos, player_pos)

        if distance < max_distance then
            local new_gain = gain * (1 - (distance / max_distance))  -- Scale gain based on distance
            minetest.sound_play(sound_name, {
                pos = pos,
                gain = math.max(new_gain, 0),  -- Ensure gain never goes negative
                max_hear_distance = max_distance,
            }, true)  -- Ephemeral sound (doesn't track entity)
        end
    end
end

--TODO: Remove after version 25w09a
minetest.register_on_joinplayer(function(player)
    minetest.chat_send_player(player:get_player_name(),
        minetest.colorize("#FF50FF", "THIS VERSION MAY BE BUGGY, PATCH RELEASES ARE PLANNED BETWEEN 02/13/25 TO 02/26/25. PLEASE REPORT ALL BUGS TO: https://github.com/VoxelForge/VoxelForge/issues")
    )
end)
-- Font
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
-- Chat Hud.
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
	add_chat_message("", minetest.colorize("#FF50FF", "THIS VERSION MAY BE BUGGY, PATCH RELEASES ARE PLANNED BETWEEN 02/13/25 TO 02/26/25. PLEASE REPORT ALL BUGS TO: https://github.com/VoxelForge/VoxelForge/issues"))
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
-- Version Warning.
minetest.register_on_mods_loaded(function()
    local worldpath = minetest.get_worldpath()
    local file_path = worldpath .. "/current_version.lua"

    -- Try to open the file for reading
    local file = io.open(file_path, "r")

    -- If the file doesn't exist, create it with the default version
    if not file then
        local new_file = io.open(file_path, "w")
        new_file:write("return {\n")
        new_file:write("current_version = { version = '25w07a' }\n")
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

        -- If the version isn't 25w07a, handle it as a potential issue
        if current_version ~= "25w07a" then
             local wfile = io.open(file_path, "w")
             wfile:write("return {\n")
             wfile:write("current_version = { version = '25w07a' }\n")
             wfile:write("}\n")
             wfile:close()
            error("This World was last played in version "..tostring(current_version).."; you are on Experimental Snapshot 25w07a. Please make a backup in case you experience world corruptions. If you would like to proceed anyway, you can click out of this error and reload.")
        end
    else
        error("Version information is missing or incorrect in current_version.lua")
    end
end)
