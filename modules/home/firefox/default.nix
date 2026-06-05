{
  config,
  lib,
  ...
}: let
  cfg = config.TM.programs.firefox;
  inherit (lib) mkEnableOption mkIf;
in {
  options.TM.programs.firefox = {
    enable = mkEnableOption "A web browser built from Firefox source tree";
    defaultApps =
      mkEnableOption "Set firefox to be the default browser"
      // {
        default = true;
      };
  };
  config = mkIf cfg.enable {
    xdg.mimeApps.defaultApplications = mkIf cfg.defaultApps {
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/chrome" = "firefox.desktop";
      "text/html" = "firefox.desktop";
      "application/x-extension-htm" = "firefox.desktop";
      "application/x-extension-html" = "firefox.desktop";
      "application/x-extension-shtml" = "firefox.desktop";
      "application/xhtml+xml" = "firefox.desktop";
      "application/x-extension-xhtml" = "firefox.desktop";
      "application/x-extension-xht" = "firefox.desktop";
    };
    stylix.targets.firefox.profileNames = ["default"];
    programs.firefox = {
      enable = true;
      policies = {
        DisableAppUpdate = true;
        DisableTelemetry = true;
        ExtensionSettings = let
          defineExtension = import ./extensions.nix;
        in
          {}
          // (defineExtension {name = "clearURLs";})
          // (defineExtension {name = "facebookContainer";})
          // (defineExtension {name = "fakeSpot";})
          // (defineExtension {name = "firefoxColor";})
          // (defineExtension {name = "firefoxTranslations";})
          // (defineExtension {name = "malSync";})
          // (defineExtension {name = "multiAccountContainers";})
          // (defineExtension {name = "plasmaIntegration";})
          // (defineExtension {name = "privateRelay";})
          // (defineExtension {name = "sponsorBlock";})
          // (defineExtension {name = "dearrow";})
          // (defineExtension {name = "stylus";})
          // (defineExtension {name = "uBlockOrigin";})
          // (defineExtension {name = "userchrome-toggle-extended";})
          // (defineExtension {name = "sidebery";})
          // (mkIf config.TM.programs._1password.enable (defineExtension {
            name = "_1password";
          }));

        "3rdparty" = {
          Extensions = {
            "uBlock0@raymondhill.net" = {
              adminSettings = {
                selectedFilterLists = [
                  "ublock-privacy"
                  "ublock-badware"
                  "ublock-filters"
                  "AdGuard - Ads"
                  "AdGuard - Mobile Ads"
                  "EasyList"
                  "AdGuard Tracking Protection"
                  "AdGuard URL Tracking Protection"
                  "Block Outsider Intrusion into LAN"
                  "EasyPrivacy"
                  "Online Malicious URL Blocklist"
                  "Phishing URL Blocklist"
                  "Peter Lowe’s Ad and tracking server list"
                  "AdGuard - Annoyances"
                  "AdGuard - Japanese"
                  "user-filters"
                ];
              };
            };
          };
        };
      };
      profiles.default = {
        isDefault = true;
        extensions.force = true;
        settings = {
          "apz.overscroll.enabled" = true;
          "browser.aboutConfig.showWarning" = false;
          "general.autoScroll" = true;
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "gfx.color_management.hdr" = config.TM.hasHDRDisplay;
          "gfx.color_management.hdr.force_enabled" = config.TM.hasHDRDisplay;
        };
        # extraConfig = builtins.readFile "${shyfox}/user.js";
        search = {
          force = true;
          default = "ddg";
          engines = {
            "ddg" = {
              url = "https://duckduckgo.com/?q=%s";
              icon = "https://duckduckgo.com/favicon.ico";
            };
            "google" = {
              url = "https://www.google.com/search?q=%s";
              icon = "https://www.google.com/favicon.ico";
            };
            "wikipedia" = {
              url = "https://en.wikipedia.org/wiki/Special:Search?search=%s";
              icon = "https://en.wikipedia.org/favicon.ico";
            };
            "Nix Pakcages" = {
              url = "https://search.nixos.org/packages?query=%s";
              icon = "https://search.nixos.org/favicon.ico";
            };
            "NixOS Options" = {
              url = "https://search.nixos.org/options?query=%s";
              icon = "https://search.nixos.org/favicon.ico";
            };
            "Home-manager options" = {
              url = "https://rycee.gitlab.io/home-manager/options.html#opt-%s";
              icon = "https://rycee.gitlab.io/home-manager/favicon.ico";
            };
            "NixOS Manual" = {
              url = "https://search.nixos.org/nixos/options.html?query=%s";
              icon = "https://search.nixos.org/favicon.ico";
            };
            "Brave Search" = {
              url = "https://search.brave.com/search?q=%s";
              icon = "https://search.brave.com/favicon.ico";
            };
          };
        };
      };
    };
    # home.file.".mozilla/firefox/${config.programs.firefox.profiles.homeManager.path}/chrome".source = "${shyfox}/chrome";
  };
}
