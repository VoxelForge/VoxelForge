"""
import os

# Get the current directory
current_directory = os.getcwd()

# List to hold the .lua files
lua_files = []

# Walk through the directory and subdirectories
for root, dirs, files in os.walk(current_directory):
    for file in files:
        if file.endswith(".lua"):
            # Add the file name with "" wrapper
            lua_files.append(f'"{file}"')

# Write the list of .lua files to a text file
with open("lua_files_list.txt", "w") as f:
    for lua_file in lua_files:
        f.write(lua_file + "\n")

print(f"Found {len(lua_files)} .lua files. List written to lua_files_list.txt.")
"""

import os

# Get the current directory
current_directory = os.getcwd()

# List to hold the .lua files
lua_files = []

# Walk through the directory and subdirectories
for root, dirs, files in os.walk(current_directory):
    for file in files:
        if file.endswith(".lua"):
            # Create the relative path for the .lua file
            relative_path = os.path.relpath(os.path.join(root, file), current_directory)
            lua_files.append(relative_path)

# Write the list of .lua files to a text file
with open("lua_files_list.txt", "w") as f:
    for lua_file in lua_files:
        f.write(f'"{lua_file}",\n')

print(f"Found {len(lua_files)} .lua files. List written to lua_files_list.txt.")


