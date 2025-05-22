{
  lib,
  config,
  osConfig ? {},
  ...
}: let
  cfg = config.TM.security.opensnitch;
  inherit (lib) mkEnableOption mkIf;
in {
  options.TM.security.opensnitch = {
    enable =
      mkEnableOption "Enable opensnitch"
      // {
        default = osConfig.TM.security.opensnitch.enable or false;
      };
  };

  config = mkIf cfg.enable {services.opensnitch-ui.enable = true;};
}
