hud = {}

-- HUD statbar values
hud.health = {}
hud.air = {}

hud.hudtables = {}

-- number of registered HUD bars
hud.hudbars_count = 0

-- HUD item ids
local health_hud = {}
local health_hud_text = {}
local health_hud_icon = {}
local health_hud_bg = {}
local air_hud = {}
local air_hud_text = {}
local air_hud_icon = {}
local air_hud_bg = {}

-- default settings

HUD_SCALEABLE = false
HUD_BARLENGTH = 160

 -- statbar positions
HUD_HEALTH_POS = {x=0.5,y=0.9}
HUD_HEALTH_OFFSET = {x=-175, y=2}
HUD_AIR_POS = {x=0.5,y=0.9}
HUD_AIR_OFFSET = {x=15,y=2}

-- dirty way to check for new statbars
if dump(minetest.hud_replace_builtin) ~= "nil" then
	HUD_SCALEABLE = true
	HUD_HEALTH_POS = {x=0.5,y=1}
	HUD_HEALTH_OFFSET = {x=-175, y=-70}
	HUD_AIR_POS = {x=0.5,y=1}
	HUD_AIR_OFFSET = {x=15,y=-70}
end

HUD_CUSTOM_POS_LEFT = HUD_HEALTH_POS
HUD_CUSTOM_POS_RIGHT = HUD_AIR_POS

HUD_CUSTOM_VMARGIN = 24
if minetest.setting_getbool("enable_damage") then
	HUD_CUSTOM_START_OFFSET_LEFT = {x=HUD_HEALTH_OFFSET.x, y=HUD_HEALTH_OFFSET.y - HUD_CUSTOM_VMARGIN}
	HUD_CUSTOM_START_OFFSET_RIGHT = {x=HUD_AIR_OFFSET.x, y=HUD_AIR_OFFSET.y - HUD_CUSTOM_VMARGIN}
else
	HUD_CUSTOM_START_OFFSET_LEFT = {x=HUD_HEALTH_OFFSET.x, y=HUD_HEALTH_OFFSET.y }
	HUD_CUSTOM_START_OFFSET_RIGHT = {x=HUD_AIR_OFFSET.x, y=HUD_AIR_OFFSET.y }
end

HUD_TICK = 0.1

function hud.value_to_barlength(value, max)
	if max == 0 then
		return 0
	else
		return math.ceil((value/max) * HUD_BARLENGTH)
	end
end

function hud.get_hudtable(identifier)
	return hud.hudtables[identifier]
end

function hud.register_hudbar(identifier, text_color, label, textures, default_start_value, default_start_max, start_hide, format_string)
	local hudtable = {}
	local pos, offset
	if hud.hudbars_count % 2 == 0 then
		pos = HUD_CUSTOM_POS_LEFT
		offset = {
			x = HUD_CUSTOM_START_OFFSET_LEFT.x,
			y = HUD_CUSTOM_START_OFFSET_LEFT.y - HUD_CUSTOM_VMARGIN * math.floor(hud.hudbars_count/2)
		}
	else
		pos = HUD_CUSTOM_POS_RIGHT
		offset = {
			x = HUD_CUSTOM_START_OFFSET_RIGHT.x,
			y = HUD_CUSTOM_START_OFFSET_RIGHT.y - HUD_CUSTOM_VMARGIN * math.floor((hud.hudbars_count-1)/2)
		}
	end
	if format_string == nil then
		format_string = "%s: %d/%d"
	end

	hudtable.add_all = function(player, start_value, start_max)
		if start_value == nil then start_value = default_start_value end
		if start_max == nil then start_max = default_start_max end
		local ids = {}
		local state = {}
		local name = player:get_player_name()
		local bgscale
		if start_max == 0 then
			bgscale = { x=0, y=0 }
		else
			bgscale = { x=1, y=1 }
		end
		ids.bg = player:hud_add({
			hud_elem_type = "image",
			position = pos,
			scale = bgscale,
			text = "hudbars_bar_background.png",
			alignment = {x=1,y=1},
			offset = { x = offset.x - 1, y = offset.y - 1 },
		})
		if textures.icon ~= nil then
			ids.icon = player:hud_add({
				hud_elem_type = "image",
				position = pos,
				scale = { x = 1, y = 1 },
				text = textures.icon,
				alignment = {x=-1,y=1},
				offset = { x = offset.x - 3, y = offset.y },
			})
		end
		ids.bar = player:hud_add({
			hud_elem_type = "statbar",
			position = pos,
			text = textures.bar,
			number = hud.value_to_barlength(start_value, start_max),
			alignment = {x=-1,y=-1},
			offset = offset,
		})
		ids.text = player:hud_add({
			hud_elem_type = "text",
			position = pos,
			text = tostring(string.format(format_string, label, start_value, start_max)),
			alignment = {x=1,y=1},
			number = text_color,
			direction = 0,
			offset = { x = offset.x + 2,  y = offset.y },
		})
		state.hidden = start_hide
		state.value = start_value
		state.max = start_max

		hud.hudtables[identifier].hudids[name] = ids
		hud.hudtables[identifier].hudstate[name] = state
	end

	hudtable.identifier = identifier
	hudtable.format_string = format_string
	hudtable.label = label
	hudtable.hudids = {}
	hudtable.hudstate = {}

	hud.hudbars_count= hud.hudbars_count + 1
	
	hud.hudtables[identifier] = hudtable
end

function hud.change_hudbar(player, identifier, new_value, new_max_value)
	local name = player:get_player_name()
	local hudtable = hud.get_hudtable(identifier)
	hudtable.hudstate[name].value = new_value
	hudtable.hudstate[name].max = new_max_value
	if hudtable.hudstate[name].hidden == false then
		if hudtable.hudstate[name].max == 0 then
			player:hud_change(hudtable.hudids[name].bg, "scale", {x=0,y=0})
		else
			player:hud_change(hudtable.hudids[name].bg, "scale", {x=1,y=1})
		end
		player:hud_change(hudtable.hudids[name].bar, "number", hud.value_to_barlength(new_value, new_max_value))
		player:hud_change(hudtable.hudids[name].text, "text",
			tostring(string.format(hudtable.format_string, hudtable.label, new_value, new_max_value))
		)
	end
end

function hud.hide_hudbar(player, identifier)
	local name = player:get_player_name()
	local hudtable = hud.get_hudtable(identifier)
	if(hudtable.hudstate[name].hidden == false) then
		player:hud_change(hudtable.hudids[name].icon, "scale", {x=0,y=0})
		player:hud_change(hudtable.hudids[name].bg, "scale", {x=0,y=0})
		player:hud_change(hudtable.hudids[name].bar, "number", 0)
		player:hud_change(hudtable.hudids[name].text, "text", "")
		hudtable.hudstate[name].hidden = true
	end
end

function hud.unhide_hudbar(player, identifier)
	local name = player:get_player_name()
	local hudtable = hud.get_hudtable(identifier)
	if(hudtable.hudstate[name].hidden) then
		local name = player:get_player_name()
		local value = hudtable.hudstate[name].value
		local max = hudtable.hudstate[name].max
		player:hud_change(hudtable.hudids[name].icon, "scale", {x=1,y=1})
		if hudtable.hudstate[name].max ~= 0 then
			player:hud_change(hudtable.hudids[name].bg, "scale", {x=1,y=1})
		end
		player:hud_change(hudtable.hudids[name].bar, "number", hud.value_to_barlength(value, max))
		player:hud_change(hudtable.hudids[name].text, "text", tostring(string.format(hudtable.format_string, hudtable.label, value, max)))
		hudtable.hudstate[name].hidden = false
	end
end


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

 if minetest.setting_getbool("enable_damage") then
 --health
	health_hud_icon[name] = player:hud_add({
		hud_elem_type = "image",
		position = HUD_HEALTH_POS,
		scale = { x = 1, y = 1 },
		text = "hudbars_icon_health.png",
		alignment = {x=-1,y=1},
		offset = { x = HUD_HEALTH_OFFSET.x - 3, y = HUD_HEALTH_OFFSET.y },
	})
	health_hud_bg[name] = player:hud_add({
		hud_elem_type = "image",
		position = HUD_HEALTH_POS,
		scale = { x = 1, y = 1 },
		text = "hudbars_bar_background.png",
		alignment = {x=1,y=1},
		offset = { x = HUD_HEALTH_OFFSET.x - 1, y = HUD_HEALTH_OFFSET.y - 1 },
	})
	health_hud[name] = player:hud_add({
		hud_elem_type = "statbar",
		position = HUD_HEALTH_POS,
		text = "hudbars_bar_health.png",
		number = hud.value_to_barlength(player:get_hp(), 20),
		alignment = {x=-1,y=-1},
		offset = HUD_HEALTH_OFFSET,
	})
	health_hud_text[name] = player:hud_add({
		hud_elem_type = "text",
		position = HUD_HEALTH_POS,
		text = tostring(string.format("Health: %d/%d", player:get_hp(), 20)),
		alignment = {x=1,y=1},
		number = 0xFFFFFF,
		direction = 0,
		offset = { x = HUD_HEALTH_OFFSET.x + 2,  y = HUD_HEALTH_OFFSET.y },
	})

 --air
	local airnumber, airtext, airscale
	local air = player:get_breath()
	if air == 11 then
		airnumber = 0
		airtext = ""
		airscale = {x=0, y=0}
	else
		airnumber = hud.value_to_barlength(math.min(air, 10), 10)
		airtext = tostring(string.format("Breath: %d/%d", math.min(air, 10), 10))
		airscale = {x=1, y=1}
	end
	air_hud_icon[name] = player:hud_add({
		hud_elem_type = "image",
		position = HUD_AIR_POS,
		scale = airscale,
		text = "hudbars_icon_breath.png",
		alignment = {x=-1,y=1},
		offset = { x = HUD_AIR_OFFSET.x - 3, y = HUD_AIR_OFFSET.y },
	})
	air_hud_bg[name] = player:hud_add({
		hud_elem_type = "image",
		position = HUD_AIR_POS,
		scale = airscale,
		text = "hudbars_bar_background.png",
		alignment = {x=1,y=1},
		offset = { x = HUD_AIR_OFFSET.x - 1, y = HUD_AIR_OFFSET.y - 1 },
	})
	air_hud[name] = player:hud_add({
		hud_elem_type = "statbar",
		position = HUD_AIR_POS,
		text = "hudbars_bar_breath.png",
		number = airnumber,
		alignment = {x=-1,y=-1},
		offset = HUD_AIR_OFFSET,
	})
	air_hud_text[name] = player:hud_add({
		hud_elem_type = "text",
		position = HUD_AIR_POS,
		text = airtext,
		alignment = {x=1,y=1},
		number = 0xFFFFFF,
		direction = 0,
		offset = { x = HUD_AIR_OFFSET.x + 2,  y = HUD_AIR_OFFSET.y },
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
		local airnumber, airtext, airscale
		if air == 11 then
			airnumber = 0
			airtext = ""
			airscale = {x=0, y=0}
		else
			airnumber = hud.value_to_barlength(math.min(air, 10), 10)
			airtext = tostring(string.format("Breath: %d/%d", math.min(player:get_breath(), 10), 10))
			airscale = {x=1, y=1}
		end
		player:hud_change(air_hud[name], "number", airnumber)
		player:hud_change(air_hud_text[name], "text", airtext)
		player:hud_change(air_hud_icon[name], "scale", airscale)
		player:hud_change(air_hud_bg[name], "scale", airscale)
	end
 --health
	local hp = tonumber(hud.health[name])
	if player:get_hp() ~= hp then
		hp = player:get_hp()
		hud.health[name] = hp
		player:hud_change(health_hud[name], "number", hud.value_to_barlength(hp, 20))
		player:hud_change(health_hud_text[name], "text",
			tostring(string.format("Health: %d/%d", hp, 20))
		)
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
