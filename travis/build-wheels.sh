#!/bin/bash

set -e -x

# Compile wheels
for PYBIN in /opt/python/*/bin; do
    "${PYBIN}/pip" install -r io/dev-requirements.txt
    "${PYBIN}/python" /io/setup.py bdist_wheel
done
