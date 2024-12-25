import os
import re

# Define your orientation to param2 conversion logic here
orientation_to_param2 = {
    "up_north": 6,
    "south_up": 2,
    "west_up": 3,
    "up_south": 8,
    "up_west": 17,
    "up_east": 15,
    "east_up": 1,
    "north_up": 0,
    "down_west": 19,
    "down_south": 10,
    "down_east": 13,
    "down_north": 4,
    # Add other orientations...
}

def process_txt_file(file_path):
    print(f"Processing .txt file: {file_path}")
    with open(file_path, 'r') as f:
        content = f.read()
    
    # Extract the orientation data from the .txt file
    match = re.search(r'\["orientation"\]="(.*?)"', content)
    if match:
        orientation = match.group(1)
        param2 = orientation_to_param2.get(orientation)
        print(f"Extracted orientation: {orientation}, corresponding param2: {param2}")
        return param2
    print("No orientation found in .txt file.")
    return None

def update_vlfschem_file(vlfschem_file_path, param2):
    try:
        # Read the content of the .vlfschem file
        with open(vlfschem_file_path, 'r', encoding='utf-8') as file:
            content = file.read()

        # Log the original content
        print(f"Original content:\n{content}")

        # Define the pattern to match the node with the name and param2
        pattern = re.compile(r'\{name="minecraft:air",param2=(\d+)\}')

        # Define the replacement string
        def replace_match(match):
            y, x, z, old_param2 = match.groups()
            # Reverse the z value
            z_reversed = str(-int(z))
            if f'{x},{y},{z_reversed}' in positions:
                replacement = f'{{name="minecraft:air",param2={param2}}}'
                print(f"Replacing with: {replacement}")  # Debug print
                return replacement
            return match.group(0)

        # Apply the replacement
        updated_content = pattern.sub(replace_match, content)

        # Log the updated content
        print(f"Updated content:\n{updated_content}")

        # Write the updated content back to the file
        with open(vlfschem_file_path, 'w', encoding='utf-8') as file:
            file.write(updated_content)
        
        print(f"Successfully updated {vlfschem_file_path} with param2: {param2}")

    except Exception as e:
        print(f"Error updating {vlfschem_file_path}: {e}")

def main(txt_directory, vlfschem_directory):
    print(f"Starting processing in directories: {txt_directory} (txt) and {vlfschem_directory} (vlfschem)")
    for txt_file in os.listdir(txt_directory):
        if txt_file.endswith('.txt'):
            txt_file_path = os.path.join(txt_directory, txt_file)
            param2 = process_txt_file(txt_file_path)
            
            if param2 is not None:
                # Assuming the .vlfschem file has the same name as the .txt file but with .vlfschem extension
                vlfschem_file = txt_file.replace('.txt', '.vlfschem')
                vlfschem_file_path = os.path.join(vlfschem_directory, vlfschem_file)
                
                if os.path.exists(vlfschem_file_path):
                    print(f"Found matching .vlfschem file: {vlfschem_file_path}")
                    update_vlfschem_file(vlfschem_file_path, param2)
                else:
                    print(f"Warning: .vlfschem file not found for {txt_file}")

# Example usage
test = "/home/joshua/snap/minetest/current/games/voxelforge/mods/CORE/vlf_data/data/voxelforge/structure/trial_chambers/convert"
txt_directory = test
vlfschem_directory = test
main(txt_directory, vlfschem_directory)
