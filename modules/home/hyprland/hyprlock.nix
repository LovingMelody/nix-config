{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit
    (lib)
    mkIf
    mkForce
    getExe
    ;
  inherit (lib.strings) trim optionalString;
  inherit (lib.TM.styling.withPalette config.TM.styles.palette) colors;
  minutes = n: 60 * n;
  seconds = n: 1000 * n;
  font_family = config.stylix.fonts.serif.name;
  zfsDisabled = !(config.TM.libExtra.fromOS ["zfs" "enable"] false);
  lockScript = import ./lockscript.nix {inherit pkgs config lib;};
  suspendScript = pkgs.writeShellScript "suspend-script" (
    optionalString zfsDisabled ''
      # Check if playing before suspending
      ${getExe pkgs.playerctl} status | ${getExe pkgs.gnugrep} -qv "Playing" && \
      ${lockScript.outPath} && \
      ${lib.getExe' pkgs.systemd "systemctl"} suspend
    ''
  );
in {
  config = mkIf config.TM.desktop.hyprland.enable {
    systemd.user.services.hypridle.Unit.After = lib.mkForce ["graphical-session.target"];
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          ignore_dbus_inhibit = false;
          lock_cmd = lockScript.outPath;
          before_sleep_cmd = "${lib.getExe' pkgs.systemd "loginctl"} lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
        };
        listener = [
          {
            timeout = minutes 15;
            on-timeout = "${lib.getExe' pkgs.systemd "loginctl"} lock-session";
          }
          {
            timeout = minutes 20;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
          {
            timeout = minutes 30; # 30min;
            on-timeout = suspendScript.outPath;
          }
        ];
      };
    };

    programs.hyprlock = {
      enable = true;
      settings = {
        general = {
          disable_loading_bar = true;
          grace = 20;
          hide_cursor = true;
          ignore_empty_input = true;
          text_trim = true;
          no_fade_in = true;
        };
        image = {
          path = "${config.home.file.".face".source or ""}";
          size = 150;
          rounding = -1; # Circle
          position = "0, 200";
          halign = "center";
          valign = "center";
        };
        input-field = {
          monitor = "";
          size = "300, 50";
          outline_thickness = 3;
          dots_size = 0.33;
          dots_spacing = 0.15;
          dots_center = true;
          dots_rounding = -1;
          dots_text_format = "♡";
          fade_on_empty = true;
          fade_timeout = seconds 1;
          placeholder_text = trim "<i>Input Password...</i>";
          hide_input = false;
          rounding = -1;
          fail_text = trim "<i>$FATAL <b>($ATTEMPTS)</b></i>";
          fail_transition = 300; # ms
          position = "0, -20";
          halign = "center";
          valign = "center";
          outer_color = mkForce colors.crust.rgb;
          inner_color = mkForce colors.surface0.rgb;
          font_color = mkForce colors.${lib.toLower config.TM.styles.accent}.rgb;
          fail_color = mkForce colors.red.rgb;
          check_color = mkForce colors.yellow.rgb;
        };
        label = [
          {
            monitor = "";
            text = "$TIME";
            inherit font_family;
            font_size = 20;
            color = colors.${lib.toLower config.TM.styles.accent}.rgb;
            position = "0, 50";
            valign = "center";
            halign = "center";
          }
          {
            monitor = "";
            text = "cmd[update:${toString (seconds 3600)}] date +'%a %b %d'";
            inherit font_family;
            font_size = 20;
            color = colors.${lib.toLower config.TM.styles.accent}.rgb;
            position = "0, 20";
            valign = "center";
            halign = "center";
          }
          {
            monitor = "";
            text = "cmd[update:${toString (seconds 10)}] ";
          }
        ];
        background = mkForce [
          {
            path = "screenshot";
            blur_passes = 6;
            blur_size = 5;
          }
          {
            path = config.stylix.image;
            blur_passes = 6;
            blur_size = 8;
          }
        ];
      };
    };
  };
}
