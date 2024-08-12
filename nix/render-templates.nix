{ pkgs
, lib
, jinja2-renderer
, ...
}:
{ templates
, includes ? [ ]
, variables ? { }
, outputPrefix ? ""
, name ? "templates"
, strict ? true
, ...
} @ args:
let
  prepareIncludesEntry = entry:
    if (lib.isDerivation entry) then { name = entry.name; path = entry; }
    else if (lib.isPath entry) then { name = builtins.baseNameOf entry; path = entry; }
    else if (lib.isAttrs entry) then entry
    else builtins.abort "Unknown 'includes' entry type for '${builtins.toString entry}'!";

  combinedIncludes = pkgs.linkFarm "includes" (builtins.map prepareIncludesEntry includes);

  extraArgs = builtins.removeAttrs args [
    "templates"
    "includes"
    "variables"
    "name"
    "strict"
  ];
in
pkgs.stdenvNoCC.mkDerivation ({
  name = "rendered-${name}";

  srcs = [
    (builtins.path { name = "templates"; path = templates; })
  ] ++ lib.optional (includes != [ ]) combinedIncludes;

  sourceRoot = ".";

  dontPatch = true;
  dontConfigure = true;
  dontInstall = true;
  dontFixup = true;

  passAsFile = [ "variables" ];
  variables = builtins.toJSON variables;

  nativeBuildInputs = [ jinja2-renderer ];

  buildPhase =
    let
      arguments = [
        ''--template "$sourceRoot/templates"''
        ''--output "$dst"''
      ]
      ++ lib.optional (includes != [ ]) ''--include "$sourceRoot/includes"''
      ++ lib.optional (variables != { }) ''--variables "$variablesPath"''
      ++ lib.optional strict "--strict";
    in
    ''
      runHook preBuild

      dst="$out/$outputPrefix"
      mkdir -p "$dst"
      jinja2-renderer ${lib.concatStringsSep " " arguments}

      runHook postBuild
    '';
} // extraArgs)

