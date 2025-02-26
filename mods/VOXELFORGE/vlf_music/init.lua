local S = minetest.get_translator(minetest.get_current_modname())

local listeners = {}

-- Registry function for songs, associating biomes with the songs
local song_biomes = {}

local function register_song_for_biomes(song_name, biomes)
	if not song_biomes[song_name] then
		song_biomes[song_name] = {}
	end
	for _, biome in ipairs(biomes) do
		table.insert(song_biomes[song_name], biome)
	end
end

-- Register songs for specific biomes
register_song_for_biomes("echo_in_the_wind", {"Mesa", "CherryGrove", "FlowerForest", "LushCaves"})
register_song_for_biomes("end", {"End"})
register_song_for_biomes("living_mice", {"Mesa", "BambooJungle", "Desert", "FlowerForest", "Forest", "Jungle", "Meadow", "MegaTaiga"})
register_song_for_biomes("oxygene", {"Jungle", "MegaTaiga"})
register_song_for_biomes("concrete_halls", {"BasaltDelta", "CrimsonForest", "Nether", "WarpedForest"})
register_song_for_biomes("bromeliad", {"BambooJungle", "CherryGrove", "FlowerForest", "Forest", "Jungle"})
local biome_names = {}
for name, _ in pairs(minetest.registered_biomes) do
    table.insert(biome_names, name)
end
register_song_for_biomes("a_familiar_room", biome_names)

local function get_player_biome(player)
	local pos = player:get_pos()
	local biome_data = minetest.get_biome_data(pos)
	if pos then
		return minetest.get_biome_name(biome_data.biome)
	end
	return nil
end


-- Get the songs available for the player's biome
local function get_available_songs_for_biome(biome)
	local available_songs = {}
	for song, biomes in pairs(song_biomes) do
		for _, registered_biome in ipairs(biomes) do
			if registered_biome == biome then
				table.insert(available_songs, song)
			end
		end
	end
	return available_songs
end

-- Fade out the music if the player is in the PaleGarden biome
local function handle_pale_garden_biome(player, handle)
	local biome = get_player_biome(player)
	if biome == "PaleGarden" then
		minetest.sound_fade(handle, 0.0, 10)  -- Gradually fade out over 10 seconds
		return true  -- Music is fading out, so we don't need to continue playing it
	end
	return false  -- Continue playing as normal
end
local function pick_track(player, dimension, underground)
	-- For simplicity, we now rely on the biome to pick a track
	local player = minetest.get_player_by_name(player:get_player_name()) -- Get the current player
	local biome = get_player_biome(player)
	local available_songs = get_available_songs_for_biome(biome)

	if #available_songs > 0 then
		local random_index = math.random(1, #available_songs)
		local track = available_songs[random_index]
		minetest.log("action", "[vlf_music] Playing track from biome: " .. track)
		return track
	end

	return nil
end

local function stop_music_for_listener_name(listener_name)
	if not listener_name then return end
	local listener = listeners[listener_name]
	if not listener then return end
	local handle = listener.handle
	if not handle then return end

	minetest.log("action", "[vlf_music] Stopping music")
	minetest.sound_stop(handle)
	listeners[listener_name].handle = nil
end

local function stop_music_for_all()
	for _, player in pairs(minetest.get_connected_players()) do
		local player_name = player:get_player_name()
		stop_music_for_listener_name(player_name)
	end
end

local function play_song(track, player_name, dimension, day_count)
	local spec = {
		name  = track,
		gain  = 0.3,
		pitch = 1.0,
	}
	local parameters = {
		to_player = player_name,
		gain      = 1.0,
		fade      = 0.0,
		pitch     = 1.0,
	}
	local handle = minetest.sound_play(spec, parameters, false)
	listeners[player_name] = {
		handle     = handle,
		dimension  = dimension,
		day_count  = day_count,
	}
end

local function play()
	local time = minetest.get_timeofday()
	if time < 0.25 or time >= 0.75 then
		stop_music_for_all()
		minetest.after(math.random(600, 1200), play)
		return
	end

	local day_count = minetest.get_day_count()
	for _, player in pairs(minetest.get_connected_players()) do
		if not player:get_meta():get("vlf_music:disable") then
			local player_name = player:get_player_name()
			local hp          = player:get_hp()
			local pos         = player:get_pos()
			local dimension   = mcl_worlds.pos_to_dimension(pos)

			local listener      = listeners[player_name]
			local handle = listener and listener.handle

			local old_dimension		= listener and listener.dimension
			local is_dimension_changed = old_dimension and (old_dimension ~= dimension) or false

			if is_dimension_changed then
				stop_music_for_listener_name(player_name)
				if not listeners[player_name] then
					listeners[player_name] = {}
				end
				listeners[player_name].hp = hp
				listeners[player_name].dimension = dimension
			elseif not handle and (not listener or (listener.day_count ~= day_count)) then
				local underground = dimension == "overworld" and pos and pos.y < 0
				local track = pick_track(player, dimension, underground)
				if track then
					play_song(track, player_name, dimension, day_count)
				else
					minetest.log("info", "no track found.")
				end
			else
				if handle and handle_pale_garden_biome(player, handle) then
					-- Music is fading out due to PaleGarden, skip further actions
					listeners[player_name] = nil
				end
			end
		end
	end

	minetest.after(math.random(600, 1200), play)
end
local music_enabled = true
if music_enabled then
	minetest.log("action", "[vlf_music] In-game music is activated")
	minetest.after(math.random(600, 1200), play)

	minetest.register_on_joinplayer(function(player, last_login)
		local player_name = player:get_player_name()
		stop_music_for_listener_name(player_name)
	end)

	minetest.register_on_leaveplayer(function(player, timed_out)
		listeners[player:get_player_name()] = nil
	end)

	minetest.register_on_respawnplayer(function(player)
		local player_name = player:get_player_name()
		stop_music_for_listener_name(player_name)
	end)
else
	minetest.log("action", "[vlf_music] In-game music is deactivated")
end

minetest.register_chatcommand("music", {
	params = "[on|off|invert [<player name>]",
	description = S("Turns music for yourself or another player on or off."),
	func = function(sender_name, params)
		local argtable = {}
		for str in string.gmatch(params, "([^%s]+)") do
			table.insert(argtable, str)
		end

		local action = argtable[1]
		local playername = argtable[2]

		local sender = minetest.get_player_by_name(sender_name)
		local target_player

		if not action or action == "" then action = "invert" end

		if not playername or playername == "" or sender_name == playername then
			target_player = sender
			playername =sender_name
		elseif not minetest.check_player_privs(sender, "debug") then
			minetest.chat_send_player(sender_name, S("You need the debug privilege in order to turn ingame music on or off for somebody else!"))
			return
		else
			target_player = minetest.get_player_by_name(playername)
		end

		if not target_player then
			minetest.chat_send_player(sender_name, S("Couldn't find player @1!", playername))
			return
		end

		local meta = target_player:get_meta()
		local display_new_state

		if action == "invert" then
			if not meta:get("vlf_music:disable") then
				meta:set_int("vlf_music:disable", 1)
				display_new_state = S("off")
			else
				meta:set_string("vlf_music:disable", "")
				display_new_state = S("on")
				minetest.after(1, play)
			end
		elseif action == "on" then
			meta:set_string("vlf_music:disable", "")
			display_new_state = S("on")
			minetest.after(1, play)
		else
			meta:set_int("vlf_music:disable", 1)
			display_new_state = S("off")
		end

		stop_music_for_listener_name(playername)
		minetest.chat_send_player(sender_name, S("Set music for @1 to: @2", playername, display_new_state))
	end,
})
