"""
import nbtlib

def convert_nbt_to_lua(nbt_file_path, output_file_path):
    # Load the NBT file
    nbt_file = nbtlib.load(nbt_file_path)
    
    # Access the root tag directly
    root_tag = nbt_file
    
    # Extract size information from the NBT file
    size = root_tag['size']
    size_lua = {
        'y': int(size[1]),
        'x': int(size[0]),
        'z': int(size[2])
    }
    
    # Extract blocks
    blocks = root_tag['blocks']
    nodes = []
    
    for block in blocks:
        pos = block['pos']
        node = {
            'metadata': {},
            'pos': {
                'y': int(pos[1]),
                'x': int(pos[0]),
                'z': int(pos[2])
            },
            'name': root_tag['palette'][block['state']]['Name'],
            'param2': 0
        }

        # Check for "orientation" in the Properties and update param2 accordingly
        if 'Properties' in block and 'orientation' in block['Properties']:
            if block['Properties']['orientation'] == "up_north":
                node['param2'] = 6
                del block['Properties']['orientation']  # Remove the orientation key
            elif block['Properties']['orientation'] == "south_up":
                node['param2'] = 2
                del block['Properties']['orientation']
            elif block['Properties']['orientation'] == "west_up":
                node['param2'] = 3
                del block['Properties']['orientation']
            elif block['Properties']['orientation'] == "up_south":
                node['param2'] = 8
                del block['Properties']['orientation']
            elif block['Properties']['orientation'] == "up_west":
                node['param2'] = 17
                del block['Properties']['orientation']
            elif block['Properties']['orientation'] == "west_up":
                node['param2'] = 3
                del block['Properties']['orientation']
            elif block['Properties']['orientation'] == "up_east":
                node['param2'] = 15
                del block['Properties']['orientation']
            elif block['Properties']['orientation'] == "east_up":
                node['param2'] = 1
                del block['Properties']['orientation']
            elif block['Properties']['orientation'] == "north_up":
                node['param2'] = 0
                del block['Properties']['orientation']
            elif block['Properties']['orientation'] == "down_west":
                node['param2'] = 19
                del block['Properties']['orientation']
            elif block['Properties']['orientation'] == "down_south":
                node['param2'] = 10
                del block['Properties']['orientation']
            elif block['Properties']['orientation'] == "down_east":
                node['param2'] = 13
                del block['Properties']['orientation']
            elif block['Properties']['orientation'] == "down_north":
                node['param2'] = 4
                del block['Properties']['orientation']

        if 'nbt' in block:
            node['metadata'] = block['nbt']
        
        nodes.append(node)
    
    # Extract entities
    entities = root_tag['entities']
    
    # Helper function to convert a Python dictionary to a compact Lua table string
    def dict_to_lua_table(d):
        lua_str = "{"
        for key, value in d.items():
            if isinstance(value, dict):
                lua_str += f'{key}={dict_to_lua_table(value)},'
            elif isinstance(value, list):
                lua_str += f'{key}={list_to_lua_table(value)},'
            elif isinstance(value, str):
                lua_str += f'{key}="{value}",'
            elif isinstance(value, int) or isinstance(value, float):
                lua_str += f'{key}={value},'
        lua_str = lua_str.rstrip(',') + "}"
        return lua_str

    def list_to_lua_table(l):
        lua_str = "{"
        for item in l:
            if isinstance(item, dict):
                lua_str += f'{dict_to_lua_table(item)},'
            elif isinstance(item, list):
                lua_str += f'{list_to_lua_table(item)},'
            elif isinstance(item, str):
                lua_str += f'"{item}",'
            elif isinstance(item, int) or isinstance(item, float):
                lua_str += f'{item},'
        lua_str = lua_str.rstrip(',') + "}"
        return lua_str

    # Prepare the Lua table data
    lua_data = {
        'size': size_lua,
        'nodes': nodes,
        'probability': root_tag.get('probability', 1),
        'entities': entities
    }
    
    # Convert data to Lua table format
    lua_str = f"return {dict_to_lua_table(lua_data)}"

    # Write the Lua table to a file
    with open(output_file_path, 'w') as f:
        f.write(lua_str)
    
    print(f"Converted {nbt_file_path} to {output_file_path}")

# Example usage
convert_nbt_to_lua('atrium_1.nbt', 'atrium_1.lua')
"""

"""
import nbtlib

def convert_nbt_to_lua(nbt_file_path, output_file_path):
    try:
        # Load the NBT file
        nbt_file = nbtlib.load(nbt_file_path)
        
        # Access the root tag directly
        root_tag = nbt_file
        
        # Extract size information from the NBT file
        size = root_tag['size']
        size_lua = {
            'y': size[1],
            'x': size[0],
            'z': size[2]
        }
        
        # Extract blocks
        blocks = root_tag['blocks']
        nodes = []
        
        for block in blocks:
            pos = block['pos']
            node = {
                'metadata': {},
                'pos': {
                    'y': pos[1],
                    'x': pos[0],
                    'z': pos[2]
                },
                'name': root_tag['palette'][block['state']]['Name'],
                'param2': 0
            }
            if 'nbt' in block:
                node['metadata'] = block['nbt']
            nodes.append(node)
        
        # Extract entities
        entities = root_tag['entities']
        
        # Helper function to convert a Python dictionary to a compact Lua table string
        def dict_to_lua_table(d, indent_level=0):
            indent = '    ' * indent_level
            lua_str = "{"
            for key, value in d.items():
                key_str = f'"{key}"' if isinstance(key, str) else key
                if isinstance(value, dict):
                    lua_str += f'{indent}    {key_str} = {dict_to_lua_table(value, indent_level + 1)},\n'
                elif isinstance(value, list):
                    lua_str += f'{indent}    {key_str} = {list_to_lua_table(value, indent_level + 1)},\n'
                elif isinstance(value, str):
                    lua_str += f'{indent}    {key_str} = "{value}",\n'
                elif isinstance(value, (int, float)):
                    lua_str += f'{indent}    {key_str} = {value},\n'
            lua_str += f'{indent}}}'
            return lua_str

        def list_to_lua_table(l, indent_level=0):
            indent = '    ' * indent_level
            lua_str = "{"
            for item in l:
                if isinstance(item, dict):
                    lua_str += f'{indent}    {dict_to_lua_table(item, indent_level + 1)},\n'
                elif isinstance(item, list):
                    lua_str += f'{indent}    {list_to_lua_table(item, indent_level + 1)},\n'
                elif isinstance(item, str):
                    lua_str += f'{indent}    "{item}",\n'
                elif isinstance(item, (int, float)):
                    lua_str += f'{indent}    {item},\n'
            lua_str += f'{indent}}}'
            return lua_str

        # Prepare the Lua table data
        lua_data = {
            'size': size_lua,
            'nodes': nodes,
            'probability': root_tag.get('probability', 1),
            'entities': entities
        }
        
        # Convert data to Lua table format
        lua_str = f"return {"
        lua_str += f"    size = {dict_to_lua_table(lua_data['size'])},\n"
        lua_str += f"    nodes = {list_to_lua_table(lua_data['nodes'])},\n"
        lua_str += f"    probability = {lua_data['probability']},\n"
        lua_str += f"    entities = {list_to_lua_table(lua_data['entities'])}\n"
        lua_str += "}\n"

        # Write the Lua table to a file
        with open(output_file_path, 'w') as f:
            f.write(lua_str)
        
        print(f"Converted {nbt_file_path} to {output_file_path}")

    except Exception as e:
        print(f"An error occurred: {e}")

# Example usage
convert_nbt_to_lua('first_plate.nbt', 'first_plate.lua')
"""

"""
import nbtlib
import os

def convert_nbt_to_lua(nbt_file_path, output_file_path):
    # Load the NBT file
    nbt_file = nbtlib.load(nbt_file_path)
    
    # Access the root tag directly
    root_tag = nbt_file
    
    # Extract size information from the NBT file
    size = root_tag['size']
    size_lua = {
        'y': int(size[1]),
        'x': int(size[0]),
        'z': int(size[2])
    }
    
    # Extract blocks
    blocks = root_tag['blocks']
    nodes = []
    
    for block in blocks:
        pos = block['pos']
        node = {
            'metadata': {},
            'pos': {
                'y': int(pos[1]),
                'x': int(pos[0]),
                'z': int(pos[2])
            },
            'name': root_tag['palette'][block['state']]['Name'],
            'param2': 0
        }

        # Check for "orientation" in the Properties and update param2 accordingly
        if 'Properties' in block and 'orientation' in block['Properties']:
            orientation = block['Properties']['orientation']
            orientation_map = {
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
                "down_north": 4
            }
            node['param2'] = orientation_map.get(orientation, 0)
            del block['Properties']['orientation']  # Remove the orientation key

        if 'nbt' in block:
            node['metadata'] = block['nbt']
        
        nodes.append(node)
    
    # Extract entities
    entities = root_tag['entities']
    
    # Helper function to convert a Python dictionary to a compact Lua table string
    def dict_to_lua_table(d):
        lua_str = "{"
        for key, value in d.items():
            if isinstance(value, dict):
                lua_str += f'{key}={dict_to_lua_table(value)},'
            elif isinstance(value, list):
                lua_str += f'{key}={list_to_lua_table(value)},'
            elif isinstance(value, str):
                lua_str += f'{key}="{value}",'
            elif isinstance(value, int) or isinstance(value, float):
                lua_str += f'{key}={value},'
        lua_str = lua_str.rstrip(',') + "}"
        return lua_str

    def list_to_lua_table(l):
        lua_str = "{"
        for item in l:
            if isinstance(item, dict):
                lua_str += f'{dict_to_lua_table(item)},'
            elif isinstance(item, list):
                lua_str += f'{list_to_lua_table(item)},'
            elif isinstance(item, str):
                lua_str += f'"{item}",'
            elif isinstance(item, int) or isinstance(item, float):
                lua_str += f'{item},'
        lua_str = lua_str.rstrip(',') + "}"
        return lua_str

    # Prepare the Lua table data
    lua_data = {
        'size': size_lua,
        'nodes': nodes,
        'probability': root_tag.get('probability', 1),
        'entities': entities
    }
    
    # Convert data to Lua table format
    lua_str = f"return {dict_to_lua_table(lua_data)}"

    # Write the Lua table to a file
    with open(output_file_path, 'w') as f:
        f.write(lua_str)
    
    print(f"Converted {nbt_file_path} to {output_file_path}")

def convert_all_nbt_in_directory(root_dir):
    for subdir, _, files in os.walk(root_dir):
        for file in files:
            if file.endswith('.nbt'):
                nbt_file_path = os.path.join(subdir, file)
                output_file_path = os.path.splitext(nbt_file_path)[0] + '.lua'
                convert_nbt_to_lua(nbt_file_path, output_file_path)

# Example usage
convert_all_nbt_in_directory('.')
"""


"""
import nbtlib
import os

def convert_nbt_to_lua(nbt_file_path, output_file_path):
    # Load the NBT file
    nbt_file = nbtlib.load(nbt_file_path)
    
    # Access the root tag directly
    root_tag = nbt_file
    
    # Extract size information from the NBT file
    size = root_tag['size']
    size_lua = {
        'y': int(size[1]),
        'x': int(size[0]),
        'z': int(size[2])
    }
    
    # Extract blocks
    blocks = root_tag['blocks']
    nodes = []
    
    for block in blocks:
        pos = block['pos']
        node = {
            'metadata': {},
            'pos': {
                'y': int(pos[1]),
                'x': int(pos[0]),
                'z': -int(pos[2])  # Invert z-coordinate to switch North and South
            },
            'name': root_tag['palette'][block['state']]['Name'],
            'param2': 0
        }

        # Check for "orientation" in the Properties and update param2 accordingly
        if 'Properties' in block and 'orientation' in block['Properties']:
            orientation = block['Properties']['orientation']
            orientation_map = {
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
                "down_north": 4
            }
            node['param2'] = orientation_map.get(orientation, 0)
            del block['Properties']['orientation']  # Remove the orientation key

        if 'nbt' in block:
            node['metadata'] = block['nbt']
        
        nodes.append(node)
    
    # Extract entities
    entities = root_tag['entities']
    
    # Helper function to convert a Python dictionary to a compact Lua table string
    def dict_to_lua_table(d):
        lua_str = "{"
        for key, value in d.items():
            if isinstance(value, dict):
                lua_str += f'{key}={dict_to_lua_table(value)},'
            elif isinstance(value, list):
                lua_str += f'{key}={list_to_lua_table(value)},'
            elif isinstance(value, str):
                lua_str += f'{key}="{value}",'
            elif isinstance(value, int) or isinstance(value, float):
                lua_str += f'{key}={value},'
        lua_str = lua_str.rstrip(',') + "}"
        return lua_str

    def list_to_lua_table(l):
        lua_str = "{"
        for item in l:
            if isinstance(item, dict):
                lua_str += f'{dict_to_lua_table(item)},'
            elif isinstance(item, list):
                lua_str += f'{list_to_lua_table(item)},'
            elif isinstance(item, str):
                lua_str += f'"{item}",'
            elif isinstance(item, int) or isinstance(item, float):
                lua_str += f'{item},'
        lua_str = lua_str.rstrip(',') + "}"
        return lua_str

    # Prepare the Lua table data
    lua_data = {
        'size': size_lua,
        'nodes': nodes,
        'probability': root_tag.get('probability', 1),
        'entities': entities
    }
    
    # Convert data to Lua table format
    lua_str = f"return {dict_to_lua_table(lua_data)}"

    # Write the Lua table to a file
    with open(output_file_path, 'w') as f:
        f.write(lua_str)
    
    print(f"Converted {nbt_file_path} to {output_file_path}")

def convert_all_nbt_in_directory(root_dir):
    for subdir, _, files in os.walk(root_dir):
        for file in files:
            if file.endswith('.nbt'):
                nbt_file_path = os.path.join(subdir, file)
                output_file_path = os.path.splitext(nbt_file_path)[0] + '.lua'
                convert_nbt_to_lua(nbt_file_path, output_file_path)

# Example usage
convert_all_nbt_in_directory('.')
"""

"""
import nbtlib
import os

def convert_nbt_to_lua(nbt_file_path, output_file_path):
    # Load the NBT file
    nbt_file = nbtlib.load(nbt_file_path)
    
    # Access the root tag directly
    root_tag = nbt_file
    
    # Extract size information from the NBT file
    size = root_tag['size']
    size_lua = {
        'y': int(size[1]),
        'x': int(size[0]),
        'z': int(size[2])
    }
    
    # Extract blocks
    blocks = root_tag['blocks']
    nodes = []
    
    for block in blocks:
        pos = block['pos']
        node = {
            'metadata': {},
            'pos': {
                'y': int(pos[1]),
                'x': int(pos[0]),
                'z': -int(pos[2])  # Invert z-coordinate to switch North and South
            },
            'name': root_tag['palette'][block['state']]['Name'],
            'param2': 0
        }

        # Check for "orientation" in the Properties and update param2 accordingly
        if 'Properties' in block and 'orientation' in block['Properties']:
            orientation = block['Properties']['orientation']
            print(f"Processing block: {node['name']} with orientation: {orientation}")
            
            orientation_map = {
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
                "down_north": 4
            }
            node['param2'] = orientation_map.get(orientation, 0)
            print(f"Converted orientation '{orientation}' to param2 value: {node['param2']}")
            
            del block['Properties']['orientation']  # Remove the orientation key

        if 'nbt' in block:
            node['metadata'] = block['nbt']
        
        nodes.append(node)
    
    # Extract entities
    entities = root_tag['entities']
    
    # Helper function to convert a Python dictionary to a compact Lua table string
    def dict_to_lua_table(d):
        lua_str = "{"
        for key, value in d.items():
            if isinstance(value, dict):
                lua_str += f'{key}={dict_to_lua_table(value)},'
            elif isinstance(value, list):
                lua_str += f'{key}={list_to_lua_table(value)},'
            elif isinstance(value, str):
                lua_str += f'{key}="{value}",'
            elif isinstance(value, int) or isinstance(value, float):
                lua_str += f'{key}={value},'
        lua_str = lua_str.rstrip(',') + "}"
        return lua_str

    def list_to_lua_table(l):
        lua_str = "{"
        for item in l:
            if isinstance(item, dict):
                lua_str += f'{dict_to_lua_table(item)},'
            elif isinstance(item, list):
                lua_str += f'{list_to_lua_table(item)},'
            elif isinstance(item, str):
                lua_str += f'"{item}",'
            elif isinstance(item, int) or isinstance(item, float):
                lua_str += f'{item},'
        lua_str = lua_str.rstrip(',') + "}"
        return lua_str

    # Prepare the Lua table data
    lua_data = {
        'size': size_lua,
        'nodes': nodes,
        'probability': root_tag.get('probability', 1),
        'entities': entities
    }
    
    # Convert data to Lua table format
    lua_str = f"return {dict_to_lua_table(lua_data)}"

    # Write the Lua table to a file
    with open(output_file_path, 'w') as f:
        f.write(lua_str)
    
    print(f"Converted {nbt_file_path} to {output_file_path}")

def convert_all_nbt_in_directory(root_dir):
    for subdir, _, files in os.walk(root_dir):
        for file in files:
            if file.endswith('.nbt'):
                nbt_file_path = os.path.join(subdir, file)
                output_file_path = os.path.splitext(nbt_file_path)[0] + '.lua'
                convert_nbt_to_lua(nbt_file_path, output_file_path)

# Example usage
convert_all_nbt_in_directory('.')
"""

"""
import nbtlib
import os

def convert_nbt_to_lua(nbt_file_path, output_file_path):
    # Load the NBT file
    nbt_file = nbtlib.load(nbt_file_path)
    
    # Access the root tag directly
    root_tag = nbt_file
    
    # Extract size information from the NBT file
    size = root_tag['size']
    size_lua = {
        'y': int(size[1]),
        'x': int(size[0]),
        'z': int(size[2])
    }
    
    # Extract blocks
    blocks = root_tag['blocks']
    nodes = []
    
    # Step 1: Find the smallest and largest z-coordinates
    min_z = float('inf')
    max_z = float('-inf')
    for block in blocks:
        z = int(block['pos'][2])
        if z < min_z:
            min_z = z
        if z > max_z:
            max_z = z
    
    # Step 2: Create mappings for the blocks with smallest and largest z-coordinates
    swap_map = {}
    for block in blocks:
        z = int(block['pos'][2])
        if z == min_z:
            swap_map[tuple(block['pos'])] = (block['pos'][0], block['pos'][1], max_z)
        elif z == max_z:
            swap_map[tuple(block['pos'])] = (block['pos'][0], block['pos'][1], min_z)

    # Step 3: Process blocks and apply the swaps
    for block in blocks:
        pos = tuple(block['pos'])
        new_pos = swap_map.get(pos, pos)
        
        node = {
            'metadata': {},
            'pos': {
                'y': int(new_pos[1]),
                'x': int(new_pos[0]),
                'z': int(new_pos[2])  # Use the swapped z-coordinate
            },
            'name': root_tag['palette'][block['state']]['Name'],
            'param2': 0
        }

        # Check for "orientation" in the Properties and update param2 accordingly
        if 'Properties' in block and 'orientation' in block['Properties']:
            orientation = block['Properties']['orientation']
            print(f"Processing block: {node['name']} with orientation: {orientation}")
            
            orientation_map = {
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
                "down_north": 4
            }
            node['param2'] = orientation_map.get(orientation, 0)
            print(f"Converted orientation '{orientation}' to param2 value: {node['param2']}")
            
            del block['Properties']['orientation']  # Remove the orientation key

        if 'nbt' in block:
            node['metadata'] = block['nbt']
        
        nodes.append(node)
    
    # Extract entities
    entities = root_tag['entities']
    
    # Helper function to convert a Python dictionary to a compact Lua table string
    def dict_to_lua_table(d):
        lua_str = "{"
        for key, value in d.items():
            if isinstance(value, dict):
                lua_str += f'{key}={dict_to_lua_table(value)},'
            elif isinstance(value, list):
                lua_str += f'{key}={list_to_lua_table(value)},'
            elif isinstance(value, str):
                lua_str += f'{key}="{value}",'
            elif isinstance(value, int) or isinstance(value, float):
                lua_str += f'{key}={value},'
        lua_str = lua_str.rstrip(',') + "}"
        return lua_str

    def list_to_lua_table(l):
        lua_str = "{"
        for item in l:
            if isinstance(item, dict):
                lua_str += f'{dict_to_lua_table(item)},'
            elif isinstance(item, list):
                lua_str += f'{list_to_lua_table(item)},'
            elif isinstance(item, str):
                lua_str += f'"{item}",'
            elif isinstance(item, int) or isinstance(item, float):
                lua_str += f'{item},'
        lua_str = lua_str.rstrip(',') + "}"
        return lua_str

    # Prepare the Lua table data
    lua_data = {
        'size': size_lua,
        'nodes': nodes,
        'probability': root_tag.get('probability', 1),
        'entities': entities
    }
    
    # Convert data to Lua table format
    lua_str = f"return {dict_to_lua_table(lua_data)}"

    # Write the Lua table to a file
    with open(output_file_path, 'w') as f:
        f.write(lua_str)
    
    print(f"Converted {nbt_file_path} to {output_file_path}")

def convert_all_nbt_in_directory(root_dir):
    for subdir, _, files in os.walk(root_dir):
        for file in files:
            if file.endswith('.nbt'):
                nbt_file_path = os.path.join(subdir, file)
                output_file_path = os.path.splitext(nbt_file_path)[0] + '.lua'
                convert_nbt_to_lua(nbt_file_path, output_file_path)

# Example usage
convert_all_nbt_in_directory('.')
"""

"""
import nbtlib
import os

def convert_nbt_to_lua(nbt_file_path, output_file_path):
    # Load the NBT file
    nbt_file = nbtlib.load(nbt_file_path)
    
    # Access the root tag directly
    root_tag = nbt_file
    
    # Extract size information from the NBT file
    size = root_tag['size']
    size_lua = {
        'y': int(size[1]),
        'x': int(size[0]),
        'z': int(size[2])
    }
    
    # Extract blocks
    blocks = root_tag['blocks']
    nodes = []
    
    # Step 1: Find the smallest and largest z-coordinates
    min_z = float('inf')
    max_z = float('-inf')
    
    for block in blocks:
        z = int(block['pos'][2])
        if z < min_z:
            min_z = z
        if z > max_z:
            max_z = z

    # Step 2: Separate blocks into two groups based on min_z and max_z
    min_z_blocks = []
    max_z_blocks = []

    for block in blocks:
        z = int(block['pos'][2])
        if z == min_z:
            min_z_blocks.append(block)
        elif z == max_z:
            max_z_blocks.append(block)
        else:
            # Process blocks that aren't at min_z or max_z normally
            pos = block['pos']
            node = {
                'metadata': {},
                'pos': {
                    'y': int(pos[1]),
                    'x': int(pos[0]),
                    'z': int(pos[2])
                },
                'name': root_tag['palette'][block['state']]['Name'],
                'param2': 0
            }
            nodes.append(node)

    # Step 3: Swap positions of blocks with min_z and max_z
    for block in min_z_blocks:
        pos = block['pos']
        node = {
            'metadata': {},
            'pos': {
                'y': int(pos[1]),
                'x': int(pos[0]),
                'z': max_z  # Swap to max_z
            },
            'name': root_tag['palette'][block['state']]['Name'],
            'param2': 0
        }
        nodes.append(node)
    
    for block in max_z_blocks:
        pos = block['pos']
        node = {
            'metadata': {},
            'pos': {
                'y': int(pos[1]),
                'x': int(pos[0]),
                'z': min_z  # Swap to min_z
            },
            'name': root_tag['palette'][block['state']]['Name'],
            'param2': 0
        }
        nodes.append(node)

    # (Rest of the code remains the same)
    # Check for "orientation" in the Properties and update param2 accordingly
    for node in nodes:
        block = next((b for b in blocks if b['pos'] == [node['pos']['x'], node['pos']['y'], node['pos']['z']]), None)
        if block and 'Properties' in block and 'orientation' in block['Properties']:
            orientation = block['Properties']['orientation']
            print(f"Processing block: {node['name']} with orientation: {orientation}")
            
            orientation_map = {
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
                "down_north": 4
            }
            node['param2'] = orientation_map.get(orientation, 0)
            print(f"Converted orientation '{orientation}' to param2 value: {node['param2']}")
            
            del block['Properties']['orientation']  # Remove the orientation key

        if block and 'nbt' in block:
            node['metadata'] = block['nbt']
    
    # Extract entities
    entities = root_tag['entities']
    
    # Helper function to convert a Python dictionary to a compact Lua table string
    def dict_to_lua_table(d):
        lua_str = "{"
        for key, value in d.items():
            if isinstance(value, dict):
                lua_str += f'{key}={dict_to_lua_table(value)},'
            elif isinstance(value, list):
                lua_str += f'{key}={list_to_lua_table(value)},'
            elif isinstance(value, str):
                lua_str += f'{key}="{value}",'
            elif isinstance(value, int) or isinstance(value, float):
                lua_str += f'{key}={value},'
        lua_str = lua_str.rstrip(',') + "}"
        return lua_str

    def list_to_lua_table(l):
        lua_str = "{"
        for item in l:
            if isinstance(item, dict):
                lua_str += f'{dict_to_lua_table(item)},'
            elif isinstance(item, list):
                lua_str += f'{list_to_lua_table(item)},'
            elif isinstance(item, str):
                lua_str += f'"{item}",'
            elif isinstance(item, int) or isinstance(item, float):
                lua_str += f'{item},'
        lua_str = lua_str.rstrip(',') + "}"
        return lua_str

    # Prepare the Lua table data
    lua_data = {
        'size': size_lua,
        'nodes': nodes,
        'probability': root_tag.get('probability', 1),
        'entities': entities
    }
    
    # Convert data to Lua table format
    lua_str = f"return {dict_to_lua_table(lua_data)}"

    # Write the Lua table to a file
    with open(output_file_path, 'w') as f:
        f.write(lua_str)
    
    print(f"Converted {nbt_file_path} to {output_file_path}")

def convert_all_nbt_in_directory(root_dir):
    for subdir, _, files in os.walk(root_dir):
        for file in files:
            if file.endswith('.nbt'):
                nbt_file_path = os.path.join(subdir, file)
                output_file_path = os.path.splitext(nbt_file_path)[0] + '.lua'
                convert_nbt_to_lua(nbt_file_path, output_file_path)

# Example usage
convert_all_nbt_in_directory('.')
"""


import nbtlib
import os

def convert_nbt_to_lua(nbt_file_path, output_file_path):
    # Load the NBT file
    nbt_file = nbtlib.load(nbt_file_path)
    
    # Access the root tag directly
    root_tag = nbt_file
    
    # Extract size information from the NBT file
    size = root_tag['size']
    size_lua = {
        'y': int(size[1]),
        'x': int(size[0]),
        'z': int(size[2])
    }
    
    # Extract blocks
    blocks = root_tag['blocks']
    nodes = []

    # Step 1: Determine the min and max z-coordinates
    min_z = float('inf')
    max_z = float('-inf')
    
    for block in blocks:
        z = int(block['pos'][2])
        if z < min_z:
            min_z = z
        if z > max_z:
            max_z = z

    # Step 2: Calculate the midpoint for swapping
    midpoint_z = (min_z + max_z) / 2

    # Step 3: Process blocks and swap z-coordinates
    for block in blocks:
        pos = block['pos']
        z = int(pos[2])
        
        # Swap z-coordinate by reflecting it across the midpoint
        new_z = int(midpoint_z * 2 - z)

        node = {
            'metadata': {},
            'pos': {
                'y': int(pos[1]),
                'x': int(pos[0]),
                'z': new_z
            },
            'name': root_tag['palette'][block['state']]['Name'],
            'param2': 0
        }

        # Check for "orientation" in the Properties and update param2 accordingly
        if 'Properties' in block and 'orientation' in block['Properties']:
            orientation = block['Properties']['orientation']
            print(f"Processing block: {node['name']} with orientation: {orientation}")
            
            orientation_map = {
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
                "down_north": 4
            }
            node['param2'] = orientation_map.get(orientation, 0)
            print(f"Converted orientation '{orientation}' to param2 value: {node['param2']}")
            
            del block['Properties']['orientation']  # Remove the orientation key

        if 'nbt' in block:
            node['metadata'] = block['nbt']
        
        nodes.append(node)
    
    # Extract entities
    entities = root_tag['entities']
    
    # Helper function to convert a Python dictionary to a compact Lua table string
    def dict_to_lua_table(d):
        lua_str = "{"
        for key, value in d.items():
            if isinstance(value, dict):
                lua_str += f'{key}={dict_to_lua_table(value)},'
            elif isinstance(value, list):
                lua_str += f'{key}={list_to_lua_table(value)},'
            elif isinstance(value, str):
                lua_str += f'{key}="{value}",'
            elif isinstance(value, int) or isinstance(value, float):
                lua_str += f'{key}={value},'
        lua_str = lua_str.rstrip(',') + "}"
        return lua_str

    def list_to_lua_table(l):
        lua_str = "{"
        for item in l:
            if isinstance(item, dict):
                lua_str += f'{dict_to_lua_table(item)},'
            elif isinstance(item, list):
                lua_str += f'{list_to_lua_table(item)},'
            elif isinstance(item, str):
                lua_str += f'"{item}",'
            elif isinstance(item, int) or isinstance(item, float):
                lua_str += f'{item},'
        lua_str = lua_str.rstrip(',') + "}"
        return lua_str

    # Prepare the Lua table data
    lua_data = {
        'size': size_lua,
        'nodes': nodes,
        'probability': root_tag.get('probability', 1),
        'entities': entities
    }
    
    # Convert data to Lua table format
    lua_str = f"return {dict_to_lua_table(lua_data)}"

    # Write the Lua table to a file
    with open(output_file_path, 'w') as f:
        f.write(lua_str)
    
    print(f"Converted {nbt_file_path} to {output_file_path}")

def convert_all_nbt_in_directory(root_dir):
    for subdir, _, files in os.walk(root_dir):
        for file in files:
            if file.endswith('.nbt'):
                nbt_file_path = os.path.join(subdir, file)
                output_file_path = os.path.splitext(nbt_file_path)[0] + '.lua'
                convert_nbt_to_lua(nbt_file_path, output_file_path)

# Example usage
convert_all_nbt_in_directory('.')

