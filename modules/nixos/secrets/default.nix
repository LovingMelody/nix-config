{lib, ...}: {
  imports = [(lib.TM.get-shared-module "secrets")];
}
