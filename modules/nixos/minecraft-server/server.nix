{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.TM.server.services.minecraft;
  inherit
    (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  sources = builtins.fromJSON (builtins.readFile ./sources.json);
  version =
    builtins.replaceStrings
    [
      "."
      "\n"
    ]
    [
      "_"
      ""
    ]
    (builtins.readFile ./version);
in {
  options.TM.server.services.minecraft = {
    enable = mkEnableOption "Minecraft server";
    autoStart = mkEnableOption "Auto start Minecraft server";
    eula = mkEnableOption "Accept EULA";
    openFirewall = mkEnableOption "Open firewall for Minecraft server";
    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/TM/minecraft";
      description = "Directory to store Minecraft data in";
    };
    rcon = {
      port = mkOption {
        type = types.int;
        default = 51339;
        description = "Port for RCON";
      };
    };
    image = mkOption {
      type = types.str;
      default = "itzg/minecraft-server:java17-alpine";
      description = "Docker image to use for the Minecraft server";
    };
    worldName = mkOption {
      type = types.str;
      default = "world";
      description = "Name of the world to use";
    };
  };

  config = mkIf cfg.enable {
    topology.self.services.minecraft = {
      name = "Minecraft (${cfg.worldName})";
      inherit (pkgs.minecraft) icon;
    };
    users.users.minecraft = {
      description = "Minecraft server service user";
      home = mkDefault cfg.dataDir;
      isSystemUser = true;
      group = config.users.groups.minecraft.name;
    };
    users.groups.minecraft = {};
    sops.secrets."Minecraft/server_properties/ops_list" = {
      sopsFile = lib.TM.get-secret-file "Minecraft/generic.yaml";
      owner = config.users.users.minecraft.name;
      reloadUnits = [
        "minecraft-server.socket"
        "minecraft-server.service"
      ];
      path = cfg.dataDir + "/ops.json";
    };
    services.minecraft-servers = {
      enable = true;
      inherit (cfg) eula;
      servers.melody = {
        enable = true;
        inherit (cfg) autoStart;
        package = pkgs.minecraftServers."fabric-${version}";
        restart = "always";
        inherit (cfg) openFirewall;
        # TODO: Allow this to be configured
        serverProperties = {
          motd = "Melody's Minecraft Server";
          difficulty = "normal";
          allow-nether = true;
          announce-player-achievements = false;
          generate-structures = true;
          snooper-enabled = false;
          pvp = false;
          allow-flight = true;
          enable-rcon = false;
          world-name = cfg.worldName;
          level-name = cfg.worldName;
          enforce-secure-profile = false;
        };
        # TODO: Allow this to be configured
        whitelist = {
          AnimeFetish = "0d1fef22-25f7-48a0-ae9b-135b50817e01";
          LovingMelody = "0d3b7ff3-198f-491c-b83f-02bcf2337924";
          archamad418 = "1996008d-5ed4-4e7a-948b-69b78e4b163f";
          Venecil = "2345bdc2-579b-48ba-9a71-d0f4c9a3ca3f";
          Berunkasuteru = "f2b3f075-d142-46e8-8752-2c6461b348cd";
          SmolBrainYasuo = "e5efa5f6-9be9-4e5a-ac2d-cae4eadb04f6";
        };
        symlinks = {
          mods = let
            from-sources = mod: pkgs.fetchurl {inherit (sources.${mod}) url sha512;};
            to-source-list = mods: builtins.map from-sources mods;
          in
            pkgs.linkFarmFromDrvs "mods" (to-source-list [
              "VanillaRefresh"
              "Terralith"
              "Tectonic"
              "Nullscape"
              "Incendium"
              "Balm"
              "NetherPortalFix"
              "ConcurrentChunkManagementEngine"
              "Krypton"
              "FabricAPI"
              "Sit!"
            ]);
        };
        files = {
        };
      };
    };
  };
}
