{
  lib,
  config,
  pkgs,
  osConfig ? {},
  ...
}: let
  cfg = config.TM.programs.waybar;
  inherit (lib) mkEnableOption mkIf;
  timezone = osConfig.time.timeZone or "America/New_York";
  usingUWSM = osConfig.programs.hyprland.withUWSM or false;
in {
  options.TM.programs.waybar = {
    enable = mkEnableOption "Waybar";
  };

  config = mkIf cfg.enable {
    # Disable stylix module
    stylix.targets.waybar.enable = false;

    programs.waybar = {
      catppuccin = {
        enable = true;
        mode = "prependImport";
      };
      package = pkgs.waybar.overrideAttrs (prev: {
        mesonFlags = (prev.mesonFlags or []) ++ ["-Dexperimental=true"];
      });
      enable = true;
      systemd.enable = true;
      settings = {
        main-bar = {
          layer = "top";
          position = "top";
          modules-left = ["hyprland/workspaces"];
          modules-center = [
            "clock"
            "idle_inhibitor"
          ];
          modules-right = [
            "mpris"
            "tray"
            "gamemode"
            "pulseaudio"
            "temperature"
            "battery"
            "network"
            "privacy"
            "custom/notification"
            "custom/power"
          ];
          network = {
            format-wifi = "{essid}({signal_strength}%) ";
            format-ethernet = "{ifname} ";
            format-disconnected = "";
            max-length = 50;
            on-click = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
          };
          idle_inhibitor = {
            format = "{icon}";
            format-icons = {
              activated = "";
              deactivated = "";
            };
            # TODO: Set this lol
            on-click = "";
          };
          tray = {
            icon-size = 15;
            spacing = 5;
          };
          clock = {
            inherit timezone;
            format = "{:%H:%M:%S} ";
            tooltip-format = ''
              <big>{:%Y %b}</big>
              <tt><small>{calander}</small></tt>'';
            interval = 1;
          };
          cpu = {
            format = "{usage}% ";
            tooltip = false;
            interval = 15;
          };
          memory = {
            format = "{}% ";
            tooltip = false;
            interval = 15;
          };
          battery = {
            states = {
              good = 95;
              warning = 20;
              critical = 10;
            };
            format = "{capacity}% {icon}";
            format-charging = "{capacity}% ";
            format-plugged = "{capacity}% ";
            format-alt = "{time} {icon}";
            format-full = "";
            format-icons = [
              ""
              ""
              ""
              ""
              ""
            ];
          };
          pulseaudio = {
            format = "{volume}% {icon}";
            format-bluetooth = "{volume}% {icon} {format_source}";
            # prepend muted icon at front
            format-bluetooth-muted = "!{icon} {format_source}";
            format-muted = "0% {icon}";
            format-source = "{volume}% ";
            format-source-muted = "";
            format-icons = {
              headphone = "";
              hands-free = "";
              headset = "";
              phone = "";
              portable = "";
              car = "";
              default = [
                ""
                ""
                ""
              ];
            };
            on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
          };
          mpris = {
            format = "{player_icon} {status_icon} {dynamic}";
            format-paused = "{player_icon} {status_icon} <i>{dynamic}</i>";
            dynamic-order = [
              "title"
              "artist"
              "position"
              "length"
            ];
            dynamic-importance-order = [
              "title"
              "artist"
              "position"
              "length"
            ];
            player-icons = {
              spotify = "";
              chromium = "";
              firefox = "";
              vlc = "";
              default = "";
            };
            ignored-players = [
              "firefox"
              "chromium"
              "brave"
            ];
            status-icons = {
              playing = "";
              paused = "";
              stopped = "";
            };
            interval = 1;
          };
          "custom/power" = {
            format = "";
            on-click = let
              power-menu = pkgs.writeScript "wofi-powermenu.sh" ''
                entries="⇠ Logout\n⏾ Suspend\n⭮ Reboot\n⭮ Firmware \n⏻ Shutdown"
                selected=$(echo -e $entries|${pkgs.wofi}/bin/wofi --width 250 --height 210 --dmenu --cache-file /dev/null | awk '{print tolower($2)}')

                case $selected in
                  logout)
                    ${
                  if usingUWSM
                  then "exec uwsm stop"
                  else "hyprctl dispatch exit"
                };;
                  suspend)
                    exec systemctl suspend;;
                  reboot)
                    exec systemctl reboot;;
                  firmware)
                    exec systemctl reboot --firmware-setup;;
                  shutdown)
                    exec systemctl poweroff -i;;
                esac
              '';
            in "${power-menu}";
          };
          "custom/notification" = {
            tooltip = false;
            format = "{icon}";
            format-icons = {
              notification = "<span foreground='red'><small><sup>⬤</sup></small></span>";
              none = " ";
              dnd-notification = "<span foreground='red'><small><sup>⬤</sup></small></span>";
              dnd-none = " ";
            };
            return-type = "json";
            exec-if = "which swaync-client";
            exec = "swaync-client -swb";
            on-click = "sleep 0.1; swaync-client -t -sw";
            on-click-right = "sleep 0.1; swaync-client -d -sw";
            escape = true;
          };
        };
      };
      style = ''
        * {
          border: none;
          font-family: Font Awesome, ${config.stylix.fonts.monospace.name}, ${config.stylix.fonts.sansSerif.name}, ${config.stylix.fonts.serif.name};
          font-size: ${builtins.toString config.stylix.fonts.sizes.desktop}px;
          color: @text;
          border-radius: 20px;
        }

        window {
          font-weight: bold;
        }

        window#waybar {
          background-color: alpha(@base, 0);
        }

        .modules-right {
          background-color: alpha(@crust, 0.85);
          margin: 2px 10px 0 0;
        }

        .modules-center {
          background-color: alpha(@crust, 0.85);
          color: @rosewater;
          margin: 2px 0 0 0;
        }
        .modules-left {
          background-color: alpha(@crust, 0.85);
          margin: 2px 0 0 5px;
        }

        #workspaces button {
          padding: 1px 5px;
          background-color: transparent;
        }

        /* TODO: Style these */
        #workspaces button:hover {
          box-shadow: inherit;
          background-color: alpha(@flamingo,1);
        }

        #workspaces button.active {
          background-color: alpha(@mantle, 1.85);
        }

        #clock,
        #battery,
        #cpu,
        #memory,
        #temperature,
        #network,
        #pulseaudio,
        #custom-power,
        #idle_inhibitor {
          padding: 0 10px;
        }
        #custom-power {
            background-color: alpha(@lavender,0.6);
            border-radius: 50px;
            margin: 5px 5px;
            padding: 1px 3px;
        }
        # Catppuccinix these too
        /*-----Indicators----*/
        #idle_inhibitor.activated {
            color: #2dcc36;
        }
        #pulseaudio.muted {
            color: @red;
        }
        #battery.charging {
            color: @green;
        }
        #battery.warning:not(.charging) {
          color: @yellow;
        }
        #battery.critical:not(.charging) {
            color: @red;
        }
        #temperature.critical {
            color: @red;
        }
      '';
    };
  };
}
