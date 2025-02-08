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
