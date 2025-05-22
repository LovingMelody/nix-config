{lib, ...}: {
  TM.home-profiles.desktop.enable = true;
  home.stateVersion = lib.TM.stateVersion.nixos;
}
