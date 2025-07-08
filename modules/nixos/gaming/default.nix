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
    ;
  inherit (lib.strings) toShellVars optionalString;
in {
  options.TM.gaming = {
    enable = mkEnableOption "Enable gaming specific configs";
    remotePlay = mkEnableOption "Enable settings for remote play";
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
        default = 100;
        inherit (options.zramSwap.memoryPercent) description;
      };
    };
    starCitizen = {
      enable =
        mkEnableOption "Enable Star Citizen"
        // {
          default = true;
        };
    };
  };

  config = mkIf cfg.enable {
    fonts.packages = [pkgs.wineWowPackages.fonts];
    nix-citizen.starCitizen = {
      inherit (cfg.starCitizen) enable;
      package = pkgs.star-citizen;
      umu.enable = false;
      disableEAC = false;
      preCommands = let
        vars = {
          DXVK_HUD = "compiler";
          MANGO_HUD = 1;
          NVPRESENT_ENABLE_SMOOTH_MOTION = 1;
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
        extraCompatPackages = with pkgs; [proton-ge-bin];
        protontricks.enable = true;
        platformOptimizations.enable = true;
      };
    };
    programs.wine.ntsync.enable = true;

    services = with pkgs; {
      xserver.modules = [xorg.xf86inputjoystick];
      udev = {
        packages = [game-devices-udev-rules];
      };
      scx = {
        enable = mkDefault true;
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
    # security.pam.loginLimits = [{
    #   domain = "*";
    #   type = "soft";
    #   item = "nofile";
    #   value = "16777216";
    # }];
    environment.systemPackages = [
      pkgs.lug-helper
      pkgs.mangohud
      pkgs.moonlight-qt
      pkgs.steam
      pkgs.gargoyle
      (pkgs.rsi-launcher.override (_: {
        extraLibs = config.hardware.graphics.extraPackages ++ [config.hardware.graphics.package];
        extraEnvVars = {
          DXVK_HUD = "compiler";
          MANGO_HUD = 1;
          DXVK_HDR =
            if config.TM.hasHDRDisplay
            then 1
            else 0;
          NVPRESENT_ENABLE_SMOOTH_MOTION = 1;
        };
      }))
      pkgs.teamspeak6-client
      pkgs.mumble
    ];

    boot = {
      kernelPackages = cfg.kernel;
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
