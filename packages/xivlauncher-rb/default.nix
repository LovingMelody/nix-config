{
  lib,
  xivlauncher,
  pins,
  makeDesktopItem,
  steam,
  aria2,
  useGameMode ? false,
  useSteamRun ? true,
  nvngxPath ? "",
}: let
  inherit (pins) xivlauncher-rb;
  version = lib.strings.removePrefix "rb-v" xivlauncher-rb.version;
in
  (xivlauncher.override {inherit useSteamRun;}).overrideAttrs (o: {
    pname = "xivlauncher-rb";
    src = pins.xivlauncher-rb;
    inherit version;
    nugetDeps = ./deps.json; # File generated with `nix-build -A xivlauncher-rb.passthru.fetch-deps`

    # please do not unpin these even if they match the defaults, xivlauncher is sensitive to .NET versions
    dotnetFlags = [
      "-p:BuildHash=${version}"
      "-p:PublishSingleFile=false"
    ];

    executables = ["XIVLauncher.Core"];

    desktopItems = [
      (makeDesktopItem {
        name = "xivlauncher-rb";
        exec = "XIVLauncher.Core";
        icon = "xivlauncher";
        desktopName = "XIVLauncher-RB";
        comment = o.meta.description;
        categories = ["Game"];
        startupWMClass = "XIVLauncher.Core";
      })
    ];
    postFixup =
      lib.optionalString useSteamRun (
        let
          steam-run =
            (steam.override {
              extraPkgs = pkgs:
                [
                  pkgs.libunwind
                  pkgs.zstd
                ]
                ++ lib.optional useGameMode pkgs.gamemode;
              extraProfile = ''
                unset TZ
              '';
            }).run;
        in ''
          substituteInPlace $out/bin/XIVLauncher.Core \
            --replace 'exec' 'exec ${steam-run}/bin/steam-run'
        ''
      )
      + ''
        wrapProgram $out/bin/XIVLauncher.Core --prefix GST_PLUGIN_SYSTEM_PATH_1_0 ":" "$GST_PLUGIN_SYSTEM_PATH_1_0" --prefix XL_NVNGXPATH ":" ${nvngxPath}
        # the reference to aria2 gets mangled as UTF-16LE and isn't detectable by nix: https://github.com/NixOS/nixpkgs/issues/220065
        mkdir -p $out/nix-support
        echo ${aria2} >> $out/nix-support/depends
      '';
  })
