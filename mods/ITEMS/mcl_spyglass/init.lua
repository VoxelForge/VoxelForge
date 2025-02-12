local S = minetest.get_translator(minetest.get_current_modname())

minetest.register_tool("mcl_spyglass:spyglass",{
	description = S("Spyglass"),
	_doc_items_longdesc = S("A spyglass is an item that can be used for zooming in on specific locations."),
	inventory_image = "mcl_spyglass.png",
	groups = {tool = 1},
	stack_max = 1,
	_mcl_toollike_wield = true,
	touch_interaction = "short_dig_long_place",
})

minetest.register_craft({
	output = "mcl_spyglass:spyglass",
	recipe = {
		{"mcl_amethyst:amethyst_shard"},
		{"mcl_copper:copper_ingot"},
		{"mcl_copper:copper_ingot"},
	}
})

local spyglass_scope = {}

local function add_scope(player)
	local wielditem = player:get_wielded_item()
	if wielditem:get_name() == "mcl_spyglass:spyglass" then
		spyglass_scope[player] = player:hud_add({
			type = "image",
			position = {x = 0.5, y = 0.5},
			scale = {x = -100, y = -100},
			text = "mcl_spyglass_scope.png",
		})
		player:hud_set_flags({wielditem = false})
	end
end

local function remove_scope(player)
	if spyglass_scope[player] then
		player:hud_remove(spyglass_scope[player])
		spyglass_scope[player] = nil
		player:hud_set_flags({wielditem = true})
		playerphysics.set_absolute_fov(player, 0)
	end
end

local function check_looking_at(player)
	local eye_pos = player:get_pos()
	eye_pos.y = eye_pos.y + player:get_properties().eye_height -- Adjust for the player's eye height
	local look_dir = player:get_look_dir()
	local look_ray = minetest.raycast(eye_pos, vector.add(eye_pos, vector.multiply(look_dir, 25)), true, false)

	for pointed_thing in look_ray do
		if pointed_thing.type == "object" then
			local obj = pointed_thing.ref
			if obj and obj:get_luaentity() and obj:get_luaentity().name == "mobs_mc:parrot" then
				awards.unlock(player:get_player_name(), "mcl:spyglass_at_parrot")
			elseif obj and obj:get_luaentity() and obj:get_luaentity().name == "mobs_mc:ghast" then
				awards.unlock(player:get_player_name(), "mcl:spyglass_at_ghast")
			elseif obj and obj:get_luaentity() and obj:get_luaentity().name == "mobs_mc:enderdragon" then
				awards.unlock(player:get_player_name(), "mcl:spyglass_at_dragon")
			end
		end
	end
end

controls.register_on_press(function(player, key)
	if mcl_serverplayer.is_csm_capable (player) then
		return
	end
	if key ~= "RMB" and key ~= "zoom" then return end
	if spyglass_scope[player] == nil then
		add_scope(player)
	end
end)

controls.register_on_release(function(player, key)
	if mcl_serverplayer.is_csm_capable (player) then
		return
	end
	if key ~= "RMB" and key ~= "zoom" then return end
	local ctrl = player:get_player_control()
	if key == "RMB" and ctrl.zoom or key == "zoom" and ctrl.place then return end
	remove_scope(player)
end)

controls.register_on_hold(function(player, key)
	if mcl_serverplayer.is_csm_capable (player) then
		return
	end
	if key ~= "RMB" and key ~= "zoom" then return end
	local wielditem = player:get_wielded_item()
	if wielditem:get_name() == "mcl_spyglass:spyglass" then
		playerphysics.set_absolute_fov(player, 8)
		if spyglass_scope[player] == nil then
			add_scope(player)
		end
		check_looking_at(player)
	else
		remove_scope(player)
	end
end)

minetest.register_on_dieplayer(function(player)
	remove_scope(player)
end)

minetest.register_on_leaveplayer(function(player)
	spyglass_scope[player] = nil
end)
