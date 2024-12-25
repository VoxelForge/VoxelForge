import nbtlib  # This is an example, replace with your NBT library

def nbt_to_lua(nbt_data):
    def convert(data):
        if isinstance(data, dict):
            return '{' + ', '.join(f'["{k}"]={convert(v)}' for k, v in data.items()) + '}'
        elif isinstance(data, list):
            return '{' + ', '.join(convert(v) for v in data) + '}'
        elif isinstance(data, str):
            return f'"{data}"'
        elif isinstance(data, (int, float)):
            return str(data)
        elif data is None:
            return 'nil'
        else:
            raise TypeError(f'Unsupported data type: {type(data)}')

    return f'return {convert(nbt_data)}'

# Load the NBT file
nbt_file_path = 'atrium_1.nbt'
nbt_data = nbtlib.load(nbt_file_path)

# Convert NBT to Lua
lua_code = nbt_to_lua(nbt_data)

# Save Lua code to file
lua_file_path = 'atrium_1_old.lua'
with open(lua_file_path, 'w') as lua_file:
    lua_file.write(lua_code)

print(f'Converted {nbt_file_path} to {lua_file_path}')

