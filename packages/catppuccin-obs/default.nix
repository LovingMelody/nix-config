{
  stdenvNoCC,
  pins,
}: let
  inherit (pins) obs;
in
  stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "catppuccin-obs";
    version = "git+${builtins.substring 0 7 finalAttrs.src.revision}";
    src = obs;
    installPhase = ''
      mkdir -p $out/share
      cp -r $src/themes $out/share/themes
    '';
  })
