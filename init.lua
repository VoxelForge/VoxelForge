hb = {}

hb.hudtables = {}

-- number of registered HUD bars
hb.hudbars_count = 0

-- default settings
HUD_BARLENGTH = 160

-- statbar positions
HUD_START_OFFSET_LEFT = { x = -175, y = -70 }
HUD_START_OFFSET_RIGHT = { x = 15, y = -70 }
HUD_POS_LEFT = { x=0.5, y=1 }
HUD_POS_RIGHT = { x = 0.5, y = 1 }

HUD_VMARGIN = 24
HUD_TICK = 0.1

function hb.value_to_barlength(value, max)
	if max == 0 then
		return 0
	else
		return math.ceil((value/max) * HUD_BARLENGTH)
	end
end

function hb.get_hudtable(identifier)
	return hb.hudtables[identifier]
end

function hb.register_hudbar(identifier, text_color, label, textures, default_start_value, default_start_max, start_hidden, format_string)
	local hudtable = {}
	local pos, offset
	if hb.hudbars_count % 2 == 0 then
		pos = HUD_POS_LEFT
		offset = {
			x = HUD_START_OFFSET_LEFT.x,
			y = HUD_START_OFFSET_LEFT.y - HUD_VMARGIN * math.floor(hb.hudbars_count/2)
		}
	else
		pos = HUD_POS_RIGHT
		offset = {
			x = HUD_START_OFFSET_RIGHT.x,
			y = HUD_START_OFFSET_RIGHT.y - HUD_VMARGIN * math.floor((hb.hudbars_count-1)/2)
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
		local bgscale, iconscale, text, barnumber
		if start_max == 0 or start_hidden then
			bgscale = { x=0, y=0 }
		else
			bgscale = { x=1, y=1 }
		end
		if start_hidden then
			iconscale = { x=0, y=0 }
			barnumber = 0
			text = ""
		else
			iconscale = { x=1, y=1 }
			barnumber = hb.value_to_barlength(start_value, start_max)
			text = string.format(format_string, label, start_value, start_max)
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
				scale = iconscale,
				text = textures.icon,
				alignment = {x=-1,y=1},
				offset = { x = offset.x - 3, y = offset.y },
			})
		end
		ids.bar = player:hud_add({
			hud_elem_type = "statbar",
			position = pos,
			text = textures.bar,
			number = barnumber,
			alignment = {x=-1,y=-1},
			offset = offset,
		})
		ids.text = player:hud_add({
			hud_elem_type = "text",
			position = pos,
			text = text,
			alignment = {x=1,y=1},
			number = text_color,
			direction = 0,
			offset = { x = offset.x + 2,  y = offset.y },
		})
		-- Do not forget to update hb.get_hudbar_state if you add new fields to the state table
		state.hidden = start_hidden
		state.value = start_value
		state.max = start_max
		state.text = text
		state.barlength = hb.value_to_barlength(start_value, start_max)

		hb.hudtables[identifier].hudids[name] = ids
		hb.hudtables[identifier].hudstate[name] = state
	end

	hudtable.identifier = identifier
	hudtable.format_string = format_string
	hudtable.label = label
	hudtable.hudids = {}
	hudtable.hudstate = {}

	hb.hudbars_count= hb.hudbars_count + 1
	
	hb.hudtables[identifier] = hudtable
end

function hb.init_hudbar(player, identifier, start_value, start_max)
	hb.hudtables[identifier].add_all(player, start_value, start_max)
end

function hb.change_hudbar(player, identifier, new_value, new_max_value)
	if new_value == nil and new_max_value == nil then
		return
	end

	local name = player:get_player_name()
	local hudtable = hb.get_hudtable(identifier)
	local value_changed, max_changed = false, false

	if new_value ~= nil then
		if new_value ~= hudtable.hudstate[name].value then
			hudtable.hudstate[name].value = new_value
			value_changed = true
		end
	else
		new_value = hudtable.hudstate[name].value
	end
	if new_max_value ~= nil then
		if new_max_value ~= hudtable.hudstate[name].max then
			hudtable.hudstate[name].max = new_max_value
			max_changed = true
		end
	else
		new_max_value = hudtable.hudstate[name].max
	end

	if hudtable.hudstate[name].hidden == false then
		if max_changed then
			if hudtable.hudstate[name].max == 0 then
				player:hud_change(hudtable.hudids[name].bg, "scale", {x=0,y=0})
			else
				player:hud_change(hudtable.hudids[name].bg, "scale", {x=1,y=1})
			end
		end

		if value_changed or max_changed then
			local new_barlength = hb.value_to_barlength(new_value, new_max_value)
			if new_barlength ~= hudtable.hudstate[name].barlength then
				player:hud_change(hudtable.hudids[name].bar, "number", hb.value_to_barlength(new_value, new_max_value))
				hudtable.hudstate[name].barlength = new_barlength
			end

			local new_text = string.format(hudtable.format_string, hudtable.label, new_value, new_max_value)
			if new_text ~= hudtable.hudstate[name].text then
				player:hud_change(hudtable.hudids[name].text, "text", new_text)
				hudtable.hudstate[name].text = new_text
			end
		end
	end
end

function hb.hide_hudbar(player, identifier)
	local name = player:get_player_name()
	local hudtable = hb.get_hudtable(identifier)
	if(hudtable.hudstate[name].hidden == false) then
		if hudtable.hudids[name].icon ~= nil then
			player:hud_change(hudtable.hudids[name].icon, "scale", {x=0,y=0})
		end
		player:hud_change(hudtable.hudids[name].bg, "scale", {x=0,y=0})
		player:hud_change(hudtable.hudids[name].bar, "number", 0)
		player:hud_change(hudtable.hudids[name].text, "text", "")
		hudtable.hudstate[name].hidden = true
	end
end

function hb.unhide_hudbar(player, identifier)
	local name = player:get_player_name()
	local hudtable = hb.get_hudtable(identifier)
	if(hudtable.hudstate[name].hidden) then
		local name = player:get_player_name()
		local value = hudtable.hudstate[name].value
		local max = hudtable.hudstate[name].max
		if hudtable.hudids[name].icon ~= nil then
			player:hud_change(hudtable.hudids[name].icon, "scale", {x=1,y=1})
		end
		if hudtable.hudstate[name].max ~= 0 then
			player:hud_change(hudtable.hudids[name].bg, "scale", {x=1,y=1})
		end
		player:hud_change(hudtable.hudids[name].bar, "number", hb.value_to_barlength(value, max))
		player:hud_change(hudtable.hudids[name].text, "text", tostring(string.format(hudtable.format_string, hudtable.label, value, max)))
		hudtable.hudstate[name].hidden = false
	end
end

function hb.get_hudbar_state(player, identifier)
	local ref = hb.get_hudtable(identifier).hudstate[player:get_player_name()]
	-- Do not forget to update this chunk of code in case the state changes
	local copy = {
		hidden = ref.hidden,
		value = ref.value,
		max = ref.max,
		text = ref.text,
		barlength = ref.barlength,
	}
	return copy
end

--register built-in HUD bars
if minetest.setting_getbool("enable_damage") then
	hb.register_hudbar("health", 0xFFFFFF, "Health", { bar = "hudbars_bar_health.png", icon = "hudbars_icon_health.png" }, 20, 20, false)
	hb.register_hudbar("breath", 0xFFFFFF, "Breath", { bar = "hudbars_bar_breath.png", icon = "hudbars_icon_breath.png" }, 10, 10, true)
end

--load custom settings
local set = io.open(minetest.get_modpath("hudbars").."/hudbars.conf", "r")
if set then 
	dofile(minetest.get_modpath("hudbars").."/hudbars.conf")
	set:close()
end

local function hide_builtin(player)
	 player:hud_set_flags({healthbar = false, breathbar = false})
end


local function custom_hud(player)
	if minetest.setting_getbool("enable_damage") then
		hb.init_hudbar(player, "health", player:get_hp())
		hb.init_hudbar(player, "breath", player:get_breath())
	end
end


-- update built-in HUD bars
local function update_hud(player)
	if minetest.setting_getbool("enable_damage") then
		--air
		local air = player:get_breath()
		
		if air == 11 then
			hb.hide_hudbar(player, "breath")
		else
			hb.unhide_hudbar(player, "breath")
			hb.change_hudbar(player, "breath", air)
		end
		
		--health
		hb.change_hudbar(player, "health", player:get_hp())
	end
end

minetest.register_on_joinplayer(function(player)
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
			-- only proceed if damage is enabled
			if minetest.setting_getbool("enable_damage") then
			 -- update all hud elements
			 update_hud(player)
			end
		 end
		
		end
		if timer > 4 then timer = 0 end
	end)
end)
