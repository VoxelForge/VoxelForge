local S = minetest.get_translator("mcl_potions")
mcl_potions.register_potion({
	name = "infestation",
	desc_suffix = S("of Infestation"),
	_tt = nil,
	_longdesc = S("Causes 1-2 silverfish to spawn with a 10% chance when damaged"),
	color = "#472331",
	_effect_list = {
		infested = {},
	},
	has_arrow = true,
})

mcl_potions.register_potion({
	name = "oozing",
	desc_suffix = S("of Oozing"),
	_tt = nil,
	_longdesc = S("Causes 2 medium slimes to spawn on death"),
	color = "#60AA30",
	_effect_list = {
		oozing = {},
	},
	has_arrow = true,
})

mcl_potions.register_potion({
	name = "weaving",
	desc_suffix = S("of Weaving"),
	_tt = nil,
	_longdesc = S("Causes 2-3 cobwebs to appear on death"),
	color = "#ACCCFF",
	_effect_list = {
		weaving = {},
	},
	has_arrow = true,
})
mcl_potions.register_potion({
	name = "wind_charged",
	desc_suffix = S("of Wind Charging"),
	_tt = nil,
	_longdesc = S("Causes A wind burst on death"),
	color = "#CEE1FE",
	_effect_list = {
		wind_charged = {},
	},
	has_arrow = true,
})
