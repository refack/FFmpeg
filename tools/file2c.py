
import sys
import os

def main():
    if len(sys.argv) < 4:
        print("Usage: file2c.py <input> <output> <varname>")
        sys.exit(1)

    input_path = sys.argv[1]
    output_path = sys.argv[2]
    var_name = sys.argv[3]

    with open(input_path, 'rb') as f_in, open(output_path, 'w') as f_out:
        data = f_in.read()
        f_out.write(f"#include <stdint.h>\n")
        f_out.write(f"const unsigned int ff_{var_name}_len = {len(data)};\n")
        f_out.write(f"const unsigned char ff_{var_name}_data[] = {{\n")
        for i, byte in enumerate(data):
            f_out.write(f"0x{byte:02x}, ")
            if (i + 1) % 16 == 0:
                f_out.write("\n")
        f_out.write("\n0\n};\n")

if __name__ == "__main__":
    main()
