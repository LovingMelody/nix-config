{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.TM.security.opensnitch;
  inherit
    (lib)
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
          duration = "allways";
          operator = {
            type = true;
            sensitive = false;
            operand = "process.path";
            data = getExe' pkgs._1password-cli "op";
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
        XIVLauncher = {
          name = "XIVLauncher";
          enabled = true;
          action = "allow";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = lib.getExe pkgs.xivlauncher;
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
            data = lib.getExe pkgs.firefox;
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
