# mcl_mobs
## Registering mobs and mob definition

A new mob is registered using
`mcl_mobs.register_mob(name, mob_definition)`

This takes care of registering the mob entity using fields from the definition below.

Since commit PR#598 (mineclonia 0.90) these special rules apply to the fields used in the mob definition, before this no custom fields could be used in the mob definition!

All fields that correspond to a minetest object property e.g. collisionbox, will automatically be moved to the `initial_properties` sub-table to comply with minetest 5.8 deprecation.

Fields not mentioned in this document can also be added as custom fields for the luaentity.


### Mob definition table
{
tbc.
}


## Spawning mobs
Mobs can be added to the natural spawn cycle using

`mcl_mobs.spawn_setup(spawn_definition)`

### Spawn Definition table
{
	name             = name, --name of the mob to be spawned
	dimension        = dimension, --dimension this spawn rule applies to
	type_of_spawning = type_of_spawning, -- "ground", "water" or "lava"
	biomes           = biomes, --table of biome names this rule applies to
	biomes_except    = biomes_except, --apply to all biomes of the dimension except the ones in this table (exclusive with biomes)
	min_light        = min_light, --minimum light value this rule applies to
	max_light        = max_light, --maximum light value ..
	chance           = chance, --chance the mob is spawned, higher values make spawning more likely
	aoc              = aoc, --"active object count", don't spawn mob if this amount of other mobs is already in the area
	min_height       = min_height, --minimum Y position this rule applies to
	max_height       = max_height, --maximum Y position this rule applies to
	check_position   = function(pos), --function to check the position the mob would spawn at, return false to deny spawning
	on_spawn         = function(pos), --function that will be run when the mob successfully spawned
}


## Commands
* /spawn_mob mob_name - spawns a mob at the player position
* /spawncheck mob_name runs through the natural spawn checks to verify if a mob can spawn at the players position (and if not gives a reason why spawning was denied)
* /mobstats - gives some statistics about the currently active mobs and spawn attempts on the whole server
* /clearmobs [<all> | <nametagged> | <tamed>] [<range>] - a safer alternative to /clearobjects that only applies to loaded mobs

## Mobs API functions
Every luaentity registered by mcl_mobs.register_mob has mcl_mobs.mob_class set as a metatable which, besides default values for fields in the luaentity provides a number of functions. "mob" refers to the luaentity of the mob in the following list:

mob:safe_remove() - removes the mob in the on_step allowing other functions to still run. It also extinguishes the mob if it is burning as to not leave behind flame entities.
mob:set_nametag(new_name) - sets the nametag of the mob
mob:set_properties(property_table) - works in the same way as mob.object:set_properties() would except that it will not set fields that are already set to the given value, potentially saving network bandwidth.

## Mob projectiles
Custom projectiles for mobs can be registered using
`mcl_mobs.register_arrow(name, arrow_def)`
### Arrow definition
