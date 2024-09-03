"""
import os
import re

def extract_block_names_from_vlfschem(vlfschem_file_path):
    block_names = set()
    try:
        with open(vlfschem_file_path, 'r') as file:
            content = file.read()
            # Regular expression to find block names in the format name = "minecraft:block_name"
            matches = re.findall(r'name\s*=\s*"([^"]+)"', content)
            block_names.update(matches)
    except Exception as e:
        print(f"Error reading {vlfschem_file_path}: {e}")
    return block_names

def write_blocknames_file(directory):
    block_names = set()
    
    # Walk through the directory and its subdirectories
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.lua'):
                vlfschem_file_path = os.path.join(root, file)
                block_names.update(extract_block_names_from_vlfschem(vlfschem_file_path))
    
    # Define the output file path
    output_file = os.path.join(directory,'blocknames.txt')
    
    # Write the block names to the output file
    with open(output_file, 'w') as file:
        for block_name in sorted(block_names):
            file.write(block_name + '\n')
    
    print(f"Block names have been written to {output_file}")
"""

"""
import os
import re

def extract_block_names_from_vlfschem(vlfschem_file_path):
    block_names = set()
    try:
        with open(vlfschem_file_path, 'r') as file:
            content = file.read()
            # Regular expression to find block names in the format name = "minecraft:block_name"
            matches = re.findall(r'name\s*=\s*"\s*(minecraft:[^"]+)\s*"', content)
            block_names.update(matches)
    except Exception as e:
        print(f"Error reading {vlfschem_file_path}: {e}")
    return block_names

def write_blocknames_file(directory):
    block_names = set()
    
    # Walk through the directory and its subdirectories
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.lua'):
                vlfschem_file_path = os.path.join(root, file)
                block_names.update(extract_block_names_from_vlfschem(vlfschem_file_path))
    
    # Define the output file path
    output_file = os.path.join(directory, 'blocknames.txt')
    
    # Write the block names to the output file
    with open(output_file, 'w') as file:
        for block_name in sorted(block_names):
            file.write(block_name + '\n')
    
    print(f"Block names have been written to {output_file}")
"""

import os
import re

def extract_block_names_from_vlfschem(vlfschem_file_path):
    block_names = set()
    try:
        with open(vlfschem_file_path, 'r') as file:
            content = file.read()
            # Regular expression to find block names in the format name = "minecraft:block_name"
            matches = re.findall(r'name\s*=\s*"\s*(minecraft:[^"]+)\s*"', content)
            block_names.update(matches)
    except Exception as e:
        print(f"Error reading {vlfschem_file_path}: {e}")
    return block_names

def write_blocknames_file(directory):
    block_names = set()
    
    # Walk through the directory and its subdirectories
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.lua'):
                vlfschem_file_path = os.path.join(root, file)
                block_names.update(extract_block_names_from_vlfschem(vlfschem_file_path))
    
    # Define the output file path
    output_file = os.path.join(directory, 'blocknames.txt')
    
    # Write the block names to the output file with the specified format
    with open(output_file, 'w') as file:
        for block_name in sorted(block_names):
            file.write(f'["{block_name}"] =\n')
    
    print(f"Block names have been written to {output_file}")

# Example usage
directory_path = '/home/joshua/snap/minetest/current/games/voxelforge/mods/CORE/vlf_data/data/voxelforge/structure/trial_chambers'
write_blocknames_file(directory_path)
