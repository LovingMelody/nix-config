{
  config,
  lib,
  ...
}: let
  cfg = config.TM.programs.lsd;
  inherit (lib) mkEnableOption mkIf;
in {
  options.TM.programs.lsd.enable =
    mkEnableOption "The next gen ls command"
    // {
      default = true;
    };

  config = mkIf cfg.enable {
    programs.lsd = {
      enable = true;
    };
  };
}
