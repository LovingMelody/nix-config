#!/usr/bin/env bash
# Note: flake inputs should be run before running this
echo "Updating MC sources"
python3 ./modules/nixos/minecraft-server/generate-sources.py "$MC_VERSION" >./modules/nixos/minecraft-server/sources.json

echo "Updating npins"
npins update
echo "Formatting..."
nix fmt --accept-flake-config -L
