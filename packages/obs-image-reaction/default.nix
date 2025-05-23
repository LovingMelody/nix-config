{
  stdenv,
  pins,
  obs-studio,
  cmake,
  pkg-config,
}: let
  inherit (pins) obs-image-reaction;
in
  stdenv.mkDerivation {
    name = "obs-image-reaction";
    version = "git+${builtins.substring 0 8 obs-image-reaction.revision}";
    src = obs-image-reaction;
    nativeBuildInputs = [
      cmake
      pkg-config
    ];
    LibObs_DIR = "${obs-studio}/lib/cmake/libobs";
    buildInputs = [
      obs-studio
    ];
  }
