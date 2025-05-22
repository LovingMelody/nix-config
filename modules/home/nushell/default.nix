{
  config,
  lib,
  ...
}: let
  cfg = config.TM.shells.nushell;
  inherit (lib) mkEnableOption mkIf;
in {
  options.TM.shells.nushell.enable =
    mkEnableOption "A modern shell written in Rust"
    // {
      default = true;
    };

  config = mkIf cfg.enable {
    programs.nushell = {
      enable = true;
      extraConfig = ''
        def nuopen [arg, --raw (-r)] { if $raw { open -r $arg } else { open $arg } }
        alias open = ^open
      '';
      extraEnv = ''
        $env.config = {
          show_banner: false,
        }
      '';
    };
  };
}
