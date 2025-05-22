{
  config,
  lib,
  ...
}: let
  cfg = config.TM.users;
  inherit (lib) mkIf;
in {
  config = mkIf cfg.enable {
    users = {
      groups.builder = {};
      users.builder = {
        openssh.authorizedKeys.keyFiles = config.users.users.root.openssh.authorizedKeys.keyFiles;
        group = "builder";
        extraGroups = ["ssh"];
        createHome = false;
        isSystemUser = true;
        useDefaultShell = true;
        description = "NixOS builder";
      };
    };
  };
}
