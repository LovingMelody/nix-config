{
  lib,
  config,
  ...
}:
{
  imports = [(lib.TM.get-shared-module "defaults")];
}
// lib.mkIf (builtins.hasAttr "home-manager" config) {
  config.home-manager.backupFileExtension = lib.mkDefault "home-backup";
}
