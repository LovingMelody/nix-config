{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.TM.gaming;
  inherit
    (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    types
    optional
    versions
    ;
  inherit (lib.TM.package-helper) pins;
in {
  options.TM.gaming = {
    enable = mkEnableOption "Enable gaming specific configs";
    remotePlay = mkEnableOption "Enable settings for remote play";
    cachyPatches = mkEnableOption "Enable CachyOS Patches";
    kernel = mkOption {
      type = types.raw;
      default = pkgs.linuxPackages_latest;
      description = "Set kernel";
    };
    rsiLauncher = {
      enable =
        mkEnableOption "Enable RSI Launcher"
        // {
          default = true;
        };
    };
  };

  config = mkIf cfg.enable {
    fonts.packages = [pkgs.wineWow64Packages.fonts];
    environment.sessionVariables = {
      DXVK_HDR =
        if config.TM.hasHDRDisplay
        then 1
        else 0;
      DXVK_HUD = mkDefault "compiler";
    };
    programs.rsi-launcher = {
      inherit (cfg.rsiLauncher) enable;
      package = pkgs.rsi-launcher-git;
      preCommands = "export MANGOHUD=1";
      umu.enable = false;
      disableEAC = false;
      patchXwayland = false;
      enforceWaylandDrv = true;
    };
    programs = {
      wavey-launcher.enable = true;
      gamemode = {
        enable = mkDefault config.TM.isLaptop;
        settings = {
          general = {
            softrealtime = "auto";
            renice = 15;
          };
        };
      };
      gamescope = {
        enable = true;
        capSysNice = false;
      };
      steam = {
        enable = true;
        remotePlay.openFirewall = true;
        extraCompatPackages = with pkgs; [proton-ge-bin dw-proton-bin proton-em-bin proton-cachyos-bin];
        extraPackages = with pkgs; [lsfg-vk lsfg-vk-ui umu-launcher mangohud];
        protontricks.enable = true;
        platformOptimizations.enable = true;
      };
      wine = {
        ntsync = lib.versionAtLeast config.boot.kernelPackages.kernel.version "6.14";
        enable = true;
        package = mkDefault pkgs.wine-astral;
        binfmt = true;
      };
    };

    services = with pkgs; {
      xserver.modules = [xf86-input-joystick];
      udev = {
        packages = [game-devices-udev-rules];
      };
      bpftune.enable = mkDefault true;
      ananicy = {
        enable = mkDefault (! config.programs.gamemode.enable);
        package = pkgs.ananicy-cpp;

        rulesProvider = pkgs.ananicy-rules-cachyos;
      };
    };
    nix.settings = let
      substituters = [
        "https://nix-gaming.cachix.org"
        "https://nix-citizen.cachix.org"
      ];
      trusted-public-keys = [
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
        "nix-citizen.cachix.org-1:lPMkWc2X8XD4/7YPEEwXKKBg+SVbYTVrAaLA2wQTKCo="
      ];
    in {
      inherit substituters trusted-public-keys;
      trusted-substituters = substituters;
      extra-trusted-public-keys = trusted-public-keys;
    };

    # # StarCitizen requirements
    # boot.kernel.sysctl = {
    #   "vm.max_map_count" = 16777216;
    #   "fs.file-max" = 524288;
    # };
    security.pam.loginLimits = [
      {
        domain = "*";
        type = "soft";
        item = "memlock";
        value = "unlimited";
      }
      {
        domain = "*";
        type = "hard";
        item = "memlock";
        value = "unlimited";
      }
    ];
    environment = {
      etc."vulkan/implicit_layer.d/VkLayer_LS_frame_generation.json".source = "${pkgs.lsfg-vk}/share/vulkan/implicit_layer.d/VkLayer_LS_frame_generation.json";
      systemPackages =
        [
          (pkgs.makeAutostartItem {
            name = "steam";
            inherit (config.programs.steam) package;
          })
          config.programs.steam.package
        ]
        ++ (with pkgs; [
          bs-manager
          r2modman
          lsfg-vk
          lsfg-vk-ui

          lug-helper
          mangohud
          gargoyle
          teamspeak6-client
          mumble
          umu-launcher
          faugus-launcher
          protonplus
          low-latency-layer
        ]);
    };

    boot = {
      kernelPackages = cfg.kernel;
      kernelPatches =
        optional cfg.cachyPatches
        {
          name = "0001-cachyos-base-all";
          patch = "${pins.cachy-kernel-patches}/${versions.majorMinor config.boot.kernelPackages.kernel.version}/all/0001-cachyos-base-all.patch";
        };
    };

    hardware = {
      graphics = {
        enable = true;
        enable32Bit = true;
      };
      steam-hardware.enable = true; # Provides udev rules for controller, HTC vive, and Valve Index
    };

    TM.sound.enable = true;
  };
}
