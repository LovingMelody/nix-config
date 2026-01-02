{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (pkgs.stdenv) isDarwin;
  inherit (lib) mkDefault mkIf optional TM;
in {
  imports = [(TM.get-shared-module "defaults")];

  config = {
    programs = {
      # Don't allow on servers
      direnv.enable = !config.TM.isServer;
      yazi = {
        enable = true;
        plugins.lazygit = pkgs.yaziPlugins.lazygit;
      };
      broot.enable = true;
    };
    home = {
      keyboard = mkIf isDarwin {layout = true;};
      homeDirectory = let
        inherit (config.home) username;
      in
        mkDefault (
          if pkgs.stdenv.isDarwin
          then "/Users/${username}"
          else if (username != "root")
          then "/home/${username}"
          else "/root"
        );
      packages =
        [
          pkgs.file
          pkgs.imagemagickBig
          pkgs.kitty.terminfo
          pkgs.kitty.kitten
          pkgs.nh
          pkgs.rclone
          pkgs.ripgrep
          pkgs.fselect
          pkgs.jq
          pkgs.yq-go
          pkgs.nix-output-monitor
          pkgs.gallery-dl-unstable
        ]
        ++ optional config.TM.isGui pkgs.ffmpeg-full
        ++ optional (!config.TM.isGui) pkgs.ffmpeg-headless;
      file = let
        wallpaper-ext = builtins.match ".*\\.([^.]+)$" config.stylix.image;
      in {
        # TODO: Make this a variable
        ".face" = mkIf (config.home.username == "melody") {
          source = builtins.fetchurl {
            url = "https://cdn.little-melody.net/Public/face.png";
            sha256 = "1cq388rr3lzbdcb0zswzihsp19smjn2wnjx1bwdzmrb1hdj8anxx";
          };
        };
        ".wallpaper" = mkDefault {source = config.stylix.image;};

        ".wallpaper.${
          if wallpaper-ext != null
          then builtins.head wallpaper-ext
          else ""
        }".source =
          config.stylix.image;
        ".cargo/config.toml" = mkDefault {
          text = ''
            [alias]
            gen = "generate"

            [cargo-new]
            name = "${config.programs.git.settings.user.name}"
            email = "${config.programs.git.settings.user.email}"
            vcs = "git"
          '';
        };
        ".local/bin/set-title" = mkDefault {
          text = ''
            #!/usr/bin/env bash
            set-title() {
              echo -ne "\033]0;$@\007"
            }
            set-title $@
          '';
          executable = true;
        };
      };
      stateVersion = lib.TM.stateVersion.nixos;
    };
  };
}
