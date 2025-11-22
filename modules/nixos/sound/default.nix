{
  lib,
  config,
  ...
}: let
  cfg = config.TM.sound;
  inherit
    (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in {
  options.TM.sound = {
    enable = mkEnableOption "Enable sound";
    lowLatency = mkOption {
      type = types.bool;
      default = false;
      description = "Enable low latency mode";
    };
    support32Bit = mkEnableOption {
      types = types.bool;
      default = true;
      description = "Enable 32 bit support";
    };
  };

  config = mkIf cfg.enable {
    security.rtkit.enable = true;
    services = {
      pulseaudio.enable = false;
      pipewire = {
        enable = true;
        alsa = mkDefault {
          enable = true;
          inherit (cfg) support32Bit;
        };
        pulse.enable = true;
        jack.enable = true;
        wireplumber.enable = true;
        lowLatency = {
          enable = cfg.lowLatency;
          rate = 48000;
        };
      };
    };
  };
}
