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

def accept_file(name):
    return not (
        name.endswith('.a') or      # static libraries
        name.endswith('.hpp') or    # headers
        name.endswith('.h') or      # headers
        name.endswith('.cmake') or  # cmake files
        name.endswith('.pc') or     # package-config files
        name.endswith('.txt')       # text files
    )

def cmake_process_manifest_hook(cmake_manifest):
    print(cmake_manifest)
    print('\n\n')
    cmake_manifest = list(filter(accept_file, cmake_manifest))
    print(cmake_manifest)
    return cmake_manifest

setup(
    name="xeus-robot",
    version="0.3.0",
    description='A wheel for xeus-robot',
    author='Sylvain Corlay, Johan Mabille, Martin Renou',
    license='',
    packages=['xrobot'],
    py_modules=['xrobot_launcher'],
    install_requires=[
        'pygments>=2.3.1,<3',
        'robotframework-interpreter>=0.6.3,<0.7',
        'robotframework-lsp',
        'jupyterlab_robotmode',
        'ipython>=7.20,<8'
    ],
    setup_requires=setup_requires,
    cmake_args=['-DCMAKE_INSTALL_LIBDIR=lib', '-DPYTHON_EXECUTABLE:FILEPATH=' + python_path],
    cmake_process_manifest_hook=cmake_process_manifest_hook
)
