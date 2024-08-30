local S = minetest.get_translator(minetest.get_current_modname())

local mod_target = minetest.get_modpath("vlf_target")

minetest.register_entity("vlf_experience:bottle",{
	initial_properties = {
		textures = {"vlf_experience_bottle.png"},
		hp_max = 1,
		visual_size = {x = 0.35, y = 0.35},
		collisionbox = {-0.1, -0.1, -0.1, 0.1, 0.1, 0.1},
		pointable = false,
	},
	on_step = function(self, dtime)
		local pos = self.object:get_pos()
		local node = minetest.get_node(pos)
		local n = node.name
		if n ~= "air" and n ~= "vlf_portals:portal" and n ~= "vlf_portals:portal_end" and minetest.get_item_group(n, "liquid") == 0 then
			minetest.sound_play("vlf_entity_effects_breaking_glass", {pos = pos, max_hear_distance = 16, gain = 1})
			vlf_experience.throw_xp(pos, math.random(3, 11))
			minetest.add_particlespawner({
				amount = 50,
				time = 0.1,
				minpos = vector.add(pos, vector.new(-0.1, 0.5, -0.1)),
				maxpos = vector.add(pos, vector.new( 0.1, 0.6,  0.1)),
				minvel = vector.new(-2, 0, -2),
				maxvel = vector.new( 2, 2,  2),
				minacc = vector.new(0, 0, 0),
				maxacc = vector.new(0, 0, 0),
				minexptime = 0.5,
				maxexptime = 1.25,
				minsize = 1,
				maxsize = 2,
				collisiondetection = true,
				vertical = false,
				texture = "vlf_particles_entity_effect.png^[colorize:blue:127",
			})
			if mod_target and n == "vlf_target:target_off" then
				vlf_target.hit(vector.round(pos), 0.4) --4 redstone ticks
			end
			self.object:remove()
		end
	end,
})

local function throw_xp_bottle(pos, dir, velocity)
	minetest.sound_play("vlf_throwing_throw", {pos = pos, gain = 0.4, max_hear_distance = 16}, true)
	local obj = minetest.add_entity(pos, "vlf_experience:bottle")
	if not obj or not obj:get_pos() then return end
	obj:set_velocity(vector.multiply(dir, velocity))
	local acceleration = vector.multiply(dir, -3)
	acceleration.y = -9.81
	obj:set_acceleration(acceleration)
end

minetest.register_craftitem("vlf_experience:bottle", {
	description = S("Bottle o' Enchanting"),
	inventory_image = "vlf_experience_bottle.png",
	wield_image = "vlf_experience_bottle.png",
	on_use = function(itemstack, placer, pointed_thing)
		throw_xp_bottle(vector.add(placer:get_pos(), vector.new(0, 1.5, 0)), placer:get_look_dir(), 10)
		if not minetest.is_creative_enabled(placer:get_player_name()) then
			itemstack:take_item()
		end
		return itemstack
	end,
	_on_dispense = function(_, pos, _, _, dir)
		throw_xp_bottle(vector.add(pos, vector.multiply(dir, 0.51)), dir, 10)
	end
})

