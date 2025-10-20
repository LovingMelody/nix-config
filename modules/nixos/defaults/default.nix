{
  config,
  lib,
  inputs,
  pkgs,
  format,
  nixpkgs-overlays,
  ...
}: let
  cfg = config.TM.defaults;
  inherit
    (lib)
    TM
    mkDefault
    mkMerge
    mkIf
    optional
    ;
  inherit (config.TM) isServer;
in
  # hostInfo = lib.TM.info.allHostInfo (inputs.self);
  {
    imports = [(TM.get-shared-module "defaults")];
    config = mkMerge [
      (mkIf cfg.enable {
        home-manager.backupFileExtension = mkDefault "home-backup";
        # Feature isn't stable yet:
        # system.etc.overlay.enable = mkDefault config.boot.initrd.systemd.enable ;
        boot = {
          initrd.systemd = {
            suppressedUnits = lib.mkIf config.systemd.enableEmergencyMode [
              "emergency.service"
              "emergency.target"
            ];
            enable = mkDefault (format != "iso");
          };
          supportedFilesystems = [
            "ntfs"
            "btrfs"
          ];
          blacklistedKernelModules = [
            # Obscure network protocols
            "ax25"
            "netrom"
            "rose"
            # Old or rare or insufficiently audited filesystems
            "adfs"
            "affs"
            "bfs"
            "befs"
            "cramfs"
            "efs"
            "erofs"
            "exofs"
            "freevxfs"
            "f2fs"
            "vivid"
            "gfs2"
            "ksmbd"
            "cifs"
            "cramfs"
            "freevxfs"
            "jffs2"
            "hfs"
            "hfsplus"
            "udf"
            "hpfs"
            "jfs"
            "minix"
            "nilfs2"
            "omfs"
            "qnx4"
            "qnx6"
            "sysv"
          ];
        };
        xdg = {
          autostart.enable = mkDefault config.TM.isGui;
          icons.enable = mkDefault config.TM.isGui;
          menus.enable = mkDefault config.TM.isGui;
          mime.enable = mkDefault config.TM.isGui;
          sounds.enable = mkDefault config.TM.isGui;
        };
        # GIT is needed for flakes
        environment = {
          # stub-ld.enable = mkDefault (!config.TM.isServer);
          variables = mkIf config.TM.isServer {
            BROWSER = mkDefault "echo";
          };
          systemPackages =
            [
              pkgs.nix-tree
              pkgs.btop
              pkgs.comma
              pkgs.file
              pkgs.git
              pkgs.htop
              pkgs.imagemagickBig
              # pkgs.kitty.terminfo
              pkgs.nh
              pkgs.ripgrep
              pkgs.rsync
              pkgs.vim
              pkgs.fselect
              pkgs.jq
              pkgs.yq-go
              pkgs.nix-output-monitor
              pkgs.restic
              pkgs.rclone
              pkgs.unique-basenames
              pkgs.unzip
              pkgs.lazygit
            ]
            ++ optional config.TM.isGui pkgs.ffmpeg_8-full
            ++ optional (!config.TM.isGui) pkgs.ffmpeg_8-headless;
          etc.FLAKE_CURRENT_COMMIT = {
            text = "${config.system.configurationRevision}";
          };
          pathsToLink =
            ["/share/zsh" "/share/fish"]
            ++ lib.optionals config.TM.isGui [
              "/share/xdg-desktop-portal"
              "/share/applications"
            ];
        };
        system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev;
        fonts = {
          fontDir.decompressFonts = mkDefault true;
          enableDefaultPackages = config.TM.isGui;
          fontconfig.enable = config.TM.isGui;
          packages = optional config.TM.isGui pkgs.corefonts;
        };

        programs = {
          zsh = {
            enable = mkDefault true;
            autosuggestions.enable = mkDefault true;
            syntaxHighlighting.enable = mkDefault true;
          };
          nh = {
            enable = mkDefault true;
            clean = {
              enable = mkDefault true;
              extraArgs = mkDefault "--keep-since 30d --keep 30";
            };
          };
          starship = {
            enable = mkDefault true;
            settings = {
              add_newline = mkDefault false;
              battery = mkDefault {
                full_symbol = "🔋";
                charging_symbol = "⚡️";
                discharging_symbol = "💀";
                display = [
                  {
                    threshold = 10;
                    style = "bold red";
                  }
                  {
                    threshold = 30;
                    style = "bold yellow";
                  }
                ];
              };
              username = {
                show_always = mkDefault true;
                style_user = mkDefault "bold pink";
                style_root = mkDefault "bold red";
              };
              directory = {
                substitutions = {
                  "Documents" = "󰈙 ";
                  "Downloads" = " ";
                  "Music" = " ";
                  "Pictures" = " ";
                };
              };
            };
          };
        };
        networking =
          {
            networkmanager.enable = mkDefault true;
          }
          // (mkIf config.networking.networkmanager.enable {
            nameservers = mkDefault (
              if config.services.resolved.enable
              then [
                "1.1.1.1#one.one.one.one"
                "9.9.9.9#dns.quad9.net"
              ]
              else [
                "1.1.1.1"
                "9.9.9.9"
              ]
            );
            networkmanager = {
              dns = mkDefault (
                if config.services.resolved.enable
                then "systemd-resolved"
                else "default"
              );
              wifi.powersave = mkDefault config.TM.isLaptop;
            };
          });

        systemd = {
          enableEmergencyMode = !config.TM.isServer;
          services.NetworkManager-wait-online.serviceConfig.ExecStart = mkDefault [
            ""
            "${lib.getExe' pkgs.networkmanager "nm-online"} -q"
          ];
        };
        services = {
          # Enable flatpk by default if xdg portal is enabled
          # Allows running things that nix wont run easily
          flatpak.enable = mkDefault config.xdg.portal.enable;
          resolved = {
            enable = mkDefault true;
            dnsovertls = mkDefault "opportunistic";
          };
          upower.enable = mkDefault true;
          openssh = mkDefault {
            enable = true;
            settings = {
              X11Forwarding = false;
              KexAlgorithms = [
                "curve25519-sha256"
                "curve25519-sha256@libssh.org"
                "diffie-hellman-group16-sha512"
                "diffie-hellman-group18-sha512"
                "sntrup761x25519-sha512@openssh.com"
              ];
              passwordAuthentication = false;
              UseDns = true;
            };
          };
          geoclue2 = {
            geoProviderUrl = mkDefault "https://beacondb.net/v1/geolocate";
            submissionUrl = mkDefault "https://beacondb.net/v2/geosubmit";
            submissionNick = mkDefault "geoclue";
          };
        };
        nixpkgs = {
          config = {
            allowUnfree = true;
            cudaSupport = config.TM.MyNextGPUWillNotBeNvidia;
          };
          overlays = nixpkgs-overlays;
        };
        nix = {
          daemonIOSchedClass = mkDefault (
            if isServer
            then "best-effort"
            else "idle"
          );
          settings = {
            trusted-users = [
              "builder"
              "root"
              "@wheel"
              "melody"
            ];
          };
          # buildMachines = let
          #   snow = hostInfo.Snow;
          #   vulpix = hostInfo.Vulpix;
          # in [
          #   {
          #     inherit (snow) hostName;Gg
          #     systems = [ snow.platform ] ++ snow.extra-platforms;
          #     supportedFeatures = snow.features;
          #     maxJobs = 4;
          #     speedFactor = 8;
          #     sshUser = "builder";
          #   }
          #   {
          #     inherit (vulpix) hostName;
          #     systems = [ vulpix.platform ] ++ vulpix.extra-platforms;
          #     supportedFeatures = vulpix.features;
          #     maxJobs = 4;
          #     speedFactor = 2;
          #     sshUser = "builder";
          #   }
          # ];
          # gc = {
          #   automatic = mkDefault true;
          #   options = mkDefault "--delete-older-than 30d";
          # };
        };
      })
      (mkIf
        config.TM.knowsHiddenMove {
          sops.secrets."Networking/Wireless/Home/ssid" = {
            sopsFile = TM.get-secret-file "generic.yaml";
            key = "Networking.Wireless.Home.ssid";
            format = "yaml";
          };
          sops.secrets."Networking/Wireless/Home/pass" = {
            sopsFile = TM.get-secret-file "generic.yaml";
            key = "Networking.Wireless.Home.pass";
            format = "yaml";
          };
          sops.secrets."Networking/Wireless/MothersHome/ssid" = {
            sopsFile = TM.get-secret-file "generic.yaml";
            key = "Networking.Wireless.MothersHome.ssid";
            format = "yaml";
          };
          sops.secrets."Networking/Wireless/MothersHome/pass" = {
            sopsFile = TM.get-secret-file "generic.yaml";
            key = "Networking.Wireless.MothersHome.pass";
            format = "yaml";
          };
          sops.templates."wifi.env" = {
            content = ''
              WIFI_HOME_SSID=${config.sops.placeholder."Networking/Wireless/Home/ssid"}
              WIFI_HOME_PSK=${config.sops.placeholder."Networking/Wireless/Home/pass"}
              WIFI_MOM_SSID=${config.sops.placeholder."Networking/Wireless/MothersHome/ssid"}
              WIFI_MOM_PSK=${config.sops.placeholder."Networking/Wireless/MothersHome/pass"}
            '';
            owner = "root";
            mode = "0400";
          };
          networking.networkmanager.ensureProfiles = {
            environmentFiles = [config.sops.templates."wifi.env".path];
            profiles = {
              Home = {
                connection = {
                  id = "Home";
                  type = "wifi";
                  autoconnect = "true";
                  "autoconnect-priority" = "100"; # prefer Home
                  # "interface-name" = "wlan0";     # uncomment to pin a NIC
                };
                wifi = {
                  ssid = "$WIFI_HOME_SSID";
                  mode = "infrastructure";
                  hidden = "false";
                };
                "wifi-security" = {
                  "key-mgmt" = "wpa-psk";
                  psk = "$WIFI_HOME_PSK";
                };
                ipv4.method = "auto";
                ipv6.method = "auto";
              };

              MothersHome = {
                connection = {
                  id = "MothersHome";
                  type = "wifi";
                  autoconnect = "true";
                  "autoconnect-priority" = "50";
                };
                wifi = {
                  ssid = "$WIFI_MOM_SSID";
                  mode = "infrastructure";
                  hidden = "false";
                };
                "wifi-security" = {
                  "key-mgmt" = "wpa-psk";
                  psk = "$WIFI_MOM_PSK";
                };
                ipv4.method = "auto";
                ipv6.method = "auto";
              };
            };
          };
        })
    ];
  }
