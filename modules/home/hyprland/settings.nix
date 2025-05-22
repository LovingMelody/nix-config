{
  config,
  osConfig,
  lib,
  ...
}: let
  cfg = config.TM.desktop.hyprland;
  usingUWSM = osConfig.programs.hyprland.withUWSM or false;
  exec = lib.strings.optionalString usingUWSM "uwsm app --";
  inherit (config.TM.styles) palette accent;
  inherit (lib) toLower optional mkIf;
  inherit (lib.strings) optionalString;
  rgb = color: let
    c = palette.${color};
  in "rgb(${lib.strings.removePrefix "#" c.hex})";
  rgba = color: alpha: let
    c = palette.${color};
  in "rgba(${toString c.rgb.r}, ${toString c.rgb.g}, ${toString c.rgb.b}, ${toString alpha})";
in {
  wayland.windowManager.hyprland.settings = {
    experimental = {
      xx_color_management_v4 = true;
    };
    "$mod" = "SUPER";
    env = [];
    #nvidia things...
    monitor = [
      ", preferred, auto, 1, vrr, 1, bitdepth, 10${optionalString cfg.enableHDR ", cm, hdr, sdrbrightness, 1.3"}"
      "Unknown-1,disable"
    ];
    general = {
      gaps_in = 5;
      gaps_out = 8;
      border_size = 1;
      allow_tearing = false;
      resize_on_border = true;
      layout = "dwindle";
      "col.active_border" = rgb (toLower accent);
      "col.inactive_border" = rgb "crust";
    };
    cursor = mkIf (osConfig.TM.MyNextGPUWillNotBeNvidia or false) {no_hardware_cursors = true;};
    exec-once =
      [
        "${exec} hyprctl setcursor '${config.stylix.cursor.name}' ${toString config.stylix.cursor.size}"
      ]
      ++ optional config.TM.programs._1password.enable "${exec} 1password --silent &"
      ++ config.TM.desktop.hyprland.extraAutoStart;
    dwindle = {
      force_split = 0;
      special_scale_factor = 0.8;
      split_width_multiplier = 1.0;
      use_active_for_splits = true;
      pseudotile = true;
      preserve_split = true;
    };
    decoration = {
      rounding = 10;
      inactive_opacity = 0.6;
      active_opacity = config.stylix.opacity.desktop;
      blur = {
        enabled = true;
        brightness = 1.0;
        contrast = 1.0;
        noise = 1.0e-2;

        vibrancy = 0.2;
        vibrancy_darkness = 0.5;
        passes = 4;
        size = 2;
        special = true;

        popups = true;
        popups_ignorealpha = 0.2;
      };
      shadow = {
        color = rgba "base" 99;
        enabled = true;
        ignore_window = true;
        offset = "0 15";
        range = 100;
        render_power = 2;
        scale = 0.97;
      };
    };
    animations = {
      enabled = true;
      bezier = "overshot, 0.13, 0.99, 0.29, 1.1";
      animation = [
        "windows, 1, 4, overshot, slide"
        "windowsOut, 1, 5, default, popin 80%"
        "border, 1, 5, default"
        "fade, 1, 8, default"
        "workspaces, 1, 6, overshot, slidevert"
      ];
    };
    group = {
      "col.border_active" = rgb (toLower accent);
      "col.border_inactive" = rgb "mantle";
      "col.border_locked_active" = rgb "red";
      groupbar = {
        text_color = rgb "text";
        "col.active" = rgb (toLower accent);
        "col.inactive" = rgb "mantle";
        font_size = 10;
        gradients = false;
      };
    };
    input = {
      kb_layout = "us";
      kb_options = "caps:escape";
      touchpad = {
        natural_scroll = true;
        clickfinger_behavior = true;
      };
      follow_mouse = 1;
      float_switch_override_focus = 2;
      sensitivity = 0; # -1.0 to 1.0
    };
    gestures = {
      workspace_swipe = true;
      workspace_swipe_fingers = 4;
      workspace_swipe_distance = 250;
      workspace_swipe_invert = true;
      workspace_swipe_min_speed_to_force = 15;
      workspace_swipe_cancel_ratio = 0.5;
      workspace_swipe_create_new = true;
    };
    misc = {
      background_color = rgb "base";
      disable_autoreload = true;
      vrr = 1;
      focus_on_activate = true;
      always_follow_on_dnd = true;
      layers_hog_keyboard_focus = true;
      animate_manual_resizes = false;
    };
    xwayland.force_zero_scaling = true;
    debug.disable_logs = false;
    plugin = {
      hyprbars = {
        bar_height = 20;
        bar_precedence_over_border = true;
        bar_button_alignment = "right";
        hyprbars-button = let
          inherit (config.lib.stylix) colors;
        in [
          "rgb(${colors.red}), 15, , hyprctl dispatch killactive"
          "rgb(${colors.green}), 15, , hyprctl dispatch fullscreen 1"
        ];
      };
    };
  };
}
