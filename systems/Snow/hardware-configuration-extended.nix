{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkDefault mkForce;
in {
  imports = with inputs; [
    ./hardware-configuration.nix
    nixos-hardware.nixosModules.common-cpu-intel-cpu-only
    nixos-hardware.nixosModules.common-gpu-intel-disable
    nixos-hardware.nixosModules.common-pc-ssd
  ];
  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        extraEntries = {};
      };
      efi.canTouchEfiVariables = true;
    };
    binfmt = {
      emulatedSystems = [
        "aarch64-linux"
        "x86_64-windows"
        # "wasm32-wasi"
        # "wasm64-wasi"
      ];
    };
    kernelModules = [
      "i2c-dev"
      "i2c-i801"
    ];
    kernelParams = ["module_blacklist=i915"];
    supportedFilesystems = ["ntfs"];
  };
  powerManagement.cpuFreqGovernor = "performance";
  sops.secrets."Charjabug/password" = {
    sopsFile = lib.TM.get-secret-file "UPS/home.yaml";
  };
  power.ups = {
    enable = true;
    mode = "netclient";
    upsmon = {
      enable = true;
      monitor.Charjabug = {
        user = "ghdsgsdgds";
        powerValue = 1;
        system = "myups@homeassistant";
        passwordFile = config.sops.secrets."Charjabug/password".path;
      };
    };
  };

  environment.systemPackages = with pkgs; [headsetcontrol via qmk qmk_hid dos2unix];
  services = {
    blueman.enable = true;
    fwupd.enable = true;
    udev = {
      packages = with pkgs; [liquidctl headsetcontrol via qmk-udev-rules];
      extraRules = ''
        SUBSYSTEM=="usb", ATTR{idVendor}=="2104", ATTR{idProduct}=="0313", MODE="0666"
      '';
    };
  };
  hardware = {
    # uni-sync = { enable = true; };
    bluetooth = {
      enable = true;
      settings.general = {
        Experimental = true;
      };
    };
    openrazer = {
      enable = true;
      users = [config.users.users.melody.name];
    };
    keyboard.qmk.enable = true;
  };
  networking.interfaces.enp7s0.wakeOnLan.enable = true;

  # # Set docker storage driver to btrfs
  # virtualisation.docker.storageDriver = "btrfs";
  virtualisation.vmVariant = {
    disko.devices = mkForce (import ./disko-vm.nix {inherit lib;});
  };
  # TPM
  # security.tpm2.enable = true;
  # security.tpm2.pkcs11.enable = true;
  # security.tpm2.tctiEnvironment.enable = true;

  TM = {
    programs.wine.binfmt = true;
    isGui = mkDefault true;
    isDesktop = mkDefault true;
    hasHDRDisplay = mkDefault true;
    hasWifi7 = mkDefault true;
    # Enable Nvidia stuff
    MyNextGPUWillNotBeNvidia = true;
    services.liquidctl = {
      enable = true;
      config = {
        "NZXT Kraken Z" = {
          commands = [
            "set pump speed 100"
            "set fan speed 100"
            "set lcd screen gif ${pkgs.fetchurl {
              url = "https://cdn.little-melody.net/Public/Linux/Wallpaper/eevee.gif";
              hash = "sha512-ocpAItFUQyVsJvrcwfUUqPu7ZwaglHvNH0rNbJXWjkkqllBYdeliVEHj/W45p1+/Y5LfYRe204osM67aWIdCtg==";
            }}"
          ];
        };
      };
    };
  };
  topology.self.interfaces.enp7s0.network = "home";
}
