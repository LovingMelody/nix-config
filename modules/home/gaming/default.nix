{
  lib,
  config,
  osConfig ? {},
  pkgs,
  ...
}: let
  cfg = config.TM.gaming;
  nvidia = osConfig.TM.MyNextGPUWillNotBeNvidia or false;

  enableMangoHud =
    config.programs.mangohud.settings
    // {
      no_display = false;
    };
  inherit
    (lib)
    mkDefault
    mkEnableOption
    mkForce
    mkIf
    mkOption
    ;
in {
  imports = [./ffxiv];
  options.TM.gaming = {
    enable =
      mkEnableOption "Gaming modules"
      // {
        default = (osConfig.TM.gaming.enable or false) && config.home.username != "root";
      };
    dxvk-nvapi = {
      enable = mkEnableOption "Enable dxvk-nvapi only meant to be used on nixos" // {default = nvidia;};
      package = mkOption {
        type = lib.types.package;
        default = pkgs.dxvk-nvapi;
      };
      smartLink = mkEnableOption "Smartly link nvapi to wine & ~/Games" // {default = cfg.dxvk-nvapi.enable;};
    };
    prepareWinePrefix = {
      enable = mkEnableOption "Prepare Wine prefix for gaming" // {default = true;};
      package = mkOption {
        type = lib.types.package;
        default = pkgs.wineprefix-preparer-git;
      };
      paths = mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {default = "${config.home.homeDirectory}/.wine";};
        description = "Paths to prepare for gaming, defaults to $HOME/.wine";
      };
    };
  };
  config = mkIf cfg.enable {
    xdg.configFile."openvr/openvrpaths.vrpath" = mkIf ((osConfig.TM.vr.enable or false) && (osConfig.TM.vr.useWivrn or false)) {
      text = let
        steam = "${config.xdg.dataHome}/Steam";
      in
        builtins.toJSON {
          version = 1;
          jsonid = "vrpathreg";

          external_drivers = null;
          config = ["${steam}/config"];

          log = ["${steam}/logs"];

          "runtime" = [
            "${pkgs.xrizer}/lib/xrizer"
            # OR
            #"${pkgs.opencomposite}/lib/opencomposite"
          ];
        };
    };
    # TM.reshade.enable = true;
    programs.mangohud = {
      enable = true;
      enableSessionWide = mkDefault false; # Disabled since it's rendering on Gnome Shell
      settings = {
        alpha = mkForce 0.6;
        cpu_temp = true;
        gpu_temp = true;
        battery = true;
        background_alpha = mkForce 0.3;
        horizontal = true;
        hud_compact = true;
        hud_no_margin = true;
        no_display = mkDefault true;
        position = "top-center";
        horizontal_stretch = false;
        frame_timing = 0;
        time = true;
        time_no_label = true;
      };
      settingsPerApplication = {
        "wine-ffxiv_dx11" = enableMangoHud;
        "wine-StarCitizen" = enableMangoHud;
        "wine-Borderlands3" = enableMangoHud;
        "wine-TheFirstDescendant" = enableMangoHud;
        "wine-M1-Win64-Shipping" = enableMangoHud;
        "wine-BlackDesert64" = enableMangoHud;
        "wine-Overwatch" = enableMangoHud;
        "wine-Warframe" = enableMangoHud;
      };
    };
    xdg = {
      configFile = {
        "dxvk-nvapi/x32" = {
          inherit (cfg.dxvk-nvapi) enable;
          source = "${cfg.dxvk-nvapi.package}/x32";
        };
        "dxvk-nvapi/x64" = {
          inherit (cfg.dxvk-nvapi) enable;
          source = "${cfg.dxvk-nvapi.package}/x64";
        };
        "dxvk-nvapi/deps/nvngx.dll" = {
          inherit (cfg.dxvk-nvapi) enable;
          source = "${osConfig.hardware.nvidia.package}/lib/nvidia/wine/nvngx.dll";
        };
        "dxvk-nvapi/deps/_nvngx.dll" = {
          inherit (cfg.dxvk-nvapi) enable;
          source = "${osConfig.hardware.nvidia.package}/lib/nvidia/wine/_nvngx.dll";
        };
        "dxvk-nvapi/utils/smart-link.sh" = let
          nvngx = config.xdg.configFile."dxvk-nvapi/deps/nvngx.dll".source;
          _nvngx = config.xdg.configFile."dxvk-nvapi/deps/_nvngx.dll".source;
          smart-link =
            pkgs.writeShellScriptBin "smart-link.sh"
            ''
              #!/usr/bin/env bash
              link-files() {
                ${lib.getExe pkgs.findutils} ~/Games ~/.local/share/Steam/steamapps/compatdata -name "$1" -print0 |
                  while IFS= read -r -d "" line; do
                    rm -v "$line"
                    ln -sv "$2" "$line"
                  done
              }
              link-files 'nvngx.dll' '${nvngx}'
              link-files '_nvngx.dll' '${_nvngx}'
            '';
        in {
          enable = cfg.dxvk-nvapi.smartLink;
          executable = true;
          source = lib.getExe smart-link;
          # Update links with driver updates
          onChange = lib.getExe smart-link;
        };
      };
      dataFile."wine-astral".source = pkgs.wine-astral;
    };

    # TODO: Check if wineprefix is already running
    systemd.user.services = mkIf cfg.prepareWinePrefix.enable (lib.attrsets.mapAttrs' (name: value:
      lib.attrsets.nameValuePair ("update-wine-prefix-" + name) {
        Unit = {
          Description = "Update default wine prefix";
          requiresMountsFor = [value];
        };
        Service = {
          Type = "oneshot";
          RemainsAfterExit = false;
          ExecStart = lib.getExe (pkgs.writeShellScriptBin "update-wine-prefix" ''
            # This will check if the wine server is currently running
            wineserver -k20 || ${lib.getExe cfg.prepareWinePrefix.package}
          '');

          Environment = [
            ''WINEPREFIX=${value}''
            ''PATH="${lib.strings.makeBinPath [pkgs.wine-astral cfg.prepareWinePrefix.package]}:$PATH"''
          ];
        };
      })
    cfg.prepareWinePrefix.paths);
  };
}
