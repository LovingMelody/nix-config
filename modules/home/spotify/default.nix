{
  config,
  inputs,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  cfg = config.TM.programs.spotify;
  inherit (lib) mkEnableOption mkIf;
in {
  options.TM.programs.spotify.enable =
    mkEnableOption "Spotify"
    // {
      default = osConfig.TM.programs.spotify.enable or true;
    };
  imports = [
    inputs.spicetify-nix.homeManagerModules.default
  ];
  config = mkIf cfg.enable {
    programs.spicetify = {
      enable = true;
      theme = pkgs.spicePkgs.themes.catppuccin;
      colorScheme = "${lib.toLower config.TM.styles.flavor}";
      enabledExtensions = with pkgs.spicePkgs.extensions; [
        shuffle
        powerBar
        keyboardShortcut
        fullAppDisplay
        autoVolume
        betterGenres
        aiBandBlocker
      ];
    };
  };
}
