{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.TM.programs.librewolf;
  inherit (lib) mkEnableOption mkIf;
in {
  options.TM.programs.librewolf.enable =
    mkEnableOption "A fork of Firefox, focused on privacy, security and freedom";

  config = mkIf cfg.enable {
    programs.librewolf = {
      enable = true;
      package = pkgs.librewolf;
    };
  };
}
