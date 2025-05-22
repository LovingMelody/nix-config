{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.TM.programs.neovim;
in {
  options.TM.programs.neovim = {
    enable =
      mkEnableOption "neovim"
      // {
        default = true;
      };
    defaultEditor =
      mkEnableOption "Set default editor"
      // {
        default = true;
      };
  };
  config = mkIf cfg.enable {
    programs.nvf = {
      inherit (cfg) enable defaultEditor;
      enableManpages = true;
      settings = import ./nvf.nix {inherit config pkgs lib;};
    };
  };
}
