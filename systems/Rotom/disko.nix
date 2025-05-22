{
  disks ? [
    "/dev/disk/by-id/wwn-0x5002538e702c2273" # SDA
    "/dev/disk/by-id/wwn-0x5f8db4c505130227" # SDB
    "/dev/disk/by-id/wwn-0x5000c500c3a5ee56" # SDC
  ],
  secretFile ? "/tmp/secret.key",
  ...
}: let
  defineZfs = device: {
    type = "disk";
    inherit device;
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
in {
  disk = {
    bootswap = {
      type = "disk";
      device = builtins.elemAt disks 1;
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "5G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          # luks = {
          #   size = "5G";
          #   content = {
          #     type = "luks";
          #     name = "crypted";
          #     passwordFile = secretFile;
          #     settings = {
          #       allowDiscards = true;
          #     };
          #     content = {
          #       type = "btrfs";
          #       extraArgs = ["-f"];
          #       subvolumes = {
          #         "@vault" = {
          #           mountpoint = "/vault";
          #           mountOptions = ["compress=zstd:9" "noatime" "discard=async"];
          #         };
          #       };
          #     };
          #   };
          # };
          Swap = {
            size = "100%";
            content = {
              type = "swap";
              randomEncryption = true;
              resumeDevice = true;
            };
          };
        };
      };
    };
    z = defineZfs (builtins.elemAt disks 0);
    x = defineZfs (builtins.elemAt disks 2);
  };
  zpool = {
    zroot = {
      type = "zpool";
      mode = {
        topology = {
          type = "topology";
          vdev = [
            {members = ["z"];}
            {members = ["x"];}
          ];
        };
      };
      rootFsOptions = {
        compression = "zstd-5";
        "com.sun:auto-snapshot" = "false";
        acltype = "posixacl";
        xattr = "sa";
        mountpoint = "none";
      };
      datasets = {
        # encrypted = {
        #   type = "zfs_fs";
        #   options = {
        #     mountpoint = "none";
        #     encryption = "aes-256-gcm";
        #     keyformat = "passphrase";
        #     keylocation = "file:///vault/secret.key";
        #   };
        # };
        "NixOS/root" = {
          type = "zfs_fs";
          mountpoint = "/";
          postCreateHook = "zfs snapshot zroot/NixOS/root@blank";
        };
        # No reason to back this up, it can be recreated
        "NixOS/nix" = {
          type = "zfs_fs";
          mountpoint = "/nix";
        };
        "NixOS/safe" = {
          type = "zfs_fs";
          options = {
            mountpoint = "none";
            "com.sun:auto-snapshot" = "true";
          };
        };
        "NixOS/safe/home" = {
          type = "zfs_fs";
          mountpoint = "/home";
        };
        "NixOS/safe/FinalFantasyXIV" = {
          type = "zfs_fs";
          mountpoint = "/.FFXIV";
        };
        "NixOS/safe/logs" = {
          type = "zfs_fs";
          mountpoint = "/var/logs";
        };
      };
    };
  };
}
