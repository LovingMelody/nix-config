{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  inherit
    (lib)
    mapAttrs
    mapAttrsToList
    mkIf
    mkOption
    types
    ;
  inherit (pkgs.stdenv) isLinux;
  cfg = config.TM.defaults;
in {
  # Defaults to true
  options.TM.defaults.enable = mkOption {
    type = types.bool;
    default = true;
    description = "Enable nebula base defaults";
  };

  config = mkIf cfg.enable {
    qt.enable = config.TM.isGui;
    nixpkgs.config = mkIf (config.home-manager.useGlobalPkgs or true) {
      allowUnfree = true;
      permittedInsecurePackages = [];
      # permittedInsecurePackages = [
      #   "freeimage"
      #   "python-2.7.18.7-env"
      # ];
    };
    nix = {
      package = pkgs.nix;
      registry = mapAttrs (_: v: {flake = v;}) inputs;
      nixPath = mapAttrsToList (k: v: "${k}=${v.to.path}") config.nix.registry;
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
          "recursive-nix"
        ];
        auto-optimise-store = isLinux;
        keep-outputs = true;
        keep-derivations = true;
        min-free = "${toString (100 * 1024 * 1024)}";
        max-free = "${toString (100 * 1024 * 1024)}";
        flake-registry = "/etc/nix/registry.json";
      };
    };
  };
}
