#!/bin/bash

set -e -x

# Compile wheels
for PYBIN in /opt/python/*/bin; do
    ${PYBIN}/python /io/setup.py bdist_wheel
done
