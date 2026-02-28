{
  config,
  osConfig,
  lib,
  pkgs,
  ...
}: let
  cfg = config.TM.styles;
  inherit
    (lib)
    TM
    mkDefault
    mkEnableOption
    mkIf
    mkOverride
    ;
in {
  imports = [
    (import (TM.get-shared-module "styles") {inherit osConfig;})
  ];
  options.TM.styles.followOS =
    mkEnableOption "Follow OS Styling"
    // {
      default = true;
    };

  config = mkIf cfg.followOS {
    # Priority values:
    # mkDefault = 1000
    # (var = value) 100
    # mkForce = 50
    # We use 99 to allow mkForce to still work
    # But to be higher than the result of stylix.enable
    fonts.fontconfig.enable = mkOverride 99 config.TM.isGui;
    catppuccin = {
      cursors.enable = false;
      kvantum.enable = config.TM.isGui; # Use stylix theme
      vivaldi.enable = config.programs.vivaldi.enable;
      wezterm.apply = true;
    };
    xdg.enable = true;
    TM.styles = {
      inherit
        (osConfig.TM.styles)
        enable
        flavor
        wallpaper
        polarity
        editImage
        ;
    };
    qt.style.name = "kvantum";
    gtk = {
      enable = mkDefault config.TM.isGui;
      gtk2.force = true;
    };
    catppuccin.gtk.icon.enable = false;
    home.file = let
      wallpaper-ext =
        if config.stylix.image == null
        then [""]
        else (builtins.match ".*\\.([^.]+)$" config.stylix.image);
    in {
      ".wallpaper" = mkDefault {source = config.stylix.image;};

      ".wallpaper.${
        if wallpaper-ext != null
        then builtins.head wallpaper-ext
        else ""
      }".source =
        config.stylix.image;
    };
    stylix = {
      icons = {
        enable = osConfig.TM.isGui;
        package = pkgs.catppuccin-papirus-folders.override {
          accent = lib.toLower config.TM.styles.accent;
          flavor = lib.toLower config.TM.styles.flavor;
        };
        light = "Papirus-Light";
        dark = "Papirus-Dark";
      };
      targets = {
        kitty.enable = false;
        tmux.enable = false;
        fzf.enable = false;
        bat.enable = false;
        btop.enable = false;
        helix.enable = false;
        yazi.enable = false;
        alacritty.enable = config.TM.isGui;
        hyprland.enable = false;
        mako.enable = false;
        swaylock.enable = false;
        kde.enable = config.TM.isGui;
        starship.enable = false;
        qt.enable = false;
      };
    };
  };
}
