{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.TM.programs.fastfetch;
  inherit (lib) mkEnableOption mkIf getExe;
  inherit (lib.strings) optionalString toLower;
  pokemonValue = config.TM.pokemon.name or config.TM.pokemon.pokedex or null;
  pokemonVariant =
    if (config.TM.pokemon.variant or null) != null
    then "--${toLower config.TM.pokemon.variant}"
    else "";
  logo =
    if (pokemonValue != null)
    then let
      txt = pkgs.runCommand "pokemon-${pokemonValue}" {} ''
        mkdir -p $out
        ${getExe pkgs.pokeget-rs} ${pokemonValue} \
        ${pokemonVariant} \
        ${optionalString (config.TM.pokemon.shiny or false) "--shiny"} \
        > $out/pokemon-${pokemonValue}.txt'';
    in "${txt}/pokemon-${pokemonValue}.txt"
    else null;
in {
  options.TM.programs.fastfetch.enable =
    mkEnableOption "Enable Fastfetch"
    // {
      default = true;
    };

  config = mkIf cfg.enable {
    programs.fastfetch = {
      enable = true;
      settings = {
        display = {
          separator = "  ";
          constants = [
            "─────────────────"
          ];
          key = {
            type = "icon";
            paddingLeft = 2;
          };
        };
        logo = mkIf (logo != null) {
          source = logo;
          type = "file-raw";
        };
        modules = [
          {
            type = "custom";
            format = "┌{$1} {#1}Hardware Information{#} {$1}┐";
          }
          "host"
          "cpu"
          "gpu"
          "disk"
          "memory"
          "swap"
          "display"
          "brightness"
          "battery"
          "poweradapter"
          "bluetooth"
          "sound"
          "gamepad"
          {
            type = "custom";
            format = "├{$1} {#1}Software Information{#} {$1}┤";
          }
          {
            type = "title";
            keyIcon = "";
            key = "Title";
            format = "{user-name}@{host-name}";
          }
          "os"
          "kernel"
          "lm"
          "de"
          "wm"
          "shell"
          "terminal"
          "terminalfont"
          "theme"
          "icons"
          "wallpaper"
          "packages"
          "uptime"
          "media"
          {
            type = "localip";
            compact = true;
          }
          {
            type = "publicip";
            timeout = 1000;
          }
          {
            type = "wifi";
            format = "{ssid}";
          }
          "locale"
          {
            type = "custom";
            format = "└{$1}──────────────────────{$1}┘";
          }
          {
            type = "colors";
            paddingLeft = 2;
            symbol = "circle";
          }
        ];
      };
    };
  };
}
