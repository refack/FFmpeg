#!/usr/bin/env python3

import argparse
import sys
import os
from pathlib import Path
import json
import re
from typing import Any
from jinja2 import Environment, FileSystemLoader, select_autoescape

type ContextDict = dict[str, Any]

# Setup Jinja2 environment
TEMPLATE_DIR = Path(__file__).parent / 'templates'
env = Environment(
    loader=FileSystemLoader(TEMPLATE_DIR),
    autoescape=select_autoescape(['html', 'xml']),
    keep_trailing_newline=True
)


def render_template(template_name: str, context: ContextDict, output_path: Path | str | None = None, mode: str = 'w') -> None:
    template = env.get_template(template_name)
    rendered = template.render(context)

    if output_path:
        with Path(output_path).open(mode) as f:
            f.write(rendered)
    else:
        sys.stdout.write(rendered)


def cmd_file2c(args: argparse.Namespace) -> None:
    data = Path(args.input).read_bytes()

    context = {
        'var_name': args.var_name,
        'data': data
    }
    render_template('file2c.c.jinja', context, Path(args.output))


# Regex to match Makefile variable assignments: OBJS-$(CONDITION) += file.o
VAR_ASSIGNMENT_PATTERN = re.compile(r'^(OBJS|SHLIBOBJS|STLIBOBJS|RESOBJS)(?:-(.+?))?\s*\+?=\s*(.*)')
# Regex to match 'include' or '-include' directives
INCLUDE_DIRECTIVE_PATTERN = re.compile(r'^-?include\s+\$\(SRC_PATH\)/(.+)')
# Regex to match Makefile 'if' function: $(if $(CONDITION), files)
INLINE_IF_PATTERN = re.compile(r'\$\(if\s+([^,]+),\s*([^)]+)\)')

TARGET_CONDITION_PREFIX = 'TARGET_COND_'
FORCE_CONDITION_KEY = 'FORCE_COND'


def normalize_resource_path(token: str) -> Path:
    """Converts resource object files to their generated C source paths."""
    if token.endswith('.html.o'):
        base_name = Path(token[:-7]).name
        return Path(f'${{CMAKE_CURRENT_BINARY_DIR}}/{base_name}_html.c')
    if token.endswith('.css.o'):
        base_name = Path(token[:-6]).name
        return Path(f'${{CMAKE_CURRENT_BINARY_DIR}}/{base_name}_css.c')
    return Path()


def normalize_source_path(token: str, make_variables: dict[str, str], var_type: str, cur_dir: Path) -> Path:
    """Normalizes a Makefile source/object path to a standard source path."""
    for name, value in make_variables.items():
        token = token.replace(f'$({name})', value)

    if var_type == 'RESOBJS':
        resource_path = normalize_resource_path(token)
        if resource_path.name:
            return resource_path

    if '$' in token and not token.startswith('${CMAKE_CURRENT_BINARY_DIR}'):
        return Path()

    filename = Path(token)
    if filename.suffix != '.o':
        return filename

    for ext in ['.c', '.cpp', '.asm', '.rc', '.S', '.m', '.v', '.ptx', '.comp', '.glsl', '.cl']:
        maybe_file = filename.with_suffix(ext)
        if (cur_dir / maybe_file).exists():
            return maybe_file

    for pre, rep in {'.spv.o': '.glsl', '.ptx.o': '.cu', '.metallib.o': '.metal'}.items():
        maybe_file = filename.with_name(filename.name.replace(pre, rep))
        if (cur_dir / maybe_file).exists():
            return maybe_file

    raise FileNotFoundError(f"Could not find source file for object: [{cur_dir}] [{filename}]")


def read_logical_lines(file_path: Path):
    """Reads a Makefile and joins lines ending with backslash."""
    lines = []
    current_line = ''
    with open(file_path, 'r') as f:
        for raw_line in f:
            raw_line = raw_line.strip()
            if raw_line.endswith('\\'):
                current_line += f'{raw_line[:-1]} '
            else:
                current_line += raw_line
                lines.append(current_line)
                current_line = ''
    if current_line:
        lines.append(current_line)
    return lines


def parse_makefile_logic(makefile_path: Path, cur_dir: Path, cmake_var_prefix: str,
                         make_variables: dict[str, str], target_condition_map: dict[str, str],
                         force_condition: str | None):
    """Recursively parses a Makefile and extracts source files grouped by condition."""

    print(f'parse_makefile_logic [{cur_dir}] [{makefile_path}]', file=sys.stderr)

    blocks = []
    if not makefile_path.exists():
        return blocks

    for logical_line in read_logical_lines(makefile_path):
        match logical_line:
            # Handle includes
            case line if (include_match := INCLUDE_DIRECTIVE_PATTERN.match(line)):
                included_path = normalize_source_path(include_match.group(1), make_variables, 'include', cur_dir).absolute()
                included = parse_makefile_logic(included_path, cur_dir, cmake_var_prefix, make_variables, target_condition_map, force_condition)
                blocks.extend(included)

            # Handle variable assignments
            case line if (var_match := VAR_ASSIGNMENT_PATTERN.match(line)):
                var_type = var_match.group(1)
                raw_condition = var_match.group(2)
                files_string = var_match.group(3).split('#', 1)[0] if '#' in var_match.group(3) else var_match.group(3)

                if not files_string.strip():
                    continue

                active_condition = None
                if raw_condition:
                    raw_condition = raw_condition.strip()
                    match raw_condition:
                        case 'yes':
                            pass
                        case c if c.startswith('$(') and c.endswith(')'):
                            active_condition = c[2:-1]
                        case c if c in target_condition_map:
                            active_condition = target_condition_map[c]
                        case _:
                            continue    # Skip unmappable conditions

                cmake_var_name = f'{cmake_var_prefix}_SOURCES'

                def inline_if_replacer(match_obj):
                    cond = match_obj.group(1)
                    content = match_obj.group(2)
                    if cond.startswith('$(') and cond.endswith(')'):
                        cond = cond[2:-1]

                    inline_files = [
                        pf
                        for f in content.split()
                        if (pf := normalize_source_path(f, make_variables, var_type, makefile_path.parent).as_posix()) != '.'
                    ]

                    if inline_files:
                        blocks.append({
                            'condition': cond,
                            'var': cmake_var_name,
                            'files': inline_files,
                            'parent_condition': active_condition or force_condition
                        })
                    return ''

                remaining_files_str = INLINE_IF_PATTERN.sub(inline_if_replacer, files_string)
                source_files = []
                for token in remaining_files_str.split():
                    normalized_token = normalize_source_path(token, make_variables, var_type, cur_dir)
                    # Skip files with unresolved Makefile variables, unless they are CMake-style
                    if not normalized_token.name:
                        continue
                    source_files.append(normalized_token.as_posix())

                if source_files:
                    blocks.append({
                        'condition': None,
                        'var': cmake_var_name,
                        'files': source_files,
                        'parent_condition': active_condition or force_condition
                    })

    return blocks


def cmd_config_mak_to_cmake(args: argparse.Namespace) -> None:
    """Parses config.mak and generates a config.cmake for use in CMakeLists.txt."""
    variables: ContextDict = {}
    with Path(args.input).open('r') as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('#') or '=' not in line:
                continue

            key, value = map(str.strip, line.split('=', 1))

            match key[0], value:
                case '!', _:
                    variables[key[1:]] = False
                case _, 'yes':
                    variables[key] = True
                case _:
                    variables[key] = value

    context = {'variables': variables}
    render_template('config.cmake.jinja', context, Path(args.output))


def cmd_makefile_to_cmake(args: argparse.Namespace) -> None:
    """
    Parses a Makefile (or a .sourcelist.mak file) and generates a CMake list of source files.
    This command handles:
    - Variable assignments (OBJS, SHLIBOBJS, etc.)
    - Conditional assignments (OBJS-$(CONFIG_VAR) += ...)
    - Path normalization (replacing .o with .c)
    - Resource file conversion (e.g., .html.o -> _html.c)
    - Transclusion of other makefiles via 'include' directive
    """

    make_variables = {'ARCH': 'x86'}
    target_condition_map = {}
    force_condition = None

    for var_arg in args.vars:
        if '=' not in var_arg:
            continue
        key, value = var_arg.split('=', 1)
        if key == FORCE_CONDITION_KEY:
            force_condition = value
        elif key.startswith(TARGET_CONDITION_PREFIX):
            target_condition_map[key[len(TARGET_CONDITION_PREFIX):]] = value
        else:
            make_variables[key] = value

    makefile_abspath = Path(args.input).absolute()
    data_blocks = parse_makefile_logic(
        makefile_abspath,
        makefile_abspath.parent,
        args.var_prefix,
        make_variables,
        target_condition_map,
        force_condition
    )

    output_path = Path(args.output) if args.output else None
    render_template('sources.cmake.jinja', {'blocks': data_blocks}, output_path, mode='a' if args.append else 'w')


def cmd_print_config(args: argparse.Namespace) -> None:
    # Read key-value pairs from stdin
    config_items: ContextDict = {}
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        parts = line.split(None, 1)
        if len(parts) >= 2:
            key = parts[0]
            value = parts[1]
            if value == 'yes':
                config_items[key] = True
            elif value == 'no':
                config_items[key] = False
            else:
                config_items[key] = value
        elif len(parts) == 1:
            # Maybe just key? configure sends "key value"
            pass

    prefix = args.prefix
    files = args.files.split()

    for filename in files:
        file_path = Path(filename)
        match file_path.suffix:
            case '.h':
                render_template('config_header.h.jinja', {'config_items': config_items, 'prefix': prefix}, file_path, mode='a')
            case '.asm':
                render_template('config_asm.asm.jinja', {'config_items': config_items, 'prefix': prefix}, file_path, mode='a')
            case '.mak':
                render_template('config_mak.mak.jinja', {'config_items': config_items, 'prefix': prefix}, file_path, mode='a')
            case '.texi':
                render_template('config_texi.texi.jinja', {'config_items': config_items, 'prefix': prefix}, file_path, mode='a')


def cmd_print_enabled_components(args: argparse.Namespace) -> None:
    items = args.items.split()
    context = {
        'struct_name': args.struct_name,
        'name': args.name,
        'items': items
    }
    render_template('component_list.c.jinja', context, Path(args.file), mode='w')


def cmd_generate_config(args: argparse.Namespace) -> None:
    context: ContextDict = {}
    if args.json:
        try:
            context.update(json.loads(args.json))
        except json.JSONDecodeError:
            print("Error decoding JSON", file=sys.stderr)
    if args.vars:
        for arg in args.vars:
            if '=' in arg:
                k, v = arg.split('=', 1)
                context[k] = v
    if args.vars_stdin:
        for line in sys.stdin:
            line = line.strip()
            if not line:
                continue
            if '=' in line:
                k, v = line.split('=', 1)
                context[k] = v

    if args.env_vars:
        for var in args.env_vars:
            if var in os.environ:
                context[var] = os.environ[var]

    context['vars'] = context
    render_template(args.template, context, Path(args.output), mode='a' if args.append else 'w')


def main() -> None:
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(dest='command', required=True)

    # file2c
    p_file2c = subparsers.add_parser('file2c')
    p_file2c.add_argument('input')
    p_file2c.add_argument('output')
    p_file2c.add_argument('var_name')

    # config_mak_to_cmake
    p_cmtc = subparsers.add_parser('config_mak_to_cmake')
    p_cmtc.add_argument('input')
    p_cmtc.add_argument('output')

    # makefile_to_cmake
    p_mtc = subparsers.add_parser('makefile_to_cmake')
    p_mtc.add_argument('input')
    p_mtc.add_argument('var_prefix')
    p_mtc.add_argument('vars', nargs='*', default=[])
    p_mtc.add_argument('--output', '-o', default=None)
    p_mtc.add_argument('--append', action='store_true')

    # print_config
    p_pc = subparsers.add_parser('print_config')
    p_pc.add_argument('--prefix', default='')
    p_pc.add_argument('--files', required=True)

    # print_enabled_components
    p_pec = subparsers.add_parser('print_enabled_components')
    p_pec.add_argument('--file', required=True)
    p_pec.add_argument('--struct-name', required=True)
    p_pec.add_argument('--name', required=True)
    p_pec.add_argument('--items', required=True, help="Space separated list of items")

    # generate_config
    p_gc = subparsers.add_parser('generate_config')
    p_gc.add_argument('--template', required=True)
    p_gc.add_argument('--output', required=True)
    p_gc.add_argument('--json', help="JSON string with context variables")
    p_gc.add_argument('--vars', nargs='*', default=[], help="Key=value pairs")
    p_gc.add_argument('--vars-stdin', action='store_true', help="Read Key=value pairs from stdin")
    p_gc.add_argument('--env-vars', nargs='*', default=[], help="List of environment variables to include in context")
    p_gc.add_argument('--append', action='store_true')

    args = parser.parse_args()
    print(f"Generating code with {args}", file=sys.stderr)

    match args.command:
        case 'file2c':
            cmd_file2c(args)
        case 'config_mak_to_cmake':
            cmd_config_mak_to_cmake(args)
        case 'makefile_to_cmake':
            cmd_makefile_to_cmake(args)
        case 'print_config':
            cmd_print_config(args)
        case 'print_enabled_components':
            cmd_print_enabled_components(args)
        case 'generate_config':
            cmd_generate_config(args)


if __name__ == '__main__':
    main()
