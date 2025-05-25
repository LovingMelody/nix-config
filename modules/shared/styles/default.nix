{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit
    (lib)
    importJSON
    mkDefault
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    toLower
    types
    ;
  default_flavor = lib.TM.info.flavor;
  default_wallpaper = "${pkgs.hyprland.src}/assets/install/wall2.png";
  cfg = config.TM.styles;
  palette = import ./palette.nix {inherit config lib;};
  editImage =
    if config.TM.styles.editImage
    then
      img: let
        colors = lib.strings.concatStringsSep " " (lib.attrValues palette);
        baseName = builtins.baseNameOf img;
      in
        pkgs.runCommand baseName {} ''
          ${pkgs.lutgen}/bin/lutgen apply '${img}' -o $out -- ${colors}
        ''
    else
      img:
        pkgs.stdenvNoCC.mkDerivation {
          name = "wallpaper";
          src = img;
          dontUnpack = true;
          installPhase = ''cp $src $out'';
        };
in {
  options.TM.styles = {
    palette = mkOption {
      default = let
        colors =
          (importJSON "${config.catppuccin.sources.palette}/palette.json").${config.catppuccin.flavor};
      in
        colors.colors // {inherit (colors) ansiColors;};
      readOnly = true;
    };
    enable =
      mkEnableOption "Enable Nebula styles"
      // {
        default = true;
      };
    flavor = mkOption {
      type = types.enum [
        "Latte"
        "Frappe"
        "Macchiato"
        "Mocha"
      ];
      default = default_flavor;
      description = "The catppucin flavor of the theme";
    };
    accent = mkOption {
      type = types.enum [
        "Blue"
        "Flamingo"
        "Green"
        "Lavender"
        "Maroon"
        "Mauve"
        "Peach"
        "Pink"
        "Red"
        "Rosewawter"
        "Sapphire"
        "Sky"
        "Teal"
        "Yellow"
      ];
      default = "Pink";
      description = "Catppucin accent color";
    };
    wallpaper = mkOption {
      default = default_wallpaper;
      description = "The wallpaper to use";
    };
    polarity = mkOption {
      type = types.enum [
        "dark"
        "light"
      ];
      default =
        if cfg.flavor == "Latte"
        then "light"
        else "dark";
      description = "The polarity of the theme";
    };
    editImage =
      mkEnableOption "Edit the image to match the theme by applying LUT"
      // {
        default = true;
      };
    # finalImage = mkOption {
    #   type = types.path;
    #   internal = true;
    #   readOnly = true;
    #   description = "Path to the output image";
    #   default = if cfg.editImage then image else cfg.wallpaper;
    # };
    fonts = {
      serif = {
        package = mkOption {
          type = lib.types.package;
          default = pkgs.inter;
        };
        name = mkOption {
          type = lib.types.str;
          default = "Inter";
        };
      };
      sansSerif = {
        package = mkOption {
          type = lib.types.package;
          default = cfg.fonts.serif.package;
        };
        name = mkOption {
          type = lib.types.str;
          default = cfg.fonts.serif.name;
        };
      };
      emoji = {
        package = mkOption {
          type = lib.types.package;
          default = pkgs.noto-fonts-emoji;
        };
        name = mkOption {
          type = lib.types.str;
          default = "Noto Color Emoji";
        };
      };
      monospace = {
        package = mkOption {
          type = lib.types.package;
          default = pkgs.nerd-fonts.caskaydia-cove;
        };
        name = mkOption {
          type = lib.types.str;
          default = "CaskaydiaCove Nerd Font";
        };
      };
      sizes = {
        terminal = mkOption {
          type = lib.types.int;
          default = 18;
        };
        desktop = mkOption {
          type = lib.types.int;
          default = 14;
        };
        applications = mkOption {
          type = lib.types.int;
          default = 16;
        };
        popups = mkOption {
          type = lib.types.int;
          default = 12;
        };
      };
    };
  };
  # TODO: Replace stylix some of the enabled styles just dont work
  # Breaks some configs such as waybar by default

  config = mkIf cfg.enable (mkMerge [
    {
      catppuccin = {
        enable = true;
        cache.enable = true;
        flavor = toLower cfg.flavor;
        accent = toLower cfg.accent;
      };
    }

    {
      stylix = {
        enable = true;
        base16Scheme = palette;
        # Don't define what defined by catppuccin
        targets = {
          nvf.enable = false;
          gtk.enable = mkDefault config.TM.isGui;
          qt.enable = mkDefault config.TM.isGui;
        };
        opacity.desktop = mkDefault 0.70;
        image = editImage cfg.wallpaper;
        inherit (cfg) polarity fonts;
      };
    }
  ]);
}
