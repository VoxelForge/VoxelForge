██████╗░ ██████╗░ ░█████╗░ ░█████╗░ ███████╗ ██████╗░ ██╗░░░██╗ ██████╗░ ░█████╗░ ██╗░░░░░
██╔══██╗ ██╔══██╗ ██╔══██╗ ██╔══██╗ ██╔════╗ ██╔══██╗ ██║░░░██║ ██╔══██╗ ██╔══██╗ ██║░░░░░
██████╔╝ ██████╔╝ ██║░░██║ ██║░░██║ ███████║ ██║░░██║ ██║░░░██║ ██████╔╝ ███████║ ██║░░░░░
██╔═══╝░ ██╔═██╗░ ██║░░██║ ██║░░░░░ ██╔════║ ██║░░██║ ██║░░░██║ ██╔═██╗░ ██╔══██║ ██║░░░░░
██║░░░░░ ██║░╚██╗ ██╔══██║ ██║░░██║ ███████║ ██║░░██║ ╚██████╔╝ ██║░╚██╗ ██║░░██║ ███████╗
╚═╝░░░░░ ╚═╝░░╚═╝ ╚█████╔╝ ░╚█████╝ ╚═════╝░ ██████╔╝ ░╚════╝░  ╚═╝░░╚═╝ ╚═╝░░╚═╝ ╚══════╝

░██████╗ ████████╗ ██████╗░ ██╗░░░██╗ ░█████╗░ ████████╗ ██╗░░░██╗ ██████╗░ ███████╗ ░██████╗
██╔════╝ ╚══██╔══╝ ██╔══██╗ ██║░░░██║ ██╔══██╗ ╚══██╔══╝ ██║░░░██║ ██╔══██╗ ██╔════╗ ██╔════╝
╚█████╗░ ░░░██║░░░ ██████╔╝ ██║░░░██║ ██║░░██║ ░░░██║░░░ ██║░░░██║ ██████╔╝ ███████║ ╚█████╗░
░╚═══██╗ ░░░██║░░░ ██╔═██╗░ ██║░░░██║ ██║░░░░░ ░░░██║░░░ ██║░░░██║ ██╔═██╗░ ██╔════║ ░╚═══██╗
██████╔╝ ░░░██║░░░ ██║░╚██╗ ╚██████╔╝ ██║░░██║ ░░░██║░░░ ╚██████╔╝ ██║░╚██╗ ███████║ ██████╔╝
╚═════╝░ ░░░╚═╝░░░ ╚═╝░░╚═╝ ░╚════╝░  ░╚█████╝ ░░░╚═╝░░░ ░╚════╝░  ╚═╝░░╚═╝ ╚═════╝░ ╚═════╝░
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------


#Overview

This is a procedural structure generation system inspired by Minecraft's jigsaw system.

 - Terms used.

Puzzle Piece: == Schematic template.
# How It Works.
## 1. Puzzle Pieces

 - Puzzle pieces are small schematics designed to be placed in the world and connect to each other to for a procedural building. Each piece has predefined attachment points (jigsaw blocks) for connecting to other pieces.

## 2. Jigsaw Blocks

 - Jigsaw Block define how pieces attach to each other. Each connector has:

 - A Target Pool: (e.g voxelforge:trial_chambers/spawner more on that later)

 - A name: (e.g voxelforge:spider_spawner)

 - A Target Name: (e.g voxelforge:empty)

 - Final State: (e.g air)

 - All of the above must be defined for a structure to be placed.

## 3. Puzzle Piece Connection.

 - For two pieces to connect You'll need the following.

 - 1: The connecting schematic must be from the origin schematic's "Target Pool" Usually a json file (more on that later)
 - 2: It's name must match the connecting node's Target name and vice versa.
 - 3: The bounding boxes must not overlap.

## 4. Placement Rules

 - Placement rules dictate how structures expand. Key rules include:

 - Min/Max Depth: Limits how many pieces can be recursively placed.

 - Bounding Box Check: Ensures pieces do not overlap.

 - Terrain Matching: Checks if the placement terrain is valid.

 - Rotation & Mirroring: Allows orientation adjustments.

 - Generation Process

   - Step 1: Starting Structure Placement

     - Luanti places a decoration at a selected pos which is based on noise and world seed. Along with the allowed biomes.

     - It places this structure at a specific coordinate.

   - Step 2: Jigsaw Expansion

     - The system scans for jigsaw connectors within the structure.

     - For each connector, a compatible piece is selected from the structure set.

     - The selected piece is rotated and aligned to fit the connector.

     - The new piece is placed, and its own jigsaw connectors are added to the queue.

   - Step 3: Recursive Expansion

     - The process repeats recursively until:

     - The max depth is reached.

     - No valid pieces can be placed.

     - The structure encounters an obstruction.

     - There are no more valid jigsaw connectors.

   - Step 4: Finalization

     - Blocks are loaded

##Template Pool Usage

The system uses JSON for defining structures. Example JSON configuration:

```{
  "elements": [
    {
      "element": {
        "element_type": "voxelforge:single_pool_element",
        "location": "voxelforge:trial_chambers/reward/vault",
        "processors": {
          "processors": []
        },
        "projection": "rigid"
      },
      "weight": 1
    }
  ],
  "fallback": "voxelforge:empty"
}
```

1. *elements*: Elements holds every element in that particular table. The code grabs that list. and puts it in a table.
2. *element*: element is each schematic. Required to find possible schematics.
3. *element_type*: element_type is unused at this time.
4. *location*: Leads to the schematic directory. Hardcoded to require *voxelforge:* in front
5. *processors*: table for all processors for that schematic.
7. *processors*: all processors for schematic in the processors table.
8. *projection*: Valid projections are *rigid*1 and *terrain_matching*2.

note 1. *rigid* means jigsaw blocks connect perfectly ignoring terrain.
note 2. *terrain_matching* means jigsaw blocks connect on the x and z, but Y has room to move and match the terrain.

9. *weight*: Code gets the total weight of the schematics them finds the most likely for that position.
10. *fallback*: Partially implemented, adds a fallback if no schematics work.

#Advanced Features

1. Heightmap Integration

Pieces check terrain height before placement to avoid floating or buried structures.

2. Custom Rulesets

Users can define rules for how structures generate based on environmental conditions.

3. Structure Puzzle Pieces

Predefined template structures can be used to quickly create settlements.

#World Generation

See API.md in vlf_structures


