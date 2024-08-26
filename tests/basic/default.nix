{ pkgs, render-templates }:
let
  rendered = render-templates {
    name = "derivation-test";
    templates = ./templates;
    includes = [ ./macros ];
    variables = {
      name = "world";
      program = "Nix";
    };
    outputPrefix = "test";
    strict = true;
  };

in
{
  basic = pkgs.testers.testEqualContents {
    assertion = "Render templates correclty";
    expected = pkgs.writeTextDir "test/example.txt" (builtins.readFile ./expected/example.txt);
    actual = rendered;
  };
}
