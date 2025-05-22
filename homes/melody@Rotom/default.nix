{lib, ...}: {
  TM.home-profiles.desktop.enable = false;
  home.stateVersion = lib.TM.stateVersion.nixos;
}
