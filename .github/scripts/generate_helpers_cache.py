import requests, json

# GitHub API endpoint for JSON script definitions
API_URL = "https://api.github.com/repos/community-scripts/ProxmoxVE/contents/frontend/public/json"

# Base URL where .sh install scripts are hosted
SCRIPT_BASE = "https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/scripts"

# Output filename for the generated cache
OUTPUT_FILE = "helpers_cache.json"

# Fetch list of JSON files
res = requests.get(API_URL)
data = res.json()
cache = []

# Process each JSON file
for item in data:
    url = item.get("download_url")
    if not url or not url.endswith(".json"):
        continue
    try:
        raw = requests.get(url).json()
        if not isinstance(raw, dict):
            continue
    except:
        continue

    # Extract mandatory fields
    slug = raw.get("slug")
    script = raw.get("install_methods", [{}])[0].get("script", "")
    if not slug or not script:
        continue  # skip non-script or invalid entries

    # Extract optional fields
    desc = raw.get("description", "")
    categories = raw.get("categories", [])
    notes = [note.get("text", "") for note in raw.get("notes", []) if isinstance(note, dict)]

    # Construct full URL to the install script
    full_script_url = f"{SCRIPT_BASE}/{script}"

    # Append script info to cache list
    cache.append({
        "slug": slug,
        "desc": desc,
        "script": script,
        "script_url": full_script_url,
        "categories": categories,
        "notes": notes
    })

# Write the full cache to JSON file
with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
    json.dump(cache, f, indent=2)

print(f"✅ helpers_cache.json created with {len(cache)} valid scripts.")