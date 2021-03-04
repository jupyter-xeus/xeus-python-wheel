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

# Dependencies
# ============

set(ZEROMQ_GIT_TAG        v4.3.2)
set(CPPZMQ_GIT_TAG        v4.7.1)
set(XTL_GIT_TAG           0.7.2)
set(JSON_GIT_TAG          v3.7.3)
set(XEUS_GIT_TAG          1.0.1)
set(PYBIND11_GIT_TAG      v2.6.0)
set(PYBIND11_JSON_GIT_TAG 0.2.9)
# set(XEUS_PYTHON_GIT_TAG   0.11.2)
set(XEUS_PYTHON_GIT_TAG   6fcaffb9a08f42c21c23415dc199b4c7155d7e0a)
# set(XEUS_ROBOT_GIT_TAG    0.3.0)
set(XEUS_ROBOT_GIT_TAG    9aaf0c46a0fa310f3a4983e8268c3f7446bdcb9a)

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

set(XEUS_DISABLE_ARCH_NATIVE ON CACHE BOOL "remove -march=native flag" FORCE)
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
set(XPYT_BUILD_SHARED OFF CACHE BOOL "Do not build xeus-python shared object" FORCE)
set(XPYT_BUILD_STATIC ON CACHE BOOL "Build xeus-python static library" FORCE)
set(XPYT_USE_SHARED_XEUS OFF CACHE BOOL "Link statically with libxeus.a" FORCE)
set(XPYT_USE_SHARED_XEUS_PYTHON OFF CACHE BOOL "Link statically with libxeus-python.a" FORCE)
set(XPYT_BUILD_XPYTHON_EXECUTABLE OFF CACHE BOOL "Do not build xpython executable" FORCE)
set(XPYT_BUILD_XPYTHON_EXTENSION OFF CACHE BOOL "Build xpython extension module" FORCE)

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

# Xeus-Robot
# -----------

message(STATUS "Fetching xeus-robot")

set(XROBOT_KERNELSPEC_PATH "")

set(XROB_DISABLE_ARCH_NATIVE ON CACHE BOOL "remove -march=native flag" FORCE)
set(XROB_ENABLE_PYPI_WARNING ON CACHE BOOL "Enable PyPI warning for xrobot" FORCE)
set(XROB_USE_SHARED_XEUS_PYTHON OFF CACHE BOOL "Link statically with libxeus-python.a" FORCE)
set(XROB_BUILD_XROBOT_EXECUTABLE OFF CACHE BOOL "Do not build xrobot executable" FORCE)
set(XROB_BUILD_XROBOT_EXTENSION ON CACHE BOOL "Build xrobot extension module" FORCE)

FetchContent_Declare(
  xeus-robot
  GIT_REPOSITORY https://github.com/martinRenou/xeus-robot
  GIT_TAG ${XEUS_ROBOT_GIT_TAG}
)

FetchContent_GetProperties(xeus-robot)

if(NOT xeus-robot_POPULATED)
  FetchContent_Populate(xeus-robot)
  add_subdirectory(${xeus-robot_SOURCE_DIR} ${xeus-robot_BINARY_DIR})
endif()

# Manually install xrobot_extension library in the xrobot directory
install(TARGETS xrobot_extension
        LIBRARY DESTINATION xrobot)

# Kernelspec
# ----------

get_filename_component(XROB_PYTHON_EXECUTABLE_PATH ${PYTHON_EXECUTABLE} REALPATH)
get_filename_component(XROB_PYTHON_EXECUTABLE_NAME ${XROB_PYTHON_EXECUTABLE_PATH} NAME)
message(STATUS "Python executable name: " ${XROB_PYTHON_EXECUTABLE_NAME})

configure_file (
    "${CMAKE_CURRENT_SOURCE_DIR}/kernels/xrobot/kernel.json.in"
    "${CMAKE_CURRENT_SOURCE_DIR}/kernels/xrobot/kernel.json"
)

# Configuration and data directories for jupyter and xrobot
set(XJUPYTER_DATA_DIR "share/jupyter" CACHE STRING "Jupyter data directory")

# Install xrobot Jupyter kernelspec
set(XROB_KERNELSPEC_DIR ${CMAKE_CURRENT_SOURCE_DIR}/kernels)
install(DIRECTORY ${XROB_KERNELSPEC_DIR}
        DESTINATION ${XJUPYTER_DATA_DIR}
        PATTERN "*.in" EXCLUDE)
