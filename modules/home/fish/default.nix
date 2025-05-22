{
  self,
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.TM.shells.fish;
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.TM.package-helper) pins;
in {
  options.TM.shells.fish.enable =
    mkEnableOption "Smart and user-friendly command line shell"
    // {
      default = !pkgs.stdenv.isDarwin;
    };

  config = mkIf cfg.enable {
    home.packages = [pkgs.grc];
    programs.fish = {
      enable = true;
      interactiveShellInit = "fish_hybrid_key_bindings";
      shellAliases = ((import "${self}/shellAliases.nix") {inherit pkgs;}) // {};
      plugins = with pkgs; [
        {
          name = "grc";
          inherit (fishPlugins.grc) src;
        }
        {
          name = "fish-fzf";
          src = fishPlugins.fzf-fish;
        }
        # { name = "async-prompt"; src = fishPlugins.async-prompt;}

        {
          name = "replay.fish";
          src = pins."replay.fish";
        }
        {
          name = "getopts.fish";
          src = pins."getopts.fish";
        }
        {
          name = "done";
          inherit (fishPlugins.done) src;
        }
      ];
    };
  };
}
