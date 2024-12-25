"""
import nbtlib

def convert_nbt_to_lua(nbt_file_path, output_file_path):
    # Load the NBT file
    nbt_file = nbtlib.load(nbt_file_path)
    
    # Access the root tag directly
    root_tag = nbt_file
    
    # Extract size information from the NBT file
    size = tuple(root_tag['size'])
    
    # Extract blocks and palette
    blocks = root_tag['blocks']
    palette = root_tag['palette']
    
    # Extract entities
    entities = root_tag['entities']
    
    # Prepare Lua table data
    lua_data = {
        'size': size,
        'blocks': blocks,
        'palette': palette,
        'entities': entities
    }
    
    # Helper function to convert a Python dictionary to a Lua table string
    def dict_to_lua_table(d):
        lua_str = "{\n"
        for key, value in d.items():
            if isinstance(value, dict):
                lua_str += f'  ["{key}"]={dict_to_lua_table(value)},\n'
            elif isinstance(value, list):
                lua_str += f'  ["{key}"]={list_to_lua_table(value)},\n'
            elif isinstance(value, str):
                lua_str += f'  ["{key}"]="{value}",\n'
            elif isinstance(value, tuple):
                lua_str += f'  ["{key}"]={tuple_to_lua_table(value)},\n'
            elif isinstance(value, int):
                lua_str += f'  ["{key}"]={value},\n'
            elif isinstance(value, float):
                lua_str += f'  ["{key}"]={value},\n'
        lua_str += "}\n"
        return lua_str

    def list_to_lua_table(l):
        lua_str = "{\n"
        for item in l:
            if isinstance(item, dict):
                lua_str += f'  {dict_to_lua_table(item)},\n'
            elif isinstance(item, list):
                lua_str += f'  {list_to_lua_table(item)},\n'
            elif isinstance(item, str):
                lua_str += f'  "{item}",\n'
            elif isinstance(item, tuple):
                lua_str += f'  {tuple_to_lua_table(item)},\n'
            elif isinstance(item, int):
                lua_str += f'  {item},\n'
            elif isinstance(item, float):
                lua_str += f'  {item},\n'
        lua_str += "}\n"
        return lua_str

    def tuple_to_lua_table(t):
        return f'{{{", ".join(map(str, t))}}}'

    # Convert data to Lua table format
    lua_str = f"return {dict_to_lua_table(lua_data)}"

    # Write the Lua table to a file
    with open(output_file_path, 'w') as f:
        f.write(lua_str)
    
    print(f"Converted {nbt_file_path} to {output_file_path}")

# Example usage
convert_nbt_to_lua('slime.nbt', 'slime.vlfschem')
"""

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
            'metadata': {},  # Assuming metadata is empty in this example
            'pos': {
                'y': pos[1],
                'x': pos[0],
                'z': pos[2]
            },
            'name': root_tag['palette'][block['state']],
            'param2': 0  # Default value for param2
        }
        if 'nbt' in block:
            node['metadata'] = block['nbt']
        nodes.append(node)
    
    # Extract entities
    entities = root_tag['entities']
    
    # Prepare Lua table data
    lua_data = {
        'size': size_lua,
        'nodes': nodes,
        'probability': root_tag.get('probability', 1),
        'entities': entities
    }
    
    # Helper function to convert a Python dictionary to a Lua table string
    def dict_to_lua_table(d):
        lua_str = "{\n"
        for key, value in d.items():
            if isinstance(value, dict):
                lua_str += f'    {key} = {dict_to_lua_table(value)},\n'
            elif isinstance(value, list):
                lua_str += f'    {key} = {list_to_lua_table(value)},\n'
            elif isinstance(value, str):
                lua_str += f'    {key} = "{value}",\n'
            elif isinstance(value, int):
                lua_str += f'    {key} = {value},\n'
            elif isinstance(value, float):
                lua_str += f'    {key} = {value},\n'
        lua_str += "}\n"
        return lua_str

    def list_to_lua_table(l):
        lua_str = "{\n"
        for item in l:
            if isinstance(item, dict):
                lua_str += f'    {dict_to_lua_table(item)},\n'
            elif isinstance(item, list):
                lua_str += f'    {list_to_lua_table(item)},\n'
            elif isinstance(item, str):
                lua_str += f'    "{item}",\n'
            elif isinstance(item, int):
                lua_str += f'    {item},\n'
            elif isinstance(item, float):
                lua_str += f'    {item},\n'
        lua_str += "}\n"
        return lua_str

    # Convert data to Lua table format
    lua_str = f"return {dict_to_lua_table(lua_data)}"

    # Write the Lua table to a file
    with open(output_file_path, 'w') as f:
        f.write(lua_str)
    
    print(f"Converted {nbt_file_path} to {output_file_path}")

# Example usage
convert_nbt_to_lua('slime.nbt', 'slime.lua')
"""

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
        'y': f'Int({size[1]})',
        'x': f'Int({size[0]})',
        'z': f'Int({size[2]})'
    }
    
    # Extract blocks
    blocks = root_tag['blocks']
    nodes = []
    
    for block in blocks:
        pos = block['pos']
        node = {
            'metadata': {},
            'pos': {
                'y': f'Int({pos[1]})',
                'x': f'Int({pos[0]})',
                'z': f'Int({pos[2]})'
            },
            'name': {'Name': root_tag['palette'][block['state']]},
            'param2': 0
        }
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
                lua_str += f'"{key}"="{value}",'
            elif isinstance(value, int):
                lua_str += f'{key}=Int({value}),'
            elif isinstance(value, float):
                lua_str += f'{key}=Float({value}),'
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
            elif isinstance(item, int):
                lua_str += f'Int({item}),'
            elif isinstance(item, float):
                lua_str += f'Float({item}),'
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
convert_nbt_to_lua('slime.nbt', 'slime.lua')
"""

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
            'name': {'Name': root_tag['palette'][block['state']]},
            'param2': 0
        }
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
                lua_str += f'"{key}"="{value}",'
            elif isinstance(value, int):
                lua_str += f'{key}={value},'
            elif isinstance(value, float):
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
            elif isinstance(item, int):
                lua_str += f'{item},'
            elif isinstance(item, float):
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
"""

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
            'name': {'Name': root_tag['palette'][block['state']]},
            'param2': 0
        }
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
                lua_str += f'"{key}"="{value}",'
            elif isinstance(value, int):
                lua_str += f'{key}={value},'
            elif isinstance(value, float):
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
            elif isinstance(item, int):
                lua_str += f'{item},'
            elif isinstance(item, float):
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
convert_nbt_to_lua('slime.nbt', 'slime.lua')
"""

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
            'name': {'Name': root_tag['palette'][block['state']]},
            'param2': 0
        }

        # Check for "orientation" in the Properties and update param2 accordingly
        if 'Properties' in block and 'orientation' in block['Properties']:
            if block['Properties']['orientation'] == "up_north":
                node['param2'] = 6
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
                lua_str += f'"{key}"="{value}",'
            elif isinstance(value, int):
                lua_str += f'{key}={value},'
            elif isinstance(value, float):
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
            elif isinstance(item, int):
                lua_str += f'{item},'
            elif isinstance(item, float):
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
convert_nbt_to_lua('slime.nbt', 'slime.lua')
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
convert_nbt_to_lua('end_1.nbt', 'end_1.lua')

