{osConfig ? {}}: {
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
  inherit (lib.TM) toTitle;
  default_flavor = lib.TM.info.flavor;
  default_wallpaper = "${pkgs.hyprland.src}/assets/install/wall2.png";
  cfg = config.TM.styles;
  # NOTE: Ugly fix for https://github.com/nix-community/stylix/issues/437
  # Maybe one day this will be fixed but for now this ugly code works
  palette = import ./palette.nix {inherit config lib;};
  editImage =
    if config.TM.styles.editImage
    then
      img: let
        colors = lib.strings.concatStringsSep " " (lib.attrValues palette);
        baseName = builtins.baseNameOf img;
      in
        pkgs.runCommand baseName {} ''
          ${lib.getExe pkgs.lutgen} apply '${img}' -o $out -- ${colors}
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
        default = osConfig.TM.styles.enable or true;
      };
    flavor = mkOption {
      type = types.enum [
        "Latte"
        "Frappe"
        "Macchiato"
        "Mocha"
      ];
      default = osConfig.TM.styles.flavor or  default_flavor;
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
      default = osConfig.TM.styles.accent or "Pink";
      description = "Catppucin accent color";
    };
    wallpaper = mkOption {
      default = osConfig.TM.styles.wallpaper or default_wallpaper;
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
        default = osConfig.TM.styles.editImage or true;
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
          default = osConfig.TM.styles.fonts.serif.package or pkgs.inter;
        };
        name = mkOption {
          type = lib.types.str;
          default = osConfig.TM.styles.fonts.serif.name or "Inter";
        };
      };
      sansSerif = {
        package = mkOption {
          type = lib.types.package;
          default = osConfig.TM.styles.fonts.sansSerif.package or cfg.fonts.serif.package;
        };
        name = mkOption {
          type = lib.types.str;
          default = osConfig.TM.styles.fonts.sansSerif.name or cfg.fonts.serif.name;
        };
      };
      emoji = {
        package = mkOption {
          type = lib.types.package;
          default = osConfig.TM.styles.fonts.emoji.package or pkgs.noto-fonts-color-emoji;
        };
        name = mkOption {
          type = lib.types.str;
          default = osConfig.TM.styles.fonts.emoji.name or "Noto Color Emoji";
        };
      };
      monospace = {
        package = mkOption {
          type = lib.types.package;
          default = osConfig.TM.styles.fonts.monospace.package or pkgs.nerd-fonts.caskaydia-cove;
        };
        name = mkOption {
          type = lib.types.str;
          default = osConfig.TM.styles.fonts.monospace.name or "CaskaydiaCove Nerd Font";
        };
      };
      sizes = {
        terminal = mkOption {
          type = lib.types.int;
          default = osConfig.TM.styles.fonts.sizes.terminal or 18;
        };
        desktop = mkOption {
          type = lib.types.int;
          default = osConfig.TM.styles.fonts.sizes.desktop or 14;
        };
        applications = mkOption {
          type = lib.types.int;
          default = osConfig.TM.styles.fonts.sizes.applications or 16;
        };
        popups = mkOption {
          type = lib.types.int;
          default = osConfig.TM.styles.fonts.sizes.popups or 12;
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
        autoEnable = true;
        cache.enable = true;
        flavor = toLower cfg.flavor;
        accent = toLower cfg.accent;
      };
    }

    {
      stylix = {
        enable = true;
        base16Scheme = palette;
        cursor = {
          name = "catppuccin-${toLower cfg.flavor}-${toLower cfg.accent}-cursors";
          package = pkgs.catppuccin-cursors."${toLower cfg.flavor}${toTitle config.catppuccin.accent}";
          size = mkDefault 32;
        };
        # HINT: Don't define what defined by catppuccin
        targets = {
          spicetify.colors.enable = false;
          nvf.enable = false;
          gtk.enable = mkDefault config.TM.isGui;
          qt = {
            enable = mkDefault config.TM.isGui;
            # platform = mkForce "qtct";
          };
        };
        opacity.desktop = mkDefault 0.70;
        image = (editImage cfg.wallpaper).outPath;

        inherit (cfg) polarity fonts;
      };
    }
  ]);
}
