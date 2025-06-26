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
    getExe'
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
    boot.binfmt = {
      emulatedSystems = ["x86_64-windows"];
      registrations.x86_64-windows = {
        interpreter = getExe' cfg.package "wine";
        interpreterSandboxPath = "${cfg.package}/";
      };
    };
  };
}
