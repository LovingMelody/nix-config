{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.TM.lix;
  inherit (lib) types mkOption mkIf;
in {
  options.TM.lix.enable = mkOption {
    type = types.bool;
    default = false;
    description = "Use lix instead of nix";
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [
      (_final: prev: {
        inherit
          (prev.lixPackageSets.stable)
          nixpkgs-review
          nix-eval-jobs
          nix-fast-build
          colmena
          ;
      })
    ];

    nix.package = pkgs.lixPackageSets.stable.lix;
  };
}
