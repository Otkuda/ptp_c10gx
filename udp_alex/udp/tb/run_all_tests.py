import os
import argparse
from pathlib import Path


#
# Usage:
#   run_all_tests test_var
#

test_dir = Path(".")
parser = argparse.ArgumentParser()

parser.add_argument("test_var", help="Which tests to run: myhdl")

args = parser.parse_args()

def run_myhdl_tests():
    for el in test_dir.iterdir():
        if el.is_file() and str(el).startswith("test_") and str(el).endswith(".py"):
            try:
                out = os.popen(f"timeout -s SIGQUIT 120 pytest {el} | grep -e '{el}'").readline()
                with open('tests_res.txt', 'a') as f:
                    f.write(out)
            except Exception as e:
                print(e)

if os.path.exists("tests_res.txt"):
    os.remove("tests_res.txt")

if args.test_var == "myhdl":
    run_myhdl_tests()


