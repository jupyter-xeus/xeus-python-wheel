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

try:
    import pathlib
    import re
    cmake = pathlib.Path(__file__).parent / 'CMakeLists.txt'
    xeus_version = None
    with open(str(cmake)) as f:
        for line in f:
            m = re.search(r'XEUS_PYTHON_GIT_TAG\s+([^\s)]+)', line)
            if m is not None: 
                xeus_version = m.group(1)

    if xeus_version is None:
        raise ValueError("Couldn't find the version in CMakeLists.txt")
except Exception as e:
    print('Could not determine the version of xeus_python')
    print(e)
    sys.exit(1) 


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
    name="xeus-python",
    version=xeus_version,
    description='A wheel for xeus-python',
    author='Sylvain Corlay, Johan Mabille',
    license='',
    packages=['xpython'],
    py_modules=['xpython_launcher'],
    install_requires=[
        'jedi>=0.15.1,<0.18',
        'pygments>=2.3.1,<3',
        'debugpy>=1.1.0'
    ],
    setup_requires=setup_requires,
    cmake_args=['-DCMAKE_INSTALL_LIBDIR=lib', '-DPYTHON_EXECUTABLE:FILEPATH=' + python_path],
    cmake_process_manifest_hook=cmake_process_manifest_hook
)
