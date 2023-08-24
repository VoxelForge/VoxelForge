minetest.register_entity("mcl_wieldview:wieldview", {
	initial_properties = {
		hp_max           = 1,
		visual           = "wielditem",
		physical         = false,
		is_visible       = false,
		pointable        = false,
		collide_with_objects = false,
		static_save = false,
		collisionbox = {-0.21, -0.21, -0.21, 0.21, 0.21, 0.21},
		selectionbox = {-0.21, -0.21, -0.21, 0.21, 0.21, 0.21},
		visual_size  = {x = 0.21, y = 0.21},
	}
})

local wieldview_luaentites = {}
local offhand_luaentites = {}

local function update_wieldview_entity(player)
	local luaentity = wieldview_luaentites[player]
	local offhand_ent = offhand_luaentites[player]

	if luaentity and luaentity.object:get_yaw() then
		local item = player:get_wielded_item():get_name()

		if item == luaentity._item then return end

		luaentity._item = item

		local def = player:get_wielded_item():get_definition()
		if def and def._mcl_wieldview_item then
			item = def._mcl_wieldview_item
		end

		local item_def = minetest.registered_items[item]
		luaentity.object:set_properties({
			glow = item_def and item_def.light_source or 0,
			wield_item = item,
			is_visible = item ~= ""
		})
	else
		-- If the player is running through an unloaded area,
		-- the wieldview entity will sometimes get unloaded.
		-- This code path is also used to initalize the wieldview.
		-- Creating entites from minetest.register_on_joinplayer
		-- is unreliable as of Minetest 5.6
		local obj_ref = minetest.add_entity(player:get_pos(), "mcl_wieldview:wieldview")
		if not obj_ref then return end
		obj_ref:set_attach(player, "Wield_Item")
		--offhand_ref:set_attach(player, "Hand_Left", vector.new(0, 1, 0), vector.new(90, 45, 90))
		--obj_ref:set_attach(player, "Hand_Right", vector.new(0, 1, 0), vector.new(90, 45, 90))
		wieldview_luaentites[player] = obj_ref:get_luaentity()
	end

	if offhand_ent and offhand_ent.object:get_yaw() then
		local item = mcl_offhand.get_offhand(player):get_name()

		if item == offhand_ent._item then return end

		offhand_ent._item = item

		local def = mcl_offhand.get_offhand(player):get_definition()
		if def and def._mcl_wieldview_item then
			item = def._mcl_wieldview_item
		end

		local item_def = minetest.registered_items[item]
		offhand_ent.object:set_properties({
			glow = item_def and item_def.light_source or 0,
			wield_item = item,
			is_visible = item ~= ""
		})
	else
		local offhand_ref = minetest.add_entity(player:get_pos(), "mcl_wieldview:wieldview")
		if not offhand_ref then return end
		--obj_ref:set_attach(player, "Wield_Item")
		offhand_ref:set_attach(player, "Arm_Left", vector.new(-0.4, 4.5, 2), vector.new(120, 0, 0))
		--obj_ref:set_attach(player, "Hand_Right", vector.new(0, 1, 0), vector.new(90, 45, 90))
		offhand_luaentites[player] = offhand_ref:get_luaentity()
	end
end

minetest.register_on_leaveplayer(function(player)
	if wieldview_luaentites[player] then
		wieldview_luaentites[player].object:remove()
		offhand_luaentites[player].object:remove()
	end
	wieldview_luaentites[player] = nil
	offhand_luaentites[player] = nil
end)

minetest.register_globalstep(function(dtime)
	local players = minetest.get_connected_players()
	for i, player in pairs(players) do
		update_wieldview_entity(player)
	end
end)
