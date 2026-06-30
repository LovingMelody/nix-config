{
  config,
  lib,
  ...
}: let
  cfg = config.TM.impermanence;
  inherit (lib) mkIf mkEnableOption;
  inherit (config.TM.libExtra) fromOS;
in {
  options.TM.impermanence = {
    enable =
      mkEnableOption "Impermanence"
      // {
        default = fromOS ["impermanence" "enable"] false;
      };
  };

  config = mkIf cfg.enable {};
}
