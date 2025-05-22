{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.TM.sound;
  inherit (lib) mkIf;
  inherit (config.TM.libExtra) mkEnableTarget;
in {
  options.TM.sound = {
    enable = mkEnableTarget "Enable Sound options for home" [
      "sound"
      "enable"
    ];
  };

  config = mkIf cfg.enable {
    # # Enable Easy Effects
    # services.easyeffects.enable = mkDefault (pkgs.stdenv.isLinux && config.TM.isGui);
  };
}
