{
  config,
  lib,
  modulesPath,
  pkgs,
  ...
}: {
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  boot = {
    swraid.mdadmConf = ''
      MAILADDR root
    '';
    initrd = {
      systemd.enable = true;
      availableKernelModules = [
        "vmd"
        "xhci_pci"
        "ahci"
        "nvme"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
      kernelModules = [];
    };
    kernelModules = ["kvm-intel"];
    extraModulePackages = [];
  };
  TM.zfs = {
    enable = true;
    useUnstable = lib.versionOlder pkgs.zfs.version "2.4.0";
  };

  disko.devices = import ./disko.nix {inherit lib;};
  environment.etc.crypttab.text = let
    inherit (config.disko.devices.disk.z.content.partitions.luks.content.settings) keyFile;
  in ''
    # See man crypttab
    crypted UUID=133b06a1-5596-4fc3-b662-e81079e40133 ${keyFile} - discard
  '';
  fileSystems = {
    "/home/melody/.xlcore".options = ["x-gvfs-hide"];
    "/home/melody/FinalFantasy".options = ["x-gvfs-hide"];
    "/home/melody/ffxiv-extras/Mare".options = ["x-gvfs-hide"];
    "/home/melody/ffxiv-extras/Penumbra".options = ["x-gvfs-hide"];
    "/home/melody/OneDrive".options = ["x-gvfs-hide"];
    "/home/melody/Games".options = ["x-gvfs-hide"];
    "/.persistent".neededForBoot = true;
  };
  system.activationScripts.melFileSystemPerms = {
    text = ''
      # These are ZFS mountpoints, lets just set them to ensure its correct
      chown melody:games /home/melody/ffxiv-extras/Mare
      chown melody:games /home/melody/ffxiv-extras/Penumbra
      chown melody:games /home/melody/.xlcore
      chown melody:games /home/melody/FinalFantasy
    '';
  };

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  networking.hostId = "d65ab8b2";
  # networking.interfaces.enp7s0.useDHCP = lib.mkDefault true;

  TM.simd.arch = "alderlake";

  # nixpkgs.hostPlatform = {
  #   system =  "x86_64-linux";
  # };
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
