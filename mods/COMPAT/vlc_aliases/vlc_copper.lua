for _,v in pairs({"","_exposed","_weathered"}) do
	minetest.register_alias("mcl_copper:waxed_block"..v,"vlc_copper:block"..v.."_preserved")
	minetest.register_alias("mcl_copper:waxed_block"..v.."_cut","vlc_copper:block"..v.."_cut_preserved")
	minetest.register_alias("mcl_stairs:stair_waxed_copper"..v.."_cut","vlc_stairs:stair_copper"..v.."_cut_preserved")
	minetest.register_alias("mcl_stairs:stair_waxed_copper"..v.."_cut_inner","vlc_stairs:stair_copper"..v.."_cut_inner_preserved")
	minetest.register_alias("mcl_stairs:stair_waxed_copper"..v.."_cut_outer","vlc_stairs:stair_copper"..v.."_cut_outer_preserved")
	minetest.register_alias("mcl_stairs:slab_waxed_copper"..v.."_cut","vlc_stairs:slab_copper"..v.."_cut_preserved")
	minetest.register_alias("mcl_stairs:slab_waxed_copper"..v.."_cut_top","vlc_stairs:slab_copper"..v.."_cut_top_preserved")
	minetest.register_alias("mcl_stairs:slab_waxed_copper"..v.."_cut_double","mcl_stairs:slab_copper"..v.."_cut_double_preserved")
end

--waxed oxidized makes no sense - it doesn't exist anymore
minetest.register_alias("mcl_copper:waxed_block_oxidized","vlc_copper:waxed_block_oxidized")
minetest.register_alias("mcl_copper:waxed_block_oxidized_cut","vlc_copper:waxed_block_oxidized_cut")
minetest.register_alias("mcl_stairs:stair_waxed_copper_oxidized_cut","vlc_stairs:stair_waxed_copper_oxidized_cut")
minetest.register_alias("mcl_stairs:stair_waxed_copper_oxidized_cut_inner","vlc_stairs:stair_waxed_copper_oxidized_cut_inner")
minetest.register_alias("mcl_stairs:stair_waxed_copper_oxidized_cut_outer","vlc_stairs:stair_waxed_copper_oxidized_cut_outer")
minetest.register_alias("mcl_stairs:slab_waxed_copper_oxidized_cut","vlc_stairs:slab_waxed_copper_oxidized_cut")
minetest.register_alias("mcl_stairs:slab_waxed_copper_oxidized_cut_top","vlc_stairs:slab_waxed_copper_oxidized_cut_top")
minetest.register_alias("mcl_stairs:slab_waxed_copper_oxidized_cut_double","vlc_stairs:slab_waxed_copper_oxidized_cut_double")
