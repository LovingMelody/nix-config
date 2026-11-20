{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.TM.nvidia;
  # With PRIME offload the iGPU drives the display; forcing these globally would
  # put the whole session (and all VA-API/GLX clients) on the dGPU.
  primeOffload = config.hardware.nvidia.prime.offload.enable;
  inherit (lib) mkDefault mkEnableOption mkIf mkRenamedOptionModule;
in {
  imports = [(mkRenamedOptionModule ["TM" "MyNextGPUWillNotBeNvidia"] ["TM" "nvidia" "enable"])];

  options.TM.nvidia.enable = mkEnableOption "NVIDIA driver, Wayland and Proton/DLSS integration";

  config = mkIf cfg.enable {
    boot.blacklistedKernelModules = ["nova_core" "nova_drm" "nouveau"];
    services.xserver.videoDrivers = mkDefault ["nvidia"];
    environment = {
      sessionVariables = {
        LIBVA_DRIVER_NAME = mkIf (!primeOffload) (mkDefault "nvidia");
        # May crash firefox
        GBM_BACKEND = mkIf (!primeOffload) (mkDefault "nvidia-drm");
        # May break screensharing / Discord
        __GLX_VENDOR_LIBRARY_NAME = mkIf (!primeOffload) (mkDefault "nvidia");
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
