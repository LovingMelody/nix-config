{
  pkgs,
  config,
  inputs,
  lib,
  system,
  ...
}: let
  inherit (lib) mkForce mkIf;
in {
  imports = [./hardware-configuration-extended.nix];

  TM = {
    pokemon = {
      name = "Vulpix";
      pokedex = 37;
      variant = "Alolan";
    };
    knowsHiddenMove = true;
    defaultNetworkAdapter = "wlp7s0f0";
    vr = {
      enable = true;
      useWivrn = true;
    };
    services.ai = {
      ollama.enable = true;
      # Disabled till this issue is resolved
      # https://github.com/NixOS/nixpkgs/issues/321920
      open-webui.enable = false;
    };
    isDesktop = true;
    isGui = true;
    autoUpgrade.operation = "boot";
    virt.enable = true;
    autoUpgrade.enable = false;
    users.enable = true;
    time.enable = true;
    gaming.enable = true;
    streaming.enable = true;
    sound.enable = true;
    security = {
      opensnitch.enable = false;
      enable = true;
      # TPM2 unlock is currently broken
      # https://github.com/NixOS/nixpkgs/issues/265366
      enableTPM = false;
      enableSecureBoot = false;
    };
    desktop = {
      gnome.enable = false;
      hyprland = {
        enable = false;
      };
    };
    programs = {
      spotify.enable = true;
      _1password.enable = true;
    };

    styles = {
      flavor = "Mocha";
      accent = "Lavender";
      enable = true;
      editImage = config.TM.styles.flavor != "Latte";
      # generateBase16 = false;
      wallpaper =
        if config.TM.styles.flavor == "Latte"
        then
          pkgs.fetchurl {
            url = "https://cdn.little-melody.net/Public/Linux/Wallpaper/kuromi-melody.png";
            hash = "sha512-QjmS3bVinfN1ViQNjlh753qHnPGvnD47WleL3q+PoEdibwAxPeByTXOVRGY+TU/ALXImnhOyxMhvYAXPTE70cg==";
          }
        else
          pkgs.fetchurl {
            url = "https://cdn.little-melody.net/Public/Linux/Wallpaper/AkidaWho-shark.png";
            hash = "sha512-oXX4aeUc4/rIfkcUHAym2y9nkenGdNYUaFbYrsvtA8yA4C9dZ/OUopqUZDLKbdwvHUprjwoscqHyolAM+pfIKA==";
          };
    };
  };
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  # specialisation = {
  #   # Configs has conflits w/ Hyprland
  #   hyprland = {
  #     inheritParentConfig = true;
  #     configuration = {
  #       environment.etc."specialisation".text = "hyprland";
  #       TM.desktop.gnome.enable = mkForce false;
  #       TM.desktop.hyprland.enable = mkForce true;
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
  #   # kde = {
  #   #   inheritParentConfig = true;
  #   #   configuration = {
  #   #     environment.etc."specialisation".text = "kde";
  #   #     TM.desktop.gnome.enable = mkForce false;
  #   #     TM.desktop.hyprland.enable = mkForce false;
  #   #     services.desktopManager.plasma6.enable = true;
  #   #   };
  #   # };
  #
  #   # openNvidia = {
  #   #   inheritParentConfig = true;
  #   #   configuration = {
  #   #     boot = {
  #   #       blacklistedKernelModules = [
  #   #         "nvidia"
  #   #         "nvidia_uvm"
  #   #       ];
  #   #       initrd.kernelModules = [ "nouveau" ];
  #   #       kernelParams = [
  #   #         "nouveau.config=NvGspRm=1"
  #   #         "nouveau.debug=info,VBIOS=info,gsp=debug"
  #   #       ];
  #   #     };
  #   #     services.xserver.enable = true;
  #   #     services.xserver.videoDrivers = lib.mkForce [ "modesetting" ];
  #   #     environment.etc."specialisation".text = "openNvidia";
  #   #     TM.MyNextGPUWillNotBeNvidia = mkForce false;
  #   #     system.nixos.tags = [ "NVK" ];
  #   #   };
  #   # };
  # };

  boot.plymouth.enable = false;

  networking = {
    hostName = "Snow";

    networkmanager.enable = true;
    # Open ports in the firewall.
    firewall = let
      networking-services = {
        wallpaper-engine = {
          tcp = 7889;
          udp = 7884;
        };
      };
    in {
      allowedTCPPorts = [networking-services.wallpaper-engine.tcp];
      allowedUDPPorts = [networking-services.wallpaper-engine.udp];
    };
    nameservers = ["1.1.1.1" "9.9.9.9"];
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Disable pixiecore's autostart
  systemd.services = mkIf config.services.pixiecore.enable {
    pixiecore.wantedBy = mkForce [];
  };
  # programs.ssh.askPassword = "${pkgs.seahorse}/libexec/seahorse/ssh-askpass";
  services = {
    orca.enable = false;
    desktopManager.cosmic.enable = true;
    desktopManager.plasma6.enable = true;
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };

    gnome.gnome-remote-desktop.enable = true;
    hardware.openrgb = {
      enable = true;
      motherboard = "intel";
    };
    usbmuxd.enable = true;
    pixiecore = let
      inherit (inputs.self.nixosConfigurations.Netboot.config.system) build;
    in {
      enable = false;
      openFirewall = true;
      dhcpNoBind = true; # Use existing DHCP server.
      mode = "boot";
      kernel = "${build.kernel}/bzImage";
      initrd = "${build.netbootRamdisk}/initrd";
      cmdLine = "init=${build.toplevel}/init loglevel=4";
      debug = true;
    };
    xserver = {
      enable = true;

      # Configure keymap in X11
      xkb.layout = "us";
    };
    dbus.packages = [pkgs.gcr];
    openssh.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).

  users.users.melody.packages = with pkgs; [
    gitkraken
    prismlauncher
    nil
    # telegram-desktop
    vscode
    wl-clipboard
    # yubioath-flutter
    bitwarden-cli
    czkawka
    nmap
    # iw3
    # inputs.ags.packages.${pkgs.stdenv.hostPlatform.system}.agsFull
  ];

  environment.systemPackages = with pkgs; [
    tetex
    texstudio
    #libvert
    #qemu
    abaddon
    cava
    gh
    git
    pamixer
    spotify
    # star-citizen
    tmux
    wget
    android-tools
    fuzzel
    xwayland-satellite

    # KDE
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

  virtualisation = {
    libvirtd.enable = false;
    # waydroid.enable = true;
  };
  # Disable autosleep
  programs = {
    niri.enable = false;
    gamemode.enable = mkForce false;
    coolercontrol.enable = false;
    fuse.userAllowOther = true;
    honkers-railway-launcher.enable = true;
    wavey-launcher = {
      enable = true;
      package = inputs.aagl.packages.${system}.wavey-launcher;
    };
    kdeconnect.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    gnome-disks.enable = true;
    noisetorch.enable = true;
    fish.enable = true;
    zsh = {
      enableCompletion = true;
      autosuggestions.enable = true;
      enable = true;
      ohMyZsh.plugins = ["1password"];
    };
    mosh.enable = true;
  };

  hardware.logitech.wireless = {
    enable = true;
    enableGraphical = true;
  };

  boot.kernel.sysctl."vm.max_map_count" = lib.mkForce 16777216;
}
