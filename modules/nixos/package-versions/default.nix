{
  lib,
  config,
  ...
}: let
  cfg = config.TM.current-system-packages;
  inherit (lib) mkEnableOption mkIf;
in {
  options.TM.current-system-packages = {
    enable =
      mkEnableOption "Store all packages and versions"
      // {
        default = false;
      };
  };

  config = mkIf cfg.enable {
    environment.etc.current-system-packages.text = let
      packages = builtins.map (p: "${p.name}") config.environment.systemPackages;
      sortedUnique = builtins.sort builtins.lessThan (lib.unique packages);
      formatted = builtins.concatStringsSep "\n" sortedUnique;
    in
      formatted;
  };
}
