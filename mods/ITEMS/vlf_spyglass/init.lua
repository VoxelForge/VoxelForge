local S = minetest.get_translator(minetest.get_current_modname())

-- TODO: when < minetest 5.9 isn't supported anymore, remove this variable check and replace all occurrences of [hud_elem_type_field] with type
local hud_elem_type_field = "type"
if not minetest.features.hud_def_type_field then
	hud_elem_type_field = "hud_elem_type"
end

minetest.register_tool("vlf_spyglass:spyglass", {
	description = S("Spyglass"),
	_doc_items_longdesc = S("A spyglass is an item that can be used for zooming in on specific locations."),
	inventory_image = "vlf_spyglass.png",
	stack_max = 1,
	_vlf_toollike_wield = true,
})

minetest.register_craft({
	output = "vlf_spyglass:spyglass",
	recipe = {
		{"vlf_amethyst:amethyst_shard"},
		{"vlf_copper:copper_ingot"},
		{"vlf_copper:copper_ingot"},
	}
})

local spyglass_scope = {}
local zoom_active = {}

local function add_scope(player)
	local wielditem = player:get_wielded_item()
	if wielditem:get_name() == "vlf_spyglass:spyglass" and not spyglass_scope[player] then
		spyglass_scope[player] = player:hud_add({
			[hud_elem_type_field] = "image",
			position = {x = 0.5, y = 0.5},
			scale = {x = -100, y = -100},
			text = "vlf_spyglass_scope.png",
		})
		player:hud_set_flags({wielditem = false})
		player:set_fov(8, false, 0.1)
	end
end

local function remove_scope(player)
	if spyglass_scope[player] then
		player:hud_remove(spyglass_scope[player])
		spyglass_scope[player] = nil
		player:hud_set_flags({wielditem = true})
		player:set_fov(86.1)
	end
end

local function check_looking_at(player)
	local eye_pos = player:get_pos()
	eye_pos.y = eye_pos.y + player:get_properties().eye_height -- Adjust for the player's eye height
	local look_dir = player:get_look_dir()
	local look_ray = minetest.raycast(eye_pos, vector.add(eye_pos, vector.multiply(look_dir, 50)), true, false)

	for pointed_thing in look_ray do
		if pointed_thing.type == "object" then
			local obj = pointed_thing.ref
			if obj and obj:get_luaentity() and obj:get_luaentity().name == "mobs_mc:parrot" then
				awards.unlock(player:get_player_name(), "vlf:spyglass_at_parrot")
			elseif obj and obj:get_luaentity() and obj:get_luaentity().name == "mobs_mc:ghast" then
				awards.unlock(player:get_player_name(), "vlf:spyglass_at_ghast")
			elseif obj and obj:get_luaentity() and obj:get_luaentity().name == "mobs_mc:enderdragon" then
				awards.unlock(player:get_player_name(), "vlf:spyglass_at_dragon")
			end
		end
	end
end

controls.register_on_press(function(player, key)
	if key ~= "RMB" and key ~= "zoom" then return end
	if not zoom_active[player] then
		zoom_active[player] = true
		add_scope(player)
	end
end)

controls.register_on_release(function(player, key, time)
	if key ~= "RMB" and key ~= "zoom" then return end
	local ctrl = player:get_player_control()
	if key == "RMB" and ctrl.zoom or key == "zoom" and ctrl.place then return end
	zoom_active[player] = false
	remove_scope(player)
end)

controls.register_on_hold(function(player, key, time)
	if key ~= "RMB" and key ~= "zoom" then return end
	local wielditem = player:get_wielded_item()
	if wielditem:get_name() == "vlf_spyglass:spyglass" then
		player:set_fov(8, false, 0.1)
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
	zoom_active[player] = nil
end)

minetest.register_on_leaveplayer(function(player)
	remove_scope(player)
	zoom_active[player] = nil
end)
