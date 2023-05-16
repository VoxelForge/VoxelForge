local S = minetest.get_translator("mcl_bamboo")

local wood_groups = { handy = 1, axey = 1, flammable = 2, fence_wood = 1, fire_encouragement = 5, fire_flammability = 20 }

-- Due to door fix #2736, doors are displayed backwards. When this is fixed, set this variable to false.
local BROKEN_DOORS = true

local top_door_tiles = { "mcl_bamboo_door_top.png", "mcl_bamboo_door_top.png" }
local bot_door_tiles = { "mcl_bamboo_door_bottom.png", "mcl_bamboo_door_bottom.png" }

if BROKEN_DOORS then
	top_door_tiles = { "mcl_bamboo_door_top_alt.png", "mcl_bamboo_door_top.png" }
	bot_door_tiles = { "mcl_bamboo_door_bottom_alt.png", "mcl_bamboo_door_bottom.png" }
end

mcl_doors:register_door("mcl_bamboo:bamboo_door", {
	description = S("Bamboo Door."),
	inventory_image = "mcl_bamboo_door_wield.png",
	wield_image = "mcl_bamboo_door_wield.png",
	groups = { handy = 1, axey = 1, material_wood = 1, flammable = -1 },
	_mcl_hardness = 3,
	_mcl_blast_resistance = 3,
	tiles_bottom = bot_door_tiles,
	tiles_top = top_door_tiles,
	sounds = mcl_sounds.node_sound_wood_defaults(),
})

mcl_doors:register_trapdoor("mcl_bamboo:bamboo_trapdoor", {
	description = S("Bamboo Trapdoor."),
	inventory_image = "mcl_bamboo_door_complete.png",
	groups = {},
	tile_front = "mcl_bamboo_trapdoor_side.png",
	tile_side = "mcl_bamboo_trapdoor_side.png",
	_doc_items_longdesc = S("Wooden trapdoors are horizontal barriers which can be opened and closed by hand or a redstone signal. They occupy the upper or lower part of a block, depending on how they have been placed. When open, they can be climbed like a ladder."),
	_doc_items_usagehelp = S("To open or close the trapdoor, rightclick it or send a redstone signal to it."),
	wield_image = "mcl_bamboo_trapdoor_side.png",
	inventory_image = "mcl_bamboo_trapdoor_side.png",
	groups = { handy = 1, axey = 1, mesecon_effector_on = 1, material_wood = 1, flammable = -1 },
	_mcl_hardness = 3,
	_mcl_blast_resistance = 3,
	sounds = mcl_sounds.node_sound_wood_defaults(),
})

mcl_flowerpots.register_potted_cube("mcl_bamboo:bamboo", { name = "bamboo_plant",
				   desc = S("Bamboo"),
				   image = "mcl_bamboo_bamboo_fpm.png",
})

mcl_stairs.register_stair_and_slab_simple(
		"bamboo_block",
		"mcl_bamboo:bamboo_block",
		S("Bamboo Stair"),
		S("Bamboo Slab"),
		S("Double Bamboo Slab")
)
mcl_stairs.register_stair_and_slab_simple(
		"bamboo_stripped",
		"mcl_bamboo:bamboo_block_stripped",
		S("Stripped Bamboo Stair"),
		S("Stripped Bamboo Slab"),
		S("Double Stripped Bamboo Slab")
)
mcl_stairs.register_stair_and_slab_simple(
		"bamboo_plank",
		"mcl_bamboo:bamboo_plank",
		S("Bamboo Plank Stair"),
		S("Bamboo Plank Slab"),
		S("Double Bamboo Plank Slab")
)

minetest.override_item("mcl_stairs:slab_bamboo_plank", { groups = {
	wood_slab = 1,
	building_block = 1,
	slab = 1,
	axey = 1,
	handy = 1,
	stair = 1,
	flammable = 1,
	fire_encouragement = 5,
	fire_flammability = 20
}})

mesecon.register_pressure_plate(
		"mcl_bamboo:pressure_plate_bamboo_wood",
		S("Bamboo Pressure Plate"),
		{ "mcl_bamboo_bamboo_plank.png" },
		{ "mcl_bamboo_bamboo_plank.png" },
		"mcl_bamboo_bamboo_plank.png",
		nil,
		{ { "mcl_bamboo:bamboo_plank", "mcl_bamboo:bamboo_plank" } },
		mcl_sounds.node_sound_wood_defaults(),
		{ axey = 1, material_wood = 1 },
		nil,
		S("A wooden pressure plate is a redstone component which supplies its surrounding blocks with redstone power while any movable object (including dropped items, players and mobs) rests on top of it."))

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_bamboo:pressure_plate_bamboo_wood_off",
	burntime = 15
})

mcl_signs.register_sign_custom("mcl_bamboo", "_bamboo", "mcl_bamboo_bamboo_sign.png",
		"#ffffff", "mcl_bamboo_bamboo_sign_wield.png", "mcl_bamboo_bamboo_sign_wield.png",
		"Bamboo Sign")
mcl_signs.register_sign_craft("mcl_bamboo", "mcl_bamboo:bamboo_plank", "_bamboo")


mcl_fences.register_fence("bamboo_fence", S("Bamboo Fence"), "mcl_bamboo_fence_bamboo.png", wood_groups,
			2, 15, { "group:fence_wood" }, mcl_sounds.node_sound_wood_defaults())
mcl_fences.register_fence_gate("bamboo_fence", S("Bamboo Fence Gate"), "mcl_bamboo_fence_gate_bamboo.png",
			wood_groups, 2, 15, mcl_sounds.node_sound_wood_defaults()) -- note: about missing params.. will use defaults.
--[[
mesecon.register_button(
		"bamboo",
		S("Bamboo Button"),
		"mcl_bamboo_bamboo_plank.png",
		BAMBOO_PLANK,
		mcl_sounds.node_sound_wood_defaults(),
		{ material_wood = 1, handy = 1, pickaxey = 1, flammable = 3, fire_flammability = 20, fire_encouragement = 5, },
		1,
		false,
		S("A bamboo button is a redstone component made out of stone which can be pushed to provide redstone power. When pushed, it powers adjacent redstone components for 1 second."),
		"mesecons_button_push")
--]]
