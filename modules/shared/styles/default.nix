_: {
  config,
  pkgs,
  lib,
  ...
} @ args: let
  inherit
    (lib)
    importJSON
    mkDefault
    mkIf
    mkMerge
    mkOption
    toLower
    types
    ;
  inherit (config.TM.libExtra) mkDisableTarget fromOS;
  inherit (lib.TM) toTitle;
  globalPackagesEnabled = args.osConfig.home-manager.useGlobalPkgs or false;
  default_flavor = lib.TM.info.flavor;
  default_wallpaper = "${pkgs.hyprland.src}/assets/install/wall2.png";
  cfg = config.TM.styles;
  # NOTE: Ugly fix for https://github.com/nix-community/stylix/issues/437
  # Maybe one day this will be fixed but for now this ugly code works
  palette = import ./palette.nix {inherit config lib;};
  # Catppuccin owns colours: wherever a catppuccin target is enabled, turn off the
  # colours of the matching stylix target (stylix keeps fonts/opacity), or the whole
  # stylix target when it has no separate `colors` toggle.
  catppuccinColorOverrides = let
    aliases = {
      nvim = "neovim";
      tty = "console";
    };
    stylixTargets = args.options.stylix.targets;
  in
    # catppuccin.vscode is configured per profile, so the generic rule can't see it
    lib.optionalAttrs (stylixTargets ? vscode && args.options ? catppuccin.vscode.profiles) {
      vscode.colors.enable = mkIf (lib.any (p: p.enable) (lib.attrValues config.catppuccin.vscode.profiles)) (mkDefault false);
    }
    // lib.concatMapAttrs (name: opt: let
      target = aliases.${name} or name;
      # skip renamed/hidden aliases such as catppuccin.vscode.enable
      isTarget = opt ? enable && (opt.enable.visible or true) == true;
      off = mkIf config.catppuccin.${name}.enable (mkDefault false);
    in
      lib.optionalAttrs (isTarget && stylixTargets ? ${target}) {
        ${target} =
          if stylixTargets.${target} ? colors
          then {colors.enable = off;}
          else {enable = off;};
      })
    args.options.catppuccin;
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
    enable = mkDisableTarget "Enable Styling" ["styles" "enable"];
    flavor = mkOption {
      type = types.enum [
        "Latte"
        "Frappe"
        "Macchiato"
        "Mocha"
      ];
      default = fromOS ["styles" "flavor"] default_flavor;
      description = "The Catppuccin flavor of the theme";
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
        "RoseWater"
        "Sapphire"
        "Sky"
        "Teal"
        "Yellow"
      ];
      default = fromOS ["styles" "accent"] "Pink";
      description = "Catppuccin accent color";
    };
    wallpaper = mkOption {
      default = fromOS ["styles" "wallpaper"] default_wallpaper;
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
    editImage = mkDisableTarget "Edit the image to match the theme by applying LUT" ["styles" "editImage"];
    fonts = {
      serif = {
        package = mkOption {
          type = lib.types.package;
          default = fromOS ["styles" "fonts" "serif" "package"] pkgs.inter;
        };
        name = mkOption {
          type = lib.types.str;
          default = fromOS ["styles" "fonts" "serif" "name"] "Inter";
        };
      };
      sansSerif = {
        package = mkOption {
          type = lib.types.package;
          default = fromOS ["styles" "fonts" "sansSerif" "package"] cfg.fonts.serif.package;
        };
        name = mkOption {
          type = lib.types.str;
          default = fromOS ["styles" "fonts" "sansSerif" "name"] cfg.fonts.serif.name;
        };
      };
      emoji = {
        package = mkOption {
          type = lib.types.package;
          default = fromOS ["styles" "fonts" "emoji" "package"] pkgs.noto-fonts-color-emoji;
        };
        name = mkOption {
          type = lib.types.str;
          default = fromOS ["styles" "fonts" "emoji" "name"] "Noto Color Emoji";
        };
      };
      monospace = {
        package = mkOption {
          type = lib.types.package;
          default = fromOS ["styles" "fonts" "monospace" "package"] pkgs.nerd-fonts.caskaydia-cove;
        };
        name = mkOption {
          type = lib.types.str;
          default = fromOS ["styles" "fonts" "monospace" "name"] "CaskaydiaCove Nerd Font";
        };
      };
      sizes = {
        terminal = mkOption {
          type = lib.types.int;
          default = fromOS ["styles" "fonts" "sizes" "terminal"] 18;
        };
        desktop = mkOption {
          type = lib.types.int;
          default = fromOS ["styles" "fonts" "sizes" "desktop"] 14;
        };
        applications = mkOption {
          type = lib.types.int;
          default = fromOS ["styles" "fonts" "sizes" "desktop"] 16;
        };
        popups = mkOption {
          type = lib.types.int;
          default = fromOS ["styles" "fonts" "sizes" "popups"] 12;
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
        # Avoid IFD for ports read at eval time (see lib.TM.catppuccinSources).
        sources = lib.TM.catppuccinSources;
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
        targets = mkMerge [
          catppuccinColorOverrides
          {
            spicetify.colors.enable = false;
            nvf.enable = false;
            gtk.enable = mkDefault config.TM.isGui;
            qt = {
              enable = mkDefault config.TM.isGui;
            };
          }
        ];
        opacity.desktop = mkDefault 0.70;
        image = (editImage cfg.wallpaper).outPath;
        # Quick Fix for nix-community/stylix#1832
        # Alternative to PR #2473
        overlays.enable = mkDefault (! globalPackagesEnabled);
        inherit (cfg) polarity fonts;
      };
    }
  ]);
}
