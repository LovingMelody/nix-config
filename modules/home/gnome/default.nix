{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.TM.desktop.gnome;
  inherit (config.TM.libExtra) mkEnableTarget;
  inherit (lib) filter mkIf toLower;

  inherit (lib.TM.styling.withPalette config.TM.styles.palette) colors;
  inherit (inputs.home-manager.lib.hm.gvariant) mkTuple;
  accent = colors.${toLower config.TM.styles.accent};
in {
  options.TM.desktop.gnome = {
    enable = mkEnableTarget "Gnome desktop environment" [
      "desktop"
      "gnome"
      "enable"
    ];
  };

  config = mkIf cfg.enable {
    TM.isGui = true;
    home.packages = [
      pkgs.gnomeExtensions.appindicator # System tray icons
      # pkgs.gnomeExtensions.gsconnect # KDE Connect implementation for gnome
      # pkgs.gnomeExtensions.dash-to-panel # An icon taskbar for gnome
      pkgs.gnomeExtensions.caffeine # Disable auto suspend and screen blank
      # pkgs.gnomeExtensions.arcmenu # Windows like start-menu
      # pkgs.gnomeExtensions.removable-drive-menu # Add a removable drive menu to the top bar
      # pkgs.gnomeExtensions.bluetooth-quick-connect # Quick connect to bluetooth devices
      # pkgs.gnomeExtensions.blur-my-shell
      pkgs.gnomeExtensions.user-themes
      pkgs.gnomeExtensions.headsetcontrol
    ];
    # ++ (optional (config.TM.styles.polarity == "light")) pkgs.gnomeExtensions.luminus-desktop-y;

    dconf.settings = {
      "org/gnome/shell".enabled-extensions = map (extension: extension.extensionUuid) (
        filter (p: builtins.hasAttr "extensionUuid" p) config.home.packages
      );

      "org/gnome/shell/extensions/blur-my-shell" = {
        brightness = 0.85;
        dash-opacity = config.stylix.opacity.desktop;
        sigma = 15;
        static-blur = false;
      };
      "org/gnome/shell/extensions/blur-my-shell/panel".blur = true;

      "org/gnome/shell/extensions/gsconnect".show-indicators = true;
      "org/gnome/shell/extensions/HeadsetControl".headsetcontrol-executable = lib.getExe pkgs.headsetcontrol;

      "org/gnome/shell/extensions/bluetooth-quick-connect" = {
        keep-menu-on-toggle = false;
        refresh-button-on = true;
      };
      "org/gnome/desktop/lockdown" = {disable-lock-screen = false;};
      "org/gnome/desktop/privacy" = {
        old-files-age = "unit32 30";
        remove-old-temp-files = true;
        remove-old-trash-files = true;
      };
      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
        ];
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        binding = "<Super>Return";
        command = "kitty";
        name = "Kitty";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
        binding = "<Alt><Super>space";
        command = "1password --quick-access";
        name = "1password";
      };
      "org/gnome/shell/app-switcher" = {current-workspace-only = true;};
      "org/gtk/settings/file-chooser" = {
        date-format = "regular";
        location-mode = "path-bar";
        show-hidden = true;
        show-size-column = true;
        show-type-column = true;
        sort-directories-first = true;
      };
      "org/gtk/gtk4/settings/file-chooser" = {
        date-format = "regular";
        location-mode = "path-bar";
        show-hidden = true;
        show-size-column = true;
        show-type-column = true;
        sort-directories-first = true;
      };
      "org/gnome/desktop/wm/preferences" = {
        action-middle-click-titlebar = "none";
        button-layout = "appmenu:minimize,maximize,close";
        resize-with-right-button = true;
      };
      "org/gnome/tweaks" = {show-extensions-notice = false;};
      "org/gnome/mutter" = {center-new-windows = true;};
      "org/gnome/shell/extensions/arcmenu" = {
        menu-arrow-rise = mkTuple [false 0];
        menu-background-color = colors.base.rgb;
        menu-border-color = colors.mantle.rgba 0.2;
        menu-border-radius = 14;
        menu-border-width = 0;
        menu-font-size = 11;
        menu-foreground-color = accent.rgb;
        menu-item-active-bg-color = colors.crust.rgba 0.15;
        menu-item-active-fg-color = accent.rgb;
        menu-item-hover-bg-color = colors.overlay0.rgba 0.15;
        menu-item-hover-fg-color = accent.rgb;
        menu-separator-color = colors.surface2.rgba 0.15;
        multi-monitor = true;
        override-menu-theme = true;
        prefs-visible-page = 0;
        search-entry-border-radius = mkTuple [true 25];
      };

      "org/gnome/system/location" = {enabled = true;};
    };
  };
}
