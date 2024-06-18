minetest.register_on_joinplayer(function(player)
	player:set_formspec_prepend(vlf_vars.gui_nonbg .. vlf_vars.gui_bg_color .. vlf_vars.gui_bg_img)
end)
