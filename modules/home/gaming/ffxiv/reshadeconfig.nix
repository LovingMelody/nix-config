{
  config,
  cfg,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) replaceStrings;
  windowsSep = replaceStrings ["/"] ["\\"];
  shaders = "Z:${config.home.homeDirectory}/.xlcore/ffxiv/game/reshade-shaders/shaders";
  textures = "Z:${config.home.homeDirectory}/.xlcore/ffxiv/game/reshade-shaders/textures";
  EffectSearchPaths = [(windowsSep shaders)] ++ cfg.reshade.extraShaderPaths;
  TextureSearchPaths = [(windowsSep textures)] ++ cfg.reshade.extraTexturePaths;
  PresetPath = windowsSep "Z:${config.home.homeDirectory}/.xlcore/ffxiv/game/reshade-presets/${cfg.reshade.defaultPreset}";

  copyFont = font:
  # ReShade needs an exact path to the font's .ttf
    pkgs.runCommandLocal "reshade-stylix.ttf"
    {FONTCONFIG_FILE = pkgs.makeFontsConf {fontDirectories = [font.package];};}
    ''
      font=$(${pkgs.fontconfig}/bin/fc-match -v "${font.name}" | grep "file:" | cut -d '"' -f 2)
      cp $font $out
    '';

  EditorFont = windowsSep "Z:${toString (copyFont config.stylix.fonts.monospace)}";
  Font = windowsSep "Z:${toString (copyFont config.stylix.fonts.sansSerif)}";
in {
  GENERAL = {
    inherit EffectSearchPaths;
    inherit PresetPath;
    inherit TextureSearchPaths;
  };
  SCREENSHOT = {
    SavePath = windowsSep "Z:${cfg.reshade.screenshotPath}/";
  };
  STYLE = {
    inherit Font EditorFont;
  };
}
