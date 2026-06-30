{
  self,
  config,
  lib,
  ...
}: let
  cfg = config.TM.users;
  inherit (lib) mkIf mkEnableOption;
in {
  options.TM.users.enable = mkEnableOption "User defaults - Opt out" // {default = true;};
  imports = [
    "${self}/modules/nixos/users/perUser/root"
    "${self}/modules/nixos/users/perUser/melody"
    "${self}/modules/nixos/users/perUser/builder"
  ];

  config = mkIf cfg.enable {
    # systemd.sysusers.enable = true;
    # Create groups for servies
    # Audio Group

    users.groups = {
      # Audio Services (EX Jellyfin & Polaris)
      audio = {};
      # Video Services (EX Jellyfin & Polaris)
      video = {};
      # Gaming Services (EX Steam)
      games = {};
      # Virtualization Services (EX QEMU)
      virtualization = {};
      # SSH
      ssh = {};
    };
  };
}
