import os
import nbtlib  # Ensure you have nbtlib installed

def extract_block_names_from_nbt(nbt_file_path):
    # Placeholder function for extracting block names from an NBT file
    # Replace this with your actual logic for extracting block names
    block_names = []
    try:
        nbt_data = nbtlib.load(nbt_file_path)
        # Adjust this according to your NBT file's structure
        if 'Blocks' in nbt_data:
            for entry in nbt_data['Blocks']:
                if 'Name' in entry:
                    block_name = entry['Name']
                    block_names.append(block_name)
    except Exception as e:
        print(f"Error reading {nbt_file_path}: {e}")
    return block_names

def write_blocknames_file(directory):
    block_names = set()
    
    # Walk through the directory and its subdirectories
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.nbt'):
                nbt_file_path = os.path.join(root, file)
                block_names.update(extract_block_names_from_nbt(nbt_file_path))
    
    # Define the output file path
    output_file = os.path.join(directory, 'blocknames.txt')
    
    # Write the block names to the output file
    with open(output_file, 'w') as file:
        for block_name in sorted(block_names):
            file.write(block_name + '\n')
    
    print(f"Block names have been written to {output_file}")

# Example usage
# Example usage
directory_path = '/home/joshua/snap/minetest/current/games/voxelforge/mods/CORE/vlf_data/data/voxelforge/structure'
write_blocknames_file(directory_path)
