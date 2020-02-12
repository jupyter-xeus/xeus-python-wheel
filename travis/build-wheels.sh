#!/bin/bash

set -e -x

find /opt/python/ -name "pip" -print
find /opt/python/ -name "*.a" -print
ls -al /opt/python/cp35-cp35m/lib/python3.5/
# Compile wheels
#for PYBIN in /opt/python/cp3*/bin; do
#    if [ "${PYBIN}" != "/opt/python/cp34-cp34m/bin" ]; then
        #"${PYBIN}/pip" install -r /io/dev-requirements.txt
#        "${PYBIN}/pip" install scikit-build 
#        "${PYBIN}/pip" install cmake
#        "${PYBIN}/pip" wheel /io/ -w wheelhouse/
#    fi
#done
