{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.TM.sound;
  inherit (lib) mkIf mkDefault;
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
    services.easyeffects = {
      enable = mkDefault (pkgs.stdenv.isLinux && config.TM.isGui);
      extraPresets = {
        HD600S = builtins.fromJSON (builtins.readFile ./EasyEffectPresets/HD600S.json);
        "Logitech Pro X" = builtins.fromJSON (builtins.readFile ./EasyEffectPresets/LogitechProX.json);
        Microphone = builtins.fromJSON (builtins.readFile ./EasyEffectPresets/Microphone.json);
      };
    };
  };
}
