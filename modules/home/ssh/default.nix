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
      compression = true;
      forwardAgent = true;
      matchBlocks = {
        "eu.nixbuild.net" = {
          identitiesOnly = true;
          identityFile = "~/.ssh/nixbuild.pub";
        };
      };
    };
  };
}
