import argparse
import codegen

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('input')
    parser.add_argument('output')
    parser.add_argument('var_name')
    args = parser.parse_args()
    codegen.cmd_file2c(args)
