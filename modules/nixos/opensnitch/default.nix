{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.TM.security.opensnitch;
  inherit
    (lib)
    getExe
    getExe'
    mkEnableOption
    mkIf
    ;
in {
  options.TM.security.opensnitch = {
    enable = mkEnableOption "Enable opensnitch";
  };

  config = mkIf cfg.enable {
    services.opensnitch = {
      enable = true;
      settings = {
        LogLevel = 1;
        DefaultAction = "allow";
        Firewall =
          if config.networking.nftables.enable
          then "nftables"
          else "iptables";
      };
      rules = {
        _1password-gui = {
          name = "1password-gui";
          enabled = config.TM.programs._1password.gui;
          action = "allow";
          duration = "always";
          operator = {
            type = true;
            sensitive = false;
            operand = "process.path";
            data = getExe' pkgs._1password-gui "1password";
          };
        };
        _1password = {
          name = "1password-cli";
          enabled = config.TM.programs._1password.enable;
          action = "allow";
          duration = "always";
          operator = {
            type = true;
            sensitive = false;
            operand = "process.path";
            data = getExe' pkgs._1password-cli "op";
          };
        };
        ntpd-rs = {
          name = "ntpd-rs";
          enabled = config.services.ntpd-rs.enable;
          action = "allow";
          duration = "always";
          operator = {
            type = true;
            sensitive = false;
            operand = "process.path";
            data = getExe config.services.ntpd-rs.package;
          };
        };
        mosh-client = {
          name = "mosh-client";
          enabled = true;
          action = "allow";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = getExe' pkgs.mosh "mosh-client";
          };
        };
        mosh-server = {
          name = "mosh-server";
          enabled = config.programs.mosh.openFirewall;
          action = "allow";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = lib.getExe' pkgs.mosh "mosh-server";
          };
        };
        # SSH
        sshd = {
          name = "sshd";
          enabled = true;
          action = "allow";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = lib.getExe' pkgs.openssh "sshd";
          };
        };
        ssh = {
          name = "ssh";
          enabled = true;
          action = "allow";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = lib.getExe' pkgs.openssh "ssh";
          };
        };
        Wine = {
          name = "wine";
          enabled = config.programs.wine.enable;
          action = "allow";
          duration = "always";
          operator = {
            type = "regex";
            sensitive = false;
            operand = "process.parent.path";
            data = "^${lib.getBin config.programs.wine.package}/bin/.*";
          };
        };
        syncthing = {
          name = "syncthing";
          enabled = config.home-manager.users.melody.services.syncthing.enable or false;
          action = "allow";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = lib.getExe (config.home-manager.users.melody.services.syncthing.package or pkgs.syncthing);
          };
        };
        Tailscaled = {
          name = "tailscaled";
          enabled = config.services.tailscale.enable;
          action = "allow";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = lib.getExe' config.services.tailscale.package "tailscaled";
          };
        };
        Tailscale = {
          name = "tailscale";
          enabled = config.services.tailscale.enable;
          action = "allow";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = lib.getExe' config.services.tailscale.package "tailscale";
          };
        };
        XIVLauncher = {
          name = "XIVLauncher";
          enabled = config.home-manager.users.melody.TM.gaming.games.ffxiv.enable;
          action = "allow";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.parent.path";
            data = lib.getExe (config.home-manager.users.melody.TM.gaming.games.ffxiv.package or pkgs.xivlauncher);
          };
        };
        nix = {
          name = "nix";
          enabled = true;
          action = "allow";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = lib.getExe pkgs.nix;
          };
        };
        firefox = {
          name = "firefox";
          enabled = true;
          action = "allow";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = lib.getExe (config.home-manager.users.melody.programs.firefox.finalPackage or config.programs.firefox.package);
          };
        };
        git = {
          name = "git";
          enabled = true;
          action = "allow";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = lib.getExe pkgs.git;
          };
        };
        git-remote-https = {
          name = "git-remote-https";
          enabled = true;
          action = "allow";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = lib.getExe' pkgs.git "git-remote-https";
          };
        };
        curl = {
          name = "curl";
          enabled = true;
          action = "allow";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = lib.getExe pkgs.curl;
          };
        };

        systemd-timesyncd = {
          name = "systemd-timesyncd";
          enabled = true;
          action = "allow";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = "${lib.getBin pkgs.systemd}/lib/systemd/systemd-timesyncd";
          };
        };
        systemd-resolved = {
          name = "systemd-resolved";
          enabled = true;
          action = "allow";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = "${lib.getBin pkgs.systemd}/lib/systemd/systemd-resolved";
          };
        };
        upsmon = {
          name = "upsmon";
          enabled = config.power.ups.upsmon.enable;
          action = "allow";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = getExe' pkgs.nut "upsmon";
          };
        };
      };
    };
  };
}
