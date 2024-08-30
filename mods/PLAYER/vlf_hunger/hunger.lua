--local S = minetest.get_translator(minetest.get_current_modname())

-- wrapper for minetest.item_eat (this way we make sure other mods can't break this one)
function minetest.do_item_eat(hp_change, replace_with_item, itemstack, user, pointed_thing)
	if not user or not user.is_player or not user:is_player() or user.is_fake_player then return itemstack end

	local rc = vlf_util.call_on_rightclick(itemstack, user, pointed_thing)
	if rc then return rc end

	-- Also don't eat when pointing object (it could be an animal)
	if pointed_thing.type == "object" then
		return itemstack
	end

	local old_itemstack = itemstack

	local name = user:get_player_name()

	local creative = minetest.is_creative_enabled(name)

	-- Special foodstuffs like the cake may disable the eating delay
	local no_eat_delay = creative or (minetest.get_item_group(itemstack:get_name(), "no_eat_delay") == 1)

	-- Allow eating only after a delay of 2 seconds. This prevents eating as an excessive speed.
	-- FIXME: time() is not a precise timer, so the actual delay may be +- 1 second, depending on which fraction
	-- of the second the player made the first eat.
	-- FIXME: In singleplayer, there's a cheat to circumvent this, simply by pausing the game between eats.
	-- This is because os.time() obviously does not care about the pause. A fix needs a different timer mechanism.
	if no_eat_delay or (vlf_hunger.last_eat[name] < 0) or (os.difftime(os.time(), vlf_hunger.last_eat[name]) >= 2) then
		local can_eat_when_full = creative or (vlf_hunger.active == false)
		or minetest.get_item_group(itemstack:get_name(), "can_eat_when_full") == 1
		-- Don't allow eating when player has full hunger bar (some exceptional items apply)
		if can_eat_when_full or (vlf_hunger.get_hunger(user) < 20) then
			itemstack = vlf_hunger.eat(hp_change, replace_with_item, itemstack, user, pointed_thing)
			for _, callback in pairs(minetest.registered_on_item_eats) do
				local result = callback(hp_change, replace_with_item, itemstack, user, pointed_thing, old_itemstack)
				if result then
					return result
				end
			end
			vlf_hunger.last_eat[name] = os.time()
		end
	end

	return itemstack
end

function vlf_hunger.eat(hp_change, replace_with_item, itemstack, user, _)
	local item = itemstack:get_name()
	local def = vlf_hunger.registered_foods[item]
	if not def then
		def = {}
		if type(hp_change) ~= "number" then
			hp_change = 1
			minetest.log("error", "Wrong on_use() definition for item '" .. item .. "'")
		end
		def.saturation = hp_change
		def.replace = replace_with_item
	end
	local func = vlf_hunger.item_eat(def.saturation, def.replace, def.poisontime, def.poison, def.exhaust, def.poisonchance)
	return func(itemstack, user)
end

-- Reset HUD bars after food poisoning

function vlf_hunger.reset_bars_poison_hunger(player)
	hb.change_hudbar(player, "hunger", nil, nil, "hbhunger_icon.png", nil, "hbhunger_bar.png")
	if vlf_hunger.debug then
		hb.change_hudbar(player, "exhaustion", nil, nil, nil, nil, "vlf_hunger_bar_exhaustion.png")
	end
end

local poisonrandomizer = PseudoRandom(os.time())

function vlf_hunger.item_eat(hunger_change, replace_with_item, poisontime, poison, exhaust, poisonchance)
	return function(itemstack, user)
		if not user or not user.is_player or not user:is_player() or user.is_fake_player then return itemstack end
		local itemname = itemstack:get_name()
		local creative = minetest.is_creative_enabled(user:get_player_name())
		if itemstack:peek_item() and user then
			if not creative then
				itemstack:take_item()
			end
			local name = user:get_player_name()
			--local hp = user:get_hp()

			local pos = user:get_pos()
			-- player height
			pos.y = pos.y + 1.5
			local foodtype = minetest.get_item_group(itemname, "food")
			if foodtype == 3 then
				-- Item is a drink, only play drinking sound (no particle)
				minetest.sound_play("survival_thirst_drink", {
					max_hear_distance = 12,
					gain = 1.0,
					pitch = 1 + math.random(-10, 10)*0.005,
					object = user,
				}, true)
			else
				-- Assume the item is a food
				-- Add eat particle entity_effect and sound
				local def = minetest.registered_items[itemname]
				local texture = def.inventory_image
				if not texture or texture == "" then
					texture = def.wield_image
				end
				-- Special item definition field: _food_particles
				-- If false, force item to not spawn any food partiles when eaten
				if def._food_particles ~= false and texture and texture ~= "" then
					local v = user:get_velocity() or user:get_player_velocity()
					for i = 0, math.min(math.max(8, hunger_change*2), 25) do
						minetest.add_particle({
							pos = { x = pos.x, y = pos.y, z = pos.z },
							velocity = vector.add(v, { x = math.random(-1, 1), y = math.random(1, 2), z = math.random(-1, 1) }),
							acceleration = { x = 0, y = math.random(-9, -5), z = 0 },
							expirationtime = 1,
							size = math.random(1, 2),
							collisiondetection = true,
							vertical = false,
							texture = "[combine:3x3:" .. -i .. "," .. -i .. "=" .. texture,
						})
					end
				end
				minetest.sound_play("vlf_hunger_bite", {
					max_hear_distance = 12,
					gain = 1.0,
					pitch = 1 + math.random(-10, 10)*0.005,
					object = user,
				}, true)
			end

			if vlf_hunger.active and hunger_change then
				-- Add saturation (must be defined in item table)
				local _vlf_saturation = minetest.registered_items[itemname]._vlf_saturation
				local saturation
				if not _vlf_saturation then
					saturation = 0
				else
					saturation = minetest.registered_items[itemname]._vlf_saturation
				end
				vlf_hunger.saturate(name, saturation, false)

				-- Add food points
				local h = vlf_hunger.get_hunger(user)
				if h < 20 and hunger_change then
					h = h + hunger_change
					if h > 20 then h = 20 end
					vlf_hunger.set_hunger(user, h, false)
				end

				hb.change_hudbar(user, "hunger", h)
				vlf_hunger.update_saturation_hud(user, vlf_hunger.get_saturation(user), h)
			elseif not vlf_hunger.active and hunger_change then
				user:set_hp(math.min(user:get_properties().hp_max or 20, user:get_hp() + hunger_change))
			end
			-- Poison
			if vlf_hunger.active and poisontime then
				local do_poison = false
				if poisonchance then
					if poisonrandomizer:next(0,100) < poisonchance then
						do_poison = true
					end
				else
					do_poison = true
				end
				if do_poison then
					local level = vlf_entity_effects.get_entity_effect_level(user, "hunger")
					vlf_entity_effects.give_entity_effect_by_level("hunger", user, level+exhaust, poisontime)
				end
			end

			if not creative then
				local nstack = ItemStack(replace_with_item)
				local inv = user:get_inventory()
				if itemstack:get_count() == 1 then
					itemstack:add_item(replace_with_item)
				elseif inv:room_for_item("main",nstack) then
					inv:add_item("main", nstack)
				else
					minetest.add_item(user:get_pos(), nstack)
				end
			end
		end
		return itemstack
	end
end

if vlf_hunger.active then
	-- player-action based hunger changes
	minetest.register_on_dignode(function(_, _, player)
		-- is_fake_player comes from the pipeworks, we are not interested in those
		if not player or not player:is_player() or player.is_fake_player == true then
			return
		end
		local name = player:get_player_name()
		-- dig event
		vlf_hunger.exhaust(name, vlf_hunger.EXHAUST_DIG)
	end)
end
