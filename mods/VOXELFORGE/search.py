import os
import re
from collections import defaultdict

def is_text_file(filepath):
    blacklisted_extensions = ('.png', '.jpg', '.jpeg')
    if filepath.lower().endswith(blacklisted_extensions):
        return False
    return True

def search_files(directory, include_term, exclude_terms):
    results = defaultdict(int)
    include_pattern = re.compile(re.escape(include_term), re.IGNORECASE)
    exclude_patterns = [re.compile(re.escape(term), re.IGNORECASE) for term in exclude_terms]

    # Search files in the given directory
    for root, _, files in os.walk(directory):
        for file in files:
            file_path = os.path.join(root, file)
            if is_text_file(file_path):
                try:
                    with open(file_path, 'r', encoding='utf-8') as f:
                        text = f.read()
                        if include_pattern.search(text) and not any(pattern.search(text) for pattern in exclude_patterns):
                            results[file_path] = len(re.findall(include_pattern, text))
                except (UnicodeDecodeError, PermissionError):
                    pass

    # Print the search results
    if results:
        for file, count in results.items():
            print(f"\nFile: {file}")
            print(f"  '{include_term}' found {count} times")
    else:
        print(f"No results found for '{include_term}'.")

def get_search_terms():
    include_term = input("Enter the word or phrase to search for: ")
    exclude_terms = []
    add_more = 'yes'
    while add_more == 'yes':
        exclude_term = input("Enter a word or phrase to exclude: ")
        exclude_terms.append(exclude_term)
        add_more = input("Would you like to add more words or phrases to ignore? (yes/no): ").strip().lower()
    return include_term, exclude_terms

# Main execution
directory = os.getcwd()  # Get the current working directory
include_term, exclude_terms = get_search_terms()  # Get search and exclusion terms
search_files(directory, include_term, exclude_terms)  # Perform the search

