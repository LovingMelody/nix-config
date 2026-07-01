{
  stdenvNoCC,
  pins,
}: let
  inherit (pins) gposingway;
in
  stdenvNoCC.mkDerivation (_finalAttrs: {
    pname = "gposingway";
    version = "git+${gposingway.revision}";
    src = gposingway;
    installPhase = ''
      mkdir -p $out/share/
      mkdir -p $out/share/extras
      mkdir -p $out/share/docs
      mkdir -p $out/lib/
      cp -r $src/reshade-shaders/Shaders $out/share/shaders
      cp -r $src/reshade-shaders/Textures $out/share/textures
      cp -r $src/reshade-presets $out/share/presets
      cp -r $src/md $out/share/docs
      cp $src/dxgi.dll $out/lib/
      cp $src/ReShade.ini $out/share/extras
    '';
  })
