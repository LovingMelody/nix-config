{
  config,
  lib,
  ...
}: let
  cfg = config.TM.zram;
  inherit
    (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in {
  options.TM.zram = {
    enable =
      mkEnableOption "Enable zswap"
      // {
        default = true;
      };
    memoryPercent = mkOption {
      type = types.int;
      default = 90;
      description = "zramSwap memory percent";
    };
    priority = mkOption {
      type = types.int;
      default = 100;
      description = "zram priority (higher than swap)";
    };
    swappiness = mkOption {
      type = types.ints.between 0 200;
      default = 180;
      description = ''
        vm.swappiness while zram is enabled. values >100 are recommended.
      '';
    };
    pageCluster = mkOption {
      type = types.ints.unsigned;
      default = 0;
      description = "vm.page-cluster while zram is enabled (0 = no swap readahead, ideal for zram)";
    };
  };
  config = mkIf cfg.enable {
    zramSwap = mkDefault {inherit (cfg) enable memoryPercent priority;};
    boot.kernel.sysctl = {
      "vm.swappiness" = cfg.swappiness;
      "vm.page-cluster" = cfg.pageCluster;
    };
  };
}
