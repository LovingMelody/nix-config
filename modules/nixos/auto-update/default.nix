# Enables system upgrades using system.autoUpgrade
{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.TM.autoUpgrade;
  inherit
    (lib)
    mdDoc
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in {
  options.TM.autoUpgrade = {
    enable = mkEnableOption "Enable autoupgrades" // {default = true;};
    operation = mkOption {
      type = types.enum [
        "switch"
        "boot"
      ];
      default = "switch";
    };
    dates = mkOption {
      type = types.str;
      default = "daily";
    };
    allowReboot = mkEnableOption "Allow rebooting for kernel, module or initrd updates";
    randomizedDelaySec = mkOption {
      type = types.str;
      default = "1h";
      description = mdDoc "Randomized delay for upgrades format must be {manpage}`systemd.time(7)`";
    };
    persistent = mkEnableOption "Enable persistent upgrades" // {default = true;};
    flags = mkOption {
      type = types.listOf types.str;
      default =
        ["-L" "--verbose" "--verbose"]
        ++ lib.optionals (builtins.hasAttr "specialisation" config.environment.etc) ["--specialisation" config.environment.etc.specialisation.text];
    };
  };

  config = mkIf cfg.enable {
    # Git is needed for the flake to be able to update itself
    # TODO: This should be removed once flakes are stable
    environment.systemPackages = [pkgs.git];
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    system.autoUpgrade = {
      inherit
        (cfg)
        enable
        operation
        dates
        allowReboot
        randomizedDelaySec
        persistent
        flags
        ;
      flake = lib.TM.info.url;
    };
  };
}
