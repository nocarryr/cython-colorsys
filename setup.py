import sys

CY_ANNOTATE = '--annotate' in sys.argv
if CY_ANNOTATE:
    sys.argv.remove('--annotate')

from setuptools import setup, Extension

try:
    from Cython.Compiler import Options as CyOptions
except ImportError:
    CyOptions = None

if CY_ANNOTATE:
    CyOptions.annotate = True

ext_modules = [
    Extension('cycolorsys._cycolorsys', ['src/cycolorsys/_cycolorsys.pyx']),
    Extension('cycolorsys.colorobj', ['src/cycolorsys/colorobj.pyx']),
]

setup(
    ext_modules = ext_modules,
)
