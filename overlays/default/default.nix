{
  self,
  lib,
  inputs,
  ...
}: let
  inherit (inputs) nixpkgs nix-reshade spicetify-nix;
  inherit (lib.TM.package-helper) pins patchLibcuda blacklistPatches shortRev;
  # shortRev = s: builtins.substring 0 7 s;
  allowGplAsync = pins.dxvk-gplasync.revision != "159ee8ef743d18769dfea284ea95393aca6b8421";
in
  final: prev: let
    # pinnedOverlay = pkg:
    #   prev.${pkg}.overrideAttrs {
    #     src = pins.${pkg};
    #     version = pins.${pkg}.version or "git+${pins.${pkg}.revision}";
    #   };
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
    /*
    # https://github.com/NixOS/nixpkgs/issues/445447
    cmakeCompatFix = pkg: brokenVersion: pkg.overrideAttrs (o: {cmakeFlags = (o.cmakeFlags or []) ++ lib.optional (brokenVersion || (lib.versionOlder o.version brokenVersion)) "-DCMAKE_POLICY_VERSION_MINIMUM=3.5";});
    */
    clangStdenv = pkg: pkg.override {stdenv = final.clangStdenv;};
  in {
    alvr = (prev.alvr.overrideAttrs
      (prev: {
        nativeBuildInputs = prev.nativeBuildInputs ++ lib.optional final.config.cudaSupport final.cudaPackages.cuda_nvcc;
      })).override {
      /*
      ffmpeg = final.ffmpeg-full;
      */
    };
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
      version = "${o.version}+${shortRev pins.npins.revision}";
      src = pins.npins;
    });
    inherit (inputs.nixpkgs-using.packages.${final.stdenv.hostPlatform.system}) nixpkgs-using;
    inherit (inputs.moonlight-mod.packages.${final.stdenv.hostPlatform.system}) moonlight;
    osm-gps-map = prev.osm-gps-map.overrideAttrs (o: {
      buildInputs = o.buildInputs ++ [final.gtk-doc];
      nativeBuildInputs = (o.nativeBuildInputs or []) ++ [final.autoreconfHook];
    });
    photoprism = prev.photoprism.override {
      ffmpeg = final.ffmpeg-full;
      imagemagick = final.imagemagickBig;
    };
    # kitty = pinnedOverlay "kitty";
    gargoyle = blacklistPatches ((prev.gargoyle.override {stdenv = final.clangStdenv;}).overrideAttrs {
      src = pins.gargoyle;
      version = builtins.replaceStrings ["\n"] [""] "${builtins.readFile (pins.gargoyle + "/VERSION")}-${shortRev pins.gargoyle.revision}";
    }) ["ftbfs_gcc14.patch" "cmake4-fix"];
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
      (nix-reshade.system.packages.${final.stdenv.hostPlatform.system})
      reshade
      reshade-full
      reshade-shaders-full
      ;
    firefox-unwrapped = prev.firefox-unwrapped.override {pipewireSupport = true;};
    reshade-max = nix-reshade.system.packages.${final.stdenv.hostPlatform.system}.complete;
    rpcs3 = prev.rpcs3.override {enableDiscordRpc = true;};
    # nix = prev.lix;
    # Overlays go here
    catppuccin-base16 = final.callPackage "${self}/packages/catppuccin-base16" {inherit pins;};
    xivlauncher-rb = final.callPackage "${self}/packages/xivlauncher-rb" {inherit pins;};
    rename-padded-numbers = final.callPackage "${self}/packages/rename-padded-numbers" {};
    slower = final.callPackage "${self}/packages/slower" {};
    catppuccin-obs = final.callPackage "${self}/packages/catppuccin-obs" {inherit pins;};
    nitch = final.callPackage "${self}/packages/nitch" {};
    iw3 = final.callPackage "${self}/packages/iw3" {inherit pins;};
    unique-basenames = final.callPackage "${self}/packages/unique-basenames" {};
    textools = final.callPackage "${self}/packages/textools" {wine = final.wine-astral;};
    star-citizen = prev.star-citizen.override {
      preCommands = ''
        export DXVK_LOG_LEVEL=debug
        export WINEDEBUG=
      '';
      inherit (final) wineprefix-preparer;
      wine = final.wine-astral;
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
      wine = final.wine-astral;
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
      withOpenASAR = false;
      withVencord = false;
      withMoonlight = true;
    });
    discord-canary = discordEnableKrisp (prev.discord-canary.override {
      withOpenASAR = false;
      withVencord = true;
      withMoonlight = false;
    });
    discord-ptb = discordEnableKrisp (prev.discord-ptb.override {
      withOpenASAR = false;
      withVencord = false;
      withMoonlight = false;
    });

    obs-studio = prev.obs-studio.overrideAttrs (o: {
      buildInputs = o.buildInputs ++ [final.rnnoise final.libsysprof-capture];
    });

    linux-wallpaperengine = prev.linux-wallpaperengine.overrideAttrs {
      src = pins.linux-wallpaperengine;
      version = pins.linux-wallpaperengine.revision;
    };

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
        ffmpeg = final.ffmpeg-full;
        stdenv = final.clangStdenv;
      }).overrideAttrs (o: {
        # version = lib.removeSuffix "-" (builtins.replaceStrings ["UNKNOWN"] [(shortRev pins.mpv.revision)] (builtins.readFile "${pins.mpv}/MPV_VERSION"));
        # src = pins.mpv;
        # patches = [];
        mesonFlags = builtins.filter (flag: ! (builtins.elem flag [(lib.mesonEnable "sdl2" false) (lib.mesonEnable "sdl2" true)])) (o.mesonFlags or []);
      });
    mpv-mpris = prev.mpv-mpris.override {
      ffmpeg = final.ffmpeg-full;
      stdenv = final.clangStdenv;
    };

    vivaldi = prev.vivaldi.override {
      proprietaryCodecs = true;
      inherit (final) vivaldi-ffmpeg-codecs;
    };

    spicePkgs = spicetify-nix.legacyPackages.${final.stdenv.hostPlatform.system};

    # EasyEffects on OpenSuse uses clang, mimic that
    easyeffects = clangStdenv (prev.easyeffects.overrideAttrs (o: {
      buildInputs = o.buildInputs ++ (with final; [llvmPackages.openmp serd.dev flac libportal libportal-qt6 libsysprof-capture libogg libvorbis libopus] ++ flac.buildInputs ++ libsndfile.buildInputs);
      cmakeFlags =
        (o.cmakeFlags or [])
        ++ [
          "-DCMAKE_CXX_SCAN_FOR_MODULES=OFF"
        ];
      version = pins.easyeffects.version;
      src = pins.easyeffects;
    }));

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

    # r2modman = prev.r2modman.overrideAttrs {
    #   src = pins.r2modman;
    #   inherit (pins.r2modman) version;
    #   offlineCache = final.fetchYarnDeps {
    #     yarnLock = "${pins.r2modman}/yarn.lock";
    #     hash = "sha256-V6N0RIjT3etoP6XdZhnQv4XViLRypp/JWxnb0sBc6Oo=";
    #   };
    # };

    /*
    Temp Fixes
    https://github.com/NixOS/nixpkgs/issues/445447
    */

    /*
    FFMPEG Fixes
    */
    # gmic = if lib.versionOlder prev.gmic.version "3.6.3" then
    #   prev.gmic.overrideAttrs { ffmpeg = final.ffmpeg_7; }

    # Apply Fix from NixOS/nixpkgs#457803
    /*
    TODO: Changes to to be upstreamed
    Anthing below this line should potentially be upstreamed
    */
    obs-studio-plugins =
      prev.obs-studio-plugins
      // {
        obs-backgroundremoval = prev.obs-studio-plugins.obs-backgroundremoval.overrideAttrs {
          # version = "git+${pins.obs-backgroundremoval.revision}";
          # src = pins.obs-backgroundremoval;
          CUDA_BIN_PATH = "${final.cudaPackages.cudatoolkit}";
          CUDA_TOOLKIT_ROOT_DIR = "${final.cudaPackages.cudatoolkit}";
        };
        obs-ios-camera-source = final.callPackage "${self}/packages/obs-ios-camera-source" {inherit pins;};
        obs-image-reaction = final.callPackage "${self}/packages/obs-image-reaction" {inherit pins;};
      };
  }
