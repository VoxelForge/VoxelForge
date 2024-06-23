vlf_core = {}

-- Repair percentage for toolrepair
vlf_core.repair = 0.05

vlf_autogroup.register_diggroup("handy")
vlf_autogroup.register_diggroup("pickaxey", {
	levels = { "wood", "gold", "stone", "iron", "diamond" }
})
vlf_autogroup.register_diggroup("axey")
vlf_autogroup.register_diggroup("shovely")
vlf_autogroup.register_diggroup("shearsy")
vlf_autogroup.register_diggroup("shearsy_wool")
vlf_autogroup.register_diggroup("shearsy_cobweb")
vlf_autogroup.register_diggroup("swordy")
vlf_autogroup.register_diggroup("swordy_cobweb")
vlf_autogroup.register_diggroup("hoey")

-- Load files
local modpath = minetest.get_modpath(minetest.get_current_modname())
dofile(modpath.."/functions.lua")
dofile(modpath.."/nodes_base.lua") -- Simple solid cubic nodes with simple definitions
dofile(modpath.."/nodes_liquid.lua") -- Liquids
dofile(modpath.."/nodes_trees.lua") -- Trees
dofile(modpath.."/nodes_cactuscane.lua") -- Cactus and sugar canes
dofile(modpath.."/nodes_glass.lua") -- Glass
dofile(modpath.."/nodes_climb.lua") -- Climbable nodes
dofile(modpath.."/nodes_stairs.lua")
dofile(modpath.."/nodes_misc.lua") -- Other and special nodes
dofile(modpath.."/craftitems.lua")
dofile(modpath.."/crafting.lua")
