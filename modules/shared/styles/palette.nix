{
  config,
  lib,
}: let
  inherit (lib) importJSON;
  inherit (config.catppuccin) flavor;
  palette = (importJSON "${config.catppuccin.sources.palette}/palette.json").${flavor}.colors;
  getHex = n: lib.strings.removePrefix "#" palette.${n}.hex;
in {
  base00 = getHex "base";
  base01 = getHex "mantle";
  base02 = getHex "surface0";
  base03 = getHex "surface1";
  base04 = getHex "surface2";
  base05 = getHex "text";
  base06 = getHex "rosewater";
  base07 = getHex "lavender";
  base08 = getHex "red";
  base09 = getHex "peach";
  base0A = getHex "yellow";
  base0B = getHex "green";
  base0C = getHex "teal";
  base0D = getHex "blue";
  base0E = getHex "mauve";
  base0F = getHex "flamingo";
  base10 = getHex "mantle"; # darker background
  base11 = getHex "crust"; # darkest background
  base12 = getHex "maroon"; # bright red
  base13 = getHex "rosewater"; # bright yellow
  base14 = getHex "green"; # bright green
  base15 = getHex "sky"; # bright cyan
  base16 = getHex "sapphire"; # bright blue
  base17 = getHex "pink"; # bright purple
}
