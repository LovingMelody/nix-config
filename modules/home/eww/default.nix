{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.TM.programs.eww;
  inherit (lib) mkEnableOption mkIf;
in {
  options.TM.programs.eww = {
    enable = mkEnableOption "EWW";
  };

  config = mkIf cfg.enable {
    xdg.configFile."eww/bar/eww.yuck".source = ./config/bar/eww.yuck;
    programs.eww = {
      enable = true;
      package = pkgs.eww-wayland;
    };
  };
}
