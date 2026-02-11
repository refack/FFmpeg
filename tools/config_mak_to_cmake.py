
import sys

def main():
    if len(sys.argv) < 3:
        print("Usage: config_mak_to_cmake.py <config.mak> <config.cmake>")
        sys.exit(1)

    config_mak = sys.argv[1]
    config_cmake = sys.argv[2]

    with open(config_mak, 'r') as f_in, open(config_cmake, 'w') as f_out:
        f_out.write("# Generated from config.mak\n\n")

        for line in f_in:
            line = line.strip()
            if not line or line.startswith('#'):
                continue

            # Handle !CONFIG_VAR=yes -> set(CONFIG_VAR OFF) or just omit it?
            # FFmpeg makefiles use !VAR=yes to mean VAR is not set (or false).
            # Wait, !CONFIG_DOC=yes usually means it is explicitly disabled?
            # Let's check config.mak again.

            if '=' not in line:
                continue

            key, value = line.split('=', 1)
            key = key.strip()
            value = value.strip()

            if key.startswith('!'):
                # !CONFIG_DOC=yes means CONFIG_DOC is disabled.
                real_key = key[1:]
                f_out.write(f"set({real_key} OFF)\n")
            else:
                # CONFIG_DOC=yes means CONFIG_DOC is enabled.
                if value == 'yes':
                    f_out.write(f"set({key} ON)\n")
                else:
                    # Handle string values
                    # Escape quotes
                    value = value.replace('"', '\\"')
                    f_out.write(f'set({key} "{value}")\n')

if __name__ == "__main__":
    main()
