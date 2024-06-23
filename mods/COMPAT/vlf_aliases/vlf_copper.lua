for _,v in pairs({"","_exposed","_weathered"}) do
	minetest.register_alias("vlf_copper:waxed_block"..v,"vlf_copper:block"..v.."_preserved")
	minetest.register_alias("vlf_copper:waxed_block"..v.."_cut","vlf_copper:block"..v.."_cut_preserved")
	minetest.register_alias("vlf_stairs:stair_waxed_copper"..v.."_cut","vlf_stairs:stair_copper"..v.."_cut_preserved")
	minetest.register_alias("vlf_stairs:stair_waxed_copper"..v.."_cut_inner","vlf_stairs:stair_copper"..v.."_cut_inner_preserved")
	minetest.register_alias("vlf_stairs:stair_waxed_copper"..v.."_cut_outer","vlf_stairs:stair_copper"..v.."_cut_outer_preserved")
	minetest.register_alias("vlf_stairs:slab_waxed_copper"..v.."_cut","vlf_stairs:slab_copper"..v.."_cut_preserved")
	minetest.register_alias("vlf_stairs:slab_waxed_copper"..v.."_cut_top","vlf_stairs:slab_copper"..v.."_cut_top_preserved")
	minetest.register_alias("vlf_stairs:slab_waxed_copper"..v.."_cut_double","vlf_stairs:slab_copper"..v.."_cut_double_preserved")
end

--waxed oxidized makes no sense - it doesn't exist anymore
minetest.register_alias("vlf_copper:waxed_block_oxidized","vlf_copper:waxed_block_oxidized")
minetest.register_alias("vlf_copper:waxed_block_oxidized_cut","vlf_copper:waxed_block_oxidized_cut")
minetest.register_alias("vlf_stairs:stair_waxed_copper_oxidized_cut","vlf_stairs:stair_waxed_copper_oxidized_cut")
minetest.register_alias("vlf_stairs:stair_waxed_copper_oxidized_cut_inner","vlf_stairs:stair_waxed_copper_oxidized_cut_inner")
minetest.register_alias("vlf_stairs:stair_waxed_copper_oxidized_cut_outer","vlf_stairs:stair_waxed_copper_oxidized_cut_outer")
minetest.register_alias("vlf_stairs:slab_waxed_copper_oxidized_cut","vlf_stairs:slab_waxed_copper_oxidized_cut")
minetest.register_alias("vlf_stairs:slab_waxed_copper_oxidized_cut_top","vlf_stairs:slab_waxed_copper_oxidized_cut_top")
minetest.register_alias("vlf_stairs:slab_waxed_copper_oxidized_cut_double","vlf_stairs:slab_waxed_copper_oxidized_cut_double")
