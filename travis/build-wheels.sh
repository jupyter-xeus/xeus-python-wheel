#!/bin/bash

set -e -x

# Compile wheels
for PYBIN in /opt/python/cp3*/bin; do
    if [ "${PYBIN}" == "/opt/python/cp35-cp35m/bin" ]; then
        "${PYBIN}/pip" install scikit-build 
        "${PYBIN}/pip" install -r /io/dev-requirements.txt
        "${PYBIN}/pip" wheel /io/ -w /io/wheelhouse/
    fi
done

# Install packages and test
for PYBIN in /opt/python/cp3*/bin; do
    if [ "${PYBIN}" == "/opt/python/cp35-cp35m/bin" ]; then
        "${PYBIN}/pip" install --verbose xeus-python --no-index -f /io/wheelhouse
        ls -al /io/
        (cd /io/test; "${PYBIN}/pytest" . -v)
    fi
done

