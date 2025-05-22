{
  self,
  config,
  lib,
  ...
}: let
  cfg = config.TM.users;
  inherit (lib) TM mkDefault mkIf;
  homeConfigPath = "${self}/homes/root@${config.networking.hostName}";
in {
  config = mkIf cfg.enable {
    # Define root home
    home-manager.users.root = {
      home.username = "root";
      imports = lib.optional (builtins.pathExists homeConfigPath) homeConfigPath;
    };
    users.users.root = {
      openssh.authorizedKeys.keyFiles = [(TM.get-ssh-key-file "melody" "primary")];
      initialHashedPassword = mkDefault "$y$j9T$mbaez7gndeXjoFjwITJxq.$Mec3S9jVYgm6tW9HzqJgk0xP1xhBoNh4tsMy1dsryYB";
      extraGroups = ["ssh"];
    };
  };
}
