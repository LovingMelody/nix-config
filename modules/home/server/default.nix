{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.TM.home-profiles.server;
  inherit (lib) mkEnableOption mkIf;
in {
  options.TM.home-profiles.server = {
    enable = mkEnableOption "Enable server defaults";
  };

  config = mkIf cfg.enable {
    TM.programs.kitty.enable = false;
    home.packages = [pkgs.wezterm.terminfo];
  };
}
