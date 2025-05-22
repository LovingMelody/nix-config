{
  stdenv,
  pkgs,
  pins,
}: let
  inherit (pins) obs-ios-camera-source;
in
  stdenv.mkDerivation {
    name = "obs-ios-camera-source";
    version = "git+${builtins.substring 0 8 obs-ios-camera-source.revision}";
    src = obs-ios-camera-source;
    nativeBuildInputs = with pkgs; [
      cmake
      pkg-config
    ];
    buildInputs = with pkgs; [
      gcc
      automake
      obs-studio
      openssl
      git
      ffmpeg
    ];
  }
