{lib, ...}:
with lib; {
  options.TM.styles.catppuccin = {
    enable = mkEnableOption "Catppucchin themeing";
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
