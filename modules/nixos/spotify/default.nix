{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.TM.programs.spotify;
  inherit (lib) mkEnableOption mkIf;
in {
  # This is just lets you enable spotify globally
  options.TM.programs.spotify.enable =
    mkEnableOption "Spotify"
    // {
      default = false;
    };

  config = mkIf cfg.enable {
    environment.systemPackages = [pkgs.spotatui];
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
