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

      extraConfig.pipewire."10-clock" = {
        "context.properties" = {
          "default.clock.rate" = 48000;

          "default.clock.allowed-rates" = [48000 44100];

          "default.clock.quantum" = 2048;

          "default.clock.min-quantum" = 1024;

          "default.clock.max-quantum" = 8192;
        };

        "context.modules" = [
          {
            name = "libpipewire-module-rt";
            flags = ["ifexists" "nofail"];
            args = {
              "nice.level" = -11;
              "rt.prio" = 88; # RT priority (rtkit ceiling is usually 99)
              "rt.time.soft" = 200000; # 200ms soft RT time limit (microseconds)
              "rt.time.hard" = 200000; # Hard limit — process killed if exceeded
            };
          }
        ];
      };

      wireplumber.extraConfig = {
        "10-device-rules"."monitor.alsa.rules" = [
          {
            # Topping E70 — native S32LE/48kHz, match pw-top observation
            matches = [{"node.name" = "~alsa_output.usb-Topping.*";}];
            actions.update-props = {
              "audio.format" = "S32LE";
              "audio.rate" = 48000;
              # period-num * quantum = total ALSA buffer. 3 periods gives
              # one quantum of slack before an underrun becomes audible.
              "api.alsa.period-num" = 3;
              "session.suspend-timeout-seconds" = 0;
            };
          }
          {
            # Logitech PRO X Wireless — USB, likely F32P internally.
            matches = [{"node.name" = "~alsa_output.usb-Logitech_PRO_X.*";}];
            actions.update-props = {
              "audio.rate" = 48000;
              "api.alsa.period-num" = 3;
              "session.suspend-timeout-seconds" = 0;
            };
          }
          {
            # Blue USB mic — pin to 48kHz to match the output graph rate.
            matches = [{"node.name" = "~alsa_input.usb-Generic_Blue_Microphones.*";}];
            actions.update-props = {
              "audio.rate" = 48000;
              "session.suspend-timeout-seconds" = 0;
            };
          }
        ];

        "21-game-rate"."stream.rules" = [
          {
            matches = [{"media.class" = "Stream/Output/Audio";}];
            actions.update-props = {
              "audio.rate" = 48000;
            };
          }
        ];
      };
    };
  };
}
