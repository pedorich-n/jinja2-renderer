{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default-linux";
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
    ];

    perSystem = { config, system, pkgs, lib, ... }: {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [
          inputs.poetry2nix.overlays.default
        ];
      };

      checks =
        let
          tests = import ./tests { inherit (config.lib) render-templates; inherit pkgs; };
        in
        tests;

      packages = {
        jinja2-renderer = pkgs.callPackage ./nix/jinja2-renderer.nix { };
      };

      lib = {
        render-templates = pkgs.callPackage ./nix/render-templates.nix { inherit (config.packages) jinja2-renderer; };
      };

      overlayAttrs = {
        inherit (config.packages) jinja2-renderer;
      };
    };

  });
}
