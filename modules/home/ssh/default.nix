{
  config,
  lib,
  ...
}: let
  cfg = config.TM.programs.ssh;
  inherit (lib) mkEnableOption mkIf;
in {
  options.TM.programs.ssh.enable = mkEnableOption "ssh";
  config = mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      /**/
      settings = {
        "Host *" = {
          # forwardAgent = true;
          compression = true;
        };
        "Host eu.nixbuild.net" = {
          identitiesOnly = true;
          identityFile = "~/.ssh/nixbuild.pub";
        };
      };
    };
  };
}
