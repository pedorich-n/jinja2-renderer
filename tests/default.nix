{ pkgs, render-templates }: {
  basic-test = pkgs.callPackage ./basic { inherit render-templates; };
}
