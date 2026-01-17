{
  config,
  lib,
  modulesPath,
  pkgs,
  ...
}: {
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  boot = {
    initrd = {
      systemd.enable = true;
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "sd_mod"
      ];
      kernelModules = [];
    };
    kernelModules = ["kvm-amd"];
    extraModulePackages = [];
  };
  TM.zfs = {
    enable = true;
    useUnstable = lib.versionAtLeast "6.14" (lib.TM.latestZFSKernel pkgs pkgs.zfs).kernel.version;
  };
  environment.etc."mdadm.conf".text = ''
    MAILADDR root
  '';

  disko.devices = import ./disko.nix {inherit lib;};

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  networking.hostId = "46dbfa49";
  # networking.interfaces.enp7s0.useDHCP = lib.mkDefault true;
  TM.simd.arch = "znver2";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
