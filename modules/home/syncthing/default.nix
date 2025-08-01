{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.TM.services.syncthing;
in {
  options.TM.services.syncthing = {
    enable = mkEnableOption "Enable File sync" // {default = true;};
  };
  config = mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      tray.enable = config.TM.isGui;
      settings.options = {
        relaysEnabled = false;
        urAccepted = 0;
      };
    };
  };
}
