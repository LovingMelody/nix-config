{
  config,
  lib,
  ...
}: let
  cfg = config.TM.programs.gh;
  inherit (lib) mkEnableOption mkIf;
in {
  options.TM.programs.gh.enable =
    mkEnableOption "GitHub CLI tool"
    // {
      default = true;
    };

  config = mkIf cfg.enable {programs.gh.enable = true;};
}
