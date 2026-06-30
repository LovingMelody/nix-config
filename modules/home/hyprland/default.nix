{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}: let
  cfg = config.TM.desktop.hyprland;
  inherit
    (lib)
    mkDefault
    mkEnableOption
    mkOption
    mkIf
    types
    ;
  inherit (lib.strings) toShellVars;
  inherit (config.TM.libExtra) fromOS;
in {
  imports = [
    ./hyprpanel/base.nix
    ./hyprlock.nix
    ./settings.nix
    ./rules.nix
    ./binds.nix
  ];
  options.TM.desktop.hyprland = {
    enable =
      mkEnableOption "Hyprland"
      // {
        default = fromOS ["dekstop" "hyprland" "enable"] false;
      };
    enableHDR = mkEnableOption "Enable HDR" // {default = config.TM.hasHDRDisplay;};
    extraAutoStart = mkOption {
      # List of strings
      type = types.listOf types.str;
      default = fromOS ["desktop" "hyprland" "extraAutoStart"] [];
    };
    extraSettings = mkOption {
      type = types.attrs;
      default = fromOS ["desktop" "hyprland" "extraSettings"] {};
    };
    package = mkOption {
      type = types.package;
      default = osConfig.programs.hyprland.package or pkgs.hyprland;
    };
    portalPackage = mkOption {
      type = types.package;
      default =
        osConfig.programs.hyprland.portalPackage
        or (pkgs.xdg-desktop-portal-hyprland.override {
          hyprland = cfg.package;
        });
    };
  };

  config = mkIf cfg.enable {
    systemd.user.sessionVariables = {
      QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;
    };
    # Use hyprbar
    TM.programs.waybar.enable = false;
    programs.rofi = {
      enable = true;
      package = pkgs.wofi;
    };
    systemd.user.services.hyprpaper.Unit.After = lib.mkForce ["graphical-session.target"];
    services = {
      hyprpaper = {
        enable = true;
        settings = {
          ipc = "on";
          splash = false;
          preload = ["${config.stylix.image}"];
          wallpaper = mkDefault [", ${config.stylix.image}"];
        };
      };
      network-manager-applet.enable = true;
      gpg-agent.pinentry.package = mkDefault pkgs.pinentry-gnome3;
      # swaync.enable = true;
      playerctld.enable = true;
      gnome-keyring = {
        enable = true;
        components = [
          "pkcs11"
          "ssh"
          "secrets"
        ];
      };
    };
    xdg.configFile."uwsm/env-hyprland" = {
      text = let
        hdrEnabled = cfg.enableHDR;
      in ''
        ${toShellVars {
          DXVK_HDR = hdrEnabled;
        }}
      '';
    };
    home = {
      packages = with pkgs; [
        rofi-wayland
        gnome-keyring
        seahorse
        pamixer
        hyprpicker
        hyprsunset
        grimblast
        nautilus
        networkmanager
        wl-clipboard
        libgtop
      ];
    };
    wayland.windowManager.hyprland = {
      enable = true;
      package = null;
      xwayland.enable = true;
      systemd = {
        enable = !(osConfig.programs.hyprland.withUSM or false);
        variables = ["--all"];
      };
      settings = cfg.extraSettings;
    };
    xdg.portal = {
      inherit (osConfig.xdg.portal) config;

      #   enable = true;
      #   extraPortals = [ cfg.portalPackage ];
      #   config = {
      #     common.default = [ "hyprland" ];
      #   };
    };
  };
}
