{
  description = "Melody's NixOS configuration";

  outputs = {
    self,
    systems,
    ...
  } @ inputs: let
    lib = inputs.nixpkgs.lib.extend (_final: _prev:
      {
        ${self.namespace} = import ./lib {
          inherit self;
          inherit (inputs.nixpkgs) lib;
        };
      }
      // inputs.home-manager.lib);
    nixpkgs-overlays = [
      inputs.niri.overlays.default
      inputs.nix-citizen.overlays.default
      # NOTE: Disabled breaks CI, changes upstream in pr#425870
      # inputs.nix-citizen.overlays.updated-vulkan-sdk
      inputs.self.overlays.default
      inputs.nix-minecraft.overlays.default
      inputs.nix-topology.overlays.default
      inputs.rust-overlay.overlays.default
    ];
    listdir = dir: builtins.attrNames (lib.filterAttrs (_: t: t == "directory") (builtins.readDir dir));
    defineModules = type:
      builtins.listToAttrs (map (name: {
        inherit name;
        value = import "${self}/modules/${type}/${name}";
      }) (listdir "${self}/modules/${type}"));
    defineNixpkgs = system:
      import inputs.nixpkgs {
        inherit system;
        overlays = nixpkgs-overlays;
        config = {allowUnfree = true;};
      };
    forAllSystems = f: lib.genAttrs (import systems) (system: f (defineNixpkgs system));
    treefmtEval = forAllSystems (pkgs: inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix);
  in {
    inherit lib;
    namespace = "TM";
    nixosModules = defineModules "nixos";
    homeModules = defineModules "home";
    formatter = builtins.mapAttrs (_n: v: v.config.build.wrapper) treefmtEval;
    overlays.default = import ./overlays/default {inherit inputs self lib;};
    nixosConfigurations = let
      inherit (inputs.nixpkgs.lib) nixosSystem filterAttrs;
      mkHost = host:
        nixosSystem rec {
          system = import "${self}/systems/${host}/system.nix";
          specialArgs = {
            inherit system host lib self nixpkgs-overlays;
            inputs = inputs // {inherit self;};
          };
          modules =
            [
              "${self}/systems/${host}"
              ({config, ...}: {
                system.stateVersion = (import "${self}/stateVersion.nix").nixos;
                networking.hostName = host;
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  extraSpecialArgs = specialArgs // {osConfig = config;};
                  sharedModules =
                    [
                      inputs.catppuccin.homeModules.catppuccin
                      inputs.nix-index-database.hmModules.nix-index
                      inputs.nvf.homeManagerModules.default
                      inputs.sops-nix.homeManagerModules.sops
                      inputs.impermanence.nixosModules.home-manager.impermanence
                      inputs.stylix.homeModules.stylix
                    ]
                    ++ (lib.mapAttrsToList (_: m: m) self.homeModules);
                };
              })
              inputs.aagl.nixosModules.default
              inputs.disko.nixosModules.disko
              inputs.home-manager.nixosModules.home-manager
              inputs.nix-gaming.nixosModules.pipewireLowLatency
              inputs.nix-gaming.nixosModules.platformOptimizations
              inputs.nix-gaming.nixosModules.wine
              inputs.nix-citizen.nixosModules.StarCitizen
              inputs.nix-minecraft.nixosModules.minecraft-servers
              # inputs.nixos-cosmic.nixosModules.default
              inputs.nvf.nixosModules.default
              inputs.sops-nix.nixosModules.sops
              inputs.spicetify-nix.nixosModules.default
              inputs.stylix.nixosModules.stylix
              inputs.catppuccin.nixosModules.catppuccin
              inputs.lanzaboote.nixosModules.lanzaboote
              inputs.impermanence.nixosModules.impermanence
              inputs.nix-topology.nixosModules.default
            ]
            ++ (lib.mapAttrsToList (_: m: m) self.nixosModules);
        };
    in
      builtins.mapAttrs (name: _: mkHost name) (filterAttrs (n: t: t == "directory" && (! builtins.elem n ["Melodys-MBP"])) (builtins.readDir "${self}/systems"));
    packages = forAllSystems (pkgs: {
      inherit
        (pkgs)
        star-citizen
        rsi-launcher
        wine-astral
        wine-astral-ntsync
        catppuccin-base16
        gargoyle
        gallery-dl
        gallery-dl-unstable
        nitch
        rename-padded-numbers
        textools
        unique-basenames
        xivlauncher-rb
        gposingway
        slower
        firefox
        brave
        chromium
        discord
        ;
      inherit (pkgs.kdePackages) qtwebengine;
      inherit (pkgs.obs-studio-plugins) obs-ios-camera-source obs-image-reaction;
      topology-map =
        (import inputs.nix-topology {
          inherit pkgs;
          modules = [
            ./topology
            {inherit (self) nixosConfigurations;}
          ];
        }).config.output;

      installer-iso = self.nixosConfigurations.installer.config.system.build.images.iso-installer;
    });
  };
  nixConfig = {
    extra-substituters = ["https://cache.garnix.io"];
    extra-trusted-public-keys = ["cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="];
  };
  # TODO: Migrate server configs to this flake
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs = {
    aagl = {
      url = "github:ezKEa/aagl-gtk-on-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
        rust-overlay.follows = "rust-overlay";
      };
    };
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-compat.url = "github:edolstra/flake-compat";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
    garnix-lib = {
      url = "github:garnix-io/garnix-lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    ini-merger = {
      url = "github:LovingMelody/ini-merger";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs = {
        flake-compat.follows = "flake-compat";
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
        rust-overlay.follows = "rust-overlay";
      };
    };
    lib-aggregate = {
      url = "github:nix-community/lib-aggregate";
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs-lib.follows = "nixpkgs";
      };
    };
    niri = {
      url = "github:YaLTeR/niri";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        rust-overlay.follows = "rust-overlay";
      };
    };
    nix-citizen = {
      url = "github:LovingMelody/nix-citizen";
      inputs = {
        nix-gaming.follows = "nix-gaming";
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
        treefmt-nix.follows = "treefmt-nix";
        flake-parts.follows = "flake-parts";
      };
    };
    nix-eval-jobs = {
      url = "github:nix-community/nix-eval-jobs";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nix-index/nixpkgs";
    };
    nix-index = {
      url = "github:nix-community/nix-index";
      inputs = {
        flake-compat.follows = "flake-compat";
        nixpkgs.follows = "nixpkgs";
      };
    };
    nix-minecraft = {
      url = "github:Infinidoge/nix-minecraft";
      inputs = {
        flake-compat.follows = "flake-compat";
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
    };
    nix-reshade = {
      url = "github:LovingMelody/nix-reshade";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.treefmt-nix.follows = "treefmt-nix";
    };
    nix-topology = {
      url = "github:oddlama/nix-topology";
      inputs = {
        devshell.follows = "devshell";
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
    };
    nixos-anywhere = {
      url = "github:nix-community/nixos-anywhere";
      inputs = {
        disko.follows = "disko";
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
    # nixos-cosmic = {
    #   url = "github:lilyinstarlight/nixos-cosmic";
    #   inputs = {
    #     flake-compat.follows = "flake-compat";
    #     rust-overlay.follows = "rust-overlay";
    #   };
    # };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
      };
    };
    nvf = {
      url = "github:NotAShelf/nvf";
      inputs = {
        flake-parts.follows = "flake-parts";
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
      };
    };
    moonlight-mod = {
      url = "github:moonlight-mod/moonlight";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    schemes = {
      url = "github:tinted-theming/schemes";
      flake = false;
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
      };
    };
    stylix = {
      url = "github:nix-community/stylix";
      inputs = {
        flake-compat.follows = "flake-compat";
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
        tinted-schemes.follows = "schemes";
        flake-parts.follows = "flake-parts";
      };
    };
    systems.url = "github:nix-systems/default";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
