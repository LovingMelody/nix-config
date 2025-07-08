{
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.TM.programs.thunderbird;
in {
  options.TM.programs.thunderbird.enable = mkEnableOption "Enable Thunderbird";

  config = mkIf cfg.enable {
    programs.thunderbird = {
      enable = true;
      profiles.default = {
        isDefault = true;
      };
    };
  };
}
