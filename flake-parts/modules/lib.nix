{ lib, flake-parts-lib, ... }:
let
  inherit (lib)
    mkOption
    types
    ;
  inherit (flake-parts-lib)
    mkTransposedPerSystemModule
    ;
in
mkTransposedPerSystemModule {
  name = "lib";
  option = mkOption {
    type = types.lazyAttrsOf types.raw;
    default = { };
    description = ''
      Per system lib functions
    '';
  };
  file = ./lib.nix;
}