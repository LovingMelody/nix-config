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
    # nix-minecraft keeps each server in <services.minecraft-servers.dataDir>/<name>,
    # not in cfg.dataDir, so back up from where the server actually lives
    serverDir = "${config.services.minecraft-servers.dataDir}/melody";
    serverLog = "${serverDir}/logs/latest.log";
    overworld = "${serverDir}/${cfg.worldName}";
    nether = "${serverDir}/${cfg.worldName}_nether";
    end = "${serverDir}/${cfg.worldName}_the_end";
    # nix-minecraft creates per server units / stdin
    # minecraft-server-$NAME.{service/socket}

    serverService = "minecraft-server-melody.service";
    serverSocket = "minecraft-server-melody.socket";
    stdinFifo = config.services.minecraft-servers.managementSystem.systemd-socket.stdinSocket.path "melody";
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
          timerConfig = {
            OnBootSec = "30min";
            OnUnitActiveSec = "4h";
          };
        };
        services.minecraft-backup = {
          inherit (cfg.backup) enable;
          # Triggered by the timer only; never pull the server up (autoStart may be off)
          after = [
            serverService
            serverSocket
          ];
          path = [
            pkgs.bash
            pkgs.gnugrep
            pkgs.restic
            pkgs.systemd
            pkgs.uutils-coreutils-noprefix
          ];
          serviceConfig = {
            Type = "oneshot";
            User = config.users.users.minecraft.name;
          };
          script =
            ''
              if ! systemctl is-active --quiet ${serverService}; then
                echo "${serverService} is not running, skipping backup"
                exit 0
              fi

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
                echo "$1" >> '${stdinFifo}'
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
                  backup ${serverDir}
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
              # Re-enable saving however we exit, including a failed backup
              trap "rcon save-on" EXIT

              # rcon is fire-and-forget (stdin fifo), so wait for the server to
              # log that the flush finished before reading the world files
              log_offset=$(stat -c %s '${serverLog}' 2>/dev/null || echo 0)
              exec {save_log}< <(exec timeout 5m tail -c "+$((log_offset + 1))" -F '${serverLog}' 2>/dev/null)
              tail_pid=$!
              rcon 'save-all flush'
              saved=0
              grep -q -m1 'Saved the game' <&"$save_log" && saved=1
              kill "$tail_pid" 2>/dev/null || true
              exec {save_log}<&-
              if [ "$saved" -ne 1 ]; then
                rcon 'say §c§lERROR: §r§cWorld backup aborted, save did not finish'
                echo "Timed out waiting for 'save-all flush' to finish" >&2
                exit 1
              fi

              do_backup

              rcon 'say §a§lSUCCESS: §r§aWorld backup complete!'
            '';
        };
      };
    };
}
