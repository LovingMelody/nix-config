{
  lib,
  self,
  ...
}: let
  pins = import "${self}/npins";
in rec {
  selectHighestVersion = a: b:
    if lib.versionOlder a.version b.version
    then b
    else a;
  package-helper = {
    shortRev = s: builtins.substring 0 7 s;
    inherit pins;

    propegateInputs = package: deps:
      package.overrideAttrs (old: {
        propagatedBuildInputs =
          deps
          ++ lib.optionals (builtins.hasAttr "propagatedBuildInputs" old) old.propagatedBuildInputs;
      });
    addPatches = package: patches:
      package.overrideAttrs (old: {
        patches = patches ++ lib.optionals (builtins.hasAttr "patches" old) old.patches;
      });
    blacklistPatches = package: blacklist:
      package.overrideAttrs (o: {
        patches =
          if (builtins.hasAttr "patches" o)
          then
            if o.patches == []
            then []
            else builtins.filter (patch: lib.lists.any (b: (builtins.baseNameOf patch) == b) blacklist) (o.patches or [])
          else [];
      });
    patchLibcuda = package:
      package.overrideAttrs (old: {
        postInstall = ''
          ${
            if old ? postInstall && old.postInstall != null
            then old.postInstall
            else ""
          }
          for so in $out/lib*/libcuda.so*; do
            echo patching "$so"
            echo -ne $(od -An -tx1 -v "$so" | tr -d '\n' | sed -e 's/00 00 00 f8 ff 00 00 00/00 00 00 f8 ff ff 00 00/g' -e 's/ /\\x/g') > libcuda.patched.so
            echo "Patched, outputted to libcuda.patched.so"
            mv --verbose libcuda.patched.so "$so"
          done
        '';
      });
  };
  info = {
    flavor = "Mocha";
    url = "github:LovingMelody/nix-config";
    hostInfo = host: flake: {
      inherit (flake.nixosConfigurations.${host}.config.networking) hostName;
      platform = import (./src/hosts + "/${host}/system.nix");
      extra-platforms = flake.nixosConfigurations.${host}.config.nix.settings.extra-platforms or [];
      features = flake.nixosConfigurations.${host}.config.nix.settings.system-features;
      inherit (flake.nixosConfigurations.${host}.config.system.nixos) tags;
    };
    allHostInfo = flake: map (host: lib.TM.info.hostInfo host flake) (builtins.attrNames flake.nixosConfigurations);
  };
  styling = {
    # For using with config.TM.styles.palette;
    withPalette = palette: {
      colors = lib.mapAttrs (_name: color: {
        rgb = "rgb(${toString color.rgb.r}, ${toString color.rgb.g}, ${toString color.rgb.b})";
        rgba = alpha: "rgba(${toString color.rgb.r}, ${toString color.rgb.g}, ${toString color.rgb.b}, ${toString alpha})";
        inherit (color) hex name;
        inherit (color.rgb) r g b;
      }) (lib.filterAttrs (n: _: n != "ansiColors") palette);
      # fromColor = color: {
      #   rgb =
      #     let
      #       c = palette.${color};
      #     in
      #     "rgb(${lib.strings.removePrefix "#" c.hex})";
      #   rgba =
      #     alpha:
      #     let
      #       c = palette.${color};
      #     in
      #     "rgba(${toString c.rgb.r}, ${toString c.rgb.g}, ${toString c.rgb.b}, ${toString alpha})";
      #   inherit (palette.${color}) hex;
      #   inherit (palette.${color}.rgb) r g b;
      # };
    };
  };
  listdirs = dir: builtins.attrNames (lib.filterAttrs (_: t: t == "directory") (builtins.readDir dir));
  listfiles = dir: builtins.attrNames (lib.filterAttrs (_: t: t == "regular") (builtins.readDir dir));
  get-secret-file = file: "${self}/secrets/${file}";
  get-shared-module = name: "${self}/modules/shared/${name}";

  get-ssh-key-file = user: key: "${self}/keys/${user}/ssh/${key}";

  # Takes a string ex: "pink" and converts it to title casing "Pink"
  # toTitile: str -> str
  toTitle = str:
    (lib.toUpper (builtins.substring 0 1 str))
    + lib.toLower (builtins.substring 1 (builtins.stringLength str) str);

  stateVersion = {
    nixos = "26.05";
    # This should be the same as nixos
    home = stateVersion.nixos;
    darwin = 6;
  };
  # List of kernel versions known to be an issue
  # `~` prefixed versions cover all minor versions of the kernel
  # Otherwise the exact kernel version should be listed
  blacklistedKernelVersions = [
    # 6.19 has caused audio issues so its blacklisted for now.
    # DRM Color API is of note in this release but not available
    # For NVIDIA at this time
    # Last tested version: 6.19.13
    "~6.19"
  ];
  # Helper function that takes the kernel package set and checks if the
  # kernel version in the package set is blacklisted
  # isBlacklistedKernelVersion: kernel package set -> bool
  isBlacklistedKernelVersion = kernelPackages:
    builtins.any (
      v:
        if lib.hasPrefix "~" v
        then (lib.removePrefix "~" v) == (lib.versions.majorMinor kernelPackages.kernel.version)
        else kernelPackages.kernel.version == v
    )
    blacklistedKernelVersions;
  latestZFSKernel = pkgs: zfsPackage: let
    zfsCompatibleKernelPackages =
      lib.filterAttrs (
        name: kernelPackages:
          (builtins.match "linux_[0-9]+_[0-9]+" name)
          != null
          && (builtins.tryEval kernelPackages).success
          && (!kernelPackages.${zfsPackage.kernelModuleAttribute}.meta.broken)
          && (! isBlacklistedKernelVersion kernelPackages)
      )
      pkgs.linuxKernel.packages;
  in
    lib.last (
      lib.sort (a: b: (lib.versionOlder a.kernel.version b.kernel.version)) (
        builtins.attrValues zfsCompatibleKernelPackages
      )
    );
  # Applies a lut to an image
  # pkgs - this should be the nixpkgs package set
  # palette - list of hex codes for lutgen to work with (base16 / base24)
  # img: The image to be modified
  # This returns a new DRV with the modified image
  # IMPORTANT: This does not remove the original image from the nix store.
  #    This means that you are doubling the space taken by the image with this function
  # lutgen: pkgs ListOf[Strings] drv -> drv
  lutgen = pkgs: palette: img: let
    colors = lib.strings.concatStringsSep " " (lib.attrValues palette);
    baseName = builtins.baseNameOf img;
    lutgen = lib.getExe pkgs.lutgen;
    magick = lib.getExe pkgs.imagemagick;
  in
    pkgs.runCommand baseName {} ''
      if [[ $(${magick} identify -format '%A' '${img}') == "blend" ]]; then
        echo "image has alpha preserving..."
        ${magick} convert '${img}' -alpha extract alpha_map.png
        ${lutgen} apply '${img}' --output 'edited.png' -- ${colors}
        ${magick} convert edited.png alpha_map.png -alpha off -compose CopyOpacity -composite "$out"
      else
          ${lutgen} apply '${img}' --output "$out" -- ${colors}
      fi
    '';
}
