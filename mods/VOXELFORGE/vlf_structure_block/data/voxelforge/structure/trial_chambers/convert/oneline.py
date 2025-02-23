def lua_to_oneline_no_spaces(input_file, output_file):
    with open(input_file, 'r') as file:
        lua_code = file.read()

    # Remove all whitespace characters (spaces, tabs, newlines)
    single_line_code = ''.join(lua_code.split())

    with open(output_file, 'w') as file:
        file.write(single_line_code)

# Example usage
lua_to_oneline_no_spaces('end_1.vlfschem', 'end_1_1.vlfschem')
