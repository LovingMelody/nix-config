{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.TM.programs.geeqie;
  inherit (lib) mkEnableOption mkIf;
in {
  options.TM.programs.geeqie = {
    enable = mkEnableOption "Lightweight GTK based image viewer";
    defaultApps =
      mkEnableOption "Set geeqie to be the default image viewer"
      // {
        default = true;
      };
  };
  config = mkIf cfg.enable {
    xdg.mimeApps.defaultApplications = mkIf cfg.defaultApps {
      "image/jpeg" = "org.geeqie.Geeqie.desktop";
      "image/bmp" = "org.geeqie.Geeqie.desktop";
      "image/x-bmp" = "org.geeqie.Geeqie.desktop";
      "image/x-MS-bmp" = "org.geeqie.Geeqie.desktop";
      "image/gif" = "org.geeqie.Geeqie.desktop";
      "image/x-icon" = "org.geeqie.Geeqie.desktop";
      "image/png" = "org.geeqie.Geeqie.desktop";
      "image/x-portable-anymap" = "org.geeqie.Geeqie.desktop";
      "image/x-portable-bitmap" = "org.geeqie.Geeqie.desktop";
      "image/x-portable-graymap" = "org.geeqie.Geeqie.desktop";
      "image/x-portable-pixmap" = "org.geeqie.Geeqie.desktop";
      "image/x-tga" = "org.geeqie.Geeqie.desktop";
      "image/tiff" = "org.geeqie.Geeqie.desktop";
      "image/x-xbitmap" = "org.geeqie.Geeqie.desktop";
      "image/x-xpixmap" = "org.geeqie.Geeqie.desktop";
      "image/svg" = "org.geeqie.Geeqie.desktop";
      "image/svg+xml" = "org.geeqie.Geeqie.desktop";
      "image/x-png" = "org.geeqie.Geeqie.desktop";
      "image/xpm" = "org.geeqie.Geeqie.desktop";
      "image/x-ico" = "org.geeqie.Geeqie.desktop";
    };
    home.packages = [pkgs.geeqie];
  };
}
