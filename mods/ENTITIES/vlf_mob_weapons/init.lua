minetest.register_entity("vlf_mob_weapons:bow",{
	initial_properties = {
		textures = {"vlf_bows:bow_0"},
		hp_max = 10,
		visual = "wielditem",
		visual_size = {x=0.08, y=0.08},
		collisionbox = {-0.0,-0.0,-0.0,0.0,0.0,0.0},
		pointable = false,
		physical = true,
		collide_with_objects = false,
	},
	on_step = function(self, dtime, moveresult)
		-- Check if the entity is attached
		if not self.object:get_attach() then
			-- If not attached, remove the entity
			self.object:remove()
		end
	end,
})
