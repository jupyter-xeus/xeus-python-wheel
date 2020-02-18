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
        find /opt/ -name "libxeus-python.so"
        export PATH_BU=$PATH
        export LD_LIBRARY_PATH_BU=$LD_LIBRARY_PATH
        export PATH=$PATH:${PYBIN}
        export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/_internal/cpython-3.5.9/lib
        ldd ${PYBIN}/xpython
        (cd /io/test; "${PYBIN}/pytest" . -v)
        export PATH=$PATH_BU
        export LD_LIBRARY_PATH=$LD_LIBRARY_PATH_BU
    fi
done

