local S = minetest.get_translator(minetest.get_current_modname())

vlf_torches.register_torch({
	name = "torch",
	description = S("Torch"),
	doc_items_longdesc = S("Torches are light sources which can be placed at the side or on the top of most blocks."),
	doc_items_hidden = false,
	icon = "default_torch_on_floor.png",
	tiles = {{
		name = "default_torch_on_floor_animated.png",
		animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 3.3}
	}},
	-- this is 15 in minecraft
	light = 14,
	groups = {dig_immediate = 3, deco_block = 1},
	sounds = vlf_sounds.node_sound_wood_defaults(),
	particles = true,
	flame_type = 1,
})

minetest.register_craft({
	output = "vlf_torches:torch 4",
	recipe = {
		{"group:coal"},
		{"vlf_core:stick"},
	}
})

