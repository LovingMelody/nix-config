{
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkDefault mkIf;
  cfg = config.TM.vr;
in {
  options.TM.vr = {
    enable = mkEnableOption "Enable VR";
    patchKernel = mkEnableOption "Patch kernel remove CAP_SYS_NICE";
    wireless = mkEnableOption "Wireless VR" // {default = true;};
  };

  config = mkIf cfg.enable {
    services.wivrn = {
      enable = cfg.wireless;
      openFirewall = true;
      defaultRuntime = mkDefault true;
      autoStart = mkDefault true;
      steam.importOXRRuntimes = mkDefault true;
    };
  };
}
