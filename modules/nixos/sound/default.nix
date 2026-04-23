{
  lib,
  config,
  ...
}: let
  cfg = config.TM.sound;
  inherit
    (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
in {
  options.TM.sound = {
    enable = mkEnableOption "Enable sound";
    support32Bit = mkOption {
      type = types.bool;
      default = true;
      description = "Enable 32 bit support";
    };
  };

  config = mkIf cfg.enable {
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa = {
        enable = true;
        inherit (cfg) support32Bit;
      };
      pulse.enable = true;
      jack.enable = true;
    };
  };
}
