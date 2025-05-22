{
  lib,
  config,
  ...
}: let
  cfg = config.TM.programs.gpg;
  inherit (lib) mkOption mkIf types;
in {
  options.TM.programs.gpg = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable GPG";
    };
  };

  config = mkIf cfg.enable {programs.gpg.enable = true;};
}
