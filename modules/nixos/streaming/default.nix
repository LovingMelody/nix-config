{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.TM.streaming;
  inherit (lib) mkEnableOption mkIf;
in {
  options.TM.streaming = {
    enable = mkEnableOption "Enable streaming specific kernel modules & install OBS";
  };

  config = mkIf cfg.enable {
    programs.obs-studio = {
      enable = true;
      enableVirtualCamera = true;
      plugins = with pkgs; [
        obs-studio-plugins.obs-composite-blur
        obs-studio-plugins.obs-pipewire-audio-capture
        obs-studio-plugins.obs-backgroundremoval
        obs-studio-plugins.obs-vkcapture
        obs-studio-plugins.input-overlay
        pkgs.obs-ios-camera-source
      ];
    };
    boot = {
      extraModulePackages = with config.boot.kernelPackages; [v4l2loopback];
      kernelModules = [
        "snd-aloop"
      ];
    };
  };
}
