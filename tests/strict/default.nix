{ pkgs, render-templates }:
let
  rendered = strict: render-templates {
    name = "strict-test-${pkgs.lib.boolToString strict}";
    templates = ./templates;
    variables = {
      foo = "bar"; # Wrong variables! 
    };
    outputPrefix = "test";
    inherit strict;
  };

in
{
  strict-true = pkgs.testers.testBuildFailure (rendered true);

  strict-false = pkgs.testers.testEqualContents {
    assertion = "Render templates correclty";
    expected = pkgs.writeTextDir "test/example.txt" (builtins.readFile ./expected/example.txt);
    actual = (rendered false);
  };
}
