minetest.register_lbm({
	label = "Update shulker box formspecs (0.72.0)",
	name = ":vlf_chests:update_shulker_box_formspecs_0_72_0",
	nodenames = { "group:shulker_box" },
	run_at_every_load = false,
	action = function(pos, node)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", vlf_chests.formspec_shulker_box(meta:get_string("name")))
	end,
})

minetest.register_lbm({
	label = "Upgrade old ender chest formspec",
	name = ":vlf_chests:replace_old_ender_form",
	nodenames = { "vlf_chests:ender_chest_small" },
	run_at_every_load = false,
	action = function(pos, node)
		minetest.get_meta(pos):set_string("formspec", "")
	end,
})
