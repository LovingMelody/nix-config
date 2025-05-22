{
  lib,
  config,
  ...
} @ args: let
  inherit (lib) mkEnableOption mkOption types;
  # Basic redef to inherit OS config
  # There is a better way to do this but I dont know it
  # Should probably get added to lib.TM eventually...
  fromOS = import ./fromOS.nix {inherit lib args;};
  mkEnableTarget = txt: module: (mkEnableOption txt) // {default = fromOS module false;};
in {
  options.TM = {
    isDesktop = mkEnableTarget "Environment is on a desktop" ["isDesktop"];
    isGui = mkEnableTarget "Environment is gui" ["isGui"];
    isLaptop = mkEnableTarget "Environment is on a laptop" ["isLaptop"];
    isServer = mkEnableTarget "Environment is on a server" ["isServer"];
    isWSL = mkEnableTarget "Environment is running through WSL" ["isWSL"];
    hasHDRDisplay = mkEnableTarget "System has a HDR capable Display" ["hasHDRDisplay"];
    libExtra = mkOption {
      description = "Libs from TM that are required to be loaded in with the config";
      type = types.attrs;
      default = fromOS "libExtra" {};
    };
    defaultNetworkAdapter = mkOption {
      description = "Default Network interface for system";
      type = types.nullOr types.str;
      default = fromOS ["defaultNetworkAdapter"] null;
    };
    pokemon = {
      name = mkOption {
        description = "Name of the pokemon";
        type = types.nullOr types.str;
        default =
          fromOS [
            "pokemon"
            "name"
          ]
          null;
      };
      pokedex = mkOption {
        description = "Pokedex number for the system";
        type = types.nullOr types.int;
        default = fromOS [
          "pokemon"
          "pokedex"
        ];
      };
      variant = mkOption {
        description = "Variant of the pokemon";
        type = types.nullOr types.str;
        default =
          fromOS [
            "pokemon"
            "variant"
          ]
          null;
      };
      shiny = mkEnableTarget "Is a shiny pokemon?" [
        "pokemon"
        "shiny"
      ];
    };
  };
  config = {
    warnings = lib.optional (
      config.TM.defaultNetworkAdapter == null
    ) "TM.defaultNetworkAdapter is not defined";
    TM.libExtra = {
      inherit fromOS mkEnableTarget;
    };
    assertions = [
      {
        assertion = !config.TM.isLaptop || !config.TM.isDesktop;
        message = "System cannot be both a laptop & a desktop";
      }
      {
        assertion = config.TM.isLaptop != config.TM.isDesktop;
        message = "config.TM.isLpatop or config.TM.isDesktop needs to be defined";
      }
    ];
  };
}
