{lib, ...}: let
  inherit (lib) mkEnableOption mkOption types;
in {
  options.TM.styles.catppuccin = {
    enable = mkEnableOption "Catppucchin theming";
    flavor = mkOption {
      type = types.enum [
        "Latte"
        "Frappe"
        "Macchiato"
        "Mocha"
      ];
      default = "Mocha";
    };
  };
}
