{
  config,
  lib,
  ...
}: let
  cfg = config.TM.programs.man;
  inherit (lib) mkEnableOption mkIf;
in {
  options.TM.programs.man.enable =
    mkEnableOption "man pages"
    // {
      default = true;
    };

  config = mkIf cfg.enable {
    manual.manpages.enable = true;
    programs.man.enable = true;
  };
}
