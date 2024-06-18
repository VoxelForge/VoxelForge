minetest.register_on_joinplayer(function(player)
	player:set_formspec_prepend(vlc_vars.gui_nonbg .. vlc_vars.gui_bg_color .. vlc_vars.gui_bg_img)
end)
