# Jinja2 Render

Simple CLI tool to render Jinja2 templates


## NIX Usage

```nix

pkgs.render-templates {
    templates = ./templates; # Path to templates; Must be a folder
    includes = [ 
        builtins.path {name = "macros"; path = ../macros; }; # Extra files to include to Jinja2 Env
    ];
    variables = {
        foo = "bar";
    }; # Variables to use for substitution;
    outputPrefix = "example/folder"; # Where to save rendered files under $out
    name = "example-templates";
    stricut = true; # Disallow underfined variables
};

```