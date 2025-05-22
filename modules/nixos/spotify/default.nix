{
  inputs,
  system,
  config,
  lib,
  ...
}: let
  cfg = config.TM.programs.spotify;
  spicePkgs = inputs.spicetify-nix.legacyPackages.${system};
  inherit (lib) mkDefault mkEnableOption mkIf;
in {
  # This is just lets you enable spotify globally
  options.TM.programs.spotify.enable =
    mkEnableOption "Spotify"
    // {
      default = false;
    };

  config = mkIf cfg.enable {
    programs.spicetify = {
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
