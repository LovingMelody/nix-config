{
  lib,
  modulesPath,
  ...
}: {
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  # initrd/kvm modules, microcode and simd.arch come from ./facter.json
  # (modules/nixos/helpers/facter.nix + TM.defaults.hardwareTuning).
  disko.devices = import ./disko.nix {inherit lib;};
}
