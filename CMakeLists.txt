cmake_minimum_required(VERSION 3.4.0)

project(wheel)
set(WHEEL_VERSION 0.1.0)

# To use cmake modules/functions or FindXXX files:
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")
include(GNUInstallDirs) # Define CMAKE_INSTALL_xxx: LIBDIR, INCLUDEDIR
set(wheel_export_file "${PROJECT_BINARY_DIR}/wheelTargets.cmake")

set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" "${CMAKE_CURRENT_SOURCE_DIR}")
set(CMAKE_POSITION_INDEPENDENT_CODE ON CACHE BOOL "Enable position independent code" FORCE)

# Default to static build
set(BUILD_STATIC_LIBS ON CACHE BOOL "enable static build of xeus" FORCE)
set(BUILD_SHARED_LIBS OFF CACHE BOOL "disable shared build of xeus" FORCE)

message(STATUS "PYTHON_EXECUTABLE is ${PYTHON_EXECUTABLE}")
message(STATUS "CMAKE_LIBRARY_PATH is ${CMAKE_LIBRARY_PATH}")
message(STATUS "OPENSSL_CONFIG is ${OPENSSL_CONFIG}")
message(STATUS "LIBSODIUM CONFIG is ${LIBSODIUM_CONFIG}")

# Dependencies
# ============

set(ZEROMQ_GIT_TAG        v4.3.2)
set(CPPZMQ_GIT_TAG        v4.7.1)
set(XTL_GIT_TAG           0.7.2)
set(JSON_GIT_TAG          v3.7.3)
set(XEUS_GIT_TAG          3.0.3)
set(XEUS_ZMQ_GIT_TAG      1.0.2)
set(PYBIND11_GIT_TAG      v2.10.0)
set(PYBIND11_JSON_GIT_TAG 0.2.11)
set(XEUS_PYTHON_GIT_TAG   0.15.12)

# pre-build non-cmake dependencies
# ================================

configure_file(External_OpenSSL.cmake.in OpenSSL-download/CMakeLists.txt @ONLY)
configure_file(bcryptgen.patch.in OpenSSL-download/bcryptgen.patch @ONLY)
configure_file(commoncrypto.patch.in OpenSSL-download/commoncrypto.patch @ONLY)
execute_process(COMMAND ${CMAKE_COMMAND} -G "${CMAKE_GENERATOR}" -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
                    -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER} -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} .
                RESULT_VARIABLE result
                WORKING_DIRECTORY
                ${CMAKE_CURRENT_BINARY_DIR}/OpenSSL-download)
execute_process(COMMAND ${CMAKE_COMMAND} --build .
                RESULT_VARIABLE result
                WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/OpenSSL-download )
if(result)
    message(FATAL_ERROR "CMake step for OpenSSL failed: ${result}")
endif()

# This makes sure that find_package(OpenSSL) finds the version we built
set(OPENSSL_ROOT_DIR "${CMAKE_INSTALL_PREFIX}")

if(UNIX AND NOT APPLE)
  configure_file(External_libuuid.cmake.in libuuid-download/CMakeLists.txt @ONLY)
  execute_process(COMMAND ${CMAKE_COMMAND} -G "${CMAKE_GENERATOR}" -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
                    -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER} -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} .
                  RESULT_VARIABLE result
                  WORKING_DIRECTORY
                  ${CMAKE_CURRENT_BINARY_DIR}/libuuid-download)
  execute_process(COMMAND ${CMAKE_COMMAND} --build .
                  RESULT_VARIABLE result
                  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/libuuid-download )
  if(result)
    message(FATAL_ERROR "CMake step for libuuid failed: ${result}")
  endif()
endif()

if(UNIX)
  configure_file(External_libsodium.cmake.in libsodium-download/CMakeLists.txt @ONLY)
  execute_process(COMMAND ${CMAKE_COMMAND} -G "${CMAKE_GENERATOR}"  -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
                      -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER} -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} .
                  RESULT_VARIABLE result
                  WORKING_DIRECTORY
                  ${CMAKE_CURRENT_BINARY_DIR}/libsodium-download)
  execute_process(COMMAND ${CMAKE_COMMAND} --build .
                  RESULT_VARIABLE result
                  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/libsodium-download )
endif()

# Fetch and build cmake dependencies
# ==================================

include(FetchContent)


# LibZMQ
# ------

message(STATUS "Libzmq")

set(BUILD_SHARED OFF CACHE BOOL "enable libzmq shared build" FORCE)
set(BUILD_STATIC ON CACHE BOOL "enable libzmq static build" FORCE)
set(WITH_DOC OFF CACHE BOOL "do not generate libzmq documentation" FORCE)
set(BUILD_TESTS OFF CACHE BOOL "do not build libzmq tests" FORCE)
set(ENABLE_CPACK OFF CACHE BOOL "disable cpack rules" FORCE)

if(WIN32)
  set(WITH_LIBSODIUM OFF CACHE BOOL "do not use libsodium in zeromq" FORCE)
endif()

FetchContent_Declare(
  libzmq
  GIT_REPOSITORY https://github.com/zeromq/libzmq
  GIT_TAG ${ZEROMQ_GIT_TAG}
)

FetchContent_GetProperties(libzmq)

if(NOT libzmq_POPULATED)
  FetchContent_Populate(libzmq)
  add_subdirectory(${libzmq_SOURCE_DIR} ${libzmq_BINARY_DIR})
endif()

# CppZMQ
# ------

message(STATUS "Fetching cppzmq")

set(CPPZMQ_BUILD_TESTS OFF CACHE BOOL "Don't build cppzmq tests" FORCE)

FetchContent_Declare(
  cppzmq
  GIT_REPOSITORY https://github.com/zeromq/cppzmq
  GIT_TAG ${CPPZMQ_GIT_TAG}
)

FetchContent_GetProperties(cppzmq)

if(NOT cppzmq_POPULATED)
  FetchContent_Populate(cppzmq)
  add_subdirectory(${cppzmq_SOURCE_DIR} ${cppzmq_BINARY_DIR})
endif()

# Nlohmann_JSON
# -------------

message(STATUS "Fetching nlohmann_json")

set(BUILD_TESTING OFF CACHE BOOL "do not build nlohmann_json tests" FORCE)

FetchContent_Declare(
  nlohmann_json
  GIT_REPOSITORY https://github.com/nlohmann/json
  GIT_TAG ${JSON_GIT_TAG}
)

FetchContent_GetProperties(nlohmann_json)

if(NOT nlohmann_json_POPULATED)
  FetchContent_Populate(nlohmann_json)
  add_subdirectory(${nlohmann_json_SOURCE_DIR} ${nlohmann_json_BINARY_DIR})
endif()

# Xtl
# ---

message(STATUS "Fetching xtl")

set(BUILD_TESTS OFF CACHE BOOL "do not build xtl tests" FORCE)

FetchContent_Declare(
  xtl
  GIT_REPOSITORY https://github.com/xtensor-stack/xtl
  GIT_TAG ${XTL_GIT_TAG}
)

FetchContent_GetProperties(xtl)

if(NOT xtl_POPULATED)
  FetchContent_Populate(xtl)
  add_subdirectory(${xtl_SOURCE_DIR} ${xtl_BINARY_DIR})
endif()


# Xeus
# ----

message(STATUS "Fetching xeus")

set(XEUS_STATIC_DEPENDENCIES ON CACHE BOOL "links with static libraries" FORCE)
set(XEUS_BUILD_SHARED_LIBS OFF CACHE BOOL "Do not build xeus shared object" FORCE)
set(XEUS_BUILD_STATIC_LIBS ON CACHE BOOL "Build xeus static library" FORCE)

FetchContent_Declare(
  xeus
  GIT_REPOSITORY https://github.com/jupyter-xeus/xeus
  GIT_TAG ${XEUS_GIT_TAG}
)

FetchContent_GetProperties(xeus)

if(NOT xeus_POPULATED)
  FetchContent_Populate(xeus)
  add_subdirectory(${xeus_SOURCE_DIR} ${xeus_BINARY_DIR})
endif()


# Xeus Zmq
# --------

message(STATUS "Fetching xeus zmq")

set(XEUS_ZMQ_STATIC_DEPENDENCIES ON CACHE BOOL "links with static libraries" FORCE)
set(XEUS_ZMQ_BUILD_SHARED_LIBS OFF CACHE BOOL "Do not build xeus shared object" FORCE)
set(XEUS_ZMQ_BUILD_STATIC_LIBS ON CACHE BOOL "Build xeus static library" FORCE)

FetchContent_Declare(
  xeus_zmq
  GIT_REPOSITORY https://github.com/jupyter-xeus/xeus-zmq
  GIT_TAG ${XEUS_ZMQ_GIT_TAG}
)

FetchContent_GetProperties(xeus_zmq)

if(NOT xeus_zmq_POPULATED)
  FetchContent_Populate(xeus_zmq)
  add_subdirectory(${xeus_zmq_SOURCE_DIR} ${xeus_zmq_BINARY_DIR})
endif()

# Pybind11
# --------

message(STATUS "Fetching pybind11")

set(PYBIND11_TEST OFF)

FetchContent_Declare(
  pybind11
  GIT_REPOSITORY https://github.com/pybind/pybind11
  GIT_TAG ${PYBIND11_GIT_TAG}
)

FetchContent_GetProperties(pybind11)

if(NOT pybind11_POPULATED)
  FetchContent_Populate(pybind11)
  add_subdirectory(${pybind11_SOURCE_DIR} ${pybind11_BINARY_DIR})
endif()

# Pybind11_JSON
# -------------

message(STATUS "Fetching pybind11_json")

FetchContent_Declare(
  pybind11_json
  GIT_REPOSITORY https://github.com/pybind/pybind11_json
  GIT_TAG ${PYBIND11_JSON_GIT_TAG}
)

FetchContent_GetProperties(pybind11_json)

if(NOT pybind11_json_POPULATED)
  FetchContent_Populate(pybind11_json)
  add_subdirectory(${pybind11_json_SOURCE_DIR} ${pybind11_json_BINARY_DIR})
endif()

# Xeus-Python
# -----------

message(STATUS "Fetching xeus-python")

set(XPYTHON_KERNELSPEC_PATH "")

set(XPYT_DISABLE_ARCH_NATIVE ON CACHE BOOL "remove -march=native flag" FORCE)
set(XPYT_ENABLE_PYPI_WARNING ON CACHE BOOL "Enable PyPI warning for xeus-python" FORCE)
set(XPYT_BUILD_SHARED OFF CACHE BOOL "Do not build xeus-python shared object" FORCE)
set(XPYT_BUILD_STATIC ON CACHE BOOL "Build xeus-python static library" FORCE)
set(XPYT_USE_SHARED_XEUS OFF CACHE BOOL "Link statically with libxeus.a" FORCE)
set(XPYT_USE_SHARED_XEUS_PYTHON OFF CACHE BOOL "Link statically with libxeus-python.a" FORCE)
set(XPYT_BUILD_XPYTHON_EXECUTABLE OFF CACHE BOOL "Do not build xpython executable" FORCE)
set(XPYT_BUILD_XPYTHON_EXTENSION ON CACHE BOOL "Build xpython extension module" FORCE)

FetchContent_Declare(
  xeus-python
  GIT_REPOSITORY https://github.com/jupyter-xeus/xeus-python
  GIT_TAG ${XEUS_PYTHON_GIT_TAG}
)

FetchContent_GetProperties(xeus-python)
if(NOT xeus-python_POPULATED)
  FetchContent_Populate(xeus-python)
  add_subdirectory(${xeus-python_SOURCE_DIR} ${xeus-python_BINARY_DIR})
endif()

# Manually install xpython_extension library in the xpython directory
install(TARGETS xpython_extension
        LIBRARY DESTINATION xpython)

# Kernelspec
# ----------

get_filename_component(XPYT_PYTHON_EXECUTABLE_PATH ${PYTHON_EXECUTABLE} REALPATH)
get_filename_component(XPYT_PYTHON_EXECUTABLE_NAME ${XPYT_PYTHON_EXECUTABLE_PATH} NAME)
message(STATUS "Python executable name: " ${XPYT_PYTHON_EXECUTABLE_NAME})

configure_file (
    "${CMAKE_CURRENT_SOURCE_DIR}/kernels/xpython/kernel.json.in"
    "${CMAKE_CURRENT_SOURCE_DIR}/kernels/xpython/kernel.json"
)

configure_file (
    "${CMAKE_CURRENT_SOURCE_DIR}/kernels/xpython-raw/kernel.json.in"
    "${CMAKE_CURRENT_SOURCE_DIR}/kernels/xpython-raw/kernel.json"
)

# Configuration and data directories for jupyter and xeus-python
set(XJUPYTER_DATA_DIR "share/jupyter" CACHE STRING "Jupyter data directory")

# Install xpython Jupyter kernelspec
set(XPYT_KERNELSPEC_DIR ${CMAKE_CURRENT_SOURCE_DIR}/kernels)
install(DIRECTORY ${XPYT_KERNELSPEC_DIR}
        DESTINATION ${XJUPYTER_DATA_DIR}
        PATTERN "*.in" EXCLUDE)
