{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkOption mkIf;
  cfg = config.TM.programs.appimage;
in {
  options.TM.programs.appimage = {
    enable = mkEnableOption "Enable Appimage & binfmt" // {default = ! config.TM.isServer;};
    extraPkgs = mkOption {
      description = "Extra packages for appimage-run";
      default = _pkgs: [];
    };
    package = mkOption {
      description = "App image runner package";
      default = pkgs.appimage-run;
      apply = p: p.override (o: {extraPkgs = pkgs: ((o.extraPkgs or (_: [])) pkgs) ++ (cfg.extraPkgs pkgs);});
    };
  };

  config = mkIf cfg.enable {
    programs.appimage = {
      enable = true;
      binfmt = true;
      inherit (cfg) package;
    };
  };
}
