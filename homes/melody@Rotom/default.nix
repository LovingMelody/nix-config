{lib, ...}: {
  TM = {
    home-profiles.desktop.enable = false;
    programs = {
      git.enable = true;
      _1password = {
        enable = true;
        sshAgent = true;
        gpgSign = {
          enable = true;
          signingKey = lib.removeSuffix "\n" (builtins.readFile (lib.TM.get-ssh-key-file "melody" "primary"));
        };
      };
    };
  };
  home.stateVersion = lib.TM.stateVersion.nixos;
}
