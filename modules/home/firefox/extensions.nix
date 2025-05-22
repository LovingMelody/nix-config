{
  name,
  installation_mode ? "normal_installed",
  default_area ? "menupanel",
}: let
  addons = {
    uBlockOrigin = {
      id = "uBlock0@raymondhill.net";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
    };
    sidebery = {
      id = "{3c078156-979c-498b-8990-85f7987dd929}";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/sidebery/latest.xpi";
    };
    sponsorBlock = {
      id = "sponsorBlocker@ajay.app";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
    };
    firefoxColor = {
      id = "FirefoxColor@mozilla.com";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/firefox-color/latest.xpi";
    };
    plasmaIntegration = {
      id = "plasma-browser-integration@kde.org";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/plasma-integration/latest.xpi";
    };
    malSync = {
      id = "{c84d89d9-a826-4015-957b-affebd9eb603}";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/mal-sync/latest.xpi";
    };
    stylus = {
      id = "{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/styl-us/latest.xpi";
    };
    multiAccountContainers = {
      id = "@testpilot-containers";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/multi-account-containers/latest.xpi";
    };
    facebookContainer = {
      id = "@contain-facebook";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/facebook-container/latest.xpi";
    };
    privateRelay = {
      id = "private-relay@firefox.com";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/private-relay/latest.xpi";
    };
    firefoxTranslations = {
      id = "firefox-translations-addon@mozilla.org";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/firefox-translations/latest.xpi";
    };
    fakeSpot = {
      id = "{44df5123-f715-9146-bfaa-c6e8d4461d44}";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/fakespot-fake-reviews-amazon/latest.xpi";
    };
    clearURLs = {
      id = "{74145f27-f039-47ce-a470-a662b129930a}";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/clearurls/latest.xpi";
    };
    userchrome-toggle-extended = {
      id = "userchrome-toggle-extended@n2ezr.ru";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/userchrome-toggle-extended/latest.xpi";
    };
    _1password = {
      id = "{d634138d-c276-4fc8-924b-40a0ea21d284}";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/1password-x-password-manager/latest.xpi";
    };
    dearrow = {
      id = "deArrow@ajay.app";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/dearrow/latest.xpi";
    };
  };
  addon = addons.${name};
in {
  ${addon.id} = {
    inherit (addon) install_url;
    inherit installation_mode;
    inherit default_area;
  };
}
