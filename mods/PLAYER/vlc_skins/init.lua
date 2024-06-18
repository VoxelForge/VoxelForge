local mod_path = minetest.get_modpath(minetest.get_current_modname())

local vlc_skins_enabled = minetest.settings:get_bool("vlc_enable_skin_customization", true)
if vlc_skins_enabled then
	dofile(mod_path .. "/edit_skin.lua")
	dofile(mod_path .. "/mesh_hand.lua")
end
