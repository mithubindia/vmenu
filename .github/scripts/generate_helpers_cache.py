import requests, json
from pathlib import Path

API_URL = "https://api.github.com/repos/community-scripts/ProxmoxVE/contents/frontend/public/json"
SCRIPT_BASE = "https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/scripts"
OUTPUT_FILE = Path("json/helpers_cache.json")
OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)

res = requests.get(API_URL)
data = res.json()
cache = []

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

    slug = raw.get("slug")
    script = raw.get("install_methods", [{}])[0].get("script", "")
    if not slug or not script:
        continue

    desc = raw.get("description", "")
    categories = raw.get("categories", [])
    notes = [note.get("text", "") for note in raw.get("notes", []) if isinstance(note, dict)]

    full_script_url = f"{SCRIPT_BASE}/{script}"

    cache.append({
        "name": name,
        "slug": slug,
        "desc": desc,
        "script": script,
        "script_url": full_script_url,
        "categories": categories,
        "notes": notes
    })

with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
    json.dump(cache, f, indent=2)

print(f"â helpers_cache.json created at {OUTPUT_FILE} with {len(cache)} valid scripts.")
