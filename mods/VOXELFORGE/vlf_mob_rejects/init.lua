local modpath = minetest.get_modpath("vlf_mob_rejects")
dofile(modpath.."/copper_golem.lua")

minetest.register_entity(":mobs_mc:firefly", {
    initial_properties = {
        physical = true,
        collide_with_objects = false,
        visual = "sprite",
        textures = {"blank.png"},
        automatic_rotate = math.pi / 90,
    },

    on_activate = function(self, staticdata, dtime_s)
        self.object:remove() -- Remove the entity immediately on activation
    end,
})

minetest.register_alias("mobs_mc:firefly_spawner", "air")
