import json
import os
import sys
from urllib import request

SCRIPT_DIR = os.path.abspath(os.path.dirname(__file__))

# Game version should be passed to this script

with open(os.path.join(SCRIPT_DIR, "version"), mode="r") as f:
    GAME_VERSION = f.read().strip()

assert GAME_VERSION != ""

print(f"Fetching updates for {GAME_VERSION}", file=sys.stderr)
ENTRIES_TO_FIND = [
    {"name": "VanillaRefresh", "id": "gWO6Zqey", "loader": "fabric"},
    # World Generation
    {"name": "Terralith", "id": "8oi3bsk5", "loader": "fabric"},
    {"name": "Tectonic", "id": "lWDHr9jE", "loader": "fabric"},
    {"name": "Nullscape", "id": "LPjGiSO4", "loader": "fabric"},
    {"name": "Incendium", "id": "ZVzW5oNS", "loader": "fabric"},
    # Dependency for NetherPortalFix
    {"name": "Balm", "id": "MBAkmtvl", "loader": "fabric"},
    {"name": "NetherPortalFix", "id": "nPZr02ET", "loader": "fabric"},
    {"name": "ConcurrentChunkManagementEngine", "id": "VSNURh3q", "loader": "fabric"},
    {"name": "Krypton", "id": "fQEb0iXm", "loader": "fabric"},
    # Dependency for NetherPortalFix, Tectonic, Sit!, Balm
    {"name": "FabricAPI", "id": "P7dR8mSH", "loader": "fabric"},
    {"name": "ClothConfigAPI", "id": "9s6osm5g", "loader": "fabric"},
    {"name": "Sit!", "id": "EsYqsGV4", "loader": "fabric"},
    {"name": "Gyser", "id": "wKkoqHrH", "loader": "fabric"},
    {"name": "ServerCore", "id": "4WWQxlQP", "loader": "fabric"},
    {"name": "Lithium", "id": "gvQqBUqZ", "loader": "fabric"},
]


def get_item(entry):
    print(f"Fetching sources for {entry}", file=sys.stderr)
    with request.urlopen(
        f"https://api.modrinth.com/v2/project/{entry['id']}/version"
    ) as f:
        item = json.loads(f.read().decode("utf-8"))
    for v in item:
        if not any([version == GAME_VERSION for version in v["game_versions"]]):
            continue
        if not any([loader == entry["loader"] for loader in v["loaders"]]):
            continue
        file = v["files"][0]
        if file["hashes"]["sha512"] is None:
            continue
        if file["url"] is None:
            continue
        return {"sha512": file["hashes"]["sha512"], "url": file["url"]}


sources = {}
for entry in ENTRIES_TO_FIND:
    try:
        # Continue even if a source fails to be found
        # This will allow it to error in nix
        # Helps check if minecraft version updates
        source = get_item(entry)
        sources[entry["name"]] = source
    except IndexError:  # Only catch index errors
        print(f"Failed to get source for {entry['name']}", file=sys.stderr)

print(json.dumps(sources))
