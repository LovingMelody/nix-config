{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.TM.desktop.hyprland;
  inherit
    (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in {
  options.TM.desktop.hyprland = {
    enable = mkEnableOption "hyprland";
    package = mkOption {default = pkgs.hyprland;};
    portalPackage = mkOption {
      default = pkgs.xdg-desktop-portal-hyprland.override {
        hyprland = config.TM.desktop.hyprland.package;
      };
    };
    extraAutoStart = mkOption {
      # List of strings
      type = types.listOf types.str;
      default = [];
    };
    extraSettings = mkOption {
      type = types.attrs;
      default = {};
    };
  };

  config = mkIf cfg.enable {
    systemd = {
      services = {
        # Prevent errors spam on screen
        greetd.serviceConfig = {
          type = "idle";
          StandardInput = "tty";
          StandardOutput = "tty";
          StandardError = "journal";
          TTYReset = true;
          TTYHangup = true;
          TTYDisallocate = true;
        };
        before-sleep = {
          requiredBy = ["sleep.target"];
          partOf = ["sleep.target"];
          description = "Commands run before sleep";
          serviceConfig = {
            ExecStart = (pkgs.writeShellScript "suspend-script" "loginctl lock-sessions; sleep 3s;").outPath;
            Type = "oneshot";
          };
        };
      };
      user.services.polkit-kde-authentication-agent-1 = {
        description = "polkit-kde-authentication-agent-1";
        wantedBy = ["graphical-session.target"];
        wants = ["graphical-session.target"];
        after = ["graphical-session.target"];
        serviceConfig = {
          Type = "simple";
          ExecStart = with pkgs.kdePackages; "${polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };
    };
    environment.systemPackages = [
      pkgs.kdePackages.polkit-kde-agent-1
    ];
    # Greeter
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${lib.getExe pkgs.greetd.tuigreet} --greeting 'Welcome back' --time";
        };
      };
    };
    programs = {
      light.enable = true;
      hyprlock.enable = true;
      hyprland = {
        enable = true;
        withUWSM = true;
        inherit (cfg) package;
        inherit (cfg) portalPackage;
        xwayland = {
          enable = true;
        };
      };
    };
    services = {
      dbus = {
        implementation = "broker";
        packages = with pkgs; [
          gcr
          gnome-settings-daemon
        ];
      };
      xserver = {
        displayManager.startx.enable = true;
        updateDbusEnvironment = true;
      };
      hypridle.enable = true;
      gnome = {
        glib-networking.enable = true;
        gnome-keyring.enable = true;
        sushi.enable = true;
      };
      gvfs.enable = true;
    };
    security = {
      pam.services = {
        gdm.enableGnomeKeyring = true;
        login.enableGnomeKeyring = true;
      };
      polkit = {
        enable = true;
      };
    };
    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      config = {
        common = {
          default = ["gtk"];
          "org.freedesktop.impl.portal.Secret" = [
            "gnome-keyring"
          ];
        };
        hyprland.default = ["gtk" "hyprland"];
      };
      extraPortals = with pkgs; [
        # xdg-desktop-portal-gtk
      ];
    };
  };
}
