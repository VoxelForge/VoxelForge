-- Backwards compat code for "old" 0.83 and prior pigman. This transforms all
-- existing pigmen into the new zombified piglins.
local S = minetest.get_translator(minetest.get_current_modname())
local pigman = {
	description = S("Zombified Piglin"),
	textures = {{ "" }},
	after_activate = function(self)
		self.object = vlc_util.replace_mob(self.object, "mobs_mc:zombified_piglin")
	end,
}

vlc_mobs.register_mob("mobs_mc:pigman", pigman)
vlc_mobs.register_mob("mobs_mc:baby_pigman", pigman)
