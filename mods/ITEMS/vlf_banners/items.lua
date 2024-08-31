local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)

local function readable_name(str)
	str = str:gsub("_", " ")
    return (str:gsub("^%l", string.upper))
end

for _,pattern in pairs({"thing", "skull", "creeper", "flower", "bricks", "curly_border", "globe", "piglin" }) do
	minetest.register_craftitem("vlf_banners:pattern_"..pattern,{
		description = S(readable_name(pattern).." Banner Pattern"),
		_tt_help = minetest.colorize(vlf_colors.YELLOW, S("Can be used to craft special banner designs on the loom")),
		_doc_items_longdesc = S("Special Banner Pattern"),
		inventory_image = "vlf_banners_pattern_"..pattern..".png",
		wield_image = "vlf_banners_pattern_"..pattern..".png",
		groups = { banner_pattern = 1 },
		_pattern = pattern,
	})
end

minetest.register_craft({
	type = "shapeless",
	output = "vlf_banners:pattern_thing",
	recipe = { "vlf_core:paper", "vlf_core:apple_gold_enchanted" }
})
minetest.register_craft({
	type = "shapeless",
	output = "vlf_banners:pattern_skull",
	recipe = { "vlf_core:paper", "vlf_heads:wither_skeleton" }
})
minetest.register_craft({
	type = "shapeless",
	output = "vlf_banners:pattern_creeper",
	recipe = { "vlf_core:paper", "vlf_heads:creeper" }
})
minetest.register_craft({
	type = "shapeless",
	output = "vlf_banners:pattern_flower",
	recipe = { "vlf_core:paper", "vlf_flowers:oxeye_daisy" }
})
minetest.register_craft({
	type = "shapeless",
	output = "vlf_banners:pattern_bricks",
	recipe = { "vlf_core:paper", "vlf_core:brick_block" }
})
minetest.register_craft({
	type = "shapeless",
	output = "vlf_banners:pattern_curly_border",
	recipe = { "vlf_core:paper", "vlf_core:vine" }
})
