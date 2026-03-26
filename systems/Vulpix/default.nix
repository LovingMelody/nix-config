{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkForce readFile;
in {
  # AMD :    pci-0000:04:00.0-card
  # NVIDIA : pci-0000:01:00.0-card
  imports = [./hardware-configuration-extended.nix];
  TM = {
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
    # defaults.enable = true;
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
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
  };
  programs.opengamepadui = {
    enable = false;
    inputplumber.enable = config.programs.opengamepadui.enable;
  };
  # services.displayManager.cosmic-greeter.enable = true;
  TM.desktop.gnome.enable = false;
  # specialisation = {
  #   # Configs has conflits w/ gnome & wayland doesnt run the best w/ nvidia
  #   gnome = {
  #     inheritParentConfig = true;
  #     configuration = {
  #       environment.etc."specialisation".text = "gnome";
  #       TM.desktop.gnome.enable = mkForce true;
  #       TM.desktop.hyprland.enable = mkForce false;
  #     };
  #   };
  #   cosmic = {
  #     inheritParentConfig = true;
  #     configuration = {
  #       environment.etc."specialisation".text = "cosmic";
  #       TM.desktop.gnome.enable = mkForce false;
  #       TM.desktop.hyprland.enable = mkForce false;
  #       services.desktopManager.cosmic.enable = true;
  #       services.displayManager.cosmic-greeter.enable = true;
  #     };
  #   };
  # };
  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      systemd-boot.enable = false;
      limine.enable = true;
      efi.canTouchEfiVariables = true;
    };

    # Polymouth
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
  };
  networking = {
    networkmanager.enable = true;
    useDHCP = false;
    interfaces.wlp2s0.useDHCP = true;
  };

  # Enable the X11 windowing system.
  services = {
    xserver = {
      enable = true;

      # Configure keymap in X11
      xkb.layout = "us";
    };

    openssh.enable = true;
  };

  users.users.melody.packages = [pkgs.nmap];
  environment.systemPackages = with pkgs; [
    firefox
    git
    _1password-cli
    _1password-gui
    spotify
    vscode
    nil
    android-tools
    # yubioath-flutter
    #KDE
    kdePackages.discover # Optional: Install if you use Flatpak or fwupd firmware update sevice
    kdePackages.kcalc # Calculator
    kdePackages.kcharselect # Tool to select and copy special characters from all installed fonts
    kdePackages.kclock # Clock app
    kdePackages.kcolorchooser # A small utility to select a color
    kdePackages.kolourpaint # Easy-to-use paint program
    kdePackages.ksystemlog # KDE SystemLog Application
    kdePackages.sddm-kcm # Configuration module for SDDM
    kdiff3 # Compares and merges 2 or 3 files or directories
    kdePackages.isoimagewriter # Optional: Program to write hybrid ISO files onto USB disks
    kdePackages.partitionmanager # Optional: Manage the disk devices, partitions and file systems on your computer
    # Non-KDE graphical packages
    hardinfo2 # System information and benchmarks for Linux systems
    wayland-utils # Wayland utilities
    wl-clipboard # Command-line copy/paste utilities for Wayland
  ];

  security.polkit.enable = true;

  home-manager.users.melody = {
    services.linux-wallpaperengine = {
      enable = false;
      wallpapers = [
        {
          monitor = "eDP-1";
          wallpaperId = "2800570496";
          fps = 30;
          audio = {
            silent = true;
            processing = false;
            automute = false;
          };
        }
      ];
    };
    stylix.fonts.sizes = {
      terminal = mkForce 14;
      desktop = mkForce 12;
      applications = mkForce 12;
      popups = mkForce 10;
    };
    xdg.configFile."uwsm/env-hyprland".text = ''
      export AQ_DRM_DEVICES="/dev/dri/card1:/dev/dri/card0"
    '';
    wayland.windowManager.hyprland.settings.monitor = [
      "eDP-1, preferred, 0x0, 1"
      ", preferred, auto, 1"
      "Unknown-1,disable"
    ];
    programs = {
      direnv.enable = true;
    };
    TM = {
      home-profiles.desktop.enable = true;
      impermanence.enable = false;
      # defaults.enable = true;
      programs = {
        _1password = {
          enable = true;
          sshAgent = true;
          gpgSign = {
            enable = true;
            signingKey = lib.removeSuffix "\n" (readFile (lib.TM.get-ssh-key-file "melody" "primary"));
          };
        };
        git.enable = true;
      };
    };
  };
}
