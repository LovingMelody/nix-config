{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  cfg = config.TM.streaming;
  inherit (lib) mkEnableOption mkIf;
in {
  options.TM.streaming = {
    enable =
      mkEnableOption "Enable Streaming Configurations"
      // {
        default = osConfig.TM.streaming.enable or false;
      };
  };

  config = mkIf cfg.enable {
    programs.obs-studio = {
      enable = true;
      plugins = with pkgs; [
        obs-studio-plugins.obs-composite-blur
        obs-studio-plugins.obs-pipewire-audio-capture
        obs-studio-plugins.obs-backgroundremoval
        obs-studio-plugins.obs-vkcapture
        obs-studio-plugins.input-overlay
        pkgs.obs-ios-camera-source
      ];
    };
    xdg.configFile."obs-studio/themes" = {
      source = "${pkgs.catppuccin-obs}/share/themes";
      recursive = true;
    };
  };
}
