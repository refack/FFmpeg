#!/bin/sh

# Generate CMake configuration
echo "Generating ffbuild/config.cmake..."
python ffbuild/codegen.py config_mak_to_cmake ffbuild/config.mak ffbuild/config.cmake

# Generate CMake source lists
echo "Generating CMake source lists..."
for lib_dir in libavutil libswscale libswresample libavcodec libavformat libavdevice libavfilter fftools; do
    lib_name_upper=$(echo "$lib_dir" | tr '[:lower:]' '[:upper:]')
    source_list_file="$lib_dir/Makefile"

    if [ "$lib_dir" = "fftools" ]; then
        output_file="$lib_dir/sources.cmake"
        python ffbuild/codegen.py makefile_to_cmake "$lib_dir/ffmpeg.sourcelist.mak" FFMPEG TARGET_COND_ffmpeg=CONFIG_FFMPEG ARCH=$arch -o "$output_file"
        python ffbuild/codegen.py makefile_to_cmake "$lib_dir/ffprobe.sourcelist.mak" FFPROBE TARGET_COND_ffprobe=CONFIG_FFPROBE ARCH=$arch -o "$output_file" --append
        python ffbuild/codegen.py makefile_to_cmake "$lib_dir/ffplay.sourcelist.mak" FFPLAY TARGET_COND_ffplay=CONFIG_FFPLAY ARCH=$arch -o "$output_file" --append
        python ffbuild/codegen.py makefile_to_cmake "$lib_dir/resources/resobjs.sourcelist.mak" FFMPEG FORCE_COND=CONFIG_FFMPEG ARCH=$arch -o "$output_file" --append
        continue
    fi

    python ffbuild/codegen.py makefile_to_cmake "$source_list_file" "$lib_name_upper" ARCH=$arch -o "$lib_dir/sources.cmake"
#    # Append arch-specific sources
#    if [ -f "$lib_dir/$arch/Makefile" ]; then
#        python ffbuild/codegen.py makefile_to_cmake "$lib_dir/$arch/Makefile" "$lib_name_upper" ARCH=$arch -o "$lib_dir/sources.cmake" --append
#    fi
done

