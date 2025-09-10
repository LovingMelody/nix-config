{
  config,
  lib,
  modulesPath,
  ...
}: {
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  boot = {
    initrd = {
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
      kernelModules = [];
    };
    kernelModules = ["kvm-amd"];
    extraModulePackages = [];
  };
  #disko.devices = import ./disko.nix { inherit lib; };
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/2fc116e3-26d2-4889-aaf5-748a444a41a9";
    fsType = "btrfs";
    options = ["subvol=@"];
  };

  boot.initrd.luks.devices."luks-ca69090a-52d2-412a-bf75-17b20d990d6a".device = "/dev/disk/by-uuid/ca69090a-52d2-412a-bf75-17b20d990d6a";

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/2392-9F6D";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [];
  # fileSystems."/.persist".neededForBoot = true;

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  TM.simd.arch = "znver3";
}
