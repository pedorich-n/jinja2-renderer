_: {
  perSystem = { pkgs, config, ... }: {
    checks =
      let
        tests = import ../tests { inherit (config.lib) render-templates; inherit pkgs; };
      in
      tests;
  };
}
