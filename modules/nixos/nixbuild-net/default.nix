{
  config,
  lib,
  ...
}: let
  cfg = config.TM.nixbuild-net;
  inherit (lib) mkEnableOption mkIf mkAfter;
in {
  options.TM.nixbuild-net = {
    enable =
      mkEnableOption "Enable nixbuild"
      // {
        default = true;
      };
  };

  config = mkIf cfg.enable {
    programs.ssh.extraConfig = ''
      Host eu.nixbuild.net
      PubkeyAcceptedKeyTypes ssh-ed25519
      ServerAliveInterval 60
      IPQoS throughput
      IdentityFile /var/build-helpers/nixbuild-key
    '';
    programs.ssh.knownHosts = {
      nixbuild = {
        hostNames = ["eu.nixbuild.net"];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPIQCZc54poJ8vqawd8TraNryQeJnvH1eLpIDgbiqymM";
      };
    };
    nix = {
      settings = {
        substituters = mkAfter ["ssh://eu.nixbuild.net"];
        trusted-public-keys = ["nixbuild.net/UL9GKE-1:SsaxUnnJn7buBvS7RsElxeDvThiJr8oT37ZAjyvzKhU="];
      };
      distributedBuilds = true;
      extraOptions = "builders-use-substitutes = true";
      buildMachines = [
        {
          hostName = "eu.nixbuild.net";
          system = "x86_64-linux";
          maxJobs = 100;
          supportedFeatures = [
            "benchmark"
            "big-parallel"
            "x86-64-v3"
          ];
        }
        {
          hostName = "eu.nixbuild.net";
          system = "i686-linux";
          maxJobs = 100;
          supportedFeatures = [
            "benchmark"
            "big-parallel"
          ];
        }
        {
          hostName = "eu.nixbuild.net";
          system = "aarch64-linux";
          maxJobs = 100;
          supportedFeatures = [
            "benchmark"
            "big-parallel"
          ];
        }
      ];
    };
  };
}
