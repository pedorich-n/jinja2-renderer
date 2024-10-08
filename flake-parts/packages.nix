_: {
  perSystem = { config, pkgs, ... }: {
    packages = {
      jinja2-renderer = pkgs.callPackage ../nix/jinja2-renderer.nix { };
      docs = pkgs.callPackage ../nix/docs.nix { };
    };

    overlayAttrs = {
      inherit (config.packages) jinja2-renderer;
    };
  };
}
