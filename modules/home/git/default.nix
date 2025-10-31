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
    programs.delta.enable = true;
    programs.git = {
      package = pkgs.gitFull;
      enable = true;
      lfs = {
        enable = true;
      };
      ignores = [
        "*~"
        "*.swp"
        ".DS_Store"
      ];
      settings = {
        user = {
          name = "Melody Renata";
          email = "me@lovingmelody.io";
        };
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
      signing = {
        signByDefault = config.programs.gpg.enable;
        key = lib.removeSuffix "\n" (builtins.readFile (lib.TM.get-ssh-key-file "melody" "primary"));
      };
    };
  };
}
