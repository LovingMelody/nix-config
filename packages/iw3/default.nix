# https://github.com/nagadomi/nunif/discussions/547
{
  pins,
  lib,
  stdenv,
  python3Packages,
  copyDesktopItems,
  makeDesktopItem,
  fetchgit,
  pkgs,
  ...
}: let
  inherit (pins) nunif;
in
  python3Packages.buildPythonApplication rec {
    pname = "nunif_iw3";
    version = nunif.revision;
    pyproject = false;

    src = nunif;

    # patches = [
    #   ./change_wx_lock_file_location.patch
    #   ./change_config_dir.patch
    # ];

    nativeBuildInputs = [pkgs.makeWrapper copyDesktopItems];

    propagatedBuildInputs = with python3Packages; [
      requests
      tqdm
      scipy
      waitress
      bottle
      diskcache
      flake8
      psutil
      pyyaml
      platformdirs
      packaging
      filelock
      torch-bin
      torchvision-bin
      pillow
      pillow-heif
      wxpython
      av
      truststore
      safetensors
      einops
    ];

    desktopItems = [
      (makeDesktopItem {
        name = "Nunif IW3";
        exec = pname;
        icon = pname;
        desktopName = "Nunif IW3";
        comment = "Convert 2D videos into 3D ones";
        categories = ["Utility"];
      })
    ];

    buildPhase = ''
      runHook preBuild

      mkdir -p $out/${pname}
      cp -r * $out/${pname}

      mkdir -p $out/bin

      echo '#!${pkgs.bash}/bin/bash' > $out/run_gui.sh
      echo '${pkgs.python3}/bin/python3 -m iw3.gui' >> $out/run_gui.sh

      chmod +x $out/run_gui.sh

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      makeWrapper $out/run_gui.sh $out/bin/${pname} \
        --set PYTHONPATH "$PYTHONPATH:$out/${pname}:$out/${pkgs.python3.sitePackages}" \
        --set GSETTINGS_SCHEMA_DIR "${pkgs.glib.getSchemaPath pkgs.gtk3}" \

      install -Dm444 \
        ${src}/iw3/icon.ico \
        $out/share/icons/hicolor/256x256/apps/${pname}.png

      runHook postInstall
    '';
  }
