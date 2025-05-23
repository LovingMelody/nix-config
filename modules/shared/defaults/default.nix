{
  config,
  pkgs,
  lib,
  inputs,
  nixpkgs-overlays,
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
      cudaSupport = config.TM.MyNextGPUWillNotBeNvidia or false;
      overlays = nixpkgs-overlays;
    };
    nix = {
      registry = mapAttrs (_: v: {flake = v;}) inputs;
      nixPath = mapAttrsToList (k: v: "${k}=${v.to.path}") config.nix.registry;
      settings = {
        trusted-public-keys = [
          "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
          "nix-citizen.cachix.org-1:lPMkWc2X8XD4/7YPEEwXKKBg+SVbYTVrAaLA2wQTKCo="
          "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="
          "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
          "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        ];
        substituters = [
          "https://nix-gaming.cachix.org"
          "https://nix-citizen.cachix.org"
          "https://cosmic.cachix.org/"
          "https://cache.garnix.io"
          "https://cache.nixos.org"
          "https://hydra.nixos.org" # Always used, set to high priority
        ];
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
