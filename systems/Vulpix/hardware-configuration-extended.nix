{
  lib,
  inputs,
  config,
  pkgs,
  ...
}: {
  imports = with inputs; [
    ./hardware-configuration.nix
    nixos-hardware.nixosModules.common-cpu-amd
    nixos-hardware.nixosModules.common-cpu-amd-pstate
    nixos-hardware.nixosModules.common-pc-laptop-ssd
    nixos-hardware.nixosModules.common-pc-laptop
    nixos-hardware.nixosModules.asus-zephyrus-ga401
    nixos-hardware.nixosModules.asus-battery
    nixos-hardware.nixosModules.common-gpu-nvidia
  ];
  boot = {
    initrd.systemd.enable = true;
    binfmt.emulatedSystems = ["aarch64-linux"];
  };
  #TM.MyNextGPUWillNotBeNvidia = true;
  environment.systemPackages = [pkgs.headsetcontrol];
  services = {
    fprintd.enable = true;
    asusd.enable = lib.mkDefault true;
    fwupd.enable = true;
    udev.packages = [pkgs.headsetcontrol];
  };
  networking = {
    hostName = "Vulpix"; # Define your hostname.
    hostId = "7c40a3b8";
  };
  TM = {
    hasHDRDisplay = lib.mkDefault false;
    programs.wine.binfmt = true;
    zfs.enable = false;
    isLaptop = true;
    virt.enable = true;
  };
  nixpkgs.config = {
    rocmSupport = true;
    cudaSupport = true;
  };
  programs = {
    gamemode.enable = true;
    rog-control-center = {
      enable = true;
      autoStart = true;
    };
  };
  environment.sessionVariables = lib.mkIf config.programs.gamemode.enable {
    GAMEMODERUNEXEC = lib.mkIf config.hardware.nvidia.prime.offload.enableOffloadCmd "nvidia-offload";
  };
  hardware = {
    nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;
    # uni-sync = { enable = true; };
    bluetooth = {
      enable = true;
    };
    # openrazer = {
    #   enable = true;
    #   users = [ config.users.users.melody.name ];
    # };
  };

  #hardware.nvidia.modesetting.enable = true;
  #services.logind.lidSwitch = "ignore";
  topology.self.interfaces.wlp2s0.network = "home";
}
