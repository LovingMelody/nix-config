{
  lib,
  pkgs,
  wine ? pkgs.wineWowPackages.stable,
  fetchurl,
  writeShellScriptBin,
  winetricks,
  location ? "$HOME/Games/TexToolsFFXIV",
}: let
  version = "3.1.0.1";
  src = fetchurl {
    url = "https://github.com/TexTools/FFXIV_TexTools_UI/releases/download/v${version}/Install_TexTools.exe";
    hash = "sha512-ht7ML8T7o+ihHbhsRj4FAd0A2W4HYN4dLj5WGq4EkWX0eqQlYQnFex9KsnJh2CgAfpV3LTMGofDKa/Ly7Lx+GQ==";
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
