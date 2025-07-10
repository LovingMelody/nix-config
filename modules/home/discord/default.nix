{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.TM.programs.discord;
  inherit
    (lib)
    forEach
    mkIf
    mkMerge
    mkOption
    types
    ;
in {
  options.TM.programs.discord = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Discord";
    };
    packages = mkOption {
      type = types.listOf types.package;
      default = pkgs.discord;
      description = "Discord packages";
    };
    vencord = {
      directory = mkOption {
        type = types.path;
        default = "${config.xdg.configHome}/Vencord";
        description = "Vencord directory";
      };
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Vencord";
      };
      css = mkOption {
        type = types.str;
        default = "";
        description = "Vencord CSS";
      };
      # Attribute set converted to json is nullable
      config = mkOption {
        type = with types; nullOr attrs;
        default = null;
        description = "Vencord config";
      };
    };
    openASAR.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable OpenASAR";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = let
        withOpenASAR = cfg.openASAR.enable;
        withVencord = cfg.vencord.enable;
      in
        forEach cfg.packages (p: p.override {inherit withVencord withOpenASAR;});
    }
    (mkIf cfg.vencord.enable (mkMerge [
      # {home.file."${cfg.vencord.directory}/settings/quickCss.css".text = cfg.vencord.css;}
      # (mkIf (!builtins.isNull cfg.vencord.config) {
      #   home.file."${cfg.vencord.directory}/settings/settings.json".text =
      #     builtins.toJSON cfg.vencord.config;
      # })
    ]))
  ]);
}
