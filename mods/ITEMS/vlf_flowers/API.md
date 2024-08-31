# API

Flower mod for MineClonia

# Functions

## vlf_flowers.register_simple_flower(name, desc, image, simple_selection_box)

Register a simple flower:

* name: legacity name eg: "my_super_flower"
* desc: description eg: "My Super Flower"
* image: texture
* simple_selection_box: nodebox of the flower

## vlf_flowers.on_bone_meal(itemstack, placer, pointed_thing, pos, n)

## vlf_flowers.on_bone_meal_simple(itemstack, placer, pointed_thing, pos, n)

## vlf_flowers.get_palette_color_from_pos(pos)

## vlf_flowers.on_place_flower(pos, node, itemstack)

## vlf_flowers.add_large_plant(name, large_plant_definition)

### Large plant definition
```lua
{
	bottom = {
		tiles = { "tile1.png" },
		-- optional: any node definition fields for the bottom node
	},
	top = {
		--optional: any node definition fields for the top node
		--some fields e.g. "drop" and related are copied from the bottom node if not specified explicitly
	},
	desc = "Short Description",
	longdesc = "Crazy Long description",
	inv_img = "image.png",           -- inventory and wield image
	tiles_top = { "tile1_top.png" }, -- this may be used as a shortcut for top = { tiles = { "tile1_top.png" }},
	tiles_bottom = { "tile1_bottom.png" }, -- this may be used as a shortcut for bottom = { tiles = { "tile1_bottom.png" }},
	selbox_radius = 5/16,            --radius of the selection box
	selbox_top_height = 5/16,        --height or the selection box of the top part
	grass_color = false,             -- if grasslike param2 coloring should be used for this plant
	is_flower = false,               -- if plant is considered a flower
}
```
