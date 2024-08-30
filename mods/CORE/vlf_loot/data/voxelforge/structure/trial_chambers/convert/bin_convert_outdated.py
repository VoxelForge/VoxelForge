import struct

def parse_lua_file(lua_file):
    """Parse Lua file and extract key-value pairs."""
    data = {}
    with open(lua_file, 'r') as file:
        lines = file.readlines()
        for line in lines:
            if '=' in line:
                key, value = line.strip().split('=', 1)
                key = key.strip().strip('"').strip("'")
                value = value.strip().strip('"').strip("'")
                data[key] = value
    return data

def write_binary_file(binary_file, data):
    """Write key-value pairs to a binary file."""
    with open(binary_file, 'wb') as file:
        for key, value in data.items():
            key_len = len(key)
            value_len = len(value)
            # Write key length, key, value length, and value
            file.write(struct.pack('I', key_len))
            file.write(key.encode('utf-8'))
            file.write(struct.pack('I', value_len))
            file.write(value.encode('utf-8'))

def convert_lua_to_binary(lua_file, binary_file):
    """Convert Lua file to binary file."""
    data = parse_lua_file(lua_file)
    write_binary_file(binary_file, data)

# Example usage
lua_file = 'end_1.vlfschem'
binary_file = 'end_1.vlfschem.bin'
convert_lua_to_binary(lua_file, binary_file)
