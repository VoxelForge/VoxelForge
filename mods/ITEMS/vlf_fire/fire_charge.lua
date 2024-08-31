local S = minetest.get_translator(minetest.get_current_modname())

-- Fire Charge
minetest.register_craftitem("vlf_fire:fire_charge", {
	description = S("Fire Charge"),
	_tt_help = S("Dispenser projectile").."\n"..S("Starts fires and ignites blocks"),
	_doc_items_longdesc = S("Fire charges are primarily projectiles which can be launched from dispensers, they will fly in a straight line and burst into a fire on impact. Alternatively, they can be used to ignite fires directly."),
	_doc_items_usagehelp = S("Put the fire charge into a dispenser and supply it with redstone power to launch it. To ignite a fire directly, simply place the fire charge on the ground, which uses it up."),
	inventory_image = "vlf_fire_fire_charge.png",
	on_place = function(itemstack, user, pointed_thing)
		-- Use pointed node's on_rightclick function first, if present
		local new_stack = vlf_util.call_on_rightclick(itemstack, user, pointed_thing)
		if new_stack then
			return new_stack
		end

		-- Check protection
		local protname = user:get_player_name()
		if minetest.is_protected(pointed_thing.under, protname) then
			minetest.record_protection_violation(pointed_thing.under, protname)
			return itemstack
		end

		-- Ignite/light fire
		local node = minetest.get_node(pointed_thing.under)
		if pointed_thing.type == "node" then
			local nodedef = minetest.registered_nodes[node.name]
			if nodedef and nodedef._on_ignite then
				local overwrite = nodedef._on_ignite(user, pointed_thing)
				if not overwrite then
					vlf_fire.set_fire(pointed_thing, user, false)
				end
			else
				vlf_fire.set_fire(pointed_thing, user, false)
			end
			if not minetest.is_creative_enabled(user:get_player_name()) then
				itemstack:take_item()
			end
		end
		return itemstack
	end,
	_on_dispense = function(stack, pos, droppos, dropnode, dropdir)
		-- Throw fire charge
		local shootpos = vector.add(pos, vector.multiply(dropdir, 0.51))
		local fireball = minetest.add_entity(shootpos, "mobs_mc:blaze_fireball")
		if fireball and fireball:get_pos() then
			local ent = fireball:get_luaentity()
			ent._shot_from_dispenser = true
			local v = ent.velocity or 1
			fireball:set_velocity(vector.multiply(dropdir, v))
			ent.switch = 1
		end
		stack:take_item()
	end,
})

minetest.register_craft({
	type = "shapeless",
	output = "vlf_fire:fire_charge 3",
	recipe = { "vlf_mobitems:blaze_powder", "group:coal", "vlf_mobitems:gunpowder" },
})
