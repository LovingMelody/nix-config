{
  pkgs,
  lib,
  ...
}: {
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    vscode
    mosh
  ];
  services.tailscale.enable = true;

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  environment.darwinConfig = "$HOME/.config/DotFiles";

  networking = {
    localHostName = "Melodys-MBP";
    wakeOnLan.enable = true;
  };

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true; # default shell on catalina
  programs.fish.enable = true;
  programs._1password.enable = true;
  programs._1password-gui.enable = true;
  programs.nix-index.enable = true;

  users.users.melody.home = "/Users/melody";
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    # users.melody = flake-self.homeConfigurations.darwin;
    sharedModules = [
      {
        TM.programs._1password = {
          enable = true;
          gpgSign.enable = false;
          sshAgent = true;
        };
        programs.alacritty.package = pkgs.hello;
      }
    ];
  };
  # HomeBrew - not auto installed
  homebrew = {
    onActivation = {
      autoUpdate = true;
      upgrade = true;
    };
    global.autoUpdate = true;

    enable = true;
    # casks = [
    #   "protonvpn"
    #   "alacritty"
    #   "discord"
    #   "firefox"
    #   "wezterm"
    #   "spotify"
    #   "1password"
    # ];
    onActivation.cleanup = "uninstall";
    masApps = {
      "vinegar tube cleaner" = 1591303229;
      "sponsorblock for youtube" = 1573461917;
      "1password for safari" = 1569813296;
      numbers = 409203825;
    };
  };

  nix.settings.auto-optimise-store = lib.mkForce false;
  system = {
    startup.chime = false;
    # Keep home & system the same
    system = lib.TM.stateVersion.home;
    defaults = {
      NSGlobalDomain = {
        AppleEnableMouseSwipeNavigateWithScrolls = true;
        AppleEnableSwipeNavigateWithScrolls = true;
        AppleICUForce24HourTime = true;
        AppleInterfaceStyle = null; # We use auto
        AppleInterfaceStyleSwitchesAutomatically = true;
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        AppleTemperatureUnit = "Celsius";
        NSAutomaticCapitalizationEnabled = true;
        NSAutomaticDashSubstitutionEnabled = true;
        NSAutomaticPeriodSubstitutionEnabled = true;
        NSAutomaticQuoteSubstitutionEnabled = true;
        NSAutomaticSpellingCorrectionEnabled = true;
        NSAutomaticWindowAnimationsEnabled = true;
        NSDocumentSaveNewDocumentsToCloud = true;
        NSScrollAnimationEnabled = true; # Smooth Scrolling
      };
      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
      alf = {
        globalstate = 1;
        stealthenabled = 1;
      };
      finder = {
        ShowPathbar = true;
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        CreateDesktop = false; # Icons on desktop
        ShowStatusBar = true;
      };
      screencapture = {
        disable-shadow = false;
        type = "png";
      };
    };
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };
    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    stateVersion = lib.TM.stateVersion.darwin;
  };
}
