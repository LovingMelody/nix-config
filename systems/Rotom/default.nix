# Pokedex: #0479
# Rotom - Its electric-like body can enter some kinds of machines and take control in order to make mischief.
{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) toString;
in {
  imports = [./hardware-configuration-extended.nix];

  sops.secrets.prism = {
    owner = config.systemd.services.photoprism.serviceConfig.User;
    group = config.systemd.services.photoprism.serviceConfig.Group;
    path = "/.secrets-extra/photoprism-admin";
    restartUnits = ["photoprism.service"];
    sopsFile = lib.TM.get-secret-file "hosts/Rotom/prism.yaml";
  };

  TM = {
    pokemon = {
      name = "Rotom";
      pokedex = 479;
    };
    knowsHiddenMove = false;
    users.enable = true;
    time.enable = true;
    sound.enable = true;
    server.services.minecraft = {
      enable = true;
      autoStart = false;
      eula = true;
      backup.enable = false; # Currently broken
      openFirewall = true;
      worldName = "NewWorld";
    };
    # services.aria2.enable = true;
  };
  home-manager.users.melody = {
    TM.home-profiles.server.enable = true;
  };
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  users = {
    groups.photoprism = {};
    users.photoprism = {
      name = "photoprism";
      group = "photoprism";
      isSystemUser = true;
    };
  };

  services = {
    openssh.enable = true;
    davfs2.enable = false;
    mysql = {
      enable = true;
      package = pkgs.mariadb;
      settings = {
        mysqld = {
          port = 3036;
          bind-address = "127.0.0.1";
        };
      };
      ensureDatabases = ["photoprism"];
      ensureUsers = [
        {
          name = "photoprism";
          ensurePermissions = {"photoprism.*" = "ALL PRIVILEGES";};
        }
      ];
    };
    photoprism = {
      enable = true;
      originalsPath = "/data/photoprism";
      passwordFile = config.sops.secrets.prism.path;
      address = "0.0.0.0";
      settings = {
        PHOTOPRISM_ORIGINALS_LIMIT = builtins.toString (80 * 1023); # file size limit for originals in MB
        PHOTOPRISM_HTTP_COMPRESSION = "gzip";
        PHOTOPRISM_READONLY = "true"; # do not modify originals directory (reduced functionality)
        PHOTOPRISM_EXPERIMENTAL = "true"; # enables experimental features
        PHOTOPRISM_DISABLE_WEBDAV = "true"; # disables built-in WebDAV server
        PHOTOPRISM_DETECT_NSFW = "false"; # Doesn't work well
        PHOTOPRISM_UPLOAD_NSFW = "true"; # Check doesnt work well
        PHOTOPRISM_DATABASE_DRIVER = "mysql";
        PHOTOPRISM_DATABASE_SERVER = with config.services.mysql.settings.mysqld; "${bind-address}:${toString port}"; # MariaDB database server
        PHOTOPRISM_DATABASE_NAME = "photoprism";
        PHOTOPRISM_DATABASE_USER = "photoprism";
        PHOTOPRISM_DATABASE_PASSWORD = config.services.photoprism.passwordFile;
        PHOTOPRISM_INDEX_SCHEDULE = "@every 42h";
      };
    };
    flaresolverr.enable = false;
  };
  # systemd.services.photoprism = mkIf config.services.photoprism.enable {
  #   serviceConfig.EnvironmentFile = "/.secrets-extra/photoprism-db";
  # };
  programs.mosh.enable = true;

  networking = {
    nameservers = [
      "9.9.9.9"
      "1.1.1.1"
    ];
    hostName = "Rotom";
    networkmanager.enable = true;
  };
  environment.systemPackages = with pkgs; [
    vim
    tmux
    git
  ];
}
