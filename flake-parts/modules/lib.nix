# Based on https://github.com/hercules-ci/flake-parts/blob/8471fe90ad337a8074e957b69ca4d0089218391d/modules/checks.nix
# And https://github.com/hercules-ci/flake-parts/issues/220#issuecomment-2053718001
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
