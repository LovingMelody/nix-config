{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.TM.virt;
  inherit (lib) mkDefault mkEnableOption mkIf;
in {
  options.TM.virt = {
    enable = mkEnableOption "Enable Virtualisation";
  };

  config = mkIf cfg.enable {
    virtualisation = {
      # lxc.enable = true;
      # lxd.enable = true;
      libvirtd = {
        enable = mkDefault true;
        qemu = {
          package = mkDefault pkgs.qemu_kvm;
          swtpm.enable = mkDefault true;
          ovmf = {
            enable = true;
            packages = [
              (pkgs.OVMF.override {
                secureBoot = true;
                tpmSupport = true;
              })
              .fd
            ];
          };
        };
      };
    };
  };
}
