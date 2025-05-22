{
  config,
  osConfig,
  inputs,
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
    (TM.get-shared-module "styles")
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
    catppuccin.cursors.enable = false;
    catppuccin.kvantum.enable = false; # Use stylix theme
    catppuccin.wezterm.apply = true;
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
    gtk = {
      enable = mkDefault config.TM.isGui;
      iconTheme = {
        package = mkDefault pkgs.adwaita-icon-theme;
        name = mkDefault "adwaita-icon-theme";
      };
    };
    stylix = {
      iconTheme = {
        enable = true;
        package = pkgs.adwaita-icon-theme;
        light = "Adwaita";
        dark = "Adwaita";
      };
      targets = {
        kitty.enable = false;
        tmux.enable = false;
        fzf.enable = false;
        bat.enable = false;
        btop.enable = false;
        helix.enable = false;
        yazi.enable = false;
        alacritty.enable = false;
        hyprland.enable = false;
        mako.enable = false;
        swaylock.enable = false;
        kde.enable = mkDefault config.TM.isGui;
        starship.enable = false;
      };
    };
  };
}
