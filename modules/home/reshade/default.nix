# To be based on https://github.com/kevinlekiller/reshade-steam-proton
{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.TM.reshade;
  inherit (lib) mkEnableOption mkIf mkOption;
in {
  options.TM.reshade = {
    enable = mkEnableOption "Reshade handler";
    packages = {
      standard = mkOption {
        default = pkgs.reshade;
        description = "ReShade without addons";
      };
      full = mkOption {
        default = pkgs.reshade-full;
        description = "ReShade with addons";
      };
    };
    shaders = mkOption {
      default = with pkgs.shaders; [
        {
          name = "quint";
          source = quint;
        }
        {
          name = "gposingway";
          source = gposingway;
        }
      ];
      # type = listOf attrs;
      description = "List of shader files";
    };
  };

  config = mkIf cfg.enable {
    home.file =
      {
        ".ReShade/full".source = cfg.packages.full;
        ".ReShade/standard".source = cfg.packages.standard;
      }
      // (builtins.listToAttrs (
        builtins.map (shader: {
          name = ".ReShade/shaders/${shader.name}";
          value = {
            inherit (shader) source;
          };
        })
        cfg.shaders
      ));

    # TODO: Take an array of attrs ({ name = str; source=package;}), put them .ReShade/shaders/{name}
  };
}
