mcl_trees = {}
mcl_trees.woods = {}

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)

dofile(modpath.."/functions.lua")
dofile(modpath.."/api.lua")
dofile(modpath.."/items.lua")
dofile(modpath.."/recipes.lua")
dofile(modpath.."/abms.lua")

dofile(modpath.."/aliases.lua")
