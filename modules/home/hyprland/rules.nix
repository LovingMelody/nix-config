{
  lib,
  config,
  ...
}: let
  red = with config.TM.styles.palette.red.rgb; "${toString r}, ${toString g}, ${toString b}";
in {
  wayland.windowManager.hyprland.settings = {
    # layer rules
    layerrule = let
      toRegex = list: let
        elements = lib.concatStringsSep "|" list;
      in "^(${elements})$";

      lowopacity = [
        "bar"
        "calendar"
        "notifications"
        "system-menu"
      ];

      blurred = lib.concatLists [lowopacity];
    in [
      "blur, ${toRegex blurred}"
      "xray 1, ${toRegex ["bar"]}"
      "ignorealpha 0.2, ${toRegex lowopacity}"
      "animation slide right,kitty"
    ];

    # window rules
    windowrulev2 = [
      # media viewer
      "float, title:^(Media viewer)$"
      "float, class:^(termfloat)$"
      # "content game, class:^(git.exe)$"
      "tile, class:^(git.exe)$"

      # make Firefox PiP window floating and sticky
      "float, title:^(Picture-in-Picture)$"
      "pin, title:^(Picture-in-Picture)$"

      "pin, title:^(Quick Access — 1Password)$"

      # throw sharing indicators away
      "workspace special silent, title:^(Firefox — Sharing Indicator)$"
      "workspace special silent, title:^(.*is sharing (your screen|a window)\\.)$"

      # idle inhibit while watching videos
      "idleinhibit focus, class:^(mpv|.+exe|celluloid)$"
      "idleinhibit focus, class:^(firefox)$, title:^(.*YouTube.*)$"
      "idleinhibit fullscreen, class:^(firefox)$"

      "dimaround, class:^(gcr-prompter)$"
      "dimaround, class:^(xdg-desktop-portal-gtk)$"

      # Polkit Rules
      "tag +polkit, class:^(org.kde.polkit-kde-authentication-agent-1)$"
      "tag +polkit, class:^(polkit-gnome-authentication-agent-1)$"
      "tag +polkit, class:^(gcr-prompter)$" # Not Polkit
      "float, tag:polkit"
      "dimaround, tag:polkit"
      "center, tag:polkit"
      "stayfocused, tag:polkit"
      "bordercolor rgb(${red}), tag:polkit"
      "pin, tag:polkit"

      # 1Password Quick Access
      "float, title:^(Quick Access — 1Password)$"
      "center, title:^(Quick Access — 1Password)$"
      "stayfocused, title:^(Quick Access — 1Password)$"
      "pin, title:^(Quick Access — 1Password)$"

      # fix xwayland apps
      "rounding 0, xwayland:1"
      "center, class:^(.*jetbrains.*)$, title:^(Confirm Exit|Open Project|win424|win201|splash)$"

      # don't render hyprbars on tiling windows
      "plugin:hyprbars:nobar, floating:0"

      "opacity 1.0 override 1.0 override,class:^(xwaylandvideobridge)$"
      "noanim,class:^(xwaylandvideobridge)$"
      "nofocus,class:^(xwaylandvideobridge)$"
      "noinitialfocus,class:^(xwaylandvideobridge)$"
      "opacity 1.0 override 1.0 override,class:ffxiv_dx11.exe"
      "opacity 1.0 override 1.0 override,class:Miru"
    ];
  };
}
