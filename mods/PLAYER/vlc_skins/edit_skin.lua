local S = minetest.get_translator("vlc_skins")
local C = minetest.colorspec_to_colorstring

vlc_skins = {
	simple_skins = {},
	texture_to_simple_skin = {},
	item_names = {"base", "footwear", "eye", "mouth", "bottom", "top", "hair", "headwear"},
	tab_names = {"skin", "template", "base", "headwear", "hair", "eye", "mouth", "top", "arm", "bottom", "footwear"},
	tab_descriptions = {
		template = S("Templates"),
		arm = S("Arm size"),
		base = S("Bases"),
		footwear = S("Footwears"),
		eye = S("Eyes"),
		mouth = S("Mouths"),
		bottom = S("Bottoms"),
		top = S("Tops"),
		hair = S("Hairs"),
		headwear = S("Headwears"),
		skin = S("Skins"),
	},
	steve = {}, -- Stores skin values for Steve skin
	alex = {}, -- Stores skin values for Alex skin
	base = {}, -- List of base textures

	-- Base color is separate to keep the number of junk nodes registered in check
	base_color = {0xffeeb592, 0xffb47a57, 0xff8d471d},
	color = {
		0xff613915, -- 1 Dark brown
		0xff97491b, -- 2 Medium brown
		0xffb17050, -- 3 Light brown
		0xffe2bc7b, -- 4 Beige
		0xff706662, -- 5 Gray
		0xff151515, -- 6 Black
		0xffc21c1c, -- 7 Red
		0xff178c32, -- 8 Green
		0xffae2ad3, -- 9 Plum
		0xffebe8e4, -- 10 White
		0xffe3dd26, -- 11 Yellow
		0xff449acc, -- 12 Light blue
		0xff124d87, -- 13 Dark blue
		0xfffc0eb3, -- 14 Pink
		0xffd0672a, -- 15 Orange
	},
	footwear = {},
	mouth = {},
	eye = {},
	bottom = {},
	top = {},
	hair = {},
	headwear = {},
	masks = {},
	preview_rotations = {},
	ranks = {},
	player_skins = {},
	player_formspecs = {},
}

function vlc_skins.register_item(item)
	assert(vlc_skins[item.type], "Skin item type " .. item.type .. " does not exist.")
	local texture = item.texture or "blank.png"
	if item.steve then
		vlc_skins.steve[item.type] = texture
	end

	if item.alex then
		vlc_skins.alex[item.type] = texture
	end

	table.insert(vlc_skins[item.type], texture)
	vlc_skins.masks[texture] = item.mask
	vlc_skins.preview_rotations[texture] = item.preview_rotation
	vlc_skins.ranks[texture] = item.rank
end

function vlc_skins.register_simple_skin(skin)
	if skin.index then
		vlc_skins.simple_skins[skin.index] = skin
	else
		table.insert(vlc_skins.simple_skins, skin)
	end
	vlc_skins.texture_to_simple_skin[skin.texture] = skin
end

function vlc_skins.save(player)
	local skin = vlc_skins.player_skins[player]
	if not skin then return end

	local meta = player:get_meta()
	meta:set_string("vlc_skins:skin", minetest.serialize(skin))

	-- Clear out the old way of storing the simple skin ID
	meta:set_string("vlc_skins:skin_id", "")
end

minetest.register_chatcommand("skin", {
	description = S("Open skin configuration screen."),
	privs = {},
	func = function(name, param) vlc_skins.show_formspec(minetest.get_player_by_name(name)) end
})

function vlc_skins.compile_skin(skin)
	if not skin then return "blank.png" end

	if skin.simple_skins_id then
		return skin.simple_skins_id
	end

	local ranks = {}
	local layers = {}
	for i, item in ipairs(vlc_skins.item_names) do
		local texture = skin[item]
		local layer = ""
		local rank = vlc_skins.ranks[texture] or i * 10
		if texture and texture ~= "blank.png" then
			if skin[item .. "_color"] and vlc_skins.masks[texture] then
				local color = C(skin[item .. "_color"])
				layer = "(" .. vlc_skins.masks[texture] .. "^[colorize:" .. color .. ":alpha)"
			end
			if #layer > 0 then layer = layer .. "^" end
			layer = layer .. texture
			layers[rank] = layer
			table.insert(ranks, rank)
		end
	end
	table.sort(ranks)
	local output = ""
	for i, rank in ipairs(ranks) do
		if #output > 0 then output = output .. "^" end
		output = output .. layers[rank]
	end
	return output
end

function vlc_skins.update_player_skin(player)
	if not player then
		return
	end

	local skin = vlc_skins.player_skins[player]

	vlc_player.player_set_skin(player, vlc_skins.compile_skin(skin))

	local slim_arms
	if skin.simple_skins_id then
		slim_arms = vlc_skins.texture_to_simple_skin[skin.simple_skins_id].slim_arms
	else
		slim_arms = skin.slim_arms
	end
	local model = slim_arms and "vlc_armor_character_female.b3d" or "vlc_armor_character.b3d"
	vlc_player.player_set_model(player, model)
end

-- Load player skin on join
minetest.register_on_joinplayer(function(player)
	local skin = player:get_meta():get_string("vlc_skins:skin")
	if skin then
		skin = minetest.deserialize(skin)
	end
	if skin then
		if not vlc_skins.texture_to_simple_skin[skin.simple_skins_id] then
			skin.simple_skins_id = nil
		end

		vlc_skins.player_skins[player] = skin
	else
		if math.random() > 0.5 then
			skin = table.copy(vlc_skins.steve)
		else
			skin = table.copy(vlc_skins.alex)
		end
		vlc_skins.player_skins[player] = skin
	end

	vlc_skins.player_formspecs[player] = {
		active_tab = "skin",
		page_num = 1
	}

	if #vlc_skins.simple_skins > 0 then
		local skin_id = tonumber(player:get_meta():get_string("vlc_skins:skin_id"))
		if skin_id and vlc_skins.simple_skins[skin_id] then
			local texture = vlc_skins.simple_skins[skin_id].texture
			vlc_skins.player_skins[player].simple_skins_id = texture
		end
	end
	vlc_skins.save(player)
	vlc_skins.update_player_skin(player)
end)

minetest.register_on_leaveplayer(function(player)
	vlc_skins.player_skins[player] = nil
	vlc_skins.player_formspecs[player] = nil
end)

function vlc_skins.show_formspec(player)
	local formspec_data = vlc_skins.player_formspecs[player]
	local skin = vlc_skins.player_skins[player]
	local active_tab = formspec_data.active_tab
	local page_num = formspec_data.page_num

	local formspec = "formspec_version[3]size[14.2,11]"

	for i, tab in pairs(vlc_skins.tab_names) do
		if tab == active_tab then
			formspec = formspec ..
				"style[" .. tab .. ";bgcolor=green]"
		end

		local y = 0.3 + (i - 1) * 0.8
		formspec = formspec ..
			"style[" .. tab .. ";content_offset=16,0]" ..
			"button[0.3," .. y .. ";4,0.8;" .. tab .. ";" .. vlc_skins.tab_descriptions[tab] .. "]" ..
			"image[0.4," .. y + 0.1 .. ";0.6,0.6;vlc_skins_icons.png^[verticalframe:11:" .. i - 1 .. "]"

		if skin.simple_skins_id then break end
	end

	local slim_arms
	if skin.simple_skins_id then
		slim_arms = vlc_skins.texture_to_simple_skin[skin.simple_skins_id].slim_arms
	else
		slim_arms = skin.slim_arms
	end
	local mesh = slim_arms and "vlc_armor_character_female.b3d" or "vlc_armor_character.b3d"

	formspec = formspec ..
		"model[11,0.3;3,7;player_mesh;" .. mesh .. ";" ..
		vlc_skins.compile_skin(skin) ..
		",blank.png,blank.png;0,180;false;true;0,0]"

	if active_tab == "skin" then
		local page_start = (page_num - 1) * 8 - 1
		local page_end = math.min(page_start + 8 - 1, #vlc_skins.simple_skins)
		formspec = formspec ..
			"style_type[button;bgcolor=#00000000]"

		local skin = table.copy(skin)
		local simple_skins_id = skin.simple_skins_id
		skin.simple_skins_id = nil
		vlc_skins.simple_skins[-1] = {
			slim_arms = skin.slim_arms,
			texture = vlc_skins.compile_skin(skin),
		}
		simple_skins_id = simple_skins_id or
			vlc_skins.simple_skins[-1].texture

		for i = page_start, page_end do
			local skin = vlc_skins.simple_skins[i]
			local j = i - page_start - 1
			local mesh = skin.slim_arms and "vlc_armor_character_female.b3d" or
				"vlc_armor_character.b3d"

			local x = 4.5 + (j + 1) % 4 * 1.6
			local y = 0.3 + math.floor((j + 1) / 4) * 3.1

			formspec = formspec ..
				"model[" .. x .. "," .. y .. ";1.5,3;player_mesh;" .. mesh .. ";" ..
				skin.texture ..
				",blank.png,blank.png;0,180;false;true;0,0]"

			if simple_skins_id == skin.texture then
				formspec = formspec ..
					"style[" .. i ..
					";bgcolor=;bgimg=vlc_skins_select_overlay.png;" ..
					"bgimg_pressed=vlc_skins_select_overlay.png;bgimg_middle=14,14]"
			end
			formspec = formspec ..
				"button[" .. x .. "," .. y .. ";1.5,3;" .. i .. ";]"
		end

		if page_start == -1 then
			formspec = formspec .. "image[4.85,1;0.8,0.8;vlc_skins_button.png]"
		end
	elseif active_tab == "template" then
		formspec = formspec ..
			"model[5,2;2,3;player_mesh;vlc_armor_character.b3d;" ..
			vlc_skins.compile_skin(vlc_skins.steve) ..
			",blank.png,blank.png;0,180;false;true;0,0]" ..

			"button[5,5.2;2,0.8;steve;" .. S("Select") .. "]" ..

			"model[7.5,2;2,3;player_mesh;vlc_armor_character_female.b3d;" ..
			vlc_skins.compile_skin(vlc_skins.alex) ..
			",blank.png,blank.png;0,180;false;true;0,0]" ..

			"button[7.5,5.2;2,0.8;alex;" .. S("Select") .. "]"

	elseif vlc_skins[active_tab] then
		formspec = formspec ..
			"style_type[button;bgcolor=#00000000]"
		local textures = vlc_skins[active_tab]
		local page_start = (page_num - 1) * 16 + 1
		local page_end = math.min(page_start + 16 - 1, #textures)

		for j = page_start, page_end do
			local i = j - page_start + 1
			local texture = textures[j]
			local preview = vlc_skins.masks[skin.base] .. "^[colorize:gray^" .. skin.base
			local color = C(skin[active_tab .. "_color"])
			local mask = vlc_skins.masks[texture]
			if color and mask then
				preview = preview .. "^(" .. mask .. "^[colorize:" .. color .. ":alpha)"
			end
			preview = preview .. "^" .. texture

			local mesh = "vlc_skins_head.obj"
			if active_tab == "top" then
				mesh = "vlc_skins_top.obj"
			elseif active_tab == "bottom" or active_tab == "footwear" then
				mesh = "vlc_skins_bottom.obj"
			end

			local rot_x = -10
			local rot_y = 20
			if vlc_skins.preview_rotations[texture] then
				rot_x = vlc_skins.preview_rotations[texture].x
				rot_y = vlc_skins.preview_rotations[texture].y
			end

			i = i - 1
			local x = 4.5 + i % 4 * 1.6
			local y = 0.3 + math.floor(i / 4) * 1.6
			formspec = formspec ..
				"model[" .. x .. "," .. y ..
				";1.5,1.5;" .. mesh .. ";" .. mesh .. ";" ..
				preview ..
				";" .. rot_x .. "," .. rot_y .. ";false;false;0,0]"

			if skin[active_tab] == texture then
				formspec = formspec ..
					"style[" .. texture ..
					";bgcolor=;bgimg=vlc_skins_select_overlay.png;" ..
					"bgimg_pressed=vlc_skins_select_overlay.png;bgimg_middle=14,14]"
			end
			formspec = formspec .. "button[" .. x .. "," .. y .. ";1.5,1.5;" .. texture .. ";]"
		end
	elseif active_tab == "arm" then
		local x = skin.slim_arms and 5.7 or 4.6
		formspec = formspec ..
			"image_button[4.6,0.3;1,1;vlc_skins_thick_arms.png;thick_arms;]" ..
			"image_button[5.7,0.3;1,1;vlc_skins_slim_arms.png;slim_arms;]" ..
			"style[arm;bgcolor=;bgimg=vlc_skins_select_overlay.png;" ..
			"bgimg_middle=14,14;bgimg_pressed=vlc_skins_select_overlay.png]" ..
			"button[" .. x .. ",0.3;1,1;arm;]"
	end


	if skin[active_tab .. "_color"] then
		local colors = vlc_skins.color
		if active_tab == "base" then colors = vlc_skins.base_color end

		local tab_color = active_tab .. "_color"
		local selected_color = skin[tab_color]
		for i, colorspec in pairs(colors) do
			local color = C(colorspec)
			i = i - 1
			local x = 4.6 + i % 6 * 0.9
			local y = 8 + math.floor(i / 6) * 0.9
			formspec = formspec ..
				"image_button[" .. x .. "," .. y ..
				";0.8,0.8;blank.png^[noalpha^[colorize:" ..
				color .. ":alpha;" .. colorspec .. ";]"

			if selected_color == colorspec then
				formspec = formspec ..
					"style[" .. color ..
					";bgcolor=;bgimg=vlc_skins_select_overlay.png;bgimg_middle=14,14;" ..
					"bgimg_pressed=vlc_skins_select_overlay.png]" ..
					"button[" .. x .. "," .. y .. ";0.8,0.8;" .. color .. ";]"
			end

		end

		if active_tab ~= "base" then
			-- Bitwise Operations !?!?!
			local red = math.floor(selected_color / 0x10000) - 0xff00
			local green = math.floor(selected_color / 0x100) - 0xff0000 - red * 0x100
			local blue = selected_color - 0xff000000 - red * 0x10000 - green * 0x100
			formspec = formspec ..
				"container[10.2,8]" ..
				"scrollbaroptions[min=0;max=255;smallstep=20]" ..

				"box[0.4,0;2.49,0.38;red]" ..
				"label[0.2,0.2;-]" ..
				"scrollbar[0.4,0;2.5,0.4;horizontal;red;" .. red .."]" ..
				"label[2.9,0.2;+]" ..

				"box[0.4,0.6;2.49,0.38;green]" ..
				"label[0.2,0.8;-]" ..
				"scrollbar[0.4,0.6;2.5,0.4;horizontal;green;" .. green .."]" ..
				"label[2.9,0.8;+]" ..

				"box[0.4,1.2;2.49,0.38;blue]" ..
				"label[0.2,1.4;-]" ..
				"scrollbar[0.4,1.2;2.5,0.4;horizontal;blue;" .. blue .. "]" ..
				"label[2.9,1.4;+]" ..

				"container_end[]"
		end
	end

	local page_count = 1
	if vlc_skins[active_tab] then
		page_count = math.ceil(#vlc_skins[active_tab] / 16)
	elseif active_tab == "skin" then
		page_count = math.ceil((#vlc_skins.simple_skins + 2) / 8)
	end

	if page_num > 1 then
		formspec = formspec ..
			"image_button[4.5,6.7;1,1;vlc_skins_arrow.png^[transformFX;previous_page;]"
	end

	if page_num < page_count then
		formspec = formspec ..
			"image_button[9.8,6.7;1,1;vlc_skins_arrow.png;next_page;]"
	end

	if page_count > 1 then
		formspec = formspec ..
			"label[7.3,7.2;" .. page_num .. " / " .. page_count .. "]"
	end

	local player_name = player:get_player_name()
	minetest.show_formspec(player_name, "vlc_skins:skins", formspec)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if fields.__vlc_skins then
		vlc_skins.show_formspec(player)
		return false
	end

	if formname ~= "vlc_skins:skins" then return false end

	local formspec_data = vlc_skins.player_formspecs[player]
	local active_tab = formspec_data.active_tab

	-- Cancel formspec resend after scrollbar move
	if formspec_data.form_send_job then
		formspec_data.form_send_job:cancel()
		formspec_data.form_send_job = nil
	end

	if fields.quit then
		vlc_skins.save(player)
		return true
	end

	if fields.alex then
		vlc_skins.player_skins[player] = table.copy(vlc_skins.alex)
		vlc_skins.update_player_skin(player)
		vlc_skins.show_formspec(player)
		return true
	elseif fields.steve then
		vlc_skins.player_skins[player] = table.copy(vlc_skins.steve)
		vlc_skins.update_player_skin(player)
		vlc_skins.show_formspec(player)
		return true
	end

	for i, tab in pairs(vlc_skins.tab_names) do
		if fields[tab] then
			formspec_data.active_tab = tab
			formspec_data.page_num = 1
			vlc_skins.show_formspec(player)
			return true
		end
	end

	local skin = vlc_skins.player_skins[player]
	if not skin then return true end

	if fields.next_page then
		local page_num = formspec_data.page_num
		page_num = page_num + 1

		local page_count
		if active_tab == "skin" then
			page_count = math.ceil((#vlc_skins.simple_skins + 2) / 8)
		else
			page_count = math.ceil(#vlc_skins[active_tab] / 16)
		end

		if page_num > page_count then
			page_num = page_count
		end
		formspec_data.page_num = page_num
		vlc_skins.show_formspec(player)
		return true
	elseif fields.previous_page then
		local page_num = formspec_data.page_num
		page_num = page_num - 1
		if page_num < 1 then page_num = 1 end
		formspec_data.page_num = page_num
		vlc_skins.show_formspec(player)
		return true
	end

	if active_tab == "arm" then
		if fields.thick_arms then
			skin.slim_arms = false
		elseif fields.slim_arms then
			skin.slim_arms = true
		end
		vlc_skins.update_player_skin(player)
		vlc_skins.show_formspec(player)
		return true
	end

	if
		skin[active_tab .. "_color"] and (
			fields.red and fields.red:find("^CHG") or
			fields.green and fields.green:find("^CHG") or
			fields.blue and fields.blue:find("^CHG")
		)
	then
		local red = fields.red:gsub("%a%a%a:", "")
		local green = fields.green:gsub("%a%a%a:", "")
		local blue = fields.blue:gsub("%a%a%a:", "")
		red = tonumber(red) or 0
		green = tonumber(green) or 0
		blue = tonumber(blue) or 0

		local color = 0xff000000 + red * 0x10000 + green * 0x100 + blue
		if color >= 0 and color <= 0xffffffff then
			-- We delay resedning the form because otherwise it will break dragging scrollbars
			formspec_data.form_send_job = minetest.after(0.2, function()
				if player and player:is_player() then
					skin[active_tab .. "_color"] = color
					vlc_skins.update_player_skin(player)
					vlc_skins.show_formspec(player)
					formspec_data.form_send_job = nil
				end
			end)
			return true
		end
	end

	local field
	for f, value in pairs(fields) do
		if value == "" then
			field = f
			break
		end
	end

	if field and active_tab == "skin" then
		local index = tonumber(field)
		index = index and math.floor(index) or 0
		vlc_skins.simple_skins[-1].texture = nil
		if
			#vlc_skins.simple_skins > 0 and
			index >= -1 and index <= #vlc_skins.simple_skins
		then
			skin.simple_skins_id = vlc_skins.simple_skins[index].texture
			vlc_skins.update_player_skin(player)
			vlc_skins.show_formspec(player)
		end
		return true
	end

	-- See if field is a texture
	if
		field and vlc_skins[active_tab] and
		table.indexof(vlc_skins[active_tab], field) ~= -1
	then
		skin[active_tab] = field
		vlc_skins.update_player_skin(player)
		vlc_skins.show_formspec(player)
		return true
	end

	-- See if field is a color
	local number = tonumber(field)
	if number and skin[active_tab .. "_color"] then
		local color = math.floor(number)
		if color and color >= 0 and color <= 0xffffffff then
			skin[active_tab .. "_color"] = color
			vlc_skins.update_player_skin(player)
			vlc_skins.show_formspec(player)
			return true
		end
	end

	return true
end)

local function init()
	local f = io.open(minetest.get_modpath("vlc_skins") .. "/list.json")
	assert(f, "Can't open the file list.json")
	local data = f:read("*all")
	assert(data, "Can't read data from list.json")
	local json, error = minetest.parse_json(data)
	assert(json, error)
	f:close()

	for _, item in pairs(json) do
		vlc_skins.register_item(item)
	end
	vlc_skins.steve.base_color = vlc_skins.base_color[2]
	vlc_skins.steve.hair_color = 0xff5d473b
	vlc_skins.steve.top_color = 0xff993535
	vlc_skins.steve.bottom_color = 0xff644939
	vlc_skins.steve.slim_arms = false

	vlc_skins.alex.base_color = vlc_skins.base_color[1]
	vlc_skins.alex.hair_color = 0xff715d57
	vlc_skins.alex.top_color = 0xff346840
	vlc_skins.alex.bottom_color = 0xff383532
	vlc_skins.alex.slim_arms = true

	vlc_skins.register_simple_skin({
		index = 0,
		texture = "character.png"
	})
	vlc_skins.register_simple_skin({
		index = 1,
		texture = "vlc_skins_character_1.png",
		slim_arms = true
	})
end

init()
