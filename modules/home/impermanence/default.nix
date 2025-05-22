{
  config,
  lib,
  osConfig,
  inputs,
  ...
}: let
  cfg = config.TM.impermanence;
  inherit (lib) mkIf mkOption types;
in {
  options.TM.impermanence = {
    enable = mkOption {
      type = types.bool;
      description = "Impermanence";
      default =
        if builtins.hasAttr "nebula" osConfig
        then osConfig.TM.impermanence.enable
        else false;
    };
  };

  config = mkIf cfg.enable {};
}
