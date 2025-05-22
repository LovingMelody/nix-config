{
  lib,
  pkgs,
  config,
  ...
}: let
  whoami = lib.getExe' pkgs.coreutils "whoami";
  pgrep = lib.getExe' pkgs.procps "pgrep";
in
  pkgs.writeShellScript "lock-screen.sh" ''
    # I'm not entirely sure that this is actually the best
    # But it works for me, systems are normally only single user but we dont want
    # A script or something to trigger this thats running on another user
    export USER="$(${whoami})"
    # idk why 1password will just open itself if its not already running and stay open
    # when the entire point of this command is just to lock if the app isnt locked ._.
    ${pgrep} -u "$USER" '1password' && 1password --lock || echo "warn: 1password does not appear to be running"
    # Check if hyprlock is already running, we dont specify bin path here
    # Since hyprlock might be a different path (autoupdates idk)
    ${pgrep} -u "$USER" hyprlock || ${lib.getExe config.programs.hyprlock.package} --immediate $@
  ''
