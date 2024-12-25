--Bow
dofile(minetest.get_modpath("vlf_bows") .. "/arrow.lua")
dofile(minetest.get_modpath("vlf_bows") .. "/bow.lua")

--Crossbow
dofile(minetest.get_modpath("vlf_bows") .. "/crossbow.lua")

--Compatiblility with older MineClone worlds
minetest.register_alias("vlf_throwing:bow", "vlf_bows:bow")
minetest.register_alias("vlf_throwing:arrow", "vlf_bows:arrow")
