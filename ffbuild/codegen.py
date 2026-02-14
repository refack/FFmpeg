#!/usr/bin/env python3

import argparse
import sys
import os
import json
import re
from jinja2 import Environment, FileSystemLoader, select_autoescape

# Setup Jinja2 environment
TEMPLATE_DIR = os.path.join(os.path.dirname(__file__), 'templates')
env = Environment(
    loader=FileSystemLoader(TEMPLATE_DIR),
    autoescape=select_autoescape(['html', 'xml']),
    keep_trailing_newline=True
)

def render_template(template_name, context, output_path=None, mode='w'):
    template = env.get_template(template_name)
    rendered = template.render(context)

    if output_path:
        with open(output_path, mode) as f:
            f.write(rendered)
    else:
        sys.stdout.write(rendered)

def cmd_file2c(args):
    with open(args.input, 'rb') as f:
        data = f.read()

    context = {
        'var_name': args.var_name,
        'data': data
    }
    render_template('file2c.c.jinja', context, args.output)

def cmd_config_mak_to_cmake(args):
    variables = {}
    with open(args.input, 'r') as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('#'):
                continue
            if '=' not in line:
                continue
            key, value = line.split('=', 1)
            key = key.strip()
            value = value.strip()

            if key.startswith('!'):
                key = key[1:]
                variables[key] = False
            else:
                if value == 'yes':
                    variables[key] = True
                else:
                    variables[key] = value

    context = {'variables': variables}
    render_template('config.cmake.jinja', context, args.output)

def cmd_makefile_to_cmake(args):
    VAR_ASSIGN_RE = re.compile(r'^(OBJS|SHLIBOBJS|STLIBOBJS)(?:-(.+?))?\s*\+?=\s*(.*)')
    INCLUDE_RE = re.compile(r'^include\s+\$\(SRC_PATH\)/(.+)')
    INCLUDE_IGNORE_RE = re.compile(r'^-include\s+\$\(SRC_PATH\)/(.+)')
    IF_RE = re.compile(r'\$\(if\s+([^,]+),\s*([^)]+)\)')

    def process_file_name(f, vars):
        for k, v in vars.items():
            f = f.replace(f"$({k})", v)
        if f.endswith('.o'):
            f = f[:-2] + '.c'
        return f

    def parse_makefile(makefile_path, root_dir, var_prefix, vars):
        blocks = []

        if not os.path.exists(makefile_path):
            return blocks

        with open(makefile_path, 'r') as f:
            lines = []
            current_line = ""
            for line in f:
                line = line.strip()
                if line.endswith('\\'):
                    current_line += line[:-1] + " "
                else:
                    current_line += line
                    lines.append(current_line)
                    current_line = ""
            if current_line:
                lines.append(current_line)

        for line in lines:
            m_inc = INCLUDE_RE.match(line)
            if not m_inc:
                m_inc = INCLUDE_IGNORE_RE.match(line)

            if m_inc:
                included_file = m_inc.group(1)
                for k, v in vars.items():
                    included_file = included_file.replace(f"$({k})", v)
                full_included_path = os.path.join(root_dir, included_file)
                # Recursive call
                blocks.extend(parse_makefile(full_included_path, root_dir, var_prefix, vars))
                continue

            m_var = VAR_ASSIGN_RE.match(line)
            if m_var:
                # var_type = m_var.group(1)
                raw_condition = m_var.group(2)
                files_str = m_var.group(3)

                if not files_str:
                    continue
                if '#' in files_str:
                    files_str = files_str.split('#', 1)[0]

                condition = None
                if raw_condition:
                    raw_condition = raw_condition.strip()
                    if raw_condition == 'yes':
                        pass
                    elif raw_condition.startswith('$(') and raw_condition.endswith(')'):
                        condition = raw_condition[2:-1]
                    else:
                        continue # Skip target specific assignment

                cmake_var = f"{var_prefix}_SOURCES"

                # Handle $(if ...) blocks inside the file list
                files_str_processed = files_str

                # We need to extract the if blocks and process them separately
                # because they add files conditionally.

                # Simple parser for one level of $(if ...)
                # Note: This is simplified compared to original script but should cover most cases
                # The original script used a regex replacer which added to extra_blocks.
                # Here we will do similar logic.

                def if_replacer(match):
                    cond = match.group(1)
                    res = match.group(2)
                    if cond.startswith('$(') and cond.endswith(')'):
                        cond = cond[2:-1]

                    res_files = res.split()
                    processed_res = []
                    for f in res_files:
                        f = process_file_name(f, vars)
                        if '$' in f: continue
                        if f: processed_res.append(f)

                    if processed_res:
                        blocks.append({
                            'condition': cond,
                            'var': cmake_var,
                            'files': processed_res,
                            'parent_condition': condition
                        })
                    return ""

                files_str_remaining = IF_RE.sub(if_replacer, files_str)

                file_list = files_str_remaining.split()
                src_files = []
                for f in file_list:
                    f = process_file_name(f, vars)
                    if '$' in f: continue
                    src_files.append(f)

                if src_files:
                    blocks.append({
                        'condition': None,
                        'var': cmake_var,
                        'files': src_files,
                        'parent_condition': condition
                    })
        return blocks

    vars = {}
    vars['ARCH'] = 'x86' # Fallback
    if args.vars:
        for arg in args.vars:
            if '=' in arg:
                k, v = arg.split('=', 1)
                vars[k] = v

    root_dir = os.getcwd()
    blocks = parse_makefile(args.input, root_dir, args.var_prefix, vars)

    context = {'blocks': blocks}
    render_template('sources.cmake.jinja', context, args.output)

def cmd_print_config(args):
    # Read key-value pairs from stdin
    config_items = {}
    for line in sys.stdin:
        line = line.strip()
        if not line: continue
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
        if filename.endswith('.h'):
            render_template('config_header.h.jinja', {'config_items': config_items, 'prefix': prefix}, filename, mode='a')
        elif filename.endswith('.asm'):
            render_template('config_asm.asm.jinja', {'config_items': config_items, 'prefix': prefix}, filename, mode='a')
        elif filename.endswith('.mak'):
             render_template('config_mak.mak.jinja', {'config_items': config_items, 'prefix': prefix}, filename, mode='a')
        elif filename.endswith('.texi'):
             render_template('config_texi.texi.jinja', {'config_items': config_items, 'prefix': prefix}, filename, mode='a')

def cmd_print_enabled_components(args):
    items = args.items.split()
    context = {
        'struct_name': args.struct_name,
        'name': args.name,
        'items': items
    }
    render_template('component_list.c.jinja', context, args.file, mode='w')

def cmd_generate_config(args):
    context = {}
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
            if not line: continue
            if '=' in line:
                k, v = line.split('=', 1)
                context[k] = v

    if args.env_vars:
        for var in args.env_vars:
            if var in os.environ:
                context[var] = os.environ[var]

    context['vars'] = context
    render_template(args.template, context, args.output, mode='a' if args.append else 'w')

def main():
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
    p_mtc.add_argument('vars', nargs='*')
    p_mtc.add_argument('--output', '-o', default=None)

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
    p_gc.add_argument('--vars', nargs='*', help="Key=value pairs")
    p_gc.add_argument('--vars-stdin', action='store_true', help="Read Key=value pairs from stdin")
    p_gc.add_argument('--env-vars', nargs='*', help="List of environment variables to include in context")
    p_gc.add_argument('--append', action='store_true')

    args = parser.parse_args()

    if args.command == 'file2c':
        cmd_file2c(args)
    elif args.command == 'config_mak_to_cmake':
        cmd_config_mak_to_cmake(args)
    elif args.command == 'makefile_to_cmake':
        cmd_makefile_to_cmake(args)
    elif args.command == 'print_config':
        cmd_print_config(args)
    elif args.command == 'print_enabled_components':
        cmd_print_enabled_components(args)
    elif args.command == 'generate_config':
        cmd_generate_config(args)

if __name__ == "__main__":
    main()
