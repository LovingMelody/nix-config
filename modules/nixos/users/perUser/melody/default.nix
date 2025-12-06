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
      createHome = true;
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
          "virtualisation"
          "wheel"
          "vboxusers"
          "kvm"
        ]
        ++ optional config.virtualisation.incus.enable "incus-admin";
      shell = mkForce pkgs.zsh;
      description = "Melody Renata";
      openssh.authorizedKeys.keyFiles = [
        (lib.TM.get-ssh-key-file "melody" "blink")
        (lib.TM.get-ssh-key-file "melody" "primary")
      ];
    };
    systemd.tmpfiles.rules = let
      faceImg = pkgs.fetchurl {
        url = "https://cdn.little-melody.net/Public/face.png";
        hash = "sha256-vVuFZINh5fobX6FLy4WVVadwNYyf6w8Wa+vTkTNCA7M=";
      };
    in ["L+ /share/faces/melody - - - - ${faceImg}"];
  };
}
