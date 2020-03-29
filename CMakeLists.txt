cmake_minimum_required(VERSION 3.4.0)

project(wheel)
set(WHEEL_VERSION 0.1.0)

# To use cmake modules/functions or FindXXX files:
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")
include(GNUInstallDirs) # Define CMAKE_INSTALL_xxx: LIBDIR, INCLUDEDIR
set(wheel_export_file "${PROJECT_BINARY_DIR}/wheelTargets.cmake")

set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" "${CMAKE_CURRENT_SOURCE_DIR}")

# Default to static build
set(BUILD_STATIC_LIBS ON CACHE BOOL "enable static build of xeus" FORCE)
set(BUILD_SHARED_LIBS OFF CACHE BOOL "disable shared build of xeus" FORCE)

message(STATUS "PYTHON_EXECUTABLE is ${PYTHON_EXECUTABLE}")

set(CMAKE_LIBRARY_PATH "${CMAKE_LIBRARY_PATH} opt/python/cp35-cp35m/lib/")
message(STATUS "CMAKE_LIBRARY_PATH is ${CMAKE_LIBRARY_PATH}")

# Dependencies
# ============

set(ZEROMQ_GIT_TAG        v4.3.2)
set(CPPZMQ_GIT_TAG        master)
set(XTL_GIT_TAG           0.6.12)
set(JSON_GIT_TAG          v3.7.3)
set(XEUS_GIT_TAG          0.23.9)
set(PYBIND11_GIT_TAG      v2.3)
set(PYBIND11_JSON_GIT_TAG 0.2.4)
set(XEUS_PYTHON_GIT_TAG   0.6.13)

# pre-build non-cmake dependencies
# ================================

configure_file(External_OpenSSL.cmake.in OpenSSL-download/CMakeLists.txt @ONLY)
configure_file(bcryptgen.patch.in OpenSSL-download/bcryptgen.patch @ONLY)
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

configure_file(External_libsodium.cmake.in libsodium-download/CMakeLists.txt @ONLY)
execute_process(COMMAND ${CMAKE_COMMAND} -G "${CMAKE_GENERATOR}"  -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
                    -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER} -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} .
                RESULT_VARIABLE result
                WORKING_DIRECTORY
                ${CMAKE_CURRENT_BINARY_DIR}/libsodium-download)
execute_process(COMMAND ${CMAKE_COMMAND} --build .
                RESULT_VARIABLE result
                WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/libsodium-download )

# Fetch and build cmake dependencies
# ==================================

include(FetchContent)

message(STATUS "Fetching libzmq")
set(BUILD_SHARED OFF CACHE BOOL "enable libzmq shared build" FORCE)
set(BUILD_STATIC ON CACHE BOOL "enable libzmq static build" FORCE)
set(WITH_DOC OFF CACHE BOOL "do not generate libzmq documentation" FORCE)
set(BUILD_TESTS OFF CACHE BOOL "do not build libzmq tests" FORCE)

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

message(STATUS "Fetching xeus")
set(XEUS_DISABLE_ARCH_NATIVE ON CACHE BOOL "remove -march=native flag" FORCE)
set(XEUS_STATIC_DEPENDENCIES ON CACHE BOOL "links with static libraries" FORCE)
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

set(XPYTHON_KERNELSPEC_PATH "")
set(XPYT_DISABLE_ARCH_NATIVE ON CACHE BOOL "remove -march=native flag" FORCE)
set(XPYT_STATIC_DEPENDENCIES ON CACHE BOOL "links with static library" FORCE)
set(XPYT_ENABLE_PYPI_WARNING ON CACHE BOOL "Enable warning on PyPI wheels" FORCE)

string(REPLACE "." ";" VERSION_LIST ${PYTHON_VERSION_STRING})
list(GET VERSION_LIST 0 PY_VERSION_MAJOR)
list(GET VERSION_LIST 1 PY_VERSION_MINOR)
list(GET VERSION_LIST 2 PY_VERSION_PATCH)
set(XPYT_SEP ":") # TODO: use ";" on windows

string(CONCAT XEUS_SYSPATH
 "" ${XPYT_SEP}
# Standard sys.path
 "{PREFIX}/lib/python${PY_VERSION_MAJOR}${PY_VERSION_MINOR}.zip" ${XPYT_SEP}
 "{PREFIX}/lib/python${PY_VERSION_MAJOR}.${PY_VERSION_MINOR}" ${XPYT_SEP}
 "{PREFIX}/lib/python${PY_VERSION_MAJOR}.${PY_VERSION_MINOR}/lib-dynload" ${XPYT_SEP}
 "{PREFIX}/lib/python${PY_VERSION_MAJOR}.${PY_VERSION_MINOR}/site-packages" ${XPYT_SEP}
# Same with "..". Some Linux distributions are such that Python packages are split between /usr and /usr/local.
 "{PREFIX}/../lib/python${PY_VERSION_MAJOR}${PY_VERSION_MINOR}.zip" ${XPYT_SEP}
 "{PREFIX}/../lib/python${PY_VERSION_MAJOR}.${PY_VERSION_MINOR}" ${XPYT_SEP}
 "{PREFIX}/../lib/python${PY_VERSION_MAJOR}.${PY_VERSION_MINOR}/lib-dynload" ${XPYT_SEP}
 "{PREFIX}/../lib/python${PY_VERSION_MAJOR}.${PY_VERSION_MINOR}/site-packages" ${XPYT_SEP}
# Same with "lib64". Some Linux distributions patch CPython to use lib64 instead of lib.
 "{PREFIX}/lib64/python${PY_VERSION_MAJOR}${PY_VERSION_MINOR}.zip" ${XPYT_SEP}
 "{PREFIX}/lib64/python${PY_VERSION_MAJOR}.${PY_VERSION_MINOR}" ${XPYT_SEP}
 "{PREFIX}/lib64/python${PY_VERSION_MAJOR}.${PY_VERSION_MINOR}/lib-dynload" ${XPYT_SEP}
 "{PREFIX}/lib64/python${PY_VERSION_MAJOR}.${PY_VERSION_MINOR}/site-packages" ${XPYT_SEP}
 "{PREFIX}/../lib64/python${PY_VERSION_MAJOR}${PY_VERSION_MINOR}.zip" ${XPYT_SEP}
 "{PREFIX}/../lib64/python${PY_VERSION_MAJOR}.${PY_VERSION_MINOR}" ${XPYT_SEP}
 "{PREFIX}/../lib64/python${PY_VERSION_MAJOR}.${PY_VERSION_MINOR}/lib-dynload" ${XPYT_SEP}
 "{PREFIX}/../lib64/python${PY_VERSION_MAJOR}.${PY_VERSION_MINOR}/site-packages" ${XPYT_SEP}
)
set(XPYT_SYSPATH ${XEUS_SYSPATH} CACHE BOOL "Set relative paths" FORCE)

message(STATUS "Fetching xeus-python")
FetchContent_Declare(
  xeus-python
  GIT_REPOSITORY https://github.com/jupyter-xeus/xeus-python
  GIT_TAG ${XEUS_PYTHON_GIT_TAG}
)

FetchContent_GetProperties(xeus-python)
if(NOT xeus-python_POPULATED)
  FetchContent_Populate(xeus-python)
  message(STATUS "Enabling PyPI warning for xeus-python")
  set(XEUS_ENABLE_PYPI_WARNING ON CACHE BOOL "Enable PyPI warning for xeus-python" FORCE)
  add_subdirectory(${xeus-python_SOURCE_DIR} ${xeus-python_BINARY_DIR})
endif()

