vlf_dyes = {}

local S = minetest.get_translator(minetest.get_current_modname())
local D = vlf_util.get_dynamic_translator()

-- Common color table to be used by other mods. The "vlf2" field if present
-- represents the name of the color in vlf2 if it is different. This is used
-- in the vlf_dye compat mod to adabt the recipes.
vlf_dyes.colors = {
	["white"] = {
		readable_name = "White",
		groups = {basecolor_white=1,   excolor_white=1,     unicolor_white=1},
		rgb = "#d0d6d7",
		unicolor = "white",
		vlf2 = "white",
	},
	["silver"] = {
		readable_name = "Light Grey",
		groups = {basecolor_grey=1,    excolor_grey=1,      unicolor_grey=1},
		rgb = "#818177",
		unicolor = "grey",
		vlf2 = "grey",
	},
	["grey"] = {
		readable_name = "Grey",
		groups = {basecolor_grey=1,    excolor_darkgrey=1,  unicolor_darkgrey=1},
		rgb = "#383c40",
		unicolor = "darkgrey",
		vlf2 = "dark_grey",
	},
	["black"] = {
		readable_name = "Black",
		groups = {basecolor_black=1,   excolor_black=1,     unicolor_black=1},
		rgb = "#080a10",
		unicolor = "black",
		vlf2 = "black",
	},
	["purple"] = {
		readable_name = "Purple",
		groups = {basecolor_magenta=1, excolor_violet=1,    unicolor_violet=1},
		rgb = "#6821a0",
		unicolor = "violet",
		vlf2 = "violet",
	},
	["blue"] = {
		readable_name = "Blue",
		groups = {basecolor_blue=1,    excolor_blue=1,      unicolor_blue=1},
		rgb = "#2e3094",
		unicolor = "blue",
		vlf2 = "blue",
	},
	["light_blue"] = {
		readable_name = "Light Blue",
		groups = {basecolor_blue=1,    excolor_blue=1,      unicolor_light_blue=1},
		rgb = "#258ec9",
		unicolor = "light_blue",
		vlf2 = "lightblue",
	},
	["cyan"] = {
		readable_name = "Cyan",
		groups = {basecolor_cyan=1,    excolor_cyan=1,      unicolor_cyan=1},
		rgb = "#167b8c",
		unicolor = "cyan",
		vlf2 = "cyan",
	},
	["green"] = {
		readable_name = "Green",
		groups = {basecolor_green=1,   excolor_green=1,     unicolor_dark_green=1},
		rgb = "#4b5e25",
		unicolor = "dark_green",
		vlf2 = "dark_green",
	},
	["lime"] = {
		readable_name = "Lime",
		groups = {basecolor_green=1,   excolor_green=1,     unicolor_green=1},
		rgb = "#60ac19",
		unicolor = "green",
		vlf2 = "green",
	},
	["yellow"] = {
		readable_name = "Yellow",
		groups = {basecolor_yellow=1,  excolor_yellow=1,    unicolor_yellow=1},
		rgb = "#f1b216",
		unicolor = "yellow",
		vlf2 = "yellow",
	},
	["brown"] = {
		readable_name = "Brown",
		groups = {basecolor_brown=1,   excolor_orange=1,    unicolor_dark_orange=1},
		rgb = "#633d20",
		unicolor = "dark_orange",
		vlf2 = "brown",
	},
	["orange"] = {
		readable_name = "Orange",
		groups = {basecolor_orange=1,  excolor_orange=1,    unicolor_orange=1},
		rgb = "#e26501",
		unicolor = "orange",
		vlf2 = "orange",
	},
	["red"] = {
		readable_name = "Red",
		groups = {basecolor_red=1,     excolor_red=1,       unicolor_red=1},
		rgb = "#912222",
		unicolor = "red",
		vlf2 = "red",
	},
	["magenta"] = {
		readable_name = "Magenta",
		groups = {basecolor_magenta=1, excolor_red_violet=1,unicolor_red_violet=1},
		rgb = "#ab31a2",
		unicolor = "red_violet",
		vlf2 = "magenta",
	},
	["pink"] = {
		readable_name = "Pink",
		groups = {basecolor_red=1,     excolor_red=1,       unicolor_light_red=1},
		rgb = "#d56791",
		unicolor = "light_red",
		vlf2 = "pink",
	},
}

-- Takes an unicolor group name (e.g. “unicolor_white”) and returns a
-- corresponding dye name (if it exists), nil otherwise.
function vlf_dyes.unicolor_to_dye(unicolor_group)
	for k,v in pairs(vlf_dyes.colors) do
		if v.groups[unicolor_group] == 1 then return "vlf_dyes:"..k end
	end
end

function vlf_dyes.vlf2_to_color(vlf2color)
	for k,v in pairs(vlf_dyes.colors) do
		if vlf2color == v.vlf2 then return k end
	end
end

for k,v in pairs(vlf_dyes.colors) do
	minetest.register_craftitem("vlf_dyes:" .. k, {
		inventory_image = "vlf_dye_white.png^(vlf_dye_mask.png^[colorize:"..v.rgb..")",
		description = D(v.readable_name .. " Dye"),
		_doc_items_longdesc = S("This item is a dye which is used for dyeing and crafting."),
		_doc_items_usagehelp = S("Rightclick on a sheep to dye its wool. Other things are dyed by crafting."),
		groups = table.update({craftitem = 1, dye = 1}, v.groups),
		_color = k,
		on_place = function(itemstack,placer,pointed_thing)
			local def = minetest.registered_nodes[minetest.get_node(pointed_thing.under).name]
			if def and def._on_dye_place then
				local ret = def._on_dye_place(pointed_thing.under,k)
				if not minetest.is_creative_enabled(placer and placer:get_player_name() or "") then
					if ret ~= true then itemstack:take_item() end
				end
			else
				local rc = vlf_util.call_on_rightclick(itemstack, placer, pointed_thing)
				if rc then return rc end
			end

			return itemstack
		end,
	})
end

minetest.register_craft({
	output = "vlf_dyes:white",
	recipe = {{"vlf_flowers:lily_of_the_valley"}},
})

minetest.register_craft({
	output = "vlf_dyes:white 3",
	recipe = {{"vlf_bone_meal:bone_meal"}},
})

minetest.register_craft({
	output = "vlf_dyes:black",
	recipe = {{"vlf_mobitems:ink_sac"}},
})

minetest.register_craft({
	output = "vlf_dyes:yellow",
	recipe = {{"vlf_flowers:dandelion"}},
})

minetest.register_craft({
	output = "vlf_dyes:yellow 2",
	recipe = {{"vlf_flowers:sunflower"}},
})

minetest.register_craft({
	output = "vlf_dyes:blue",
	recipe = {{"vlf_core:lapis"}},
})

minetest.register_craft({
	output = "vlf_dyes:blue",
	recipe = {{"vlf_flowers:cornflower"}},
})

minetest.register_craft({
	output = "vlf_dyes:light_blue",
	recipe = {{"vlf_flowers:blue_orchid"}},
})

minetest.register_craft({
	output = "vlf_dyes:silver",
	recipe = {{"vlf_flowers:azure_bluet"}},
})

minetest.register_craft({
	output = "vlf_dyes:silver",
	recipe = {{"vlf_flowers:oxeye_daisy"}},
})

minetest.register_craft({
	output = "vlf_dyes:silver",
	recipe = {{"vlf_flowers:tulip_white"}},
})

minetest.register_craft({
	output = "vlf_dyes:magenta",
	recipe = {{"vlf_flowers:allium"}},
})

minetest.register_craft({
	output = "vlf_dyes:magenta 2",
	recipe = {{"vlf_flowers:lilac"}},
})

minetest.register_craft({
	output = "vlf_dyes:orange",
	recipe = {{"vlf_flowers:tulip_orange"}},
})

minetest.register_craft({
	output = "vlf_dyes:brown",
	recipe = {{"vlf_cocoas:cocoa_beans"}},
})

minetest.register_craft({
	output = "vlf_dyes:pink",
	recipe = {{"vlf_flowers:tulip_pink"}},
})

minetest.register_craft({
	output = "vlf_dyes:pink 2",
	recipe = {{"vlf_flowers:peony"}},
})

minetest.register_craft({
	output = "vlf_dyes:red",
	recipe = {{"vlf_farming:beetroot_item"}},
})

minetest.register_craft({
	output = "vlf_dyes:red",
	recipe = {{"vlf_flowers:poppy"}},
})

minetest.register_craft({
	output = "vlf_dyes:red",
	recipe = {{"vlf_flowers:tulip_red"}},
})

minetest.register_craft({
	output = "vlf_dyes:red 2",
	recipe = {{"vlf_flowers:rose_bush"}},
})

minetest.register_craft({
	type = "shapeless",
	output = "vlf_dyes:grey 2",
	recipe = {"vlf_dyes:black", "vlf_dyes:white"},
})

minetest.register_craft({
	type = "shapeless",
	output = "vlf_dyes:light_blue 2",
	recipe = {"vlf_dyes:blue", "vlf_dyes:white"},
})

minetest.register_craft({
	type = "shapeless",
	output = "vlf_dyes:silver 3",
	recipe = {"vlf_dyes:black", "vlf_dyes:white", "vlf_dyes:white"},
})

minetest.register_craft({
	type = "shapeless",
	output = "vlf_dyes:silver 2",
	recipe = {"vlf_dyes:grey", "vlf_dyes:white"},
})

minetest.register_craft({
	type = "shapeless",
	output = "vlf_dyes:lime 2",
	recipe = {"vlf_dyes:green", "vlf_dyes:white"},
})

minetest.register_craft({
	type = "shapeless",
	output = "vlf_dyes:magenta 4",
	recipe = {"vlf_dyes:blue", "vlf_dyes:white", "vlf_dyes:red", "vlf_dyes:red"},
})

minetest.register_craft({
	type = "shapeless",
	output = "vlf_dyes:magenta 3",
	recipe = {"vlf_dyes:pink", "vlf_dyes:red", "vlf_dyes:blue"},
})

minetest.register_craft({
	type = "shapeless",
	output = "vlf_dyes:magenta 2",
	recipe = {"vlf_dyes:purple", "vlf_dyes:pink"},
})

minetest.register_craft({
	type = "shapeless",
	output = "vlf_dyes:pink 2",
	recipe = {"vlf_dyes:red", "vlf_dyes:white"},
})

minetest.register_craft({
	type = "shapeless",
	output = "vlf_dyes:cyan 2",
	recipe = {"vlf_dyes:blue", "vlf_dyes:green"},
})

minetest.register_craft({
	type = "shapeless",
	output = "vlf_dyes:purple 2",
	recipe = {"vlf_dyes:blue", "vlf_dyes:red"},
})

minetest.register_craft({
	type = "shapeless",
	output = "vlf_dyes:orange 2",
	recipe = {"vlf_dyes:yellow", "vlf_dyes:red"},
})
