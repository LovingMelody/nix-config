{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.TM.programs.bat;
  inherit (lib) mkEnableOption mkIf;
in {
  options.TM.programs.bat.enable =
    mkEnableOption "A cat(1) clone with wings."
    // {
      default = true;
    };

  config = mkIf cfg.enable {
    programs.bat = {
      enable = true;
      extraPackages = with pkgs.bat-extras; [
        # batdiff
        batgrep
        batman
        batpipe
        batwatch
        prettybat
      ];
      # config = { theme = "base16"; };
    };
  };
}
