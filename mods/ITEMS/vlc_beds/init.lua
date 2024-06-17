vlc_beds = {}
vlc_beds.player = {}
vlc_beds.pos = {}
vlc_beds.bed_pos = {}

local modpath = minetest.get_modpath("vlc_beds")

-- Load files

dofile(modpath .. "/functions.lua")
dofile(modpath .. "/api.lua")
dofile(modpath .. "/beds.lua")
dofile(modpath .. "/respawn_anchor.lua")