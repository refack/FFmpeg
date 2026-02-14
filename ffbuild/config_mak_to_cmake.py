import argparse
import codegen

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('input')
    parser.add_argument('output')
    args = parser.parse_args()
    codegen.cmd_config_mak_to_cmake(args)
