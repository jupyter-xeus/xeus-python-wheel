#!/bin/bash
set -e -x

# Compile wheels
echo Compiling wheels:
for PYBIN in /opt/python/cp3*/bin; do
    if [ "${PYBIN}" != "/opt/python/cp34-cp34m/bin" ] && [ "${PYBIN}" != "/opt/python/cp35-cp35m/bin" ] && [ "${PYBIN}" != "/opt/python/cp36-cp36m/bin" ]; then
        "${PYBIN}/pip" install -r /io/dev-requirements.txt
        "${PYBIN}/pip" wheel /io/ -w wheels/
        # "${PYBIN}/pip" wheel /io/ --verbose -w /io/wheelhouse/
    fi
done

# Relabel wheels into manylinux
echo Built wheels:
ls wheels/*.whl

echo Invoking auditwheel:
for whl in wheels/xeus_robot*.whl; do
    auditwheel repair "$whl" --plat $PLAT -w /io/wheelhouse/
done

echo Relabelled wheels:
ls /io/wheelhouse/*.whl

echo Copy platform-independent wheels:
cp wheels/*-any.whl /io/wheelhouse/

echo Testing wheels:
# Install packages and test
for PYBIN in /opt/python/cp3*/bin; do
    export LD_LIBRARY_PATH_BU=$LD_LIBRARY_PATH
    export PATH_BU=$PATH
    export PATH=$PATH:${PYBIN}
    if [ "${PYBIN}" == "/opt/python/cp34-cp34m/bin" ] || [ "${PYBIN}" == "/opt/python/cp35-cp35m/bin" ] || [ "${PYBIN}" == "/opt/python/cp36-cp36m/bin" ]; then
        continue
    elif [ "${PYBIN}" == "/opt/python/cp37-cp37m/bin" ]; then
        export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/_internal/cpython-3.7.6/lib
    elif [ "${PYBIN}" == "/opt/python/cp38-cp38m/bin" ]; then
        export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/_internal/cpython-3.8.1/lib
    fi
    # "${PYBIN}/pip" install xeus-robot --no-index -f /io/wheelhouse
    # (cd /io/test; "${PYBIN}/pytest" . -v)
    export PATH=$PATH_BU
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH_BU
done
