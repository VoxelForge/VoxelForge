# Migrating from MineClone 2 to Mineclonia
This document describes things to be aware of when migrating worlds from
MineClone 2 to Mineclonia. Migrating from MineClone 2 to Mineclonia is fully
supported but not the other way around. If you want to try Mineclonia and have
the option of going back, then we recommend taking a backup of your world
first.

## Overworld depth increase
In Mineclonia 0.83.0 the overworld depth was increased from 64 to 128 nodes to
match Minecraft 1.18. Mineclonia will automatically update worlds from
MineClone 2 and older Mineclonia versions by replacing the bedrock layer and
void underneath with newly generated mapchunks. Note that this will trigger
regeneration of ores, caves, and structures up to y level -32, but that will
only replace ground content nodes and not affect player-made structures. It can
cause some oddities though, like duplicate end portals and other structures.

### MineClone 2 features not in Mineclonia
Mineclonia does not have the following items in MineClone 2:

- Hamburgers

Such items will become unknown items when a MineClone 2 world is migrated to
Mineclonia.
