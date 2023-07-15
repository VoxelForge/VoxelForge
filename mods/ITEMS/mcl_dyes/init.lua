-- To make recipes that will work with any dye ever made by anybody, define
-- them based on groups.
-- You can select any group of groups, based on your need for amount of colors.
-- basecolor: 9, excolor: 17, unicolor: 89
--
-- Example of one shapeless recipe using a color group:
-- Note: As this uses basecolor_*, you'd need 9 of these.
-- minetest.register_craft({
--     type = "shapeless",
--     output = "<mod>:item_yellow",
--     recipe = {"<mod>:item_no_color", "group:basecolor_yellow"},
-- })

mcl_dyes = {}

local S = minetest.get_translator(minetest.get_current_modname())

local dyes = {
	{"white",	S("White Dye"),		{basecolor_white=1,   excolor_white=1,     unicolor_white=1}},
	{"grey",	S("Light Grey Dye"),	{basecolor_grey=1,    excolor_grey=1,      unicolor_grey=1}},
	{"dark_grey",	S("Grey Dye"),		{basecolor_grey=1,    excolor_darkgrey=1,  unicolor_darkgrey=1}},
	{"black",	S("Black Dye"),		{basecolor_black=1,   excolor_black=1,     unicolor_black=1}},
	{"violet",	S("Purple Dye"),	{basecolor_magenta=1, excolor_violet=1,    unicolor_violet=1}},
	{"blue",	S("Blue Dye"),		{basecolor_blue=1,    excolor_blue=1,      unicolor_blue=1}},
	{"lightblue",	S("Light Blue Dye"),	{basecolor_blue=1,    excolor_blue=1,      unicolor_light_blue=1}},
	{"cyan",	S("Cyan Dye"),		{basecolor_cyan=1,    excolor_cyan=1,      unicolor_cyan=1}},
	{"dark_green",	S("Cactus Green"),	{basecolor_green=1,   excolor_green=1,     unicolor_dark_green=1}},
	{"green",	S("Lime Dye"),		{basecolor_green=1,   excolor_green=1,     unicolor_green=1}},
	{"yellow",	S("Dandelion Yellow"),	{basecolor_yellow=1,  excolor_yellow=1,    unicolor_yellow=1}},
	{"brown",	S("Brown Dye"),		{basecolor_brown=1,   excolor_orange=1,    unicolor_dark_orange=1}},
	{"orange",	S("Orange Dye"),	{basecolor_orange=1,  excolor_orange=1,    unicolor_orange=1}},
	{"red",		S("Rose Red"),		{basecolor_red=1,     excolor_red=1,       unicolor_red=1}},
	{"magenta",	S("Magenta Dye"),	{basecolor_magenta=1, excolor_red_violet=1,unicolor_red_violet=1}},
	{"pink",	S("Pink Dye"),		{basecolor_red=1,     excolor_red=1,       unicolor_light_red=1}},
}

local unicolor_to_dye_id = {}
for d = 1, #dyes do
	for k, _ in pairs(dyes[d][3]) do
		if string.sub(k, 1, 9) == "unicolor_" then
			unicolor_to_dye_id[k] = dyes[d][1]
		end
	end
end

-- Takes an unicolor group name (e.g. “unicolor_white”) and returns a
-- corresponding dye name (if it exists), nil otherwise.
function mcl_dyes.unicolor_to_dye(unicolor_group)
	local color = unicolor_to_dye_id[unicolor_group]
	if color then
		return "mcl_dyes:" .. color
	else
		return nil
	end
end

for _, row in pairs(dyes) do
	local name, desc, grps = unpack(row)
	minetest.register_craftitem("mcl_dyes:" .. name, {
		inventory_image = "mcl_dye_" .. name .. ".png",
		description = desc,
		_doc_items_longdesc = S("This item is a dye which is used for dyeing and crafting."),
		_doc_items_usagehelp = S("Rightclick on a sheep to dye its wool. Other things are dyed by crafting."),
		groups = table.update({craftitem = 1, dye = 1}, grps)
	})
end

minetest.register_craft({
	output = "mcl_dyes:white 3",
	recipe = {{"mcl_bone_meal:bone_meal"}},
})

minetest.register_craft({
	output = "mcl_dyes:black",
	recipe = {{"mcl_mobitems:ink_sac"}},
})

minetest.register_craft({
	output = "mcl_dyes:yellow",
	recipe = {{"mcl_flowers:dandelion"}},
})

minetest.register_craft({
	output = "mcl_dyes:yellow 2",
	recipe = {{"mcl_flowers:sunflower"}},
})

minetest.register_craft({
	output = "mcl_dyes:blue",
	recipe = {{"mcl_core:lapis"}},
})

minetest.register_craft({
	output = "mcl_dyes:lightblue",
	recipe = {{"mcl_flowers:blue_orchid"}},
})

minetest.register_craft({
	output = "mcl_dyes:grey",
	recipe = {{"mcl_flowers:azure_bluet"}},
})

minetest.register_craft({
	output = "mcl_dyes:grey",
	recipe = {{"mcl_flowers:oxeye_daisy"}},
})

minetest.register_craft({
	output = "mcl_dyes:grey",
	recipe = {{"mcl_flowers:tulip_white"}},
})

minetest.register_craft({
	output = "mcl_dyes:magenta",
	recipe = {{"mcl_flowers:allium"}},
})

minetest.register_craft({
	output = "mcl_dyes:magenta 2",
	recipe = {{"mcl_flowers:lilac"}},
})

minetest.register_craft({
	output = "mcl_dyes:orange",
	recipe = {{"mcl_flowers:tulip_orange"}},
})

minetest.register_craft({
	output = "mcl_dyes:brown",
	recipe = {{"mcl_cocoas:cocoa_beans"}},
})

minetest.register_craft({
	output = "mcl_dyes:pink",
	recipe = {{"mcl_flowers:tulip_pink"}},
})

minetest.register_craft({
	output = "mcl_dyes:pink 2",
	recipe = {{"mcl_flowers:peony"}},
})

minetest.register_craft({
	output = "mcl_dyes:red",
	recipe = {{"mcl_farming:beetroot_item"}},
})

minetest.register_craft({
	output = "mcl_dyes:red",
	recipe = {{"mcl_flowers:poppy"}},
})

minetest.register_craft({
	output = "mcl_dyes:red",
	recipe = {{"mcl_flowers:tulip_red"}},
})

minetest.register_craft({
	output = "mcl_dyes:red 2",
	recipe = {{"mcl_flowers:rose_bush"}},
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_dyes:dark_green",
	recipe = "mcl_core:cactus",
	cooktime = 10,
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dyes:dark_grey 2",
	recipe = {"mcl_dyes:black", "mcl_dyes:white"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dyes:lightblue 2",
	recipe = {"mcl_dyes:blue", "mcl_dyes:white"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dyes:grey 3",
	recipe = {"mcl_dyes:black", "mcl_dyes:white", "mcl_dyes:white"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dyes:grey 2",
	recipe = {"mcl_dyes:dark_grey", "mcl_dyes:white"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dyes:green 2",
	recipe = {"mcl_dyes:dark_green", "mcl_dyes:white"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dyes:magenta 4",
	recipe = {"mcl_dyes:blue", "mcl_dyes:white", "mcl_dyes:red", "mcl_dyes:red"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dyes:magenta 3",
	recipe = {"mcl_dyes:pink", "mcl_dyes:red", "mcl_dyes:blue"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dyes:magenta 2",
	recipe = {"mcl_dyes:violet", "mcl_dyes:pink"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dyes:pink 2",
	recipe = {"mcl_dyes:red", "mcl_dyes:white"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dyes:cyan 2",
	recipe = {"mcl_dyes:blue", "mcl_dyes:dark_green"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dyes:violet 2",
	recipe = {"mcl_dyes:blue", "mcl_dyes:red"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dyes:orange 2",
	recipe = {"mcl_dyes:yellow", "mcl_dyes:red"},
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_dyes:dark_green",
	recipe = "mcl_core:cactus",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_dyes:green",
	recipe = "group:sea_pickle",
	cooktime = 10,
})

dofile(minetest.get_modpath(minetest.get_current_modname()).."/alias.lua")
