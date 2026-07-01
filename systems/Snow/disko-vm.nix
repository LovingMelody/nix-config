{
  disks ? ["disk/by-label/nixos"],
  secretFile ? "/secret.key",
  ...
}: {
  disk.vm = {
    type = "disk";
    device = "/dev/${builtins.elemAt disks 0}";
    content = {
      type = "gpt";
      partitions = {
        system = {
          size = "100%";
          content = {
            type = "mdraid";
            name = "system";
          };
        };
      };
    };
  };
  mdadm = {
    system = {
      type = "mdadm";
      level = 1;
      content = {
        type = "gpt";
        partitions = {
          primary = {
            size = "100%";
            content = {
              type = "luks";
              name = "crypted";
              settings.allowDiscards = true;
              passwordFile = secretFile;
              content = {
                type = "zfs";
                pool = "zroot";
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
      rootFsOptions = {
        compression = "zstd-5";
        "com.sun:auto-snapshot" = "false";
      };
      datasets = {
        "NixOS/root" = {
          type = "zfs_fs";
          mountpoint = "/";
          postCreateHook = "zfs snapshot zroot/NixOS/root@blank";
        };
        "NixOS/persist" = {
          type = "zfs_fs";
          mountpoint = "/.persist";
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
      };
    };
  };
}
