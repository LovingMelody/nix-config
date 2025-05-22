{
  disks ? [
    "nvme0n1"
    "nvme1n1"
    "nvme3n1"
  ],
  secretFile ? "/.persistent/secret.key",
  ...
}: let
  defineZfs = idx: {
    type = "disk";
    device = "/dev/nvme${builtins.toString idx}n1";
    content = {
      type = "gpt";
      partitions = {
        zfs = {
          size = "100%";
          content = {
            type = "zfs";
            pool = "zroot";
          };
        };
      };
    };
  };
  b = builtins.elemAt disks 2;
in {
  disk = {
    x = defineZfs 0;
    y = defineZfs 1;
    z = {
      type = "disk";
      device = "/dev/${b}";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            size = "2G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = ["nofail"];
            };
          };
          swap = {
            size = "64G";
            content = {
              type = "swap";
              randomEncryption = true;
              resumeDevice = true; # resume from hibernation from this device
            };
          };
          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "crypted";
              # This should be done using crypttab
              initrdUnlock = false;
              settings = {
                allowDiscards = true;
                keyFile = secretFile;
              };
              content = {
                type = "btrfs";
                extraArgs = ["-f"];
                subvolumes = {
                  "@melody-OneDrive" = {
                    mountpoint = "/home/melody/OneDrive";
                    mountOptions = ["compress=zstd:9" "noatime" "discard=async"];
                  };
                  "@melody-Games" = {
                    mountpoint = "/home/melody/Games";
                    mountOptions = ["noatime" "discard=async"];
                  };
                  "@melody-docker" = {
                    mountpoint = "/home/melody/.docker-files";
                    mountOptions = ["compress=zstd:9" "noatime" "discard=async"];
                  };
                };
              };
            };
          };
        };
      };
    };
  };
  zpool = {
    zroot = {
      type = "zpool";
      mode = "mirror";
      rootFsOptions = {
        compression = "zstd-5";
        "com.sun:auto-snapshot" = "false";
        acltype = "posixacl";
        xattr = "sa";
        mountpoint = "none";
      };
      datasets = {
        NixOS = {
          type = "zfs_fs";
          options = {
            encryption = "aes-256-gcm";
            keyformat = "passphrase";
            # keylocation = "file://${secretFile}";
            keylocation = "prompt";
          };
        };
        "NixOS/root" = {
          type = "zfs_fs";
          mountpoint = "/";
          postCreateHook = "zfs snapshot zroot/NixOS/root@blank";
        };
        "NixOS/persist" = {
          type = "zfs_fs";
          mountpoint = "/.persistent";
        };
        "NixOS/nix" = {
          type = "zfs_fs";
          mountpoint = "/nix";
        };
        "NixOS/home" = {
          type = "zfs_fs";
          mountpoint = "/home";
        };
        "NixOS/logs" = {
          type = "zfs_fs";
          mountpoint = "/var/logs";
        };
        "NixOS/FinalFantasyXIV" = {
          type = "zfs_fs";
          mountpoint = "/.FinalFantasyXIV";
        };
        "NixOS/FinalFantasyXIV/melody" = {
          type = "zfs_fs";
          mountpoint = "/home/melody/FinalFantasy";
        };
        "NixOS/FinalFantasyXIV/melody/MareSync" = {
          type = "zfs_fs";
          mountpoint = "/home/melody/ffxiv-extras/Mare";
        };
        "NixOS/FinalFantasyXIV/melody/Penumbra" = {
          type = "zfs_fs";
          mountpoint = "/home/melody/ffxiv-extras/Penumbra";
        };
        "NixOS/FinalFantasyXIV/melody/XIV" = {
          type = "zfs_fs";
          mountpoint = "/home/melody/.xlcore";
        };
      };
    };
  };
}
