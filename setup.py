from setuptools import setup, Extension

ext_modules = [Extension('cycolorsys._cycolorsys', ['src/cycolorsys/_cycolorsys.pyx'])]

setup(
    ext_modules = ext_modules,
)
