# Alias list
alias = {
    "minecraft:air": "air",
    "minecraft:birch_planks": "vlf_trees:wood_birch",
    "minecraft:carved_pumpkin": "vlf_farming:pumpkin_face",
    "minecraft:chest": "vlf_chests:chest_small",
    "minecraft:cobblestone": "vlf_core:cobble",
    "minecraft:cobblestone_slab": "vlf_stairs:slab_cobble",
    "minecraft:cobblestone_stairs": "vlf_stairs:stair_cobble",
    "minecraft:cobblestone_wall": "vlf_walls:cobble",
    "minecraft:crafting_table": "vlf_crafting_table:crafting_table",
    "minecraft:dark_oak_fence": "vlf_fences:dark_oak_fence",
    "minecraft:dark_oak_log": "vlf_trees:bark_dark_oak",
    "minecraft:dark_oak_planks": "vlf_trees:wood_dark_oak",
    "minecraft:dark_oak_slab": "vlf_stairs:slab_dark_oak",
    "minecraft:dark_oak_stairs": "vlf_stairs:stair_dark_oak",
    "minecraft:hay_block": "vlf_farming:hay_block",
    "minecraft:jigsaw": "minecraft:jigsaw",
    "minecraft:mossy_cobblestone": "vlf_core:mossycobble",
    "minecraft:mossy_cobblestone_slab": "vlf_walls:mossycobble",
    "minecraft:mossy_cobblestone_stairs": "vlf_stairs:stair_mossycobble",
    "minecraft:mossy_cobblestone_wall": "vlf_stairs:slab_mossycobble",
    "minecraft:pumpkin": "vlf_farming:pumpkin",
    "minecraft:torch": "vlf_torches:torch",
    "minecraft:vine": "vlf_core:vine",
    "minecraft:white_wall_banner": "vlf_banners:hanging_banner",
    "minecraft:white_wool": "vlf_wool:white",
}


"""
import os
import re

def load_vlfschem(filepath):
    try:
        with open(filepath, 'r') as file:
            content = file.read()
            return content
    except Exception as e:
        print(f"Error loading .vlfschem file: {e}")
        return None

def replace_node_names_in_vlfschem(content, alias):
    def replace_match(match):
        node_name = match.group(1)
        return f'name = "{alias.get(node_name, node_name)}"'

    # Use regex to find all node names in the form of name = "minecraft:block_name"
    modified_content = re.sub(r'name\s*=\s*"([^"]+)"', replace_match, content)
    return modified_content

def save_vlfschem(filepath, content):
    try:
        with open(filepath, 'w') as file:
            file.write(content)
        print(f"Saved modified .vlfschem file: {filepath}")
    except Exception as e:
        print(f"Error saving .vlfschem file: {e}")

def process_directory(directory, alias):
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.lua'):  # Assuming .vlfschem files have a .lua extension
                filepath = os.path.join(root, file)
                print(f"Loading schematic from file: {filepath}")
                original_content = load_vlfschem(filepath)
                if original_content:
                    modified_content = replace_node_names_in_vlfschem(original_content, alias)
                    save_vlfschem(filepath, modified_content)
                else:
                    print(f"Skipping file due to load error: {filepath}")

def replace_node_names_in_vlfschem_files(directory, alias):
    process_directory(directory, alias)

# Example usage
modpath = "/home/joshua/snap/minetest/current/games/voxelforge/mods/CORE/vlf_data"
replace_node_names_in_vlfschem_files(
    os.path.join(modpath, "data", "voxelforge", "structure", "trial_chambers"),
    alias
)
"""

"""
import os
import re

def load_vlfschem(filepath):
    "Load a Lua file (.vlfschem) as a string"
    try:
        with open(filepath, 'r') as file:
            content = file.read()
            return content
    except Exception as e:
        print(f"Error loading .vlfschem file: {e}")
        return None

def replace_node_names_in_vlfschem(content, alias):
    "Replace node names in the .vlfschem content string using the alias dictionary"
    def replace_match(match):
        node_name = match.group(1)
        new_name = alias.get(node_name, node_name)
        print(f"Replacing {node_name} with {new_name}")
        return f'name = "{new_name}"'

    # Use regex to find all node names in the form of name = "minecraft:block_name"
    modified_content = re.sub(r'name\s*=\s*"([^"]+)"', replace_match, content)
    return modified_content

def save_vlfschem(filepath, content):
    "Save the modified Lua file back to disk"
    try:
        with open(filepath, 'w') as file:
            file.write(content)
        print(f"Saved modified .vlfschem file: {filepath}")
    except Exception as e:
        print(f"Error saving .vlfschem file: {e}")

def process_directory(directory, alias):
    "Process all .vlfschem files in a directory, replacing node names"
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.lua'):  # Assuming .vlfschem files have a .lua extension
                filepath = os.path.join(root, file)
                print(f"Loading schematic from file: {filepath}")
                original_content = load_vlfschem(filepath)
                if original_content:
                    modified_content = replace_node_names_in_vlfschem(original_content, alias)
                    if modified_content != original_content:
                        print(f"Changes detected in {filepath}, saving...")
                        save_vlfschem(filepath, modified_content)
                    else:
                        print(f"No changes made to {filepath}")
                else:
                    print(f"Skipping file due to load error: {filepath}")

def replace_node_names_in_vlfschem_files(directory, alias):
    "Main function to replace node names in all .vlfschem files in a directory"
    process_directory(directory, alias)

# Example usage
modpath = "/home/joshua/snap/minetest/current/games/voxelforge/mods/CORE/vlf_data"
replace_node_names_in_vlfschem_files(
    os.path.join(modpath, "data", "voxelforge", "structure", "trial_chambers"),
    alias
)
"""

import os
import re

def load_vlfschem(filepath):
    """Load a Lua file (.vlfschem) as a string"""
    try:
        with open(filepath, 'r') as file:
            content = file.read()
            return content
    except Exception as e:
        print(f"Error loading .vlfschem file: {e}")
        return None

def replace_node_names_in_vlfschem(content, alias):
    """Replace node names in the .vlfschem content string using the alias dictionary"""
    def replace_match(match):
        node_name = match.group(1)
        # Debugging to ensure correct replacements
        if node_name in alias:
            print(f"Replacing '{node_name}' with '{alias[node_name]}'")
        else:
            print(f"No alias for '{node_name}', keeping original")
        new_name = alias.get(node_name, node_name)
        return f'name = "{new_name}"'

    # Use regex to find all node names in the form of name = "minecraft:block_name"
    modified_content = re.sub(r'name\s*=\s*"([^"]+)"', replace_match, content)
    return modified_content

def save_vlfschem(filepath, content):
    """Save the modified Lua file back to disk"""
    try:
        with open(filepath, 'w') as file:
            file.write(content)
        print(f"Saved modified .vlfschem file: {filepath}")
    except Exception as e:
        print(f"Error saving .vlfschem file: {e}")

def process_directory(directory, alias):
    """Process all .vlfschem files in a directory, replacing node names"""
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.lua'):  # Assuming .vlfschem files have a .lua extension
                filepath = os.path.join(root, file)
                print(f"\nProcessing file: {filepath}")
                original_content = load_vlfschem(filepath)
                
                if original_content:
                    # Debugging the original content
                    print("\nOriginal Content:")
                    print(original_content)

                    modified_content = replace_node_names_in_vlfschem(original_content, alias)

                    # Debugging the modified content
                    print("\nModified Content:")
                    print(modified_content)

                    if modified_content != original_content:
                        print(f"\nChanges detected in {filepath}, saving...")
                        save_vlfschem(filepath, modified_content)
                    else:
                        print(f"\nNo changes made to {filepath}")
                else:
                    print(f"\nSkipping file due to load error: {filepath}")

def replace_node_names_in_vlfschem_files(directory, alias):
    """Main function to replace node names in all .vlfschem files in a directory"""
    process_directory(directory, alias)

# Example usage
modpath = "/home/joshua/snap/minetest/current/games/voxelforge/mods/MAPGEN/vlf_data"
replace_node_names_in_vlfschem_files(
    os.path.join(modpath, "data", "voxelforge", "structure", "pillager_outpost"),
    alias
)
