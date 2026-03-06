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
              pkgs.gitFull
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
              pkgs.nyaa
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
              insertNameservers = [
                "1.1.1.1"
                "1.0.0.1"
                "2606:4700:4700::1111"
                "2606:4700:4700::1001"
                "9.9.9.9"
                "149.112.112.112"
                "2620:fe::fe"
                "2620:fe::9"
              ];
              wifi.powersave = mkDefault config.TM.isLaptop;
              settings = {
                connection-wifi = {
                  match-device = "type:wifi";
                  "ipv4.route-metric" = 50;
                  "ipv6.route-metric" = 25;
                };
              };
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
            settings.Resolve.DNSOverTLS = mkDefault "opportunistic";
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
            cudaSupport = config.TM.MyNextGPUWillNotBeNvidia or false;
          };
          overlays =
            nixpkgs-overlays
            ++ [
              (final: prev: {
                umu-launcher = prev.umu-launcher.override {
                  steam = config.programs.steam.package;
                };
                steam-run = config.programs.steam.package.run;
                steam-run-free =
                  if config.nixpkgs.config.allowUnfree
                  then final.steam-run
                  else config.programs.steam.package.run-free;
              })
            ];
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
          sops.secrets."wifi.env" = {
            sopsFile = TM.get-secret-file "wifi.env";
            format = "dotenv";
            owner = "root";
            mode = "0400";
          };
          networking.networkmanager.ensureProfiles = {
            environmentFiles = [config.sops.secrets."wifi.env".path];
            profiles = {
              Mothers-Home = {
                connection = {
                  id = "Mothers-Home";
                  type = "wifi";
                };
                ipv4 = {
                  method = "auto";
                };
                ipv6 = {
                  addr-gen-mode = "default";
                  method = "auto";
                };
                proxy = {};
                wifi = {
                  mode = "infrastructure";
                  ssid = "$WIFI_MOM_SSID";
                };
                wifi-security = {
                  key-mgmt = "sae";
                  psk = "$WIFI_MOM_PSK";
                };
              };
              Home-5G = {
                connection = {
                  id = "Home-5G";
                  type = "wifi";
                  autoconnect-priority = "2";
                };
                ipv4 = {
                  method = "auto";
                };
                ipv6 = {
                  addr-gen-mode = "default";
                  method = "auto";
                };
                proxy = {};
                wifi = {
                  mode = "infrastructure";
                  ssid = "$WIFI_HOME_B_SSID";
                };
                wifi-security = {
                  auth-alg = "open";
                  key-mgmt = "wpa-psk";
                  psk = "$WIFI_HOME_B_PSK";
                };
              };
              Home-MLO = {
                connection = {
                  autoconnect-priority = "99";
                  autoconnect =
                    if config.TM.hasWifi7
                    then "true"
                    else "false";
                  id = "Home-MLO";
                  type = "wifi";
                };
                ipv4 = {
                  method = "auto";
                };
                ipv6 = {
                  addr-gen-mode = "stable-privacy";
                  method = "auto";
                };
                proxy = {};
                wifi = {
                  mode = "infrastructure";
                  ssid = "$WIFI_HOME_D_SSID";
                };
                wifi-security = {
                  key-mgmt = "sae";
                  psk = "$WIFI_HOME_D_PSK";
                };
              };
              Home = {
                connection = {
                  id = "Home";
                  type = "wifi";
                  autoconnect = "true";
                  "autoconnect-priority" = "98";
                };
                wifi = {
                  ssid = "$WIFI_HOME_C_SSID";
                  mode = "infrastructure";
                  hidden = "false";
                };
                "wifi-security" = {
                  "key-mgmt" = "wpa-psk";
                  psk = "$WIFI_HOME_C_PSK";
                };
                ipv4.method = "auto";
                ipv6.method = "auto";
              };
              Home_Legacy = {
                connection = {
                  id = "Home - Legacy";
                  type = "wifi";
                  autoconnect = "true";
                  "autoconnect-priority" = "50";
                  # "interface-name" = "wlan0";     # uncomment to pin a NIC
                };
                wifi = {
                  ssid = "$WIFI_HOME_A_SSID";
                  mode = "infrastructure";
                  hidden = "false";
                };
                "wifi-security" = {
                  "key-mgmt" = "wpa-psk";
                  psk = "$WIFI_HOME_A_PSK";
                };
                ipv4.method = "auto";
                ipv6.method = "auto";
              };
              Home_Fallback = {
                connection = {
                  id = "Home - Fallback";
                  type = "wifi";
                  autoconnect = "true";
                  "autoconnect-priority" = "80"; # prefer Home
                  # "interface-name" = "wlan0";     # uncomment to pin a NIC
                };
                wifi = {
                  ssid = "$WIFI_HOME_A_SSID";
                  mode = "infrastructure";
                  hidden = "false";
                };
                "wifi-security" = {
                  "key-mgmt" = "wpa-psk";
                  psk = "$WIFI_HOME_A_PSK";
                };
                ipv4.method = "auto";
                ipv6.method = "auto";
              };
              Hotspot_A = {
                connection = {
                  id = "HotspotA";
                  type = "wifi";
                  autoconnect = "true";
                  "autoconnect-priority" = "30";
                };
                wifi = {
                  ssid = "$WIFI_HOTSPOT_A_SSID";
                  mode = "infrastructure";
                  hidden = "false";
                };
                "wifi-security" = {
                  "key-mgmt" = "wpa-psk";
                  psk = "$WIFI_HOTSPOT_A_PSK";
                };
                ipv4.method = "auto";
                ipv6.method = "auto";
              };
              Hotspot_B = {
                connection = {
                  id = "HotspotB";
                  type = "wifi";
                  autoconnect = "true";
                  "autoconnect-priority" = "20";
                };
                wifi = {
                  ssid = "$WIFI_HOTSPOT_B_SSID";
                  mode = "infrastructure";
                  hidden = "false";
                };
                "wifi-security" = {
                  "key-mgmt" = "wpa-psk";
                  psk = "$WIFI_HOTSPOT_B_PSK";
                };
                ipv4.method = "auto";
                ipv6.method = "auto";
              };
            };
          };
        })
    ];
  }
