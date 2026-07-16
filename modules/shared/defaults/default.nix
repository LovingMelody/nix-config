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
    mkEnableOption
    mkForce
    mkIf
    mkMerge
    ;
  inherit (lib.TM) get-secret-file;
  inherit (pkgs.stdenv) isLinux;
  cfg = config.TM.defaults;
in {
  # Defaults to true
  options.TM.defaults.enable = mkEnableOption "Enable base defaults" // {default = true;};

  config = mkIf cfg.enable (mkMerge [
    {
      qt.enable = mkForce config.TM.isGui;
      nix = {
        registry = mapAttrs (_: v: {flake = v;}) inputs;
        nixPath = mapAttrsToList (k: v: "${k}=${v.to.path}") config.nix.registry;
        settings = {
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
            "nix-citizen.cachix.org-1:lPMkWc2X8XD4/7YPEEwXKKBg+SVbYTVrAaLA2wQTKCo="
            "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="
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
            "https://cosmic.cachix.org"
            "https://robotnix.cachix.org"
            "https://cache.flox.dev"
            "https://cache.nixos-cuda.org"
            "https://ezkea.cachix.org"
          ];
          experimental-features = ["nix-command" "flakes"];
          auto-optimise-store = isLinux;
          keep-outputs = true;
          keep-derivations = true;
          min-free = "${toString (1 * 1024 * 1024 * 1024)}";
          max-free = "${toString (5 * 1024 * 1024 * 1024)}";
          flake-registry = "/etc/nix/registry.json";
        };
      };
    }

    (mkIf config.TM.knowsHiddenMove {
      sops.secrets."nix-netrc" = mkMerge [
        {
          sopsFile = get-secret-file "netrc.bin";
          format = "binary";
          mode = "600";
        }
        (
          mkIf (! (lib.attrsets.hasAttrByPath ["home" "username"] config)) {
            owner = "root";
          }
        )
      ];
      nix.settings = {
        netrc-file = config.sops.secrets."nix-netrc".path;
        substituters = ["https://cache.nix-ci.com"];
        trusted-public-keys = ["nix-ci:g3xV5BDTLtIBZr/A00IU1x0EtKKlb7YLgBN2SgYgM6A="];
      };
    })
  ]);
}
