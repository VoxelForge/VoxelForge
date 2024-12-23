import os
import re
from collections import defaultdict

def is_text_file(filepath):
    """
    Check if a file is a text file based on its extension.
    """
    blacklisted_extensions = ('.png', '.jpg', '.jpeg')
    return not filepath.lower().endswith(blacklisted_extensions)

def search_files(directory, include_term, exclude_terms):
    """
    Search for files containing the include_term but not any of the exclude_terms.
    
    Args:
        directory (str): The directory to search in.
        include_term (str): The word or phrase to search for.
        exclude_terms (list of str): List of words or phrases to exclude.
    
    Returns:
        dict: A dictionary of file paths and counts of include_term occurrences.
    """
    results = defaultdict(int)
    include_pattern = re.compile(re.escape(include_term), re.IGNORECASE)
    exclude_patterns = [re.compile(re.escape(term), re.IGNORECASE) for term in exclude_terms]
    
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
                    # Ignore files that cannot be read
                    continue
    return results

def main():
    """
    Main function to interact with the user and run the search.
    """
    directory = os.getcwd()
    include_term = input("Enter the word or phrase to search for: ").strip()
    exclude_terms = []

    exclude_term = input("Enter the word or phrase to exclude (or press Enter to skip): ").strip()
    if exclude_term:
        exclude_terms.append(exclude_term)
    
    add_more = input("Would you like to add more words or phrases to ignore? (yes/no): ").strip().lower()
    while add_more == 'yes':
        try:
            additional_term = input("Enter a word or phrase to exclude: ").strip()
            exclude_terms.append(additional_term)
            add_more = input("Would you like to add another word or phrase to ignore? (yes/no): ").strip().lower()
        except ValueError:
            print("Invalid input. Please try again.")

    # Perform the search
    results = search_files(directory, include_term, exclude_terms)
    
    # Print results
    if results:
        print("\nSearch Results:")
        for file, count in results.items():
            print(f"File: {file}")
            print(f"  '{include_term}' found {count} times")
    else:
        print("\nNo files found matching the criteria.")

if __name__ == "__main__":
    main()

