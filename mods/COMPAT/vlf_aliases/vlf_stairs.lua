-- Aliases for backwards-compability with 0.21.0

local materials = {
	"wood", "junglewood", "sprucewood", "acaciawood", "birchwood", "darkwood",
	"cobble", "brick_block", "sandstone", "redsandstone", "stonebrick",
	"quartzblock", "purpur_block", "nether_brick"
}

for m=1, #materials do
	local mat = materials[m]
	minetest.register_alias("stairs:slab_"..mat, "vlf_stairs:slab_"..mat)
	minetest.register_alias("stairs:stair_"..mat, "vlf_stairs:stair_"..mat)

	-- corner stairs
	minetest.register_alias("stairs:stair_"..mat.."_inner", "vlf_stairs:stair_"..mat.."_inner")
	minetest.register_alias("stairs:stair_"..mat.."_outer", "vlf_stairs:stair_"..mat.."_outer")
end

minetest.register_alias("stairs:slab_stone", "vlf_stairs:slab_stone")
minetest.register_alias("stairs:slab_stone_double", "vlf_stairs:slab_stone_double")
