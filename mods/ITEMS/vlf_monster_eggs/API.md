# Monster egg registration
This mod registers "infested" variants of nodes.
When such nodes are dug or blasted, they spawn a silverfish.

## register_infested_block(nodename, description)
Registers an infested variant of node "nodename".

Most properties of the
original node are kept the same, but the description, the drops, the values
for hardness and blast_resistance and the callbacks on_dig_node and on_blast
are changed.
* nodename: a registered nodename
* description: a short description.

Example: when called with "mymod:mynode" as argument, an infested node is
registered with the name "vlf_monster_eggs:monster_egg_mynode".
