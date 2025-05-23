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
      plugins = with pkgs.obs-studio-plugins; [
        input-overlay
        obs-backgroundremoval
        obs-composite-blur
        obs-image-reaction
        obs-ios-camera-source
        obs-pipewire-audio-capture
        obs-vkcapture
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
