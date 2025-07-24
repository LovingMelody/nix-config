{
  self,
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.TM.users;
  inherit (lib) mkForce mkIf optional;
  homeConfigPath = "${self}/homes/melody@${config.networking.hostName}";
in {
  config = mkIf cfg.enable {
    # Define melody
    home-manager.users.melody = {
      home.username = "melody";
      imports = optional (builtins.pathExists homeConfigPath) homeConfigPath;
    };
    programs.zsh.enable = true;
    users.groups.melody = {};
    users.users.melody = {
      isNormalUser = true;
      initialPassword = "Nixtastic!23";
      group = "melody";
      extraGroups =
        [
          "adbusers"
          "audio"
          "bluetooth"
          "games"
          "libvirtd"
          "lp"
          "plugdev"
          "podman"
          "docker"
          "ssh"
          "tss"
          "video"
          "virtualization"
          "wheel"
        ]
        ++ optional config.virtualisation.lxd.enable "lxd";
      shell = mkForce pkgs.zsh;
      description = "Melody Renata";
      openssh.authorizedKeys.keyFiles = [
        (lib.TM.get-ssh-key-file "melody" "blink")
        (lib.TM.get-ssh-key-file "melody" "primary")
      ];
    };
  };
}
