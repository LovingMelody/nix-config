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
  };
  config = mkIf cfg.enable {zramSwap = mkDefault {inherit (cfg) enable memoryPercent priority;};};
}
