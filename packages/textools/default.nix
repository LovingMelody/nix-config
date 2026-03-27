{
  lib,
  pkgs,
  wine ? pkgs.wineWow64Packages.stable,
  fetchurl,
  writeShellScriptBin,
  winetricks,
  location ? "$HOME/Games/TexToolsFFXIV",
}: let
  version = "3.1.0.2";
  src = fetchurl {
    url = "https://github.com/TexTools/FFXIV_TexTools_UI/releases/download/v${version}/Install_TexTools.exe";
    hash = "sha256-tL8Ym1WTfPsR/VS552Kqd/q39IpAFCPLY6VKziBsoVM=";
  };
in
  writeShellScriptBin "textools" ''
    export WINETRICKS_LATEST_VERSION_CHECK='disabled'
    export WINEARCH='win32'
    mkdir -p "${location}"
    export WINEPREFIX="$(readlink -f "${location}")"
    export PATH="${lib.makeBinPath [wine winetricks]}:$PATH"
    export USER="$(whoami)"
    export WINEDLLOVERRIDES='winemenubuilder.exe=d'
    TEXTOOLS="$WINEPREFIX/drive_c/Program Files/FFXIV TexTools/FFXIV_TexTools/FFXIV_TexTools.exe"
    if ![ -f $TEXTOOLS ]; then
      winetricks -q -f corefonts tahoma dotnet48 win10
      wineserver -k
      wine ${src} /S
      # Vulkan renderer needed
      # NOTE: DXVK doesn't work here
      wine reg add "HKCU\Software\Wine\AppDefaults\FFXIV_TexTools.exe\Direct3D" /v renderer /t REG_SZ /d vulkan /f
      wineserver -k
    fi
    wine "$TEXTOOLS"
  ''
