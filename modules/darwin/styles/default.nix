{
  lib,
  inputs,
  ...
}: {
  imports = [(lib.TM.get-shared-module "styles") "${inputs.catppuccin}/modules/global.nix"];
}
