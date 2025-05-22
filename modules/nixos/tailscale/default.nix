# Enable tailscale config
{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.TM.networking.tailscale;
  inherit
    (lib)
    mkOption
    mkEnableOption
    mkMerge
    mkIf
    types
    optional
    ;
in {
  options.TM.networking.tailscale = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable tailscale";
    };
    manageSSH =
      mkEnableOption "Set tailscale to manage connections"
      // {
        default = true;
      };
    autoConnect = mkEnableOption "Autoconnect to tailscale";
  };

  config = let
    key = "TailScale/authKey";
  in
    mkIf cfg.enable (mkMerge [
      (mkIf cfg.enable {
        topology.networks.tailScale = {
          name = "TailScale";
          cidrv4 = "100.64.0.0/10";
          cidrv6 = "fd7a:115c:a1e0::/96";
        };
        topology.self.interfaces.${config.services.tailscale.interfaceName} = {
          network = "tailScale";
          virtual = true;
          type = "tailscale";
          icon = pkgs.fetchurl {
            url = "https://simpleicons.org/icons/tailscale.svg";
            hash = "sha256-gOzd4IwqTN2qZER/y/r6uBMmhkZxzTO3/D1AxMhmHfw=";
          };
        };
        services.tailscale = {
          enable = true;
          extraUpFlags = optional cfg.manageSSH "--ssh";
        };
        networking.firewall = {
          trustedInterfaces = ["tailscale0"];
          checkReversePath = "loose";
          allowedUDPPorts = [config.services.tailscale.port];
        };
      })
      (mkIf cfg.autoConnect {
        sops.secrets."${key}" = {
          sopsFile = lib.TM.get-secret "hosts/${config.networking.hostName}/tailscale.yaml";
          owner = config.users.users.root.name;
          reloadUnits = ["tailscale-autoconnect.service"];
        };

        # Autoconnect
        services.tailscale.authKeyFile = config.sops.secrets."${key}".path;
      })
    ]);
}
