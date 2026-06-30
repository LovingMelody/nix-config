{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.TM.server.services.minecraft;
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;
  inherit (lib.TM) get-secret-file;
in {
  options.TM.server.services.minecraft.backup = {
    enable = mkEnableOption "Enable backups";
    everything = mkEnableOption "Backup Everything" // {default = true;};
  };

  config = let
    overworld = "${cfg.dataDir}/${cfg.worldName}";
    nether = "${cfg.dataDir}/${cfg.worldName}_nether";
    end = "${cfg.dataDir}/${cfg.worldName}_the_end";
  in
    mkIf (cfg.enable && cfg.backup.enable) {
      sops.secrets = {
        "Minecraft/backup/b2/applicationKey" = {
          sopsFile = get-secret-file "Minecraft/generic.yaml";
          owner = config.users.users.minecraft.name;
          reloadUnits = ["minecraft-backup.service"];
        };
        "Minecraft/backup/b2/keyID" = {
          sopsFile = get-secret-file "Minecraft/generic.yaml";
          owner = config.users.users.minecraft.name;
          reloadUnits = ["minecraft-backup.service"];
        };
        "Minecraft/backup/restic/password" = {
          sopsFile = get-secret-file "Minecraft/generic.yaml";
          owner = config.users.users.minecraft.name;
          reloadUnits = ["minecraft-backup.service"];
        };
        "Minecraft/backup/restic/repository" = {
          sopsFile = get-secret-file "Minecraft/generic.yaml";
          owner = config.users.users.minecraft.name;
          reloadUnits = ["minecraft-backup.service"];
        };
      };

      systemd = {
        timers.minecraft-backup = {
          wantedBy = ["timers.target"];
          requires = [
            "minecraft-server.service"
            "minecraft-server.socket"
          ];
          timerConfig = {
            OnBootSec = "30min";
            OnUnitActiveSec = "4h";
          };
        };
        services.minecraft-backup = {
          inherit (cfg.backup) enable;
          wantedBy = ["multi-user.target"];
          requires = [
            "minecraft-server.service"
            "minecraft-server.socket"
          ];
          after = ["minecraft-server.service"];
          path = [
            pkgs.bash
            pkgs.restic
            pkgs.uutils-coreutils-noprefix
          ];
          serviceConfig = {
            Type = "oneshot";
            User = config.users.users.minecraft.name;
          };
          script =
            ''
              function test_readable {
                if [[ ! -r "$1" ]]; then
                  echo "File $1 is not readable"
                  exit 1
                fi
              }
              # Test if all secrets are readable
              test_readable ${config.sops.secrets."Minecraft/backup/restic/password".path}
              test_readable ${config.sops.secrets."Minecraft/backup/restic/repository".path}
              test_readable ${config.sops.secrets."Minecraft/backup/b2/keyID".path}
              test_readable ${config.sops.secrets."Minecraft/backup/b2/applicationKey".path}

              function rcon {
                echo "$1" >> /run/minecraft-server.stdin
              }

              function backup {
                B2_ACCOUNT_ID=$(cat ${config.sops.secrets."Minecraft/backup/b2/keyID".path}) \
                B2_ACCOUNT_KEY=$(cat ${config.sops.secrets."Minecraft/backup/b2/applicationKey".path}) \
                restic \
                  --password-file ${config.sops.secrets."Minecraft/backup/restic/password".path} \
                  --repository-file ${config.sops.secrets."Minecraft/backup/restic/repository".path} \
                  backup "$1"
              }
            ''
            + (
              if cfg.backup.everything
              then ''

                function do_backup {
                  backup ${cfg.dataDir}
                }

              ''
              else ''

                function do_backup {
                  # Check if world folder exists run backup if it does warn if it doesnt
                  if [ ! -d ${overworld} ]; then
                  echo World folder does not exist
                  else
                    backup ${overworld}
                  fi

                  # Backup world_nether folder
                  if [ ! -d ${nether} ]; then
                    echo World nether folder does not exist
                  else
                    backup ${nether}
                  fi

                  # Backup world_the_end folder
                  if [ ! -d ${end} ]; then
                    echo "World the end folder does not exist"
                  else
                    backup ${end}
                  fi
                }

              ''
            )
            + ''

              rcon 'say §c§lWARNING: §r§cWorld backup in 10 minutes'
              sleep 5m
              rcon 'say §c§lWARNING: §r§cWorld backup in 5 minutes'
              sleep 4m
              rcon 'say §c§lWARNING: §r§cWorld backup in 1 minute'
              sleep 1m
              rcon 'say §c§lWARNING: §r§cWorld backup starting NOW!'

              rcon 'save-off'
              rcon 'save-all flush'
              # Wait for save to finish before backing up
              # FIXME: Fix race condition
              sleep 1m

              do_backup

              rcon save-on
              rcon 'say §a§lSUCCESS: §r§aWorld backup complete!'
            '';
        };
      };
    };
}
