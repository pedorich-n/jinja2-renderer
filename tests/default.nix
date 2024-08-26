{ pkgs, render-templates }:
builtins.foldl' (acc: test: acc // (import test { inherit pkgs render-templates; })) { } [
  ./basic
  ./strict
]

