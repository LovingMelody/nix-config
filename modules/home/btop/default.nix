{
  config,
  lib,
  ...
}: let
  cfg = config.TM.programs.btop;
  inherit (lib) mkEnableOption mkIf;
in {
  options.TM.programs.btop.enable =
    mkEnableOption "btop"
    // {
      default = true;
    };

  config = mkIf cfg.enable {
    programs.btop = {
      enable = true;
      settings = {
        truecolor = true;
        proc_tree = true;
        clock_format = "%H:%M:%S";
      };
    };
  };
}
