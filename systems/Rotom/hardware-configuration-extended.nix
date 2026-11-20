{inputs, ...}: {
  imports = with inputs; [
    ./hardware-configuration.nix
    nixos-hardware.nixosModules.common-cpu-amd
  ];
  TM = {
    isDesktop = true;
    isServer = true;
    isGui = false;
  };

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
      };
      efi.canTouchEfiVariables = true;
    };
    binfmt.emulatedSystems = ["aarch64-linux"];
    supportedFilesystems = [
      "ntfs"
      "zfs"
    ];
  };
  powerManagement.cpuFreqGovernor = "performance";

  services.fwupd.enable = true;
  networking.interfaces.enp7s0.wakeOnLan.enable = true;
}
