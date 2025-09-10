{
  lib,
  config,
  system,
  ...
}: let
  inherit
    (lib)
    mkIf
    mkEnableOption
    mkOption
    types
    ;
  inherit (lib.systems) architectures;
  inherit (config.TM.libExtra) fromOS;
  cfg = config.TM.simd;
in {
  options.TM.simd = {
    enable =
      mkEnableOption "Optimized builds with simd instructions"
      // {
        default =
          fromOS [
            "simd"
            "enable"
          ]
          true;
      };
    partial =
      mkEnableOption "Dont set gcc options reducing builds. Features will still be added"
      // {
        default = fromOS ["sind" "partial"] true;
      };
    arch = mkOption {
      type = with types; str;
      default = fromOS [
        "simd"
        "arch"
      ] "x86-64-v2";
      description = ''
        Microarchetecture string for gcc march
        Can be determined with ``nix run nixpkgs#gcc -- -march=native -Q --help=target | grep march";
      '';
    };
  };

  config = let
    inherit (cfg) arch;
  in
    mkIf cfg.enable {
      nix.settings.system-features =
        [
          "kvm"
          "big-parallel"
          "benchmark"
          "nixos-test"
          "gccarch-${arch}"
        ]
        ++ map (x: "gccarch-${x}") architectures.inferiors.${arch};
      nixpkgs.hostPlatform =
        {
          gcc = mkIf (! cfg.partial) {
            inherit arch;
            tune = arch;
          };

          inherit system;
        }
        // (builtins.mapAttrs
          (_name: function: function arch)
          lib.systems.architectures.predicates);
      # legacy
      # nixpkgs.localSystem = {
      #   gcc = mkIf (! cfg.partial) {
      #     inherit arch;
      #     tune = arch;
      #   };
      #   inherit system;
      # };
    };
}
