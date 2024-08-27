{ lib, pkgs }:
let
  extraConfig = { lib, ... }: {
    options._module.args = lib.mkOption {
      internal = true; # Hide `_module` from the docs
    };

    config._module = {
      check = false; # Don't check for unset variables
      args = {
        inherit pkgs lib; # Provide pkgs and lib to modules
      };
    };
  };

  optionsFor = module:
    (lib.evalModules {
      modules = [
        extraConfig
        module
      ];
    }).options;

  makeOptionsDoc = module: (pkgs.nixosOptionsDoc {
    options = optionsFor module;
  }).optionsCommonMark;

  # showDocs = pkgs.writeShellApplication {
  #   name = "show-docs";
  #   runtimeInputs = with pkgs; [ less glow ];
  #   text = ''
  #     glow -p "$1"
  #   '';
  # };
in
pkgs.stdenvNoCC.mkDerivation (finalAttrs:
{
  name = "render-templates.doc";

  dontUnpack = true;
  dontInstall = true;
  dontFixup = true;

  # meta.mainProgram = "docs";

  # nativeBuildInputs = with pkgs; [ mkdocs ];

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/{bin,docs,dist}

    cp ${../docs/mkdocs.yml} $out/mkdocs.yml
    cp ${makeOptionsDoc ../nix/render-templates-module.nix} $out/docs/module.md

    runHook postBuild
  '';

})
