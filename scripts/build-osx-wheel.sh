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

pip install -r dev-requirements.txt
pip wheel . --verbose -w wheelhouse

pip install --find-links=wheelhouse xeus_robot

cd test
pytest ./ -v
