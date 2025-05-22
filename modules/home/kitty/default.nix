{
  config,
  lib,
  ...
}: let
  cfg = config.TM.programs.kitty;
  inherit (lib) mkEnableOption mkIf;
in {
  options.TM.programs.kitty.enable =
    mkEnableOption "A modern, hackable, featureful, OpenGL based terminal emulator";

  config = mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      settings = {
        font_family = config.stylix.fonts.monospace.name;
        font_size = config.stylix.fonts.sizes.terminal;
        tab_bar_min_tabs = 1;
        tab_bar_edge = "bottom";
        tab_bar_style = "powerline";
        tab_powerline_style = "slanted";
        tab_title_template = "{title}{' :{}:'.format(num_windows) if num_windows > 1 else ''}";
        show_hyperlink_targets = "yes";
        shell = "fish";
        update_check_interval = 0;
      };
    };
  };
}
