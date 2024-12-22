local S = minetest.get_translator(minetest.get_current_modname())

vlf_bows = {}

-- local arrows = {
-- 	["vlf_bows:arrow"] = "vlf_bows:arrow_entity",
-- }

local GRAVITY = 9.81
local BOW_DURABILITY = 385

-- Charging time in microseconds
local BOW_CHARGE_TIME_HALF = 200000 -- bow level 1
local BOW_CHARGE_TIME_FULL = 500000 -- bow level 2 (full charge)
vlf_bows.BOW_CHARGE_TIME_HALF = 200000 / 1.0e6
vlf_bows.BOW_CHARGE_TIME_FULL = 500000 / 1.0e6

-- Factor to multiply with player speed while player uses bow
-- This emulates the sneak speed.
local PLAYER_USE_BOW_SPEED = tonumber(minetest.settings:get("movement_speed_crouch")) / tonumber(minetest.settings:get("movement_speed_walk"))

local BOW_MAX_SPEED = 3.0 * 20

--[[ Store the charging state of each player.
keys: player name
value:
nil = not charging or player not existing
number: currently charging, the number is the time from minetest.get_us_time
             in which the charging has started
]]
local bow_load = {}

-- Another player table, this one stores the wield index of the bow being charged
local bow_index = {}

function vlf_bows.shoot_arrow(arrow_item, pos, dir, yaw, shooter, power, damage, is_critical, bow_stack, collectable)
	local obj = minetest.add_entity({x=pos.x,y=pos.y,z=pos.z}, arrow_item.."_entity")
	if not obj or not obj:get_pos() then return end
	if power == nil then
		power = 1.0
	end
	local speed = power * BOW_MAX_SPEED
	local mob_shooter = shooter and not shooter:is_player ()

	if damage == nil then
		if mob_shooter then
			-- Randomize arrow damage by difficulty.
			damage = 2.0
			local bonus
				= vlf_util.dist_triangular (vlf_vars.difficulty * 0.11,
								0.57425)
			damage = damage + bonus
		else
			damage = 2.0
		end
	end
	local knockback = 0
	if bow_stack then
		local enchantments = vlf_enchanting.get_enchantments(bow_stack)
		if enchantments.power then
			damage = damage + (enchantments.power / 2) + 0.5
		end
		if enchantments.punch then
			knockback = knockback + enchantments.punch
		end
		if enchantments.flame then
			vlf_burning.set_on_fire(obj, math.huge)
		end
	end
	-- Randomize accuracy by difficulty.
	if mob_shooter then
		local f = 14 - vlf_vars.difficulty * 4
		dir = vector.copy (dir)
		dir.x = dir.x + vlf_util.dist_triangular (0, 0.0172275 * f)
		dir.y = dir.y + vlf_util.dist_triangular (0, 0.0172275 * f)
		dir.z = dir.z + vlf_util.dist_triangular (0, 0.0172275 * f)
	end
	obj:set_velocity({x=dir.x*speed, y=dir.y*speed, z=dir.z*speed})
	obj:set_acceleration({x=0, y=-GRAVITY, z=0})
	obj:set_yaw(yaw-math.pi/2)
	local le = obj:get_luaentity()
	le._shooter = shooter
	le._source_object = shooter
	le._damage = damage
	le._is_critical = is_critical
	le._startpos = pos
	le._knockback = knockback
	le._collectable = collectable
	minetest.sound_play("vlf_bows_bow_shoot", {pos=pos, max_hear_distance=16}, true)
	if shooter and shooter:is_player() then
		if obj:get_luaentity().player == "" then
			obj:get_luaentity().player = shooter
		end
		obj:get_luaentity().node = shooter:get_inventory():get_stack("main", 1):get_name()
	end
	return obj
end

local function get_arrow(player)
	local inv = player:get_inventory()
	local arrow_stack, arrow_stack_id
	for i=1, inv:get_size("main") do
		local it = inv:get_stack("main", i)
		if not it:is_empty() and minetest.get_item_group(it:get_name(), "ammo_bow") ~= 0 then
			arrow_stack = it
			arrow_stack_id = i
			break
		end
	end
	return arrow_stack, arrow_stack_id
end

local function player_shoot_arrow (player, power, is_critical)
	local arrow_stack, arrow_stack_id = get_arrow(player)
	local arrow_itemstring
	local has_infinity_enchantment = vlf_enchanting.has_enchantment(player:get_wielded_item(), "infinity")

	if minetest.is_creative_enabled(player:get_player_name()) then
		if arrow_stack then
			arrow_itemstring = arrow_stack:get_name()
		else
			arrow_itemstring = "vlf_bows:arrow"
		end
	else
		if not arrow_stack then
			return false
		end
		arrow_itemstring = arrow_stack:get_name()
		if not (has_infinity_enchantment and minetest.get_item_group(arrow_itemstring, "ammo_bow_regular") > 0) then
			arrow_stack:take_item()
		end
		local inv = player:get_inventory()
		inv:set_stack("main", arrow_stack_id, arrow_stack)
	end
	if not arrow_itemstring then
		return false
	end
	local playerpos = player:get_pos()
	local dir = player:get_look_dir()
	local yaw = player:get_look_horizontal()

	local pos = {
		x = playerpos.x,
		y = playerpos.y + 1.5,
		z = playerpos.z,
	}
	vlf_bows.shoot_arrow (arrow_itemstring, pos, dir, yaw, player,
			      power, nil, is_critical, player:get_wielded_item (),
			      not has_infinity_enchantment)
	return true
end

-- Bow item, uncharged state
minetest.register_tool("vlf_bows:bow", {
	description = S("Bow"),
	_tt_help = S("Launches arrows"),
	_doc_items_longdesc = S("Bows are ranged weapons to shoot arrows at your foes.").."\n"..
S("The speed and damage of the arrow increases the longer you charge. The regular damage of the arrow is between 1 and 9. At full charge, there's also a 20% of a critical hit, dealing 10 damage instead."),
	_doc_items_usagehelp = S("To use the bow, you first need to have at least one arrow anywhere in your inventory (unless in Creative Mode). Hold down the right mouse button (or the zoom key) to charge, release to shoot."),
	_doc_items_durability = BOW_DURABILITY,
	inventory_image = "vlf_bows_bow.png",
	wield_scale = vlf_vars.tool_wield_scale,
	stack_max = 1,
	range = 4,
	-- Trick to disable digging as well
	on_use = function() end,
	on_place = function(itemstack, player, pointed_thing)
		local rc = vlf_util.call_on_rightclick(itemstack, player, pointed_thing)
		if rc then return rc end

		itemstack:get_meta():set_string("active", "true")
		return itemstack
	end,
	on_secondary_use = function(itemstack)
		itemstack:get_meta():set_string("active", "true")
		return itemstack
	end,
	touch_interaction = "short_dig_long_place",
	groups = {weapon=1,weapon_ranged=1,bow=1,enchantability=1},
	_vlf_uses = 385,
	_vlf_burntime = 15
})

-- Iterates through player inventory and resets all the bows in "charging" state back to their original stage
local function reset_bows(player)
	local inv = player:get_inventory()
	local list = inv:get_list("main")
	for place, stack in pairs(list) do
		if stack:get_name() == "vlf_bows:bow" or stack:get_name() == "vlf_bows:bow_enchanted" then
			stack:get_meta():set_string("active", "")
		elseif stack:get_name()=="vlf_bows:bow_0" or stack:get_name()=="vlf_bows:bow_1" or stack:get_name()=="vlf_bows:bow_2" then
			stack:set_name("vlf_bows:bow")
			stack:get_meta():set_string("active", "")
			list[place] = stack
		elseif stack:get_name()=="vlf_bows:bow_0_enchanted" or stack:get_name()=="vlf_bows:bow_1_enchanted" or stack:get_name()=="vlf_bows:bow_2_enchanted" then
			stack:set_name("vlf_bows:bow_enchanted")
			stack:get_meta():set_string("active", "")
			list[place] = stack
		end
	end
	inv:set_list("main", list)
end

-- Resets the bow charging state and player speed. To be used when the player is no longer charging the bow
local function reset_bow_state(player, also_reset_bows)
	bow_load[player:get_player_name()] = nil
	bow_index[player:get_player_name()] = nil
	if minetest.get_modpath("playerphysics") then
		playerphysics.remove_physics_factor(player, "speed", "vlf_bows:use_bow")
	end
	if also_reset_bows then
		reset_bows(player)
	end
end

-- Bow in charging state
for level=0, 2 do
	minetest.register_tool("vlf_bows:bow_"..level, {
		description = S("Bow"),
		_doc_items_create_entry = false,
		inventory_image = "vlf_bows_bow_"..level..".png",
		wield_scale = vlf_vars.tool_wield_scale,
		stack_max = 1,
		range = 0, -- Pointing range to 0 to prevent punching with bow :D
		groups = {not_in_creative_inventory=1, not_in_craft_guide=1, bow=1, enchantability=1},
		-- Trick to disable digging as well
		on_use = function() end,
		on_drop = function(itemstack, dropper, pos)
			reset_bow_state(dropper)
			itemstack:get_meta():set_string("active", "")
			if vlf_enchanting.is_enchanted(itemstack:get_name()) then
				itemstack:set_name("vlf_bows:bow_enchanted")
			else
				itemstack:set_name("vlf_bows:bow")
			end
			minetest.item_drop(itemstack, dropper, pos)
			itemstack:take_item()
			return itemstack
		end,
		-- Prevent accidental interaction with itemframes and other nodes
		on_place = function(itemstack)
			return itemstack
		end,
		touch_interaction = "short_dig_long_place",
		_vlf_uses = 385,
	})
end


controls.register_on_release(function(player, key)
	if key~="RMB" and key~="zoom" then return end
	--local inv = minetest.get_inventory({type="player", name=player:get_player_name()})
	local wielditem = player:get_wielded_item()
	if (wielditem:get_name()=="vlf_bows:bow_0" or wielditem:get_name()=="vlf_bows:bow_1" or wielditem:get_name()=="vlf_bows:bow_2" or
		wielditem:get_name()=="vlf_bows:bow_0_enchanted" or wielditem:get_name()=="vlf_bows:bow_1_enchanted" or wielditem:get_name()=="vlf_bows:bow_2_enchanted") then

		local enchanted = vlf_enchanting.is_enchanted(wielditem:get_name())
		local p_load = bow_load[player:get_player_name()]
		local charge
		-- Type sanity check
		if type(p_load) == "number" then
			charge = minetest.get_us_time() - p_load
		else
			-- In case something goes wrong ...
			-- Just assume minimum charge.
			charge = 0
			minetest.log("warning", "[vlf_bows] Player "..player:get_player_name().." fires arrow with non-numeric bow_load!")
		end
		charge = math.max(math.min(charge, BOW_CHARGE_TIME_FULL), 0)

		local charge_ratio = charge / BOW_CHARGE_TIME_FULL
		charge_ratio = math.max(math.min(charge_ratio, 1), 0)

		-- Calculate damage and power.
		local is_critical = false
		if charge >= BOW_CHARGE_TIME_FULL then
			is_critical = true
		end

		local has_shot = player_shoot_arrow (player, charge_ratio, is_critical)

		if enchanted then
			wielditem:set_name("vlf_bows:bow_enchanted")
		else
			wielditem:set_name("vlf_bows:bow")
		end

		if has_shot and not minetest.is_creative_enabled(player:get_player_name()) then
			local durability = BOW_DURABILITY
			local unbreaking = vlf_enchanting.get_enchantment(wielditem, "unbreaking")
			if unbreaking > 0 then
				durability = durability * (unbreaking + 1)
			end
			wielditem:add_wear(65535/durability)
		end
		player:set_wielded_item(wielditem)
		reset_bow_state(player, true)
	end
end)

controls.register_on_hold(function(player, key)
	local name = player:get_player_name()
	local creative = minetest.is_creative_enabled(name)
	if (key ~= "RMB" and key ~= "zoom") or not (creative or get_arrow(player)) then
		return
	end
	--local inv = minetest.get_inventory({type="player", name=name})
	local wielditem = player:get_wielded_item()
		if bow_load[name] == nil
		and (wielditem:get_name()=="vlf_bows:bow" or wielditem:get_name()=="vlf_bows:bow_enchanted")
		and (wielditem:get_meta():get("active") or key == "zoom") and (creative or get_arrow(player)) then
		local enchanted = vlf_enchanting.is_enchanted(wielditem:get_name())
		if enchanted then
			wielditem:set_name("vlf_bows:bow_0_enchanted")
		else
			wielditem:set_name("vlf_bows:bow_0")
		end
		player:set_wielded_item(wielditem)
		if minetest.get_modpath("playerphysics") then
			-- Slow player down when using bow
			playerphysics.add_physics_factor(player, "speed", "vlf_bows:use_bow", PLAYER_USE_BOW_SPEED)
		end
		bow_load[name] = minetest.get_us_time()
		bow_index[name] = player:get_wield_index()
	else
		if player:get_wield_index() == bow_index[name] then
			if type(bow_load[name]) == "number" then
				if wielditem:get_name() == "vlf_bows:bow_0" and minetest.get_us_time() - bow_load[name] >= BOW_CHARGE_TIME_HALF then
					wielditem:set_name("vlf_bows:bow_1")
				elseif wielditem:get_name() == "vlf_bows:bow_0_enchanted" and minetest.get_us_time() - bow_load[name] >= BOW_CHARGE_TIME_HALF then
					wielditem:set_name("vlf_bows:bow_1_enchanted")
				elseif wielditem:get_name() == "vlf_bows:bow_1" and minetest.get_us_time() - bow_load[name] >= BOW_CHARGE_TIME_FULL then
					wielditem:set_name("vlf_bows:bow_2")
				elseif wielditem:get_name() == "vlf_bows:bow_1_enchanted" and minetest.get_us_time() - bow_load[name] >= BOW_CHARGE_TIME_FULL then
					wielditem:set_name("vlf_bows:bow_2_enchanted")
				end
			else
				if wielditem:get_name() == "vlf_bows:bow_0" or wielditem:get_name() == "vlf_bows:bow_1" or wielditem:get_name() == "vlf_bows:bow_2" then
					wielditem:set_name("vlf_bows:bow")
				elseif wielditem:get_name() == "vlf_bows:bow_0_enchanted" or wielditem:get_name() == "vlf_bows:bow_1_enchanted" or wielditem:get_name() == "vlf_bows:bow_2_enchanted" then
					wielditem:set_name("vlf_bows:bow_enchanted")
				end
			end
			player:set_wielded_item(wielditem)
		else
			reset_bow_state(player, true)
		end
	end
end)

minetest.register_globalstep(function()
	for player in vlf_util.connected_players() do
		local name = player:get_player_name()
		local wielditem = player:get_wielded_item()
		local wieldindex = player:get_wield_index()
		--local controls = player:get_player_control()
		if type(bow_load[name]) == "number" and ((wielditem:get_name()~="vlf_bows:bow_0" and wielditem:get_name()~="vlf_bows:bow_1" and wielditem:get_name()~="vlf_bows:bow_2" and wielditem:get_name()~="vlf_bows:bow_0_enchanted" and wielditem:get_name()~="vlf_bows:bow_1_enchanted" and wielditem:get_name()~="vlf_bows:bow_2_enchanted") or wieldindex ~= bow_index[name]) then
			reset_bow_state(player, true)
		end
	end
end)

minetest.register_on_joinplayer(function(player)
	reset_bows(player)
end)

minetest.register_on_leaveplayer(function(player)
	reset_bow_state(player, true)
end)

if minetest.get_modpath("vlf_core") and minetest.get_modpath("vlf_mobitems") then
	minetest.register_craft({
		output = "vlf_bows:bow",
		recipe = {
			{"", "vlf_core:stick", "vlf_mobitems:string"},
			{"vlf_core:stick", "", "vlf_mobitems:string"},
			{"", "vlf_core:stick", "vlf_mobitems:string"},
		}
	})
	minetest.register_craft({
		output = "vlf_bows:bow",
		recipe = {
			{"vlf_mobitems:string", "vlf_core:stick", ""},
			{"vlf_mobitems:string", "", "vlf_core:stick"},
			{"vlf_mobitems:string", "vlf_core:stick", ""},
		}
	})
end

-- Add entry aliases for the Help
if minetest.get_modpath("doc") then
	doc.add_entry_alias("tools", "vlf_bows:bow", "tools", "vlf_bows:bow_0")
	doc.add_entry_alias("tools", "vlf_bows:bow", "tools", "vlf_bows:bow_1")
	doc.add_entry_alias("tools", "vlf_bows:bow", "tools", "vlf_bows:bow_2")
end
