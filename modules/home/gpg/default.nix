{
  lib,
  config,
  ...
}: let
  cfg = config.TM.programs.gpg;
  inherit (lib) mkEnableOption mkIf;
in {
  options.TM.programs.gpg.enable = mkEnableOption "Enable GPG" // {default = true;};

  config = mkIf cfg.enable {programs.gpg.enable = true;};
}
