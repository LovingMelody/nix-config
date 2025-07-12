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
    # xdg.configFile."obs-studio/themes" = {
    #   source = "${pkgs.catppuccin-obs}/share/themes";
    #   recursive = true;
    # };
  };
}
