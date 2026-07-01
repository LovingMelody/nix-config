{modulesPath, ...}: {
  imports = [(modulesPath + "/installer/netboot/netboot-minimal.nix")];
  TM.time.enable = false;
  services.openssh.enable = true;
  networking.networkmanager.enable = true;
  programs.starship.enable = true;
  boot.initrd.systemd.enable = false;
  TM = {
    isLaptop = true;
    isGui = false;
    autoUpgrade.enable = false;
  };
  system.nixos.tags = ["netboot"];
}
