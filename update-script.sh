#!/usr/bin/env bash
# Note: flake inputs should be run before running this
MC_VERSION=$(nix eval .\#packages.x86_64-linux.minecraftServers.fabric-1_21_2.version --raw)
echo "Updating MC sources for $MC_VERSION"
python3 ./modules/nixos/minecraft-server/generate-sources.py "$MC_VERSION" >./modules/nixos/minecraft-server/sources.json

echo "Updating npins"
npins update
echo "Formatting..."
nix fmt
