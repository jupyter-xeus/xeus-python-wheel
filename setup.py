import sys

try:
    from skbuild import setup
    from skbuild.exceptions import SKBuildError
    from skbuild.cmaker import get_cmake_version
    from packaging.version import LegacyVersion

    setup_requires = []
    try:
        if LegacyVersion(get_cmake_version()) < LegacyVersion("3.15"):
            setup_requires.append('cmake')
    except SKBuildError:
        setup_requires.append('cmake')
except ImportError:
    print('scikit-build is required to build from source.', file=sys.stderr)
    print('Please run:', file=sys.stderr)
    print('', file=sys.stderr)
    print('  python -m pip install scikit-build')
    sys.exit(1)

python_path = sys.executable

setup(
    name="xeus-python",
    version="0.6.8",
    description='A wheel for xeus-python',
    author='Sylvain Corlay, Johan Mabille',
    license='',
    packages=[],
    setup_requires=setup_requires,
    #cmake=['-DHELLO_BUILD_TESTING:BOOL=TRUE',]
    cmake_args=['-DCMAKE_INSTALL_LIBDIR=lib', '-DPYTHON_EXECUTABLE:FILEPATH='+python_path]
)
