{
  lib,
  stdenvNoCC,
  pins,
  ...
}: let
  inherit (pins) base16;
in
  stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "catppuccin-base16";
    version = "git+${builtins.substring 0 7 finalAttrs.src.revision}";
    src = base16;

    #passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

    meta = {
      description = "Base16 Catppuccin theme";
      homepage = "https://github.com/catppuccin/base16";
      platforms = lib.platforms.all;
      license = lib.licenses.mit;
    };

    installPhase = ''
      install -Dm644 base16/* -t $out/share/themes
    '';
  })
