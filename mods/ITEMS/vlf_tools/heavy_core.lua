local S = minetest.get_translator(modname)
local heavy_core_longdesc = S("Solid Blocks of Steel. These are only forged if those worthy defeat the trials that await them.")

minetest.register_node("vlf_tools:heavy_core", {
    description = "" ..minetest.colorize(vlf_colors.DARK_PURPLE, S("Heavy Core")),
    _doc_long_desc = heavy_core_longdesc,
    tiles = {"vlf_tools_heavy_core_top.png", "vlf_tools_heavy_core_bottom.png", "vlf_tools_heavy_core_side.png"},
    is_ground_content = false,
    groups = {pickaxey = 1, building_block = 1},
    sounds = vlf_sounds.node_sound_stone_defaults(),
    paramtype2 = "facedir",
    drawtype = "nodebox",
    node_box = {
        type = "fixed",
        fixed = {
        	{-0.25, -0.5, -0.25, 0.25, 0.0, 0.25},
        },
    },
})
