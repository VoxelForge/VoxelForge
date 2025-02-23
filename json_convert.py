import json
import sys


def convert_loot_table(old_data):
    new_data = {
        "type": "chest",
        "functions": old_data.get("functions", []),
        "pools": []
    }

    for pool in old_data["pools"]:
        new_pool = {
            "rolls": {
                "min": int(pool["rolls"]["min"]),
                "max": int(pool["rolls"]["max"])
            } if isinstance(pool["rolls"], dict) else int(pool["rolls"]),
            "entries": []
        }

        for entry in pool["entries"]:
            new_entry = {
                "type": "item" if entry["type"] == "minecraft:item" else entry["type"],
                "name": entry["name"].replace("minecraft:", "mcl_"),
                "weight": entry.get("weight", 1),
            }

            # Convert functions
            if "functions" in entry:
                new_entry["functions"] = []
                for func in entry["functions"]:
                    if func["function"] == "minecraft:set_count":
                        count = func["count"]
                        if isinstance(count, dict) and count["type"] == "minecraft:uniform":
                            new_count = {"min": int(count["min"]), "max": int(count["max"])}
                        else:
                            new_count = int(count)
                        new_entry["functions"].append({
                            "function": "set_count",
                            "count": new_count
                        })

            new_pool["entries"].append(new_entry)

        new_data["pools"].append(new_pool)

    return new_data


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py <input_json_file>")
        sys.exit(1)

    input_filename = sys.argv[1]

    try:
        with open(input_filename, "r") as f:
            old_json = json.load(f)

        new_json = convert_loot_table(old_json)

        output_filename = "new_loot_table.json"
        with open(output_filename, "w") as f:
            json.dump(new_json, f, indent=4)

        print(f"Conversion complete! Saved as {output_filename}")
    except FileNotFoundError:
        print(f"Error: File '{input_filename}' not found.")
    except json.JSONDecodeError:
        print(f"Error: Failed to parse JSON from '{input_filename}'.")

