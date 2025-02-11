------------------------------------------------------------------------
-- Bows and other usable items.
------------------------------------------------------------------------

local glint = mcl_enchanting.overlay

local is_bow = {
	["mcl_bows:bow"] = {
		charge_time_half = mcl_bows.BOW_CHARGE_TIME_HALF,
		charge_time_full = mcl_bows.BOW_CHARGE_TIME_FULL,
		texture_0 = "mcl_bows_bow_0.png",
		texture_0_wielditem = "mcl_bows:bow_0",
		texture_1 = "mcl_bows_bow_1.png",
		texture_1_wielditem = "mcl_bows:bow_1",
		texture_2 = "mcl_bows_bow_2.png",
		texture_2_wielditem = "mcl_bows:bow_2",
	},
	["mcl_bows:bow_enchanted"] = {
		charge_time_half = mcl_bows.BOW_CHARGE_TIME_HALF,
		charge_time_full = mcl_bows.BOW_CHARGE_TIME_FULL,
		texture_0 = "mcl_bows_bow_0.png" .. glint,
		texture_0_wielditem = "mcl_bows:bow_0_enchanted",
		texture_1 = "mcl_bows_bow_1.png" .. glint,
		texture_1_wielditem = "mcl_bows:bow_1_enchanted",
		texture_2 = "mcl_bows_bow_2.png" .. glint,
		texture_2_wielditem = "mcl_bows:bow_2_enchanted",
	},
	["mcl_bows:crossbow"] = {
		charge_time_half = mcl_bows.CROSSBOW_CHARGE_TIME_HALF,
		charge_time_full = mcl_bows.CROSSBOW_CHARGE_TIME_FULL,
		texture_0 = "mcl_bows_crossbow_0.png",
		texture_0_wielditem = "mcl_bows:crossbow_0",
		texture_1 = "mcl_bows_crossbow_1.png",
		texture_1_wielditem = "mcl_bows:crossbow_1",
		texture_2 = "mcl_bows_crossbow_2.png",
		texture_2_wielditem = "mcl_bows:crossbow_2",
		texture_loaded = "mcl_bows_crossbow_3.png",
		texture_loaded_wielditem = "mcl_bows:crossbow_loaded",
	},
	["mcl_bows:crossbow_enchanted"] = {
		charge_time_half = mcl_bows.CROSSBOW_CHARGE_TIME_HALF,
		charge_time_full = mcl_bows.CROSSBOW_CHARGE_TIME_FULL,
		texture_0 = "mcl_bows_crossbow_0.png" .. glint,
		texture_0_wielditem = "mcl_bows:crossbow_0_enchanted",
		texture_1 = "mcl_bows_crossbow_1.png" .. glint,
		texture_1_wielditem = "mcl_bows:crossbow_1_enchanted",
		texture_2 = "mcl_bows_crossbow_2.png" .. glint,
		texture_2_wielditem = "mcl_bows:crossbow_2_enchanted",
		texture_loaded = "mcl_bows_crossbow_3.png" .. glint,
		texture_3_wielditem = "mcl_bows:crossbow_loaded_enchanted",
	},
	is_crossbow = {
		["mcl_bows:crossbow_loaded"] = true,
		["mcl_bows:crossbow_loaded_enchanted"] = true,
	},
}
mcl_serverplayer.bow_info = is_bow

function mcl_serverplayer.update_ammo (state, player, always)
	local wielditem = player:get_wielded_item ()
	local name = wielditem:get_name ()

	if not is_bow[name] then
		if state.ammo ~= 0 or always then
			local challenge = state.ammo_challenge
			state.ammo = 0
			mcl_serverplayer.send_ammoctrl (player, 0, challenge)
		end
		return
	end

	local ammo = minetest.get_item_group (name, "crossbow") > 0
		and mcl_bows.get_arrow_stack_for_crossbow (player)
		or mcl_bows.get_arrow_stack_for_bow (player)
	local count = ammo and ammo:get_count () or 0
	if state.ammo ~= count or always then
		local challenge = state.ammo_challenge
		state.ammo = count
		mcl_serverplayer.send_ammoctrl (player, count, challenge)
	end

	local enchantments = mcl_enchanting.get_enchantments (wielditem)
	local infinity = enchantments.infinity and enchantments.infinity > 0
	local quick_charge = enchantments.quick_charge or 0

	-- ???
	if not infinity then
		infinity = false
	end

	if infinity ~= state.bow_cap_infinity
		or quick_charge ~= state.bow_cap_quick_charge then
		local time = mcl_bows.crossbow_charge_time_multiplier (quick_charge)
		state.bow_cap_infinity = infinity
		state.bow_cap_quick_charge = quick_charge
		mcl_serverplayer.send_bow_capabilities (player, {
			challenge = state.ammo_challenge,
			infinity = infinity,
			charge_time = time,
		})
	end
end

function mcl_serverplayer.release_useitem (state, player, usetime, challenge)
	local wielditem = player:get_wielded_item ()
	local name = wielditem:get_name ()

	if minetest.get_item_group (name, "bow") > 0 then
		mcl_bows.player_shoot (player, wielditem, usetime * 1.0e+6)
	elseif minetest.get_item_group (name, "crossbow") > 0 then
		mcl_bows.load_crossbow (player, wielditem, usetime * 1.0e+6)
	end

	state.ammo_challenge = challenge
	mcl_serverplayer.update_ammo (state, player, true)
end
