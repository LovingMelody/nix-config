{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.TM.desktop.gnome;
  inherit (lib) mkDefault mkEnableOption mkIf;
in {
  options.TM.desktop.gnome = {
    enable = mkEnableOption "Gnome desktop environment";
  };

  config = mkIf cfg.enable {
    TM.isGui = true;
    services = {
      gnome = {
        sushi.enable = true;
        gnome-keyring.enable = true;
      };
      colord.enable = true;
      blueman.enable = true;
      xserver = {
        displayManager.gdm.enable = mkDefault true;
        desktopManager.gnome.enable = true;
      };
    };
    hardware.bluetooth = {
      enable = true;
      settings.general = {
        enable = "Source,Sink,Media,Socket";
      };
    };
    security.polkit.enable = true;
    programs = {
      _1password-gui.polkitPolicyOwners = ["melody"];
      dconf.enable = true;
    };
    services.udev.packages = [pkgs.gnome-settings-daemon];
    environment = {
      systemPackages = [pkgs.gnome-control-center];
      gnome.excludePackages = with pkgs; [
        epiphany # Browser
        gnome-console # Console
        gnome-text-editor # Text editor
        gnome-tour # Greeter
        geary # Email
        gnome-maps # Maps
        gnome-software # Software center
        # simple-scan # Scanner
      ];
    };
  };
}
