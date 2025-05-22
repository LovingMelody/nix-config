{
  config,
  lib,
  ...
}: let
  cfg = config.TM.programs.starship;
  inherit (lib) mkEnableOption mkIf;
in {
  options.TM.programs.starship.enable =
    mkEnableOption "A minimal, blazing fast, and extremely customizable prompt for any shell"
    // {
      default = true;
    };

  config = mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      settings = {
        add_newline = false;
        battery = {
          full_symbol = "🔋";
          charging_symbol = "⚡️";
          discharging_symbol = "💀";
          display = [
            {
              threshold = 10;
              style = "bold red";
            }
            {
              threshold = 30;
              style = "bold yellow";
            }
          ];
        };
        directory = {
          substitutions = {
            "Documents" = "󰈙 ";
            "Downloads" = " ";
            "Music" = " ";
            "Pictures" = " ";
            "~/.local/share/Cryptomator/mnt/" = "🔓";
          };
        };
        username = {
          show_always = true;
        };
        time.disabled = false;
        format = "$all";
      };
    };
  };
}
