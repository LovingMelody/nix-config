{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkForce;
in {
  # AMD :    pci-0000:04:00.0-card
  # NVIDIA : pci-0000:01:00.0-card
  imports = [./hardware-configuration-extended.nix];
  # Use lix
  TM = {
    vr = {
      enable = true;
      useWivrn = true;
    };
    pokemon = {
      name = "Vulpix";
      pokedex = 37;
    };
    knowsHiddenMove = true;
    isGui = true;
    isLaptop = true;
    defaultNetworkAdapter = "wlp2s0";
    autoUpgrade.enable = true;
    # ZFS Cannot safely be suspended & hibernate.
    # Making it not suitable for laptops
    zfs.enable = false;
    users.enable = true;
    time.enable = true;
    sound.enable = true;
    security = {
      enableTPM = true;
      enableSecureBoot = true;
    };
    desktop = {
      hyprland = {
        enable = false;
      };
    };
    impermanence.enable = false;
    airplay.client.enable = true;
    programs = {
      _1password = {
        enable = true;
      };
    };
    gaming = {
      enable = true;
      cachyPatches = false;
    };
    services.ai.ollama.enable = true;
  };
  stylix.fonts.sizes = {
    terminal = mkForce 14;
    desktop = mkForce 12;
    applications = mkForce 12;
    popups = mkForce 10;
  };
  services = {
    desktopManager.cosmic.enable = false;

    desktopManager.plasma6.enable = true;
    displayManager.plasma-login-manager = {
      enable = true;
    };
    xserver = {
      enable = true;
      xkb.layout = "us";
    };

    openssh.enable = true;
  };

  boot = {
    loader = {
      systemd-boot.enable = false;
      limine.enable = true;
      efi.canTouchEfiVariables = true;
    };

    plymouth.enable = true;
  };
  programs = {
    _1password-gui.polkitPolicyOwners = ["melody"];
    gamemode.settings.gpu.gpu_device = 0;
    gnome-disks.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    kdeconnect.enable = true;
    mosh.enable = true;
    noisetorch.enable = true;
    partition-manager.enable = true;
    opengamepadui = {
      enable = false;
      inputplumber.enable = config.programs.opengamepadui.enable;
    };
    nix-ld = {
      enable = true;
      libraries = with pkgs; [gamemode];
    };
  };
  networking = {
    networkmanager.enable = true;
    useDHCP = false;
    interfaces.wlp2s0.useDHCP = true;
  };

  users.users.melody.packages = [pkgs.nmap];
  environment.systemPackages = with pkgs; [
    git
    _1password-cli
    _1password-gui
    spotify
    vscode
    android-tools
    #KDE
    kdePackages.discover
    kdePackages.kcalc
    kdePackages.kcharselect
    kdePackages.kclock
    kdePackages.kcolorchooser
    kdePackages.kolourpaint
    kdePackages.ksystemlog
    kdiff3
    kdePackages.isoimagewriter
    kdePackages.partitionmanager
    hardinfo2
    wayland-utils
    wl-clipboard
  ];

  security.polkit.enable = true;

  boot.kernelPackages = mkForce (lib.TM.latestZFSKernel pkgs config.boot.zfs.package);
}
