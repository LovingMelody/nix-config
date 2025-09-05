{lib, ...}: {
  services.linux-wallpaperengine = {
    enable = false;
    wallpapers = [
      {
        monitor = "DP-1";
        wallpaperId = "3039965096"; # left
      }
      {
        monitor = "DP-3";
        wallpaperId = "3039965096"; # right
      }
    ];
  };
  programs = {
    direnv.enable = true;
  };
  TM = {
    gaming.enable = true;
    home-profiles.desktop.enable = true;
    impermanence.enable = true;
    # defaults.enable = true;
    programs = {
      waybar.enable = true;
      _1password = {
        enable = true;
        sshAgent = true;
        gpgSign = {
          enable = true;
          signingKey = lib.removeSuffix "\n" (builtins.readFile (lib.TM.get-ssh-key-file "melody" "primary"));
        };
      };
      git.enable = true;
    };
  };
  wayland.windowManager.hyprland.settings.cursor.use_cpu_buffer = lib.mkDefault true;
  home.stateVersion = lib.TM.stateVersion.nixos;
}
