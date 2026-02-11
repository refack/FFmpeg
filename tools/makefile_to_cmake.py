
import sys
import os
import re

# Regex for Make variable assignment
VAR_ASSIGN_RE = re.compile(r'^(OBJS|SHLIBOBJS|STLIBOBJS)(?:-(.+?))?\s*\+?=\s*(.*)')
INCLUDE_RE = re.compile(r'^include\s+\$\(SRC_PATH\)/(.+)')
INCLUDE_IGNORE_RE = re.compile(r'^-include\s+\$\(SRC_PATH\)/(.+)')
IF_RE = re.compile(r'\$\(if\s+([^,]+),\s*([^)]+)\)')

def process_file_name(f):
    f = f.replace('$(ARCH)', '${ARCH}')
    if f.endswith('.o'):
        f = f[:-2] + '.c'
    return f

def parse_makefile(makefile_path, root_dir, var_prefix):
    cmake_lines = []

    if not os.path.exists(makefile_path):
        return [f"# Warning: File {makefile_path} not found"]

    with open(makefile_path, 'r') as f:
        # Handle line continuations
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

    for line in lines:
        # Handle includes
        m_inc = INCLUDE_RE.match(line)
        if not m_inc:
            m_inc = INCLUDE_IGNORE_RE.match(line)

        if m_inc:
            included_file = m_inc.group(1)
            full_included_path = os.path.join(root_dir, included_file)

            cmake_lines.append(f"# Processed include: {included_file}")
            sub_lines = parse_makefile(full_included_path, root_dir, var_prefix)
            cmake_lines.extend(sub_lines)
            continue

        m_var = VAR_ASSIGN_RE.match(line)
        if m_var:
            var_type = m_var.group(1) # OBJS, SHLIBOBJS, STLIBOBJS
            raw_condition = m_var.group(2) # e.g. $(CONFIG_VAR) or target
            files = m_var.group(3)

            if not files:
                continue

            # Remove comments
            if '#' in files:
                files = files.split('#', 1)[0]

            condition = None
            if raw_condition:
                raw_condition = raw_condition.strip()
                if raw_condition == 'yes':
                    pass
                elif raw_condition.startswith('$(') and raw_condition.endswith(')'):
                    condition = raw_condition[2:-1]
                else:
                    cmake_lines.append(f"# Skipping target specific assignment: {line}")
                    continue

            cmake_var = f"{var_prefix}_SOURCES"

            extra_blocks = []

            def if_replacer(match):
                cond = match.group(1)
                res = match.group(2)
                if cond.startswith('$(') and cond.endswith(')'):
                    cond = cond[2:-1]

                res_files = res.split()
                processed_res = []
                for f in res_files:
                    f = process_file_name(f)
                    if '$' in f:
                        # Warning about unexpanded
                        continue
                    if f: processed_res.append(f)

                extra_blocks.append((cond, processed_res))
                return ""

            files = IF_RE.sub(if_replacer, files)

            file_list = files.split()
            src_files = []
            for f in file_list:
                f = process_file_name(f)
                if '$' in f:
                    cmake_lines.append(f"# Warning: Unexpanded variable in file list: {f}")
                    continue
                src_files.append(f)

            # Emit code

            # Main block
            if src_files:
                if condition:
                    if condition.startswith('!'):
                        cond_expr = f"NOT {condition[1:]}"
                    else:
                        cond_expr = condition

                    cmake_lines.append(f"if({cond_expr})")
                    for src in src_files:
                         cmake_lines.append(f"    list(APPEND {cmake_var} {src})")
                    cmake_lines.append("endif()")
                else:
                    for src in src_files:
                        cmake_lines.append(f"list(APPEND {cmake_var} {src})")

            # Extra blocks from $(if ...)
            for extra_cond, extra_files in extra_blocks:
                if not extra_files: continue

                if extra_cond.startswith('!'):
                    extra_cond_expr = f"NOT {extra_cond[1:]}"
                else:
                    extra_cond_expr = extra_cond

                if condition:
                     if condition.startswith('!'):
                        cond_expr = f"NOT {condition[1:]}"
                     else:
                        cond_expr = condition
                     cmake_lines.append(f"if({cond_expr})")

                cmake_lines.append(f"if({extra_cond_expr})")
                for src in extra_files:
                    cmake_lines.append(f"    list(APPEND {cmake_var} {src})")
                cmake_lines.append("endif()")

                if condition:
                    cmake_lines.append("endif()")

    return cmake_lines

def main():
    if len(sys.argv) < 3:
        print("Usage: makefile_to_cmake.py <Makefile> <VarPrefix>")
        sys.exit(1)

    makefile = sys.argv[1]
    var_prefix = sys.argv[2]
    root_dir = os.getcwd() # Assume running from root

    cmake_lines = parse_makefile(makefile, root_dir, var_prefix)

    for line in cmake_lines:
        print(line)

if __name__ == "__main__":
    main()
