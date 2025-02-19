import re
import copy

def rotate_90(size, nodes):
    new_size = {
        'x': size['z'],
        'y': size['y'],
        'z': size['x'],
    }

    new_nodes = []
    for node in nodes:
        if 'pos' in node:
            new_pos = {
                'x': node['pos']['z'],
                'y': node['pos']['y'],
                'z': size['x'] - 1 - node['pos']['x'],
            }

            new_param2 = (node.get('param2', 0) + 1) % 4 if node.get('param2') in {0, 1, 2, 3} else node.get('param2')

            new_node = copy.deepcopy(node)
            new_node['pos'] = new_pos
            new_node['param2'] = new_param2

            # Ignore metadata during processing
            new_node['metadata'] = {}

            new_nodes.append(new_node)

    return new_size, new_nodes

def parse_lua_table(content):
    size_pattern = re.compile(r'size\s*=\s*{([^}]*)}', re.DOTALL)
    nodes_pattern = re.compile(r'nodes\s*=\s*{(.*)}\s*,', re.DOTALL)
    
    size_match = size_pattern.search(content)
    nodes_match = nodes_pattern.search(content)
    
    size = {}
    if size_match:
        for dim in ['x', 'y', 'z']:
            match = re.search(fr'{dim}\s*=\s*(-?\d+)', size_match.group(1))
            if match:
                size[dim] = int(match.group(1))
            else:
                raise ValueError(f"Could not find dimension '{dim}' in size block.")

    nodes = []
    if nodes_match:
        node_blocks = re.findall(r'{([^}]*)}', nodes_match.group(1))
        for block in node_blocks:
            pos = {}
            pos_match = re.search(r'pos\s*=\s*{([^}]*)}', block)
            if pos_match:
                for dim in ['x', 'y', 'z']:
                    match = re.search(fr'{dim}\s*=\s*(-?\d+)', pos_match.group(1))
                    if match:
                        pos[dim] = int(match.group(1))
                    else:
                        raise ValueError(f"Could not find position '{dim}' in node block: {block}")

                param2_match = re.search(r'param2\s*=\s*(\d+)', block)
                param2 = int(param2_match.group(1)) if param2_match else 0

                name_match = re.search(r'name\s*=\s*"(.*?)"', block)
                name = name_match.group(1) if name_match else "unknown"

                nodes.append({
                    'pos': pos,
                    'param2': param2,
                    'name': name,
                    'metadata': {},  # Ignore metadata
                })

    return size, nodes

def serialize_lua_table(size, nodes):
    size_str = f'size = {{\n    x = {size["x"]},\n    y = {size["y"]},\n    z = {size["z"]},\n}},\n'
    nodes_str = 'nodes = {\n'
    
    for node in nodes:
        pos = node['pos']
        nodes_str += f'    {{\n        pos = {{ x = {pos["x"]}, y = {pos["y"]}, z = {pos["z"]} }},\n'
        nodes_str += f'        name = "{node["name"]}",\n        param2 = {node["param2"]},\n'
        nodes_str += '        metadata = {},\n    },\n'  # Metadata is ignored

    nodes_str += '},\n'

    return f'return {{\n{size_str}{nodes_str}}}'

def read_vlfschem(filename):
    with open(filename, 'r') as f:
        content = f.read()
    return content

def write_vlfschem(filename, content):
    with open(filename, 'w') as f:
        f.write(content)

def rotate_vlfschem(filename):
    content = read_vlfschem(filename)
    size, nodes = parse_lua_table(content)

    new_size, new_nodes = rotate_90(size, nodes)

    new_content = serialize_lua_table(new_size, new_nodes)
    write_vlfschem(filename, new_content)
    print(f"Rotated {filename} by 90 degrees")

if __name__ == "__main__":
    vlfschem_file = "end_1.vlfschem"  # Replace with your file
    rotate_vlfschem(vlfschem_file)

