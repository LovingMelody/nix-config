{
  config,
  osConfig ? {},
  pkgs,
  lib,
  inputs,
  ...
}: let
  inherit (lib) getExe toLower mkIf;
  gaps = {inherit (config.wayland.windowManager.hyprland.settings.general) gaps_in gaps_out;};
  homeDir = config.home.homeDirectory;

  usingUWSM = osConfig.programs.hyprland.withUWSM or false;
  exec = lib.optionalString usingUWSM "uwsm app -- ";
in {
  imports = [inputs.hyprpanel.homeManagerModules.hyprpanel];
  config = mkIf config.wayland.windowManager.hyprland.enable {
    wayland.windowManager.hyprland.settings.exec-once = [
      "${exec} ${getExe pkgs.hyprpanel}"
    ];
    home.packages = with pkgs; [
      libnotify
      grimblast # Used for snapshot by default
      hyprpicker # eyedropper for colorpicker
      hyprsunset # Blue light filter
      gpustat # GPU Usage (Nvidia)
      hyprpanel
      gpu-screen-recorder
    ];
    programs.hyprpanel = {
      inherit (config.wayland.windowManager.hyprland) enable;
      settings = {
        layout = {
          "0" = {
            left = [
              "dashboard"
              "workspaces"
              "windowtitle"
            ];
            middle = ["media"];
            right = [
              "volume"
              "network"
              "bluetooth"
              "battery"
              "systray"
              "clock"
              "notifications"
            ];
          };
          "1" = {
            left = [
              "dashboard"
              "workspaces"
              "windowtitle"
            ];
            middle = ["media"];
            right = [
              "volume"
              "clock"
              "notifications"
            ];
          };
          "2" = {
            left = [
              "dashboard"
              "workspaces"
              "windowtitle"
            ];
            middle = ["media"];
            right = [
              "volume"
              "clock"
              "notifications"
            ];
          };
        };
        bar = {
          clock = {
            format = "%a %b %d %T";
            icon = "";
          };
          network.showWifiInfo = true;
          customModules.updates.pollingInterval = 1440000;
          launcher.icon = "=";
          media.show_active_only = true;
          # monitorSpecific = true;
          workspaces = {
            applicationIconOncePerWorkspace = true;
            # hideUnoccupied = true;
            monitorSpecific = true;
            scroll_speed = 7;
            showAllActive = false;
            showApplicationIcons = false;
            showWsIcons = true;
            show_numbered = true;
            workspaces = 1;
          };
        };
        hyprpanel.restartCommand = "${pkgs.procps}/bin/pkill -u $USER -USR1 hyprpanel; ${pkgs.hyprpanel}/bin/hyprpanel";
        menus = {
          # bluetooth.showBattery = true;
          clock = {
            time.military = true;
            weather.enabled = false;
          };
          dashboard = {
            directories.left.directory3 = {
              command = "bash -c \"xdg-open $HOME/Development/\"";
              label = " Development";
            };
            powermenu = {
              avatar.image = "${homeDir}/.face";
              logout =
                if usingUWSM
                then "uwsm stop"
                else "hyprctl dispatch exit";
            };
            shortcuts.left = {
              shortcut1 = {
                command = "firefox";
                icon = "";
                tooltip = "Firefox";
              };
              shortcut2.command = "spotify";
              shortcut3.command = "discord";
            };
            stats.enable_gpu = false;
          };
          media = {
            displayTime = true;
            displayTimeTooltip = true;
          };
          power.lowBatteryNotification = true;
        };
        notifications.active_monitor = false;
        theme = {
          name = "catppuccin_${toLower config.TM.styles.flavor}";
          bar = {
            buttons = {
              spacing = "0.3em";
              style = "default";
            };
            floating = false;
            # margin_bottom = "${builtins.toString gaps.gaps_in}px";
            margin_sides = "${builtins.toString gaps.gaps_out}px";
            margin_top = "${builtins.toString gaps.gaps_in}px";
            menus.monochrome = false;
            outer_spacing = builtins.toString 0;
            transparent = true;
          };
          font = {
            inherit (config.stylix.fonts.serif) name;
            size = "${builtins.toString config.stylix.fonts.sizes.desktop}px";
          };
          osd = {
            location = "bottom";
            orientation = "horizontal";
          };
        };
      };
    };
    xdg.configFile.hyprpanel.onChange = "${pkgs.procps}/bin/pkill -u $USER -USR1 hyprpanel || true";
  };
}
