{
  lib,
  config,
  ...
}: let
  cfg = config.TM.programs.ion;
  inherit (lib) mkIf mkEnableOption;
in {
  options.TM.programs.ion.enable =
    mkEnableOption "ION shell"
    // {
      default = true;
    };
  config = mkIf cfg.enable {
    programs.ion.enable = true;
  };
}
