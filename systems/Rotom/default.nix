# Pokedex: #0479
# Rotom - Its electric-like body can enter some kinds of machines and take control in order to make mischief.
{
  pkgs,
  home-manager,
  ...
}: {
  imports = [./hardware-configuration-extended.nix];

  TM = {
    pokemon = {
      name = "Rotom";
      pokedex = 479;
    };
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

  services = {
    openssh.enable = true;
    davfs2.enable = true;
    photoprism = {
      enable = true;
      originalsPath = "/data/photoprism";
      passwordFile = "/.secrets-extra/photoprism-admin";
      address = "0.0.0.0";
    };
    flaresolverr.enable = false;
  };
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
