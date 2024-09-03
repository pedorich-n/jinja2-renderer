{ pkgs, ... }:
pkgs.poetry2nix.mkPoetryApplication {
  projectDir = ../jinja2-renderer;

  meta.mainProgram = "jinja2-renderer";

  checkGroups = [ "check" ]; # To omit dev dependencies
  checkPhase = ''
    runHook preCheck

    pytest

    runHook postCheck
  '';
}
