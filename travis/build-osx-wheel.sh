#!/bin/bash

export MINCONDA_VERSION="latest"
export MINCONDA_OS="MacOSX-x86_64"
wget "http://repo.continuum.io/miniconda/Miniconda3-$MINCONDA_VERSION-$MINCONDA_OS.sh" -O miniconda.sh
bash miniconda.sh -b -p $HOME/miniconda
export PATH="$HOME/miniconda/bin:$PATH"
conda config --set always_yes yes --set changeps1 no
conda create -n build_env python=${PYTHON_VERSION}
source activate build_env
python --version

conda install cmake scikit-build -c conda-forge

python setup.py bdist_wheel

pip install --find-links=dist xeus_python

pip install pytest jupyter_kernel_test

pytest test/ -v
