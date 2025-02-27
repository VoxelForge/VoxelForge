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
dofile(modpath.."/breeze.lua")
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
        minpos = vector.subtract(start_pos, {x = speed, y = speed, z = speed}),
        maxpos = vector.add(start_pos, {x = speed, y = speed, z = speed}),
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

-- 5.11.0 will allow media files. Come 5.11.0 full support this will be removed.
local function is_version_5100_or_lower()
    local version_info = minetest.get_version()
        if not version_info or not version_info.string then
			return false
        end
        local major, minor = version_info.string:match("^(%d+)%.(%d+)")
        major = tonumber(major)
        minor = tonumber(minor)
        return major < 5 or (major == 5 and minor <= 10)
end

minetest.register_on_mods_loaded(function()
	if is_version_5100_or_lower() then
		minetest.settings:set("font_path", modpath.."/fonts/regular.ttf")
    end
end)

minetest.register_on_shutdown(function()
	if is_version_5100_or_lower() then
		minetest.settings:set("font_path", "")
    end
end)

-- Font
minetest.register_on_mods_loaded(function()
	local font_size = minetest.settings:get("vlf_font_size") or 30
	local font_shadow_size = minetest.settings:get("vlf_font_shadow_size") or 3
	local chat_font_size = minetest.settings:get("vlf_chat_font_size") or 24
	minetest.settings:set("font_shadow", font_shadow_size)
	minetest.settings:set("font_size", font_size)
	minetest.settings:set("chat_font_size", chat_font_size)
	minetest.settings:set("font_shadow_alpha", "225")
end)

minetest.register_on_shutdown(function()
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
------------------
--=== COMPAT ===--
------------------

minetest.register_entity(":vlf_mobspawners:doll", {
    initial_properties = {
        physical = true,
        collide_with_objects = true,
        collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.8, 0.3},
        visual = "sprite",
        textures = {"blank.png"},
        makes_footstep_sound = true,
    },

    on_activate = function(self, staticdata, dtime_s)
        -- Preserve original entity properties
        local properties = self.object:get_properties()

        -- Remove the old entity
        local pos = self.object:get_pos()
        self.object:remove()

        -- Spawn the new entity with the same properties
        local new_entity = minetest.add_entity(pos, "mcl_mobspawners:doll")
        if new_entity then
            new_entity:set_properties(properties)
        end
    end,
})


local function register_vlf_entities()
    for name, def in pairs(minetest.registered_entities) do
        local vlf_name = name:gsub("^mcl_", "vlf_")
        if not minetest.registered_entities[vlf_name] then
            minetest.register_entity(":"..vlf_name, {
                on_activate = function(self, staticdata, dtime_s)
                    local new_name = self.name:gsub("^vlf_", "mcl_")
                    if minetest.registered_entities[new_name] then
                        local pos = self.object:get_pos()
                        local velocity = self.object:get_velocity()
                        local yaw = self.object:get_yaw()
                        local properties = self.object:get_properties()

                        for k, v in pairs(properties) do
                            if type(v) == "string" then
                                properties[k] = v:gsub("vlf", "mcl")
                            end
                        end

                        self.object:remove()
                        local new_obj = minetest.add_entity(pos, name)
                        if new_obj then
                            local new_entity = new_obj:get_luaentity()
                            if new_entity then
                                new_obj:set_velocity(velocity)
                                new_obj:set_yaw(yaw)
                                new_obj:set_properties(properties)
                            end
                        end
                    end
                end,
            })
        end
    end
end

register_vlf_entities()

for i = 1,4 do
minetest.register_node(":voxelforge:pink_petal_"..i, {
	description = ("Pink Petal"),
	drawtype = "mesh",
	tiles = {"mcl_cherry_blossom_pink_petals.png", "wildflower_stem.png"},
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "none",
	mesh = "wildflower_"..i..".obj",
	walkable = false,
	climbable = false,
	buildable_to = true,
    selection_box = {type = "fixed", fixed = {-1/2, -1/2, -1/2, 1/2, -5/16, 1/2}},
	groups = {
		handy = 1, shearsy = 1, hoey = 1, swordy = 1, deco_block = 1, flammable=3, attached_node=1, compostability=30,
		dig_by_piston = 1, pinkpetal = i, attached_block = 1, dig_by_water = 1, destroy_by_lava_flow = 1, not_in_creative_inventory=1
	},
	drop = "voxelforge:pink_petal " ..i,
	_mcl_shears_drop = true,
	node_placement_prediction = "",
	_mcl_blast_resistance = 0.0,
	_mcl_hardness = 0.0,
	use_texture_alpha = true,
	on_rotate = false,
	_on_bone_meal = function(_, _, _ , pos, n)
		minetest.add_item(pos,"voxelforge:pink_petals")
	end,
})
end
-- pinkpetals.

minetest.register_craftitem(":voxelforge:pinkpetals", {
    description = "Pink Petals",
    inventory_image = "mcl_cherry_blossom_pink_petals_inv.png",
    wield_image = "mcl_cherry_blossom_pink_petals_inv.png",
    groups = {craftitem=1},

    on_place = function(itemstack, placer, pointed_thing)
        if not pointed_thing or not pointed_thing.under then
            return itemstack
        end

        local pos = pointed_thing.under
        local node = minetest.get_node(pos)
        local above_pos = {x=pos.x, y=pos.y+1, z=pos.z}
        local above_node = minetest.get_node(above_pos)
        local node_def = minetest.registered_nodes[node.name]

        -- Swap the node in place if it's part of the progression
        local swap_map = {
            ["voxelforge:pink_petal_1"] = "voxelforge:pink_petal_2",
            ["voxelforge:pink_petal_2"] = "voxelforge:pink_petal_3",
            ["voxelforge:pink_petal_3"] = "voxelforge:pink_petal_4",
        }

        if swap_map[node.name] then
            minetest.set_node(pos, {name = swap_map[node.name]})
        else
            -- If not already part of the cycle, place _1 above
            if above_node.name == "air" and not (node_def and node_def.groups and node_def.groups.pinkpetal and node_def.groups.pinkpetal > 0 and node_def.groups.pinkpetal < 5) then
                minetest.set_node(above_pos, {name = "voxelforge:pink_petal_1"})
            end
        end

        return itemstack
    end
})

minetest.register_decoration({
		deco_type = "simple",
		place_on = {"mcl_core:dirt_with_grass"},
		fill_ratio = 0.15,
		biomes = {"CherryGrove"},
		y_min = mcl_vars.mg_overworld_min,
		y_max = mcl_vars.mg_overworld_max,
		decoration = "voxelforge:pink_petal_1",
})
minetest.register_decoration({
		deco_type = "simple",
		place_on = {"mcl_core:dirt_with_grass"},
		fill_ratio = 0.15,
		biomes = {"CherryGrove"},
		y_min = mcl_vars.mg_overworld_min,
		y_max = mcl_vars.mg_overworld_max,
		decoration = "voxelforge:pink_petal_2",
})
minetest.register_decoration({
		deco_type = "simple",
		place_on = {"mcl_core:dirt_with_grass"},
		fill_ratio = 0.15,
		biomes = {"CherryGrove"},
		y_min = mcl_vars.mg_overworld_min,
		y_max = mcl_vars.mg_overworld_max,
		decoration = "voxelforge:pink_petal_3",
})
minetest.register_decoration({
		deco_type = "simple",
		place_on = {"mcl_core:dirt_with_grass"},
		fill_ratio = 0.15,
		biomes = {"CherryGrove"},
		y_min = mcl_vars.mg_overworld_min,
		y_max = mcl_vars.mg_overworld_max,
		decoration = "voxelforge:pink_petal_4",
})

minetest.register_alias("mcl_cherry_blossom:pink_petals", "voxelforge:pink_petal_4")
