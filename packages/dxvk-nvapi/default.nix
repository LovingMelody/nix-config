{
  pins,
  lib,
  stdenvNoCC,
  overrideCC,
  pkgsCross,
}:
stdenvNoCC.mkDerivation (
  _finalAttrs: let
    useWin32ThreadModel = stdenv:
      overrideCC stdenv (
        stdenv.cc.override (old: {
          cc = old.cc.override {
            threadsCross = {
              model = "win32";
              package = null;
            };
          };
        })
      );

    mingw32Stdenv = useWin32ThreadModel pkgsCross.mingw32.stdenv;
    mingwW64Stdenv = useWin32ThreadModel pkgsCross.mingwW64.stdenv;

    dxvk-nvapi32 = pkgsCross.mingw32.callPackage ./base.nix {
      inherit pins;
      stdenv = mingw32Stdenv;
    };

    dxvk-nvapi64 = pkgsCross.mingwW64.callPackage ./base.nix {
      inherit pins;
      stdenv = mingwW64Stdenv;
    };
  in {
    pname = "dxvk-nvapi";
    inherit (dxvk-nvapi64) version;

    outputs = [
      "out"
    ];

    strictDeps = true;

    buildCommand = ''
      mkdir -p $out
      install -v -D -m 644 -t "$out/" '${pins.dxvk-nvapi}/LICENSE'
      install -v -D -m 644 -t "$out/" '${pins.dxvk-nvapi}/README.md'
      install -v -D -m644 -t "$out/x32" ${dxvk-nvapi32}/bin/*.dll
      install -v -D -m644 -t "$out/x64" ${dxvk-nvapi64}/bin/*.dll
    '';

    passthru = {
      inherit dxvk-nvapi32 dxvk-nvapi64;
    };

    __structuredAttrs = true;

    meta = {
      description = "Alternative NVAPI implementation on top of DXVK";
      homepage = "https://github.com/jp7677/dxvk-nvapi";
      changelog = "https://github.com/jp7677/dxvk-nvapi/releases";
      license = lib.licenses.mit;
      maintainers = [lib.maintainers.fuzen];
      platforms = [
        "x86_64-darwin"
        "i686-linux"
        "x86_64-linux"
      ];
    };
  }
)
