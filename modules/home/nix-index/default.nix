{
  config,
  lib,
  inputs,
  ...
}: let
  cfg = config.TM.programs.nix-index;
  inherit (lib) mkEnableOption mkIf;
in {
  options.TM.programs.nix-index.enable =
    mkEnableOption "A files database for nixpkgs"
    // {
      default = true;
    };
  config = mkIf cfg.enable {
    programs.nix-index.enable = true;
    programs.nix-index-database.comma.enable = true;
  };
}
