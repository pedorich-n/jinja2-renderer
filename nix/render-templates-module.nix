{ config, pkgs, lib, jinja2-renderer, ... }:
let
  jsonFormat = pkgs.formats.json { };

  prepareIncludesEntry = entry:
    if (lib.isDerivation entry) then { name = entry.name; path = entry; }
    else if (lib.isPath entry) then { name = builtins.baseNameOf entry; path = entry; }
    else if (lib.isAttrs entry) then entry
    else builtins.abort "Unknown 'includes' entry type for '${builtins.toString entry}'!";

  combinedIncludes = pkgs.linkFarm "includes" (builtins.map prepareIncludesEntry config.includes);
in
{
  ###### interface
  options = with lib; {
    templates = mkOption {
      type = types.path;
      example = literalExpression "./templates/";
      description = ''
        Path to Jinja2 templates to render.
        :::{.warning}
        Must be a path to a folder!
        :::
      '';
    };

    name = mkOption {
      type = types.str;
      default = "templates";
      description = "Name of the resulting derivation";
    };

    includes = mkOption {
      type = with types; listOf path;
      default = [ ];
      description = "Extra paths to add to Jinja2 Environment";
      example = literalExpression ''
        [
          ./macros
          ./global-macros
        ]
      '';
    };

    variables = mkOption {
      type = jsonFormat.type;
      default = { };
      description = "Variables to use for substitution";
      example = literalExpression ''
        {
          message = "Hello World";
        }
      '';
    };

    outputPrefix = mkOption {
      type = types.str;
      default = "";
      description = "Prefix to put rendered templates under $out";
      example = literalExpression "/etc/example";
    };

    strict = mkOption {
      type = types.bool;
      default = true;
      description = "If enabled, undefined variables will lead to build failure";
    };

    extraDerivationArgs = mkOption {
      type = types.raw;
      default = { };
      description = "Extra arguments to pass to derivation";
      example = literalExpression ''
        preBuild = "mv ./templates/a.txt.j2 ./templates/b.txt.j2";
      '';
    };



    _out = mkOption {
      type = types.package;
      internal = true;
      readOnly = true;
    };
  };

  ###### implementation
  config = {
    _out = pkgs.stdenvNoCC.mkDerivation ({
      name = "rendered-${config.name}";

      srcs = [
        (builtins.path { name = "templates"; path = config.templates; })
      ] ++ lib.optional (config.includes != [ ]) combinedIncludes;

      sourceRoot = ".";

      dontPatch = true;
      dontConfigure = true;
      dontInstall = true;
      dontFixup = true;

      nativeBuildInputs = [ jinja2-renderer ];

      env = {
        variablesPath = jsonFormat.generate "variables.json" config.variables;
        inherit (config) outputPrefix;
      };

      buildPhase =
        let
          arguments = [
            ''--template "$sourceRoot/templates"''
            ''--output "$dst"''
          ]
          ++ lib.optional (config.includes != [ ]) ''--include "$sourceRoot/includes"''
          ++ lib.optional (config.variables != { }) ''--variables "$variablesPath"''
          ++ lib.optional config.strict "--strict";
        in
        ''
          runHook preBuild

          dst="$out/$outputPrefix"
          mkdir -p "$dst"
          jinja2-renderer ${lib.concatStringsSep " " arguments}

          runHook postBuild
        '';
    } // config.extraDerivationArgs);
  };
}
