{
  config,
  pkgs,
  lib,
  inputs,
  nixpkgs-overlays,
  osConfig ? {},
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
    nixpkgs.config = {
      allowUnfree = true;
      # FIXME: Remove once darktable no longer requires this
      permittedInsecurePackages = ["libsoup-2.74.3"];
      cudaSupport = config.TM.MyNextGPUWillNotBeNvidia or false;
      cudaCapabilities = ["7.5" "8.0" "8.6"];

      overlays = mkIf (! (osConfig.home-manager.useGlobalPkgs or false)) nixpkgs-overlays;
    };
    nix = {
      registry = mapAttrs (_: v: {flake = v;}) inputs;
      nixPath = mapAttrsToList (k: v: "${k}=${v.to.path}") config.nix.registry;
      settings = {
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
          "nix-citizen.cachix.org-1:lPMkWc2X8XD4/7YPEEwXKKBg+SVbYTVrAaLA2wQTKCo="
          "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
          "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="
          # "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
          "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
        substituters = [
          "https://cache.nixos.org"
          "https://nix-gaming.cachix.org"
          "https://nix-community.cachix.org"
          "https://nix-citizen.cachix.org"
          "https://cache.garnix.io"
          "https://cosmic.cachix.org/"
          # "https://hydra.nixos.org"
          "https://chaotic-nyx.cachix.org/"
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
