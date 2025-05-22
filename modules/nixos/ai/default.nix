{
  self,
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.TM.services.ai;
  inherit
    (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    types
    ;
in {
  options.TM.services.ai = {
    ollama = {
      enable = mkEnableOption "Enable Ollama";
      openFirewall = mkEnableOption "Open Firewall";
      port = mkOption {
        type = types.int;
        default = 11434;
        description = "Port ollama listen's on";
      };
      host = mkOption {
        type = types.str;
        default = "127.0.0.1";
      };
      models = mkOption {
        type = types.listOf types.str;
        description = "List of models to load";
        default = [
          "deepseek-r1"
          "phi4"
          "dolphin3"
        ];
      };
    };
    open-webui = {
      enable = mkEnableOption "Enable Open Web UI";
      openFirewall = mkEnableOption "Open firewall";
      port = mkOption {
        type = types.int;
        default = 25398;
      };
      host = mkOption {
        type = types.str;
        default = "127.0.0.1";
      };
      environment = mkOption {
        type = types.attrsOf types.str;
        default = {
          ANONYMIZED_TELEMETRY = "False";
          DO_NOT_TRACK = "True";
          SCARF_NO_ANALYTICS = "True";
          OLLAMA_API_BASE_URL =
            if cfg.ollama.enable
            then "http://${cfg.ollama.host}:${toString cfg.ollama.port}"
            else "";
        };
      };
    };
  };
  config = mkMerge [
    (mkIf cfg.ollama.enable {
      topology.self.services.ollama = {
        hidden = mkDefault (!cfg.ollama.openFirewall);
        info = "${cfg.ollama.host}:${toString cfg.ollama.port}";
        name = "Ollama";
      };
      services.ollama = {
        inherit
          (cfg.ollama)
          enable
          openFirewall
          port
          host
          ;
        loadModels = cfg.ollama.models;
      };
    })
    (mkIf cfg.open-webui.enable {
      topology.self.services.open-webui = {
        hidden = mkDefault (!cfg.open-webui.openFirewall);
        info = "AI Web Interface: ${cfg.open-webui.host}:${toString cfg.open-webui.port}";
        name = "Open WebUI";
      };
      services.open-webui = {
        inherit
          (cfg.open-webui)
          enable
          openFirewall
          port
          host
          environment
          ;
      };
    })
  ];
}
