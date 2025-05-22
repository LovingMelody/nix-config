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
  };
  config = mkIf cfg.enable {
    # TM.reshade.enable = true;
    programs.mangohud = {
      enable = true;
      enableSessionWide = mkDefault true;
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
    xdg.configFile = {
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
  };
}
