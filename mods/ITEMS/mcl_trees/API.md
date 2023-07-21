# API for `mcl_trees`

Register your own wood types. It will automatically register the associated nodes like stairs, fences etc.

## Quick start

Simple way of registering willow wood `willow`:
mcl_trees.register_wood("willow",wood_definition) -- see below for explanation of wood definition

```
mcl_trees.register_wood("willow")
```

For advanced usage you can override and/or turn on and off certain features for example:

mcl_trees.register_wood("willow",{
	sign_color = "#00FF00", --hex color for the sign
	sapling = {tiles = { "different_sapling_texture_file.png" } },
	boat = false, --no willow boat
})

valid fields are: sign_color, sign, leaves, sapling, tree, planks, bark, stripped, stripped_bark, fence, stairs, doors, trapdoors, boat, chest_boat

This expects the following textures unless that feature is disabled. "mcl_willow" being your modname.
The texture filenames can be overriden by setting the tiles/inventory_image/wield_image fields of the registration table.

mcl_willow_tree_willow.png
mcl_willow_tree_willow_top.png

mcl_willow_stripped_willow.png
mcl_willow_stripped_willow_top.png

mcl_willow_planks_willow.png

mcl_willow_leaves_willow.png
mcl_willow_sapling_willow.png

mcl_doors_trapdoor_willow.png
mcl_doors_trapdoor_willow_open.png
mcl_doors_door_willow.png
mcl_doors_door_willow_upper.png
mcl_doors_door_willow_lower.png

mcl_boats_willow_boat.png
mcl_boats_willow_chest_boat.png
mcl_boats_willow_boat_texture.png

### Wood Definition
All features can be disabled by setting them to false, nil will assume default values particularly for texture filenames.

{
	sign_color="#ECA870",                      --color of the sign
	tree_schems= {                             --a table with schematics for tree growth from sapling
		{ file="filename",width=7,height=11 },
	},
	tree = {},                                 -- overrides for the tree/log node definition
	leaves = {},                               -- overrides for the leaves node definition
	drop_apples = bool,                        -- wether digging leaves may drop apples
	sapling_chances = { 1, 2, 3, 4},           -- chances a sapling gets dropped for fortune levels 0-3 (default: {20, 16, 12, 10} )
	saplingdrop = "itemstring",                -- custom itemstring to drop instead of the API sapling
	planks = {},                               -- overrides for the planks node definition
	sapling = {},                              -- overrides for the sapling node definition
	potted_sapling = {},                       -- mcl_flowerpot definition or empty/nil for defaults
	fence = {},                                -- overrides for the fence node definition
	fence_gate = {},                           -- overrides for the fence gate node definition
	stair = {},                                -- overrides for the stairs node definitions
	slab = {},                                 -- overrides for the slab node definitions
	door = {
		inventory_image = "",                  -- Door inventory image
		tiles_bottom = {},                     -- Tiles for the lower part of the door
		tiles_top = {}                         -- Tiles for the upper part of the door
	},
	trapdoor = {
		tile_front = "",                       -- Tiles for the front part of the trapdoor
		tile_side = "",                        -- Tiles for the side part of the trapdoor
		wield_image = "",                      -- Wield image for the door
	},
	boat = {
		item = {},                             -- overrides for the boat item definition
		object = {},                           -- overrides for the boat item definition
		entity = {},                           -- overrides for the boat lua entity
	},
})
