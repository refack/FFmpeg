# --- Platform Detections ---

platform_test_cmd(){
    log "$@"
    "$@" >> $logfile 2>&1
    test_cmd_status=$?
    if [ "$quiet" != "yes" ] && [ -n "$progress_msg_list" ]; then
        if [ $test_cmd_status -eq 0 ]; then
            progress_result 'yes'
        else
            progress_result 'no'
        fi
    fi
    return $test_cmd_status
}
platform_test_stat(){
    log platform_test_stat "$@"
    stat "$1" >> $logfile 2>&1
}
platform_test_cc(){
    progress "test_cc $1"
    log platform_test_cc "$@"
    cat > $TMPC
    log_file $TMPC
    platform_test_cmd $cc $CPPFLAGS $CFLAGS "$@" $CC_C $(cc_o $TMPO) $TMPC
}
platform_test_cxx(){
    progress "test_cxx $1"
    log platform_test_cxx "$@"
    cat > $TMPCPP
    log_file $TMPCPP
    platform_test_cmd $cxx $CPPFLAGS $CXXFLAGS "$@" $CXX_C $(cxx_o $TMPO) $TMPCPP
}
platform_test_objcc(){
    progress "test_objcc $1"
    log platform_test_objcc "$@"
    cat > $TMPM
    log_file $TMPM
    platform_test_cmd $objcc -Werror=missing-prototypes $CPPFLAGS $CFLAGS $OBJCFLAGS "$@" $OBJCC_C $(cc_o $TMPO) $TMPM
}
platform_test_glslc(){
    log platform_test_glslc "$@"
    cat > $TMPGLSL
    log_file $TMPGLSL
    platform_test_cmd $glslc $GLSLCFLAGS $glslcflags "$@" $(glslc_o $TMPO) $TMPGLSL
}
platform_check_glslc(){
    progress "check_glslc $1"
    log platform_check_glslc "$@"
    name=$1
    shift 1
    disable $name
    platform_test_glslc "$@" <<EOF && enable $name
#version 460
#pragma shader_stage(compute)
#extension GL_GOOGLE_include_directive : platform_require
void main(void) {}
EOF
}
platform_test_nvcc(){
    log platform_test_nvcc "$@"
    cat > $TMPCU
    log_file $TMPCU
    tmpcu_=$TMPCU
    tmpo_=$TMPO
    [ -x "$(command -v cygpath)" ] && tmpcu_=$(cygpath -m $tmpcu_) && tmpo_=$(cygpath -m $tmpo_)
    platform_test_cmd $nvcc $nvccflags "$@" $NVCC_C $(nvcc_o $tmpo_) $tmpcu_
}
platform_check_nvcc(){
    progress "check_nvcc $1"
    log platform_check_nvcc "$@"
    name=$1
    shift 1
    disabled $name && return
    disable $name
    platform_test_nvcc "$@" <<EOF && enable $name
extern "C" {
    __global__ void hello(unsigned char *data) {}
}
EOF
}
platform_test_cpp(){
    progress "test_cpp $1"
    log platform_test_cpp "$@"
    cat > $TMPC
    log_file $TMPC
    platform_test_cmd $cc $CPPFLAGS $CFLAGS "$@" $(cc_e $TMPO) $TMPC
}
platform_test_as(){
    progress "test_as $1"
    log platform_test_as "$@"
    cat > $TMPS
    log_file $TMPS
    platform_test_cmd $as $CPPFLAGS $ASFLAGS "$@" $AS_C $(as_o $TMPO) $TMPS
}
platform_test_x86asm(){
    log platform_test_x86asm "$@"
    echo "$1" > $TMPASM
    log_file $TMPASM
    shift
    platform_test_cmd $x86asmexe $X86ASMFLAGS -Werror "$@" $(x86asm_o $TMPO) $TMPASM
}
platform_check_cmd(){
    progress "check_cmd $1"
    log platform_check_cmd "$@"
    cmd=$1
    disabled $cmd && return
    disable $cmd
    platform_test_cmd $@ && enable $cmd
}
platform_check_as(){
    progress "check_as $1"
    log platform_check_as "$@"
    name=$1
    code=$2
    shift 2
    disable $name
    platform_test_as $@ <<EOF && enable $name
$code
EOF
}
platform_check_inline_asm(){
    progress "check_inline_asm $1"
    log platform_check_inline_asm "$@"
    name="$1"
    code="$2"
    shift 2
    disable $name
    platform_test_cc "$@" <<EOF && enable $name
void foo(void){ __asm__ volatile($code); }
EOF
}
platform_check_inline_asm_flags(){
    progress "check_inline_asm_flags $1"
    log platform_check_inline_asm_flags "$@"
    name="$1"
    code="$2"
    flags=''
    shift 2
    while [ "$1" != "" ]; do
      append flags $1
      shift
    done;
    disable $name
    cat > $TMPC <<EOF
void foo(void){ __asm__ volatile($code); }
EOF
    log_file $TMPC
    platform_test_cmd $cc $CPPFLAGS $CFLAGS $flags "$@" $CC_C $(cc_o $TMPO) $TMPC &&
    enable $name && add_cflags $flags && add_asflags $flags && add_ldflags $flags
}
platform_check_insn(){
    progress "check_insn $1"
    log platform_check_insn "$@"
    platform_check_inline_asm ${1}_inline "\"$2\""
    platform_check_as ${1}_external "$2"
}
platform_check_arch_level(){
    progress "check_arch_level $1"
    log platform_check_arch_level "$@"
    level="$1"
    platform_check_as tested_arch_level ".arch $level"
    enabled tested_arch_level && as_arch_level="$level"
}
platform_check_archext_name_insn(){
    progress "check_archext_name_insn $1"
    log platform_check_archext_name_insn "$@"
    feature="$1"
    archext="$2"
    instr="$3"
    instr2="$4"
    # Check if the assembly is accepted in inline assembly.
    platform_check_inline_asm ${feature}_inline "\"$instr \n\t $instr2\""
    # We don't check if the instruction is supported out of the box by the
    # external assembler (we don't try to set ${feature}_external) as we don't
    # need to use these instructions in non-runtime detected codepaths.

    disable $feature

    enabled as_arch_directive && arch_directive=".arch $as_arch_level" || arch_directive=""

    # Test if the assembler supports the .arch_extension $archext directive.
    arch_extension_directive=".arch_extension $archext"
    platform_test_as <<EOF && enable as_archext_${archext}_directive || arch_extension_directive=""
$arch_directive
$arch_extension_directive
EOF

    # Test if we can assemble the instruction after potential .arch and
    # .arch_extension directives.
    platform_test_as <<EOF && enable ${feature}
$arch_directive
$arch_extension_directive
$instr
$instr2
EOF
}
platform_check_archext_insn(){
    progress "check_archext_insn $1"
    log platform_check_archext_insn "$@"
    feature="$1"
    instr="$2"
    instr2="$3"
    platform_check_archext_name_insn "$feature" "$feature" "$instr" "$instr2"
}
platform_check_x86asm(){
    progress "check_x86asm $1"
    log platform_check_x86asm "$@"
    name=$1
    shift
    disable $name
    platform_test_x86asm "$@" && enable $name
}
platform_test_ld(){
    progress "test_ld $1"
    log platform_test_ld "$@"
    type=$1
    shift 1
    flags=$(filter_out '-l*|*.so' $@)
    libs=$(filter '-l*|*.so' $@)
    platform_test_$type $($cflags_filter $flags) || return
    flags=$($ldflags_filter $flags)
    libs=$($ldflags_filter $libs)
    platform_test_cmd $ld $LDFLAGS $LDEXEFLAGS $flags $(ld_o $TMPE) $TMPO $libs $extralibs
}
platform_check_ld(){
    progress "check_ld $1"
    log platform_check_ld "$@"
    type=$1
    name=$2
    shift 2
    disable $name
    platform_test_ld $type $@ && enable $name
}
platform_test_code(){
    log platform_test_code "$@"
    check=$1
    headers=$2
    code=$3
    shift 3
    {
        for hdr in $headers; do
            print_include $hdr
        done
        echo "int main(void) { $code; return 0; }"
    } | platform_test_$check "$@"
}
platform_check_cppflags(){
    progress "check_cppflags $1"
    log platform_check_cppflags "$@"
    platform_test_cpp "$@" <<EOF && append CPPFLAGS "$@"
#include <stdlib.h>
EOF
}
platform_test_cflags(){
    log platform_test_cflags "$@"
    set -- $($cflags_filter "$@")
    platform_test_cc "$@" <<EOF
int x;
EOF
}
platform_check_cflags(){
    progress "check_cflags $1"
    log platform_check_cflags "$@"
    platform_test_cflags "$@" && add_cflags "$@"
}
platform_test_cxxflags(){
    progress "test_cxxflags $1"
    log platform_test_cxxflags "$@"
    set -- $($cflags_filter "$@")
    platform_test_cxx "$@" <<EOF
int x;
EOF
}
platform_check_cxxflags(){
    progress "check_cxxflags $1"
    log platform_check_cxxflags "$@"
    platform_test_cxxflags "$@" && add_cxxflags "$@"
}
platform_test_objcflags(){
    log platform_test_objcflags "$@"
    set -- $($objcflags_filter "$@")
    platform_test_objcc "$@" <<EOF
int x;
EOF
}
platform_check_objcflags(){
    progress "check_objcflags $1"
    log platform_check_objcflags "$@"
    platform_test_objcflags "$@" && add_objcflags "$@"
}
platform_check_allcflags(){
    progress "check_allcflags $1"
    allcret=0
    platform_check_cflags "$@" || allcret=$?
    platform_check_cxxflags "$@" || allcret=$?
    platform_check_objcflags "$@" || allcret=$?
    return $allcret
}
platform_test_ldflags(){
    progress "test_ldflags $1"
    log platform_test_ldflags "$@"
    set -- $($ldflags_filter "$@")
    platform_test_ld "cc" "$@" <<EOF
int main(void){ return 0; }
EOF
}
platform_check_ldflags(){
    progress "check_ldflags $1"
    log platform_check_ldflags "$@"
    platform_test_ldflags "$@" && add_ldflags "$@"
}
platform_test_stripflags(){
    log platform_test_stripflags "$@"
    # call platform_test_cc to get a fresh TMPO
    platform_test_cc <<EOF
int main(void) { return 0; }
EOF
    platform_test_cmd $strip $ASMSTRIPFLAGS "$@" $TMPO
}
platform_check_stripflags(){
    progress "check_stripflags $1"
    log platform_check_stripflags "$@"
    platform_test_stripflags "$@" && add_stripflags "$@"
}
platform_check_headers(){
    headers=$1
    progress_parts 'check_headers' $headers
    log platform_check_headers "$@"
    shift
    disable_sanitized $headers
    {
        for hdr in $headers; do
            print_include $hdr
        done
        echo "int x;"
    } | platform_test_cpp "$@" && enable_sanitized $headers
}
platform_check_header_objcc(){
    progress "check_header_objcc $1"
    log platform_check_header_objcc "$@"
    rm -f -- "$TMPO"
    header=$1
    shift
    disable_sanitized $header
    {
       echo "#include <$header>"
       echo "int main(void) { return 0; }"
    } | platform_test_objcc && platform_test_stat "$TMPO" && enable_sanitized $header
}
platform_check_apple_framework(){
    log platform_check_apple_framework "$@"
    framework="$1"
    name="$(tolower $framework)"
    header="${framework}/${framework}.h"
    disable $name
    platform_check_header_objcc $header &&
        enable $name && eval ${name}_extralibs='"-framework $framework"'
}
platform_check_func(){
    log platform_check_func "$@"
    func=$1
    shift
    disable $func
    platform_test_ld "cc" "$@" <<EOF && enable $func
extern int $func();
int main(void){ $func(); }
EOF
}
platform_check_mathfunc(){
    log platform_check_mathfunc "$@"
    func=$1
    narg=$2
    shift 2
    test $narg = 2 && args="f, g" || args="f"
    disable $func
    platform_test_ld "cc" "$@" <<EOF && enable $func
#include <math.h>
float foo(float f, float g) { return $func($args); }
int main(void){ return (int) foo; }
EOF
}
platform_check_func_headers(){
    headers=$1
    funcs=$2
    progress_parts 'check_func_headers' $headers $funcs
    log platform_check_func_headers "$@"
    shift 2
    {
        for hdr in $headers; do
            print_include $hdr
        done
        echo "#include <stdint.h>"
        for func in $funcs; do
            echo "long check_$func(void) { return (long) $func; }"
        done
        echo "int main(void) { int ret = 0;"
        # LTO could optimize out the test functions without this
        for func in $funcs; do
            echo " ret |= ((intptr_t)check_$func) & 0xFFFF;"
        done
        echo "return ret; }"
    } | platform_test_ld "cc" "$@" && enable $funcs && enable_sanitized $headers
}
platform_check_class_headers_cxx(){
    headers=$1
    classes=$2
    progress_parts 'check_class_headers_cxx' $headers $classes
    log platform_check_class_headers_cxx "$@"
    shift 2
    {
        for hdr in $headers; do
            echo "#include <$hdr>"
        done
        echo "int main(void) { "
        i=1
        for class in $classes; do
            echo "$class obj$i;"
            i=$(expr $i + 1)
        done
        echo "return 0; }"
    } | platform_test_ld "cxx" "$@" && enable $funcs && enable_sanitized $headers
}
platform_test_cpp_condition(){
    log platform_test_cpp_condition "$@"
    header=$1
    condition=$2
    shift 2
    platform_test_cpp "$@" <<EOF
#include <$header>
#if !($condition)
#error "unsatisfied condition: $condition"
#endif
EOF
}
platform_check_cpp_condition(){
    log platform_check_cpp_condition "$@"
    name=$1
    shift 1
    disable $name
    platform_test_cpp_condition "$@" && enable $name
}
platform_test_cflags_cc(){
    log platform_test_cflags_cc "$@"
    flags=$1
    header=$2
    condition=$3
    shift 3
    set -- $($cflags_filter "$flags")
    platform_test_cc "$@" <<EOF
#include <$header>
#if !($condition)
#error "unsatisfied condition: $condition"
#endif
EOF
}
platform_check_cflags_cc(){
    log platform_check_cflags_cc "$@"
    flags=$1
    platform_test_cflags_cc "$@" && add_cflags $flags
}
platform_test_cxxflags_cc(){
    log platform_test_cxxflags_cc "$@"
    flags=$1
    header=$2
    condition=$3
    shift 3
    set -- $($cflags_filter "$flags")
    platform_test_cxx "$@" <<EOF
#include <$header>
#if !($condition)
#error "unsatisfied condition: $condition"
#endif
EOF
}
platform_check_cxxflags_cc(){
    log platform_check_cxxflags_cc "$@"
    flags=$1
    platform_test_cxxflags_cc "$@" && add_cxxflags $flags
}
platform_check_lib(){
    log platform_check_lib "$@"
    name="$1"
    headers="$2"
    funcs="$3"
    shift 3
    disable $name
    platform_check_func_headers "$headers" "$funcs" "$@" &&
        enable $name && eval ${name}_extralibs="\$@"
}
platform_check_lib_cpp(){
    log platform_check_lib_cpp "$@"
    name="$1"
    headers="$2"
    code="$3"
    shift 3
    disable $name
    platform_test_code ld "$headers" "$code" cxx "$@" &&
        enable $name && eval ${name}_extralibs="\$@"
}
platform_check_lib_cxx(){
    log platform_check_lib_cxx "$@"
    name="$1"
    headers="$2"
    classes="$3"
    shift 3
    disable $name
    platform_check_class_headers_cxx "$headers" "$classes" "$@" &&
        enable $name && eval ${name}_extralibs="\$@"
}
platform_test_pkg_config(){
    log platform_test_pkg_config "$@"
    name="$1"
    pkg_version="$2"
    pkg="${2%% *}"
    headers="$3"
    funcs="$4"
    shift 4
    disable $name
    platform_test_cmd $pkg_config --exists --print-errors "$pkg_version" || return
    pkg_cflags=$($pkg_config --cflags $pkg_config_flags $pkg)
    pkg_libs=$($pkg_config --libs $pkg_config_flags $pkg)
    pkg_incdir=$($pkg_config --variable=includedir $pkg_config_flags $pkg)
    platform_check_func_headers "$headers" "$funcs" $pkg_cflags $pkg_libs "$@" &&
        enable $name &&
        set_sanitized "${name}_cflags"    $pkg_cflags &&
        set_sanitized "${name}_incdir"    $pkg_incdir &&
        set_sanitized "${name}_extralibs" $pkg_libs
}
platform_test_pkg_config_cpp(){
    log platform_test_pkg_config_cpp "$@"
    name="$1"
    pkg_version="$2"
    pkg="${2%% *}"
    headers="$3"
    cond="$4"
    shift 4
    disable $name
    platform_test_cmd $pkg_config --exists --print-errors "$pkg_version" || return
    pkg_cflags=$($pkg_config --cflags $pkg_config_flags $pkg)
    pkg_incdir=$($pkg_config --variable=includedir $pkg_config_flags $pkg)
    pkg_incflags=$($pkg_config --cflags-only-I $pkg_config_flags $pkg)
    platform_test_cpp_condition "$pkg_incdir/$headers" "$cond" $pkg_cflags "$@" &&
        enable $name &&
        set_sanitized "${name}_cflags" $pkg_cflags &&
        set_sanitized "${name}_incdir" $pkg_incdir &&
        set_sanitized "${name}_incflags" $pkg_incflags
}
platform_check_pkg_config(){
    log platform_check_pkg_config "$@"
    name="$1"
    platform_test_pkg_config "$@" &&
        eval add_cflags \$${name}_cflags
}
platform_check_pkg_config_cpp(){
    log platform_check_pkg_config_cpp "$@"
    name="$1"
    platform_test_pkg_config_cpp "$@" &&
        eval add_cflags \$${name}_cflags
}
platform_check_pkg_config_header_only(){
    log platform_check_pkg_config_cpp "$@"
    name="$1"
    platform_test_pkg_config_cpp "$@" &&
        eval add_cflags \$${name}_incflags
}
platform_test_exec(){
    platform_test_ld "cc" "$@" && { enabled cross_compile || $TMPE >> $logfile 2>&1; }
}
platform_check_exec_crash(){
    log platform_check_exec_crash "$@"
    code=$(cat)

    # exit() is not async signal safe.  _Exit (C99) and _exit (POSIX)
    # are safe but may not be available everywhere.  Thus we use
    # raise(SIGTERM) instead.  The check is run in a subshell so we
    # can redirect the "Terminated" message from the shell.  SIGBUS
    # is not defined by standard C so it is used conditionally.

    (platform_test_exec "$@") >> $logfile 2>&1 <<EOF
#include <signal.h>
static void sighandler(int sig){
    raise(SIGTERM);
}
int foo(void){
    $code
}
int (*func_ptr)(void) = foo;
int main(void){
    signal(SIGILL, sighandler);
    signal(SIGFPE, sighandler);
    signal(SIGSEGV, sighandler);
#ifdef SIGBUS
    signal(SIGBUS, sighandler);
#endif
    return func_ptr();
}
EOF
}
platform_check_type(){
    headers=$1
    type=$2
    progress_parts "check_type $type" $headers
    log platform_check_type "$@"
    shift 2
    disable_sanitized "$type"
    platform_test_code cc "$headers" "$type v" "$@" && enable_sanitized "$type"
}
platform_check_objc_class(){
    headers=$1
    type=$2
    progress_parts "check_objc_class $type" $headers
    log platform_check_objc_class "$@"
    shift 2
    disable_sanitized "$type"
    platform_test_code objcc "$headers" "$type* v" "$@" && enable_sanitized "$type"
}
platform_check_struct(){
    headers=$1
    struct=$2
    member=$3
    progress_parts "check_struct ${struct}.${member}" $headers
    log platform_check_struct "$@"
    shift 3
    disable_sanitized "${struct}_${member}"
    platform_test_code cc "$headers" "const void *p = &(($struct *)0)->$member" "$@" &&
        enable_sanitized "${struct}_${member}"
}
platform_check_builtin(){
    progress "check_builtin $1"
    log platform_check_builtin "$@"
    name=$1
    headers=$2
    builtin=$3
    shift 3
    disable "$name"
    platform_test_code ld "$headers" "$builtin" "cc" "$@" && enable "$name"
}
platform_check_compile_assert(){
    progress "check_compile_assert $1"
    log platform_check_compile_assert "$@"
    name=$1
    headers=$2
    condition=$3
    shift 3
    disable "$name"
    platform_test_code cc "$headers" "char c[2 * !!($condition) - 1]" "$@" && enable "$name"
}
platform_check_cc(){
    progress "check_cc $1"
    log platform_check_cc "$@"
    name=$1
    shift
    disable "$name"
    platform_test_code cc "$@" && enable "$name"
}
platform_require(){
    log platform_require "$@"
    name_version="$1"
    name="${1%% *}"
    shift
    platform_check_lib $name "$@" || die "ERROR: $name_version not found"
}
platform_require_cc(){
    progress "require_cc $1"
    log platform_require_cc "$@"
    name="$1"
    platform_check_cc "$@" || die "ERROR: $name failed"
}
platform_require_cxx(){
    progress "require_cxx $1"
    log platform_require_cxx "$@"
    name_version="$1"
    name="${1%% *}"
    shift
    platform_check_lib_cxx "$name" "$@" || die "ERROR: $name_version not found"
}
platform_require_cpp(){
    progress "require_cpp $1"
    log platform_require_cpp "$@"
    name_version="$1"
    name="${1%% *}"
    shift
    platform_check_lib_cpp "$name" "$@" || die "ERROR: $name_version not found"
}
platform_require_headers(){
    progress "require_headers $1"
    log platform_require_headers "$@"
    headers="$1"
    platform_check_headers "$@" || die "ERROR: $headers not found"
}
platform_require_cpp_condition(){
    progress "require_cpp_condition $1"
    log platform_require_cpp_condition "$@"
    condition="$3"
    platform_check_cpp_condition "$@" || die "ERROR: $condition not satisfied"
}
platform_require_pkg_config(){
    progress "require_pkg_config $1"
    log platform_require_pkg_config "$@"
    pkg_version="$2"
    platform_check_pkg_config "$@" || die "ERROR: $pkg_version not found using pkg-config$pkg_config_fail_message"
}
platform_require_pkg_config_cpp(){
    progress "require_pkg_config_cpp $1"
    log platform_require_pkg_config_cpp "$@"
    pkg_version="$2"
    platform_check_pkg_config_cpp "$@" || die "ERROR: $pkg_version not found using pkg-config$pkg_config_fail_message"
}
platform_test_host_cc(){
    log platform_test_host_cc "$@"
    cat > $TMPC
    log_file $TMPC
    platform_test_cmd $host_cc $host_cflags "$@" $HOSTCC_C $(hostcc_o $TMPO) $TMPC
}
platform_test_host_cpp(){
    log platform_test_host_cpp "$@"
    cat > $TMPC
    log_file $TMPC
    platform_test_cmd $host_cc $host_cppflags $host_cflags "$@" $(hostcc_e $TMPO) $TMPC
}
platform_check_host_cppflags(){
    progress "check_host_cppflags $1"
    log platform_check_host_cppflags "$@"
    platform_test_host_cpp "$@" <<EOF && append host_cppflags "$@"
#include <stdlib.h>
EOF
}
platform_check_host_cflags(){
    progress "check_host_cflags $1"
    log platform_check_host_cflags "$@"
    set -- $($host_cflags_filter "$@")
    platform_test_host_cc "$@" <<EOF && append host_cflags "$@"
int x;
EOF
}
platform_test_host_cflags_cc(){
    log platform_test_host_cflags_cc "$@"
    flags=$1
    header=$2
    condition=$3
    shift 3
    set -- $($host_cflags_filter "$flags")
    platform_test_host_cc "$@" <<EOF
#include <$header>
#if !($condition)
#error "unsatisfied condition: $condition"
#endif
EOF
}
platform_check_host_cflags_cc(){
    progress "check_host_cflags_cc $1"
    log platform_check_host_cflags_cc "$@"
    flags=$1
    platform_test_host_cflags_cc "$@" && add_host_cflags $flags
}
platform_test_host_cpp_condition(){
    log platform_test_host_cpp_condition "$@"
    header=$1
    condition=$2
    shift 2
    platform_test_host_cpp "$@" <<EOF
#include <$header>
#if !($condition)
#error "unsatisfied condition: $condition"
#endif
EOF
}
platform_check_host_cpp_condition(){
    progress "check_host_cpp_condition $1"
    log platform_check_host_cpp_condition "$@"
    name=$1
    shift 1
    disable $name
    platform_test_host_cpp_condition "$@" && enable $name
}
platform_probe_cc(){
    pfx=$1
    _cc=$2
    first=$3

    unset _type _ident _cc_c _cc_e _cc_o _flags _cflags _cxxflags
    unset _ld_o _ldflags _ld_lib _ld_path
    unset _depflags _DEPCMD _DEPFLAGS _DEPCCFLAGS _DEPCXXFLAGS
    _flags_filter=echo

    if $_cc --version 2>&1 | grep -q '^GNU assembler'; then
        true # no-op to avoid reading stdin in following checks
    elif $_cc -v 2>&1 | grep -q '^gcc.*LLVM'; then
        _type=llvm_gcc
        gcc_extra_ver=$(expr "$($_cc --version 2>/dev/null | head -n1)" : '.*\((.*)\)')
        _ident="llvm-gcc $($_cc -dumpversion 2>/dev/null) $gcc_extra_ver"
        _depflags='-MMD -MF $(@:.o=.d) -MT $@'
        _cflags_speed='-O3'
        _cflags_size='-Os'
    elif $_cc -v 2>&1 | grep -qi ^gcc; then
        _type=gcc
        gcc_version=$($_cc --version | head -n1)
        gcc_basever=$($_cc -dumpversion)
        gcc_pkg_ver=$(expr "$gcc_version" : '[^ ]* \(([^)]*)\)')
        gcc_ext_ver=$(expr "$gcc_version" : ".*$gcc_pkg_ver $gcc_basever \\(.*\\)")
        _ident=$(cleanws "gcc $gcc_basever $gcc_pkg_ver $gcc_ext_ver")
        case $gcc_basever in
            2) ;;
            2.*) ;;
            *) _depflags='-MMD -MF $(@:.o=.d) -MT $@' ;;
        esac
        if [ "$first" = true ]; then
            case $gcc_basever in
                4.2*)
                warn "gcc 4.2 is outdated and may miscompile FFmpeg. Please use a newer compiler." ;;
            esac
        fi
        _cflags_speed='-O3'
        _cflags_size='-Os'
    elif $_cc --version 2>/dev/null | grep -q ^icc; then
        _type=icc
        _ident=$($_cc --version | head -n1)
        _depflags='-MMD'
        _cflags_speed='-O3'
        _cflags_size='-Os'
        _flags_filter=icc_flags
    elif $_cc -v 2>&1 | grep -q xlc; then
        _type=xlc
        _ident=$($_cc -qversion 2>/dev/null | head -n1)
        _cflags_speed='-O5'
        _cflags_size='-O5 -qcompact'
    elif $_cc --vsn 2>/dev/null | grep -Eq "ARM (C/C\+\+ )?Compiler"; then
        test -d "$sysroot" || die "No valid sysroot specified."
        _type=armcc
        _ident=$($_cc --vsn | grep -i build | head -n1 | sed 's/.*: //')
        armcc_conf="$PWD/armcc.conf"
        $_cc --arm_linux_configure                 \
             --arm_linux_config_file="$armcc_conf" \
             --configure_sysroot="$sysroot"        \
             --configure_cpp_headers="$sysinclude" >>$logfile 2>&1 ||
             die "Error creating armcc configuration file."
        $_cc --vsn | grep -q RVCT && armcc_opt=rvct || armcc_opt=armcc
        _flags="--arm_linux_config_file=$armcc_conf --translate_gcc"
        as_default="${cross_prefix}gcc"
        _depflags='-MMD'
        _cflags_speed='-O3'
        _cflags_size='-Os'
    elif $_cc -v 2>&1 | grep -q clang && ! $_cc -? > /dev/null 2>&1; then
        _type=clang
        _ident=$($_cc --version 2>/dev/null | head -n1)
        _depflags='-MMD -MF $(@:.o=.d) -MT $@'
        _cflags_speed='-O3'
        _cflags_size='-Oz'
    elif $_cc -V 2>&1 | grep -q Sun; then
        _type=suncc
        _ident=$($_cc -V 2>&1 | head -n1 | cut -d' ' -f 2-)
        _DEPCMD='$(DEP$(1)) $(DEP$(1)FLAGS) $($(1)DEP_FLAGS) $< | sed -e "1s,^.*: ,$@: ," -e "\$$!s,\$$, \\\," -e "1!s,^.*: , ," > $(@:.o=.d)'
        _DEPFLAGS='-xM1 -x$stdc'
        _ldflags='-std=$stdc'
        _cflags_speed='-O5'
        _cflags_size='-O5 -xspace'
        _flags_filter=suncc_flags
    elif $_cc -v 2>&1 | grep -q 'PathScale\|Path64'; then
        _type=pathscale
        _ident=$($_cc -v 2>&1 | head -n1 | tr -d :)
        _depflags='-MMD -MF $(@:.o=.d) -MT $@'
        _cflags_speed='-O2'
        _cflags_size='-Os'
        _flags_filter='filter_out -Wdisabled-optimization'
    elif $_cc -v 2>&1 | grep -q Open64; then
        _type=open64
        _ident=$($_cc -v 2>&1 | head -n1 | tr -d :)
        _depflags='-MMD -MF $(@:.o=.d) -MT $@'
        _cflags_speed='-O2'
        _cflags_size='-Os'
        _flags_filter='filter_out -Wdisabled-optimization|-Wtype-limits|-fno-signed-zeros'
    elif $_cc 2>&1 | grep -q 'Microsoft.*ARM.*Assembler'; then
        _type=armasm
        _ident=$($_cc | head -n1)
        # 4509: "This form of conditional instruction is deprecated"
        _flags="-nologo -ignore 4509"
        _flags_filter=armasm_flags
    elif $_cc 2>&1 | grep -q Intel; then
        _type=icl
        _ident=$($_cc 2>&1 | head -n1)
        _depflags='-QMMD -QMF$(@:.o=.d) -QMT$@'
        # Not only is O3 broken on 13.x+ but it is slower on all previous
        # versions (tested) as well.
        _cflags_speed="-O2"
        _cflags_size="-O1 -Oi" # -O1 without -Oi miscompiles stuff
        if $_cc 2>&1 | grep -q Linker; then
            _ld_o='-out:$@'
        else
            _ld_o='-Fe$@'
        fi
        _cc_o='-Fo$@'
        _cc_e='-P'
        _flags_filter=icl_flags
        _ld_lib='%.lib'
        _ld_path='-libpath:'
        # -Qdiag-error to make icl error when seeing certain unknown arguments
        _flags='-nologo -Qdiag-error:4044,10157'
        # -Qvec- -Qsimd- to prevent miscompilation, -GS, fp:precise for consistency
        # with MSVC which enables it by default.
        _cflags='-Qms0 -Qvec- -Qsimd- -GS -fp:precise'
        disable stripping
    elif $_cc -? 2>/dev/null | grep -q 'LLVM.*Linker'; then
        # lld can emulate multiple different linkers; in ms link.exe mode,
        # the -? parameter gives the help output which contains an identifiable
        # string, while it gives an error in other modes.
        _type=lld-link
        # The link.exe mode doesn't have a switch for getting the version,
        # but we can force it back to gnu mode and get the version from there.
        _ident=$($_cc -flavor gnu --version 2>/dev/null)
        _ld_o='-out:$@'
        _flags_filter=msvc_flags_link
        _ld_lib='%.lib'
        _ld_path='-libpath:'
    elif VSLANG=1033 $_cc -nologo- 2>&1 | grep -q ^Microsoft || { $_cc -v 2>&1 | grep -q clang && $_cc -? > /dev/null 2>&1; }; then
        _type=msvc
        if VSLANG=1033 $_cc -nologo- 2>&1 | grep -q ^Microsoft; then
            # Depending on the tool (cl.exe or link.exe), the version number
            # is printed on the first line of stderr or stdout
            _ident=$(VSLANG=1033 $_cc 2>&1 | grep ^Microsoft | head -n1 | tr -d '\r')
        else
            _ident=$($_cc --version 2>/dev/null | head -n1 | tr -d '\r')
        fi
        if [ -x "$(command -v wslpath)" ]; then
            _DEPCMD='$(DEP$(1)) $(DEP$(1)FLAGS) $($(1)DEP_FLAGS) $< 2>&1 | awk '\''/including/ { sub(/^.*file: */, ""); if (!match($$0, / /)) { print $$0 } }'\'' | xargs -r -d\\n -n1 wslpath -u | awk '\''BEGIN { printf "%s:", "$@" }; { sub(/\r/,""); printf " %s", $$0 }; END { print "" }'\'' > $(@:.o=.d)'

        else
            _DEPCMD='$(DEP$(1)) $(DEP$(1)FLAGS) $($(1)DEP_FLAGS) $< 2>&1 | awk '\''/including/ { sub(/^.*file: */, ""); gsub(/\\/, "/"); if (!match($$0, / /)) print "$@:", $$0 }'\'' > $(@:.o=.d)'
        fi
        _DEPFLAGS='$(CPPFLAGS) -showIncludes -Zs'
        _DEPCCFLAGS='$(CFLAGS)'
        _DEPCXXFLAGS='$(CXXFLAGS)'
        _cflags_speed="-O2"
        _cflags_size="-O1"
        if $_cc -nologo- 2>&1 | grep -q Linker; then
            _ld_o='-out:$@'
            _flags_filter=msvc_flags_link
        else
            _ld_o='-Fe$@'
            _flags_filter=msvc_flags
        fi
        _cc_o='-Fo$@'
        _cc_e='-P -Fi$@'
        _ld_lib='%.lib'
        _ld_path='-libpath:'
        _flags='-nologo'
        _cxxflags='-Zc:__cplusplus -EHsc'
        disable stripping
    elif $_cc --version 2>/dev/null | grep -q ^cparser; then
        _type=cparser
        _ident=$($_cc --version | head -n1)
        _depflags='-MMD'
        _cflags_speed='-O4'
        _cflags_size='-O2'
        _flags_filter=cparser_flags
    fi

    eval ${pfx}_type=\$_type
    eval ${pfx}_ident=\$_ident
}
platform_check_64bit(){
    progress "check_64bit $1"
    arch32=$1
    arch64=$2
    expr=${3:-'sizeof(void *) > 4'}
    platform_test_code cc "" "int test[2*($expr) - 1]" &&
        subarch=$arch64 || subarch=$arch32
    enable $subarch
}
platform_probe_libc(){
    pfx=$1
    pfx_no_=${pfx%_}
    # uclibc defines __GLIBC__, so it needs to be checked before glibc.
    if platform_test_${pfx}cpp_condition features.h "defined __UCLIBC__"; then
        eval ${pfx}libc_type=uclibc
        add_${pfx}cppflags -D_POSIX_C_SOURCE=200112 -D_XOPEN_SOURCE=600
    elif platform_test_${pfx}cpp_condition features.h "defined __GLIBC__"; then
        eval ${pfx}libc_type=glibc
        add_${pfx}cppflags -D_POSIX_C_SOURCE=200112 -D_XOPEN_SOURCE=600
    # MinGW headers can be installed on Cygwin, so check for newlib first.
    elif platform_test_${pfx}cpp_condition newlib.h "defined _NEWLIB_VERSION"; then
        eval ${pfx}libc_type=newlib
        add_${pfx}cflags -U__STRICT_ANSI__
        add_${pfx}cppflags -D_XOPEN_SOURCE=600
    # MinGW64 is backwards compatible with MinGW32, so check for it first.
    elif platform_test_${pfx}cpp_condition _mingw.h "defined __MINGW64_VERSION_MAJOR"; then
        eval ${pfx}libc_type=mingw64
        if platform_test_${pfx}cpp_condition _mingw.h "__MINGW64_VERSION_MAJOR < 3"; then
            add_compat msvcrt/snprintf.o
            add_allcflags "-include $source_path/compat/msvcrt/snprintf.h"
        fi
        add_${pfx}cflags -U__STRICT_ANSI__
        if ! platform_test_${pfx}cpp_condition crtdefs.h "defined(_UCRT)"; then
            add_${pfx}cppflags -D__USE_MINGW_ANSI_STDIO=1
        fi
        platform_test_${pfx}cpp_condition windows.h "!defined(_WIN32_WINNT) || _WIN32_WINNT < 0x0600" &&
            add_${pfx}cppflags -D_WIN32_WINNT=0x0600
        add_${pfx}cppflags -D_POSIX_C_SOURCE=200112 -D_XOPEN_SOURCE=600
    elif platform_test_${pfx}cpp_condition _mingw.h "defined __MINGW_VERSION"  ||
         platform_test_${pfx}cpp_condition _mingw.h "defined __MINGW32_VERSION"; then
        eval ${pfx}libc_type=mingw32
        platform_test_${pfx}cpp_condition _mingw.h "__MINGW32_MAJOR_VERSION > 3 || \
            (__MINGW32_MAJOR_VERSION == 3 && __MINGW32_MINOR_VERSION >= 15)" ||
            die "ERROR: MinGW32 runtime version must be >= 3.15."
        add_${pfx}cflags -U__STRICT_ANSI__
        if ! platform_test_${pfx}cpp_condition crtdefs.h "defined(_UCRT)"; then
            add_${pfx}cppflags -D__USE_MINGW_ANSI_STDIO=1
        fi
        platform_test_${pfx}cpp_condition _mingw.h "__MSVCRT_VERSION__ < 0x0700" &&
            add_${pfx}cppflags -D__MSVCRT_VERSION__=0x0700
        platform_test_${pfx}cpp_condition windows.h "!defined(_WIN32_WINNT) || _WIN32_WINNT < 0x0600" &&
            add_${pfx}cppflags -D_WIN32_WINNT=0x0600
        add_${pfx}cppflags -D_POSIX_C_SOURCE=200112 -D_XOPEN_SOURCE=600
    elif platform_test_${pfx}cpp_condition crtversion.h "defined _VC_CRT_MAJOR_VERSION"; then
        eval ${pfx}libc_type=msvcrt
        if platform_test_${pfx}cpp_condition crtversion.h "_VC_CRT_MAJOR_VERSION < 14"; then
            if [ "$pfx" = host_ ]; then
                add_host_cppflags -Dsnprintf=_snprintf
            else
                add_compat strtod.o strtod=avpriv_strtod
                add_compat msvcrt/snprintf.o snprintf=avpriv_snprintf   \
                                             _snprintf=avpriv_snprintf  \
                                             vsnprintf=avpriv_vsnprintf
            fi
        fi
        add_${pfx}cppflags -D_USE_MATH_DEFINES -D_CRT_SECURE_NO_WARNINGS -D_CRT_NONSTDC_NO_WARNINGS
        # The MSVC 2010 headers (Win 7.0 SDK) set _WIN32_WINNT to
        # 0x601 by default unless something else is set by the user.
        # This can easily lead to us detecting functions only present
        # in such new versions and producing binaries requiring windows 7.0.
        # Therefore explicitly set the default to Vista unless the user has
        # set something else on the command line.
        # Don't do this if WINAPI_FAMILY is set and is set to a non-desktop
        # family. For these cases, configure is free to use any functions
        # found in the SDK headers by default. (Alternatively, we could force
        # _WIN32_WINNT to 0x0602 in that case.)
        platform_test_${pfx}cpp_condition stdlib.h "defined(_WIN32_WINNT)" ||
            { platform_test_${pfx}cpp <<EOF && add_${pfx}cppflags -D_WIN32_WINNT=0x0600; }
#ifdef WINAPI_FAMILY
#include <winapifamily.h>
#if !WINAPI_FAMILY_PARTITION(WINAPI_PARTITION_DESKTOP)
#error not desktop
#endif
#endif
EOF
        if [ "$pfx" = "" ]; then
            platform_check_func strtoll || add_allcflags -Dstrtoll=_strtoi64
            platform_check_func strtoull || add_allcflags -Dstrtoull=_strtoui64
        fi
    elif platform_test_${pfx}cpp_condition stddef.h "defined __KLIBC__"; then
        eval ${pfx}libc_type=klibc
    elif platform_test_${pfx}cpp_condition sys/cdefs.h "defined __BIONIC__"; then
        eval ${pfx}libc_type=bionic
    elif platform_test_${pfx}cpp_condition sys/brand.h "defined LABELED_BRAND_NAME"; then
        eval ${pfx}libc_type=solaris
        add_${pfx}cppflags -D__EXTENSIONS__ -D_XOPEN_SOURCE=600
    elif platform_test_${pfx}cpp_condition sys/version.h "defined __DJGPP__"; then
        eval ${pfx}libc_type=djgpp
        add_cppflags -U__STRICT_ANSI__
        add_allcflags "-include $source_path/compat/djgpp/math.h"
        add_compat djgpp/math.o
    fi
    platform_test_${pfx}cc <<EOF
#include <time.h>
void *v = localtime_r;
EOF
test "$?" != 0 && platform_test_${pfx}cc -D_POSIX_C_SOURCE=200112 -D_XOPEN_SOURCE=600 <<EOF && add_${pfx}cppflags -D_POSIX_C_SOURCE=200112 -D_XOPEN_SOURCE=600
#include <time.h>
void *v = localtime_r;
EOF

    eval test -n "\${${pfx}libc_type}" && enable ${pfx}libc_${libc_type}
}
platform_check_gas(){
    progress "check_gas $1"
    log "check_gas using '$as' as AS"
    # :vararg is used on aarch64, arm and ppc altivec
    platform_check_as vararg "
.macro m n, y:vararg=0
\n: .int \y
.endm
m x" || return 1
    # .altmacro is only used in arm asm
    ! enabled arm || platform_check_as gnu_as ".altmacro"
}
platform_probe_glslc(){
    glslc_probe=$1
    if platform_test_cmd $glslc_probe -v; then
        # glslang/glslangValidator
        glslc=$glslc_probe
        glslcflags="-V --target-env spirv1.6"
        glslc_opt_speed=""
        glslc_opt_size="-Os"
        glslc_opt_none="-Od"
        glslc_debug="-gVS"
        GLSLC_DEPFLAGS='--depfile $(@:.spv=.d)'
    elif platform_test_cmd $glslc_probe --version; then
        # glslc
        glslc=$glslc_probe
        glslcflags="--target-env=vulkan1.4 --target-spv=spv1.6"
        glslc_opt_speed="-O"
        glslc_opt_size="-Os"
        glslc_opt_none="-O0"
        glslc_debug="-g"
        GLSLC_DEPFLAGS='-MD -MF $(@:.spv=.d) -MT $@'
    else
        disable spirv_compiler
        return 1
    fi
    platform_check_glslc spirv_compiler || return 0

    append GLSLCFLAGS $glslcflags
    if enabled small; then
        append GLSLCFLAGS $glslc_opt_size
    elif enabled optimizations; then
        append GLSLCFLAGS $glslc_opt_speed
    else
        append GLSLCFLAGS $glslc_opt_none
    fi
    if enabled debug; then
        append GLSLCFLAGS $glslc_debug
    fi
}
platform_check_disable_warning(){
    progress "check_disable_warning $1"
    warning_flag=-W${1#-Wno-}
    platform_test_cflags $unknown_warning_flags $warning_flag && add_cflags $1
    platform_test_cxxflags -Werror $unknown_warning_flags $warning_flag && add_cxxflags $1
    platform_test_objcflags $unknown_warning_flags $warning_flag && add_objcflags $1
}
platform_check_disable_warning_headers(){
    progress "check_disable_warning_headers $1"
    warning_flag=-W${1#-Wno-}
    platform_test_cflags $warning_flag && add_cflags_headers $1
}
platform_check_optflags(){
    progress "check_optflags $1"
    platform_check_allcflags "$@"
    [ -n "$lto" ] && platform_check_ldflags "$@"
}