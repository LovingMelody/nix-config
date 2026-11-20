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
    binfmt.emulatedSystems = ["aarch64-linux"];
  };
  environment.systemPackages = [pkgs.headsetcontrol];
  services = {
    fprintd.enable = true;
    # asus-wmi has no "low-power"; quiet is the lowest profile here
    tlp.settings = {
      PLATFORM_PROFILE_ON_BAT = "quiet";
      # amd-pstate drops scaling_max_freq to nominal (3.3GHz) when boost is
      # disabled on battery and doesn't raise it again when boost is
      # re-enabled on AC, so restore the boost max explicitly.
      CPU_SCALING_MAX_FREQ_ON_AC = 4683471;
    };
    asusd = {
      enable = lib.mkDefault true;
      # TLP owns platform profile + EPP. asusd only does fan curves, charge
      # limit and aura; it still re-applies fan curves when TLP switches
      # profile (it watches platform_profile).
      asusdConfig.text = ''
        (
            charge_control_end_threshold: 80,
            base_charge_control_end_threshold: 0,
            disable_nvidia_powerd_on_battery: true,
            ac_command: "",
            bat_command: "",
            platform_profile_linked_epp: false,
            platform_profile_on_battery: Quiet,
            change_platform_profile_on_battery: false,
            platform_profile_on_ac: Performance,
            change_platform_profile_on_ac: false,
            profile_quiet_epp: Power,
            profile_balanced_epp: BalancePower,
            profile_custom_epp: Performance,
            profile_performance_epp: Performance,
            ac_profile_tunings: {},
            dc_profile_tunings: {},
            armoury_settings: {},
        )
      '';
    };
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
    nvidia.enable = true;
    virt.enable = true;
  };
  nixpkgs.config = {
    cudaSupport = lib.mkForce true;
  };
  programs = {
    rog-control-center = {
      enable = true;
      autoStart = false;
    };
  };
  environment.sessionVariables = lib.mkIf config.programs.gamemode.enable {
    GAMEMODERUNEXEC = lib.mkIf config.hardware.nvidia.prime.offload.enableOffloadCmd "nvidia-offload";
  };
  hardware = {
    bluetooth = {
      enable = true;
    };
  };

  topology.self.interfaces.wlp2s0.network = "home";
}
