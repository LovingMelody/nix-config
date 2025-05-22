{
  config,
  lib,
  ...
}: let
  cfg = config.TM.programs.chromium;
  inherit (lib) mkEnableOption mkIf optional;
in {
  options.TM.programs.chromium.enable = mkEnableOption "Chromium browser";

  config = mkIf cfg.enable {
    programs.chromium = {
      enable = true;
      extensions =
        [
          {id = "nblkbiljcjfemkfjnhoobnojjgjdmknf";} # PronounDB
          {id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";} # Ublock Origin
          {id = "bmnlcjabgnpnenekpadlanbbkooimhnj";} # Paypal Honey
          {id = "aeblfdkhhhdcdjpifhhbdiojplfjncoa";} # 1Password
          {id = "lckanjgmijmafbedllaakclkaicjfmnk";} # Clear URLs
          {id = "mnjggcdmjocbbbhaepdhchncahnbgone";} # Sponsor block for YouTube
          {id = "kekjfbackdeiabghhcdklcdoekaanoel";} # Mal Sync
          {id = "clngdbkpkpeebahjckkjfobafhncgmne";} # Stylus
          {id = "fhcgjolkccmbidfldomjliifgaodjagh";} # Cookie AutoDelete
        ]
        ++ optional config.TM.programs._1password.enable {
          id = "aeblfdkhhhdcdjpifhhbdiojplfjncoa"; # 1Password
        };
    };
  };
}
