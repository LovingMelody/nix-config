{
  config,
  lib,
  modulesPath,
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
  TM.zfs.enable = true;
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

  nixpkgs.hostPlatform = {
    system = "x86_64-linux";
    avx2Support = true;
    fmaSupport = true;
    avxSupport = true;
    sse3Support = true;
    ssse3Support = true;
    sse4_1Support = true;
    sse4_2Support = true;
    aesSupport = true;
    # gcc.tune = "zen2";
  };
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
