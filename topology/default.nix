# Topology config
{pkgs, ...}: {
  networks.home = {
    name = "Home Netork";
    cidrv4 = "192.168.4.1/24";
  };
  networks.tailScale.icon = pkgs.fetchurl {
    url = "https://simpleicons.org/icons/tailscale.svg";
    hash = "sha256-gOzd4IwqTN2qZER/y/r6uBMmhkZxzTO3/D1AxMhmHfw=";
  };
  nodes.home-assistant = {
    deviceType = "device";
    hardware.info = "Home Assistant Yellow";
    interfaces.eth0.network = "home";
    interfaces.tailScale.network = "tailScale";
    services.NUT = {
      name = "Network UPS Tools";
      icon = ./nut-logo.png;
    };
    services.HA = {
      name = "Home Assistant";
      icon = "services.home-assistant";
    };
  };
}
