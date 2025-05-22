{
  lib,
  inputs,
  ...
}: {
  imports = [
    (lib.TM.get-shared-module "neovim")
  ];
}
