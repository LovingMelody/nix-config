{
  pkgs,
  lib,
  config,
  inputs,
  system,
  ...
}: let
  cfg = config.TM.styles;
  inherit
    (lib)
    mkDefault
    mkForce
    mkIf
    toLower
    ;
  inherit (lib.TM) get-shared-module toTitle;
in {
  imports = [(get-shared-module "styles")];
  # TODO: Replace stylix some of the enabled styles just dont work
  # Breaks some configs such as waybar by default

  config = mkIf cfg.enable {
    programs.dconf.enable = true;
    boot.plymouth.logo = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/catppuccin/catppuccin/b3584ebc7a74fed37bd7d0dda494d88c17248439/assets/footers/gray0_ctp_on_line.png";
      sha256 = "0avvj5mr642v4djkpwym8drgzq4pskh4bdpb5998spplr8ymqq17";
    };
    qt = {
      enable = mkDefault config.TM.isGui;
      # platformTheme = mkDefault "gnome";
      style = mkForce "adwaita${lib.strings.optionalString (config.stylix.polarity == "dark") "-dark"}";
    };
    fonts = {
      fontDir.enable = config.TM.isGui;
      packages = lib.optionals config.TM.isGui [
        config.stylix.fonts.monospace.package
        config.stylix.fonts.serif.package
        pkgs.nerd-fonts.symbols-only
        pkgs.nerd-fonts.caskaydia-cove
        pkgs.nerd-fonts.caskaydia-mono
        pkgs.font-awesome
        inputs.apple-fonts.packages.${system}.ny
        inputs.apple-fonts.packages.${system}.ny-nerd
        inputs.apple-fonts.packages.${system}.sf-compact
        inputs.apple-fonts.packages.${system}.sf-compact-nerd
        inputs.apple-fonts.packages.${system}.sf-mono
        inputs.apple-fonts.packages.${system}.sf-mono-nerd
        inputs.apple-fonts.packages.${system}.sf-pro
        inputs.apple-fonts.packages.${system}.sf-pro-nerd
        pkgs.noto-fonts-cjk-sans
        pkgs.noto-fonts-cjk-serif
      ];
      fontconfig = {
        hinting.style = "medium";
        useEmbeddedBitmaps = true;
      };
    };
    stylix = {
      # Catppuccin themes this
      targets = {
        plymouth.enable = false;
        grub.enable = false;
        chromium.enable = config.TM.isGui;
      };
      cursor = {
        name = "catppuccin-${toLower cfg.flavor}-${toLower cfg.accent}-cursors";
        package = pkgs.catppuccin-cursors."${toLower cfg.flavor}${toTitle config.catppuccin.accent}";
        size = mkDefault 32;
      };
    };
  };
}
