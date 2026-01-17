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
    options
    types
    optional
    versions
    ;
  inherit (lib.strings) toShellVars optionalString;
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
    zram = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable ZRam - Star citizen needs it <40G";
      };
      memoryPercent = mkOption {
        type = types.int;
        default = 30;
        inherit (options.zramSwap.memoryPercent) description;
      };
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
    fonts.packages = [pkgs.wineWowPackages.fonts];
    programs.rsi-launcher = {
      inherit (cfg.rsiLauncher) enable;
      package = pkgs.rsi-launcher-git;
      umu.enable = false;
      disableEAC = false;
      preCommands = let
        vars = {
          DXVK_HUD = "compiler";
          MANGO_HUD = 1;
          PROTON_ENABLE_NGX_UPDATER = "1";
          DXVK_NVAPI_DRS_NGX_DLSS_SR_OVERRIDE = "on";
          DXVK_NVAPI_DRS_NGX_DLSS_RR_OVERRIDE = "on";
          DXVK_NVAPI_DRS_NGX_DLSS_FG_OVERRIDE = "on";
          DXVK_NVAPI_DRS_NGX_DLSS_SR_OVERRIDE_RENDER_PRESET_SELECTION = "render_preset_latest";
          # NVPRESENT_ENABLE_SMOOTH_MOTION = 1;
        };
        hdrVars =
          optionalString config.TM.hasHDRDisplay
          ''
            export DXVK_HDR=1
          '';
      in ''
        ${toShellVars vars}
        ${hdrVars}
      '';
      patchXwayland = false;
      enforceWaylandDrv = true;
    };
    zramSwap = {
      inherit (cfg.zram) enable memoryPercent;
    };
    programs = {
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
        extraCompatPackages = with pkgs; [proton-ge-bin umu-launcher];
        extraPackages = with pkgs; [lsfg-vk lsfg-vk-ui umu-launcher mangohud];
        protontricks.enable = true;
        platformOptimizations.enable = true;
      };
    };
    programs.wine = {
      ntsync = lib.versionAtLeast config.boot.kernelPackages.kernel.version "6.14";
      enable = true;
      package = mkDefault pkgs.wine-astral;
      binfmt = true;
    };

    services = with pkgs; {
      xserver.modules = [xorg.xf86inputjoystick];
      udev = {
        packages = [game-devices-udev-rules];
      };
      scx = {
        enable = mkDefault false;
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
      systemPackages = [
        pkgs.bs-manager
        pkgs.r2modman
        pkgs.lsfg-vk
        pkgs.lsfg-vk-ui

        (pkgs.makeAutostartItem {
          name = "steam";
          inherit (config.programs.steam) package;
        })
        pkgs.lug-helper
        pkgs.mangohud
        config.programs.steam.package
        pkgs.gargoyle
        pkgs.teamspeak6-client
        pkgs.mumble
        pkgs.umu-launcher
      ];
    };

    boot = {
      kernelPackages = cfg.kernel;
      kernelPatches = optional cfg.cachyPatches [
        {
          name = "0001-cachyos-base-all";
          patch = "${pins.cachy-kernel-patches}/${versions.majorMinor config.boot.kernelPackages.kernel.version}/all/0001-cachyos-base-all.patch";
        }
      ];
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
