{
  stdenvNoCC,
  pins,
}: let
  inherit (pins) obs;
in
  stdenvNoCC.mkDerivation (finalAttrs: {
    name = "catppuccin-obs";
    version = "git+${builtins.substring 0 7 finalAttrs.src.revision}";
    src = obs;

    #passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

    installPhase = ''
      mkdir -p $out/share
      cp -r $src/themes $out/share/themes
    '';
  })
