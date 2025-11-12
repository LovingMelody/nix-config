{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.TM.zfs;
  inherit
    (lib)
    mkDefault
    mkEnableOption
    mkForce
    mkIf
    ;
in {
  options.TM.zfs = {
    enable = mkEnableOption "Enable ZFS specifics";
    useUnstable = mkEnableOption "Enable ZFS unstable";
  };
  config = mkIf cfg.enable {
    boot.zfs.package = mkDefault (
      if (cfg.useUnstable && (lib.versionAtLeast pkgs.zfs_unstable.version pkgs.zfs.version))
      then pkgs.zfs_unstable
      else pkgs.zfs
    );
    services.zfs = {
      autoScrub.enable = true;
      trim.enable = true;
    };

    systemd.targets = {
      /*
      Disable hibernate:
      ZFS hibernating is not safe and may cause data corruption
      Open issues to be addressed first:
      [make Linux hibernation (suspend-to-disk) more robust](https://github.com/openzfs/zfs/issues/12842)
      [ability to supend (and resume) all zpool IO (zpool suspend|resume)](https://github.com/openzfs/zfs/issues/12843)
      */
      hibernate.enable = mkForce false;
      hybrid-sleep.enable = mkForce false;
      suspend.enable = mkForce false;
    };
    /*
    ZFS is for some reason pushing me to use the RT kernel, which I do not want
    ZFS Kernel may unexpectedly degrade in version due to ZFS not updating before the "latest" kernel is dropped (if not lts)
    We will just use LTS instead of using `config.boot.zfs.package.latestCompatibleLinuxPackages`
    This shouldn't cause anything to break...
    */
    boot.kernelPackages = mkForce (lib.TM.latestZFSKernel pkgs config.boot.zfs.package);
    # (if isServer then pkgs.linuxPackages else pkgs.linuxPackages_xanmod)
  };
}
