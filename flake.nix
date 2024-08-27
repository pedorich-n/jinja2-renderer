{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
        systems.follows = "systems";
        treefmt-nix.follows = "";
        nix-github-actions.follows = "";
      };
    };
  };

  outputs = inputs@{ flake-parts, systems, self, ... }: flake-parts.lib.mkFlake { inherit inputs; } ({ withSystem, ... }: {
    systems = import systems;
    imports = [
      inputs.flake-parts.flakeModules.easyOverlay
      ./flake-parts/modules/lib.nix
      ./flake-parts/module-args.nix
      ./flake-parts/packages.nix
      ./flake-parts/lib.nix
    ];

    perSystem = { config, system, pkgs, lib, ... }: {

      checks =
        let
          tests = import ./tests { inherit (config.lib) render-templates; inherit pkgs; };
        in
        tests;
    };

  });
}
