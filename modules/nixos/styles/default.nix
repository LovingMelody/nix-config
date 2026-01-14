{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.TM.styles;
  inherit
    (lib)
    mkDefault
    mkIf
    ;
  inherit (lib.TM) get-shared-module;
in {
  imports = [(import (get-shared-module "styles") {osConfig = {};})];
  # TODO: Replace stylix some of the enabled styles just dont work
  # Breaks some configs such as waybar by default

  config = mkIf cfg.enable {
    environment.systemPackages = [pkgs.kdePackages.qtstyleplugin-kvantum];
    programs.dconf.enable = true;
    boot.plymouth.logo = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/catppuccin/catppuccin/b3584ebc7a74fed37bd7d0dda494d88c17248439/assets/footers/gray0_ctp_on_line.png";
      sha256 = "0avvj5mr642v4djkpwym8drgzq4pskh4bdpb5998spplr8ymqq17";
    };
    qt = {
      enable = mkDefault config.TM.isGui;
      # platformTheme = "kvantum";
      # style = mkForce "adwaita${lib.strings.optionalString (config.stylix.polarity == "dark") "-dark"}";
    };
    fonts = {
      fontDir.enable = config.TM.isGui;
      packages = lib.optionals config.TM.isGui [
        config.stylix.fonts.monospace.package
        config.stylix.fonts.serif.package
        pkgs.font-awesome
        pkgs.inter
        pkgs.nerd-fonts.caskaydia-cove
        pkgs.nerd-fonts.caskaydia-mono
        pkgs.nerd-fonts.open-dyslexic
        pkgs.nerd-fonts.symbols-only
        pkgs.noto-fonts-cjk-sans
        pkgs.noto-fonts-cjk-serif
        pkgs.open-dyslexic
      ];
      fontconfig = {
        hinting.style = "medium";
        useEmbeddedBitmaps = true;
      };
    };
    stylix = {
      homeManagerIntegration.autoImport = false;
      # Catppuccin themes this
      targets = {
        plymouth.enable = false;
        grub.enable = false;
        chromium.enable = config.TM.isGui;
        qt.enable = true;
      };
    };
  };
}
