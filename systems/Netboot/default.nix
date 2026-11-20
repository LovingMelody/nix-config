{modulesPath, ...}: {
  imports = [(modulesPath + "/installer/netboot/netboot-minimal.nix")];
  TM.time.enable = false;
  services.openssh.enable = true;
  networking.networkmanager.enable = true;
  # ZFS support comes from netboot-minimal; root is never ZFS here, so never force-import pools
  boot.zfs.forceImportRoot = false;
  programs.starship.enable = true;
  TM = {
    isLaptop = true;
    isGui = false;
    autoUpgrade.enable = false;
  };
  system.nixos.tags = ["netboot"];
}
