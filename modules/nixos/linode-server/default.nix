{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.TM.server.hosts.linode;
  inherit (lib) mkEnableOption mkIf;
in {
  options.TM.server.hosts.linode = {
    enable = mkEnableOption "Enable settings specific to linode";
    longview.enable = mkEnableOption "Enable Linode Longview";
  };

  # Configuration based on https://www.linode.com/docs/guides/install-nixos-on-linode
  config = mkIf cfg.enable {
    sops.secrets."longview/apiKey" = {
      sopsFile = lib.TM.get-secret-file "longview/default.yaml";
    };
    networking = {
      usePredictableInterfaceNames = false;
      useDHCP = false; # Disable DHCP globally as we will not need it.
      # required for ssh?
      interfaces.eth0.useDHCP = true;
    };
    environment.systemPackages = with pkgs; [
      inetutils
      mtr
      sysstat
    ];
    services = {
      openssh.enable = true;

      longview = {
        inherit (cfg.longview) enable;
        apiKeyFile = config.sops.secrets."longview/apiKey".path;
      };
    };

    # Enable Lish
    boot = {
      # Enable lish
      kernelParams = ["console=ttyS0,19200n8"];
      loader = {
        grub = {
          extraConfig = ''
            serial --speed=19200 --unit=0 --word=8 --parity=no --stop=1;
            terminal_input serial;
            terminal_output serial
          '';
          # Grub config
          forceInstall = true;
          device = "nodev";
        };
        # Timeout increased for lish
        timeout = 10;
      };
    };
  };
}
