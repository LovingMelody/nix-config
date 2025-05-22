{pkgs, ...}: {
  #l = "${pkgs.eza}/bin/eza";
  #ls = "${pkgs.eza}/bin/eza";
  #ll = "${pkgs.eza}/bin/eza -l";
  g = "${pkgs.git}/bin/git";
  t = "${pkgs.tig}/bin/tig status";
  e = "$EDITOR";
  ee = "${pkgs.fzf}/bin/fzf --print0 | xargs -0 $EDITOR";
  download = "${pkgs.aria}/bin/aria2c";
  ".." = "cd ..";
  "..." = "cd ../..";
  "...." = "cd ../../../";
  cat = "${pkgs.bat}/bin/bat -p";
  cp = "${pkgs.coreutils-full}/bin/cp --reflink=auto --sparse=auto";
  sudo = "sudo ";
  df = "${pkgs.duf}/bin/duf";
  hl = "ls --hyperlink=auto -alh";
  hla = "ls --hyperlink=auto -A";
  hll = "ls --hyperlink=auto -l";
  hlla = "ls --hyperlink=auto -lA";
  hllt = "ls --hyperlink=auto -l --tree";
  hls = "ls --hyperlink=auto";
  hlt = "ls --hyperlink=auto --tree";
  find-font = "${pkgs.fontconfig}/bin/fc-list | ${pkgs.fzf}/bin/fzf --preview '${pkgs.fontconfig}/bin/fc-match {}'";
}
