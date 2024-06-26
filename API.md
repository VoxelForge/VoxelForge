# API
## Groups
VoxelForge makes very extensive use of groups. Making sure your items and
objects have the correct group memberships is very important. Groups are
explained in `GROUPS.md`.

## Mod naming convention
Mods mods in VoxelForge follow a simple naming convention: Mods with the prefix
“`vlc_`” are specific to VoxelForge, although they may be based on an existing
standalone. Mods which lack this prefix are *usually* verbatim copies of a
standalone mod. Some modifications may still have been applied, but the APIs are
held compatible.

## Adding items
### Special fields
Items can have these fields:

* `_vlc_generate_description(itemstack)`: Required for any items which
  manipulate their description in any way. This function takes an itemstack of
  its own type and must set the proper advanced description for this itemstack.
  If you don't do this, anvils will fail at properly restoring the description
  when their custom name gets cleared at an anvil. See `vlc_banners` for an
  example.

Tools can have these fields:

* `_vlc_diggroups`: Specifies the digging groups that a tool can dig and how
  efficiently. See `_vlc_autogroup` for more information.

All nodes can have these fields:

* `_vlc_hardness`: Hardness of the block, ranges from 0 to infinity (represented
  by -1). Determines digging times. Default: 0
* `_vlc_blast_resistance`: How well this block blocks and resists explosions.
  Default: 0
* `_vlc_falling_node_alternative`: If set to an itemstring, the node will turn
  into this node before it starts to fall.
* `_vlc_after_falling(pos)`: Called after a falling node finished falling and
  turned into a node.

### Tool Callbacks
Nodes can have "tool callbacks" modifying the on_place function of certain tools.
The first return value should be the itemstack and the second an option bool
i ndicatingif no wear should be added to the tool e.g. because the mod does it
itsself.

* _on_axe_place(itemstack,placer,pointed_thing)
* _on_shovel_place(itemstack,placer,pointed_thing)
* _on_sword_place(itemstack,placer,pointed_thing)
* _on_pickaxe_place(itemstack,placer,pointed_thing)
* _on_shears_place(itemstack,placer,pointed_thing)

Use the `vlc_sounds` mod for the sounds.

## APIs
A lot of things are possible by using one of the APIs in the mods. Note that not
all APIs are documented yet, but it is planned. The following APIs should be
more or less stable but keep in mind that VoxelForge is still unfinished. All
directory names are relative to `mods/`

### Items
* Doors: `ITEMS/vlc_doors`
* Fences and fence gates: `ITEMS/vlc_fences`
* Stairs and slabs: `ITEM/vlc_stairs`
* Walls: `ITEMS/vlc_walls`
* Beds: `ITEMS/vlc_beds`
* Buckets: `ITEMS/vlc_buckets`
* Dispenser support: `ITEMS/REDSTONE/vlc_dispensers`
* Campfires: `ITEMS/vlc_campfires`
* Trees and wood related nodes: `ITEMS/vlc_trees`

### Mobs
* Mobs: `ENTITIES/vlc_mobs`

VoxelForge uses its own mobs framework, called “vlc_mobs”.
This is a fork of [mobs redo](https://codeberg.org/tenplus1/mobs_redo) by TenPlus1.

You can add your own mobs, spawn eggs and spawning rules with this mod. API
documnetation is included in `ENTITIES/vlc_mobs/api.txt`.

This mod includes modificiations from the original Mobs Redo. Some items have
been removed or moved to other mods. The API is mostly identical, but a few
features have been added. Compability is not really a goal, but function and
attribute names of Mobs Redo 1.41 are kept. If you have code for a mod which
works fine under Mobs Redo, it should be easy to make it work in VoxelForge,
chances are good that it works out of the box.

### Help
* Item help texts: `HELP/doc/doc_items`
* Low-level help entry and category framework: `HELP/doc/doc`
* Support for lookup tool (required for all entities): `HELP/doc/doc_identifier`

### HUD
* Statbars: `HUD/hudbars`

### Utility APIs
* Change player physics: `PLAYER/playerphysics`
* Select random treasures: `CORE/vlc_loot`
* Get flowing direction of liquids: `CORE/flowlib`
* `on_walk_over` callback for nodes: `CORE/walkover`
* `_on_arrow_hit` callback when node is hit by an arrow: function(pos, arrow_luaentity)
* `_on_dye_place` callback when node is rickclicked with a dye: function(pos, color_name)
* `_on_hopper_in` callback when an item is about to be pushed to the node from a hopper: function(hopper_pos, node_pos)
* `_on_hopper_out` callback when an item is about to be sucked into a hopper under the node: function(node_pos, hopper_pos)
* `_on_lightning_strike` callback when a node is hit by lightning: function(node_pos, lightning_pos1, lightning_pos2)
* Get node names close to player (to reduce constant querying):
  `PLAYER/vlc_playerinfo`
* Colors and dyes API: `ITEMS/vlc_dyes`
* Explosion API
* Music discs API
* Flowers and flower pots
* Add job sites: `ENTITIES/mobs_mc`
* Add villager professions: `MAGPGEN/vlc_villages`
* `placement_prevented(table)` callback to see if a node will accept an attachment on the face being attached to. The table takes the following keys:

	```lua
	{
		itemstack = itemstack,
		placer = placer,
		pointed_thing = pointed_thing,
	}
	```

### Unstable APIs
The following APIs may be subject to change in future. You could already use
these APIs but there will probably be breaking changes in the future, or the API
is not as fleshed out as it should be. Use at your own risk!

* Panes (like glass panes and iron bars): `ITEMS/xpanes`
* `_on_ignite` callback: `ITEMS/vlc_fire`
* Farming: `ITEMS/vlc_farming`
* Anything related to redstone: Don't touch (yet)
* Any other mod not explicitly mentioned above

### Planned APIs
* Custom banner patterns
* Custom dimensions
* Custom portals
* Proper sky and weather APIs
# VLC
