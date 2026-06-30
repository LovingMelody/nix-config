{
  config,
  lib,
  osConfig,
  ...
}: let
  cfg = config.TM.impermanence;
  inherit (lib) mkIf mkOption types;
in {
  options.TM.impermanence = {
    enable = mkOption {
      type = types.bool;
      description = "Impermanence";
      default = osConfig.TM.impermanence.enable or false;
    };
  };

  config = mkIf cfg.enable {};
}
