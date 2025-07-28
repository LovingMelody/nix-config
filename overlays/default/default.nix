{
  self,
  lib,
  inputs,
  ...
}: let
  inherit (inputs) nixpkgs nix-reshade;
  inherit (lib.TM.package-helper) pins patchLibcuda;
  shortRev = s: builtins.substring 0 7 s;
  allowGplAsync = pins.dxvk-gplasync.revision != "36d811356f59c0d0668621187fd3aa4d4ce6ce93";
in
  final: prev: let
    pinnedOverlay = pkg:
      prev.${pkg}.overrideAttrs {
        src = pins.${pkg};
        version = pins.${pkg}.version or "git+${pins.${pkg}.revision}";
      };
    discordEnableKrisp = pkg: let
      patch-krisp = prev.writers.writePython3 "krisp-patcher" {
        libraries = with prev.python3Packages; [
          capstone
          pyelftools
        ];
        # Ignore syntax checker error codes that affect krisp-patcher.py
        flakeIgnore = [
          "E501"
          "F403"
          "F405"
        ];
      } (builtins.readFile ./discord-krisp-patcher.py);
      binaryName = pkg.meta.mainProgram;
      node_module = "\\$HOME/.config/discord/${prev.discord.version}/modules/discord_krisp/discord_krisp.node";
    in
      pkg.overrideAttrs (o: {
        postInstall =
          o.postInstall
          + ''
            wrapProgramShell $out/opt/${binaryName}/${binaryName} \
              --run "${patch-krisp} ${node_module}"
          '';
      });
  in {
    linuxKernel =
      prev.linuxKernel
      // {
        packages =
          builtins.mapAttrs
          (_kernelName: kernelSet:
            kernelSet
            // (
              if kernelSet ? nvidiaPackages
              then {nvidiaPackages.beta = patchLibcuda kernelSet.nvidiaPackages.beta;}
              else {}
            ))
          prev.linuxKernel.packages;
      };
    npins = (final.callPackage "${pins.npins}/npins.nix" {}).overrideAttrs (o: {
      version = "${o.version}+${pins.npins.revision}";
      src = pins.npins;
    });
    photoprism = prev.photoprism.override {
      ffmpeg = final.ffmpeg-full;
      imagemagick = final.imagemagickBig;
    };
    kitty = pinnedOverlay "kitty";
    gargoyle = prev.gargoyle.overrideAttrs {
      src = pins.gargoyle;
      version = pins.gargoyle.revision;
    };
    gallery-dl = prev.gallery-dl.overrideAttrs (o: {
      inherit (pins.gallery-dl-stable) version;
      src = pins.gallery-dl-stable;
      disabledTestPaths = (o.disabledTestPaths or []) ++ ["test/test_postprocessor.py"];
    });
    gallery-dl-unstable = final.gallery-dl.overrideAttrs (o: {
      version = "${o.version}-git+${pins.gallery-dl.revision}";
      src = pins.gallery-dl;
    });
    dxvk_2 = prev.dxvk_2.overrideAttrs {
      src = pins.dxvk;
      version = "git+${pins.dxvk.revision}";
    };
    dxvk = final.callPackage "${nixpkgs}/pkgs/by-name/dx/dxvk/package.nix" {};
    dxvk-nvapi = final.callPackage "${self}/packages/dxvk-nvapi" {inherit pins;};
    inherit
      (nix-reshade.system.packages.${prev.system})
      reshade
      reshade-full
      reshade-shaders-full
      ;
    firefox-unwrapped = prev.firefox-unwrapped.override {pipewireSupport = true;};
    reshade-max = nix-reshade.system.packages.${prev.system}.complete;
    rpcs3 = prev.rpcs3.override {enableDiscordRpc = true;};
    # nix = prev.lix;
    # Overlays go here
    catppuccin-base16 = final.callPackage "${self}/packages/catppuccin-base16" {inherit pins;};
    xivlauncher-rb = final.callPackage "${self}/packages/xivlauncher-rb" {};
    rename-padded-numbers = final.callPackage "${self}/packages/rename-padded-numbers" {};
    slower = final.callPackage "${self}/packages/slower" {};
    catppuccin-obs = final.callPackage "${self}/packages/catppuccin-obs" {inherit pins;};
    nitch = final.callPackage "${self}/packages/nitch" {};
    unique-basenames = final.callPackage "${self}/packages/unique-basenames" {};
    textools = final.callPackage "${self}/packages/textools" {};
    star-citizen = prev.star-citizen.override {
      preCommands = ''
        export DXVK_LOG_LEVEL=debug
        export WINEDEBUG=
      '';
      inherit (final) wineprefix-preparer;
      wine = final.wine-astral-ntsync;
    };
    rsi-launcher = prev.rsi-launcher.override {
      disableEac = false;
      extraEnvVars = {
        DXVK_HUD = "compiler";
        MANGO_HUD = 1;
        DXVK_HDR = 1;
        NVPRESENT_ENABLE_SMOOTH_MOTION = 1;
      };
      preCommands = ''
        export DXVK_LOG_LEVEL=debug
        export WINEDEBUG=
      '';
      inherit (final) wineprefix-preparer;
      wine = final.wine-astral-ntsync;
    };
    dxvk-w64 = prev.dxvk-w64.overrideAttrs {
      pname =
        if allowGplAsync
        then "dxvk-gplasync"
        else "dxvk";
      src = pins.dxvk;
      version = "git+${pins.dxvk.revision}";
      patches = lib.optionals allowGplAsync [
        "${pins.dxvk-gplasync}/patches/dxvk-gplasync-master.patch"
        "${pins.dxvk-gplasync}/patches/global-dxvk.conf.patch"
      ];
    };
    dxvk-w32 = prev.dxvk-w32.overrideAttrs {
      pname =
        if allowGplAsync
        then "dxvk-gplasync"
        else "dxvk";
      src = pins.dxvk;
      version = "git+${pins.dxvk.revision}";
      patches = lib.optionals allowGplAsync [
        "${pins.dxvk-gplasync}/patches/dxvk-gplasync-master.patch"
        "${pins.dxvk-gplasync}/patches/global-dxvk.conf.patch"
      ];
    };
    vkd3d-proton-w64 = prev.vkd3d-proton-w64.overrideAttrs {
      src = pins.vkd3d-proton;
      version = "git+${pins.vkd3d-proton.revision}";
    };
    vkd3d-proton-w32 = prev.vkd3d-proton-w32.overrideAttrs {
      src = pins.vkd3d-proton;
      version = "git+${pins.vkd3d-proton.revision}";
    };
    wineprefix-preparer = final.callPackage ./wineprefix-preparer.nix {
      inherit (final) dxvk-w64 dxvk-w32 vkd3d-proton-w64 vkd3d-proton-w32;
    };
    wineprefix-preparer-git = final.wineprefix-preparer;
    discord = discordEnableKrisp (prev.discord.override {
      withOpenASAR = true;
      withVencord = true;
    });
    discord-canary = discordEnableKrisp (prev.discord-canary.override {
      withOpenASAR = true;
      withVencord = true;
    });
    discord-ptb = discordEnableKrisp (prev.discord-ptb.override {
      withOpenASAR = true;
      withVencord = true;
    });

    obs-studio = prev.obs-studio.override {ffmpeg = final.ffmpeg-full;};

    lutris = prev.lutris.override {
      steamSupport = true;
      extraPkgs = _pkgs: [
        final.winetricks
        final.gamescope
        final.goverlay
        final.gamemode
      ];
      extraLibraries = _pkgs: [final.mangohud];
    };

    gposingway = final.callPackage "${self}/packages/shaders/gposingway" {inherit pins;};

    mpv-unwrapped =
      (prev.mpv-unwrapped.override {
        jackaudioSupport = true;
        sdl2Support = true;
        sixelSupport = true;
        vapoursynthSupport = true;
      }).overrideAttrs {
        version = lib.removeSuffix "-" (builtins.replaceStrings ["UNKNOWN"] [(shortRev pins.mpv.revision)] (builtins.readFile "${pins.mpv}/MPV_VERSION"));
        src = pins.mpv;
      };

    /*
    Lets use lix :D
    */
    # nixForLinking = final.nixVersions.stable;
    #
    # nixVersions =
    #   prev.nixVersions
    #   // {
    #     stable = final.lix;
    #     stable_upstream = prev.nixVersions.stable;
    #   };
    #
    # nix-doc = prev.nix-doc.override {withPlugin = false;};
    # nix = final.nixVersions.stable;

    /*
    TODO: Changes to to be upstreamed
    Anthing below this line should potentially be upstreamed
    */
    obs-studio-plugins =
      prev.obs-studio-plugins
      // {
        obs-backgroundremoval = prev.obs-studio-plugins.obs-backgroundremoval.overrideAttrs {
          version = "git+${pins.obs-backgroundremoval.revision}";
          src = pins.obs-backgroundremoval;
          CUDA_BIN_PATH = "${final.cudaPackages.cudatoolkit}";
          CUDA_TOOLKIT_ROOT_DIR = "${final.cudaPackages.cudatoolkit}";
        };
        obs-ios-camera-source = final.callPackage "${self}/packages/obs-ios-camera-source" {inherit pins;};
        obs-image-reaction = final.callPackage "${self}/packages/obs-image-reaction" {inherit pins;};
      };
  }
