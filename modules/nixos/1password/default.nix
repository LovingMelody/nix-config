{
  config,
  lib,
  ...
}: let
  cfg = config.TM.programs._1password;
  inherit (lib) mkEnableOption mkIf optionals;
in {
  options.TM.programs._1password = {
    enable = mkEnableOption "Enable 1password";
    gui =
      mkEnableOption "Enable 1password gui"
      // {
        default = true;
      };
  };

  config = mkIf cfg.enable {
    environment.etc."1password/custom_allowed_browsers".text = "";
    programs = {
      _1password.enable = true;
      _1password-gui = {
        enable = true;
        polkitPolicyOwners = optionals config.TM.users.enable ["melody"];
      };
    };
  };
}
