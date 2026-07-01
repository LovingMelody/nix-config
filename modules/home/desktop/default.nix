{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.TM.home-profiles.desktop;
  inherit (lib) mkEnableOption mkIf;
in {
  options.TM.home-profiles.desktop = {
    enable = mkEnableOption "Enable desktop defaults";
  };
  config = mkIf cfg.enable {
    TM = {
      programs = {
        chromium.enable = true;
        firefox.enable = true;
        thunderbird.enable = true;
        geeqie.enable = false;
        kitty.enable = true;
        mpv.enable = true;
        ssh.enable = true;
      };
    };
    programs = {
      nixcord = {
        enable = true;
        discord.vencord.enable = true;
        # config.plugins = {
        #   platformIndicators.enable = true;
        #   anonymiseFileNames = {
        #     enable = true;
        #     settings.method = 2;
        #   };
        #   blurNSFW.enable = true;
        #
        # };
      };
      alacritty.enable = true;
      vivaldi = {
        enable = true;
        nativeMessagingHosts = [pkgs.kdePackages.plasma-browser-integration];
      };
      wezterm = {
        enable = true;
        extraConfig = ''
          local config = {}
          if wezterm.config_builder then
            config = wezterm.config_builder()
          end
        '';
      };
    };

    gtk.font.size = lib.mkDefault 12;
    /*
    gtk.theme = lib.mkDefault {
    package = pkgs.catppuccin-gtk.override {
    accents = [ "pink" ];
    size = "compact";
    tweaks = [ "rimless" "black" ];
    variant = config.TM.styles.flavor;
    };
    name = "Catppuccin-${config.TM.styles.flavor}-Compact-Pink-Dark";
    };
    */
    home = {
      sessionVariables = {
        DOTNET_CLI_TELEMETRY_OPTOUT = "1";
        DOTNET_ROOT = "${pkgs.dotnet-sdk}";
        DOTNET_SKIP_FIRST_TIME_EXPERIENCE = "1";
      };
      sessionPath = [
        "${pkgs.dotnet-sdk}/bin"
        "~/.local/bin"
        "~/.cargo/bin"
      ];
      keyboard = {
        layout = true;
      };
      packages = with pkgs; [
        zathura
        audacity
        blanket
        epiphany
        fractal
        freetube
        gnome-text-editor
        gimp3-with-plugins
        haruna
        protonmail-desktop
        protonmail-bridge-gui
      ];
    };
    fonts.fontconfig.enable = true;
    services.easyeffects = {
      package = pkgs.easyeffects;
      enable = true;
    };
  };
}
