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
  pins = lib.TM.package-helper.pinsFor pkgs;

  # Laptop: bump the platform profile while a game runs (Performance on AC,
  # Balanced on battery) and restore whatever was active afterwards.
  # gamemode 1.8 can't drive platform_profile itself, and the custom scripts
  # run as the user, so this goes through asusd / power-profiles-daemon.
  useAsusd = config.services.asusd.enable;
  usePpd = config.services.power-profiles-daemon.enable;
  gamemodeLaptopScripts = let
    runtimeInputs =
      [pkgs.coreutils pkgs.gnused pkgs.libnotify]
      ++ optional useAsusd pkgs.asusctl
      ++ optional usePpd pkgs.power-profiles-daemon;
    common = ''
      state="''${XDG_RUNTIME_DIR:-/tmp}/gamemode-laptop-profile"
      on_ac() {
        for ps in /sys/class/power_supply/*; do
          if [ "$(cat "$ps/type" 2>/dev/null)" = Mains ] && [ "$(cat "$ps/online" 2>/dev/null)" = 1 ]; then
            return 0
          fi
        done
        return 1
      }
    '';
  in {
    start = pkgs.writeShellApplication {
      name = "gamemode-laptop-start";
      inherit runtimeInputs;
      text =
        common
        + (
          if useAsusd
          then ''
            asusctl profile get | sed -n 's/^Active profile: //p' > "$state" || true
            if on_ac; then target=Performance; else target=Balanced; fi
            asusctl profile set "$target" || true
          ''
          else if usePpd
          then ''
            powerprofilesctl get > "$state" || true
            if on_ac; then target=performance; else target=balanced; fi
            powerprofilesctl set "$target" || true
          ''
          else ''
            target="governor only"
          ''
        )
        + ''
          if on_ac; then power=AC; else power=battery; fi
          notify-send -a GameMode -i applications-games "GameMode on" "$power — $target" || true
        '';
    };
    end = pkgs.writeShellApplication {
      name = "gamemode-laptop-end";
      inherit runtimeInputs;
      text =
        common
        + (
          if useAsusd || usePpd
          then ''
            if [ -s "$state" ]; then
              ${
              if useAsusd
              then ''asusctl profile set "$(cat "$state")" || true''
              else ''powerprofilesctl set "$(cat "$state")" || true''
            }
              rm -f "$state"
            fi
          ''
          else ""
        )
        + ''
          notify-send -a GameMode -i applications-games "GameMode off" || true
        '';
    };
  };
in {
  options.TM.gaming = {
    enable = mkEnableOption "Enable gaming specific configs";
    remotePlay = mkEnableOption "Enable settings for remote play" // {default = true;};
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
      moonlight-qt.enable = true;
      gamemode = {
        enable = mkDefault config.TM.isLaptop;
        settings = {
          general = {
            softrealtime = mkDefault "auto";
            # >10 risks starving pipewire / the compositor under load
            renice = mkDefault 10;
            ioprio = mkDefault 0;
            inhibit_screensaver = mkDefault 1;
            desiredgov = mkDefault "performance";
            disable_splitlock = mkDefault 1;
          };
          custom = mkIf config.TM.isLaptop {
            start = "${gamemodeLaptopScripts.start}/bin/gamemode-laptop-start";
            end = "${gamemodeLaptopScripts.end}/bin/gamemode-laptop-end";
            script_timeout = 10;
          };
        };
      };
      gamescope = {
        enable = true;
        capSysNice = false;
      };
      steam = {
        enable = true;
        remotePlay.openFirewall = cfg.remotePlay;
        extraCompatPackages = with pkgs; [proton-ge-bin dw-proton-bin proton-cachyos-bin];
        extraPackages = with pkgs; [lsfg-vk lsfg-vk-ui umu-launcher mangohud];
        protontricks.enable = true;
        platformOptimizations.enable = true;
        extest.enable = mkDefault true;
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
      sunshine = {
        enable = cfg.remotePlay;
        capSysAdmin = mkDefault true;
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
          heroic
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
