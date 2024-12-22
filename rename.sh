#!/bin/bash

# Rename folders
find . -depth -type d -name '*vlf*' | while read -r dir; do
    new_dir=$(echo "$dir" | sed 's/vlf/vlf/g')
    mv "$dir" "$new_dir"
done

# Rename files (including non-text files)
find . -depth -type f -name '*vlf*' | while read -r file; do
    new_file=$(echo "$file" | sed 's/vlf/vlf/g')
    mv "$file" "$new_file"
done

# Update file contents for text files only
find . -type f ! -exec file {} \; | grep -i text | cut -d: -f1 | while read -r file; do
    sed -i 's/vlf/vlf/g' "$file"
done

