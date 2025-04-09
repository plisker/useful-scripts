"""
This script downloads Slack emojis from the JSON response to Slack's emoji.list endpoint.

To generate the JSON, please see Slack's API documentation: https://api.slack.com/methods/emoji.list

This script ensures that aliases are properly resolved (by downloading them as new files) and does other reasonable
error checking
"""

import os
import json
import requests

# File path for the input JSON
json_file_path = "emoji_data.json"

# Folder to save the emoji images
output_folder = "emoji"

# Ensure the output folder exists
os.makedirs(output_folder, exist_ok=True)

def resolve_alias(name, emoji_map):
    """Resolve the final name for an alias."""
    seen = set()
    while name.startswith("alias:"):
        name = name.split("alias:")[1]
        if name in seen:  # Prevent infinite loops
            raise ValueError(f"Circular alias detected: {name}")
        seen.add(name)
    return name

def download_image(name, url, folder):
    """Download and save the image."""
    try:
        # Make the request
        response = requests.get(url, stream=True)
        response.raise_for_status()

        # Determine file extension and output path
        file_extension = os.path.splitext(url)[-1]
        file_path = os.path.join(folder, f"{name}{file_extension}")

        # Save the file
        with open(file_path, "wb") as img_file:
            for chunk in response.iter_content(chunk_size=8192):
                img_file.write(chunk)

        print(f"Downloaded: {name}")
    except Exception as e:
        print(f"Failed to download {name}: {e}")

# Read the JSON file
with open(json_file_path, "r") as file:
    data = json.load(file)

# Check if the JSON structure is valid
if "emoji" in data:
    emoji_data = data["emoji"]

    for name, value in emoji_data.items():
        try:
            # Resolve the final image name and URL
            if value.startswith("alias:"):
                resolved_name = resolve_alias(name, emoji_data)
                if resolved_name in emoji_data:
                    final_url = emoji_data[resolved_name]
                else:
                    raise ValueError(f"Alias points to non-existent emoji: {resolved_name}")
            else:
                resolved_name = name
                final_url = value

            # Download the image using the resolved URL but save with the original name
            if not final_url.startswith("alias:"):
                download_image(name, final_url, output_folder)

        except Exception as e:
            print(f"Error processing {name}: {e}")
else:
    print("The JSON file does not contain an 'emoji' field.")
