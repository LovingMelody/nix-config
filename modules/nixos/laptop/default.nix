{
  config,
  lib,
  ...
}: let
  # Defined in helper
  cfg = config.TM.isLaptop;
  inherit (lib) mkIf;
in {
  config = mkIf cfg {
    services = {
      thermald.enable = true;
      tlp = {
        enable = true;
        pd.enable = true;
        settings = {
          CPU_BOOST_ON_AC = 1;
          CPU_BOOST_ON_BAT = 0;
          CPU_HWP_DYN_BOOST_ON_AC = 1;
          CPU_HWP_DYN_BOOST_ON_BAT = 0;
          CPU_SCALING_GOVERNOR_ON_AC = "performance";
          CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
          CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
          CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
          PLATFORM_PROFILE_ON_AC = "performance";
          PLATFORM_PROFILE_ON_BAT = "low-power";
        };
      };
      power-profiles-daemon.enable = false;
    };
  };
}
