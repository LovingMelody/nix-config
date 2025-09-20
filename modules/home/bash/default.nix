{
  self,
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.TM.shells.bash;
  inherit (lib) mkEnableOption mkIf;
in {
  options.TM.shells.bash.enable =
    mkEnableOption "GNU Bourne-Again Shell, the de facto standard shell on Linux"
    // {
      default = true;
    };
  config = mkIf cfg.enable {
    programs.bash = {
      enable = true;
      enableVteIntegration = true;
      historyControl = ["ignorespace"];
      historyIgnore = [
        "#"
        "ls"
        "cd"
        "exit"
      ];
      shellOptions = [
        "histappend"
        "checkwinsize"
        "checkjobs"
      ];
      shellAliases = ((import "${self}/shellAliases.nix") {inherit pkgs lib;}) // {};
    };
  };
}
