{
  config,
  lib,
  ...
}: let
  cfg = config.TM.impermanence;
  dir = directory: user: group: mode: {
    inherit
      directory
      user
      group
      mode
      ;
  };
  inherit
    (lib)
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    types
    ;
in {
  options.TM.impermanence = {
    enable = mkEnableOption "impermanence";
    rollbackCommand = mkOption {
      type = types.str;
      description = "Command to remove all impermanent files";
    };
    persistentDirectory = mkOption {
      type = types.str;
      description = "Directory to store persistent files";
      default = "/.persistent";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      # Handles rollbacks for ZFS, disabled to ensure paths are fully set
      # boot.initrd.systemd.services.impermanence = {
      #   description = "Resets root to a clean state (Requires ZFS)";
      #   wantedBy = [ "initrd.target" ];
      #   after = [ "zfs-import-zroot.service" ];
      #   before = [ "sysroot.mount" ];
      #   path = with pkgs; [ zfs ];
      #   unitConfig.DefaultDependencies = "no";
      #   serviceConfig.Type = "oneshot";
      #   script = cfg.rollbackCommand;
      # };
      environment.persistence.${cfg.persistentDirectory} = {
        hideMounts = true;
        directories = [
          (dir "/var/log" "root" "root" "u=rwx,g=rx,o=rx")
          (dir "/var/lib/bluetooth" "root" "root" "u=rwx,g=,o=")
          (dir "/var/lib/nixos" "root" "root" "u=rwx,g=rx,o=rx")
          (dir "/var/lib/systemd/coredump" "root" "root" "u=rwx,g=rx,o=rx")
          (dir "/etc/NetworkManager/system-connections" "root" "root" "u=rwx,g=,o=")
          "/var/lib/flatpak"
          "/var/lib/libvirt"
          "/var/lib/pipewire"
          (dir "/var/lib/alsa" "root" "root" "u=rwx,g=rx,o=rx")
          (dir "/var/cache/tailscale" "root" "root" "u=rwx,g=rx,o=rx")

          (dir "/var/lib/tailscale" "root" "root" "u=rwx,g=,o=")
          (dir "/var/db/sudo" "root" "root" "u=rwx,g=,o=")
          (dir "/etc/secureboot" "root" "root" "u=rwx,g=rx,o=rx")
          (dir "/etc/fwupd" "root" "root" "u=rwx,g=rx,o=rx")
          (dir "/etc/ssh/authorized_keys.d" "root" "root" "u=rwx,g=rx,o=rx")
          (dir "/var/lib/colord" "colord" "colord" "u=rwx,g=rx,o=rx")
        ];
        files = [
          "/etc/machine-id"
          {
            file = "/etc/nix/id_rsa";
            parentDirectory = {
              mode = "u=rwx,g=,o=";
            };
          }
          "/etc/shadow"
          "/etc/passwd"
          "/etc/group"
          "/etc/subgid"
          "/etc/subuid"
          "/etc/sudoers"
          "/etc/adjtime"
          "/etc/ssh/ssh_host_ed25519_key"
          "/etc/ssh/ssh_host_ed25519_key.pub"
          "/etc/ssh/ssh_host_rsa_key"
          "/etc/ssh/ssh_host_rsa_key.pub"
        ];
      };
    }
    (mkIf config.TM.users.enable {
      programs.fuse.userAllowOther = true;
      environment.persistence.${cfg.persistentDirectory} = {
        users.melody = {
          directories = [
            "Downloads"
            "Music"
            "Games"
            "Pictures"
            "Documents"
            "Videos"
            "VirtualBox VMs"
            "Development"
            {
              directory = ".gnupg";
              mode = "0700";
            }
            {
              directory = ".ssh";
              mode = "0700";
            }
            {
              directory = ".local/share/keyrings";
              mode = "0700";
            }
            ".local/share/direnv"
            {directory = ".local/share/Steam";}
            {directory = ".steam";}
            ".config/obs-studio"
            ".config/discord"
            ".config/VencordDesktop"
            ".local/share/TelegramDesktop"
            ".mozilla"
            ".config/kdeconnect"
          ];
          files = [
            ".screenrc"
            ".config/spotify/prefs"
            ".config/spotify/Users/fuzen-py/prefs"
          ];
        };
      };
    })
  ]);
}
