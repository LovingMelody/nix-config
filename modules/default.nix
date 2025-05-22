{
  self,
  lib,
  ...
}: let
  listImports = dir: builtins.attrNames (lib.filterAttrs (_: t: t == "directory") (builtins.readDir dir));
in {
  flake = {
    nixosModules.TM = {imports = listImports "${self}/modules/nixos";};
    homeModules.TM = {imports = listImports "${self}/modules/home";};
  };
}
