vlf_beds = {}
vlf_beds.player = {}
vlf_beds.pos = {}
vlf_beds.bed_pos = {}

local modpath = minetest.get_modpath("vlf_beds")

-- Load files

dofile(modpath .. "/functions.lua")
dofile(modpath .. "/api.lua")
dofile(modpath .. "/beds.lua")
dofile(modpath .. "/respawn_anchor.lua")