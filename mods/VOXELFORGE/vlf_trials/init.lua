local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

vlf_trials = {}

dofile(modpath.."/ominous.lua")
dofile(modpath.."/ominous_item_spawner.lua")
dofile(modpath.."/trial_spawner.lua")
