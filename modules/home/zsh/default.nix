{
  self,
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.TM.shells.zsh;
  inherit (lib) mkEnableOption mkIf;
in {
  options.TM.shells.zsh.enable =
    mkEnableOption "The Z shell"
    // {
      default = true;
    };

  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      shellAliases = (import "${self}/shellAliases.nix") {inherit pkgs;};
    };
  };
}
