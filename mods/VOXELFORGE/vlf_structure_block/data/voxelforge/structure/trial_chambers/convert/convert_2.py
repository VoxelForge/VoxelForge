import nbtlib
import struct

def convert_nbt_to_vlfschem(nbt_file_path, output_file_path):
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
    
    # Prepare the data for the vlfschem format
    vlfschem_data = {
        'size': size,
        'nodes': [],
        'metadata': [],
        'entities': []
    }
    
    # Create a palette mapping
    palette_mapping = {}
    for index, block in enumerate(palette):
        if 'Properties' in block:
            block_name = f"{block['Name']}[{','.join(f'{k}={v}' for k, v in block['Properties'].items())}]"
        else:
            block_name = block['Name']
        palette_mapping[index] = block_name
    
    # Process blocks to create the nodes list
    for block in blocks:
        pos = tuple(block['pos'])
        state = block['state']
        node = {
            'name': palette_mapping[state],
            'pos': pos,
            'param2': 0  # Assuming param2 is not used here
        }
        vlfschem_data['nodes'].append(node)
    
    # Add entities data
    for entity in entities:
        entity_data = {
            'id': entity['nbt']['id'],
            'pos': tuple(entity['pos']),
            'data': entity
        }
        vlfschem_data['entities'].append(entity_data)

    # Serialize the data to the binary vlfschem format
    with open(output_file_path, 'wb') as f:
        # Write size
        f.write(struct.pack('3i', *vlfschem_data['size']))
        
        # Write nodes
        for node in vlfschem_data['nodes']:
            f.write(struct.pack('3i', *node['pos']))
            f.write(struct.pack('i', node['param2']))
            f.write(node['name'].encode('utf-8') + b'\x00')
        
        # Write entities
        for entity in vlfschem_data['entities']:
            f.write(entity['id'].encode('utf-8') + b'\x00')
            f.write(struct.pack('3f', *entity['pos']))
            # Serializing the entire entity data as binary might be complex,
            # so here we're just writing the position and ID for simplicity.

    print(f"Converted {nbt_file_path} to {output_file_path}")

# Example usage
convert_nbt_to_vlfschem('slime.nbt', 'example.vlfschem')
