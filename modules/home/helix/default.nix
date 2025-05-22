{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.TM.programs.helix;
  inherit (lib) mkEnableOption mkIf;
in {
  options.TM.programs.helix.enable =
    mkEnableOption "helix editor"
    // {
      default = true;
    };

  config = mkIf cfg.enable {
    programs.helix = {
      enable = true;
      settings = {
        editor = {
          bufferline = "multiple";
          color-modes = true;
          mouse = true;
          line-number = "relative";
          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };
          file-picker.hidden = false;
          insert-final-newline = true;
          lsp = {
            display-messages = true;
            display-inlay-hints = true;
          };
          whitespace = {
            render = "all";
          };
        };
      };
      extraPackages = with pkgs; [
        nil
        marksman
        texlab
      ];
    };
  };
}
