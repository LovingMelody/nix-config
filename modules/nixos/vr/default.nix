{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkDefault mkIf optional;
  cfg = config.TM.vr;
in {
  options.TM.vr = {
    enable = mkEnableOption "Enable VR";
    patchKernel = mkEnableOption "Patch kernel remove CAP_SYS_NICE";
    useWivrn = mkEnableOption "Wivrn instead of ALVR" // {default = false;};
    autoStart = mkEnableOption "Autostart services";
  };

  config = mkIf cfg.enable {
    services.wivrn = {
      enable = cfg.useWivrn;
      openFirewall = true;
      autoStart = mkDefault cfg.autoStart;
      steam = {
        importOXRRuntimes = mkDefault true;
        inherit (config.programs.steam) package;
      };
    };
    programs.alvr = {
      enable = ! cfg.useWivrn;
      openFirewall = true;
    };
    environment.systemPackages = [pkgs.wayvr];
    boot.kernelPatches = optional cfg.patchKernel [
      {
        name = "amdgpu-ignore-ctx-privileges";
        patch = pkgs.fetchpatch {
          name = "cap_sys_nice_begone.patch";
          url = "https://github.com/Frogging-Family/community-patches/raw/master/linux61-tkg/cap_sys_nice_begone.mypatch";
          hash = "sha256-Y3a0+x2xvHsfLax/uwycdJf3xLxvVfkfDVqjkxNaYEo=";
        };
      }
    ];
  };
}
