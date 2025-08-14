{
  self,
  lib,
  pkgs,
  config,
  inputs,
  system,
  osConfig,
  ...
}: let
  lib-hm = inputs.home-manager.lib.hm;
  cfg = config.TM.gaming.games.ffxiv;
  gamingCfg = config.TM.gaming;
  inherit
    (lib.strings)
    concatStringsSep
    escapeShellArg
    hasPrefix
    optionalString
    splitString
    ;
  inherit (lib.attrsets) mergeAttrsList;
  inherit (lib.filesystem) listFilesRecursive;
  inherit
    (lib)
    generators
    getExe
    makeBinPath
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  inherit (builtins) map filter any;
  # Takes a shader package & installs shaders & presets
  # TODO: Include addons?
  shaderPackageToAttrs = pkg:
    mergeAttrsList (map (
        file: let
          target = ".xlcore/ffxiv/game/${file}";
          exactTarget = "${config.home.homeDirectory}/${target}";
        in {
          # Typically this wouldn't be allowed as the string
          # As attrset keys are not allowed to hold a context
          # The context is no longer relevant so we can safely
          # Remove it, in the event that the string is invalidated
          # The key simply wouldn't exist which is the desired behavior
          "${builtins.unsafeDiscardStringContext target}" = {
            source = "${pkg}/${file}";
            onChange = ''
              run mkdir -p ${escapeShellArg (builtins.dirOf exactTarget)}
              [ -e ${escapeShellArg exactTarget} ] && run rm ${escapeShellArg exactTarget}
              run cp --reflink=auto -v ${escapeShellArg "${pkg}/${file}"} ${escapeShellArg exactTarget}
              run chmod u+rw ${escapeShellArg exactTarget}
            '';
          };
        }
      ) (filter (path:
        any (dir: hasPrefix "${dir}/" path) [
          "reshade-presets"
          "reshade-shaders"
        ]) (map (path: concatStringsSep "/" (lib.lists.drop 4 (splitString "/" path))) (listFilesRecursive pkg))));
  shaderAttrsToActivationScript = attrs:
    builtins.concatStringsSep "\n" (lib.attrsets.mapAttrsToList (_name: value: value.onChange) attrs);
  shaderInstallActivation = pkgs:
    shaderAttrsToActivationScript (
      if (builtins.typeOf pkgs) == "list"
      then mergeAttrsList (map shaderPackageToAttrs pkgs)
      else shaderPackageToAttrs pkgs
    );
in {
  options.TM.gaming.games.ffxiv = {
    enable =
      mkEnableOption "Enable Final Fantasy XIV"
      // {
        default = gamingCfg.enable or false;
      };
    useGameMode =
      mkEnableOption "Enable gamemode support"
      // {
        default = osConfig.programs.gamemode.enable or false;
      };
    reshade = {
      enable =
        mkEnableOption "Enable reshade"
        // {
          default = true;
        };

      defaultPreset = mkOption {
        type = types.str;
        default = "ipsuShade/g2. ipsusuGameplay (FPS and Quality)/ipsusuGameplay - Pastel.ini";
        description = "Path to Gposingway preset";
      };

      screenshotPath = mkOption {
        type = types.str;
        default = "${config.home.homeDirectory}/Pictures/FinalFantasyXIV";
        description = "Path to FFXIV screenshots";
      };
      package = mkOption {
        type = types.package;
        default = inputs.nix-reshade.packages.${system}.complete;
        description = "Reshade package";
      };
      extraShaderPaths = mkOption {
        type = types.listOf types.path;
        default = [];
        description = "Extra shader paths";
      };
      extraTexturePaths = mkOption {
        type = types.listOf types.path;
        default = [];
        description = "Extra textures";
      };
      reshadeConfig = let
        defaultIni = import "${self}/modules/home/gaming/ffxiv/reshadeconfig.nix" {
          inherit
            pkgs
            config
            cfg
            lib
            ;
        };
      in
        mkOption {
          type = types.attrs;
          default = defaultIni;
          description = "ReShade configuration";
          example = defaultIni;
        };
    };
  };
  options.TM.experiments.shaders = mkOption {description = "Experimental option for testing";};

  config = mkIf cfg.enable {
    TM.experiments.shaders = shaderPackageToAttrs cfg.reshade.package;
    # Include rsync here so we can use it to copy the shaders
    # If this is linked in the script, the script will run when rsync is updated
    home = {
      packages = [
        (pkgs.xivlauncher-rb.override {
          inherit (cfg) useGameMode;
          nvngxPath = optionalString osConfig.TM.MyNextGPUWillNotBeNvidia "${osConfig.hardware.nvidia.package}/lib/nvidia/wine/";
          extraLibraries = _: osConfig.hardware.graphics.extraPackages ++ [osConfig.hardware.graphics.package pkgs.lsfg-vk];
          steam = osConfig.programs.steam.package or pkgs.steam;
        })
        pkgs.rsync
        pkgs.textools
      ];
      file = mkIf cfg.reshade.enable {
        # use packaged reshade
        ".xlcore/ffxiv/game/dxgi.dll".source = "${cfg.reshade.package}/lib/reshade/ReShade64.dll";

        # ".xlcore/wineprefix/drive_c/windows/system32/d3dcompiler_47.dll"
        ".xlcore/ffxiv/game/d3dcompiler_47.dll".source = "${cfg.reshade.package}/lib/d3dcompiler_47.dll";
        # FIXME: This doesn't work, ReShade.ini needs to be writable
        # FIXME: Move this to its own block thats configurable, its messy
        ".xlcore/ReShade.ini".source = let
          reshadeINI = generators.toINI {listsAsDuplicateKeys = true;} cfg.reshade.reshadeConfig;
          genInI = let
            inherit (inputs.ini-merger.packages.${system}) ini-merger;
          in
            pkgs.stdenv.mkDerivation {
              name = "ffxiv-generated-ini";
              src = "${self}/modules/home/gaming/ffxiv";
              modifiers = pkgs.writeText "Modifiers.ini" reshadeINI;
              installPhase = ''
                mkdir -p $out
                ${getExe ini-merger} '${self}/modules/home/gaming/ffxiv/ReShade.ini' $out/ReShade.ini \
                  $modifiers
              '';
            };
        in "${genInI}/ReShade.ini";
        # ".xlcore/ffxiv/game/reshade-presets" = {
        #   source = "${cfg.reshade.package}/reshade-presets";
        #   recursive = true;
        # };
        # ".xlcore/ffxiv/game/reshade-shaders" = {
        #   source = "${cfg.reshade.package}/reshade-shaders";
        #   recursive = true;
        # };
        ".xlcore/copyIni.sh" = {
          text = ''
            mkdir -p "${config.home.homeDirectory}/.xlcore/ffxiv/game"
            cp -v --no-preserve=mode,ownership --reflink=auto -f "${config.home.homeDirectory}/.xlcore/ReShade.ini" \
               "${config.home.homeDirectory}/.xlcore/ffxiv/game/ReShade.ini"
          '';
          executable = true;
          onChange = ''
            ${config.home.homeDirectory}/.xlcore/copyIni.sh
          '';
        };
        ".xlcore/ShaderCopy.sh" = {
          source = let
            name = "ShaderCopy";
            xlcore = "${config.home.homeDirectory}/.xlcore";
            script = pkgs.writeShellScriptBin name ''

              # reshade version: ${cfg.reshade.package.version or "UNKNOWN"}
              # Reshade Package path: ${cfg.reshade.package}
              mkdir -p '${xlcore}/ffxiv/game/reshade-shaders/'
              mkdir -p '${xlcore}/ffxiv/game/reshade-presets/'
              # # copy the files from nixpkgs to reshade directory
              # # This is to allow the user to modify the shaders without modifying the nix store
              # # NOTE: This is just to prevent errors, changes will be deleted on next update
              # ${getExe pkgs.rsync} -avz --no-perms --no-owner --no-group --delete \
              #     '${cfg.reshade.package}/reshade-shaders/' '${xlcore}/ffxiv/game/reshade-shaders/'
              # ${getExe pkgs.rsync} -avz --no-perms --no-owner --no-group --delete \
              #     '${cfg.reshade.package}/reshade-presets/' '${xlcore}/ffxiv/game/reshade-presets/'
              # Ensure ownership is correct
              chown -Rv "$USER" '${xlcore}/ffxiv/game/reshade-shaders'
              chown -Rv "$USER" '${xlcore}/ffxiv/game/reshade-presets'
              # find '${xlcore}/ffxiv/game/'reshade-{shaders,presets} -type f -exec chmod 644 {} \;
              # Cache to prevent this directory from being backed up, we create this from reshade
              cat > '${xlcore}/ffxiv/CACHEDIR.TAG' <<EOL
              Signature: 8a477f597d28d172789f06886806bc55
              # This file is a cache directory tag created by (application name).
              # For information about cache directory tags, see:
              #	http://www.brynosaurus.com/cachedir/
              EOL
              # Install iMMERSE Shaders -- All Extra shaders were removed in previous steps
              # Shaders Cannot be ReDistributed so we will simply check if they exist...
              # Opting to not use requireFile, I don't wish for this to fail the build if not present (its optional)
              # TODO: Consider using iMMERSE's open source shaders only
              # Ensure path exists...
              if [ -e ${xlcore}/iMMERSE ]; then
                ${getExe pkgs.rsync} -avz --no-perms --no-owner --no-group \
                  '${xlcore}/iMMERSE/Shaders/'  '${xlcore}/ffxiv/game/reshade-shaders/shaders/'
                ${getExe pkgs.rsync} -avz --no-perms --no-owner --no-group \
                  '${xlcore}/iMMERSE/Textures/'  '${xlcore}/ffxiv/game/reshade-shaders/textures/'
                find '${xlcore}/iMMERSE/Addons' -type f -iname '*.addon64' \
                  -exec cp -v {} '${xlcore}/ffxiv/game/' \;
                # Ensure ownership is correct (again)
                chown -Rv "$USER" '${xlcore}/ffxiv/game/reshade-shaders'
                chown -Rv "$USER" '${xlcore}/ffxiv/game/reshade-presets'
                chown -Rv "$USER" '${xlcore}'/ffxiv/game/*.addon64
              fi
            '';
          in "${
            pkgs.symlinkJoin {
              inherit name;
              paths = [script];
              nativeBuildInputs = with pkgs; [makeWrapper];
              postInstall = ''
                wrapProgram $out/bin/${name} \
                  --prefix PATH : ${
                  makeBinPath [
                    pkgs.bash
                    pkgs.coreutils
                    pkgs.rsync
                  ]
                }
              '';
            }
          }/bin/${name}";
          executable = true;
          # This is a hack to force the shaders to be updated when the pkg is updated
          onChange = ''
            ${config.home.homeDirectory}/.xlcore/ShaderCopy.sh
          '';
        };
        ".xlcore/reshadesetup.sh" = {
          text = ''
            # Copy the Reshade ini file to the game directory
            ${config.home.homeDirectory}/${config.home.file.".xlcore/copyIni.sh".target}
            # Copy shaders & create CACHEDIR.TAG
            ${config.home.homeDirectory}/${config.home.file.".xlcore/ShaderCopy.sh".target}
          '';
          executable = true;
        };
        ".xlcore/compatibilitytool/dxvk/dxvk-nix/x32".source = pkgs.dxvk-w32 + "/bin";
        ".xlcore/compatibilitytool/dxvk/dxvk-nix/x64".source = pkgs.dxvk-w64 + "/bin";
      };
      activation = mkIf cfg.reshade.enable {
        ffxivShaderInstall = lib-hm.dag.entryAfter ["writeBoundary"] (shaderInstallActivation cfg.reshade.package);
      };
    };
  };
}
