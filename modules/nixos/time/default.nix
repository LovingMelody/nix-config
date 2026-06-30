{
  lib,
  config,
  ...
}: let
  cfg = config.TM.time;
  inherit
    (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  inherit (lib.strings) optionalString;
in {
  options.TM.time = {
    enable = mkEnableOption "Enable System time. Uses ntpd-rs to sync time." // {default = true;};
    timeZone = mkOption {
      type = with types; nullOr str;
      default = optionalString config.TM.isGui "America/New_York";
      description = "Timezone";
      apply = str:
        if str == ""
        then null
        else str;
    };
    hwclock =
      mkEnableOption "Hardware clock"
      // {
        default = true;
      };
  };

  config = mkIf cfg.enable {
    # Lets set this to null
    time = {
      # timeZone = if config.TM.isGui then cfg.timeZone else null;
      inherit (cfg) timeZone;
      hardwareClockInLocalTime = !cfg.hwclock;
    };
    # Only Enable if timezone is null - timezoned wont work if timezone is defined
    services = {
      timesyncd.enable = mkDefault false;
      ntpd-rs.enable = mkDefault (!config.boot.isContainer);
      # automatic-timezoned.enable = mkDefault (config.time.timeZone != null);
      geoclue2.enable = config.time.timeZone != null;
    };
  };
}
