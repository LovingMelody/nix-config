{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.TM.programs.wine;
  inherit
    (lib)
    mkIf
    mkEnableOption
    mkOption
    ;
in {
  options.TM.programs.wine = {
    binfmt = mkEnableOption "Enable Wine binfmt";
    package = mkOption {
      description = "Wine Package to use";
      default = pkgs.wine-astral-ntsync;
    };
  };

  config = mkIf cfg.binfmt {
    environment.systemPackages = [cfg.package];
    programs.wine = {
      binfmt = true;
      enable = true;
      inherit (cfg) package;
    };
  };
}
