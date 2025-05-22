{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.TM.programs.tmux;
  inherit (lib) mkEnableOption mkIf;
in {
  options.TM.programs.tmux.enable =
    mkEnableOption "Terminal multiplexer"
    // {
      default = true;
    };
  config = mkIf cfg.enable {
    programs.tmux = {
      extraConfig = ''
        set -g @catppuccin_pane_border_status "top"
        set -g @catppuccin_window_left_separator ""
        set -g @catppuccin_window_right_separator " "
        set -g @catppuccin_window_middle_separator " █"
        set -g @catppuccin_window_number_position "right"

        set -g @catppuccin_window_default_fill "number"
        set -g @catppuccin_window_default_text "#W"

        set -g @catppuccin_window_current_fill "number"
        set -g @catppuccin_window_current_text "#W"

        set -g @catppuccin_status_modules_right "directory user host battery cpu session"
        set -g @catppuccin_status_left_separator  " "
        set -g @catppuccin_status_right_separator ""
        set -g @catppuccin_status_right_separator_inverse "no"
        set -g @catppuccin_status_fill "icon"
        set -g @catppuccin_status_connect_separator "no"

        set -g @catppuccin_directory_text "#{pane_current_path}"

        bind-key a send-prefix
        bind | split-window -h -c "#{pane_current_path}"
        bind - split-window -v -c "#{pane_current_path}"
        bind c new-window -c "#{pane_current_path}"
        set-option -g set-titles on
        set-option -g set-titles-string "Tmux #{online_status} #{session_name} > #{pane_title} | #h"
      '';
      sensibleOnTop = true;
      enable = true;
      shortcut = "a";
      aggressiveResize = true;
      baseIndex = 1;
      newSession = true;
      escapeTime = 0;
      secureSocket = true;
      clock24 = true;
      terminal = "screen-256color";
      mouse = true;
      historyLimit = 50000;
      plugins = with pkgs; [
        tmuxPlugins.cpu
        {
          plugin = tmuxPlugins.resurrect;
          extraConfig = "set -g @resurrect-strategy-nvim 'session'";
        }
        # {
        #   plugin = tmuxPlugins.online-status;
        #   extraConfig = ''
        #     set -g status-right "Online: #{online_status} | %a %h-%d %H:%M "
        #     set -g @online_icon "ok"
        #     set -g @offline_icon "offline!"
        #     set -g @route_to_ping "1.1.1.1"
        #   '';
        # }
        tmuxPlugins.pain-control
        tmuxPlugins.battery
        {
          plugin = tmuxPlugins.continuum;
          extraConfig = ''
            set -g  @continuum-restore 'on'
            set -g @continuum-save-interval '60' # minutes
          '';
        }
      ];
    };
  };
}
