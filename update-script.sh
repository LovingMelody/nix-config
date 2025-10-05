#!/usr/bin/env nix-shell
#! nix-shell -i bash
#! nix-shell -p bash nix-update npins
# Note: flake inputs should be run before running this
echo "Updating MC sources"
python3 ./modules/nixos/minecraft-server/generate-sources.py >./modules/nixos/minecraft-server/sources.json

echo "Updating npins"
npins update
echo "Formatting..."
nix fmt --accept-flake-config -L
