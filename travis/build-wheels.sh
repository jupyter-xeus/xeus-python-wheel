#!/bin/bash

set -e -x

# Compile wheels
for PYBIN in /opt/python/cp3*/bin; do
    if [ "${PYBIN}" != "/opt/python/cp34-cp34m/bin" ]; then
        "${PYBIN}/pip" install -r /io/dev-requirements.txt
        "${PYBIN}/pip" wheel /io/ -w wheelhouse/
    fi
done
