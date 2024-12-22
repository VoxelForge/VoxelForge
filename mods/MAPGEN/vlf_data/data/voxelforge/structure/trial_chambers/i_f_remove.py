"""
import os
import re

def remove_wrappers(content):
    # Remove Int() wrappers
    content = re.sub(r'Int\((.*?)\)', r'\1', content)
    # Remove Float() wrappers
    content = re.sub(r'Float\((.*?)\)', r'\1', content)
    return content

def process_file(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        content = file.read()
    
    modified_content = remove_wrappers(content)
    
    with open(file_path, 'w', encoding='utf-8') as file:
        file.write(modified_content)

def process_files_in_directory(directory, extension='.py'):
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith(extension):
                file_path = os.path.join(root, file)
                process_file(file_path)

# Example usage for a single file
file_path = 'atrium_1.lua'
process_file(file_path)

# Example usage for multiple files in a directory
directory = '/home/joshua/snap/minetest/current/games/voxelforge/mods/CORE/vlf_data/data/voxelforge/structure/trial_chambers/test'
process_files_in_directory(directory, extension='.lua')
"""

import os
import re

def remove_wrappers(content):
    # Remove Int() wrappers
    content = re.sub(r'Int\((.*?)\)', r'\1', content)
    # Remove Float() wrappers
    content = re.sub(r'Float\((.*?)\)', r'\1', content)
    # Remove Bye() wrappers
    content = re.sub(r'Byte\((.*?)\)', r'\1', content)
    return content

def process_file(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        content = file.read()
    
    modified_content = remove_wrappers(content)
    
    with open(file_path, 'w', encoding='utf-8') as file:
        file.write(modified_content)

def process_files_in_directory(directory, extension='.py'):
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith(extension):
                file_path = os.path.join(root, file)
                process_file(file_path)

# Get the directory where this Python file is located
main_directory = os.path.dirname(os.path.abspath(__file__))

# Process all .lua files in this directory and its subdirectories
process_files_in_directory(main_directory, extension='.lua')
