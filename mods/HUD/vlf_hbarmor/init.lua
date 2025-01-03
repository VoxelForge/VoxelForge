local S = minetest.get_translator(minetest.get_current_modname())

local vlf_hbarmor = {
    -- HUD statbar values
    armor = {},
    -- Stores if player's HUD bar has been initialized so far.
    player_active = {},
    -- Time difference in seconds between updates to the HUD armor bar.
    -- Increase this number for slow servers.
    tick = 0.1,
    -- If true, the armor bar is hidden when the player does not wear any armor
    autohide = true,
}

local tick_config = minetest.settings:get("vlf_hbarmor_tick")

if tonumber(tick_config) then
	vlf_hbarmor.tick = tonumber(tick_config)
end


local function must_hide(_, arm)
	return arm == 0
end

local function arm_printable(arm)
	return math.ceil(math.floor(arm+0.5))
end

local function custom_hud(player)
	local name = player:get_player_name()

	if minetest.settings:get_bool("enable_damage") then
		local ret = vlf_hbarmor.get_armor(player)
		if ret == false then
			minetest.log("error", "[vlf_hbarmor] Call to vlf_hbarmor.get_armor in custom_hud returned with false!")
			return
		end
		local arm = tonumber(vlf_hbarmor.armor[name])
		if not arm then
			arm = 0
		end
		local hide
		if vlf_hbarmor.autohide then
			hide = must_hide(name, arm)
		else
			hide = false
		end
		hb.init_hudbar(player, "armor", arm_printable(arm), nil, hide)
	end
end

--register and define armor HUD bar
hb.register_hudbar("armor", 0xFFFFFF, S("Armor"), { icon = "hbarmor_icon.png", bgicon = "hbarmor_bgicon.png", bar = "hbarmor_bar.png" }, 0, 20, vlf_hbarmor.autohide)

function vlf_hbarmor.get_armor(player)
	local name = player:get_player_name()
	local pts = player:get_meta():get_int("vlf_armor:armor_points")
	if not pts then
		return false
	else
		vlf_hbarmor.set_armor(name, pts)
	end
	return true
end

function vlf_hbarmor.set_armor(player_name, pts)
	vlf_hbarmor.armor[player_name] = math.max(0, math.min(20, pts))
end

-- update hud elemtens if value has changed
local function update_hud(player)
	local name = player:get_player_name()
	--armor
	local arm = tonumber(vlf_hbarmor.armor[name])
	if not arm then
		arm = 0
		vlf_hbarmor.armor[name] = 0
	end
	if vlf_hbarmor.autohide then
		-- hide armor bar completely when there is none
		if must_hide(name, arm) then
			hb.hide_hudbar(player, "armor")
		else
			hb.change_hudbar(player, "armor", arm_printable(arm))
			hb.unhide_hudbar(player, "armor")
		end
	else
		hb.change_hudbar(player, "armor", arm_printable(arm))
	end
end

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	custom_hud(player)
	vlf_hbarmor.player_active[name] = true
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	vlf_hbarmor.player_active[name] = false
end)

local main_timer = 0
local timer = 0
minetest.register_globalstep(function(dtime)
    --TODO: replace this by playerglobalstep API then implemented
	main_timer = main_timer + dtime
	timer = timer + dtime
	if main_timer > vlf_hbarmor.tick or timer > 4 then
		if minetest.settings:get_bool("enable_damage") then
			if main_timer > vlf_hbarmor.tick then main_timer = 0 end
			for player in vlf_util.connected_players() do
				local name = player:get_player_name()
				if vlf_hbarmor.player_active[name] == true then
					local ret = vlf_hbarmor.get_armor(player)
					if ret == false then
						minetest.log("error", "[vlf_hbarmor] Call to vlf_hbarmor.get_armor in globalstep returned with false!")
					end
					-- update all hud elements
					update_hud(player)
				end
			end
		end
	end
	if timer > 4 then timer = 0 end
end)
