{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.TM.home-profiles.desktop;
  inherit (config.TM.styles) palette flavor;
  inherit (lib) mkEnableOption mkIf toLower;
  inherit (builtins) toString;
  inherit (lib.TM.styling.withPalette palette) colors;
  accent = colors.${toLower config.TM.styles.accent};
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
        # FIXME: disabled due to https://github.com/NixOS/nixpkgs/pull/427813
        geeqie.enable = false;
        # FIXME: Disable due to build errors
        kitty.enable = false;
        mpv.enable = true;
        ssh.enable = true;
        discord = {
          enable = true;
          packages = [
            pkgs.discord
            # pkgs.discord-canary
            # pkgs.discord-ptb
          ];
          openASAR.enable = true;
          vencord = {
            enable = true;
            config = {
              notifyAboutUpdates = false;
              autoUpdate = false;
              autoUpdateNotification = false;
              useQuickCSS = true;
              themeLinks = [
                "https://github.com/SlippingGittys-Discord-Themes/surCord/raw/refs/heads/main/surCord.theme.css"
              ];
              frameless = true;
              transparent = true;
              plugins = {
                BadgeAPI.enabled = true;
                CommandsAPI.enabled = true;
                ContextMenuAPI.enabled = true;
                Experiments.enabled = true;
                NoScreensharePreview.enabled = true;
                OpenInApp.enabled = true;
                PictureInPicutre.enabled = true;
                ThemeAttributes.enabled = true;
                MessageAccessoriesAPI.enabled = true;
                MemberListDecoratorsAPI.enabled = true;
                MessageDecorationsAPI.enabled = true;
                MessageEventsAPI.enabled = true;
                MessagePopoverAPI.enabled = true;
                NoticesAPI.enabled = true;
                ServerListAPI.enabled = true;
                SettingsStoreAPI.enabled = true;
                NoTrack.enabled = true;
                # Configured in nix
                Settings.enabled = false;
                AlwaysAnimate.enabled = true;
                AnonymiseFileNames = {
                  enabled = true;
                  method = 0;
                  randomisedLength = 7;
                };
                BlurNSFW.enabled = true;
                CallTimer = {
                  enabled = true;
                  format = "stopwatch";
                };
                ClearURLs.enabled = true;
                CrashHandler.enabled = true;
                GameActivityToggle.enabled = false;
                ImageZoom.enabled = true;
                MessageLinkEmbeds.enabled = true;
                MemberCount.enabled = true;
                MessageLogger.enabled = true;
                MoreKaomoji.enabled = true;
                NoReplyMention.enabled = true;
                NSFWGateBypass.enabled = true;
                PinDMs.enabled = true;
                PlatformIndicators.enabled = true;
                # Discord has this now
                PronounDB = {
                  enable = false;
                  showInProfile = true;
                  showSelf = true;
                  showInMessages = true;
                  pronounsFormat = "LOWERCASE";
                };
                ReactErrorDecoder.enabled = true;
                ReverseImageSearch.enabled = true;
                ReviewDB.enabled = true;
                RoleColorEverywhere.enabled = true;
                ServerListIndicators.enabled = true;
                ShikiCodeblocks = {
                  enabled = true;
                  useDevIcon = "GREYSCALE";
                  theme = "https://raw.githubusercontent.com/shikijs/textmate-grammars-themes/refs/heads/main/packages/tm-themes/themes/catppuccin-${toLower flavor}.json";
                };
                ShowConnections.enabled = true;
                SilentTyping.enabled = true;
                SortFriendRequests.enabled = true;
                SpotifyControls.enable = true;
                SpotifyShareCommands.enabled = true;
                SupportHelper.enable = true;
                TimeBarAllActivities.enabled = true;
                TypingTweaks = {
                  enabled = true;
                  alternativeFormatting = true;
                  showRoleColors = true;
                  showAvatars = true;
                };
                Unindent.enabled = true;
                UserVoiceShow = {
                  enable = true;
                  showVoiceChannelSectionHeader = true;
                };
                ValidUser.enabled = true;
                VoiceChatDoubleClick.enabled = true;
                WhoReacted.enabled = true;
                YoutubeAdblock.enabled = true;
              };
            };
            css = ''
               code, .codeBlockText-28BOxV, .codeLine-2C-9aH, .markup-eYLPri code.inline, .after_inlineCode-2_JXPm, .before_inlineCode-1zngJj, .inlineCode-ERyvy_ {
                    font-family: "${config.stylix.fonts.monospace.name}",mono,monospace;
               }

              * {
                --font-primary: -apple-system,BlinkMacSystemFont,"SF Pro Display",sans-serif;
                --font-display: -apple-system,BlinkMacSystemFont,"SF Pro Display",sans-serif;
                --font-headline: -apple-system,BlinkMacSystemFont,"SF Pro Display",sans-serif;
                text-rendering: optimizeLegibility;
                text-transform: none !important;
                letter-spacing: 0.015em;

                /* font-weight: bold !important; */
              }
              :root:root {
                   --accent: ${accent.rgb};
                   --accent-hover: ${accent.rgba 0.977};
                   --accent-selected: ${accent.rgba 0.612};
                   --accent-focused: ${accent.rgba 0.200};

                   --surCordBackground: ${colors.base.hex};
                   --surCordBackground2: ${colors.mantle.hex};
                   --surCordTextBackground: ${colors.crust.hex};
                   --surcordFriendsBackground: ${colors.crust.hex};
                   --surcordFriends: ${colors.base.hex};
                   --surCordActiveNow: ${colors.surface0.rgba 0.27};
                   --surCordGuilds: ${colors.mantle.hex};
                   --surCordTitleBar: ${colors.base.hex};
                   --surCordSearch: ${colors.crust.hex};
                   --surCordHover: ${accent.hex};
                   --surCordBorder: ${colors.crust.hex};
                   --user-name: "${config.home.username}";
                   --background-image: none;
                   --rs-online-color: ${colors.green.hex};
                   --rs-idle-color: ${colors.yellow.hex};
                   --rs-dnd-color: ${colors.red.hex};
                   --rs-invisible-color: ${colors.surface0.hex};
                   --rs-streaming-color: ${colors.mauve.hex};
                   --accentcolor: ${toString accent.r}, ${toString accent.g}, ${toString accent.b};
                   --accentcolorV2: ${accent.hex};
                   --text-normal: ${colors.text.hex};
                   --server-unread-colour: ${toString colors.text.r} ${toString colors.text.g} ${toString colors.text.b};
                   --server-hover-colour: var(--server-unread-colour)
               }
            '';
          };
        };
      };
    };
    programs = {
      alacritty.enable = true;
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
    # services.syncthing.enable = true;
    #TM.programs.eww.enable = true;

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
        TERM = "xterm-256color";
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
        # audacity
        blanket
        cryptomator
        #
        # element-desktop
        epiphany
        # floorp # For some reason, this breaks firefox policies
        fractal
        freetube
        gnome-text-editor
        lite-xl
        gimp3-with-plugins
        krita
        haruna
      ];
    };
    fonts.fontconfig.enable = true;
    services.easyeffects = {
      enable = true;
    };
  };
}
