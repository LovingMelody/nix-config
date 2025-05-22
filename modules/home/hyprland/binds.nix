{
  lib,
  config,
  osConfig ? {},
  pkgs,
  ...
}: let
  inherit (lib) getExe' getExe;
  usingUWSM = osConfig.programs.hyprland.withUWSM or false;
  exec = lib.strings.optionalString usingUWSM "uwsm app --";
  # binds $mod + [(shift|ctrl) +] {1..10} to [move to] workspace {1..10}
  workspaces = builtins.concatLists (
    builtins.genList (
      x: let
        ws = let
          c = (x + 1) / 10;
        in
          builtins.toString (x + 1 - (c * 10));
      in [
        "$mod, ${ws}, workspace, ${toString (x + 1)}"
        "$mod SHIFT, ${ws}, movetoworkspacesilent, ${toString (x + 1)}"
        "$mod CTRL, ${ws}, movetoworkspace, ${toString (x + 1)}"
      ]
    )
    10
  );

  pgrep = getExe' pkgs.procps "pgrep";
  runOnce = program: "${pgrep} ${builtins.baseNameOf program} || ${exec} ${program}";
  lockScript = import ./lockscript.nix {inherit pkgs lib config;};
  grimBlast = runOnce (lib.getExe pkgs.grimblast);
  saveArea = "~/Pictures/$(date '+%Y-%m-%d'T'%H:%M:%S_no_watermark').png";
  inherit (config.wayland.windowManager.hyprland.settings.general) gaps_in gaps_out;
in {
  wayland.windowManager.hyprland.settings = {
    bindm = [
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
      "$mod ALT, mouse:272, resizewindow"
    ];

    bind =
      [
        "$mod, y, pin"
        "$mod, P, pseudo"
        "$mod, J, togglesplit"
        "$mod, F, fullscreen,"
        "$mod, G, togglegroup,"
        "$mod SHIFT, Q, killactive"
        "$mod SHIFT, C, exec, ${exec} ${lib.getExe pkgs.zenity} --question --text='Are you sure you want to exit hyprland' && ${
          if usingUWSM
          then "uwsm stop"
          else "hyprctl dispatch exit"
        }"
        "$mod SHIFT, SPACE, togglefloating"
        "$mod SHIFT, SPACE, centerwindow"
        "$mod SHIFT, N, changegroupactive, f"
        "$mod SHIFT, P, changegroupactive, b"
        "$mod, R, togglesplit,"
        # Gap Adjustment
        "$mod SHIFT, G, exec, hyprctl --batch 'keyword general:gaps_out ${builtins.toString gaps_out};keyword general:gaps_in ${builtins.toString gaps_in}'"
        "$mod CTRL , G, exec, hyprctl --batch 'keyword general:gaps_out 0;keyword general:gaps_in 0'"

        # Launch Kitty
        "$mod, Return, exec, ${exec} ${getExe pkgs.wezterm}"
        "$mod SHIFT, Return, exec, ${exec} ${getExe pkgs.wezterm} --class='termfloat'"

        # Lock Screen
        "$mod SHIFT, x, exec,  ${exec} ${lockScript.outPath}"

        #Screenshot
        #: area
        ", Print, exec, ${grimBlast} --notify copysave area  ${saveArea}"
        "$mod SHIFT, R, exec, ${grimBlast} --notify copysave area ${saveArea}"
        #: current screen
        "CTRL, Print, exec, ${grimBlast} --notify --cursor copysave output ${saveArea}"
        "$mod SHIFT CTRL, R, exec, ${grimBlast} --notify --cursor copysave output ${saveArea}"
        #: all screens
        "ALT, Print, exec, ${grimBlast} --notify --cursor copysave screen ${saveArea}"
        "$mod SHIFT ALT, R, exec, ${grimBlast} --notify --cursor copysave screen ${saveArea}"

        # move focus
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"

        # Move Window
        "$mod SHIFT,left ,movewindow, l"
        "$mod SHIFT,right ,movewindow, r"
        "$mod SHIFT,up ,movewindow, u"
        "$mod SHIFT,down ,movewindow, d"

        # Scroll through workspaces
        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up, workspace, e-1"

        # Toggle Opacitiy for active window
        "$mod SHIFT, A, exec, hyprctl setprop active opaque toggle"
      ]
      ++ lib.optional config.TM.programs.waybar.enable "$mod, O, exec, systemctl restart --user waybar.service"
      ++ lib.optional config.TM.programs._1password.enable "$mod ALT_L, SPACE,exec, ${exec} 1password --ozone-platform=wayland --enable-features=WaylandWindowDecorations --quick-access"
      ++ workspaces;
    /*
    # control volume,brightness,media players
    ", XF86AudioRaiseVolume,exec, ${pkgs.wireplumber}/bin/wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"
    ", XF86AudioLowerVolume,exec, ${pkgs.wireplumber}/bin/wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%-"
    ", XF86MonBrightnessUp,exec, ${pkgs.light}/bin/light -A 5"
    ", XF86MonBrightnessDown, exec, ${pkgs.light}/bin/light -U 5"
    */
    bindl = [
      # Media Controls
      ", XF86AudioPlay,exec, ${pkgs.playerctl}/bin/playerctl play-pause"
      ", XF86AudioNext,exec, ${pkgs.playerctl}/bin/playerctl next"
      ", XF86AudioPrev,exec, ${pkgs.playerctl}/bin/playerctl previous"
      # Volume
      ", XF86AudioMute,exec, ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ", XF86AudioMicMute,exec, ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle "
    ];
    bindle = [
      # control volume
      ", XF86AudioRaiseVolume,exec, ${pkgs.wireplumber}/bin/wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"
      ", XF86AudioLowerVolume,exec, ${pkgs.wireplumber}/bin/wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%-"
      # Brightness
      ", XF86MonBrightnessUp,exec, ${pkgs.light}/bin/light -A 5"
      ", XF86MonBrightnessDown, exec, ${pkgs.light}/bin/light -U 5"
    ];
    bindr = ["$mod,SPACE, exec, ${runOnce "rofi"} -show drun"];
  };
}
