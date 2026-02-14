import argparse
import codegen

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('input')
    parser.add_argument('var_prefix')
    parser.add_argument('vars', nargs='*')
    parser.add_argument('--output', '-o', default=None)
    args = parser.parse_args()
    codegen.cmd_makefile_to_cmake(args)
