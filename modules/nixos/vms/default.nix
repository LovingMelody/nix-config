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
        enable = mkDefault false;
        socketActivation = mkDefault true;
        agent.enable = mkDefault false;
        ui.enable = mkDefault false;
      };
      podman = {
        enable = mkDefault (! config.virtualisation.docker.enable);
        dockerCompat = mkDefault (! config.virtualisation.docker.enable);
      };
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
