{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.TM.services.liquidctl;
  inherit
    (lib)
    concatStringsSep
    getExe
    mapAttrsToList
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in {
  options.TM.services.liquidctl = {
    enable = mkEnableOption "Enable liquidctl service";
    config = mkOption {
      # { device-name = { commands = [ "command" ]; };
      type = types.attrsOf (types.attrsOf (types.listOf types.str));
      default = {};
      description = ''
        Configuration for liquidctl service.
      '';
      example = ''
        {
          kraken = {
            commands = [
              "set pump speed 100"
              "set fan speed 100"
              "set lcd screen liquid"
            ];
          };
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [pkgs.liquidctl];
    services.udev.packages = [pkgs.liquidctl];
    systemd.services.liquidctl = {
      wantedBy = ["multi-user.target"];
      # Udev rules are needed
      after = ["systemd-udev-settle.service"];
      # Only run once
      serviceConfig = {
        Type = "oneshot";
        PrivateNetwork = true;
        ProtectHostname = true;
        LockPersonality = true;
        ProtectClock = true;
        ProtectHome = true;
        CapabilityBoundingSet = "";
        NoNewPrivileges = true;
      };
      # Run commands defined in configuration
      # EX: { kraken = { commands = [ "set pump speed 100" "set fan speed 100" "set lcd screen liquid" ]; }; }
      # Result:
      #  liquidctl initialize -m kraken
      #
      #  liquidctl -m kraken set pump speed 100
      #  liquidctl -m kraken set fan speed 100
      #  liquidctl -m kraken set lcd screen liquid
      script = ''
        ${concatStringsSep "\n" (
          mapAttrsToList (device: _attrs: ''
            ${getExe pkgs.liquidctl} initialize -m '${device}'
          '')
          cfg.config
        )}

        ${concatStringsSep "\n" (
          mapAttrsToList (device: attrs: ''
            ${concatStringsSep "\n" (
              map (command: "${getExe pkgs.liquidctl} -m '${device}' ${command}") attrs.commands
            )}
          '')
          cfg.config
        )}
      '';
    };
  };
}
