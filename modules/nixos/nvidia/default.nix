{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.TM.MyNextGPUWillNotBeNvidia;
  inherit (lib) mkDefault mkEnableOption mkIf;
in {
  options.TM.MyNextGPUWillNotBeNvidia = mkEnableOption "Fix nvidia nonsense";

  config = mkIf cfg {
    boot.blacklistedKernelModules = ["nova_core" "nova_drm" "nouveau"];
    services.xserver.videoDrivers = mkDefault ["nvidia"];
    environment = {
      sessionVariables = {
        LIBVA_DRIVER_NAME = mkDefault "nvidia";
        # May crash firefox
        GBM_BACKEND = mkDefault "nvidia-drm";
        # May break screensharing / Discord
        __GLX_VENDOR_LIBRARY_NAME = mkDefault "nvidia";
        # Unsure what this has the potential to break tbh
        NIXOS_OZONE_WL = mkDefault "1";
        ELECTRON_OZONE_PLATFORM_HINT = mkDefault "auto";
        NVIDIA_WINE_DLL_DIR = "${config.hardware.nvidia.package}/lib/nvidia/wine/";
        XL_NVNGXPATH = "${config.hardware.nvidia.package}/lib/nvidia/wine/";
        PROTON_ENABLE_NGX_UPDATER = "1";
        DXVK_NVAPI_DRS_NGX_DLSS_SR_OVERRIDE = "on";
        DXVK_NVAPI_DRS_NGX_DLSS_RR_OVERRIDE = "on";
        DXVK_NVAPI_DRS_NGX_DLSS_FG_OVERRIDE = "on";
        DXVK_NVAPI_DRS_NGX_DLSS_SR_OVERRIDE_RENDER_PRESET_SELECTION = "render_preset_latest";
      };

      systemPackages = [pkgs.dxvk-nvapi-vkreflex-layer-git];
    };
    hardware = {
      nvidia = {
        branch = "bleeding_edge";
        modesetting.enable = mkDefault true;
        nvidiaSettings = mkDefault true;
        powerManagement.enable = mkDefault true;
        open = true;
        gsp.enable = true;
        dynamicBoost.enable = mkDefault config.TM.isLaptop;
        nvidiaPersistenced = mkDefault config.TM.isServer;
      };
      nvidia-container-toolkit.enable = mkDefault (
        config.virtualisation.docker.enable || config.virtualisation.podman.enable
      );
    };
  };
}
