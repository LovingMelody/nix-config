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
      incus = {
        enable = mkDefault config.networking.nftables.enable;
        socketActivation = mkDefault true;
        agent.enable = mkDefault config.virtualisation.incus.enable;
        ui.enable = mkDefault true;
      };
      podman = {
        enable = mkDefault (! config.virtualisation.docker.enable);
        dockerCompat = mkDefault (! config.virtualisation.docker.enable);
      };
      # lxc.enable = true;
      # lxd.enable = true;
      libvirtd = {
        enable = mkDefault true;
        qemu = {
          package = mkDefault pkgs.qemu_kvm;
          swtpm.enable = mkDefault true;
        };
      };
    };
  };
}
