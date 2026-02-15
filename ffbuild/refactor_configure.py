import os
import stat
from pathlib import Path
import re

def refactor():
    conf_path = Path('configure')
    conf_backup = conf_path.with_name('configure.bak')
    conf_backup.write_text(conf_path.read_text(encoding='utf-8'), encoding='utf-8')

    lines = conf_path.read_text(encoding='utf-8').splitlines()

    functions = []
    main_script = []

    in_function = False
    current_func = []
    brace_count = 0

    # Matches functions starting at col 0
    func_start_re = re.compile(r'^([a-zA-Z0-9_]+)\s*(\(\))?\s*\{')

    for line in lines:
        if not in_function:
            match = func_start_re.match(line)
            if match:
                in_function = True
                current_func = [line]
                brace_count = line.count('{') - line.count('}')
                if brace_count <= 0:
                    functions.append('\n'.join(current_func))
                    current_func = []
                    in_function = False
            else:
                main_script.append(line)
        else:
            current_func.append(line)
            brace_count += line.count('{') - line.count('}')
            if brace_count <= 0:
                functions.append('\n'.join(current_func))
                current_func = []
                in_function = False

    print(f'Total functions found: {len(functions)}')

    # Find a good place for source call: after the copyright header
    insert_pos = 0
    for i, line in enumerate(main_script):
        if line.startswith('LC_ALL='):
            insert_pos = i
            break

    main_script.insert(insert_pos, '. ffbuild/configure_functions.sh')

    # Progress indicator logic
    progress_logic = r'''
# Progress indicator
# Removed variable: current_check=0 (2026-02-17) - replaced by autoconf-style progress lines.
progress_msg_list=
progress_msg_count=0
progress(){
    [ "$quiet" = "yes" ] && return
    [ -n "$progress_msg_list" ] && return
    progress_msg_list=$1
    progress_msg_count=1
}

progress_parts(){
    [ "$quiet" = "yes" ] && return
    label=$1
    shift
    progress_msg_list=
    progress_msg_count=0
    for part in "$@"; do
        progress_msg_list="${progress_msg_list}${progress_msg_list:+
}${label} ${part}"
        progress_msg_count=$((progress_msg_count + 1))
    done
}

progress_clear(){
    progress_msg_list=
    progress_msg_count=0
}

progress_result(){
    [ "$quiet" = "yes" ] && return
    [ -z "$progress_msg_list" ] && return
    result=$1
    while IFS= read -r progress_line; do
        [ -n "$progress_line" ] && printf 'checking %s... %s\n' "$progress_line" "$result" >&2
    done <<EOF
$progress_msg_list
EOF
    progress_clear
}

phase(){
    [ "$quiet" = "yes" ] && return
    progress_clear
    printf '\n%s\n' "$1" >&2
}
'''

    full_functions = [progress_logic.strip()]

    # Identify functions that should have progress
    check_funcs_pattern = re.compile(r'^(check_|require_|test_cc|test_cxx|test_objcc|test_as|test_ld|test_cpp|test_pkg_config)')

    added_progress = 0
    for func in functions:
        f_lines = func.splitlines()
        first_line = f_lines[0]
        match = func_start_re.match(first_line)
        if match:
            func_name = match.group(1)
            if check_funcs_pattern.match(func_name) and len(f_lines) > 1:
                has_progress = any('progress ' in line or 'progress_parts ' in line for line in f_lines[:5])
                if not has_progress:
                    f_lines.insert(1, '    progress "' + func_name + ' $1"')
                    full_functions.append('\n'.join(f_lines))
                    added_progress += 1
                else:
                    full_functions.append(func)
            else:
                full_functions.append(func)
        else:
            full_functions.append(func)

    print(f'Added progress indicators to {added_progress} functions.')

    # Write files
    out_path = Path('ffbuild/configure_functions.sh')
    out_path.write_text('\n\n'.join(full_functions) + '\n', encoding='utf-8')
    conf_path.write_text('\n'.join(main_script) + '\n', encoding='utf-8')

    # Ensure executable
    st = conf_path.stat()
    conf_path.chmod(st.st_mode | stat.S_IEXEC)
    print('Done.')

if __name__ == '__main__':
    refactor()
