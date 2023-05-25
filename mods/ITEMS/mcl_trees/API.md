# API for `mcl_wood`

Register your own wood types. It will automatically register the associated nodes like stairs, fences etc.

## Quick start

Simple way of registering willow wood `willow`:

```
mcl_wood.register_wood("willow")
```

For advanced usage you can override and/or turn on and off certain features for example:

mcl_wood.register_wood("willow",{
	sign_color = "#00FF00", --hex color for the sign
	sapling = {tiles = { "different_sapling_texture_file.png" } },
	boat = false, --no willow boat
})

valid fields are: sign_color, sign, leaves, sapling, tree, planks, bark, stripped, stripped_bark, fence, stairs, doors, trapdoors

All except sign_color can be tables with overrides for the respective node definition. If they are nil
the standard variant is used, if they are anything else the feature is turned off.

this expects the following textures unless the feature is turned off:

mcl_wood_tree_willow.png
mcl_wood_tree_willow_top.png

mcl_wood_stripped_willow.png
mcl_wood_stripped_willow_top.png

mcl_wood_planks_willow.png

mcl_wood_leaves_willow.png
mcl_wood_sapling_willow.png

mcl_doors_trapdoor_willow.png
mcl_doors_trapdoor_willow_open.png
mcl_doors_door_willow.png
mcl_doors_door_willow_upper.png
mcl_doors_door_willow_lower.png

mcl_boats_willow_boat.png
mcl_boats_willow_chest_boat.png
