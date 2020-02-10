#!/bin/bash

set -e -x

# Compile wheels
for PYBIN in /opt/python/*/bin; do
    ${PYBIN}/python setup.py bdist_wheel /io/
done
