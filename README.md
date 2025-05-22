# Melody's NixOS Flake

<a href="https://nixos.wiki/wiki/Flakes" target="_blank">
	<img alt="Nix Flakes Ready" src="https://img.shields.io/static/v1?logo=nixos&logoColor=d8dee9&label=Nix%20Flakes&labelColor=5e81ac&message=Ready&color=d8dee9&style=for-the-badge">
</a>

This flake is meant to unify my system configs. Code isn't designed for re-use
but please feel free to make changes to enable this

## Profiling TIPS

There isnt much for profiling on nix but I have found the environment variables
`NIX_COUNT_CALLS` & `NIX_SHOW_STATS`. Set both to `1` and it outputs a large
JSON file with all the paths and whats being called frequently

## Nixpkgs checkout tip

```bash
mkdir nixpkgs
cd nixpkgs
git init
git remote add origin <url>
git fetch --depth 1 origin <sha1>
git checkout FETCH_HEAD
```
