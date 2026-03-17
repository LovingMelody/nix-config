{disks ? ["/dev/nvme0n1"], ...}: {
  disk = {
    main = {
      type = "disk";
      device = builtins.elemAt disks 0;
      content = {
        type = "gpt";
        partitions = {
          EFI = {
            size = "8G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          root = {
            end = "-64G";
            content = {
              type = "luks";
              name = "crypted";
              settings = {
                allowDiscards = true;
              };
              content = {
                type = "btrfs";
                extraArgs = ["-f"];
                mountpoint = "/";
                mountOptions = [
                  "compress=zstd"
                  "compress-force"
                ];

                subvolumes = {
                  "@root" = {
                    mountpoint = "/";
                    mountOptions = [
                      "compress=zstd"
                      "compress-force"
                    ];
                  };
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = [
                      "compress=zstd"
                      "compress-force"
                    ];
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress=zstd"
                      "compress-force"
                      "noatime"
                    ];
                  };
                  "@persist" = {
                    mountpoint = "/.persist";
                    eountOptions = [
                      "compress=zstd"
                      "compress-force"
                    ];
                  };
                  "@var-logs" = {
                    mountpoint = "/var/logs";
                  };
                  "@ffxiv-MareSync" = {
                    mountpoint = "/home/melody/ffxiv-extras/Mare";
                    mountOptions = [
                      "compress=zstd"
                      "compress-force"
                    ];
                  };
                  "@ffxiv-Penumbra" = {
                    mountpoint = "/home/melody/ffxiv-extras/Penumbra";
                    mountOptions = [
                      "compress=zstd"
                      "compress-force"
                    ];
                  };
                  "@ffxiv-xlcore" = {
                    mountpoint = "/home/melody/.xlcore";
                    mountOptions = [
                      "compress=zstd"
                      "compress-force"
                    ];
                  };
                };
              };
            };
          };
          swap = {
            size = "64G";
            content = {
              type = "swap";
              randomEncryption = true;
              resumeDevice = true;
            };
          };
        };
      };
    };
  };
}
