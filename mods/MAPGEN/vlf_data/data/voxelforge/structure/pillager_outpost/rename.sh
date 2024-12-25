#!/bin/bash

# Rename folders
#find . -depth -type d -name '*minecraft*' | while read -r dir; do
#    new_dir=$(echo "$dir" | sed 's/minecraft/voxelforge/g')
#    mv "$dir" "$new_dir"
#done

# Rename files (including non-text files)
#find . -depth -type f -name '*minecraft*' | while read -r file; do
#    new_file=$(echo "$file" | sed 's//vlf/g')
#    mv "$file" "$new_file"
#done

# Update file contents for text files only
find . -type f ! -exec file {} \; | grep -i text | cut -d: -f1 | while read -r file; do
    sed -i 's/minecraft:/voxelforge:/g' "$file"
done

