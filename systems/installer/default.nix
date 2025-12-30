{lib, ...}: {
  services.openssh.enable = true;
  networking.wireless.enable = true;
  networking.networkmanager.enable = true;
  programs.starship.enable = true;
  boot.initrd.systemd.enable = false;
  TM = {
    isLaptop = true;
    isGui = false;
    autoUpgrade.enable = false;
  };
  fileSystems = {
    "/" = {
      device = "/dev/sda1";
      fsType = "ext4";
    };
  };
  boot.loader.systemd-boot.enable = lib.mkDefault true;
}
