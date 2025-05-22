{
  config,
  inputs,
  lib,
  osConfig,
  pkgs,
  system,
  ...
}: let
  cfg = config.TM.programs.spotify;
  spicePkgs = inputs.spicetify-nix.legacyPackages.${system};
  inherit (lib) mkDefault mkEnableOption mkIf;
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
    programs.spicetify = mkIf pkgs.stdenv.isLinux {
      enable = true;
      theme = mkDefault spicePkgs.themes.catppuccin;
      colorScheme = mkDefault "${lib.toLower config.TM.styles.flavor}";
      enabledExtensions = with spicePkgs.extensions; [
        shuffle
        powerBar
        keyboardShortcut
        fullAppDisplay
        autoVolume
        betterGenres
      ];
    };
  };
}
