# Xeus-python-wheel

This project holds the recipe for building PyPI wheels for the [xeus-python](https://github.com/jupyter-xeus/xeus-python) project.

The CI produces wheels for Linux (`manylinux2010_x86_64`), OS X (`Xcode 9.4.1`), and Windows (x64).

## Building the wheels locally

The following packages must be installed in the environment to build xeus-python-wheel:

- `cmake`
- `scikit-build`
- `perl` (required to build `OpenSSL`)
- `nasm` (required to build `OpenSSL` on Windows)

The `pytest` package is also required to test the resulting package.

To build the wheel in your local environment, run

```
python setup.py bdist_wheel
```

from the source directory.
