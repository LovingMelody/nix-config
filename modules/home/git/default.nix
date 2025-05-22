{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.TM.programs.git;
  inherit (lib) mkEnableOption mkIf;
in {
  options.TM.programs.git.enable =
    mkEnableOption "Distributed version control system"
    // {
      default = true;
    };

  config = mkIf cfg.enable {
    programs.git = {
      package = pkgs.gitAndTools.gitFull;
      enable = true;
      userName = "Melody Renata";
      userEmail = "me@lovingmelody.io";
      delta.enable = true;
      lfs = {
        enable = true;
      };
      ignores = [
        "*~"
        "*.swp"
        ".DS_Store"
      ];
      extraConfig = {
        init.defaultBranch = "main";
        core = {
          whitespace = "trailing-space,space-before-tab";
        };
        safe.directory = "/etc/nixos";
        url = {
          "git@gitlab.com:".insteadOf = "gitlab:";
          "git@github.com:".insteadOf = "github:";
        };
      };
      signing =
        {
          signByDefault = config.programs.gpg.enable;
        }
        // mkIf (!config.TM.programs._1password.gpgSign.enable) {
          key = "52c78a112121b1c150ca5c626e2223885f29dea5";
        };
    };
  };
}
