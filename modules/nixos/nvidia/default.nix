{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.TM.MyNextGPUWillNotBeNvidia;
  inherit (lib) mkDefault mkEnableOption mkIf;
  inherit (lib.TM.package-helper) patchLibcuda;
in {
  options.TM.MyNextGPUWillNotBeNvidia = mkEnableOption "Fix nvidia nonsense";

  config = mkIf cfg {
    services.xserver.videoDrivers = mkDefault ["nvidia"];
    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = mkDefault "nvidia";
      # May crash firefox
      GBM_BACKEND = mkDefault "nvidia-drm";
      # May break screensharing / Discord
      __GLX_VENDOR_LIBRARY_NAME = mkDefault "nvidia";
      # Unsure what this has the potential to break tbh
      NIXOS_OZONE_WL = mkDefault "1";
      ELECTRON_OZONE_PLATFORM_HINT = mkDefault "auto";
      NVIDIA_WINE_DLL_DIR = "${config.hardware.nvidia.package}/lib/nvidia/wine/";
    };
    hardware = {
      nvidia = {
        package = mkDefault (patchLibcuda (
          if lib.versionAtLeast "575.07.08" config.boot.kernelPackages.nvidiaPackages.beta.version
          then builtins.trace "Uneeded mkDriver in modules/nixos/nvidia/default.nix" config.boot.kernelPackages.nvidiaPackages.beta
          else
            config.boot.kernelPackages.nvidiaPackages.mkDriver {
              version = "575.57.08";
              sha256_64bit = "sha256-KqcB2sGAp7IKbleMzNkB3tjUTlfWBYDwj50o3R//xvI=";
              sha256_aarch64 = "sha256-VJ5z5PdAL2YnXuZltuOirl179XKWt0O4JNcT8gUgO98=";
              openSha256 = "sha256-DOJw73sjhQoy+5R0GHGnUddE6xaXb/z/Ihq3BKBf+lg=";
              settingsSha256 = "sha256-AIeeDXFEo9VEKCgXnY3QvrW5iWZeIVg4LBCeRtMs5Io=";
              persistencedSha256 = "sha256-Len7Va4HYp5r3wMpAhL4VsPu5S0JOshPFywbO7vYnGo=";

              patches = [
                (pkgs.fetchpatch
                  {
                    url = "https://github.com/CachyOS/kernel-patches/raw/914aea4298e3744beddad09f3d2773d71839b182/6.15/misc/nvidia/0003-Workaround-nv_vm_flags_-calling-GPL-only-code.patch";
                    hash = "sha256-YOTAvONchPPSVDP9eJ9236pAPtxYK5nAePNtm2dlvb4=";
                    stripLen = 1;
                    extraPrefix = "kernel/";
                  })
              ];
            }
        ));
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
