{
  config,
  lib,
  ...
}: let
  cfg = config.TM.programs.fzf;
  inherit (lib) mkEnableOption mkIf;
in {
  options.TM.programs.fzf.enable =
    mkEnableOption "A command-line fuzzy finder written in Go"
    // {
      default = true;
    };

  config = mkIf cfg.enable {programs.fzf.enable = true;};
}
