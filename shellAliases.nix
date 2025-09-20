{
  lib,
  pkgs,
  ...
}: {
  #l = "${pkgs.eza}/bin/eza";
  #ls = "${pkgs.eza}/bin/eza";
  #ll = "${pkgs.eza}/bin/eza -l";
  g = lib.getExe pkgs.git;
  t = "${lib.getExe pkgs.tig} status";
  e = "$EDITOR";
  ee = "${lib.getExe pkgs.fzf} --print0 | xargs -0 $EDITOR";
  download = lib.getExe pkgs.aria;
  ".." = "cd ..";
  "..." = "cd ../..";
  "...." = "cd ../../../";
  cat = "${lib.getExe pkgs.bat} -p";
  cp = "${lib.getExe' pkgs.uutils-coreutils-noprefix "cp"} --reflink=auto --sparse=auto";
  sudo = "sudo ";
  df = lib.getExe pkgs.duf;
  hl = "ls --hyperlink=auto -alh";
  hla = "ls --hyperlink=auto -A";
  hll = "ls --hyperlink=auto -l";
  hlla = "ls --hyperlink=auto -lA";
  hllt = "ls --hyperlink=auto -l --tree";
  hls = "ls --hyperlink=auto";
  hlt = "ls --hyperlink=auto --tree";
  find-font = "${lib.getExe' pkgs.fontconfig "fc-list"} | ${lib.getExe pkgs.fzf} --preview '${lib.getExe' pkgs.fontconfig "fc-match"} {}'";
}
