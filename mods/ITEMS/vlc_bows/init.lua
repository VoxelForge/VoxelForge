--Bow
dofile(minetest.get_modpath("vlc_bows") .. "/arrow.lua")
dofile(minetest.get_modpath("vlc_bows") .. "/bow.lua")

--Crossbow
dofile(minetest.get_modpath("vlc_bows") .. "/crossbow.lua")

--Compatiblility with older MineClone worlds
minetest.register_alias("vlc_throwing:bow", "vlc_bows:bow")
minetest.register_alias("vlc_throwing:arrow", "vlc_bows:arrow")
