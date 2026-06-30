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
    mkDefault
    mkOption
    mkEnableOption
    mkMerge
    mkIf
    types
    optional
    ;
in {
  options.TM.networking.tailscale = {
    enable = mkEnableOption "Enable TailScale" // {default = true;};
    manageSSH =
      mkEnableOption "Set tailscale to manage connections"
      // {
        default = true;
      };
    userManaged = {
      enable = mkEnableOption "Enable" // {default = config.TM.isGui;};
      user = mkOption {
        type = types.str;
        default = "melody";
      };
    };
    autoConnect = mkEnableOption "Autoconnect to tailscale" // {default = config.TM.knowsHiddenMove;};
  };

  config = let
    key = "Networking/TailScale/AuthKey";
  in
    mkIf cfg.enable (mkMerge [
      {
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
        services = {
          tailscale = {
            enable = true;
            extraUpFlags = optional cfg.manageSSH "--ssh";
            extraSetFlags = ["--accept-dns=false"] ++ optional cfg.userManaged.enable "--operator=${cfg.userManaged.user}";
            useRoutingFeatures = mkDefault "both";
          };
          resolved = {
            enable = mkDefault true;
            # domains = ["~."];
          };
        };
        networking.firewall = {
          trustedInterfaces = ["tailscale0"];
          checkReversePath = "loose";
          allowedUDPPorts = [config.services.tailscale.port];
        };
        systemd.services.tailscale-resolved-dns = {
          description = "Register Tailscale DNS with systemd-resolved";

          after = ["tailscaled.service" "sys-subsystem-net-devices-tailscale0.device"];
          bindsTo = ["sys-subsystem-net-devices-tailscale0.device"];
          wantedBy = ["sys-subsystem-net-devices-tailscale0.device"];

          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };

          script = let
            resolvectl = lib.getExe' config.systemd.package "resolvectl";
          in ''
            ${resolvectl} dns tailscale0 '100.100.100.100' 'fd7a:115c:a1e0::53'
            ${resolvectl} domain tailscale0 '~ts.net'
          '';
        };
      }
      (mkIf cfg.autoConnect {
        sops.secrets."${key}" = {
          owner = config.users.users.root.name;
          reloadUnits = ["tailscale-autoconnect.service"];

          sopsFile =
            if config.TM.knowsHiddenMove
            then config.sops.defaultSopsFile
            else lib.TM.get-secret "hosts/${config.networking.hostName}/tailscale.yaml";
        };

        # Autoconnect
        services.tailscale.authKeyFile = config.sops.secrets."${key}".path;
      })
    ]);
}
