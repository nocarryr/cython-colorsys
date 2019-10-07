#! /usr/bin/env python

from pathlib import Path
import subprocess
import shlex

TEST_DIR = Path(__file__).resolve().parent / 'tests'

def run():
    pyx_pattern = str(TEST_DIR / '*.pyx')
    cmd_str = 'cythonize -b -i {}'.format(pyx_pattern)
    print(cmd_str)
    subprocess.call(shlex.split(cmd_str))

if __name__ == '__main__':
    run()
