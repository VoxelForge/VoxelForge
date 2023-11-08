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
 * 'nametag'		contains the name which is shown above mob.
 * 'type'			holds the type of mob that inhabits your world e.g.
 * "animal"		usually docile and walking around.
 * "monster"		attacks player or npc on sight.
 * "npc"			walk around and will defend themselves if hit first.
 * 'hp_min'		the minimum health value the mob can spawn with.
 * 'hp_max'		the maximum health value the mob can spawn with.
 * 'breath_max'	The maximum breath value the mob can spawn with and can have. If -1 (default), mob does not take drowning damage.
 * 'breathes_in_water' If true, mob loses breath when not in water. Otherwise, mob loses breath when inside a node with `drowning` attribute set (default: false).
 * 'armor'			entity armor groups (see lua_api.txt). If table, a list of armor groups like for entities. If number, set value of 'fleshy' armor group only. Note: The 'immortal=1' armor group will automatically be added since this mod handles health and damage manually. Default: 100 (mob will take full dmg from 'fleshy' hits)
 * 'passive'		when false allows animals to defend themselves when hit, otherwise they amble onwards.
 * 'retaliates'	if true this mob will retaliate against attacks.
 * 'walk_velocity' is the speed that your mob can walk around.
 * 'run_velocity'is the speed your mob can run with, usually when attacking.
 * 'walk_chance'	has a 0-100 chance value your mob will walk from standing, set to 0 for jumping mobs only.
 * 'jump'		when true allows your mob to jump updwards.
 * 'jump_height'	holds the height your mob can jump, 0 to disable jumping.
 * 'stepheight'	height of a block that your mob can easily walk up onto, defaults to 0.6.
 * 'fly'			when true allows your mob to fly around instead of walking.
 * 'fly_in'		holds the node name or a table of node names in which the mob flies (or swims) around in. The special name '__airlike' stands for all nodes with 'walkable=false' that are not liquids
 * 'runaway'		if true causes animals to turn and run away when hit.
 * 'view_range'	how many nodes in distance the mob can see a player.
 * 'damage'		how many health points the mob does to a player or another mob when melee attacking.
 * 'knock_back'	when true has mobs falling backwards when hit, the greater the damage the more they move back.
 * 'fear_height'	is how high a cliff or edge has to be before the mob stops walking, 0 to turn off height fear.
 * 'fall_speed'	has the maximum speed the mob can fall at, default is -10.
 * 'fall_damage'	when true causes falling to inflict damage.
 * 'water_damage'holds the damage per second infliced to mobs when standing in water (default: 0).
 * 'lava_damage'	holds the damage per second inflicted to mobs when standing in lava (default: 8).
 * 'fire_damage'	holds the damage per second inflicted to mobs when standing in fire (default: 1).
 * 'light_damage'holds the damage per second inflicted to mobs when it's too bright (above 13 light).
 * 'suffocation'	when true causes mobs to suffocate inside solid blocks (2 damage per second).
 * 'floats'		when set to 1 mob will float in water, 0 has them sink.
 * 'follow'		mobs follow player when holding any of the items which appear on this table, the same items can be fed to a mob to tame or breed e.g. {"farming:wheat", "default:apple"}
 * 'reach'				is how far the mob can attack player when standing nearby, default is 3 nodes.
 * 'docile_by_day'		when true has mobs wandering around during daylight hours and only attacking player at night or when provoked.
 * 'attacks_monsters'	when true has npc's attacking monsters or not.
 * 'attack_animals'	when true will have monsters attacking animals.
 * 'owner_loyal'		 when true will have tamed mobs attack anything player punches when nearby.
 * 'group_attack'		when true has same mob type grouping together to attack offender. When a table, this is a list of mob types that will get alerted as well (besides same mob type)
 * 'attack_type'		 tells the api what a mob does when attacking the player or another mob:
 * 'dogfight'		 	is a melee attack when player is within mob reach.
 * 'shoot'				has mob shoot pre-defined arrows at player when inside view_range.
 * 'dogshoot'		 	has melee attack when inside reach and shoot attack when inside view_range.
 * 'explode'		causes mob to stop and explode when inside reach.
 * 'explosion_radius'			the radius of explosion node destruction, defaults to 1
 * 'explosion_damage_radius'	the radius of explosion entity & player damage,	defaults to explosion_radius * 2
 * 'explosion_timer'	 number of seconds before mob explodes while its target is still inside reach or explosion_damage_radius, defaults to 3.
 * 'explosiontimer_reset_radius'	The distance you must travel before the timer will be reset.
 * 'allow_fuse_reset'	Allow 'explode' attack_type to reset fuse and resume chasing if target leaves the blast radius or line of sight. Defaults to true.
 * 'stop_to_explode'	 When set to true (default), mob must stop and wait for explosion_timer in order to explode. If false, mob will continue chasing.
 * 'arrow'				holds the pre-defined arrow object to shoot when attacking.
 * 'dogshoot_switch'	 allows switching between attack types by using timers (1 for shoot, 2 for dogfight)
 * 'dogshoot_count_max'contains how many seconds before switching from dogfight to shoot.
 * 'dogshoot_count2_max' contains how many seconds before switching from shoot to dogfight.
 * 'shoot_interval'	has the number of seconds between shots.
 * 'shoot_offset'		holds the y position added as to where the arrow/fireball appears on mob.
 * 'specific_attack'	 has a table of entity names that mob can also attack e.g. {"player", "mobs_animal:chicken"}.
 * 'runaway_from'		contains a table with mob names to run away from, add "player" to list to runaway from player also.
 * 'pathfinding'		 set to 1 for mobs to use pathfinder feature to locate player, set to 2 so they can build/break also (only works with dogfight attack and when 'mobs_griefing' in minetest.conf is not false).
 * 'immune_to'			is a table that holds specific damage when being hit by certain items e.g. {"default:sword_wood",0} -- causes no damage, {"default:gold_lump", -10} -- heals by 10 health points, {"default:coal_block", 20} -- 20 damage when hit on head with coal blocks.
	'makes_footstep_sound' when true you can hear mobs walking.

 * 'sounds'			this is a table with sounds of the mob Note: For all sounds except fuse and explode, the pitch is slightly randomized from the base pitch. The pitch of children is 50% higher.
	{
	 * 'distance'			maximum distance sounds can be heard, default is 10.
	 * 'base_pitch'		base pitch to use adult mobs, default is 1.0
	 * 'random'			played randomly from time to time. also played for overfeeding animal.
	 * 'eat'				played when mob eats something
	 * 'war_cry'			what you hear when mob starts to attack player. (currently disabled)
	 * 'attack'			what you hear when being attacked.
	 * 'shoot_attack'		sound played when mob shoots.
	 * 'damage'			sound heard when mob is hurt.
	 * 'death'				played when mob is killed.
	 * 'jump'				played when mob jumps. There's a built-in cooloff timer to avoid sound spam
	 * 'flop'				played when mob flops (like a stranded fish)
	 * 'fuse'				sound played when mob explode timer starts.
	 * 'explode'			sound played when mob explodes.
	}
 * 'sounds_child' 		same as sounds, but for childs. If not defined, childs will use same sound as adults but with higher pitch

 * 'drops'	 table of items that are dropped when mob is killed, fields are:
 * 'name'	name of item to drop.
 * 'chance' chance of drop, 1 for always, 2 for 1-in-2 chance etc.
 * 'min'	minimum number of items dropped.
 * 'max'	maximum number of items dropped.

 * 'textures'			holds a table list of textures to be used for mob, or you could use multiple lists inside another table for random selection e.g. { {"texture1.png"}, {"texture2.png"} }

 * 'child_texture'	 	holds the texture table for when baby mobs are used.
 * 'gotten_texture'	holds the texture table for when self.gotten value istrue, used for milking cows or shearing sheep.
 * 'gotten_mesh"		holds the name of the external object used for when self.gotten is true for mobs.
 * 'rotate'			custom model rotation, 0 = front, 90 = side, 180 = back, 270 = other side.
 * 'double_melee_attack' when true has the api choose between 'punch' and 'punch2' animations.
 * 'pushable'	Allows players, & other mobs to push the mob.

 * 'animation'		holds a table containing animation names and settings for use with mesh models: Using '_loop = false' setting will stop any of the animations from looping. 'speed_normal' is used for animation speed for compatibility with some older mobs.
	{
	 * 'stand_start'start frame for when mob stands still.
	 * 'stand_end'	end frame of stand animation.
	 * 'stand_speed'speed of animation in frames per second.
	 * 'walk_start'	when mob is walking around.
	 * 'walk_end'
	 * 'walk_speed'
	 * 'run_start'	when a mob runs or attacks.
	 * 'run_end'
	 * 'run_speed'
	 * 'fly_start'	when a mob is flying.
	 * 'fly_end'
	 * 'fly_speed'
	 * 'punch_start'when a mob melee attacks.
	 * 'punch_end'
	 * 'punch_speed'
	 * 'punch2_start' alternative melee attack animation.
	 * 'punch2_end'
	 * 'punch2_speed'
	 * 'shoot_start'shooting animation.
	 * 'shoot_end'
	 * 'shoot_speed'
	 * 'die_start'	death animation
	 * 'die_end'
	 * 'die_speed'
	 * 'die_loop'	 when set to false stops the animation looping.
	}

 * 'spawn_class' 		Classification of mod for the spawning algorithm: "hostile", "passive", "ambient" or "water"
 * 'ignores_nametag' 	if true, mob cannot be named by nametag
 * 'rain_damage' 		damage per second if mob is standing in rain (default: 0)
 * 'sunlight_damage' 	holds the damage per second inflicted to mobs when they are in direct sunlight
 * 'spawn_small_alternative' name of a smaller mob to use as replacement if spawning fails due to space requirements
 * 'glow' 				same as in entity definition
 * 'child' 			if true, spawn mob as child
 * 'shoot_arrow(self, pos, dir)' function that is called when mob wants to shoot an arrow. You can spawn your own arrow here. pos is mob position, dir is mob's aiming direction

 * 'follow_velocity' 	The speed at which a mob moves toward the player when they're holding the appropriate follow item.
 * 'instant_death' 	If true, mob dies instantly (no death animation or delay) (default: false)
 * 'xp_min'			the minimum XP it drops on death (default: 0)
 * 'xp_max'			the maximum XP it drops on death (default: 0)
 * 'fire_resistant' 	If true, the mob can't burn
 * 'fire_damage_resistant' If true the mob will not take damage when burning
 * 'ignited_by_sunlight' If true the mod will burn at daytime. (Takes sunlight_damage per second)
 * 'nofollow'			Do not follow players when they wield the "follow" item. For mobs (like villagers) that are bred in a different way.
 * 'pick_up'			table of itemstrings the mob will pick up (e.g. for breeding)
 * 'on_pick_up'		function that will be called on item pickup - arguments are self and the itementity return a (modified) itemstack
 * 'custom_visual_size' will not reset visual_size from the base class on reload
 * 'noyaw'				If true this mob will not automatically change yaw
 * 'particlespawners'	Table of particlespawners attached to the mob. This is implemented in a coord safe manner i.e. spawners are only sent to players within the player_transfer_distance (and automatically removed). This enables infinitely lived particlespawners.
 * 'doll_size_override' visual_size override for use as a "doll" in mobspawners - used for visually large mobs
 * 'extra_hostile'		Attacks "everything that moves" (all mobs)
 * 'attack_exception'	For "extra_hostile": Function that takes the object as argument. If it returns true that object will not be attacked.
 * 'deal_damage'		function(self, damage, mcl_reason) - if present this gets called instead of the normal damage functions

#### Object Properties
	Object properties can be defined right in the definition table for compatibility reasons. Note that these will be rewritten to "initial_properties" in the final mob entity.

}

### Mobs API functions
Every luaentity registered by mcl_mobs.register_mob has mcl_mobs.mob_class set as a metatable which, besides default values for fields in the luaentity provides a number of functions. "mob" refers to the luaentity of the mob in the following list:

 * mob:safe_remove() - removes the mob in the on_step allowing other functions to still run. It also extinguishes the mob if it is burning as to not leave behind flame entities.
 * mob:set_nametag(new_name) - sets the nametag of the mob
 * mob:set_properties(property_table) - works in the same way as mob.object:set_properties() would except that it will not set fields that are already set to the given value, potentially saving network bandwidth.

#### Breeding
	mob_class:feed_tame(clicker, feed_count, breed, tame, notake)
	mob_class:toggle_sit(clicker,p)

#### Combat
 * mob_class:day_docile()
 * mob_class:do_attack(player)
 * mob_class:entity_physics(pos,radius)
 * mob_class:smart_mobs(s, p, dist, dtime)
 * mob_class:attack_players_and_npcs()
 * mob_class:attack_specific()
 * mob_class:attack_monsters()
 * mob_class:dogswitch(dtime)
 * mob_class:safe_boom(pos, strength, no_remove)
 * mob_class:boom(pos, strength, fire, no_remove)
 * mob_class:on_punch(hitter, tflp, tool_capabilities, dir)
 * mob_class:check_aggro(dtime)
 * mob_class:clear_aggro()
 * mob_class:do_states_attack (dtime)
#### Movement
 * mob_class:is_node_dangerous(nodename)
 * mob_class:is_node_waterhazard(nodename)
 * mob_class:target_visible(origin)
 * mob_class:line_of_sight(pos1, pos2, stepsize)
 * mob_class:can_jump_cliff()
 * mob_class:is_at_cliff_or_danger()
 * mob_class:is_at_water_danger()
 * mob_class:env_danger_movement_checks(dtime)
 * mob_class:do_jump()
 * mob_class:follow_holding(clicker)
 * mob_class:replace(pos)
 * mob_class:check_runaway_from()
 * mob_class:follow_flop()
 * mob_class:go_to_pos(b)
 * mob_class:check_herd(dtime)
 * mob_class:teleport(target)
 * mob_class:do_states_walk()
 * mob_class:do_states_stand()
 * mob_class:do_states_runaway()
 * mob_class:check_smooth_rotation(dtime)
#### Physics
 * mob_class:player_in_active_range()
 * mob_class:object_in_range(object)
 * mob_class:item_drop(cooked, looting_level)
 * mob_class:collision()
 * mob_class:slow_mob()
 * mob_class:set_velocity(v)
 * mob_class:get_velocity()
 * mob_class:update_roll()
 * mob_class:set_yaw(yaw, delay, dtime)
 * mob_class:flight_check()
 * mob_class:check_for_death(cause, cmi_cause)
 * mob_class:deal_light_damage(pos, damage)
 * mob_class:is_in_node(itemstring) --can be group:...
 * mob_class:do_env_damage()
 * mob_class:env_damage (dtime, pos)
 * mob_class:damage_mob(reason,damage)
 * mob_class:check_entity_cramming()
 * mob_class:falling(pos)
 * mob_class:check_water_flow()
 * mob_class:check_dying()
 * mob_class:check_suspend()
#### Effects
 * mob_class:mob_sound(soundname, is_opinion, fixed_pitch)
 * mob_class:add_texture_mod(mod)
 * mob_class:remove_texture_mod(mod)
 * mob_class:damage_effect(damage)
 * mob_class:remove_particlespawners(pn)
 * mob_class:add_particlespawners(pn)
 * mob_class:check_particlespawners(dtime)
 * mob_class:set_animation(anim, fixed_frame)
 * mob_class:who_are_you_looking_at()
 * mob_class:check_head_swivel(dtime)
 * mob_class:set_animation_speed()

#### Items
 * mob_class:set_armor_texture()
 * mob_class:check_item_pickup()
#### Mount
 * mob_class:on_detach_child(child)
#### Pathfinding
 * mob:gopath(target,callback_arrived)		pathfind a way to target and run callback on arrival

## Spawning mobs
Mobs can be added to the natural spawn cycle using

`mcl_mobs.spawn_setup(spawn_definition)`

### Spawn Definition table
{
 * name             = name,             --name of the mob to be spawned
 * dimension        = dimension,        --dimension this spawn rule applies to
 * type_of_spawning = type_of_spawning, -- "ground", "water" or "lava"
 * biomes           = biomes,           --table of biome names this rule applies to
 * biomes_except    = biomes_except,    --apply to all biomes of the dimension except the ones in this table (exclusive with biomes)
 * min_light        = min_light,        --minimum light value this rule applies to
 * max_light        = max_light,        --maximum light value ..
 * chance           = chance,           --chance the mob is spawned, higher values make spawning more likely
 * aoc              = aoc,              --"active object count", don't spawn mob if this amount of other mobs is already in the area
 * min_height       = min_height,       --minimum Y position this rule applies to
 * max_height       = max_height,       --maximum Y position this rule applies to
 * check_position   = function(pos),    --function to check the position the mob would spawn at, return false to deny spawning
 * on_spawn         = function(pos),    --function that will be run when the mob successfully spawned
}


## Commands
* /spawn_mob mob_name - spawns a mob at the player position
* /spawncheck mob_name runs through the natural spawn checks to verify if a mob can spawn at the players position (and if not gives a reason why spawning was denied)
* /mobstats - gives some statistics about the currently active mobs and spawn attempts on the whole server
* /clearmobs [<all> | <nametagged> | <tamed>] [<range>] - a safer alternative to /clearobjects that only applies to loaded mobs
## Mob Eggs
	mcl_mobs.register_egg(mob, desc, background_color, overlay_color, addegg, no_creative)

 * 'name'		this is the name of your new mob to spawn e.g. "mob:sheep"
 * 'description' the name of the new egg you are creating e.g. "Spawn Sheep"
 * 'background_color' and 'overlay_color' define the colors for the texture displayed for the egg in inventory
 * 'addegg'	would you like an egg image in front of your texture (1 = yes, 0 = no)
 * 'no_creative' when set to true this stops spawn egg appearing in creative mode for destructive mobs like Dungeon Masters.

## Mob projectiles
Custom projectiles for mobs can be registered using
 * mcl_mobs.register_arrow(name, arrow_def)
 * mcl_mobs.get_arrow_damage_func(damage, damage_type, shooter_object)
 * 	Returns a damage function to be used in arrow hit functions.

### Arrow definition
#### Object Properties
	Object properties can be defined right in the definition table for compatibility reasons. Note that these will be rewritten to "initial_properties" in the final mob entity.

	 * 'visual'		same is in minetest.register_entity()
	 * 'visual_size'same is in minetest.register_entity()
	 * 'textures'	 same is in minetest.register_entity()
	 * 'velocity'	 the velocity of the arrow
	 * 'drop'		 if set to true any arrows hitting a node will drop as item
	 * 'hit_player'	a function that is called when the arrow hits a player; this function should hurt the player, the parameters are (self, player)
	 * 'hit_mob'	a function that is called when the arrow hits a mob; this function should hurt the mob, the parameters are (self, mob)
	 * 'hit_object'	a function that is called when the arrow hits an object that is neither a player nor a mob. this function should hurt the object, the parameters are (self, object)
	 * 'hit_node'	 a function that is called when the arrow hits a node, the parameters are (self, pos, node)
	 * 'tail'		 when set to 1 adds a trail or tail to mob arrows
	 * 'tail_texture' texture string used for above effect
	 * 'tail_size'	has size for above texture (defaults to between 5 and 10)
	 * 'expire'		contains float value for how long tail appears for (defaults to 0.25)
	 * 'glow'		 has value for how brightly tail glows 1 to 10 (default is 0 for no glow)
	 * 'rotate'		integer value in degrees to rotate arrow
	 * 'on_step'	is a custom function when arrow is active, nil for default.

## External Settings for "minetest.conf"

 * 'enable_damage'			if true monsters will attack players (default is true)
 * 'only_peaceful_mobs'	if true only animals will spawn in game (default is false)
 * 'mobs_disable_blood'	if false, damage effects appear when mob is hit (default is false)
 * 'mobs_spawn_protected'	if set to false then mobs will not spawn in protected areas (default is true)
 * 'mob_difficulty'		sets difficulty level (health and hit damage multiplied by this number), defaults to 1.0.
 * 'mob_spawn_chance'		multiplies chance of all mobs spawning and can be set to 0.5 to have mobs spawn more or 2.0 to spawn less. e.g.1 in 7000 * 0.5 = 1 in 3500 so better odds of spawning.
 * 'mobs_spawn'			 if false then mobs no longer spawn without spawner or spawn egg.
 * 'mobs_drop_items'		when false mobs no longer drop items when they die.
 * 'mobs_griefing'			when false mobs cannot break blocks when using either pathfinding level 2, replace functions or mobs:boom
