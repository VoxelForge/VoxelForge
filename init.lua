hud = {}

-- HUD statbar values
hud.health = {}
hud.air = {}

-- HUD item ids
local health_hud = {}
local air_hud = {}

-- default settings

HUD_SCALEABLE = false
HUD_SIZE = ""

 -- statbar positions
HUD_HEALTH_POS = {x=0.5,y=0.9}
HUD_HEALTH_OFFSET = {x=-175, y=2}
HUD_AIR_POS = {x=0.5,y=0.9}
HUD_AIR_OFFSET = {x=15,y=2}

-- dirty way to check for new statbars
if dump(minetest.hud_replace_builtin) ~= "nil" then
	HUD_SCALEABLE = true
	HUD_SIZE = {x=24, y=24}
	HUD_HEALTH_POS = {x=0.5,y=1}
	HUD_HEALTH_OFFSET = {x=-262, y=-87}
	HUD_AIR_POS = {x=0.5,y=1}
	HUD_AIR_OFFSET = {x=15,y=-87}
end

HUD_TICK = 0.1



--load custom settings
local set = io.open(minetest.get_modpath("hudbars").."/hud.conf", "r")
if set then 
	dofile(minetest.get_modpath("hudbars").."/hud.conf")
	set:close()
end

local function hide_builtin(player)
	 player:hud_set_flags({crosshair = true, hotbar = true, healthbar = false, wielditem = true, breathbar = false})
end


local function custom_hud(player)
 local name = player:get_player_name()

-- fancy hotbar (only when no crafting mod present)
 if minetest.get_modpath("crafting") == nil then
	player:hud_set_hotbar_image("hud_hotbar.png")
	player:hud_set_hotbar_selected_image("hud_hotbar_selected.png")
 end

 if minetest.setting_getbool("enable_damage") then
 --health
        player:hud_add({
		hud_elem_type = "statbar",
		position = HUD_HEALTH_POS,
		size = HUD_SIZE,
		text = "hud_heart_bg.png",
		number = 20,
		alignment = {x=-1,y=-1},
		offset = HUD_HEALTH_OFFSET,
	})
	health_hud[name] = player:hud_add({
		hud_elem_type = "statbar",
		position = HUD_HEALTH_POS,
		size = HUD_SIZE,
		text = "hud_heart_fg.png",
		number = player:get_hp(),
		alignment = {x=-1,y=-1},
		offset = HUD_HEALTH_OFFSET,
	})

 --air
	air_hud[name] = player:hud_add({
		hud_elem_type = "statbar",
		position = HUD_AIR_POS,
		size = HUD_SIZE,
		text = "hud_air_fg.png",
		number = 0,
		alignment = {x=-1,y=-1},
		offset = HUD_AIR_OFFSET,
	})

 end
end


-- update hud elemtens if value has changed
local function update_hud(player)
	local name = player:get_player_name()
 --air
	local air = tonumber(hud.air[name])
	if player:get_breath() ~= air then
		air = player:get_breath()
		hud.air[name] = air
		if air > 10 then air = 0 end
		player:hud_change(air_hud[name], "number", air*2)
	end
 --health
	local hp = tonumber(hud.health[name])
	if player:get_hp() ~= hp then
		hp = player:get_hp()
		hud.health[name] = hp
		player:hud_change(health_hud[name], "number", hp)
	end
end

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	local inv = player:get_inventory()
	hud.health[name] = player:get_hp()
	local air = player:get_breath()
	hud.air[name] = air
	minetest.after(0.5, function()
		hide_builtin(player)
		custom_hud(player)
	end)
end)

minetest.register_on_respawnplayer(function(player)
	-- reset player breath since the engine doesnt
	player:set_breath(11)
end)

local main_timer = 0
local timer = 0
local timer2 = 0
minetest.after(2.5, function()
	minetest.register_globalstep(function(dtime)
	 main_timer = main_timer + dtime
	 timer = timer + dtime
	 timer2 = timer2 + dtime
		if main_timer > HUD_TICK or timer > 4 then
		 if main_timer > HUD_TICK then main_timer = 0 end
		 for _,player in ipairs(minetest.get_connected_players()) do
			local name = player:get_player_name()

			-- only proceed if damage is enabled
			if minetest.setting_getbool("enable_damage") then
			 local hp = player:get_hp()

			 -- update all hud elements
			 update_hud(player)
			
			end
		 end
		
		end
		if timer > 4 then timer = 0 end
	end)
end)
