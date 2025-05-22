{lib, ...}: let
  inherit (lib) mkForce;
in {
  image.modules = {
    iso-installer = {
      services.openssh.enable = mkForce true;
      networking.wireless.enable = mkForce false;
      networking.networkmanager.enable = mkForce true;
      programs.starship.enable = true;
      boot.initrd.systemd.enable = mkForce false;
      TM = {
        isLaptop = mkForce true;
        isDesktop = mkForce false;
        isServer = mkForce false;
        isGui = mkForce false;
        autoUpgrade.enable = mkForce false;
      };
      stylix.image = mkForce null;
    };
  };
}
