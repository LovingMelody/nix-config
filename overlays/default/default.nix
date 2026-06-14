{
  self,
  lib,
  inputs,
  ...
}: let
  inherit (inputs) nix-reshade spicetify-nix;
  inherit (lib.TM.package-helper) pins patchLibcuda blacklistPatches shortRev;
  # shortRev = s: builtins.substring 0 7 s;
in
  final: prev: let
    # pinnedOverlay = pkg:
    #   prev.${pkg}.overrideAttrs {
    #     src = pins.${pkg};
    #     version = pins.${pkg}.version or "git+${pins.${pkg}.revision}";
    #   };
    # discordEnableKrisp = pkg: let
    #   patch-krisp = prev.writers.writePython3 "krisp-patcher" {
    #     libraries = with prev.python3Packages; [
    #       capstone
    #       pyelftools
    #     ];
    #     # Ignore syntax checker error codes that affect krisp-patcher.py
    #     flakeIgnore = [
    #       "E501"
    #       "F403"
    #       "F405"
    #     ];
    #   } (builtins.readFile ./discord-krisp-patcher.py);
    #   binaryName = pkg.meta.mainProgram;
    #   node_module = "\\$HOME/.config/discord/${prev.discord.version}/modules/discord_krisp/discord_krisp.node";
    # in
    #   pkg.overrideAttrs (o: {
    #     postInstall =
    #       o.postInstall
    #       + ''
    #         wrapProgramShell $out/opt/${binaryName}/${binaryName} \
    #           --run "${patch-krisp} ${node_module}"
    #       '';
    #   });
    /*
    # https://github.com/NixOS/nixpkgs/issues/445447
    cmakeCompatFix = pkg: brokenVersion: pkg.overrideAttrs (o: {cmakeFlags = (o.cmakeFlags or []) ++ lib.optional (brokenVersion || (lib.versionOlder o.version brokenVersion)) "-DCMAKE_POLICY_VERSION_MINIMUM=3.5";});
    */
    clangStdenv = pkg: pkg.override {stdenv = final.clangStdenv;};
  in {
    alvr =
      prev.alvr.overrideAttrs
      (prev: {
        nativeBuildInputs = prev.nativeBuildInputs ++ lib.optional final.config.cudaSupport final.cudaPackages.cuda_nvcc;
      });
    linuxKernel =
      prev.linuxKernel
      // {
        packages =
          builtins.mapAttrs
          (_kernelName: kernelSet:
            kernelSet
            // (
              if kernelSet ? nvidiaPackages
              then {
                nvidiaPackages.beta = patchLibcuda kernelSet.nvidiaPackages.beta;
                nvidiaPackages.stable = patchLibcuda kernelSet.nvidiaPackages.stable;
              }
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
    gargoyle = blacklistPatches ((clangStdenv prev.gargoyle).overrideAttrs {
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
    nunif-iw3 = final.callPackage "${self}/packages/nunif-iw3" {inherit pins;};
    unique-basenames = final.callPackage "${self}/packages/unique-basenames" {};
    textools = final.callPackage "${self}/packages/textools" {wine = final.wine-astral;};
    # NOTE: This is pinned to the commit the model was trained against.
    rnnoise =
      (prev.rnnoise.override {
        modelUrl = "https://cdn.little-melody.net/Public/Linux/Rnn/rnnoise_data-female.tar.gz";
        modelHash = "sha256-ql2BY86a1KIOR7u5ttPYxTcPPT8WUUvQ1vw4SrwsE58=";
      }).overrideAttrs (o: {
        src = final.fetchFromGitHub {
          owner = "xiph";
          repo = "rnnoise";
          rev = "70f1d256acd4b34a572f999a05c87bf00b67730d";
          hash = "sha256-fkSy7Sqnx0yLfGLciHf8PaptzFVzFAeRrhE4R5z8hSw=";
        };
        version = shortRev "70f1d256acd4b34a572f999a05c87bf00b67730d";
        patches = [];
        env.NIX_CFLAGS_COMPILE =
          toString (o.env.NIX_CFLAGS_COMPILE or "")
          + lib.optionalString final.stdenv.hostPlatform.avx2Support " -mavx2 -mfma"
          + lib.optionalString final.stdenv.hostPlatform.avxSupport " -mavx"
          + lib.optionalString final.stdenv.hostPlatform.sse4_2Support " -msse4.2"
          + lib.optionalString final.stdenv.hostPlatform.ssse3Support " -mssse3";
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

    easyeffects =
      clangStdenv
      (prev.easyeffects.overrideAttrs (o: {
        buildInputs = o.buildInputs ++ (with final; [llvmPackages.openmp serd.dev flac libportal libportal-qt6 libsysprof-capture libogg libvorbis libopus] ++ flac.buildInputs ++ libsndfile.buildInputs);
        cmakeFlags =
          (o.cmakeFlags or [])
          ++ [
            "-DCMAKE_CXX_SCAN_FOR_MODULES=OFF"
          ];
        version = let
          cmakeVer =
            builtins.match
            ''.*project\([[:space:]]*[^[:space:]]+[[:space:]]+VERSION[[:space:]]+([0-9][0-9.]+[0-9]).*''
            (builtins.readFile "${pins.easyeffects}/CMakeLists.txt");
          ver =
            builtins.elemAt (
              if cmakeVer != null
              then cmakeVer
              else ["git"]
            )
            0;
        in
          ver + "-${shortRev pins.easyeffects.revision}";
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
