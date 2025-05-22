{
  lib,
  pins,
  meson,
  ninja,
  pkg-config,
  vulkan-headers,
  stdenv,
}: let
  inherit (pins) dxvk-nvapi;
in
  stdenv.mkDerivation {
    pname = "dxvk-nvapi-vulkan-layer";
    inherit (dxvk-nvapi) version;
    src = "${dxvk-nvapi}/layer";
    nativeBuildInputs = [ninja meson pkg-config];
    postPatch = ''
      substituteInPlace "meson.build" \
        --replace-fail = "../external/Vulkan-Headers/include" "${vulkan-headers.src}/include";
        --replace-fail = "../external/vkroots" "${dxvk-nvapi}/external/vkroots";
    '';
  }
