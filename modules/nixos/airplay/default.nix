{
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkOption mkMerge mkIf mkDefault;
  cfg = config.TM.airplay;
in {
  options.TM.airplay = {
    client = {
      enable = mkEnableOption "Allow system to cast to airplay servers";
      latency = mkOption {
        default = null;
        description = "Adjust raop latency if there is dropouts (EX: 500)";
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.client.enable {
      services.avahi.enable = mkDefault true;
      services.pipewire = {
        # opens UDP ports 6001-6002
        raopOpenFirewall = mkDefault true;

        extraConfig.pipewire = {
          "10-airplay" = {
            "context.modules" = [
              ({
                  name = "libpipewire-module-raop-discover";
                }
                // (mkIf (cfg.client.latency != null) {
                  args."raop.latency.ms" = cfg.client.latency;
                }))
            ];
          };
        };
      };
    })
  ];
}
