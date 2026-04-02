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
    qt.enable = lib.mkForce config.TM.isGui;
    nixpkgs = {
      config = {
        allowUnfree = true;
        # FIXME: Remove once darktable no longer requires this
        permittedInsecurePackages = ["libsoup-2.74.3"];
        cudaSupport = config.TM.MyNextGPUWillNotBeNvidia or false;
        cudaCapabilities = ["8.6"];

        overlays = mkIf (! (osConfig.home-manager.useGlobalPkgs or false)) nixpkgs-overlays;
      };
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
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "robotnix.cachix.org-1:+y88eX6KTvkJyernp1knbpttlaLTboVp4vq/b24BIv0="
          "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
          "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
          "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="
        ];
        substituters = [
          "https://cache.nixos.org"
          "https://nix-gaming.cachix.org"
          "https://nix-community.cachix.org"
          "https://nix-citizen.cachix.org"
          "https://cache.garnix.io"
          "https://cosmic.cachix.org"
          # "https://hydra.nixos.org"
          "https://robotnix.cachix.org"
          "https://cache.flox.dev"
          "https://cache.nixos-cuda.org"
          "https://ezkea.cachix.org"
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
