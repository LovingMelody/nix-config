{
  config,
  pkgs,
  lib,
  osConfig,
  ...
}: let
  inherit (pkgs) stdenv;
  cfg = config.TM.programs._1password;
  inherit
    (lib)
    getExe'
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in {
  options.TM.programs._1password = {
    enable =
      mkEnableOption "Enable 1password"
      // {
        default = osConfig.TM.programs._1password.enable or false;
      };
    sshAgent = mkEnableOption "SSH Integration";
    gpgSign = {
      enable = mkEnableOption "Enable GPG Signing";
      signingKey = mkOption {
        type = types.str;
        description = "Signing key to be used";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;
      [_1password-cli]
      ++ lib.optionals config.TM.isGui [
        _1password-gui
      ];
    xdg.autostart = mkIf (config.TM.isGui && stdenv.hostPlatform.isLinux) {
      enable = true;
      entries = [
        "${pkgs.makeDesktopItem {
          name = "1password-silent";
          desktopName = "1Password";
          exec = "${getExe' pkgs._1password-gui "1password"} --silent";
          icon = "1password";
          categories = ["Office"];
        }}/share/applications/1password-silent.desktop"
      ];
    };
    programs.git = mkIf (cfg.gpgSign.enable && cfg.sshAgent) {
      settings = {
        "gpg \"ssh\"".program = "${getExe' pkgs._1password-gui "op-ssh-sign"}";
        gpg.format = "ssh";
      };
      signing = {
        key = cfg.gpgSign.signingKey;
        signByDefault = true;
      };
    };
    programs.ssh.settings = mkIf cfg.sshAgent {
      "Host *".identityAgent =
        if !stdenv.hostPlatform.isDarwin
        then "${config.home.homeDirectory}/.1password/agent.sock"
        else "${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
    };
  };
}
