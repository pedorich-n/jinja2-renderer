{ pkgs, ... }:
pkgs.poetry2nix.mkPoetryApplication {
  projectDir = ../jinja2-renderer;
  checkGroups = [ ]; # To omit dev dependencies

  meta.mainProgram = "jinja2-renderer";
}
