{
  lib,
  config,
  ...
}: let
  cfg = config.TM.sound;
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;
in {
  options.TM.sound = {
    enable = mkEnableOption "Enable sound";
    support32Bit = mkEnableOption "Enable 32 bit support" // {default = true;};
  };

  config = mkIf cfg.enable {
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa = {
        enable = true;
        inherit (cfg) support32Bit;
      };
      pulse.enable = true;
    };
    # services.pipewire.jack.enable is deprecated (global LD_LIBRARY_PATH impurity);
    # run JACK apps through `pw-jack <app>` instead.
    environment.systemPackages = [config.services.pipewire.package.jack];
  };
}
