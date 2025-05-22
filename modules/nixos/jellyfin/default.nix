{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.TM.services.jellyfin;
  inherit
    (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in {
  # Host Jellyfin server, maybe setup mirrors? IDK
  # TODO: Setup caddy to reverse proxy to jellyfin, Tailscale to connect to it
  options.TM.services.jellyfin = {
    enable = mkEnableOption "Jellyfin media server";
    port = mkOption {
      type = types.int;
      default = 8096;
      description = "Port to host Jellyfin on";
    };
  };

  config = mkIf cfg.enable {
    # User specifically for jellyfin, not used for anything else
    users.users.jellyfin = {
      isSystemUser = true;
      description = "Jellyfin media server";
      group = "jellyfin";
      createHome = false;
      home = "/var/lib/jellyfin";
      extraGroups = ["audio"];
    };
    services.jellyfin = {
      enable = true;
      # No reason for this to be accessable outside of Tailscale
      openFirewall = false;
      #user = config.users.users.jellyfin.name;
      #group = config.users.users.jellyfin.group;
    };
    topology.self.services.jellyfin = {
      hidden = config.services.jellyfin.openFirewall;
      icon = pkgs.fetchurl {
        url = "https://simpleicons.org/icons/jellyfin.svg";
        hash = "sha256-JE1rGRNRiRQKz/b4wceTejBkkStIIpq3Xyb343Eku5I=";
      };
    };
  };
}
