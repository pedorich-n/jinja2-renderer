import argparse
import json
from functools import reduce
from pathlib import Path
from typing import List

from jinja2 import Environment, FileSystemLoader, StrictUndefined, Template


def load_variables(json_files: List[Path]) -> dict:
    """Load variables from a JSON file."""
    jsons: List[dict] = []
    for file in json_files:
        with open(file, "r") as f:
            jsons.append(json.load(f))

    return reduce(lambda acc, d: acc | d, jsons, {})


def render_template(template: Template, variables: dict, output: Path) -> None:
    """Render a Jinja2 template and save it to a file."""
    rendered_content = template.render(variables)
    output.parent.mkdir(exist_ok=True, parents=True)
    with open(output, "w") as output_file:
        output_file.write(rendered_content)
    print(f"Rendered and saved to {output}")


def render_templates(templates_root: Path, includes: List[Path], output_root: Path, variables_paths: List[Path], strict: bool) -> None:
    env = Environment(
        loader=FileSystemLoader([templates_root] + includes),
        trim_blocks=True,
        lstrip_blocks=True,
    )
    if strict:
        env.undefined = StrictUndefined

    variables = load_variables(variables_paths)
    output_root.mkdir(exist_ok=True, parents=True)

    for template_path in templates_root.rglob("*.j2"):
        relative_path = template_path.relative_to(templates_root)
        print(f"Loading {relative_path}")
        template = env.get_template(str(relative_path))

        output_relative_path = relative_path.with_suffix("")  # Strip the '.j2' suffix
        output_path = output_root.joinpath(output_relative_path)

        render_template(template, variables, output_path)


def main():
    parser = argparse.ArgumentParser(formatter_class=lambda prog: argparse.ArgumentDefaultsHelpFormatter(prog, max_help_position=60))
    parser.add_argument("--templates", type=Path, required=True, help="Path to templates to render")
    parser.add_argument("--include", type=Path, required=False, action="append", help="Extra folder(s) to include", default=[])
    parser.add_argument("--output", type=Path, required=True, help="Path to output folder")
    parser.add_argument("--variables", type=Path, required=False, action="append", help="Path to JSON variables to use for substitution")
    parser.add_argument("--strict", action="store_true", required=False, help="If set, no undefined variables are allowed", default=False)

    args = parser.parse_args()

    templates_root: Path = args.templates.resolve()
    includes: List[Path] = [p.resolve() for p in args.include]
    output_root: Path = args.output.resolve()
    variables_paths: List[Path] = [path.resolve() for path in args.variables]

    render_templates(
        templates_root=templates_root, includes=includes, output_root=output_root, variables_paths=variables_paths, strict=args.strict
    )
